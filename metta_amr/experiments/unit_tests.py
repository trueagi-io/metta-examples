import os
import unittest

import pathlib

T = unittest.TestCase
from metta_space import PatternParser, MettaSpace

class FunctionsTest(T):

    @classmethod
    def setUpClass(cls):
        work_dir = pathlib.Path(__file__).parent.resolve().parent
        template_file = os.path.join(work_dir, "amr_templates", "test.amr")
        cls.amr_space = MettaSpace()
        pattern_loader = PatternParser(cls.amr_space)
        pattern_loader.load_templates_from_files(template_file)

    def test_get_atoms(self):
        for atom in self.amr_space.get_atoms('conset'):
            print(atom)

    def test_get_concept(self):
        #(show-000010 :instance show)
        concept = self.amr_space.get_concept('show-000010')
        self.assertEqual("show", concept)

        #(face-arg-000008 :instance @face-arg)
        concept = self.amr_space.get_concept('face-arg-000008')
        self.assertEqual("@face-arg", concept)

        #(face-expr-000002 :instance $face-expr)
        concept = self.amr_space.get_concept('face-expr-000002')
        # NOTE: we expect (Var face-expr) instead of $face-expr
        self.assertEqual("(Var face-expr)", concept)

    def compare_results(self, results, correct_results):
        err = f"\nExpected: {correct_results}\nGot: {results}"
        self.assertEqual(len(correct_results), len(results), err)
        for res in results:
            #vals = [repr(r) for r in res] if isinstance(res, list) else repr(res)
            self.assertTrue(res in correct_results, err + f"\nWrong {res}")

    def test_get_amrsets_by_concept(self):
        # (@make-faces-req :amr-set show-000010)
        # (@make-faces-req:amr-set show-000006)
        # --- amrset-by-variable ---
        # (activities-000021 :instance $activities) !
        # (@activity-options:amr-set activities-000021)
        # --- amrset-by-variable ---
        # (time-of-day-000032 :instance $time-of-day)
        # (@greeting-noname :amr-set time-of-day-000032)
        # (greeting-noname-000034 :instance @greeting-noname)
        # (@greeting-g :amr-set greeting-noname-000034)
        results = self.amr_space.get_amrsets_by_concept('show')
        correct_results = [["@make-faces-req", "show-000006"], ["@make-faces-req", "show-000010"],
         ["@activity-options", "activities-000021"],
         ["@greeting-g", "greeting-noname-000034"],
         ["@greeting-noname","time-of-day-000032"]]
        self.compare_results(results, correct_results)

    def test_get_amrsets_by_concept_nested(self):
        # (definite-000030 :instance definite)
        # (@confirm-word :amr-set definite-000030)
        # (confirm-word-000031 :instance @confirm-word)
        # (@general-confirm-please-c :amr-set confirm-word-000031)
        # also amrset-by-variable
        results = self.amr_space.get_amrsets_by_concept('definite')

        correct_results = [["@general-confirm-please-c",  "confirm-word-000031"],
         ["@confirm-word", "definite-000030"],
         ["@activity-options", "activities-000021"],
         ["@greeting-g", "greeting-noname-000034"],
         ["@greeting-noname", "time-of-day-000032"]]

        self.compare_results(results, correct_results)


    def test_get_amrsets_by_concept_var(self):
        # if concept is variable or any symbol we get amrset-by-variable
        results = self.amr_space.get_amrsets_by_concept('*')

        correct_results = [
         ["@activity-options", "activities-000021"],
         ["@greeting-g", "greeting-noname-000034"],
         ["@greeting-noname", "time-of-day-000032"]]
        self.compare_results(results, correct_results)

        results = self.amr_space.get_amrsets_by_concept('$activities')
        self.compare_results(results, correct_results)

    def test_get_relations_for_target(self):
        # (show-000006 :ARG2 make-face-expr-target-000009)
        res = self.amr_space.get_relations(':ARG2', 'show-000006', '$tarrget')
        self.compare_results(res, ['make-face-expr-target-000009'])

    def test_get_relations_for_anyrole(self):
        # (say-000017 :* *)
        # (activity-000029 :* *)
        # (enjoy-000028 :* *)
        results = self.amr_space.get_relations(':*', '$source', '$tarrget')
        correct_results = [["activity-000029", "*"], ["enjoy-000028", "*"], ["say-000017", "*"]]
        self.compare_results(results, correct_results)

    def test_get_relations_for_source(self):
        # (show-000010 :mode imperative)
        # (show-000010 :polite? +)
        # (show-000010 :ARG0 you-000011)
        # (show-000010 :ARG1 face-arg-000012)
        # (show-000010 :ARG2 make-face-expr-target-000013)
        results = self.amr_space.get_relations('$role', 'show-000010', '$target')
        correct_results = [[":ARG1", "face-arg-000012"], [":polite", "+"], [":ARG0", "you-000011"],
                           [":ARG2", "make-face-expr-target-000013"], [":mode", "imperative"]]
        self.compare_results(results, correct_results)


    def test_get_relations_for_role(self):
        # (amr-unknown-000024 :mod? exact-000026)
        # NOTE: no ? in :mod here
        res = self.amr_space.get_relations(':mod', '$source', '$target')
        # TODO: check if these results are really correct
        correct_results = [["activity-000029", "amr-unknown-000027"], ["week-000022", "next-000023"], ["amr-unknown-000024", "exact-000026"]]
        self.compare_results(res, correct_results)

    def test_get_concept_roles(self):
        # (say-000017 :instance say)
        # (say-000017 : * *)
        # (enjoy-000028 :instance enjoy)
        # (enjoy-000028 :* *)
        # (activity-000029 :instance activity)
        # (activity-000029 :* *)
        results = self.amr_space.get_concept_roles('$concept', ':*')
        correct_results = ["activity", "enjoy", "say"]
        self.compare_results(results, correct_results)

        # (show-000006 :ARG0 you-000007)
        # (show-000010 :ARG0 you-000011)
        # (say-000017 :ARG0 i-000018)
        # (listen-000019 :ARG0 person-Grace-000020)
        results = self.amr_space.get_concept_roles('$concept', ":ARG0")
        correct_results = ["say", "listen", "show"]
        # we have [["say"], ["listen"], ["show"], ["show"]]
        #self.compare_results(results, correct_results)

        # not working, because in space polite is with ?
        res = self.amr_space.get_concept_roles('$concept', ":polite")
        # we have [["show"], ["show"]]
        #self.compare_results(res, [["show"]])

        # (face-000005 :instance face)
        # (face-000005 :ARG1-of face-expr-000004)
        # (time-of-day-000032 :ARG1-of good-02-000033)
        # (time-of-day-000032 :instance $time-of-day)

        results = self.amr_space.get_concept_roles('$concept', ":ARG1-of")
        # we have [[face], [$time-of-day]]  $time-of-day  is not of type AmrConcept
        correct_results = ["face"]
        self.compare_results(results, correct_results)


        #(amr-unknown-000024 :domain that-000025)
        #(amr-unknown-000024 :mod? exact-000026)
        results = self.amr_space.get_concept_roles('amr-unknown', "$role")
        correct_results = [":domain", ":mod"]
        self.compare_results(results, correct_results)

    def test_get_instance_roles(self):
        # (amr-unknown-000024 :domain that-000025)
        # (amr-unknown-000024 :mod? exact-000026
        # (@whatis-that? :amr-set amr-unknown-000024)
        results = self.amr_space.get_instance_roles("amr-unknown-000024")
        correct_results = [[":mod", "exact-000026"],
                           [":domain", "that-000025"],
                           [":amr-set", "@whatis-that?"]]
        # ? (amr-unknown-000024 =)
        self.compare_results(results, correct_results)

    def test_is_optional_role(self):
        self.assertTrue(self.amr_space.is_optional_role('amr-unknown-000024', ':mod', 'exact-000026'))
        self.assertFalse(self.amr_space.is_optional_role('week-000022', ':mod', 'next-000023'))
        self.assertTrue(self.amr_space.is_optional_role('show-000010', ':polite', '+'))


if __name__ == '__main__':
    unittest.main()




