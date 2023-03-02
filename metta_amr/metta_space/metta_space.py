import enum
import logging
import hyperon as hp
from hyperon.atoms import S, E, ValueAtom, GroundedAtom, ExpressionAtom

from amr_processing import TypeDetector


class Types(enum.Enum):
    AmrVariable = "variable"
    AmrSet = "amrset"

def amrt2metta(token):
    if TypeDetector.is_variable(token):
        return token if token == '*' else f"(Var {token[1:]})"
    return token

class MettaSpace:
    def __init__(self):
        self.log = logging.getLogger(__name__ + '.' + type(self).__name__)
        self.metta = hp.MeTTa()
        self.metta.run('''
            ! (bind! &triples (new-space))
            ! (bind! &conset (new-space))
            ! (bind! &varset (new-space))
            ! (bind! &optrole (new-space))
            ! (bind! &roles (new-space))
        ''')
        self.cache = {}

    @staticmethod
    def results_to_str(results):
        str_results = []
        for res in results:
            str_results.append([repr(r) for r in res] if isinstance(res, list) else repr(res))
        return str_results

    def add_triple(self, triple):
        source, role, target = triple
        target = amrt2metta(target)
        # TODO: add optional role here
        isoptional = False
        if role[-1] == '?':
            role = role[:-1]
            isoptional = True
        if role == ':instance':
            self.metta.run(f"! (add-atom &triples (Instance ({source} {target})))")
        else:
            self.metta.run(f"! (add-atom &triples ({source} {role} {target}))")
            if isoptional:
                self.metta.run(f"! (add-atom &optrole ({source} {role} {target}))")
            self.add_has_role(source, role)

    def get_concept(self, value):
        results = self.metta.run(f"!(match &triples (Instance ({value} $concept))  $concept)", True)
        return repr(results[0]) if len(results) > 0 else None

    def get_atoms(self, space_name='triples'):
        return self.metta.run(f"! (get-atoms &{space_name})", True)
        #return self.amr_space.get_atoms()

    def get_amrsets_by_concept(self, concept):
        concept_results = []
        if concept is not None:
            concept = amrt2metta(concept)
            concept_results = self.metta.run(f"!(match &conset ({concept} $set $inst) ($set $inst))", True)

        results = self.metta.run(f"!(match &varset ($set $inst) ($set $inst))", True)
        results.extend(concept_results)
        results = [result.get_children() for result in results]
        return self.results_to_str(results)

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
            return_vals = f'({" ".join(res_vars)})' if len(res_vars) > 1 else res_vars[0]
            results = self.metta.run(f"!(match &triples ({arg0} {pred} {arg1}) ({return_vals}))", True)
            results = [result.get_children() if hasattr(result, "get_children") else result for result in results]
            return self.results_to_str(results)
        return []

    def get_instance_roles(self, instance):
        results = self.metta.run(f"!(match &triples ($source $role {instance}) ($role $source))", True)
        results_right = self.metta.run(f"!(match &triples ({instance} $role $target) ($role $target))", True)
        results.extend(results_right)
        results = [result.get_children() for result in results]
        return self.results_to_str(results)

    def get_concept_roles(self,  concept, role, res_vars=None):
        if res_vars is None:
            res_vars = []
            if TypeDetector.is_variable(role):
                res_vars.append(role)
            if TypeDetector.is_variable(concept):
                res_vars.append(concept)
        if len(res_vars) > 0:
            return_vals = f'({" ".join(res_vars)})' if len(res_vars) > 1 else res_vars[0]
            results = self.metta.run(f"! (match &roles ({concept} {role}) {return_vals})", True)
            results = [result.get_children() if hasattr(result, "get_children") else result for result in results]
            return self.results_to_str(results)
        return []

    def index_amrsets(self):
        results = self.metta.run(
            f"!(match &triples (, ($amrset :amr-set $target) (Instance ($target $concept))) ($amrset $target $concept))", True)
        for result in results:
            concept_atom = result.get_children()[2]
            amrset, target, concept = [repr(res) for res in result.get_children()]
            if isinstance(concept_atom, ExpressionAtom): # TODO (Val ...)
                self.metta.run(f"! (add-atom &varset ({amrset} {target}))")
            elif TypeDetector.is_amrset_name(concept):
                self.index_amrset(amrset, target, concept)
            else:
                self.metta.run(f"! (add-atom &conset ({concept} {amrset} {target}))")

    def index_amrset(self, root, root_instance, tail_amrset):
        results = self.metta.run(
            f"!(match &triples (, ({tail_amrset} :amr-set $target) (Instance ($target $concept))) ($target $concept))",
            True)
        for result in results:
            concept_atom = result.get_children()[1]
            concept = repr(concept_atom)
            if isinstance(concept_atom, ExpressionAtom): # TODO (Var ...)
                self.metta.run(f"! (add-atom &varset ({root} {root_instance}))")
            elif TypeDetector.is_amrset_name(concept):
                assert root.get_name() != concept, f'AMR set loop found, start AmrSet: {root}, last AmrSet before loop: {tail_amrset}'
            else:
                self.metta.run(f"! (add-atom &conset ({concept} {root} {root_instance}))")

    def add_has_role(self, source, role):
        concept_atom = self.get_concept(source)
        if concept_atom is not None:
            concept = repr(concept_atom)
            if not(TypeDetector.is_amrset_name(concept) or isinstance(concept_atom, ExpressionAtom)):
                self.metta.run(f"! (add-atom &roles ({concept} {role}))")

    def is_optional_role(self, source, role, target):
        if role == ":*":
            return True
        results = self.metta.run(f"! (match &optrole ({source} {role} {target}) 1)", True)
        return len(results) > 0







