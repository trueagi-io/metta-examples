; !(import! &self logistics-i-1)
!(import! &self blocks-i-1)

; UTILITY
(= (fmap $f ($a $x $y) ) ($a ($f $x) ($f $y)))

!(assertEqual (valuation (state 0))
              (superpose ((ontable A) (ontable B) (ontable C) (ontable D) (clear A) (clear B) (clear C) (clear D) (handempty))))

; GET ARITY OF A PROPOSITION
(= (arity $prop) (match &self (arity $prop $n) $n))

!(assertEqual (arity on) 2)


; EXECUTE ACTION ON STATE
; apply an action on a state and get the resulting state
; TODO check whether preconditions are met
; TODO unique union
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

; TODO add only save if the state does not exist yet, otherwise give state index
(= (save $conditions)
   (let* (($current_id (get-state state#))
          ($_1 (add-atom &self (= (valuation (state $current_id))
                               (superpose $conditions))))
          ($_2 (change-state! state# (+ (get-state state#) 1))))
    $current_id))

; !(save (superpose ((test A) (test B))))
!(save ((on a b) (holding b)))
!(save ((on smt smt) (holding smt)))

!(assertEqual (valuation (state 1))
              (superpose ((on a b) (holding b))))
!(assertEqual (valuation (state 2))
              (superpose ((on smt smt) (holding smt))))


; GET ALL STATE NUMBERS AS SANITY CHECK
!(assertEqual (match &self (= (valuation (state $n)) $r) $n)
              (superpose (0 1 2)))


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
              (superpose (5)))

!(assertEqual (valuation (state (step (step (step (step 0
                                (pick-up B))
                                (stack B C))
                                (pick-up A))
                                (stack A B))))
              (superpose ((on A B) (on B C) (clear A) (clear D) (ontable C) (ontable D) (handempty))))


; CHECK WHETHER AN ACTION CAN BE APPLIED TO A STATE

; output True if $subset ⊆ $set, otherwise False
(= (subset $subset $set) (if (== (collapse (subtraction (superpose $subset) (intersection (superpose $set) (superpose $subset)))) ()) True False))

!(assertEqual (subset (a b) (a b c))
              True)
!(assertEqual (subset (a b c) (a b d))
              False)
!(assertEqual (subset (collapse (pre (pick-up A))) (collapse (valuation (state 0))))
              True)


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
