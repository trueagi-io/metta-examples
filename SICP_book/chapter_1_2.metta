; Extension is used for several examples which requires random and current-inexact-milliseconds functions from Scheme
!(extend-py! additional_funcs.py)

(= (inc $x) (+ $x 1))
(= (dec $x) (- $x 1))

(= (sqr $x) (* $x $x))

; Since +,/,*,- in metta takes only two arguments as input:
(= (+3 $a $b $c) (+ $a (+ $b $c)))
(= (*3 $a $b $c) (* $a (* $b $c)))

; Recursive factorial evaluation
(= (factorial $n)
    (if (== $n 1)
    1
    (* $n (factorial (dec $n)))))

!(assertEqual
    (factorial 5)
    120)

; Iterative factorial evaluation
(= (ifactorial $n)
    (fact-iter 1 1 $n))

(= (fact-iter $product $counter $max-count)
    (if (> $counter $max-count)
        $product
        (fact-iter (* $counter $product) (+ $counter 1) $max-count)))

!(assertEqual
    (ifactorial 5)
    120)

; Recursive
(= (fib $n)
    (if (== $n 0)
        0
        (if (== $n 1)
            1
            (+ (fib (dec $n)) (fib (- $n 2))))))

!(assertEqual
    (fib 7)
    13)

; Iterative
(= (ifib $n)
    (fib-iter 1 0 $n))

(= (fib-iter $a $b $count)
    (if (== $count 0)
        $b
        (fib-iter (+ $a $b) $a (- $count 1))))

!(assertEqual
    (ifib 7)
    13)

(= (count-change $amount)
    (cc $amount 5))

(= (cc $amount $kinds-of-coins)
    (if (== $amount 0)
        1
        (if (or (< $amount 0) (== $kinds-of-coins 0))
            0
            (+ (cc $amount (- $kinds-of-coins 1))
                (cc (- $amount (first-denomination $kinds-of-coins)) $kinds-of-coins)))))

(= (first-denomination $kinds-of-coins)
    (case $kinds-of-coins
        (
            (1 1)
            (2 5)
            (3 10)
            (4 25)
            (5 50)
        )))

; In the book's example 100 is used to call function count-change, but for the sake of performance I've put 20 here.
!(assertEqual
    (count-change 20)
    9)

; Exercise 1.11.  A function f is defined by the rule that
; f(n) = n if n<3 and f(n) = f(n - 1) + 2f(n - 2) + 3f(n - 3) if n> 3.
;
; Write a procedure that computes f by means of a recursive process.
; Write a procedure that computes f by means of an iterative process.

(= (exercise_1_11r $n)
    (if (< $n 3)
        $n
        (+3 (exercise_1_11r (dec $n))
            (exercise_1_11r (- $n 2))
            (exercise_1_11r (- $n 3)))))

!(assertEqual
    (exercise_1_11r 7)
    37)

(= (exercise_1_11i $n)
  (exercise_1_11iter 0 1 2 $n))

(= (exercise_1_11iter $x0 $x1 $x2 $counter)
  (if (< $counter 3)
    $x2
    (exercise_1_11iter $x1 $x2 (+ $x2 (+ $x1 $x0)) (dec $counter))))

!(assertEqual
    (exercise_1_11i 7)
    37)
; -----------------------End of Exercise 1.11----------------------------

; Exercise 1.12.  The following pattern of numbers is called Pascal's triangle.
;
;                rows
;                 1 | 1
;                 2 | 1   1
;                 3 | 1   2   1
;                 4 | 1   3   3   1
;                 5 | 1   4   6   4   1
;                   --------------------
;               cols  1   2   3   4   5
; The numbers at the edge of the triangle are all 1, and each number inside
; the triangle is the sum of the two numbers above it.
; Write a procedure that computes elements of Pascal's triangle by means of a recursive process.

; $i - row, $j - col
(= (pascal_triangle_element $i $j)
  (if (or (< $j 1) (> $j $i))
        0
        (if (or (== $j 1) (== $i $j))
                1
                (+ (pascal_triangle_element (dec $i) $j)
                    (pascal_triangle_element (dec $i) (dec $j))))))

!(assertEqual
    (pascal_triangle_element 5 3)
    6)

