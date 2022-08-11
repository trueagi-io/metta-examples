!(transfer! "schemes.metta")

(= (mapExpr $f (Plus $x $y)) (Plus ($f $x) ($f $y)))
(= (mapExpr $f (Const $x)) (Const $x))

(= (evalExpr (Plus $x $y)) ($x + $y))
(= (evalExpr (Const $x)) $x)

!((cata mapExpr evalExpr) (Fix (Plus (Fix (Plus (Fix (Const 1)) (Fix (Const 2)))) (Fix (Const 3)))))
