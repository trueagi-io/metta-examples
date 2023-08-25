import time
import unittest

import hyperon as hp

class StatesSpaceTest(unittest.TestCase):


    def get_atoms(self, space_name):
        return self.metta.run(f"! (get-atoms (get-state &{space_name}))", True)
    def test_for_change_goal_property_with_states(self):
        self.metta = hp.MeTTa()
        self.metta.run('''
                   ! (bind! &goals  (new-state (new-space)))
                  
                   ''')
        self.metta.run(f'''
                  (= (new-goal-property! $goal $prop_name $value)
                      (let $new-state (new-state $value)
                      (add-atom (get-state &goals) (= ($prop_name (Goal $goal)) $new-state))
                   ))
              ''')

        times=[]
        for i in range(100):
            start = time.time()
            self.metta.run(f"!(new-goal-property! goal{i} status value{i})")
            times.append(time.time() - start)
        print("add with states", sum(times)/len(times))


        times = []
        for i in range(100):
            start = time.time()
            self.metta.run(f"!(change-state! (match (get-state &goals) (= (status (Goal goal{i})) $x) $x) value{i*2})")
            times.append(time.time() - start)
        print("change with states", sum(times) / len(times))
        #add with states 0.00022174835205078126
        #change with states 0.00013481855392456055
        #print(self.get_atoms("goals"))

    def test_for_change_goal_property_no_states(self):
        self.metta = hp.MeTTa()
        self.metta.run('''
                   ! (bind! &goals  (new-state (new-space)))
                   
                   ''')
        self.metta.run(f'''
                  (= (new-goal-property! $goal $prop_name $value)
                      (add-atom (get-state &goals) (= ($prop_name (Goal $goal)) $value))
                   )
              ''')

        self.metta.run(f'''
                        (= (replace-atom $space $from $to)(superpose ((remove-atom (get-state $space) $from) (add-atom (get-state $space) $to))))
                      ''')
        times=[]
        for i in range(100):
            start = time.time()
            self.metta.run(f"!(new-goal-property! goal{i} status value{i})")
            times.append(time.time() - start)
        print("add with values", sum(times)/len(times))

        times = []
        for i in range(100):
            start = time.time()
            self.metta.run(
                f"!(replace-atom &goals (= (status (Goal goal{i})) value{i}) (= (status (Goal goal{i})) value{i*2}))")
            times.append(time.time() - start)
        print("change with values", sum(times) / len(times))
        #add with values 0.00014554738998413087
        # change with values 0.0003659176826477051
        #print(self.get_atoms("goals"))

    def test_for_match_goal_property_with_states(self):
        self.metta = hp.MeTTa()
        self.metta.run('''
                   ! (bind! &goals  (new-state (new-space)))

                   ''')
        self.metta.run(f'''
                  (= (new-goal-property! $goal $prop_name $value)
                      (let $new-state (new-state $value)
                      (add-atom (get-state &goals) (= ($prop_name (Goal $goal)) $new-state))
                   ))
              ''')
        statuses = ["active", "done", "paused"]
        for name in statuses:
            self.metta.run(f"!(bind! &state-{name} (new-state {name}))")
        times = []
        for st in statuses:
            for i in range(100):
                start = time.time()
                self.metta.run(f"!(new-goal-property! goal-{st}-{i} status {st})")
                times.append(time.time() - start)
        print("add with states", sum(times) / len(times))
        times = []
        for i in range(100):
            start = time.time()
            res = self.metta.run(
                f"!(match (get-state &goals) (= (status (Goal $goal)) &state-active) $goal)", True)
            times.append(time.time() - start)
        print("match with states for 100 matcher", sum(times) / len(times))


        self.metta.run(f"!(new-goal-property! goal{8} status waiting)")
        self.metta.run(f"!(new-goal-property! goal{5} status waiting)")
        self.metta.run(f"!(new-goal-property! goal{28} status waiting)")
        self.metta.run(f"!(new-goal-property! goal{25} status waiting)")
        times = []
        for i in range(100):
            start = time.time()
            res = self.metta.run(
                f"!(match (get-state &goals) (= (status (Goal $goal)) &state-waiting) $goal)", True)
            times.append(time.time() - start)
        atoms = self.get_atoms("goals")
        print("atoms_count", len(atoms))
        print("match with states for 3 matched", sum(times) / len(times))

        # add with states 0.0002418677012125651
        # match with states for 100 matched  0.0024404644966125487
        # match with states for 3 matched 0.001107165813446045


    def test_for_match_goal_property_no_states(self):
        self.metta = hp.MeTTa()
        self.metta.run('''
                   ! (bind! &goals  (new-state (new-space)))

                   ''')
        self.metta.run(f'''
                         (= (new-goal-property! $goal $prop_name $value)
                             (add-atom (get-state &goals) (= ($prop_name (Goal $goal)) $value))
                          )
                     ''')
        statuses = ["active", "done", "paused"]
        times = []

        for st in statuses:
            for i in range(100):
                start = time.time()
                self.metta.run(f"!(new-goal-property! goal-{st}-{i} status {st})")
                times.append(time.time() - start)
        print("add with values", sum(times) / len(times))
        times = []
        for i in range(100):
            start = time.time()
            res = self.metta.run(
                f"!(match (get-state &goals) (= (status (Goal $goal)) active) $goal)", True)
            times.append(time.time() - start)
        print("match with values for 100 matcher", sum(times) / len(times))


        self.metta.run(f"!(new-goal-property! goal{8} status waiting)")
        self.metta.run(f"!(new-goal-property! goal{5} status waiting)")
        self.metta.run(f"!(new-goal-property! goal{28} status waiting)")
        self.metta.run(f"!(new-goal-property! goal{25} status waiting)")

        for i in range(100):
            start = time.time()
            res = self.metta.run(
                f"!(match (get-state &goals) (= (status (Goal $goal)) waiting) $goal)", True)
            times.append(time.time() - start)
        print("match with values for 3 matched", sum(times) / len(times))

        # add with values 0.00013868014017740885
        # match with values for 100 matcher 0.0014352774620056152
        # match with values for 3 matched 0.0008123373985290527



    def test_for_change_states_property_with_states(self):
        self.metta = hp.MeTTa()
        self.metta.run('''
                     ! (bind! &persons  (new-state (new-space)))
                   ''')
        self.metta.run(f'''
                 (= (new-person-property-dict! $person_id $dict-name $key $value)
                                               (let $new-state (new-state (StateValue $value))
                                               (add-atom (get-state &persons) ((PersonId $person_id) ((dict-name $dict-name) (dict-key $key)) $new-state))
                 ))
              ''')
        self.metta.run(f'''(= (change-person-property-dict! $person_id $array-name $key $value)
                    (change-state!  (match (get-state &persons) ((PersonId $person_id)  ((dict-name $dict-name) (dict-key $key)) $x) $x)  (StateValue $value)))
                                                             ''')
        times=[]
        for i in range(100):
            start = time.time()
            self.metta.run(f"!(new-person-property-dict! {i} dict-name key{i} value{i})")
            times.append(time.time() - start)
        print("add dict with states", sum(times)/len(times))


        times = []
        for i in range(100):
            start = time.time()
            self.metta.run(f"!(change-person-property-dict! {i} dict-name key{i} value{i*2})")
            times.append(time.time() - start)
        print("change  dict with states", sum(times) / len(times))
        # add dict with states 0.00046720743179321287
        # change  dict with states 0.00047077655792236326
        # print(self.get_atoms("persons"))

    def test_for_change_states_property_no_states(self):
        self.metta = hp.MeTTa()
        self.metta.run('''
                          ! (bind! &persons  (new-state (new-space)))
                        ''')
        self.metta.run(f'''
                      (= (new-person-property-dict! $person_id $dict-name $key $value)
                                                    (add-atom (get-state &persons) ((PersonId $person_id) ((dict-name $dict-name) (dict-key $key)) (StateValue $value))
                      ))
                   ''')
        self.metta.run(f'''(= (replace-atom $space $from $to)(superpose ((remove-atom (get-state $space) $from) (add-atom (get-state $space) $to))))
                                          ''')
        times = []
        for i in range(100):
            start = time.time()
            self.metta.run(f"!(new-person-property-dict! {i} dict-name key{i} value{i})")
            times.append(time.time() - start)
        print("add dict with values", sum(times) / len(times))

        times = []
        for i in range(100):
            start = time.time()
            self.metta.run(f"!(replace-atom   &persons ((PersonId {i}) ((dict-name dict-name) (dict-key key{i})) (StateValue value{i}))\
            ((PersonId {i}) ((dict-name dict-name) (dict-key key{i})) (StateValue value{i*2})))")
            times.append(time.time() - start)
        print("change dict with values", sum(times) / len(times))
        # add dict with values 0.00027881145477294924
        # change dict with values 0.0008235692977905274
        #print(self.get_atoms("persons"))



    def test_for_matching_states_property_with_states(self):
        self.metta = hp.MeTTa()
        self.metta.run('''
                        ! (bind! &states  (new-state (new-space)))
                      ''')

        self.metta.run('''(= (get-state-value (StateValue $str)) $str)''')
        self.metta.run('''(= (get-state-value (StateVar $str)) (StateVar $str))''')
        self.metta.run(f'''(= (new-state-array-index! $array-name $space)
                                                      (let $new-state (new-state 0)
                                                      (add-atom (get-state $space) ((array-name $array-name) $new-state))))''')

        self.metta.run(f'''(= (get-state-array-last-index! $array-name $space)
                         (case (match (get-state $space)((array-name $array-name) $x) (get-state $x))
                        ((%void% (superpose((new-state-array-index! $array-name $space) 0 ))) ($x $x))))''')
        self.metta.run(f'''(= (set-state-array-index! $array-name $index $space)
                             (change-state! (match (get-state $space)((array-name $array-name) $x) $x) $index))''')

        self.metta.run(f'''(= (new-array-state-value! $array-name $value $space)
                                        (let $new-state (new-state (StateValue $value))
                                        (let $index   (get-state-array-last-index! $array-name $space)
                                        (superpose ((add-atom (get-state $space)  ((array-name $array-name) (index $index) $new-state))
                                        (set-state-array-index! $array-name (+ $index 1) $space))))))
                                                           ''')
        self.metta.run(
            f'''(= (get-array-state-index! $array-name $value $space)
                     (match (get-state $space) ((array-name $array-name) (index $x) $y) (if (==  $value (get-state-value (get-state $y))) $x (superpose ()))))''')

        times = []
        for i in range(100):
            for name in ["one", "two", "three"]:
                start = time.time()
                res = self.metta.run(f"!(new-array-state-value! {name} value{i % 3} &states)")
                times.append(time.time() - start)

        for i in range(100):
            for name in ["one", "two", "three"]:
                start = time.time()
                res = self.metta.run(f"!(new-array-state-value! {name} value{3 + i} &states)")
                times.append(time.time() - start)

        print("add array with states", sum(times) / len(times))

        times = []
        res = []
        for i in range(100):
            start = time.time()
            res = self.metta.run(
                f"!(get-array-state-index! two value5  &states)", True)
            times.append(time.time() - start)
        atoms = self.get_atoms("states")
        print(f"match array with states for {len(res)} matched atoms ({len(atoms)})", sum(times) / len(times))

        times = []
        res = []
        for i in range(100):
            start = time.time()
            res = self.metta.run(
                f"!(get-array-state-index! two value{i % 3} &states)", True)
            times.append(time.time() - start)
        atoms = self.get_atoms("states")
        print(f"match array with states for {len(res)} matched atoms ({len(atoms)})", sum(times) / len(times))
        #print(atoms)
        # add array with states 0.001304538647333781
        # match array with states for 1 matched atoms (603) 0.08631737232208252
        # match array with states for 34 matched atoms (603) 0.08681018352508545



    def test_for_matching_states_property_no_states(self):
        self.metta = hp.MeTTa()
        self.metta.run('''  ! (bind! &states  (new-state (new-space)))
                              ''')

        self.metta.run('''(= (get-state-value (StateValue $str)) $str)''')
        self.metta.run('''(= (get-state-value (StateVar $str)) (StateVar $str))''')
        self.metta.run(f'''(= (new-state-array-index! $array-name $space)
                                                              (add-atom (get-state $space) ((array-name $array-name) 0)))''')

        self.metta.run(f'''(= (get-state-array-last-index! $array-name $space)
                                 (case (match (get-state $space)((array-name $array-name) $x)  $x)
                                ((%void% (superpose((new-state-array-index! $array-name $space) 0 ))) ($x $x))))''')

        self.metta.run(f'''(= (replace-atom $space $from $to)(superpose ((remove-atom (get-state $space) $from) (add-atom (get-state $space) $to))))
                                     ''')

        self.metta.run(f'''(= (set-state-array-index! $array-name $index $space)
                                     (match (get-state $space)((array-name $array-name) $x)
                                      (replace-atom $space ((array-name $array-name) $x) ((array-name $array-name) $index))))''')


        self.metta.run(f'''(= (new-array-state-value! $array-name $value $space)
                                                (
                                                (let $index   (get-state-array-last-index! $array-name $space)
                                                (superpose ((add-atom (get-state $space)  ((array-name $array-name) (index $index) $value))
                                                (set-state-array-index! $array-name (+ $index 1) $space))))))
                                                                   ''')


        self.metta.run(
            f'''(= (get-array-state-index! $array-name $value $space)
                             (match (get-state $space) ((array-name $array-name) (index $x) $value) $x))''')


        times = []
        for i in range(100):
            for name in ["one", "two", "three"]:
                start = time.time()
                res = self.metta.run(f"!(new-array-state-value! {name} value{i % 3} &states)")
                times.append(time.time() - start)

        for i in range(100):
            for name in ["one", "two", "three"]:
                start = time.time()
                res = self.metta.run(f"!(new-array-state-value! {name} value{3 + i} &states)")
                times.append(time.time() - start)

        print("add array with states", sum(times) / len(times))

        times = []
        res = []
        for i in range(100):
            start = time.time()
            res = self.metta.run(
                f"!(get-array-state-index! two value5  &states)", True)
            times.append(time.time() - start)
        atoms = self.get_atoms("states")
        print(f"match array with states for {len(res)} matched atoms ({len(atoms)})", sum(times) / len(times))

        times = []
        res = []
        for i in range(100):
            start = time.time()
            res = self.metta.run(
                f"!(get-array-state-index! two value{i % 3} &states)", True)
            times.append(time.time() - start)
        atoms = self.get_atoms("states")
        print(f"match array with states for {len(res)} matched atoms ({len(atoms)})", sum(times) / len(times))
        #add array with states 0.0028551626205444336
        #match array with states for 1 matched atoms (603) 0.00017339706420898437
        #match array with states for 34 matched atoms (603) 0.0012348747253417968
        #print(atoms)






