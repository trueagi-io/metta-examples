
import logging

from amr_processing import UtteranceParser, AmrProcessor
from metta_space import MettaSpace
from amr_matching import AmrMatcher, AmrMatch
import unittest

from metta_space import PatternParser

T = unittest.TestCase

class AmrMatcherTest(T):

    def setUp(self):
        self.amr_proc = AmrProcessor()
        self.work_space = MettaSpace()
        self.parser = PatternParser(self.work_space)

        self.input_space = MettaSpace()
        self.utterance_parser = UtteranceParser(self.amr_proc, self.input_space)
        self.matcher = AmrMatcher(self.work_space)

    def single_match(self, sentence):
        top = self.utterance_parser.parse_sentence(sentence)
        matches = self.matcher.match_value(top, self.input_space)
        self.assertEqual(1, len(matches))
        return matches[0]

    def no_match(self, sentence):
        top = self.utterance_parser.parse_sentence(sentence)
        matches = self.matcher.match_value(top, self.input_space)
        self.assertEqual(0, len(matches))

    def load_pattern(self, pattern):
        # set space for patterns

        # load given pattern into work space
        self.parser.load_text(pattern)
        self.work_space.index_amrsets()
        # process matching
        return

    def get_concept(self, instance, space):
        concepts = space.get_concepts_of_instance(instance)
        self.assertEqual(1, len(concepts))
        return concepts[0]


    # def test_plain_text(self):
    #     match = self.load_pattern_and_match('''
    #         (@intent-hi-grace :amr-set "Hi Grace.")
    #     ''', "Hi Grace.")
    #     self.assertEqual(match, AmrMatch("@intent-hi-grace", {}))

    def test_simplified_amr(self):
        self.load_pattern('''
            (@intent-hi-there :amr-set
              (say :ARG1 hi :ARG2 there))
        ''')
        match = self.single_match("Hi there.")

        self.assertEqual(match, AmrMatch("@intent-hi-there", {}))

    def test_plain_amr(self):
        self.load_pattern('''
            (@intent-hi-grace :amr-set
                (s / say\n   :ARG1 (h / hi)\n   :ARG2 (p / person\n
                :name (n / name\n                     :op1 "Grace"))))
        ''')
        match = self.single_match("Hi Grace")
        self.assertEqual(match, AmrMatch("@intent-hi-grace", {}))

    def test_plain_amr_no_spaces(self):
        self.load_pattern('''
            (@intent-hi-grace :amr-set
                (s/say :ARG1 (h/hi)
                          :ARG2 (p/person :name (n/name :op1 "Grace"))))
        ''')
        match = self.single_match("Hi Grace")
        self.assertEqual(match, AmrMatch("@intent-hi-grace", {}))

    def test_amr_attribute(self):
        self.load_pattern('''
            (@intent-hi-grace :amr-set
                (say :ARG1 hi :ARG2 (person :name (name :op1 "Grace"))))
        ''')
        match = self.single_match("Hi Grace")
        self.assertEqual(match, AmrMatch("@intent-hi-grace", {}))

    def test_hierarchical_pattern(self):
        self.load_pattern('''
            (@intent-getting-permission :amr-set
              (permit :polarity amr-unknown :ARG1 @intent-do-action))
            (@intent-do-action :amr-set
              (come :ARG1 i :ARG4 in))
            (@intent-do-action :amr-set
              (get :ARG0 i :ARG1 it))
        ''')
        match = self.single_match("May I get it?")
        self.assertEqual(match, AmrMatch("@intent-getting-permission",
            { "@intent-do-action": {} }) )

    def test_variable_instance(self):
        self.load_pattern('''
            (@intent-greeting :amr-set
              (say :ARG1 hi :ARG2 (person :name (name :op1 $name))))
        ''')
        match = self.single_match("Hi Grace")
        self.assertEqual(match, AmrMatch("@intent-greeting",
            {"(Var name)": "Grace"}))

    def test_variable_instance_explicit(self):
        self.load_pattern('''
            (@intent-greeting :amr-set
              (say :ARG1 hi :ARG2 (person :name (name :op1 ($name / -)))))
        ''')
        match = self.single_match("Hi Grace")
        self.assertEqual(match, AmrMatch("@intent-greeting",
            { "(Var name)": "Grace" }))

    def test_variable_concept(self):
        self.load_pattern('''
            (@condition-inform :amr-set
              (w / $what :ARG0 i :ARG1-of  well))
        ''')
        match = self.single_match("I slept well.")
        self.assertEqual(match, AmrMatch("@condition-inform",
            { "(Var what)": "sleep" }))

    def test_arg_of(self):
        self.load_pattern('''
            (@condition-inform :amr-set (do :ARG0 i :ARG1-of fine))
        ''')
        match = self.single_match("I am doing fine.")
        self.assertEqual(match, AmrMatch("@condition-inform", {}))

    def test_wildcard(self):
        self.load_pattern('''
            (@intent-hi :amr-set
              (say :ARG0 * :ARG1 * :ARG2 *))
        ''')
        match = self.single_match("Hi Grace.")
        self.assertEqual(match.amrset, "@intent-hi")

    def test_no_instance(self):
        self.load_pattern('''
            (@intent-invite :amr-set
              (come-in :mode (imperative / -) :ARG1 you))
        ''')
        match = self.single_match("Come in.")
        self.assertEqual(match, AmrMatch("@intent-invite", {}))

    def test_instance_for_variable_concept(self):
        self.load_pattern('''
            (@appointment-request :amr-set
                (possible :polarity amr-unknown
                   :ARG1 (help :ARG0 (y / you)
                            :ARG1 (make :ARG0 (ii / i)
                                    :ARG1 (appointment
                                        :ARG0 (ii / i)
                                        :ARG1 (v1 / $whom)
                                        :time (v2 / $when)))
                             :ARG2 (ii / i))))
        ''')
        match = self.single_match("Can you please help me make an appointment with the doctor for tomorrow?")


    def test_nevermind(self):
        self.load_pattern('''
            (@stop-topic :amr-set (mind :polarity - :mode (imperative / -) :ARG0 you :time ever))
        ''')
        match = self.single_match("Nevermind.")
        self.assertEqual(match, AmrMatch("@stop-topic", {}))

    def test_unique_instance_same_concept(self):
        self.load_pattern('''
            (@inform :amr-set
                (available
                    :ARG2 (person :name (name :op1 "Dr" :op2 "Zhivago"))
                    :time (or
                        :op1 (d1 / date-entity :time $time1)
                        :op2 (d2 / date-entity :time $time2))))
        ''')
        match = self.single_match("Dr Zhivago is available at 10PM or 11PM.")
        self.assertEqual(match, AmrMatch("@inform",
            { "(Var time1)" : "22:00",
              "(Var time2)" : "23:00"}))

    def test_search_through_amr_sets(self):
        self.load_pattern(
           '''(@intent-hi-there :amr-set
              (say :ARG1 hi :ARG2 there))
              (@intent-greeting :amr-set
              (say :ARG1 hi :ARG2 (person :name (name :op1 $name))))''')

        match = self.single_match("Hi there.")
        self.assertEqual(match, AmrMatch("@intent-hi-there", {}))
        match = self.single_match("Hi Grace")
        self.assertEqual(match, AmrMatch("@intent-greeting",
            { "(Var name)": 'Grace'}))

    def test_exact_matching(self):
        self.load_pattern('''
            (@intent-getting-permission :amr-set
                (possible
                   :polarity amr-unknown
                   :ARG1 (come
                            :ARG1 you)))
        ''')
        self.no_match("You may come.")

    def test_optional_role(self):
        self.load_pattern('''
            (@say :amr-set
                (say
                    :ARG0? $who
                    :ARG1 $what
                    :ARG2 $to))
        ''')
        match = self.single_match("Hi there.")
        self.assertEqual(match.amrset, "@say")
        self.assertEqual(self.get_concept(match.vars["(Var what)"], self.input_space), "hi")
        self.assertEqual(self.get_concept(match.vars["(Var to)"], self.input_space), "there")
        self.assertFalse("(Var who)" in match.vars)

    def test_wildcard_role(self):
        self.load_pattern('''
            (@imperative :amr-set
                (w / $what :mode (imperative / -) :* *))
        ''')
        match = self.single_match("Please come in")
        self.assertEqual(match, AmrMatch("@imperative",
            { "(Var what)": "come-in" }))

    def test_polite(self):
        self.load_pattern('''
            (@polite :amr-set
                (have :polite + :* *))
        ''')
        match = self.single_match("Please have a seat")
        self.assertEqual(match, AmrMatch("@polite", {}))
        self.load_pattern('''
            (@polite :amr-set
                (come-in :polite - :* *))
        ''')
        self.no_match("Please come in")

    def test_match_all_word_meanings(self):
        self.load_pattern('''
            (@intent-hi-there :amr-set
              (say :ARG1 hi :ARG2 there))
        ''')
        match = self.single_match("Hi there.")
        self.assertEqual(match, AmrMatch("@intent-hi-there", {}))

    def test_nomatch_pos(self):
        self.load_pattern('''
            (@slept-well :amr-set
                (s / sleep
                    :ARG0 (ii / i)
                    :ARG1-of (w / well)
                    :pos "VBD"))
        ''')
        self.no_match("I sleep well.")

    def test_match_pos(self):
        self.load_pattern('''
            (@slept-well :amr-set
                (s / sleep
                    :ARG0 (ii / i)
                    :ARG1-of (w / well)
                    :pos "VBD"))
        ''')
        match = self.single_match("I slept well.")
        self.assertEqual(match, AmrMatch("@slept-well", {}))

    def test_input_concept_is_none(self):
        self.load_pattern('''
            (@like-games :amr-set (like :ARG0 i :ARG1 (g / game)))
        ''')
        self.input_space.add_triple(('l', ':instance', 'like'))
        self.input_space.add_triple(('ii', ':instance', 'i'))
        self.input_space.add_triple(('l', ':ARG0', 'ii'))
        self.input_space.add_triple(('l', ':ARG1', 'UNO'))
        utterance = 'l'
        self.assertEqual(list(self.matcher.match_value(utterance, self.input_space)), [])

    def test_template_concept_is_none(self):
        self.load_pattern('''
            (@like-games :amr-set (like :ARG0 i :ARG1 "UNO"))
        ''')
        self.input_space.add_triple(('l', ':instance', 'like'))
        self.input_space.add_triple(('ii', ':instance', 'i'))
        self.input_space.add_triple(('g', ':instance', 'game'))
        self.input_space.add_triple(('l', ':ARG0', 'ii'))
        self.input_space.add_triple(('l', ':ARG1', 'g'))

        utterance = 'l'
        self.assertEqual(list(self.matcher.match_value(utterance, self.input_space)), [])

    def test_match_double_role(self):
        self.load_pattern('''
        (@other-questions :amr-set (have
           :polarity amr-unknown
           :ARG0 (y / you)
           :ARG1 (question
                    :ARG0 y
                    :ARG2 i
                    :mod other
                    :mod any)))
        ''')
        match = self.single_match("Do you have any other questions for me?")
        self.assertEqual(match, AmrMatch("@other-questions", {}))
        self.no_match("Do you have other questions for me?")

    def test_match_amrset_as_instance(self):
        self.load_pattern('''
          (@time-of-day :amr-set morning)
            (@time-of-day :amr-set afternoon)
            (@time-of-day :amr-set evening)
            (@time-of-day :amr-set day)

            (@greet :amr-set (@time-of-day :ARG1-of good))
        ''')
        match = self.single_match("Good morning.")
        self.assertEqual(match, AmrMatch("@greet", {
            "@time-of-day": {} }))

    def test_match_some_roles_in_amrset(self):
        self.load_pattern('''
            (@i-slept :amr-set
            (sleep :ARG0 i))
            (@i-slept-well :amr-set
            (@i-slept :ARG1-of  well))'''
        )
        match = self.single_match("I slept well.")
        self.assertEqual(match, AmrMatch("@i-slept-well",
            { "@i-slept": {} }))
        self.no_match("I slept bad.")

    def test_match_amrset_used_in_two_templates(self):
        self.load_pattern('''
            (@time-of-day :amr-set morning)
            (@time-of-day :amr-set afternoon)
            (@time-of-day :amr-set evening)
            (@time-of-day :amr-set day)

            (@greet :amr-set (@time-of-day :ARG1-of good))
            (@other :amr-set (@time-of-day :ARG1-of nice))
        ''')
        match = self.single_match("Good morning.")
        self.assertEqual(match, AmrMatch("@greet", {
            "@time-of-day": {} }))
        match = self.single_match("Nice morning.")
        self.assertEqual(match, AmrMatch("@other", {
            "@time-of-day": {} }))

    def test_optional_role_of_amrset(self):
        self.load_pattern('''
            (@general-condition-verb :amr-set do)
            (@general-condition-verb :amr-set feel)

            (@general-condition? :amr-set (@general-condition-verb :ARG0 you :ARG1 amr-unknown :time? today))
        ''')
        match = self.single_match('How do you feel?')
        self.assertEqual(match, AmrMatch('@general-condition?', {
            '@general-condition-verb': {} }))

    def test_recursive_match_of_intent_variables(self):
        self.load_pattern('''
            (@think :amr-set (think :ARG0 (w / $who-think) :ARG1 $what-think))
            (@say :amr-set (say :ARG0 (w1 / $who-say) :ARG1 $what-say))
        ''')
        match = self.single_match('I think that you said this.')
        self.assertEqual(match, AmrMatch("@think", {
            "(Var what-think)": { "@say": {
                "(Var what-say)": "this-500004",
                "(Var who-say)": "you" } },
                "(Var who-think)": "i"}))

    def test_optional_roles_in_nested_amrset_stays_optional(self):
        self.load_pattern('''
            (@ok :amr-set (okay :mode? (expressive / -)))
            (@positive-reply :amr-set @ok)
        ''')
        top = self.utterance_parser.parse_sentence('Ok')
        matches = list(self.matcher.match_value(top, self.input_space))
        self.assertTrue(AmrMatch("@ok", {}) in matches)
        self.assertTrue(AmrMatch("@positive-reply", {"@ok": {}}) in matches)

    def test_loop_pattern_error(self):
        with self.assertRaises(AssertionError) as e:
            self.load_pattern('''
                (@a :amr-set (@b))
                (@b :amr-set (@c))
                (@c :amr-set (@a))
            ''')
        self.assertIn(str(e.exception), ['AMR set loop found, ' +
                'start AmrSet: @b, ' +
                'last AmrSet before loop: @a', 'AMR set loop found, ' +
                'start AmrSet: @a, ' +
                'last AmrSet before loop: @c', 'AMR set loop found, ' +
                'start AmrSet: @c, ' +
                'last AmrSet before loop: @b'])

if __name__ == '__main__':
    #log.set_level("FINE")
    #log.use_stdout()
    logging.basicConfig(level=logging.DEBUG)
    logging.getLogger('penman').setLevel(logging.INFO)
    unittest.main()