!(assertEqual
    (pascal_triangle_element 4 3)
    3)
; -----------------------End of Exercise 1.12----------------------------

(= (expt $b $n)
    (if (== $n 0)
    1
    (* $b (expt $b (dec $n)))))

!(assertEqual
    (expt 2 3)
    8)


(= (iexpt $b $n)
    (expt-iter $b $n 1))

(= (expt-iter $b $counter $product)
    (if (== $counter 0)
        $product
        (expt-iter $b (dec $counter) (* $b $product))))

!(assertEqual
    (iexpt 2 3)
    8)

(= (fast-expt $b $n)
    (if (== $n 0)
        1
        (if (even? $n)
            (sqr (fast-expt $b (/ $n 2)))
            (* $b (fast-expt $b (dec $n))))))

(= (Abs $x) (if (< $x 0) (* $x -1) $x))

(= (even? $n)
    (== (remainder $n 2) 0))

; Remainder is the standard function in Scheme. In Metta we have "%":

(= (remainder $x $y) (% $x $y))

!(assertEqual
    (fast-expt 2 3)
    8)

; Exercise 1.16.
;
; Design a procedure that evolves an iterative exponentiation process that uses successive
; squaring and uses a logarithmic number of steps, as does fast-expt.
; (Hint: Using the observation that (b^(n/2))^2 = (b^2)^(n/2), keep, along with the exponent
; n and the base b, an additional state variable a, and define the state transformation in
; such a way that the product a bn is unchanged from state to state. At the beginning of
; the process a is taken to be 1, and the answer is given by the value of a at the end of the
; process. In general, the technique of defining an invariant quantity that remains unchanged
; from state to state is a powerful way to think about the design of iterative algorithms.)

(= (ifast-expt $b $n)
  (* (ifast-expt-iter $b $n 1) $b))

(= (ifast-expt-iter $b $n $a)
  (if (== $n 1)
    $a
    (if (even? $n)
        (ifast-expt-iter (sqr $b) (/ $n 2) (* $a $b))
        (ifast-expt-iter $b (dec $n) (* $a $b)))))

!(assertEqual
    (ifast-expt 2 3)
    8)
; -----------------------End of Exercise 1.16----------------------------


; Exercise 1.17.
;
; The exponentiation algorithms in this section are based on
; performing exponentiation by means of repeated multiplication.
; In a similar way, one can perform integer multiplication by means of repeated addition.
; The following multiplication procedure (in which it is assumed that our language can only add, not multiply)
; is analogous to the expt procedure:

; (define (* a b)
;   (if (= b 0)
;       0
;       (+ a (* a (- b 1)))))

; This algorithm takes a number of steps that is linear in b.
; Now suppose we include, together with addition, operations double,
; which doubles an integer, and halve, which divides an (even) integer by 2.
; Using these, design a multiplication procedure analogous to
; fast-expt that uses a logarithmic number of steps.

(= (double $x) (+ $x $x))
(= (halve $x) (/ $x 2))

(= (mul $a $b)
  (if (== $b 0)
    0
    (if (even? $b)
        (double (mul $a (halve $b)))
        (+ $a (mul $a (dec $b))))))

!(assertEqual
    (mul 15 24)
    360)
; -----------------------End of Exercise 1.17----------------------------

; Exercise 1.18
;
; Using the results of exercises 1.16 and 1.17, devise a procedure that generates
; an iterative process for multiplying two integers in terms of adding, doubling,
; and halving and uses a logarithmic number of steps.

(= (imul $a $b)
  (imul-iter $a $b 0))

(= (imul-iter $a $b $prod)
    (if (== $a 0)
        $prod
        (if (even? $a)
            (imul-iter (halve $a) (double $b) $prod)
            (if (> $a 0)
                (imul-iter (halve (dec $a)) (double $b) (+ $prod $b))
                (imul-iter (halve (inc $a)) (double $b) (- $prod $b))))))

!(assertEqual
    (imul 15 24)
    360)
; -----------------------End of Exercise 1.18----------------------------

