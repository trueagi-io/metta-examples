import enum
import logging
import hyperon as hp
from hyperon.atoms import S, E

from amr_processing import TypeDetector


class Types(enum.Enum):
    AmrVariable = "variable"
    AmrSet = "amrset"

class MettaSpace:
    def __init__(self):
        self.log = logging.getLogger(__name__ + '.' + type(self).__name__)
        self.metta = hp.MeTTa()
        self.space = self.metta.space()
        self.cache = {}

    def add_triple(self, triple):
        source, role, target = triple
        self.space.add_atom(E(S(source), S(role), S(target)))

    def get_concept(self, value):
        results = self.metta.run(f"!(match &self ({value} :instance $concept)  $concept)", True)
        return results[0] if len(results) > 0 else None

    def get_atoms(self):
        return self.space.get_atoms()

    def get_amrsets_by_concept(self, concept):
        results = []
        concept_results = []
        if concept is not None:
            concept_results = self.metta.run(f"!(match &self ({concept} $set amrset-by-concept $inst) ($set $inst))", True)

        results = self.metta.run(f"!(match &self ($set amrset-by-variable $inst) ($set  $inst))", True)
        results.extend(concept_results)
        return [result.get_children() for result in results]

    def is_a(self, value, type):
        if type == Types.AmrVariable:
            return TypeDetector.is_variable(value.get_name())
        if type == Types.AmrSet:
            return TypeDetector.is_amrset_name(value.get_name())
        return False

    def get_relations(self, pred, arg0, arg1, res_vars=None):
        if res_vars is None:
            res_vars = []
            if TypeDetector.is_variable(pred):
                res_vars.append(pred)
            if TypeDetector.is_variable(arg0):
                res_vars.append(arg0)
            if TypeDetector.is_variable(arg1):
                res_vars.append(arg1)
        if len(res_vars) > 0:
            return_vals = " ".join(res_vars)
            results = self.metta.run(f"!(match &self ({arg0} {pred} {arg1}) ({return_vals}))", True)
            return [result.get_children() if hasattr(result, "get_children") else result[0] for result in results]
        return []

    def get_instance_roles(self, instance):
        results = self.metta.run(f"!(match &self ($source $role {instance}) ($role $source))", True)
        results_right = self.metta.run(f"!(match &self ({instance} $role $target) ($role $target))", True)
        results.extend(results_right)
        return [result.get_children() for result in results] if len(results) > 0 else []

    def get_concept_roles(self,  concept, role, res_vars=None):
        if res_vars is None:
            res_vars = []
            if TypeDetector.is_variable(role):
                res_vars.append(role)
            if TypeDetector.is_variable(concept):
                res_vars.append(concept)
        if len(res_vars) > 0:
            return_vals = " ".join(res_vars)
            results = self.metta.run(f"!(match &self(, ($source {role} $target) ($source :instance {concept})) ({return_vals}))", True)
            return [result.get_children() if hasattr(result, "get_children") else result[0] for result in results]
        return []

    def index_amrsets(self):
        results = self.metta.run(
            f"!(match &self(, ($amrset :amr-set $target) ($target :instance $concept)) ($amrset $target $concept))", True)
        for result in results:
            amrset, target, concept = [res.get_name() for res in result.get_children()]
            if TypeDetector.is_variable(concept):
                self.space.add_atom(E(S(amrset), S("amrset-by-variable"), S(target)))
            elif TypeDetector.is_amrset_name(concept):
                self.index_amrset(amrset, target, concept)
            else:
                self.space.add_atom(E(S(concept), S(amrset), S("amrset-by-concept"), S(target)))

    def index_amrset(self, root, root_instance, tail_amrset):
        results = self.metta.run(
            f"!(match &self(, ({tail_amrset} :amr-set $target) ($target :instance $concept)) ($target $concept))",
            True)
        for result in results:
            target, concept = [res.get_name() for res in result.get_children()]
            if TypeDetector.is_variable(concept):
                self.space.add_atom(E(S(root), S("amrset-by-variable"), S(root_instance)))
            elif TypeDetector.is_amrset_name(concept):
                assert root.get_name() != concept.get_name(), f'AMR set loop found, start AmrSet: {root}, last AmrSet before loop: {tail_amrset}'
            else:
                self.space.add_atom(E(S(concept), S(root), S("amrset-by-concept"), S(root_instance)))





