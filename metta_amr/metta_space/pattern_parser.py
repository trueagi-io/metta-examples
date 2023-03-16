import io
import logging
import re

from amr_processing import TripleProcessor,  PatternInstanceDict, UtteranceParser
#_single_word_pattern = re.compile(r'^\S+$')

class PatternParser:

    def __init__(self, amr_space):
        self.log = logging.getLogger(__name__ + '.' + type(self).__name__)
        self.amr_space = amr_space
        self.triple_proc = TripleProcessor(PatternInstanceDict)

    def load_file(self, file):
        self._process_triples(self.triple_proc.file_to_triples(file))

    def load_text(self, text):
        with io.StringIO(text) as file:
            self.load_file(file)

    def load_templates(self, templates):
        self.load_text(templates)

    def load_templates_from_file(self, filename):
        with open(filename, 'r') as f:
            self.load_file(f)

    def _process_triples(self, triples):

        for triple in triples:
            # next code is used for templates like
            # (@first-activation :amr-set "I was first activated in Hong Kong.")
            # we do not use such templates
            # if TypeDetector.is_amr_set(triple) and TypeDetector.is_const(triple[2]):
            #     source, role, target = triple
            #     no_quotes = target[1:-1]
            #     if _single_word_pattern.search(no_quotes) is not None:
            #         self.amr_space.add_triple(triple)
            #     else:
            #         top = self.utterance_parser.parse_sentence(no_quotes)
            #         self.amr_space.add_triple((source, role, top))
            # else:
            self.amr_space.add_triple(triple)

    def load_templates_from_files(self, filenames):
        if not isinstance(filenames, list):
            filenames = [filenames]
        for filename in filenames:
            self.load_templates_from_file(filename)
        self.amr_space.index_amrsets()




