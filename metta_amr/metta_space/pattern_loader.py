import io
import logging
import re

from amr_processing import TripleProcessor,  PatternInstanceDict, UtteranceParser, is_const, is_amr_set
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

        #self._index_amrsets()