; Exercise 1.19.
;
; There is a clever algorithm for computing the Fibonacci numbers in a logarithmic number of steps.
; Recall the transformation of the state variables a and b in the fib-iter process of section
; 1.2.2: a <- a + b and b <- a. Call this transformation T, and observe that applying T over
; and over again n times, starting with 1 and 0, produces the pair Fib(n + 1) and Fib(n).
; In other words, the Fibonacci numbers are produced by applying T^n, the nth power of the transformation T,
; starting with the pair (1,0). Now consider T to be the special case of p = 0 and q = 1 in a family of
; transformations Tpq, where Tpq transforms the pair (a,b) according to a <- bq + aq + ap and b <- bp + aq.
;
; Show that if we apply such a transformation Tpq twice, the effect is the same as using a single transformation
; Tp'q' of the same form, and compute p' and q' in terms of p and q. This gives us an explicit way to square these
; transformations, and thus we can compute Tn using successive squaring, as in the fast-expt procedure.

(= (lfib $n)
  (lfib-iter 1 0 0 1 $n))

(= (temp? $count) False)

(= (lfib-iter $a $b $p $q $count)
    (if (== $count 0)
        $b
        (if (even? $count)
            (lfib-iter  $a
                        $b
                        (+ (sqr $p) (sqr $q))
                        (+ (sqr $q) (*3 2 $p $q))
                        (/ $count 2))
            (lfib-iter  (+3 (* $b $q) (* $a $q) (* $a $p))
                        (+ (* $b $p) (* $a $q))
                        $p
                        $q
                        (dec $count)))))

!(assertEqual
    (lfib 8)
    21)
; -----------------------End of Exercise 1.19----------------------------

(= (gcd $a $b)
    (if (== $b 0)
    $a
    (gcd $b (remainder $a $b))))

!(assertEqual
    (gcd 206 40)
    2)

(= (smallest-divisor $n)
    (find-divisor $n 2))

(= (find-divisor $n $test-divisor)
    (if (> (sqr $test-divisor) $n)
        $n
        (if (divides? $test-divisor $n)
            $test-divisor
            (find-divisor $n (inc $test-divisor)))))

(= (divides? $a $b)
    (== (remainder $b $a) 0))

(= (prime? $n)
    (== $n (smallest-divisor $n)))

!(assertEqual
    (prime? 10)
    False)
!(assertEqual
    (prime? 11)
    True)

(: lambda1 (-> Variable Atom (-> $a $t)))
(= ((lambda1 $var $body) $val)
    (let $var $val $body) )

(= (expmod $base $exp $m)
    (if (== $exp 0)
        1
        (if (even? $exp)
            (remainder (sqr (expmod $base (/ $exp 2) $m)) $m)
            (remainder (* $base (expmod $base (dec $exp) $m)) $m))))

; randomint! is from additional_funcs.py extension
(= (random $end) (randomint! 0 $end))

(= (ferma-test $n)
    (let $try-it
        (lambda1 $a
            (== (expmod $a $n $n) $a))
            ($try-it (inc (random (dec $n))))))

(= (fast-prime? $n $times)
    (if (== $times 0)
        True
        (if (ferma-test $n)
            (fast-prime? $n (dec $times))
            False)))

; These two asserts could possibly fail due to non-deterministic nature of fast-prime? function.
!(assertEqual
    (fast-prime? 17 5)
    True)

!(assertEqual
    (fast-prime? 16 5)
    False)

; Exercise 1.21.  Use the smallest-divisor procedure to find the
; smallest divisor of each of the following numbers: 199, 1999, 19999.

!(assertEqual
    (smallest-divisor 199)
  199)

; These two takes too much time to evaluate so I've commented these lines.
;!(smallest-divisor 1999)
;!(smallest-divisor 19999)


; Exercise 1.22.
;
; Most Lisp implementations include a primitive called runtime that returns an
; integer that specifies the amount of time the system has been running
; (measured, for example, in microseconds). The following timed-prime-test procedure,
; when called with an integer n, prints n and checks to see if n is prime.
;
; If n is prime, the procedure prints three asterisks followed by the amount of time used in performing the test.

(= (timed-prime-test $n)
  (let* (
    (() (println! $n))
    (() (let $curtime (timems!) (start-prime-test $n $curtime))))
    () ))

