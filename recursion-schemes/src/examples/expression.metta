!(transfer! "schemes.metta")

; How to apply a function to the slots, a Functor's map
(= (mapExpr $f (Plus $x $y)) (Plus ($f $x) ($f $y)))
(= (mapExpr $f (Const $x)) (Const $x))
(= (mapExpr $f (Var $x)) (Var $x))

; How to evaluate the structure to some value, a single step, an algebra
(= (evalExpr (Plus $x $y)) (+ $x $y))
(= (evalExpr (Const $x)) $x)
(= (evalExpr (Var $x)) (valueOf $x))

; Dictionary we can use during evaluation
(= (valueOf X) 0)
; A fold, with the Functor and algebra, applied to the Fix tree
!((cata mapExpr evalExpr) (Fix (Plus (Fix (Plus (Fix (Var X)) (Fix (Const 2)))) (Fix (Const 40)))))

; How to generate the structure based on some value, a single step, a co-algebra
(= (nTimes (, $x (S (S $n)))) (Plus (, $x (S Z)) (, $x (S $n))))
(= (nTimes (, $x (S Z))) (Const $x))
(= (nTimes (, $_ Z)) (Const 0))

; An unfold, with the Functor and co-algebra, applied to some seed value
!((ana mapExpr nTimes) (, 2 (S (S Z))))

; Combining both into a "re-fold", starting with a (co-algebra) seed value, ending with a (algebra) result value
!((hylo mapExpr evalExpr nTimes) (, 3 (S (S (S Z)))))

; How to evaluate the structure, with access to the original expression (on top of the processed value)
(= (diff (Const $_)) (Fix (Const 0)))
(= (diff (Var $_)) (Fix (Const 1)))
(= (diff (Plus (, $dx $x) (, $dy $y))) (Fix (Plus $dx $dy)))
; (= (diff (Times (, $dx $x) (, $dy $y))) (Fix (Plus (Fix (Times $dx $y)) (Fix (Times $dy $x)))))

!((para mapExpr diff) (Fix (Plus (Fix (Var X)) (Fix (Const 1)))))

; Unfold shorthand definitions like "1p" for "1 + X" into a Bind-Pure tree of expressions
(= (expand (1p $x)) (Plus (Bind (Const 1)) (Pure $x)))
(= (expand (2t $x)) (Plus (Pure $x) (Pure $x)))
(= (expand (Fix $x)) $x)

; Everything this can process
!(match &self (= (expand $X) $Y) $X)
; Expand the definition
!((futu mapExpr expand) (2t (1p (Fix (Var X)))))
