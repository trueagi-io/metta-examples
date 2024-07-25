; This script is the second part of chapter 1.3. Chapter was splitted due to different behavior of several functions
; using same lambda2 definition. Script chapter_1_3.metta contains functions which need typedef for lambda2.
; This script contains functions which works only without typdef from another script.

; quoted prevents wrapped atom from being interpreted
(: quoted (-> Atom Atom))

(: lambda1 (-> Variable Atom (-> $a $t)))
(= ((lambda1 $var $body) $val)
    (let (quote ($v $b)) (sealed ($var) (quote ($var $body))) (let (quote $v) (quote $val) $b)) )

; For lambda with two inputs
(= ((lambda2 $var1 $var2 $body) $val1 $val2)
    (let (quote ($v1 $v2 $b)) (sealed ($var1 $var2) (quote ($var1 $var2 $body))) (let (quote ($v1 $v2)) (quote ($val1 $val2)) $b)) )

; For lambda with three inputs. But actually we will use it to bypass recursive limitation while
; defining function using let
(: lambda3 (-> Variable Variable Variable Atom (-> $a $b $c $t)))
(= ((lambda3 $var1 $var2 $var3 $body) $val1 $val2 $val3)
    (let (quote ($v1 $v2 $v3 $b)) (sealed ($var1 $var2 $var3) (quote ($var1 $var2 $var3 $body))) (let (quote ($v1 $v2 $v3)) (quote ($val1 $val2 $val3)) $b)) )

(= (sqr $x) (* $x $x))

; Cube can't be defined as (* $x $x $x) as in Scheme
(= (cube $x) (* $x (sqr $x)))

; Convenient functions
(= (inc $x) (+ $x 1))
(= (dec $x) (- $x 1))

; Since metta currently doesn't support '+', '*' etc with 3+ parameters:
(= (p4 $a $b $c $d) (+ (+ $a $b) (+ $c $d)))

(= (remainder $x $y) (% $x $y))

(= (Abs $x) (if (< $x 0) (* $x -1) $x))

(= (close-enough? $x $y)
    (< (Abs (- $x $y)) 0.001))

(= (tolerance) 0.1)

; Here we had to switch places for $try and $close-enough local functions definitions (not like in SICP book)
; or it just won't work

(= (fixed-point $f $first-guess)
    (let $try (lambda2 $guess $self-try
        (let $next ($f $guess)
            (let $close-enough? (lambda2 $v1 $v2 (< (Abs (- $v1 $v2)) (tolerance)))
                (if ($close-enough? $guess $next)
                    $next
                    ($self-try $next $self-try)))))
    ($try $first-guess $try)))

!(assertEqual
    (fixed-point sqr 0.5)
    0.00390625)

(= (average $a $b) (/ (+ $a $b) 2))
; Sqrt approximation using fixed-point function
!(assertEqual
    (fixed-point (lambda1 $y (average $y (/ 2 $y))) 1)
    1.4166666666666665)

; Exercise 1.35.
;
; Show that the golden ratio Phi (section 1.2.2) is a fixed point of the
; transformation x ->  1 + 1/x, and use this fact to compute by means of the fixed-point procedure.

!(assertEqual
    (fixed-point (lambda1 $x (inc (/ 1 $x))) 1)
    1.6)

; -----------------------End of Exercise 1.35----------------------------