(= (start-prime-test $n $start-time)
  (if (prime? $n)
      (report-prime (- (timems!) $start-time))
      (println! "not simple")))

(= (report-prime $elapsed-time)
    (let*
    (
        (() (println! " time in ms: "))
        (() (println! $elapsed-time))
    )
    ()))

; Using this procedure, write a procedure search-for-primes that checks the primality of
; consecutive odd integers in a specified range.
; Use your procedure to find the three smallest primes larger than: 1000, 10,000, 100,000 and 1,000,000.
;
; Note the time needed to test each prime.

; This function is right but it works longer than not right one.
(= (loop-search-for-primes $start $end)
    (if (>= $start $end)
        (println! "done searching")
        (if (even? $start)
            (loop-search-for-primes (inc $start) $end)
            (let*
            (
                (() (timed-prime-test $start))
                (() (loop-search-for-primes (inc $start) $end))
            )
            ()))))

; !(loop-search-for-primes 10 18)
; Output primes: 11 13 17, time on each prime: 63, 114, 401 ms. Time is only evaluated for checking if number is a prime
; not for entire loop-search function. Entire search is much longer. Strange thing is that if we will call timed-prime-test
; for those 3 numbers we will get different time:
;!(timed-prime-test 11)
;!(timed-prime-test 13)
;!(timed-prime-test 17)
; 44, 46 and 62 ms respectively. I don't know what it could be related to, but checking for prime using function
; loop-search takes more time with each consequent prime.
; Exercise asks us to check time for numbers 1009, 1013, 1019
; (also for much greater numbers but it takes too long to evaluate):
;!(timed-prime-test 1009) ; 3338 ms
;!(timed-prime-test 1013) ; 3329 ms
;!(timed-prime-test 1019) ; 3427 ms

; -----------------------End of Exercise 1.22----------------------------


; Exercise 1.23.
;
; The smallest-divisor procedure shown at the start of this section does lots of needless testing:
; After it checks to see if the number is divisible by 2 there is no point in checking to see if it
; is divisible by any larger even numbers. This suggests that the values used for test-divisor should
; not be 2, 3, 4, 5, 6, ..., but rather 2, 3, 5, 7, 9, .... To implement this change, define a procedure
; next that returns 3 if its input is equal to 2 and otherwise returns its input plus 2.
; Modify the smallest-divisor procedure to use (next test-divisor) instead of (+ test-divisor 1).
; With timed-prime-test incorporating this modified version of smallest-divisor,
; run the test for each of the 12 primes found in exercise 1.22. Since this modification halves the
; number of test steps, you should expect it to run about twice as fast.
; Is this expectation confirmed? If not, what is the observed ratio of the speeds of the two algorithms,
; and how do you explain the fact that it is different from 2?

(= (next_divisor $n)
    (if (== $n 2)
        3
        (+ $n 2)))

(= (fast_smallest-divisor $n)
    (fast_find-divisor $n 2))

(= (fast_find-divisor $n $test-divisor)
    (if (> (sqr $test-divisor) $n)
        $n
        (if (divides? $test-divisor $n)
            $test-divisor
            (fast_find-divisor $n (next_divisor $test-divisor)))))

(= (prime?_2 $n)
    (== $n (fast_smallest-divisor $n)))

(= (timed-prime-test_2 $n)
  (let* (
    (() (println! $n))
    (() (let $curtime (timems!) (start-prime-test_2 $n $curtime))))
    () ))

(= (start-prime-test_2 $n $start-time)
  (if (prime?_2 $n)
      (report-prime (- (timems!) $start-time))
      (println! "not simple")))

;!(timed-prime-test_2 1009)
;!(timed-prime-test_2 1013)
;!(timed-prime-test_2 1019)

; Time in this case: 1537, 1579, 1538. This is definitely quicker. And it is close to two times faster.

; -----------------------End of Exercise 1.23----------------------------

; Exercise 1.24.
;
; Modify the timed-prime-test procedure of exercise 1.22 to use fast-prime? (the Fermat method),
; and test each of the 12 primes you found in that exercise. Since the Fermat test has (log n)
; growth, how would you expect the time to test primes near 1,000,000 to compare with the time
; needed to test primes near 1000? Do your data bear this out? Can you explain any discrepancy you find?

