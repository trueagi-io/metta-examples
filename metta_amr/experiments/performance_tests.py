import os
import time
import unittest

import pathlib

from amr_processing import UtteranceParser, TripleProcessor, AmrInstanceDict

T = unittest.TestCase
from metta_space import PatternParser, MettaSpace
from amr_matching import AmrMatcher, AmrMatch, AmrTemplateInstance
from matcher_tests import parse_amr

class MatcherTest(T):

    @classmethod
    def setUpClass(cls):
        start = time.time()
        work_dir = pathlib.Path(__file__).parent.resolve().parent
        cls.templates_dir = os.path.join(work_dir, "amr_templates")
        cls.amr_space = MettaSpace()

        pattern_loader = PatternParser(cls.amr_space)
        files = []
        if os.path.exists(cls.templates_dir):
            for f in os.listdir(cls.templates_dir):
                if f.endswith('.amr') :
                    files.append(os.path.join(cls.templates_dir, f))
            pattern_loader.load_templates_from_files(files)
        dur = (time.time() - start)
        print("templates load time:", dur)
        cls.amr_matcher = AmrMatcher(cls.amr_space)


    def test_get_atoms_count(self):
        print(len(self.amr_space.get_atoms()))

    def test_get_atoms(self):
        with open("concepts.txt", mode='w') as f:
            for atom in self.amr_space.get_atoms('conset'):
                f.write(repr(atom) + "\n")

    def test_performance_1(self):

        input_space = MettaSpace()

        tops = parse_amr(["(g / go  :ARG1 (c / check-up :ARG0 (y / you) :ARG1 (p / person   :name (n / name    :op1 \"Alan\" ))) :time (d / date-entity   :time \"15:00\") :manner (a / amr-unknown))"],
                              input_space)
        start = time.time()
        res = self.amr_matcher.match_value(tops[0], input_space)
        print("\ndoctor-checkout matching len:", len(res))
        dur = (time.time() - start)
        print("doctor-checkout matching time:", dur)

    def test_performance_2(self):
        input_space = MettaSpace()

        tops = parse_amr([ '(a / available-02  :ARG2 (p / person  :name (n / name  :op1 "John")) :time (d / date-entity  :time "15:00" :weekday (m / monday)))'],
                         input_space)
        start = time.time()
        res = self.amr_matcher.match_value(tops[0], input_space)
        print("\navailable-02 matching len:",  len(res))
        dur = (time.time() - start)
        print("available-02 matching time:", dur)

    def test_performance_3(self):
        input_space = MettaSpace()

        tops = parse_amr(['(c/ cause  :ARG1 (t / turn   :ARG0 (ii2 / i)  :ARG1 (h / hobby    :poss ii2)   :ARG2 (j / job)))'], input_space)
        start = time.time()
        res = self.amr_matcher.match_value(tops[0], input_space)
        print("\nhobby matching len:", len(res))
        dur = (time.time() - start)
        print("hobby matching time:", dur)

    def test_performance_4(self):
        input_space = MettaSpace()

        tops = parse_amr([ '(l / love-01   :ARG0 (y / you)   :ARG1 (e / eat-01   :ARG0 y    :ARG1 soup))'],
                         input_space)
        start = time.time()
        res = self.amr_matcher.match_value(tops[0], input_space)
        print("\nlove eat matching len:", len(res))
        dur = (time.time() - start)
        print("love eat matching time:", dur)


    def test_performance_5(self):
        input_space = MettaSpace()

        tops = parse_amr(['(g /guide-01 :ARG0 (ii / i) :ARG1 (y / you)  :ARG2 (e / exercise-02 :ARG1-of (s / simple-02) :purpose (r / relax-01  :ARG1 (a / and  :op1 (m / mind   :part-of y) :op2 (b / body  :part-of y)) )))'],  input_space)
        start = time.time()
        res = self.amr_matcher.match_value(tops[0], input_space)
        print("\nmeditation matching len:", len(res))
        dur = (time.time() - start)
        print("meditation matching time:", dur)


    def test_performance_6(self):
        input_space = MettaSpace()
        tops = parse_amr(['(p / person :name (n / name  :op1 "John" :op2 "Doe")  :domain (ii / i))'],  input_space)
        start = time.time()
        res = self.amr_matcher.match_value(tops[0], input_space)
        print("\nname matching  len", len(res))
        dur = (time.time() - start)
        print("name matching time:", dur)

if __name__ == '__main__':
    unittest.main()
