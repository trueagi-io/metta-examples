; WIP

(= (halfr (S (S $x)) $y) (halfr $x (S $y)))
(= (halfr (S Z) $y) (Odd $y))
(= (halfr Z $y) (Even $y))

(= (tripler (S $x)) (S (S (S (tripler $x)))))
(= (tripler Z) Z)

(= (PC (Even (S Z)) $d) (+ $d 1))
(= (PC (Even (S (S $x))) $d) (PC (halfr (S (S $x)) Z) (+ $d 1)))
(= (PC (Odd Z) $d) $d)
(= (PC (Odd (S $x)) $d) (PC (halfr (S (S (tripler (S $x)))) Z) (+ $d 2)))

(= (Collatz $n) (PC (halfr $n Z) 0))

!(Collatz (S (S Z)))
!(Collatz (S (S (S Z))))
!(Collatz (S (S (S (S Z)))))
!(Collatz (S (S (S (S (S Z))))))
!(Collatz (S (S (S (S (S (S Z)))))))
!(Collatz (S (S (S (S (S (S (S Z))))))))
!(Collatz (S (S (S (S (S (S (S (S Z)))))))))
!(Collatz (S (S (S (S (S (S (S (S (S Z))))))))))
!(Collatz (S (S (S (S (S (S (S (S (S (S Z)))))))))))