; Exercise 1.36.
;
; Modify fixed-point so that it prints the sequence of approximations
; it generates, using the newline and display primitives shown in exercise 1.22.
; Then find a solution to x^x = 1000 by finding a fixed point of x -> log(1000)/log(x).
; (Use Scheme's primitive log procedure, which computes natural logarithms.)
; Compare the number of steps this takes with and without average damping.
; (Note that you cannot start fixed-point with a guess of 1, as this would cause division by log(1) = 0.)

(= (fixed-point-print $f $first-guess)
    (let $try (lambda2 $guess $self-try
        (let $next ($f $guess)
            (let $close-enough? (lambda2 $v1 $v2 (< (Abs (- $v1 $v2)) (tolerance)))
                (if ($close-enough? $guess $next)
                        $next
                        (let*
                        (
                            (() (println! $next))
                            (() ($self-try $next $self-try))
                        )()
                        )))))
    ($try $first-guess $try)))

;!(fixed-point-print sqr 0.5)

; FIXME: currently not working, though println shows approximations.

;!(assertEqual
;    (fixed-point-print sqr 0.5)
;    0.00390625)

; -----------------------End of Exercise 1.36----------------------------

(= (average-damp $f)
    (lambda1 $x (average $x ($f $x))))

!(assertEqual
    ((average-damp sqr) 10)
    55)

(= (cube-root $x)
    (fixed-point (average-damp (lambda1 $y (/ $x (sqr $y)))) 1))

!(assertEqual
    (cube-root 5)
    1.6799045138888888)

(= (dx) 0.00001)

(= (deriv $g)
    (lambda1 $x (/ (- ($g (+ $x (dx))) ($g $x)) (dx))))

!(assertEqual
    ((deriv cube) 5)
    75.00014999664018)

(= (newton-transform $g)
  (lambda1 $x
    (- $x (/ ($g $x) ((deriv $g) $x)))))

(= (newtons-method $g $guess)
  (fixed-point (newton-transform $g) $guess))

(= (newton_sqrt $x)
  (newtons-method (lambda1 $y (- (sqr $y) $x))
                  1))

!(assertEqual
    (newton_sqrt 5)
    2.238095396823653)

(= (fixed-point-of-transform $g $transform $guess)
  (fixed-point ($transform $g) $guess))

(= (yet_another_sqrt $x)
  (fixed-point-of-transform (lambda1 $y (/ $x $y))
                            average-damp
                            1))


(= (and_another_sqrt $x)
  (fixed-point-of-transform (lambda1 $y (- (sqr $y) $x))
                            newton-transform
                            1))

!(assertEqual
    (yet_another_sqrt 5)
    2.238095238095238)

!(assertEqual
    (and_another_sqrt 5)
    2.238095396823653)

; Exercise 1.40.
;
; Define a procedure cubic that can be used together with the newtons-method
; procedure in expressions of the form
;
; (newtons-method (cubic a b c) 1)
;
; to approximate zeros of the cubic x^3 + ax^2 + bx + c.
;
; --------------------------------------------------------

(= (cubic $a $b $c)
  (lambda1 $x (p4 (cube $x) (* $a (sqr $x)) (* $b $x) $c)))

!(assertEqual
    (newtons-method (cubic 1 2 3) 1)
    -1.2762090909231458)

; -----------------------End of Exercise 1.40----------------------------

; Exercise 1.45.
;
; We saw in section 1.3.3 that attempting to compute square roots by naively finding a
; fixed point of y -> x/y does not converge, and that this can be fixed by average damping.
; The same method works for finding cube roots as fixed points of the average-damped y -> x/y^2.
; Unfortunately, the process does not work for fourth roots -- a single average damp is not
; enough to make a fixed-point search for y -> x/y3 converge. On the other hand, if we
; average damp twice (i.e., use the average damp of the average damp of y -> x/y3) the fixed-point
; search does converge. Do some experiments to determine how many average damps are required to
; compute nth roots as a fixed-point search based upon repeated average damping of y -> x/yn-1.
; Use this to implement a simple procedure for computing nth roots using fixed-point, average-damp,
; and the repeated procedure of exercise 1.43. Assume that any arithmetic operations you need
; are available as primitives.

(= (closest_pow2 $x)
  (let $iter (lambda3 $y $counter $self
    (if (< (/ $y 2) 1)
        $counter
        ($self (/ $y 2) (inc $counter) $self)))
  ($iter $x 0 $iter)))

!(assertEqual
    (closest_pow2 12)
    3)

(= (repeated_f $f $n)
    (if (== $n 1)
        $f
      (compose (repeated_f $f (dec $n)) $f)))

(= (compose $f $g)
  (lambda1 $x ($f ($g $x))))

(= (rpow $x $y)
    (if (== $y 1)
        $x
        (* $x (rpow $x (dec $y)))))

(= (n_root $n $x)
  (fixed-point-of-transform (lambda1 $y (/ $x (rpow $y (dec $n))))
                            (repeated_f average-damp (closest_pow2 $n))
                            1))

; FIXME: currently not working for some reason.
;!(assertEqual
;    (n_root 5 8)
;    1.5170557601762498)
; Though this one works:
;!(((repeated_f average-damp (closest_pow2 5)) (lambda1 $y (/ 8 (rpow $y (dec 5))))) 1.510537941965884)

; -----------------------End of Exercise 1.45----------------------------

; Exercise 1.46.
;
; Several of the numerical methods described in this chapter are instances of an
; extremely general computational strategy known as iterative improvement. Iterative
; improvement says that, to compute something, we start with an initial guess for the
; answer, test if the guess is good enough, and otherwise improve the guess and continue
; the process using the improved guess as the new guess. Write a procedure iterative-improve
; that takes two procedures as arguments: a method for telling whether a guess is good enough
; and a method for improving a guess. Iterative-improve should return as its value a procedure
; that takes a guess as argument and keeps improving the guess until it is good enough.
; Rewrite the sqrt procedure of section 1.1.7 and the fixed-point procedure of
; section 1.3.3 in terms of iterative-improve.

(= (iterative-improve $check $improve)
    (let $iter (lambda2 $x $self
        (let $next ($improve $x)
            (if ($check $x $next)
                $next
                ($self $next $self))))
    (lambda1 $guess ($iter $guess $iter))))

(= (ii_sqrt $x)
  ((iterative-improve close-enough? (lambda1 $y (average $y (/ $x $y)))) 1))

!(assertEqual
    (ii_sqrt 2)
    1.4142135623746899)

(= (new_fixed-point $f $first-guess)
    (let $close-enough?
        (lambda2 $v1 $v2
            (< (Abs (- $v1 $v2)) (tolerance)))
    ((iterative-improve $close-enough? $f) $first-guess)))

!(assertEqual
    (new_fixed-point sqr 0.3)
    0.0081)

; -----------------------End of Exercise 1.46----------------------------