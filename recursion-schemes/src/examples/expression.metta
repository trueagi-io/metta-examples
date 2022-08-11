!(transfer! "schemes.metta")

(= (mapExpr $f (Plus $x $y)) (Plus ($f $x) ($f $y)))
(= (mapExpr $f (Const $x)) (Const $x))

(= (evalExpr (Plus $x $y)) ($x + $y))
(= (evalExpr (Const $x)) $x)

!((cata mapExpr evalExpr) (Fix (Plus (Fix (Plus (Fix (Const 1)) (Fix (Const 2)))) (Fix (Const 3)))))

(= (nTimes (, $x (S (S $n)))) (Plus (, $x (S Z)) (, $x (S $n))))
(= (nTimes (, $x (S Z))) (Const $x))
(= (nTimes (, $_ Z)) (Const 0))

!((ana mapExpr nTimes) (, 2 (S (S Z))))

!((hylo mapExpr evalExpr nTimes) (, 3 (S (S (S Z)))))
