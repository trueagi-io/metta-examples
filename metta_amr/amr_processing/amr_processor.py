import logging
import penman
import penman.models.noop


_spacy_model = 'en_core_web_md'
_penman_model = penman.models.noop.NoOpModel()

def _load_spacy():
    #return spacy.load(_spacy_model)
    # There is no API to inject own model into amrlib pipeline. I keep this
    # code because I don't like reimplementing internal `add_lemmas` logic
    # using own spacy model
    global _spacy_model_cache
    if _spacy_model_cache is None:
        from amrlib.graph_processing.annotator import load_spacy
        load_spacy(_spacy_model)
        from amrlib.graph_processing.annotator import spacy_nlp
        logging.getLogger(__name__).debug("_load_spacy(): %s is loaded",
                spacy_nlp.path)
        _spacy_model_cache = spacy_nlp

_stog_model_cache = None
_gtos_model_cache = None
_spacy_model_cache = None

def load_stog_model():
    global _stog_model_cache
    global _spacy_model_cache

    if (_stog_model_cache is None) or (_spacy_model_cache is None):
        import amrlib
        if _stog_model_cache is None:
            _stog_model_cache = amrlib.load_stog_model()
        _load_spacy()
        amrlib.setup_spacy_extension()

def load_gtos_model():
    global _gtos_model_cache
    if _gtos_model_cache is None:
        import amrlib
        _gtos_model_cache = amrlib.load_gtos_model()

def clean_subs(amrs):
    new_amrs = []
    for amr in amrs:
        to_del = []
        splitted = amr.split("-")
        for split in splitted:
            if split[:2].isdigit():
                to_del.append("-"+split[:2])
        for to_d in to_del:
            amr = amr.replace(to_d, "")
        new_amrs.append(amr)
    return new_amrs

class AmrProcessor:

    def __init__(self):
        self.log = logging.getLogger(__name__ + '.' + type(self).__name__)
        global _spacy_model_cache
        self.nlp = _spacy_model_cache
        global _gtos_model_cache
        self.gtos = _gtos_model_cache

    def utterance_to_amr(self, utterance, indent=-1):
        if self.nlp is None:
            load_stog_model()
            global _spacy_model_cache
            self.nlp = _spacy_model_cache

        doc = self.nlp(utterance)
        amrs = doc._.to_amr()
        amrs = clean_subs(amrs)
        sents = doc.sents
        triples_proc = []
        for p in zip(amrs, sents):
            # Entry point (amr text->triples); can be replaced with penman.decode
            triples, top = self._add_pos_tags(doc, p[0], p[1], indent)
            # further triples processing
            triples_proc += self._sentence_splitter(triples, top)
        return list(map(lambda ts: penman.encode(penman.Graph(ts), indent=indent, model=_penman_model),
                        triples_proc))

    def amr_to_utterance(self, amr):
        if self.gtos is None:
            load_gtos_model()
            global _gtos_model_cache
            self.gtos = _gtos_model_cache
        return self.gtos.generate([amr], use_tense=False)[0][0]

    def triples_to_utterance(self, triples):
        return self.amr_to_utterance(penman.encode(penman.Graph(triples)))

    def _add_pos_tags(self, doc, amr, sent, indent):
        self.log.debug('_add_pos_tags: amr: %s, sent: %s', amr, sent)

        from amrlib.alignments.rbw_aligner import RBWAligner
        from amrlib.graph_processing.annotator import add_lemmas

        graph = add_lemmas(amr, snt_key='snt')
        aligner = RBWAligner.from_penman_w_json(graph)
        graph = aligner.get_penman_graph()
        triples = graph.triples
        self.log.debug('_add_pos_tags: alignments: %s',
                penman.surface.alignments(graph))
        for triple, alignment in penman.surface.alignments(graph).items():
            pos_tag = doc[sent.start + alignment.indices[0]].tag_
            triples.append((triple[0], ':pos', '"' + pos_tag + '"'))
        self.log.debug('_add_pos_tags: triples: %s', triples)
        return triples, graph.top

    def _child_lnodes_rec(self, triples, parent):
        '''
        Returns all those nodes (possibly duplicated) in the subgraph (including `parent`)
        which appear on the left side of triples (i.e. not leaves)
        '''
        grandchildren = []
        isOnLeft = False
        for t in triples:
            if t[0] == parent:
                isOnLeft = True
                grandchildren += self._child_lnodes_rec(triples, t[2])
        return [parent] + grandchildren if isOnLeft else []

    def _sentence_splitter(self, triples, top):
        top_roles = []
        top_concept = None
        for triple in triples:
            if triple[0] == top:
                if triple[1] == ':instance':
                    top_concept = triple[2]
                elif triple[1] != ':pos':
                    top_roles += [(triple[1], triple[2])]
        if top_concept == 'and':
            expected = 'op'
        elif top_concept == 'multi-sentence':
            expected = 'snt'
        else: return [triples]
        # Just checking that there are no unexpected roles
        for r in top_roles:
            if not expected in r[0]:
                logging.getLogger(__name__).debug("_sentence_splitter(): WARNING - unexpected role %s for %s",
                                                r[0], top_concept)
                return [triples]
        subgraphs = [[[], self._child_lnodes_rec(triples, r[1])] for r in top_roles]
        for t in triples:
            for s in subgraphs:
                if t[0] in s[1]:
                    s[0] += [t]
        return [s[0] for s in subgraphs]
