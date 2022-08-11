!(transfer! "base.metta")

(= ((cata $F $alg) $a) ($alg ($F (cata $F $alg) (unFix $a))))

(= ((para_pair $F $alg) $a) (, ((para $F $alg) $a) $a))
(= ((para $F $alg) $a) ($alg ($F (para_pair $F $alg) (unFix $a))))

(= ((ana $F $coalg) $s) (Fix ($F (ana $F $coalg) ($coalg $s))))

(= ((hylo $F $alg $coalg) $s) ($alg ($F (hylo $F $alg $coalg) ($coalg $s))))
