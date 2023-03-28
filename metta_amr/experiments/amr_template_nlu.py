import logging
import time

from amr_matching import AmrMatcher, AmrTemplateInstance
from amr_processing import AmrProcessor, UtteranceParser
from experiments.amr_generator import AmrGenerator
from metta_space import PatternParser, MettaSpace
from metta_space.metta_space import amrt2metta


class AmrTemplateNLU:

    def __init__(self, amr_space):
        self.log = logging.getLogger(__name__ + '.' + type(self).__name__)
        self.amr_space = amr_space
        self.amr_proc = AmrProcessor()
        self.pattern_parser = PatternParser(self.amr_space)

    def load_templates(self, templates, index_space=False):
        self.pattern_parser.load_text(templates, index_space)

    def load_templates_from_files(self, filenames):
        self.pattern_parser.load_templates_from_files(filenames)

    def text2intents(self, text, intent_set=None):
        self.log.info('text2intents start: %s', text)
        # REM: child_atomspace is used to avoid pollution of main atomspace with utterances.
        # If these utterances or their parses are needed, they should be explicitly saved
        # and tagged with their source.
        input_space = MettaSpace()
        utterance_parser = UtteranceParser(self.amr_proc,  input_space)
        amr_matcher = AmrMatcher(self.amr_space)
        self.log.info('initialization done')
        tops = utterance_parser.parse(text)
        self.log.info('parsing done')
        # List of lists of matches is returned (one list per (splitted) sentence),
        # so we don't confuse multiple templates from different sentences
        matching_start = time.time()
        res = [amr_matcher.match_value(top, input_space) for top in tops]
        # If intent_set is given, only match intents included there
        if intent_set is not None:
            res = [[AmrTemplateInstance(match)
                    for match in matches if match.amrset.name in intent_set]
                   for matches in res]
        else:
            res = [[AmrTemplateInstance(match)
                    for match in matches]
                   for matches in res]
        self.log.info('matching time: %s, results: %s', time.time() -
                      matching_start, res)
        self.log.info('text2intents end')
        return res

    def _declare_amr_vars(self, vs):
        variables = {}
        concepts = set()
        for var, value in vs.items():
            var_expr = amrt2metta(var)
            if var_expr not in variables:
                variables[var_expr] = []
            if isinstance(value, str):
                variables[var_expr].append(value)
                if self.amr_space.is_concept(var):
                    concepts.add(value)
            elif isinstance(value, dict):
                subint = list(value.keys())[0]
                variables[var_expr].append(subint)
                subvars, concepts = self._declare_amr_vars(value[subint])
                variables.update(subvars)
                concepts.update(concepts)
        return variables, concepts

    def intent2text(self, intent):
        """
        Generate a sentence from the content of an AmrTemplateInstance
        :param intent:  an AmrTemplate instance with the intent and variables for generation
        :return:  text sentence coming from `intent`
        """
        # Add variables to the atomspace, to be used by amr_generator
        variables, concepts = self._declare_amr_vars(intent.vars)
        amr_generator = AmrGenerator(self.amr_space, self.amr_proc, variables, concepts)
        return amr_generator.generateFull(intent.amrset)