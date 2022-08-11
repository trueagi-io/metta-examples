!(transfer! "base.metta")

(= ((cata $F $alg) $a) ($alg ($F (cata $F $alg) (unFix $a))))
