import logging
import random

from metta_space import MettaSpace
from metta_space.metta_space import Types


class AmrGenerator:

    def __init__(self, amr_space, amr_proc, variables):
        self.log = logging.getLogger(__name__ + '.' + type(self).__name__)
        self.amr_space = amr_space
        self.amr_proc = amr_proc
        self.variables = variables

    def recSubst(self, atom):
        bSubst = True
        while bSubst and atom:
            bSubst = False
            if MettaSpace.is_a(atom, Types.AmrVariable):
                if atom == '*':
                    # Just ignore wildcards since we can't guess their content
                    self.log.debug("recSubst: ignore *")
                    atom = None
                else:
                    varname = MettaSpace.get_variable_name(atom)
                    subst = self.variables[varname] if varname in self.variables else []
                    for s in subst:
                        if not MettaSpace.is_a(s, Types.AmrVariable):
                            if bSubst:
                                self.log.debug('recSubst: WARNING - additional value %s', s)
                            else:
                                self.log.debug('recSubst: AmrVariable %s --> %s', atom, s)
                            atom = s
                            bSubst = True
                    if not bSubst:
                        self.log.debug('recSubst: WARNING - no value for AmrVariable %s', atom)
            else:
                # Check if atom refers to AmrSet (set of tops of amr graphs)
                amr_set = self.amr_space.get_relations(":amr-set", atom, "$top")
                if not MettaSpace.is_a(atom, Types.AmrSet) and len(amr_set) > 0:
                    self.log.debug('recSubst: WARNING - non-AmrSet atom %s has :amr-set role', atom)
                if MettaSpace.is_a(atom, Types.AmrSet) and len(amr_set) == 0:
                    self.log.debug('recSubst: WARNING - AmrSet atom %s has no :amr-set role', atom)
                if len(amr_set) > 0:
                    # Just choose randomly now. A more advanced strategy could be
                    # to filter out subgraphs from amr-set with AmrVariable lacking StateLinks
                    s = amr_set[random.randint(0, len(amr_set)-1)]
                    self.log.debug('recSubst: :amr-set substitution %s --> %s', atom, s)
                    atom = s
                    bSubst = True
        return atom

    def triplesFromFullGraph(self, topAtom):
        self.log.debug('triplesFromFullGraph: generating %s', topAtom if topAtom else None)
        topAtom = self.recSubst(topAtom)
        triples = []
        if not topAtom: return triples
        parentName = parent = parent_var = None
        # identify parent name with substitutions

        if isinstance(topAtom, str):
            pa = self.amr_space.get_concepts_of_instance(topAtom)
            if len(pa) > 0:
                # If the parent explicitly refers to an AmrSet, AmrSet will
                # be sampled, and AmrValue will appear as a parent.
                # It is difficult to track such situations in case of other
                # recursive substitutions (e.g. with variables), so we simply assume
                # that the situation of an AmrValue as the parent is valid and implies
                # the necessity to merge two graphs referring to these AmrValues.
                parent = self.recSubst(pa[0])
                parent_var = pa[0]
                parentName = parent
        children, _ = self.amr_space.get_instance_roles(topAtom)
        connections = []
        for child in children:
            self.log.debug('triplesFromFullGraph: child %s %s %s', topAtom, child[0], child[1])
            # Fixme? recSubst will be called second time for topAtom in recursion
            # It's not a huge problem since it will do nothing, although it will generate warnings twice
            atom2 = self.recSubst(child[1])
            if not atom2 or MettaSpace.is_a(atom2, Types.AmrVariable):
                # TODO? Maybe, we need raise an exception for a non-optional role
                continue
            if child[0] == ':pos':
                # we consider :pos connected to constant attributes only now
                if parentName:
                    parentName += "~"+atom2.replace("\"", "")
                else:
                    self.log.debug('triplesFromFullGraph: WARNING - cannot add pos tag to %s', topAtom)
            elif child[0] == ':*':
                self.log.debug('triplesFromFullGraph: ignoring :*')
                continue
            else:
                # We don't consider optional roles here. They are represented by PredicateNode("is-optional")
                # which is ignored here, and full graph is reconstructed.
                # Controlling how to deal with optional roles in the generator can be added in future.
                connections += [(topAtom, child[0], atom2)]
        if parentName:
            self.log.debug('triplesFromFullGraph: topAtom %s / %s', topAtom, parentName)
            if( MettaSpace.is_a(parent_var, Types.AmrVariable) and self.amr_space.is_concept(parent_var))\
                or self.amr_space.is_concept(parent):
                # topAtom is just an instance of AmrConcept
                triples += [(topAtom, ":instance", parentName)]
            elif MettaSpace.is_a(parent, Types.AmrVariable):
                assert False, "AmrVariable {0} is not set".format(parent)
            else:
                assert (not MettaSpace.is_a(parent, Types.AmrSet)), "Unexpected type of {0} after recSubst".format(parent)
                # Generating subgraph to be merged
                side_triples = self.triplesFromFullGraph(parent)
                if len(side_triples) > 0:
                    for triple in side_triples:
                        if triple[0] == parentName:
                            # Substituting current top in place of the top of the graph to be merged
                            triples += [(topAtom, triple[1], triple[2])]
                        else:
                            triples += [triple]
        # In case of (@game-name :amr-set "Bingo"), generateFull(AmrSet("@game-name")) will
        # return an empty graph, because there are no triples. Generating single attribute value
        # is not supported.
        # elif len(connections) == 0:
        #     triples += [(topAtom.name, ':instance', None)]
        # Just sorting alphabetically works reasonably well: :ARG0,1,2 go first
        connections = sorted(connections, key = lambda n: n[1])
        child_triple = []
        for c in connections:
            try:
                child_triple = self.triplesFromFullGraph(c[2])
            except Exception as e:
                print (e, c[2])
            if len(child_triple) == 0:
                # The special case of amr attribute that substitutes amr value.
                # E.g. for (@game :amr-set "Bingo"), (name :op1 @game), we will have
                # n / name pointing to g / @game, so we need to peek into g's parent
                # to understand that we need not (n :op1 g) with triples for g,
                # but (n :op1 "Bingo"), where "Bingo" is recSubst of g's parent.
                parent2 = self.amr_space.get_concepts_of_instance(c[2])
                if len(parent2) > 0:
                    parent2 = self.recSubst(parent2[0])
                    if not parent2 is None:
                        triples += [(c[0], c[1], parent2)]
                        continue
            new_triples = [(c[0], c[1], c[2])] + child_triple
            for tn in new_triples:
                isNew = True
                for tp in triples:
                    if tp[0] == tn[0] and tp[1] == tn[1]:
                        isNew = False
                        if tp[2] != tn[2] or tp[1] != ':instance':
                            self.log.debug('triplesFromFullGraph: WARNING - conflicting (%s %s %s) (%s %s %s)',
                                           tp[0], tp[1], tp[2], tn[0], tn[1], tn[2])
                            if tp[2] != tn[2] and tp[1] != ':instance':
                                # "Do you have any other questions for me?" contains
                                # `:mod (o / other)` and `:mod (a2 / any)` simultaneously
                                isNew = True
                        # else do nothing - it is expected for :instance
                if isNew:
                    triples += [tn]
        return triples

    def renameInsts(self, triples):
        names = [t[0] for t in triples] + [t[2] for t in triples]
        for i in range(len(triples)):
            t = triples[i]
            if t[1] != ':instance': continue
            oldName = t[0]
            newName = t[2][0] # oldName[0] also works, but it can produce w/i, when what-0015/$what is in graph
            while newName in names:
                if len(newName) == 1:
                    newName += newName[0]
                elif len(newName) == 2:
                    newName += 'a'
                else:
                    newName = newName[0:2] + chr(ord(newName[2])+1)
            for j in range(len(triples)):
                if triples[j][0] == oldName: triples[j] = (newName, triples[j][1], triples[j][2])
                if triples[j][2] == oldName: triples[j] = (triples[j][0], triples[j][1], newName)
            names += [newName]
        return triples

    def generateFull(self, topAtom):
        triples = self.triplesFromFullGraph(topAtom)
        r = self.renameInsts(triples)
        text = self.amr_proc.triples_to_utterance(r) if r != [] else None
        if text is None:
            self.log.debug('generateFull: WARNING - No graph for topAtom %s', topAtom)
        return text