(= (fast-timed-prime-test $n)
  (let* (
    (() (println! $n))
    (() (let $curtime (timems!) (fast-start-prime-test $n $curtime))))
    () ))

(= (fast-start-prime-test $n $start-time)
  (if (fast-prime? $n 4)
      (report-prime (- (timems!) $start-time))
      (println! "not simple")))

;!(fast-timed-prime-test 1009) ; 1846 ms
;!(fast-timed-prime-test 1013) ; 1974 ms
;!(fast-timed-prime-test 1019) ; 2297 ms

; This one takes more time than timed-prime-test_2 but less than first one. Of course it depends on number of tries
; for fast-prime but even with 3 as number of tries time is still higher than timed-prime-test_2

; -----------------------End of Exercise 1.24----------------------------

; Exercise 1.27. Demonstrate that the Carmichael numbers listed in footnote
; 47 (561, 1105, 1729, 2465, 2821, and 6601) really do fool the Fermat test.
; That is, write a procedure that takes an integer n and tests whether an is
; congruent to a modulo n for every a < n,and try your procedure on the given
; Carmichael numbers.

(= (check_Carmichael $n)
  (check_Carmichael-iter (dec $n) $n))

(= (check_Carmichael-iter $cur $base)
    (if (== $cur 0)
        True
        (if (== (expmod $cur $base $base) $cur)
            (check_Carmichael-iter (dec $cur) $base)
            False)))

; I've tried to put 561 here but it takes too long and I havent got an answer because I've stopped metta.
!(assertEqual
    (check_Carmichael 5)
    True)
; -----------------------End of Exercise 1.27---------------------------

; Exercise 1.28. One variant of the Fermat test that cannot be fooled is called the Miller-Rabin test (Miller 1976; Rabin 1980).
; This starts from an alternate form of Fermat’s Little Theorem, which states that if n is a prime number and a is any
; positive integer less than n, then a raised to the (n−1)-st power is congruent to 1 modulo n. To test the primality of
; a number n by the Miller-Rabin test, we pick a random number a<n and raise a to the (n−1)-st power modulo n using the
; expmod procedure. However, whenever we perform the squaring step in expmod, we check to see if we have discovered a
; “nontrivial square root of 1 modulo n,” that is, a number not equal to 1 or n−1 whose square is equal to 1 modulo n.
; It is possible to prove that if such a nontrivial square root of 1 exists, then n is not prime. It is also possible to
; prove that if n is an odd number that is not prime, then, for at least half the numbers a<n, computing an−1 in this way
; will reveal a nontrivial square root of 1 modulo n. (This is why the Miller-Rabin test cannot be fooled.) Modify the
; expmod procedure to signal if it discovers a nontrivial square root of 1, and use this to implement the Miller-Rabin
; test with a procedure analogous to fermat-test. Check your procedure by testing various known primes and non-primes.
; Hint: One convenient way to make expmod signal is to have it return 0.

(= (remainder-with-check $cur $m)
    (if (and (not (== $cur 1))
             (not (== $cur (dec $m)))
             (== (remainder $cur $m) 1))
        0
        (remainder $cur $m)))

(= (expmod2 $base $exp $m)
    (if (== $exp 0)
        1
        (if (even? $exp)
            (if (== (remainder-with-check $exp $m) 0)
                0
                (remainder-with-check (sqr (expmod2 $base (/ $exp 2) $m)) $m))
            (remainder (* $base (expmod2 $base (dec $exp) $m)) $m))))

(= (miller-rabin-test $n)
    (let $try-it (lambda1 $a
        (== (expmod2 $a (dec $n) $n) 1))
    ($try-it (inc (random (dec $n))))))

(= (miller-rabin-prime? $n $times)
    (if (== $times 0)
        True
        (let*
        (
            (() (miller-rabin-test $n))
            (() (miller-rabin-prime? $n (dec $times)))
        ))))

; This test could possibly fail too since we actually need to launch miller-rabin-test several times just like
; fast-prime. But for 561 performance is rather poor to launch this test in loop.
!(assertEqual
    (miller-rabin-test 561)
    False)
