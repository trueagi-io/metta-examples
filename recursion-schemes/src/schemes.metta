!(transfer! "base.metta")

(= ((cata $F $alg) $a) ($alg ($F (cata $F $alg) (unFix $a))))

(= ((ana $F $coalg) $s) (fix ($F (ana $F $coalg) ($coalg $s))))

(= ((hylo $F $alg $coalg) $s) ($alg ($F (hylo $F $alg $coalg) ($coalg $s))))
