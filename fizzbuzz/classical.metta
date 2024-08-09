(= (range $start $end $step) (if (< $start $end) $start (empty)))
(= (range $start $end $step) (if (< $start $end) (range (+ $start $step) $end $step) (empty)))

(= (eq? $x $y) (== $x $y))
(= (divides $k $n) (eq? (% $n $k) 0))

(= (fizzbuzz $n) (FB (range 1 $n 1)))
(= (FB $n)
    (if (and (divides 3 $n) (divides 5 $n)) (FizzBuzz $n)
    (if (divides 3 $n) (Fizz $n)
    (if (divides 5 $n) (Buzz $n)
    (Nothing $n))))
)

!(fizzbuzz 50)
