(= (range $start $end $step) (if (< $start $end) $start (empty)))
(= (range $start $end $step) (if (< $start $end) (range (+ $start $step) $end $step) (empty)))

; !(union (range 1 13 1) (range 10 20 2))
; !(intersection (range 1 13 1) (range 10 20 2))
; !(subtraction (range 10 20 2) (range 1 16 1))

(= (fizzbuzz $n)
  (let* (($m3 (collapse (range 3 $n 3)))
         ($m5 (collapse (range 5 $n 5)))
         ($r (collapse (range 1 $n 1)))
         ($m35 (collapse (intersection (superpose $m3) (superpose $m5))))
         ($m3n5 (collapse (subtraction (superpose $m3) (superpose $m5))))
         ($m5n3 (collapse (subtraction (superpose $m5) (superpose $m3))))
         ($m3m5 (collapse (union (superpose $m3) (superpose $m5))))
         ($n3n5 (collapse (subtraction (superpose $r) (superpose $m3m5)))))
        (union (union (FizzBuzz (superpose $m35)) (Nothing (superpose $n3n5))) (union (Fizz (superpose $m3n5)) (Buzz (superpose $m5n3))))))

!(unique (fizzbuzz 50))
