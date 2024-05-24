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
(= (eval state $idx $action)
  (union (subtract (valuation (state $idx)) (collapse (eff-neg $action))) (eff-pos $action))
)

!(eff-pos (pick-up A))          ; > [(holding A)]
!(eff-neg (pick-up A))          ; > [(ontable A), (clear A), (handempty)]
!(eval state 0 (pick-up A))     ; > [(holding A), (ontable C), (clear B), (clear D), (ontable B), (ontable D), (clear C)]

