import enum
import logging
import hyperon as hp

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
        self.tokenizer = hp.Tokenizer()

    def add_atom(self, str_atom):
        hp_parser = hp.SExprParser(str_atom)
        self.space.add_atom(hp_parser.parse(self.tokenizer))

    def add_triple(self, triple):
        source, role, target = triple
        self.add_atom(f"({source} {role} {target})")

    def get_concept(self, value):
        results = self.metta.run(f"!(match &self ({value} :instance $concept)  $concept)", True)
        return results[0] if len(results) > 0 else None

    def get_atoms(self):
        return self.space.get_atoms()

    def get_amrsets_by_concept(self, concept):
        results = []
        concept_results = []
        if concept is not None:
            concept_results = self.metta.run(f"!(match &self (, ($inst :instance {concept})\
                  ($set :amr-set $inst)) ($set $inst))", True)
        # if amr-set is instance of
        #results = self.metta.run(f"!(match &self (, ($set :role: :amr-set $inst) ($inst :instance-of-var ????)) ($set  $inst))", True)
        results.extend(concept_results)
        return [result.get_children() for result in results]

    def is_a(self, value, type):
        if type == Types.AmrVariable:
            return TypeDetector.is_variable(value)
        if type == Types.AmrSet:
            return TypeDetector.is_amrset_name(value)
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

    def get_concept_roles(self, pred, concept, res_vars=None):
        if res_vars is None:
            res_vars = []
            if TypeDetector.is_variable(pred):
                res_vars.append(pred)
            if TypeDetector.is_variable(concept):
                res_vars.append(concept)
        if len(res_vars) > 0:
            return_vals = " ".join(res_vars)
            results = self.metta.run(f"!(match &self(, ($source {pred} $target) ($source :instance {concept})) ({return_vals}))", True)
            return [result.get_children() if hasattr(result, "get_children") else result[0] for result in results]
        return []

    # def get_instance_roles(self, amr_instance):
    #     return [self.get_relations(VariableNode("role"), amr_instance, VariableNode("right-inst"),
    #                                {"role": "AmrRole", "right-inst": None}),
    #             self.get_relations(VariableNode("role"), VariableNode("left-inst"), amr_instance,
    #                                {"role": "AmrRole", "left-inst": None})]


