import logging
from collections import OrderedDict

from metta_space import MettaSpace
from metta_space.metta_space import Types

SingleVariableTemplates = ["@select-single", "@single-name"]

class AmrMatch:

    def __init__(self, amrset, vars={}):
        self.amrset = amrset
        self.vars = vars

    def __repr__(self):
        return ('{ amrset: ' + repr(self.amrset) + ', vars: ' +
            repr(self.vars) + ' }')

    def __eq__(self, other):
        return self.amrset == other.amrset and self.vars == other.vars

class AmrMatcher:
    def __init__(self, space):
        self.space = space
        self.cache = {}
        self.log = logging.getLogger(__name__ + '.' + type(self).__name__)

    def match_amr_set(self, input_value, input_space,  template_value, amrset, h_level=0):
        self.log.debug("match_amr_set: input_value: %s, template_value: %s, amrset: %s",
                       input_value, template_value, amrset)
        matches = []
        for candidate in self.space.get_relations(":amr-set", amrset, "$target"):
            for match in self.match_amr_trees(input_value, input_space, candidate,
                    amrset_instance=template_value, h_level=h_level):
                matches.append({ amrset: match })
        return matches

    class RoleMetadata:
        def __init__(self, role):
            self.role = role
            self.targets = []

    def match_amr_trees(self, input_value, input_space, template_value, amrset_instance=None, rec_level=0, h_level=0):
        # match values
        self.log.debug('match_amr_trees: input_value: %s, template_value: %s'
                + ', amrset_instance: %s', input_value, template_value,
                amrset_instance)
        if (input_value == template_value):
            return [{}]
        if MettaSpace.is_a(template_value, Types.AmrVariable):
            matches = self.match_value(input_value, input_space, h_level=h_level+1)
            if len(matches) == 0:
                # instance AmrVariable
                return [{ template_value: input_value }]
            else:
                result = []
                for match in matches:
                    result.append({ template_value: { match.amrset: match.vars } })
                return result

        # match concepts
        input_concept = input_space.get_concept(input_value)
        template_concept = self.space.get_concept(template_value)
        self.log.debug('match_amr_trees: input_concept: %s template_concept: %s',
                       input_concept, template_concept)
        match = {}
        if (input_concept is None and template_concept is None):
            self.log.debug('match_amr_trees: different attributes')
            return []
        elif template_concept is None:
            self.log.debug('match_amr_trees: template concept is None and input concept is not')
            return []
        elif input_concept is None:
            self.log.debug('match_amr_trees: input concept is None and template concept is not')
            return []
        elif MettaSpace.is_a(template_concept, Types.AmrSet):
            # hierarchical template
            return self.match_amr_set(input_value, input_space, template_value,
                    template_concept, h_level=h_level)
        elif MettaSpace.is_a(template_concept, Types.AmrVariable):
            # parent AnchorNode
            match[template_concept] = input_concept
        elif not MettaSpace.match_concept(input_concept, template_concept):
            self.log.debug('match_amr_trees: different concepts')
            return []

        # match roles
        return self.match_amr_roles(input_value, input_space, template_value, match,
                amrset_instance, rec_level=rec_level, h_level=h_level)

    def match_amr_roles(self, input_value, input_space, template_value, match,
            amrset_instance=None, rec_level=0, h_level=0):
        self.log.debug('match_amr_roles: input_value: %s, template_value: %s'
                + ', amrset_instance: %s', input_value, template_value,
                amrset_instance)

        input_roles = {}
        for role, target in input_space.get_relations("$role", input_value, "$target"):
            if role not in input_roles:
                input_roles[role] = set()
            input_roles[role].add(target)

        template_roles = {}
        for role, target in self.space.get_relations("$role", template_value, "$target"):
            if role not in template_roles:
                template_roles[role] = self.RoleMetadata(role)
            template_roles[role].targets.append((template_value, target))

        if amrset_instance is not None:
            for role, target in self.space.get_relations("$role", amrset_instance, "$target"):
                if role == ':amr-set':
                    continue
                if role not in template_roles:
                    template_roles[role] = self.RoleMetadata(role)
                template_roles[role].targets.append((amrset_instance, target))

        matches = [ match ]
        absent_input_roles = set()
        absent_template_roles = set(template_roles.keys())
        has_role_wildcard = ":*" in template_roles
        for role in input_roles:
            if role in template_roles:
                absent_template_roles.remove(role)
            else:
                if role == ':pos' or has_role_wildcard:
                    continue
                else:
                    absent_input_roles.add(role)
                    continue

            for next_input_value in input_roles[role]:
                for source, next_template_value in template_roles[role].targets:
                    new_matches = []
                    for res in self.match_amr_trees(next_input_value, input_space,
                            next_template_value, rec_level=rec_level+1, h_level=h_level):
                        for prev_match in matches:
                            new_match = prev_match.copy()
                            new_match.update(res)
                            new_matches.append(new_match)
                    # Here we stop on the first possible match for the role.
                    # There are may be other options to match role targets in
                    # other sequence, but we ignore this for now.
                    if len(new_matches) > 0:
                        template_roles[role].targets.remove((source, next_template_value))
                        break
                matches = new_matches
                if len(matches) == 0:
                    self.log.debug('match_amr_roles: no match input for role: '
                            + '%s, value: %s, template_targets: %s',
                            role, next_input_value, template_roles[role].targets)
                    return []

            absent_mandatory_roles = self.get_mandatory_roles(template_roles[role])
            if len(absent_mandatory_roles) > 0:
                self.log.debug("match_amr_roles: non optional template roles are " +
                        "absent in input_value: %s", absent_mandatory_roles)
                return []

        if len(absent_input_roles) > 0:
            self.log.debug("match_amr_roles: input_value has roles which are " +
                    "not present in template_value: %s", absent_input_roles)
            return []

        for role in absent_template_roles:
            absent_mandatory_roles = self.get_mandatory_roles(template_roles[role])
            if len(absent_mandatory_roles) > 0:
                self.log.debug("match_amr_roles: non optional template roles are " +
                        "absent in input_value: %s", absent_mandatory_roles)
                return []

        self.log.debug('match_amr_roles: matches found, vars: %s', matches)
        # Addition for manipulating with suffixes and postfixes
        if (rec_level == 0):
            matches = self.merge_variables(matches)
        return matches

    def get_mandatory_roles(self, role_metadata):
        mandatory_roles = []
        for source, target in role_metadata.targets:
            optional = self.space.is_optional_role(source, role_metadata.role, target)
            if not optional:
                mandatory_roles.append((role_metadata.role, source, target))
        return mandatory_roles


    def match_value(self, value, input_space, h_level=0):
        if value in self.cache:
            res = self.cache[value]
            self.log.debug("match_value: value: %s, cached result: %s", value, res)
            return res
        res = []
        concept = input_space.get_concept(value)
        self.log.debug("match_value: value: %s, concept: %s", value, concept)
        for amrset, amrset_var in self.space.get_amrsets_by_concept(concept):
            self.log.debug("match_value: try amrset: %s, instance: %s", amrset, amrset_var)
            if(h_level>0):
                if (amrset in SingleVariableTemplates):
                    continue
            for match in self.match_amr_trees(value, input_space, amrset_var, h_level=h_level):
                amr_match = AmrMatch(amrset, match)
                self.log.debug("match_value: match: %s", amr_match)
                res.append(amr_match)
        self.log.debug("match_value: matching end, value %s, results: %s",
                value, res)
        self.cache[value] = res
        return res

    def check_quotes(self, val, has_quotes):
        if (val is None) or (val[0] != '"' or val[-1] != '"'):
            return False
        return has_quotes

    def concat_arrays(self, merged_name, vals_to_concat, has_quotes):
        values = []
        if isinstance(vals_to_concat, dict):
            values = list(vals_to_concat.values())
        elif isinstance(vals_to_concat, list):
            values = vals_to_concat
        for value in values:
            merged_name += value[1:-1] + " " if has_quotes else value + " "
        return merged_name

    def merge_variables(self, matches):
        new_matches = []
        var_main = "$main"
        list_to_merge = []
        prefixes = dict()
        postfixes = dict()
        has_quotes = True
        for match in matches:
            if var_main in match:
                list_to_merge.append(match[var_main].name)  # appending $main's name
                for key in match:
                    if key == var_main:
                        has_quotes = self.check_quotes(match[key].name, has_quotes)
                        continue
                    if ("-pre" in key.name):
                        if ("^" in key.name):
                            prefixes[int(key.name[-1])] = match[key].name
                        else:
                            list_to_merge.insert(0, match[key].name)
                    if ("-post" in key.name):
                        if ("^" in key.name):
                            postfixes[int(key.name[-1])] = match[key].name
                        else:
                            list_to_merge.append(match[key].name)
                    has_quotes = self.check_quotes(match[key].name, has_quotes)

            if len(list_to_merge) == 0:
                continue
            merged_name = ""
            postfixes = OrderedDict(sorted(postfixes.items()))
            prefixes = OrderedDict(sorted(prefixes.items()))

            merged_name = self.concat_arrays(merged_name, prefixes, has_quotes)
            merged_name = self.concat_arrays(merged_name, list_to_merge, has_quotes)
            merged_name = self.concat_arrays(merged_name, postfixes, has_quotes)

            merged_name = merged_name[:-1]
           # new_atom = AmrConcept(merged_name)
            new_match = dict()
            new_match[var_main] = merged_name
            new_matches.append(new_match)
        if (len(new_matches) > 0):
            matches = new_matches
        return matches
