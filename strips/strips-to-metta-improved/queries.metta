; !(import! &self logistics-i-1)
!(import! &self blocks-i-1)

; UTILITY FUNCTIONS
(= (fmap $f ($a $x $y) ) ($a ($f $x) ($f $y)))

; return True if $subset ⊆ $set, otherwise False
(= (subset $subset $set) (if (== (collapse (subtraction (superpose $subset) (intersection (superpose $set) (superpose $subset)))) ()) True False))

!(assertEqual (subset (a b) (a b c))
              True)
!(assertEqual (subset (a b c) (a b d))
              False)
!(assertEqual (subset (collapse (pre (pick-up A))) (collapse (valuation (state 0))))
              True)

; equality of two sets, returns True iff s1 == s2
(= (seteq $set1 $set2) (and (subset $set1 $set2) (subset $set2 $set1)))

!(assertEqual (seteq (a b c) (b c a))
               True)

!(assertEqual (seteq (a b c d) (b c a))
               False)


; GET PROPOSTITIONS THAT HOLD IN A STATE
!(assertEqual (valuation (state 0))
              (superpose ((ontable A) (ontable B) (ontable C) (ontable D) (clear A) (clear B) (clear C) (clear D) (handempty))))


; GET ARITY OF A PROPOSITION
(= (arity $prop) (match &self (arity $prop $n) $n))

!(assertEqual (arity on) 2)


; EXECUTE ACTION ON STATE
; apply an action on a state and get the resulting state

(= (eval (state $idx) $action)
  (union (subtraction (valuation (state $idx)) (eff-neg $action)) (eff-pos $action))
)

!(assertEqual (eff-pos (pick-up A))
              (superpose ((holding A))))
!(assertEqual (eff-neg (pick-up A))
              (superpose ((ontable A) (clear A) (handempty))))
!(assertEqual (eval (state 0) (pick-up A))
              (superpose ((holding A) (ontable C) (clear B) (clear D) (ontable B) (ontable D) (clear C))))


