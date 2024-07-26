(= (sqr $x) (* $x $x))

!(assertEqual
    (sqr 21)
    441)

!(assertEqual
    (sqr (+ 2 5))
    49)

!(assertEqual
    (sqr (sqr 3))
    81)

(= (sum-of-squares $x $y) (+ (sqr $x) (sqr $y)))

!(assertEqual
    (sum-of-squares 3 4)
    25)

(= (f $a) (sum-of-squares (+ $a 1) (* $a 2)))

!(assertEqual
    (f 5)
    136)

(= (abs $x)
    (if (> $x 0)
        $x
        (if (== $x 0)
            0
            (* $x -1))))

!(assertEqual
    (abs -5)
    5)

(= (_abs $x)
    (if (< $x 0)
        (* $x -1)
        $x))

!(assertEqual
    (_abs -5)
    5)

(= (>= $x $y) (or (> $x $y) (== $x $y)))

!(assertEqual
    (>= 6 5)
    True)

; Exercise 1.3
; Define procedure that takes three numbers as arguments and returns
; the sum of the squares of the two larger numbers

; I haven't got an idea of function's name
(= (exercise_1_3 $x1 $x2 $x3)
  (if (and (>= $x1 $x2) (>= $x3 $x2))
    (sum-of-squares $x1 $x3)
    (if (and (>= $x3 $x1) (>= $x2 $x1))
        (sum-of-squares $x2 $x3)
        (sum-of-squares $x1 $x2))))

; Check function using all permutations of 1 2 and 5
!(assertEqual
    (exercise_1_3 1 2 5)
    29)
!(assertEqual
    (exercise_1_3 1 5 2)
    29)
!(assertEqual
    (exercise_1_3 2 1 5)
    29)
!(assertEqual
    (exercise_1_3 2 5 1)
    29)
!(assertEqual
    (exercise_1_3 5 1 2)
    29)
!(assertEqual
    (exercise_1_3 5 2 1)
    29)
; -----------------------End of Exercise 1.3----------------------------

(= (a-plus-abs-b $a $b)
    ((if (> $b 0) + -) $a $b))

!(assertEqual
    (a-plus-abs-b 5 -5)
    10)


; Test to determine whether the interpreter he is faced with is using
; applicative-order evaluation or normal-order evaluation
(: test (-> Number Atom Atom))
(= (p) (p))
(= (test $x $y)
    (if (== $x 0)
    0
    $y))

; In the case of metta, evaluation type depends on the type definition of function "test".
; Default type which is %Undefined% implies applicative-order,
; while (: test (-> Number Atom Atom)) implies normal-order evaluation.
!(assertEqual
    (test 0 (p))
    0)

(= (average $x $y)
    (/ (+ $x $y) 2))

(= (improve $guess $x)
    (average $guess (/ $x $guess)))

(= (good-enough? $guess $x)
    (< (_abs (- (sqr $guess) $x)) 0.001))

(= (sqrt-iter $guess $x)
    (if (good-enough? $guess $x)
    $guess
    (sqrt-iter (improve $guess $x) $x)))

(= (sqrt $x)
    (sqrt-iter 1.0 $x))

!(assertEqual
    (sqrt 9)
    3.00009155413138)

!(assertEqual
    (sqrt (+ (sqrt 2) (sqrt 3)))
    1.7739279023207892)

; Exercise 1.7.
; The good-enough? test used in computing square roots will not be very
; effective for finding the square roots of very small numbers. Also, in real computers,
; arithmetic operations are almost always performed with limited precision. This makes our
; test inadequate for very large numbers. Explain these statements, with examples showing
; how the test fails for small and large numbers. An alternative strategy for implementing
; good-enough? is to watch how guess changes from one iteration to the next and to stop when
; the change is a very small fraction of the guess. Design a square-root procedure that uses
; this kind of end test. Does this work better for small and large numbers?

(= (better-good-enough? $old-guess $guess $x)
  (< (abs (- $old-guess $guess)) 0.000001))

(= (better-sqrt $x)
  (better-sqrt-iter 0.0 1.0 $x))

(= (better-sqrt-iter $oldguess $guess $x)
  (if (better-good-enough? $oldguess $guess $x)
      $guess
      (better-sqrt-iter $guess (improve $guess $x)
                 $x)))

!(assertEqual
    (better-sqrt 9)
    3.0)

!(assertEqual
    (better-sqrt (+ (better-sqrt 2) (better-sqrt 3)))
    1.773771228186423)

!(assertEqual
    (better-sqrt (sqr 1000))
    1000)

; -----------------------End of Exercise 1.7----------------------------

; Exercise 1.8.
; Newton's method for cube roots is based on the fact that
; if y is an approximation to the cube root of x, then a better approximation is given by the value
; (x/y^2 + 2y) / 3
; Use this formula to implement a cube-root procedure analogous to the square-root procedure.

(= (cube $x) (* $x (sqr $x)))

(= (cubert $x) (cubert-iter 1.0 $x))

(= (cubert-iter $guess $x)
  (if (good-enough-cubert? $guess $x)
      $guess
      (cubert-iter (improve-cubert $guess $x) $x)))

(= (improve-cubert $guess $x)
  (/ (+ (/ $x (sqr $guess)) (* 2 $guess)) 3))

(= (good-enough-cubert? $guess $x)
  (< (abs (- (improve-cubert $guess $x) $guess)) 0.000001))

!(assertEqual
    (cube (cubert 8))
    8.000000000144743)
; -----------------------End of Exercise 1.8----------------------------
