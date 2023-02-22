import io
import logging
import re

from amr_processing import TripleProcessor,  PatternInstanceDict,AmrInstanceDict, is_const, is_amr_set
_single_word_pattern = re.compile(r'^\S+$')
class PatternLoader:

    def __init__(self, amr_proc, amr_space):
        self.log = logging.getLogger(__name__ + '.' + type(self).__name__)
        self.amr_proc = amr_proc
        self.amr_space = amr_space
        self.utterance_parser= UtteranceParser(self.amr_proc)
        self.triple_proc = TripleProcessor(PatternInstanceDict)

    def load_file(self, file):
        self._process_triples(self.triple_proc.file_to_triples(file))

    def load_text(self, text):
        with io.StringIO(text) as file:
            self.load_file(file)

    def _process_triples(self, triples):

        for triple in triples:
            if is_amr_set(triple) and is_const(triple[2]):
                source, role, target = triple
                no_quotes = target[1:-1]
                if _single_word_pattern.search(no_quotes) is not None:
                    self.amr_space.add_triple(triple)
                else:
                    top = self.utterance_parser.parse_sentence(no_quotes)
                    self.amr_space.add_triple((source, role, top.name))
            else:
                self.amr_space.add_triple(triple)
            print("Triple :\n", triple)
            print("The atomspace contains:\n\n",  self.amr_space.get_atoms())
        #self._index_amrsets()
        #print("The atomspace contains:\n\n",  self.amr_space.atomspace.get_atoms_by_type(types.Atom))

class UtteranceParser:

    def __init__(self, amr_proc):
        self.log = logging.getLogger(__name__ + '.' + type(self).__name__)
        self.amr_proc = amr_proc
        self.triple_proc = TripleProcessor(AmrInstanceDict)
        # FIXME: NB: to have unique varible names we need importing all
        # triples into triple_proc before processing
        self.triple_proc.next_id = 500000

    def parse(self, text):
        # parse amr and return triples
        triples = []
        tops = []
        try:
            amrs = self.amr_proc.utterance_to_amr(text)
            for amr in amrs:
                parsed_amr = self.triple_proc.amr_to_triples(amr)
                tops.append(parsed_amr.tp)
                for triple in parsed_amr:
                    triples.append(triple)
        finally:
            return triples, tops



    def parse_sentence(self, text):
        triples, tops = self.parse(text)
        assert len(tops) == 1, 'Single sentence is expected as input'
        return tops[0]