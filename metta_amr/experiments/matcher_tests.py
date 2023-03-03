import os
import unittest

import pathlib

from amr_processing import UtteranceParser, TripleProcessor, AmrInstanceDict

T = unittest.TestCase
from metta_space import PatternLoader, MettaSpace, AmrMatcher

class MatcherTest(T):

    @classmethod
    def setUpClass(cls):
        work_dir = pathlib.Path(__file__).parent.resolve().parent
        template_file = os.path.join(work_dir, "amr_templates", "test.amr")
        amr_space = MettaSpace()
        cls.pattern_loader = PatternLoader(amr_space)
        cls.pattern_loader.load_templates_from_file(template_file)
        cls.amr_matcher = AmrMatcher(amr_space)

    def test_get_atoms(self):
        for atom in self.amr_matcher.space.get_atoms():
            print(atom)

    def test_get_mandatory_roles(self):
        template_roles = {}

        template_roles[':mod'] = self.amr_matcher.RoleMetadata(':mod')
        template_roles[':mod'].targets.extend([('week-000022', 'next-000023')])
        self.assertEqual(self.amr_matcher.get_mandatory_roles(template_roles[':mod']), [(':mod', 'week-000022', 'next-000023')])

        template_roles[":mod"] = self.amr_matcher.RoleMetadata(':mod')
        template_roles[":mod"].targets.extend([('amr-unknown-000024', 'exact-000026')])
        self.assertEqual(self.amr_matcher.get_mandatory_roles(template_roles[':mod']), [])

    def parse_amr(self, amrs, input_space):
        triple_proc = TripleProcessor(AmrInstanceDict)
        sentences = []
        try:
            for amr in amrs:
                parsed_amr =triple_proc.amr_to_triples(amr)
                for triple in parsed_amr:
                    input_space.add_triple(triple)
                sentences.append(parsed_amr.top)
        finally:
            return sentences

    def test_match_amr_roles(self):
        input_space = MettaSpace()
        tops = self.parse_amr(['(m/morning :ARG1-of (g/good-02))'], input_space)

        res = self.amr_matcher.match_amr_roles(tops[0], input_space, "time-of-day-000032", {})
        self.assertEqual(res, [{}])

        res = self.amr_matcher.match_amr_trees(tops[0], input_space, "time-of-day-000032")
        self.assertEqual(res, [{'(Var time-of-day)': 'morning'}])


