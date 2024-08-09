(= (C $n $k) (if (== $n 1) $k (if (== (% $n 2) 0) (C (/ $n 2) (+ $k 1)) (C (+ (* 3 $n) 1) (+ $k 1)))))

(= (Collatz $n) (C $n 0))
!(Collatz 9)