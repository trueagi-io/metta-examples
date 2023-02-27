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

    def is_variable_atom(self, value):
        return value.startswith('var-')

    def is_a(self, value, type):
        if type == Types.AmrVariable:
            if self.is_variable_atom(value):
                return True
        if type == Types.AmrSet:
            return TypeDetector.is_amrset_name(value)
        return False


    def add_triple(self, triple):
        source, role, target = triple
        if source.startswith('$'):
            source = 'var-' + source[1:]

        if target.startswith('$'):
            target = 'var-' + target[1:]

        if TypeDetector.is_instance_role(role):
            self.add_atom(f"({source} {role} {target})")
            if self.is_variable_atom(target):
                self.add_atom(f"({source} :instance-of-var {target})")
        else:
            self.add_atom(f"({source} :role: {role} {target})")

    def get_concept(self, value):
        results = self.metta.run(f"!(match &self ({value} :instance $concept)  $concept)", True)
        return results[0].get_name() if len(results) > 0 else None

    def get_atoms(self):
        return self.space.get_atoms()

    def get_amrsets_by_concept(self, concept):
        results = []
        concept_results = []
        if concept is not None:
            concept_results = self.metta.run(f"!(match &self (, ($inst :instance {concept})\
            ($set :role: :amr-set $inst)) ($set $inst))", True)
        # if amr-set is instance of
        results = self.metta.run(f"!(match &self (, ($set :role: :amr-set $inst) ($inst :instance-of-var $concept))\
         ($set  $inst))", True)
        results.extend(concept_results)
        new_results = []
        for res in results:
            children = res.get_children()
            if len(children) == 1:
                new_results.append(children[0].get_name())
            else:
                new_results.append([r.get_name() for r in children])
        return new_results if len(new_results) > 0 else []

    def get_relations(self, pred, arg0, arg1, res_vars=None):
        if res_vars is None:
            res_vars = []
            if TypeDetector.is_variable(arg0):
                res_vars.append(arg0)
            if TypeDetector.is_variable(arg1):
                res_vars.append(arg1)
        if len(res_vars) > 0:
            return_vals = " ".join(res_vars)
            results = self.metta.run(f"!(match &self ({arg0} :role: {pred} {arg1}) ({return_vals}))", True)
            new_results = []
            for res in results:
                children = res.get_children()
                if len(children) == 1:
                    new_results.append(children[0].get_name())
                else:
                    new_results.append([r.get_name() for r in children])
            return new_results if len(new_results) > 0 else []
        return []






