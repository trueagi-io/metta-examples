import os
import unittest

import pathlib

from hyperon import SymbolAtom

T = unittest.TestCase
from metta_space import PatternLoader, MettaSpace

class FunctionsTest(T):

    @classmethod
    def setUpClass(cls):
        work_dir = pathlib.Path(__file__).parent.resolve().parent
        template_file = os.path.join(work_dir, "amr_templates", "test.amr")
        cls.amr_space = MettaSpace()
        pattern_loader = PatternLoader(cls.amr_space)
        pattern_loader.load_templates_from_file(template_file)
        os.system("export PYTHONPATH=${PYTHONPATH}:/media/sveta/hdisk4/singnet/hyperon-experimental/build/python")


    def test_get_atoms(self):
        for atom in self.amr_space.get_atoms():
            print(atom)

    def test_get_concept(self):
        concept = self.amr_space.get_concept('show-000010')
        self.assertEqual("show", concept.get_name())

        concept = self.amr_space.get_concept('face-arg-000008')
        self.assertEqual("@face-arg", concept.get_name())

        concept = self.amr_space.get_concept('face-expr-000002')
        self.assertEqual("$face-expr", concept.get_name())

    def test_get_amrsets_by_concept(self):
        results = self.amr_space.get_amrsets_by_concept('show')
        correct_results = [["@make-faces-req", "show-000010"],
                           ["@make-faces-req", "show-000006"],
                           ["@activity-options", "activities-000021"]]
        self.assertEqual(len(correct_results), len(results))
        for res in results:
            self.assertTrue([r.get_name() for r in res] in correct_results)

    def test_get_amrsets_by_concept_var(self):
        # if concept is variable
        results = self.amr_space.get_amrsets_by_concept('$activities')
        correct_results = [["@activity-options", "activities-000021"]]
        self.assertEqual(len(correct_results), len(results))
        for res in results:
            self.assertTrue([r.get_name() for r in res] in correct_results)

        results = self.amr_space.get_amrsets_by_concept('*')
        self.assertEqual(len(correct_results), len(results))
        for res in results:
            self.assertTrue([r.get_name() for r in res] in correct_results)

    def test_get_relations_for_target(self):
        res = self.amr_space.get_relations(':ARG2', 'show-000006', '$tarrget')
        self.assertEqual([r.get_name() for r in res[0]], ['make-face-expr-target-000009'])

    def test_get_relations_for_anyrole(self):
        res = self.amr_space.get_relations(':*', '$source', '$tarrget')
        self.assertEqual([r.get_name() for r in res[0]], ['say-000017','*'])

    def test_get_relations_for_source(self):
        results = self.amr_space.get_relations('$role', 'show-000010', '$target')
        correct_results = [[":ARG1", "face-arg-000012"], [":polite?", "+"], [":ARG0", "you-000011"],
                           [":ARG2," "make-face-expr-target-000013"], [":mode"," imperative"]]
        self.assertEqual(len(results), len(correct_results))
        for res in results:
            self.assertTrue([r.get_name() for r in res] in correct_results)

    def test_get_relations_for_var(self):
        res = self.amr_space.get_relations(':amr-set', "$source", '$activities', res_vars=["$source"])
        self.assertEqual(res, [])

    def test_get_relations_for_role(self):
        res = self.amr_space.get_relations(':mod?', '$source', '$target')
        self.assertEqual([r.get_name() for r in res[0]], ["amr-unknown-000024", "exact-000026"])

    def test_get_concept_roles(self):
        #(say-000017 :instance say)
        #(say-000017 : * *)
        res = self.amr_space.get_concept_roles(':*', '$concept')
        self.assertEqual([r.get_name() for r in res[0]], ["say"])

        # (show-000006 :instance show)
        # (show-000006 :mode imperative)
        res = self.amr_space.get_concept_roles(":mode", '$concept')
        self.assertEqual([r.get_name() for r in res[0]], ["show"])

        # not working, because in space polite is with ?
        res = self.amr_space.get_concept_roles(":polite", '$concept')
        self.assertEqual([r.get_name() for r in res[0]], ["show"])

        #(face-000005 :instance face)
        #(face-000005 :ARG1-of face-expr-000004)
        res = self.amr_space.get_concept_roles(":ARG1-of", '$concept')
        self.assertEqual([r.get_name() for r in res[0]], ["face"])

        #(amr-unknown-000024 :instance amr-unknown)
        #(amr-unknown-000024 :domain that-000025)
        #(amr-unknown-000024 :mod? exact-000026)
        results = self.amr_space.get_concept_roles("$role", 'amr-unknown')
        correct_results = [[":domain", ":mod?"]]
        for res in results:
            self.assertTrue([r.get_name() for r in res] in correct_results)

    def test_get_instance_roles(self):
        # (amr-unknown-000024 :domain that-000025)
        # (amr-unknown-000024 :mod? exact-000026
        # (@whatis-that?:amr-set amr-unknown-000024)
        results = self.amr_space.get_instance_roles("amr-unknown-000024")
        correct_results = [[":mod", "exact-000026"],
                            [":domain", "that-000025"],
                           [":amr-set","@whatis-that?"]]
        self.assertEqual(len(correct_results), len(results))
        for res in results:
            self.assertTrue([r.get_name() for r in res] in correct_results)




if __name__ == '__main__':
    unittest.main()




