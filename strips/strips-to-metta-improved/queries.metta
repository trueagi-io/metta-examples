; !(import! &self logistics-i-1.metta)
!(import! &self blocks-i-1.metta)

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

# GET ALL STATE NUMBERS
!(match &self (= (valuation (state $n)) $r) $n)     ; > [0, 1, 2]

