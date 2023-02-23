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

    def is_a(self, value, type):
        if type == Types.AmrVariable:
            if TypeDetector.is_variable(value):
                return True
            results = self.metta.run(f"!(match &self (is_variable  {value})  $concept)")
            return len(results) > 0
        if type == Types.AmrSet:
            return TypeDetector.is_amrset_name(value)


    def add_triple(self, triple):
        source, role, target = triple
        self.add_atom(f"({source} {role} {target})")

        if TypeDetector.is_variable(source):
            self.add_atom(f"(is_variable {source})")

        if  TypeDetector.is_variable(target):
            self.add_atom(f"(is_variable {target})")

    def get_concept(self, value):
        results = self.metta.run(f"!(match &self ({value} :instance $concept)  $concept)")
        return results[0] if len(results) > 0 else None

    def get_atoms(self):
        return self.space.get_atoms()

    def get_amrsets_by_concept(self, concept):
        results = []
        concept_results = []
        if concept is not None:
            concept_results = self.metta.run(f"!(match &self (, ($inst :instance {concept})\
            ($set :amr-set $inst)) ($set $inst))")
        results = self.metta.run(f"!(match &self (, (is_variable $inst)\
                        ($set :amr-set $inst)) ($set $inst))")
        results.extend(concept_results)

        return results[0] if len(results) > 0 else None

    def get_relations(self, pred, arg0, arg1, res_vars=None):
        if res_vars is None:
            res_vars = []
            if TypeDetector.is_variable(arg0):
                res_vars.append(arg0)
            if TypeDetector.is_variable(arg1):
                res_vars.append(arg1)
        if len(res_vars) > 0:
            return_vals = " ".join(res_vars)
            results = self.metta.run(f"!(match &self ({arg0} {pred} {arg1}) ({return_vals}))")
            return results[0] if len(results) > 0 else None
        return None






