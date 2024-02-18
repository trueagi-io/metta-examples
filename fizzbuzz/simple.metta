(= (fizzbuzz $count) (fizzbuzz_ (% $count 3) (% $count 5) $count))
(= (fizzbuzz $count) (if (> $count 1) (fizzbuzz (- $count 1)) (empty)) )

(= (fizzbuzz_ $fizz $buzz $n) (case ($fizz $buzz) (
    ((0 0) (FizzBuzz $n))
    ((0 $_1) (Fizz $n))
    (($_2 0) (Buzz $n))
    ($_3 (Nothing $n))
)))

!(fizzbuzz 50)