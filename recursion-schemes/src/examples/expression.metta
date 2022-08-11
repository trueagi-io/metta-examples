!(transfer! "schemes.metta")

(= (mapExpr $f (Plus $x $y)) (Plus ($f $x) ($f $y)))
(= (mapExpr $f (Const $x)) (Const $x))
(= (mapExpr $f (Var $x)) (Var $x))

(= (evalExpr (Plus $x $y)) (+ $x $y))
(= (evalExpr (Const $x)) $x)
(= (evalExpr (Var $x)) (valueOf $x))

(= (valueOf X) 0)
!((cata mapExpr evalExpr) (Fix (Plus (Fix (Plus (Fix (Var X)) (Fix (Const 2)))) (Fix (Const 40)))))

(= (nTimes (, $x (S (S $n)))) (Plus (, $x (S Z)) (, $x (S $n))))
(= (nTimes (, $x (S Z))) (Const $x))
(= (nTimes (, $_ Z)) (Const 0))

!((ana mapExpr nTimes) (, 2 (S (S Z))))

!((hylo mapExpr evalExpr nTimes) (, 3 (S (S (S Z)))))

(= (diff (Const $_)) (Const 0))
(= (diff (Var $_)) (Const 1))
(= (diff (Plus (, $x $_1) (, $y $_2))) (Plus $x $y))

!((para mapExpr diff) (Fix (Plus (Fix (Var X)) (Fix (Const 1)))))
