import os
import unittest

import pathlib

from amr_processing import UtteranceParser, TripleProcessor, AmrInstanceDict

T = unittest.TestCase
from metta_space import PatternLoader, MettaSpace, AmrMatcher, AmrMatch


class MatcherTest(T):

    @classmethod
    def setUpClass(cls):
        work_dir = pathlib.Path(__file__).parent.resolve().parent
        template_file = os.path.join(work_dir, "amr_templates", "matcher_test.amr")
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
        template_roles[':mod'].targets.extend([('week-000005', 'next-000006')])
        self.assertEqual(self.amr_matcher.get_mandatory_roles(template_roles[':mod']), [(':mod', 'week-000005', 'next-000006')])

        template_roles[":mod"] = self.amr_matcher.RoleMetadata(':mod')
        template_roles[":mod"].targets.extend([('amr-unknown-000007', 'exact-000009')])
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

        res = self.amr_matcher.match_amr_roles(tops[0], input_space, "time-of-day-000002", {})
        self.assertEqual(res, [{}])

        res = self.amr_matcher.match_amr_trees(tops[0], input_space, "time-of-day-000002")
        self.assertEqual(res, [{'(Var time-of-day)': 'morning'}])

    def test_match_value_no_roles(self):
        input_space = MettaSpace()
        tops = self.parse_amr(['(w/we)'], input_space)
        #  will call self.match_amr_roles, but there are no roles for input_value and template_value,
        #  and self.match_amr_roles returns  [{}]
        # so the result is not empty (!=[]) and amr_matcher.match_value return AmrMatch

        res = self.amr_matcher.match_value(tops[0], input_space)
        self.assertEqual(res, [AmrMatch(amrset="@make-face-expr-target", vars={})])

    def test_match_value_with_roles(self):
        input_space = MettaSpace()
        tops = self.parse_amr(['(m/month :mod (a / amr-unknown :domain (ii / it)))'], input_space)
        res = self.amr_matcher.match_amr_trees(tops[0], input_space, "month-000010")
        self.assertEqual(res, [{}])
        res = self.amr_matcher.match_value(tops[0], input_space)
        self.assertEqual(res, [AmrMatch(amrset="@ask-current-month-g", vars={})])

    def test_match_amr_trees_with_vars(self):
        input_space = MettaSpace()
        tops = self.parse_amr(["(b / ball :time (w / week :mod (n / next)))"], input_space)
        res = self.amr_matcher.match_amr_trees(tops[0], input_space, "activities-000004")
        self.assertEqual(res,  [{"(Var activities)": 'ball'}])

    def test_match_amr_set(self):
        input_space = MettaSpace()
        tops = self.parse_amr(['(a / available-02  :ARG2 (p / person  :name (n / name  :op1 "John")) :time (d / date-entity  :time "15:00" :weekday (m / monday)))'], input_space)
        res = self.amr_matcher.match_amr_set("date-entity-000003", input_space, "daytime1-000016", "@daytime1")
        self.assertEqual(res,  [{'@daytime1': {'(Var weekday)': 'monday-000004', '(Var time)': '15:00'}}])

    def test_match_amr_roles_for_var(self):
        input_space = MettaSpace()
        tops = self.parse_amr(['(a / available-02  :ARG2 (p / person  :name (n / name  :op1 "John")) :time (d / date-entity  :time "15:00" :weekday (m / monday)))'], input_space)


        res = self.amr_matcher.match_amr_roles("date-entity-000003", input_space, "date-entity-000013", match={} )
        self.assertEqual(res, [{"(Var weekday)":  "monday-000004", '(Var time)': "15:00"}])


    def test_match_value_for_many_var_template(self):
        input_space = MettaSpace()
        tops = self.parse_amr(['(a / available-02  :ARG2 (p / person  :name (n / name  :op1 "John")) :time (d / date-entity  :time "15:00" :weekday (m / monday)))'],
                              input_space)

        res = self.amr_matcher.match_value(tops[0], input_space)
        self.assertEqual(res,
                         [AmrMatch(amrset="@person-avail-day-time-g",
                                   vars={'(Var person-name)': 'name-000002',
                                    '@daytime1': {'(Var weekday)': 'monday-000004',
                                   '(Var time)': '15:00'}})])

    def test_match_value_non_concept(self):
        input_space = MettaSpace()
        tops = self.parse_amr(['(a / available-02  :ARG2 (p / person  :name (n / name  :op1 "John")) :time (d / date-entity  :time "15:00" :weekday (m / monday)))'], input_space)


        res = self.amr_matcher.match_value("15:00", input_space)
        self.assertEqual(res, [])

    def test_match_amr_trees_var_template(self):
        input_space = MettaSpace()
        tops = self.parse_amr([ '(a / available-02  :ARG2 (p / person  :name (n / name  :op1 "John")) :time (d / date-entity  :time "15:00" :weekday (m / monday)))'],
                              input_space)
        # will trigger 'if  template_value.is_a(types.AmrVariable)'
        res = self.amr_matcher.match_amr_trees('name-000002', input_space, '(Var person-name)')
        self.assertEqual(res, [{'(Var person-name)': "name-000002"}])

    def test_match_amr_trees_non_concept(self):
        input_space = MettaSpace()
        tops = self.parse_amr([ '(a / available-02  :ARG2 (p / person  :name (n / name  :op1 "John")) :time (d / date-entity  :time "15:00" :weekday (m / monday)))'],
                              input_space)
        # will trigger 'if  template_value.is_a(types.AmrVariable)'
        res = self.amr_matcher.match_amr_trees('15:00', input_space, '(Var time)')
        self.assertEqual(res, [{'(Var time)': "15:00"}])

    def test_match_amr_roles_with_optional(self):
        input_space = MettaSpace()
        tops = self.parse_amr(['(f / follow  :ARG0 (ii / i) :ARG1 (o / order :ARG0 (d / doctor) :ARG1 (d2 / drug)))'],
                              input_space)
        res = self.amr_matcher.match_amr_roles("order-000002", input_space, "order-000019", match={})
        self.assertEqual(res, [{}])
        res = self.amr_matcher.match_value("follow-000000", input_space)
        self.assertEqual(res, [AmrMatch(amrset="@follow-doc-order", vars={})])

