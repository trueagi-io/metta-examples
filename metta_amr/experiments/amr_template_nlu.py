import logging
import time

from metta_space import PatternParser, MettaSpace
from amr_processing import AmrProcessor, UtteranceParser

class AmrTemplateNLU:

    def __init__(self):
        self.log = logging.getLogger(__name__ + '.' + type(self).__name__)
        self.amr_space = MettaSpace()
        self.amr_proc = AmrProcessor()
        self.pattern_parser = PatternParser(self.amr_space)

    def text2intents(self, text, intent_set=None):
        self.log.info('text2intents start: %s', text)
        # REM: child_atomspace is used to avoid pollution of main atomspace with utterances.
        # If these utterances or their parses are needed, they should be explicitly saved
        # and tagged with their source.
        utterance_parser = UtteranceParser(self.amr_proc)
        self.log.info('initialization done')
        tops = utterance_parser.parse(text)
        return tops

    # def text2intents(self, text, intent_set=None):
    #     self.log.info('text2intents start: %s', text)
    #     # REM: child_atomspace is used to avoid pollution of main atomspace with utterances.
    #     # If these utterances or their parses are needed, they should be explicitly saved
    #     # and tagged with their source.
    #     with child_amr_atomspace(self.amr_space) as amr_space:
    #         utterance_parser = UtteranceParser(self.amr_proc, amr_space)
    #         amr_matcher = AmrMatcher(amr_space)
    #         self.log.info('initialization done')
    #         tops = utterance_parser.parse(text)
    #         self.log.info('parsing done')
    #         # List of lists of matches is returned (one list per (splitted) sentence),
    #         # so we don't confuse multiple templates from different sentences
    #         matching_start = time.time()
    #         res = [amr_matcher.match_value(top) for top in tops]
    #         # If intent_set is given, only match intents included there
    #         if intent_set is not None:
    #             res = [[AmrTemplateInstance(match)
    #                     for match in matches if match.amrset.name in intent_set]
    #                    for matches in res]
    #         else:
    #             res = [[AmrTemplateInstance(match)
    #                     for match in matches]
    #                    for matches in res]
    #         self.log.info('matching time: %s, results: %s', time.time() -
    #                       matching_start, res)
    #         self.log.info('text2intents end')
    #         return res
    #
    #
    #
    # def intent2text(self, intent):
    #     """
    #     Generate a sentence from the content of an AmrTemplateInstance
    #     :param intent:  an AmrTemplate instance with the intent and variables for generation
    #     :return:  text sentence coming from `intent`
    #     """
    #     with child_amr_atomspace(self.amr_space) as amr_space:
    #         # Add variables to the atomspace, to be used by amr_generator
    #         amr_generator = AmrGenerator(amr_space, self.amr_proc)
    #         self._declare_amr_vars(intent.vars)
    #         return amr_generator.generateFull(amr_value_atom(intent.amrset))