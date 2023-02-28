import logging
import penman
import penman.models.noop

from amr_processing.type_detector import TypeDetector

_spacy_model = 'en_core_web_md'
_penman_model = penman.models.noop.NoOpModel()

def _remove_postfix(word):
    pos = word.rfind('-')
    return word[:pos] if pos > 0 else word

def triple_to_string(triple):
    source, role, target = triple
    return '(' + source + ', ' + role + ', ' + target + ')'

def triple_from_string(line):
    left = line.find('(')
    right = line.rfind(')')
    source, role, target = line[left+1:right].split(', ')
    return (source, role, target)

class AmrInstanceDict:

    def __init__(self, id_generator):
        self.log = logging.getLogger(__name__ + '.AmrInstanceDict')
        self.id_generator = id_generator
        self.instance_by_node = {}
        self.instance_triples = []

    def add_graph(self, graph):
        for triple in filter(TypeDetector.is_instance, graph.triples):
            self.log.debug('triple: %s', triple)
            (source, role, target) = triple
            instance = self._get_unique_instance(target)
            self.instance_by_node[source] = instance
            self.instance_triples.append((instance, role, target))

    def _get_unique_instance(self, target):
        id = self.id_generator()
        return target + '-' + '{:06d}'.format(id)

    def get_instance_triples(self):
        return self.instance_triples

    def map_node_to_instance(self, node):
        if node in self.instance_by_node:
            return self.instance_by_node[node]
        else:
            return node



_roles_with_attrs_at_right = { ':mode', ':pos', ':polarity' }

class PatternInstanceDict(AmrInstanceDict):

    def __init__(self, id_generator):
        super().__init__(id_generator)
        self.log = logging.getLogger(__name__ + '.PatternInstanceDict')

    def add_graph(self, graph):
        for triple in filter(TypeDetector.is_instance, graph.triples):
            node, instance_role, concept = triple
            assert not(TypeDetector.is_variable(node) and  TypeDetector.is_amrset_name(concept)), (
                '($var / @amrset) is not supported')
            assert not(node == '-' and  TypeDetector.is_variable(concept)), (
                '(- / $var) is not supported')
            if concept is None:
                continue
            if concept == '-':
                self.instance_by_node[node] = node
                continue
            instance = self._get_unique_instance(concept)
            self.instance_by_node[node] = instance
            self.instance_triples.append((instance, instance_role, concept))

        for triple in filter(lambda x: not TypeDetector.is_instance(x), graph.triples):
            self.log.debug('triple: %s', triple)
            source, role, target = triple
            self._add_instance(source, role, True)
            self._add_instance(target, role, False)

    def _add_instance(self, concept, role, is_source):
        if concept in self.instance_by_node:
            return
        elif  TypeDetector.is_variable(concept):
            self.instance_by_node[concept] = concept
            return
        elif TypeDetector.is_amrset_name(concept):
            if role == ':amr-set' and is_source:
                self.instance_by_node[concept] = concept
                return
        elif TypeDetector.is_const(concept):
            return
        elif not is_source and role in _roles_with_attrs_at_right:
            self.log.warn('Concept node is generated for the possible attribute '
            + 'name, please use (%s / -) if it is not expected', concept)
        instance = self._get_unique_instance(concept)
        self.instance_by_node[concept] = instance
        self.instance_triples.append((instance, ":instance", concept))

    def _get_unique_instance(self, target):
        if  TypeDetector.is_variable(target) or  TypeDetector.is_amrset_name(target):
            return super()._get_unique_instance(target[1:])
        else:
            return super()._get_unique_instance(target)

class ParsedAmr:

    def __init__(self, top, triples):
        self.top = top
        self.triples = triples

    def __iter__(self):
        return self.triples.__iter__()

    def get_top(self):
        return self.top

class TripleProcessor:

    def __init__(self, instance_dict_constr=AmrInstanceDict):
        self.log = logging.getLogger(__name__ + '.TripleProcessor')
        self.next_id = 0
        self.instance_dict_constr = instance_dict_constr

    def _process_relation(self, triple, amr_instances):
        self.log.debug('_process_relation: triple: %s', triple)
        (source, role, target) = triple
        source = amr_instances.map_node_to_instance(source)
        target = amr_instances.map_node_to_instance(target)
        return (source, role, target)

    def add_triple(self, triple):
        source, role, target = triple
        if role == ':instance':
            self._add_variable(source)

    def _add_variable(self, text):
        id = int(text.split('-')[-1])
        if self.next_id <= id:
            self.next_id = id + 1

    def _next_id(self):
        id = self.next_id
        self.next_id += 1
        return id

    def amr_to_triples(self, amr):
        graph = penman.decode(amr, model=_penman_model)
        return self._graph_to_triples(graph)

    def file_to_triples(self, file):
        for graph in penman.iterdecode(file, model=_penman_model):
            for triple in self._graph_to_triples(graph):
                yield triple

    def _graph_to_triples(self, graph):
        sentence_vars = {}
        amr_instances = self.instance_dict_constr(lambda: self._next_id())
        amr_instances.add_graph(graph)

        top = graph.top
        top = amr_instances.map_node_to_instance(top)

        return ParsedAmr(top, self._triples_generator(amr_instances, graph))

    def _triples_generator(self, amr_instances, graph):
        for triple in amr_instances.get_instance_triples():
            yield triple
        for triple in filter(lambda x: not TypeDetector.is_instance(x), graph.triples):
            yield self._process_relation(triple, amr_instances)


class UtteranceParser:

    def __init__(self, amr_proc, amr_space):
        self.log = logging.getLogger(__name__ + '.' + type(self).__name__)
        self.amr_proc = amr_proc
        self.amr_space = amr_space
        self.triple_proc = TripleProcessor(AmrInstanceDict)
        # FIXME: NB: to have unique varible names we need importing all
        # triples into triple_proc before processing
        self.triple_proc.next_id = 500000

    def parse_amr(self, amrs):
        sentences = []
        try:
            for amr in amrs:
                parsed_amr = self.triple_proc.amr_to_triples(amr)
                for triple in parsed_amr:
                    self.amr_space.add_triple(triple)
                sentences.append(parsed_amr.top)
        finally:
            return sentences

    def parse(self, text):
        sentences = []
        try:
            amrs = self.amr_proc.utterance_to_amr(text)
            sentences = self.parse_amr(amrs)
        finally:
            return sentences

    def parse_sentence(self, text):
        sentences = self.parse(text)
        assert len(sentences) == 1, 'Single sentence is expected as input'
        return sentences[0]