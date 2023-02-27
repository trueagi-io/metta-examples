from copy import deepcopy
from metta_space import Types


class AmrTemplateInstance:

    def __init__(self, match=None, amr_space=None):
        self.vars = {}
        self.subint = []
        if match:
            self.amrset = match.amrset
            self.subint, self.vars = self._unwrap_vars_rec(match.vars, amr_space)

    def _unwrap_vars_rec(self, vs, amr_space):
        subint = []
        vacc = {}
        for key, value in vs.items():
            if isinstance(key, str) and key != '*':
                if amr_space.is_a(key, Types.AmrSet):
                    subint_child, vacc_child = self._unwrap_vars_rec(value, amr_space)
                    subint += [key] + subint_child
                    # Storing all subintent variables as a value for subintent
                    if len(vacc_child) > 0:
                        vacc[key] = vacc_child
                    # And also duplicate them in a flatten dict for convenience
                    vacc.update(vacc_child)
                else:
                    assert amr_space.is_a(key, Types.AmrVariable), "Unsupported variable {0}".format(key)
                    vname = None
                    if isinstance(value, str):
                        vname = value
                        if vname.startswith('"') and vname.endswith('"'):
                            vname = vname[1:-1]
                    elif isinstance(value, dict):
                        vkey = list(value.keys())[0]
                        assert len(value) == 1 and isinstance(vkey, str) and amr_space.is_a(vkey, Types.AmrSet), \
                            "Expected only one AmrSet as variable value: {0} - {1}".format(key, value)
                        vname = vkey
                        subint_child, vacc_child = self._unwrap_vars_rec(value[vkey], amr_space)
                        subint += [vname] + subint_child
                        if len(vacc_child) > 0:
                            vname = {vname: vacc_child}
                        vacc.update(vacc_child)
                    vacc[key] = vname
        return subint, vacc

    @classmethod
    def from_values(cls, amrset, vars={}, subint=[]):
        inst = cls()
        inst.amrset = amrset
        inst.vars = deepcopy(vars)
        inst.subint = subint
        return inst

    def __repr__(self):
        return ('{ amrset: ' + self.amrset + ', vars: ' +
            repr(self.vars) + ' }' + ', subint: ' + repr(self.subint))

    def __eq__(self, other):
        if not isinstance(other, AmrTemplateInstance):
            return False
        return self.amrset == other.amrset and self.vars == other.vars and \
            self.subint == other.subint