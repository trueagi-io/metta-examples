; !(import! &self logistics-i-1)
!(import! &self blocks-i-1)

; UTILITY FUNCTIONS
(= (eq? $x $y) (== $x $y))
(= (union $x $y) $x)
(= (union $x $y) $y)
(= (intersection $x $x) $x)
(= (intersection $x $y) (empty))
(= (right-only $c $u) (if (right-only_ $c $u) $u (empty)))
(= (right-only_ $c $u) (eq? () (collapse (intersection $u (superpose $c)))))
(= (subtract $x $y) (right-only $y $x))


!(valuation (state 0))
; > [(clear A), (ontable C), (clear B), (clear D), (ontable A), (ontable B), (handempty), (ontable D), (clear C)]

; GET ARITY OF A PROPOSITION
(= (arity $prop) (match &self (arity $prop $n) $n))

!(arity on)         ; > 2


; EXECUTE ACTION ON STATE
; apply an action on a state and get the resulting state
; TODO check whether preconditions are met
; TODO unique union
(= (eval (state $idx) $action)
  (union (subtract (valuation (state $idx)) (collapse (eff-neg $action))) (eff-pos $action))
)

!(eff-pos (pick-up A))          ; > [(holding A)]
!(eff-neg (pick-up A))          ; > [(ontable A), (clear A), (handempty)]
!(eval (state 0) (pick-up A))     ; > [(holding A), (ontable C), (clear B), (clear D), (ontable B), (ontable D), (clear C)]


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

!(valuation (state 1))                      ; > [(on a b), (holding b)]
!(valuation (state 2))                      ; > [(on smt smt), (holding smt)]

; GET ALL STATE NUMBERS AS SANITY CHECK
!(match &self (= (valuation (state $n)) $r) $n)     ; > [0, 1, 2]


; EXAMPLE STACK BLOCKS A AND B

!(valuation (state (save (collapse (eval (state 0) (pick-up A))))))
!(valuation (state (save (collapse (eval (state (idx)) (stack A B))))))


; EXAMPLE MAKE TOWER A on B on C
(= (step $idx $action)
  (save (collapse (eval (state $idx) $action)))
)

!(step (state 0) (pick-up A))

!(valuation (state (step (step (step (step 0
                    (pick-up B))
                    (stack B C))
                    (pick-up A))
                    (stack A B))))


; CHECK WHETHER AN ACTION CAN BE APPLIED TO A STATE

; output True if $subset ⊆ $set, otherwise False
(= (subset $subset $set) (if (== (collapse (subtraction (superpose $subset) (intersection (superpose $set) (superpose $subset)))) ()) True False))

!(subset (a b) (a b c))         ; > True
!(subset (a b c) (a b d))       ; > False
!(subset  (collapse (pre (pick-up A))) (collapse (valuation (state 0))))        ; > True


; output True if $action can be applied in state $idx, otherwise False
(= (can-apply (state $idx) $action) (subset (collapse (pre $action)) (collapse (valuation (state $idx)))))

!(pre (pick-up A))
!(valuation (state 0))
!(can-apply (state 0) (pick-up A))      ; > True
!(can-apply (state 0) (stack A B))      ; > False

; FIND ALL ACTIONS


; FIND ALL OBJECTS OF GIVEN TYPE


; GROUND ALL ACTIONS


; FIND ALL ACTIONS THAT CAN BE APPLIED TO A STATE