; SAVE NEW STATE
!(bind! state# (new-state 1))
(= (idx) (- (get-state state#) 1))

; adds the state atom to the atom space (also if it already exists)
(= (save $conditions)
   (let* (($current_id (get-state state#))
          ($_1 (add-atom &self (= (valuation (state $current_id))
                               (superpose $conditions))))
          ($_2 (change-state! state# (+ (get-state state#) 1))))
    $current_id))

!(save ((test s1) (holding b)))
!(save ((test s2) (on smt smt)))

!(assertEqual (valuation (state 1))
              (superpose ((test s1) (holding b))))
!(assertEqual (valuation (state 2))
              (superpose ((test s2) (on smt smt))))

!(assertEqual (seteq (collapse (valuation (state 0)))
                     ((ontable A) (ontable B) (ontable C) (ontable D) (clear A) (clear B) (clear C) (clear D) (handempty)))
               True)

!(assertEqual (match &self (= (valuation (state $idx)) $props) (if (seteq (collapse $props) (collapse (valuation (state 0)))) $idx (empty)))
               0)


; return index of the state in which certain propositions hold
(= (find_state $props) (match &self (= (valuation (state $idx)) $props2)
                       (if (seteq $props (collapse $props2)) $idx (empty))))


!(assertEqual (find_state (collapse (valuation (state 0))))
               0)

!(assertEqual (find_state ((ontable A) (ontable B) (ontable C) (ontable D) (clear A) (clear B) (clear C) (clear D) (handempty)))
              0)

!(assertEqual (find_state (a b c))
              (empty))

; TODO how to make this equality work?
; now: > [(Error (empty) NoValidAlternatives)]
; !(==  (find_state (a b c)) (empty))


; only save a state if the it does not exist yet, otherwise return state index
(= (save_if_new $conditions)
    (case (find_state $conditions)
         ((Empty (save $conditions))
          ($idx $idx))
    )
)

!(assertEqual (save_if_new ((test s3)))
              (- (get-state state#) 1))

!(assertEqual (valuation (state (- (get-state state#) 1)))
              (superpose ((test s3))))


!(assertEqual (save_if_new ((ontable A) (ontable B) (ontable C) (ontable D) (clear A) (clear B) (clear C) (clear D) (handempty)))
              0)



; GET ALL STATE NUMBERS AS SANITY CHECK
!(assertEqual (match &self (= (valuation (state $n)) $r) $n)
              (superpose (0 1 2 3)))


; EXAMPLE: STACK BLOCKS A AND B
; in the initial state all blocks lie on the table
; pick up A
!(assertEqual (valuation (state (save (collapse (eval (state 0) (pick-up A))))))
              (superpose ((holding A) (ontable B) (ontable C) (ontable D) (clear B) (clear C) (clear D))))
; stack A on B
!(assertEqual (valuation (state (save (collapse (eval (state (idx)) (stack A B))))))
              (superpose ((on A B) (handempty)
                          (clear A) (clear C) (clear D)
                          (ontable B) (ontable C) (ontable D))))


; CHAIN ACTIONS: EXAMPLE MAKE TOWER A on B on C
(= (step $idx $action)
  (save (collapse (eval (state $idx) $action)))
)

!(assertEqual (step (state 0) (pick-up A))
              6)

!(assertEqual (valuation (state (step (step (step (step 0
                                (pick-up B))
                                (stack B C))
                                (pick-up A))
                                (stack A B))))
              (superpose ((on A B) (on B C) (clear A) (clear D) (ontable C) (ontable D) (handempty))))


; CHECK WHETHER AN ACTION CAN BE APPLIED TO A STATE

; output True if $action can be applied in state $idx, otherwise False
(= (can-apply (state $idx) $action) (subset (collapse (pre $action)) (collapse (valuation (state $idx)))))

!(assertEqual (pre (pick-up A))
              (superpose ((clear A) (ontable A) (handempty))))
!(assertEqual (valuation (state 0))
              (superpose ((ontable A) (ontable B) (ontable C) (ontable D) (clear A) (clear B) (clear C) (clear D) (handempty))))

!(assertEqual (can-apply (state 0) (pick-up A))
              True)
!(assertEqual (can-apply (state 0) (stack A B))
              False)

; FIND ALL ACTIONS
(= (all-actions) (match &self (action $name) $name))
!(assertEqual (all-actions)
              (superpose (put-down pick-up unstack stack)))


; FIND ALL OBJECTS OF GIVEN TYPE
; TODO transitivity of types
(= (oftype $type) (match &self (isa $name $type) $name))
!(assertEqual (oftype object)
              (superpose (A B C D)))


; GROUND ACTIONS
;!(action (oftype object) (oftype object))       ; > [(action A A), (action A C), (action A B), (action A D), (action C A), (action C C), (action C B), (action C D), (action B A), (action B C), (action B B), (action B D), (action D A), (action D C), (action D B), (action D D)]


; (= (ground $action) (fmap oftype (match &self (types $action ($x $y)) ($action $x $y))))

(= (ground $action) (match &self (types $action ()) ($action)))
(= (ground $action) (match &self (types $action ($x)) ($action (oftype $x))))
(= (ground $action) (match &self (types $action ($x $y)) ($action (oftype $x) (oftype $y))))
(= (ground $action) (match &self (types $action ($x $y $z)) ($action (oftype $x) (oftype $y) (oftype $z))))

!(assertEqual (ground pick-up)
              (superpose ((pick-up A) (pick-up B) (pick-up C) (pick-up D))))

!(assertEqual (ground stack)
              (superpose ((stack A A) (stack A B) (stack A C) (stack A D)
                          (stack B A) (stack B C) (stack B B) (stack B D)
                          (stack C A) (stack C B) (stack C C) (stack C D)
                          (stack D A) (stack D B) (stack D C) (stack D D))))


; GET ALL GROUNDED ACTIONS
!(assertEqual (ground (all-actions))
              (superpose ((pick-up A) (pick-up B) (pick-up C) (pick-up D)
                          (put-down A) (put-down B) (put-down C) (put-down D)
                          (stack A A) (stack A B) (stack A C) (stack A D)
                          (stack B A) (stack B C) (stack B B) (stack B D)
                          (stack C A) (stack C B) (stack C C) (stack C D)
                          (stack D A) (stack D B) (stack D C) (stack D D)
                          (unstack A A) (unstack A B) (unstack A C) (unstack A D)
                          (unstack B A) (unstack B C) (unstack B B) (unstack B D)
                          (unstack C A) (unstack C B) (unstack C C) (unstack C D)
                          (unstack D A) (unstack D B) (unstack D C) (unstack D D))))


; FIND ALL ACTIONS THAT CAN BE APPLIED TO A STATE
(= (apply-safe (state $idx) $action) (if (can-apply (state $idx) $action) (eval (state $idx) $action) (empty)))

!(assertEqual (apply-safe (state 0) (pick-up A))
              (superpose ((ontable B) (clear D) (clear C) (ontable D) (ontable C) (clear B) (holding A))))
!(assertEqual (apply-safe (state 0) (stack A B))
              (empty))


(= (partial-apply $a) (if (can-apply (state 0) $a) ($a (collapse (eval (state 0) $a))) (empty)))
;!(partial-apply (ground (all-actions)))



; CONSTRUCT TRANSITION SYSTEM

