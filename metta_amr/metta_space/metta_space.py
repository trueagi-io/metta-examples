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
        ''')
        self.cache = {}

    def add_triple(self, triple):
        source, role, target = triple
        target = amrt2metta(target)
        # TODO: add optional role here
        if role[-1] == '?':
            role = role[:-1]
        if role == ':instance':
            self.metta.run(f"! (add-atom &triples (Instance ({source} {target})))")
        else:
            self.metta.run(f"! (add-atom &triples ({source} {role} {target}))")

    def get_concept(self, value):
        results = self.metta.run(f"!(match &triples (Instance ({value} $concept))  $concept)", True)
        return results[0] if len(results) > 0 else None

    def get_atoms(self):
        return self.metta.run("! (get-atoms &triples)")
        #return self.amr_space.get_atoms()

    def get_amrsets_by_concept(self, concept):
        results = []
        concept_results = []
        if concept is not None:
            concept = amrt2metta(concept)
            concept_results = self.metta.run(f"!(match &conset ({concept} $set $inst) ($set $inst))", True)

        results = self.metta.run(f"!(match &varset ($set $inst) ($set $inst))", True)
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
            results = self.metta.run(f"!(match &triples ({arg0} {pred} {arg1}) ({return_vals}))", True)
            # FIXME: use repr for atoms
            return [result.get_children() if hasattr(result, "get_children") else result[0] for result in results]
        return []

    def get_instance_roles(self, instance):
        results = self.metta.run(f"!(match &triples ($source $role {instance}) ($role $source))", True)
        results_right = self.metta.run(f"!(match &triples ({instance} $role $target) ($role $target))", True)
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
            results = self.metta.run(f"!(match &triples (, ($source {role} $target) (Instance ($source {concept}))) ({return_vals}))", True)
            return [result.get_children() if hasattr(result, "get_children") else result[0] for result in results]
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





