import unittest
import logging

from amr_processing import AmrProcessor, TripleProcessor, PatternInstanceDict
from experiments.amr_generator import AmrGenerator
from metta_space import MettaSpace, PatternParser
from metta_space.metta_space import amrt2metta


class AmrGeneratorTest(unittest.TestCase):

    def setUp(self):
        self.log = logging.getLogger(__name__)
        self.amr_proc = AmrProcessor()
        self.amr_space = MettaSpace()
        p = self.parser = PatternParser(self.amr_space)
        self.triple_proc = TripleProcessor(PatternInstanceDict)

        # Basic AMRs should be precisely reconstructed by the generator
        basic_amrs = ['(come-01 :ARG1 i :ARG4 in)',
                      '(mind-15 :polarity - :mode (imperative / -) :ARG0 you :time ever)',
                      '(say-01 :ARG1 hi :ARG2 (person :name (name :op1 "Amanda")))']
        self.basic_graphs = [[p.parse(amr), amr] for amr in basic_amrs]
        # Wildcards are ignored. role? is treated as role
        self.wild_graphs = [[p.parse('(do-01 :ARG0 i :ARG1 *)'),
                             '(do-01 :ARG0 i)'],
                            # Given such templates, we can't figure out if (concept :role *) should be
                            # ignored or not. It would be better to omit `:ARG2 person`, but keep
                            # `:ARG1 come` during generation. Unfortunately, it's impossible to distinguish 
                            # a functional AMR keyword and linguistic concept. Apparently, it's better
                            # just not to use templates with wildcards for generation
                            [p.parse('(say-01 :ARG1 hi :ARG2 (person :name *))'),
                             '(say-01 :ARG1 hi :ARG2 person)'],
                            [p.parse('(permit :ARG1 (come :ARG4 *))'),
                             '(permit :ARG1 come)'],
                            # `:* *` will be ignored due to second *. To test :*, we put a concept
                            # on its right-hand side
                            [p.parse('(have-03 :polite + :* ignore)'),
                             '(have-03 :polite +)'],
                            # Optional roles are treated as obligatory in triplesFromFullGraph
                            [p.parse('(have-03 :ARG0 (ii / i) :ARG1 (question-01 :ARG0? (ii / i) :ARG2? you))'),
                             '(have-03 :ARG0 (ii / i) :ARG1 (question-01 :ARG0 (ii / i) :ARG2 you))']
                            ]
        # Substitution of variables: attribute values, concepts, subgraphs through instances
        variables = {}
        variables['(Var whom)'] = ["Dr Zhivago"]
        variables['(Var when)'] = ["tomorrow"]
        variables['(Var what)'] = [self.basic_graphs[0][0]]


        self.var_graphs = [[p.parse('''
                            (possible-01 :polarity amr-unknown
                               :ARG1 (help-01 :ARG0 you
                                        :ARG1 (make-01 :ARG0 i
                                                 :ARG1 (appointment :ARG0 i :ARG1 $whom :time (w2 / $when)))
                                                 :ARG2 i))'''),
                            '''(possible-01 :polarity amr-unknown
                                  :ARG1 (help-01 :ARG0 you
                                           :ARG1 (make-01 :ARG0 i
                                                    :ARG1 (appointment :ARG0 i :ARG1 "Dr Zhivago" :time tomorrow))
                                                    :ARG2 i))'''],
                           [p.parse('(permit :ARG1 $what)'),
                            '(permit :ARG1 (come-01 :ARG1 i :ARG4 in))']
                           # Bad style. `come-01 :time yesterday` is lost. Could, but shoulnd't be fixed.
                           # [p.parse('($what :time yesterday)'), '(come-01 :ARG1 i :ARG4 in)']
                           ]
        # AmrSets
        sentences = ['(@get-permission :amr-set (permit-01 :polarity amr-unknown :ARG1 @do-action))',
                     '(@do-action :amr-set (get-01 :ARG0 i :ARG1 it))',
                     '(@nice :amr-set nice)',
                     '(@nice :amr-set good)',
                     '(@nice :amr-set excellent)',
                     '(@hi :amr-set (say-01 :ARG1 hi :ARG2 $person))',
                     '(@doctor :amr-set (person :name (name :op1 $title :op2 "Zhivago")))'
                     # AmrSets are not expected at instance nodes
                     # p.parse('(@mixing :amr-set (@do-action :ARG1 nice))')
                     ]
        for s in sentences: p.parse(s)
        variables['(Var person)'] = ['@doctor']
        variables['(Var title)'] = ["Dr"]

        concepts = set()
        for k,v in variables.items():
            if self.amr_space.is_concept(k):
                concepts.update(v)
        self.amr_space.index_amrsets()
        self.gen = AmrGenerator(self.amr_space, self.amr_proc, variables, concepts)

    def tearDown(self):
        del self.var_graphs
        del self.wild_graphs
        del self.basic_graphs
        del self.gen
        del self.triple_proc
        del self.amr_space
        del self.amr_proc

    def remove_quotes(self, string):
        if len(string) > 2 and (string[0] == '"' and string[-1] == '"'):
            return string[1:-1]
        return string

    def triples_contain(self, triples, triple):
        # Not precise, but should be enough

        arg1 = self.remove_quotes(triple[0].split('-')[0])
        arg2 = self.remove_quotes(triple[2].split('-')[0])

        for t in triples:
            if arg1 == self.remove_quotes(t[0].split('-')[0]) and triple[1] == t[1]\
                    and arg2 == self.remove_quotes(t[2].split('-')[0]):
                return True
        return False

    def check_triples(self, top_inst, amr_t):
        triples_g = self.gen.triplesFromFullGraph(top_inst)
        # a small hach to compare generated graphs with variables, i.e.
        # to replace what-000017 `what-000017 / yesterday` and `... :time what-000017` with `yesterday`
        for j in range(len(triples_g)):
            t = triples_g[j]
            if t[1] == ':instance' and t[0].split('-')[0] != t[2].split('-')[0]:
                oldInst = t[0]
                newInst = t[2]
                for i in range(len(triples_g)):
                    if triples_g[i][0] == oldInst: triples_g[i] = (newInst, triples_g[i][1], triples_g[i][2])
                    if triples_g[i][2] == oldInst: triples_g[i] = (triples_g[i][0], triples_g[i][1], newInst)
        triples_t = [t for t in self.triple_proc.amr_to_triples(amr_t).triples]
        for t in triples_t:
            if not self.triples_contain(triples_g, t):
                return False, t
        for t in triples_g:
            if not self.triples_contain(triples_t, t):
                return False, t
        return True, None

    def test_basicgraph(self):
        for inst, amr in self.basic_graphs:
            r, t = self.check_triples(inst, amr)
            self.assertTrue(r, "Error in triple {0} for AMR {1}".format(t, amr))

    def test_wildgraph(self):
        for inst, amr in self.wild_graphs:
            r, t = self.check_triples(inst, amr)
            self.assertTrue(r, "Error in triple {0} for AMR {1}".format(t, amr))

    def test_vargraph(self):
        for inst, amr in self.var_graphs:
            r, t = self.check_triples(inst, amr)
            self.assertTrue(r, "Error in triple {0} for AMR {1}".format(t, amr))

    def test_amrset(self):
        r, t = self.check_triples('@get-permission',
                                  '(permit-01 :polarity amr-unknown :ARG1 (get-01 :ARG0 i :ARG1 it))')
        self.assertTrue(r, "Wrong triple {0}".format(t))
        r, t = self.check_triples('@hi',
                                  '(say-01 :ARG1 hi :ARG2 (person :name (name :op1 "Dr" :op2 "Zhivago")))')
        self.assertTrue(r, "Wrong triple {0}".format(t))
        for _ in range(10):
            triples = self.gen.triplesFromFullGraph('@nice')
            self.assertEqual(len(triples), 1)
            self.assertEqual(triples[0][1], ':instance')
            self.assertTrue(triples[0][2] in ['nice', 'good', 'excellent', 'good'])

    def test_plain_word(self):
        self.parser.parse('''
            (@game-name :amr-set "Bingo")
        ''')
        self.parser.parse('''
            (@suggest-game :amr-set
                (like-02
                    :ARG0 (y / you)
                    :ARG1 (play-01
                        :ARG0 y
                        :ARG1 (game :name (name :op1 @game-name)))
                        :polarity amr-unknown))
        ''')
        utterance = self.gen.generateFull('@suggest-game')
        self.assertEqual(utterance, 'Would you like to play Bingo?')

    def test_amrset_merge(self):
        self.parser.parse('(@greet-word :amr-set hi)')
        self.parser.parse('(@greeting :amr-set (@greet-word :mode (expressive / -) :location there))')
        self.parser.parse('(@good :amr-set good)')
        self.parser.parse('(@time-of-day :amr-set morning)')
        self.gen.variables["(Var day-of-time)"] =  ["@time-of-day"]
        self.parser.parse('(@good-time :amr-set (d / $day-of-time :ARG1-of @good))')
        r, t = self.check_triples('@greeting',
                                  '(hi :mode (expressive / -) :location there)')
        self.assertTrue(r, "Wrong triple {0}".format(t))
        r, t = self.check_triples('@good-time',
                                  '(morning :ARG1-of good)')
        self.assertTrue(r, "Wrong triple {0}".format(t))


if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)
    logging.getLogger('penman').setLevel(logging.INFO)
    unittest.main()