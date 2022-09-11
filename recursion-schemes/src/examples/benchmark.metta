!(transfer! "schemes.metta")

(= (mapExpr $f (Plus $x $y)) (Plus ($f $x) ($f $y)))
(= (mapExpr $f (Const $x)) (Const $x))
(= (mapExpr $f (Var $x)) (Var $x))

(= (mapNat $f (S $n)) (S ($f $n)))
(= (mapNat $f Z) Z)

(= (evalExpr (Plus $x $y)) (+ $x $y))
(= (evalExpr (Const $x)) $x)
(= (evalExpr (Var $x)) (valueOf $x))

(= (nTimes (, $x (S (S $n)))) (Plus (, $x (S Z)) (, $x (S $n))))
(= (nTimes (, $x (S Z))) (Const $x))
(= (nTimes (, $_ Z)) (Const 0))

(= (if True $x $y) $x)
(= (if False $x $y) $y)

(= (peano $n) (if (== $n 0) Z (S (- $n 1))))

!((hylo mapExpr evalExpr nTimes) (, 3 ((cata mapNat identity) ((ana mapNat peano) 10))))
