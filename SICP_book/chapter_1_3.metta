; Note: The following lambdaX type definition is more correct:
; (: lambdaX (-> Variable Variable ... $t (-> $a $b ... $t)))
; This definition also makes some additional examples work (see below).
; But it doesn't prevent interpreter from evaluation of lambda's body
; before lambda call is actually made. This is why Atom type
; is used instead for the $body argument.

; Note: The only reason why different definitions of lambdaX are needed is
; that we would like to make lambda's interchangeable with other functions.
; Otherwise we could define universal lambda like this:
; (= ((lambda ; $vars $body) $vals) (let $vars $vals $body))
; and use it like this:
; (let $sum (lambda ($a $b $c) (+ (+ $a $b) $c)) ($sum (1 2 3))

; quoted prevents wrapped atom from being interpreted
(: quoted (-> Atom Atom))

; Note: quoted is used in lambda implementations below to prevent $body to be
; evaluated inside let.

; Needed for putting lambda functions as input to functions
(: lambda1 (-> Variable Atom (-> $a $t)))
(= ((lambda1 $var $body) $val)
    (let (quoted $var) (quoted $val) $body) )

; For lambda without any input
(: lambda0 (-> Atom (-> $t)))
(= ((lambda0 $body)) $body)

; For lambda with two inputs
(: lambda2 (-> Variable Variable Atom (-> $a $b $t)))
(= ((lambda2 $var1 $var2 $body) $val1 $val2)
    (let (quoted ($var1 $var2)) (quoted ($val1 $val2)) $body))

; For lambda with three inputs. But actually we will use it to bypass recursive limitation while
; defining function using let
(: lambda3 (-> Variable Variable Variable Atom (-> $a $b $c $t)))
(= ((lambda3 $var1 $var2 $var3 $body) $val1 $val2 $val3)
    (let (quoted ($var1 $var2 $var3)) (quoted ($val1 $val2 $val3)) $body))

; Sum from $a to $b with pre-defined transition from $a to $(a+1) $next and function $term applied to $a
(= (sum $term $a $next $b)
    (if (> $a $b)
        0
        (+ ($term $a) (sum $term ($next $a) $next $b))))

(= (sqr $x) (* $x $x))

; Cube can't be defined as (* $x $x $x) as in Scheme
(= (cube $x) (* $x (sqr $x)))

; Convenient functions
(= (inc $x) (+ $x 1))
(= (dec $x) (- $x 1))

; Sum all cubes values from $a to $b. Here $term is Cube and $next is just Inc
(= (sum-cubes $a $b) (sum cube $a inc $b))

!(assertEqual
  (sum-cubes 1 10)
  3025)

(= (identity $x) $x)
(= (sum-integers $a $b) (sum identity $a inc $b))

!(assertEqual
  (sum-integers 1 10)
  55)

(= (pi-sum $a $b) (sum (lambda1 $x (/ 1.0 (* $x (+ $x 2)))) $a (lambda1 $x (+ $x 4)) $b))

; To get more precise pi-value we need more iterations (in SICP book 1000 is used). But metta is currently slower than
; scheme so in sake of performance let ~3.10 be our pi-value

!(assertEqual
  (* 8 (pi-sum 1 50))
  3.1031453128860114)

(= (integral $f $a $b $dx)
    (* (sum $f (+ $a (/ $dx 2)) (lambda1 $x (+ $x $dx)) $b) $dx))

; Once again, in sake of performance, 0.1 is used (not 0.01 or 0.001 as in book)

!(assertEqual
    (integral cube 0 1 0.1)
    0.24874999999999994)


; Exercise 1.29.
;
; Simpson's Rule is a more accurate method of numerical integration than the method
; illustrated above. Using Simpson's Rule, the integral of a function f between a and b is approximated as
;
; S|a,b of f =  h/3[y0 + 4y1 + 2y2 + 4y3 + 2y4 + ... + 2yn-2 + 4yn-1 + yn]
;
; where h = (b - a)/n, for some even integer n, and yk = f(a + kh).
; (Increasing n increases the accuracy of the approximation.)
; Define a procedure that takes as arguments f, a, b, and n and returns the value of the integral,
; computed using Simpson's Rule. Use your procedure to integrate cube between 0 and 1
; (with n = 100 and n = 1000), and compare the results to those of the integral procedure shown ab

(= (inc2 $x) (+ $x 2))

; Since metta currently doesn't support '+', '*' etc with 3+ parameters:
(= (+4 $a $b $c $d) (+ (+ $a $b) (+ $c $d)))
(= (+3 $a $b $c) (+ (+ $a $b) $c))

(= (integral-simpson $f $a $b $n)
    (let $func-h (lambda0 (/ (- $b $a) $n))
        (let $element-y (lambda1 $x ($f (+ $a (* $x ($func-h)))))
            (/ (* ($func-h) (+4 ($element-y 0) ($element-y $n)
                                                (* 4 (sum $element-y 1 inc2 (dec $n)))
                                                (* 2 (sum $element-y 2 inc2 (dec $n))))) 3))))

!(assertEqual
    (integral-simpson cube 0 1 10)
    0.25)

; -----------------------End of Exercise 1.29----------------------------


; Exercise 1.30.
;
; The sum procedure above generates a linear recursion.
; The procedure can be rewritten so that the sum is performed iteratively.

; This variant unfortunately doesnt work since we're calling $iter inside its definition.
;(= (sum-iter $term $a $next $b) (let $iter (lambda2 $a $result
;                                        (if (> $a $b) $result ($iter ($next $a) (+ $result ($term $a)))))
;                                        ($iter $a 0)))

; and thus we will use lambda3 to bypass it

(= (isum $term $a $next $b)
    (let $iter (lambda3 $z $result $self
        (if (> $z $b)
            $result
            ($self ($next $z) (+ $result ($term $z)) $self)))
    ($iter $a 0 $iter)))

(= (isum-cubes $a $b) (isum cube $a inc $b))

!(assertEqual
  (sum-cubes 1 10)
  (isum-cubes 1 10))

; -----------------------End of Exercise 1.30----------------------------

; Exercise 1.31
;
; a.  The sum procedure is only the simplest of a vast number of similar abstractions
;     that can be captured as higher-order procedures. Write an analogous procedure
;     called product that returns the product of the values of a function at points over
;     a given range. Show how to define factorial in terms of product. Also use product
;     to compute approximations to value of pi using the formula (by John Wallis).
;
;     pi   2 * 4 * 4 * 6 * 6 * 8 ...
;     -- = -------------------------
;     4    3 * 3 * 5 * 5 * 7 * 7 ...
;
; b.  If your product procedure generates a recursive process, write one that generates
;     an iterative process. If it generates an iterative process, write one that generates
;     a recursive process.

; Recursive
(= (rproduct $term $a $next $b)
        (if (> $a $b)
            1
            (* ($term $a) (rproduct $term ($next $a) $next $b))))

; Iterative
(= (iproduct $term $a $next $b) (let $iter (lambda3 $z $result $self
                                        (if (> $z $b) $result ($self ($next $z) (* $result ($term $z)) $self)))
                                        ($iter $a 1 $iter)))


(= (rfactorial $x) (rproduct identity 1 inc $x))
(= (ifactorial $x) (iproduct identity 1 inc $x))

!(assertEqual
    (rfactorial 6)
    720)

!(assertEqual
  (rfactorial 6)
  (ifactorial 6))

(= (jw_pivalue $n)
    (let $next_divident-element (lambda1 $x (* (* 2 $x) (* 2 (inc $x))))
        (let $next_divisor-element (lambda1 $y (sqr (inc (* 2 $y))))
            (* 4 (/ (iproduct $next_divident-element 1 inc $n)
                        (iproduct $next_divisor-element 1 inc $n))))))

; In sake of performance we will use only 5 iters to calculate pi-value
!(assertEqual
    (jw_pivalue 5)
    3.2751010413348074)

; -----------------------End of Exercise 1.31----------------------------

; Exercise 1.32.
;
; a. Show that sum and product (exercise 1.31) are both special cases of a still
;    more general notion called accumulate that combines a collection of terms,
;    using some general accumulation function:
;
; (accumulate combiner null-value term a next b)
;
; Accumulate takes as arguments the same term and range specifications as sum and product,
; together with a combiner procedure (of two arguments) that specifies how the current
; term is to be combined with the accumulation of the preceding terms and a null-value
; that specifies what base value to use when the terms run out. Write accumulate and show
; how sum and product can both be defined as simple calls to accumulate.
;
; b. If your accumulate procedure generates a recursive process, write one that generates
;    an iterative process. If it generates an iterative process, write one that generates
;    a recursive process.
; ----------------------------------

(= (raccumulate $combiner $null-value $term $a $next $b)
    (if (> $a $b)
        $null-value
        ($combiner ($term $a) (raccumulate $combiner $null-value $term ($next $a) $next $b))))

(= (iaccumulate $combiner $null-value $term $a $next $b)
    (let $iter (lambda3 $z $result $self
                        (if (> $z $b)
                            $result
                            ($self ($next $z) ($combiner $result ($term $z)) $self)))
      ($iter $a $null-value $iter)))

; For test reasons of defined accumulate function:
(= (racc-sum $term $a $next $b) (raccumulate + 0 $term $a $next $b))
(= (iacc-sum $term $a $next $b) (iaccumulate + 0 $term $a $next $b))

(= (pi-raccsum $a $b) (let $pi-term (lambda1 $x (/ 1 (* $x (inc2 $x))))
                        (let $pi-next (lambda1 $y (+ $y 4))
                            (racc-sum $pi-term $a $pi-next $b))))

(= (pi-iaccsum $a $b) (let $pi-term (lambda1 $x (/ 1 (* $x (inc2 $x))))
                        (let $pi-next (lambda1 $y (+ $y 4))
                            (iacc-sum $pi-term $a $pi-next $b))))

!(assertEqual
    (* 8 (pi-raccsum 1 10))
    2.976046176046176)

!(assertEqual
    (* 8 (pi-raccsum 1 10))
    (* 8 (pi-iaccsum 1 10)))

; -----------------------End of Exercise 1.32----------------------------

; Exercise 1.33.
;
; You can obtain an even more general version of accumulate (exercise 1.32)
; by introducing the notion of a filter on the terms to be combined. That is,
; combine only those terms derived from values in the range that satisfy a
; specified condition. The resulting filtered-accumulate abstraction takes
; the same arguments as accumulate, together with an additional predicate of
; one argument that specifies the filter. Write filtered-accumulate as a procedure.
; Show how to express the following using filtered-accumulate:

; a. the sum of the squares of the prime numbers in the interval a to b
;    (assuming that you have a prime? predicate already written)

; b. the product of all the positive integers less than n that are relatively prime
;    to n (i.e., all positive integers i < n such that GCD(i,n) = 1).

(= (remainder $x $y) (% $x $y))

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

; Since $filter in filtered-accumulate could depend on two inputs, prime with two params is needed.
(= (prime? $n $b)
    (prime? $n))

(= (filtered-accumulate $filter $combiner $null-value $term $a $next $b)
    (if (> $a $b)
        $null-value
        (if ($filter $a $b)
            ($combiner ($term $a) (filtered-accumulate $filter $combiner $null-value $term ($next $a) $next $b))
            (filtered-accumulate $filter $combiner $null-value $term ($next $a) $next $b))))

(= (prime-square-sum $a $b)
  (filtered-accumulate prime? + 0 sqr $a inc $b))

!(assertEqual
    (prime-square-sum 2 12)
    208)

(= (gcd $a $b)
  (if (== $b 0)
      $a
      (gcd $b (remainder $a $b))))

(= (simple_to_n $i $n)
  (== (gcd $i $n) 1))

(= (prod-simple_i_to_n $a $n)
  (filtered-accumulate simple_to_n * 1 identity $a inc $n))

!(assertEqual
    (prod-simple_i_to_n 5 15)
    112112)
; -----------------------End of Exercise 1.33----------------------------

(= (average $a $b) (/ (+ $a $b) 2))

(= (negative? $x) (< $x 0))
(= (positive? $x) (> $x 0))

(= (search $f $neg-point $pos-point)
  (let $midpoint (average $neg-point $pos-point)
    (if (close-enough? $neg-point $pos-point)
        $midpoint
        (let $test-value ($f $midpoint)
          (if (positive? $test-value)
                 (search $f $neg-point $midpoint)
                 (if (negative? $test-value)
                    (search $f $midpoint $pos-point)
                    $midpoint))))))

(= (Abs $x) (if (< $x 0) (* $x -1) $x))

(= (close-enough? $x $y)
    (< (Abs (- $x $y)) 0.001))

(= (half-interval-method $f $a $b)
    (let $a-value ($f $a)
        (let $b-value ($f $b)
            (if (and (negative? $a-value) (positive? $b-value))
                (search $f $a $b)
                (if (and (negative? $b-value) (positive? $a-value))
                    (search $f $b $a)
                    (Arguments doesn't have different signs))))))

!(assertEqual
    (half-interval-method cube -2 4)
    -0.0001220703125)

!(assertEqual
    (half-interval-method (lambda1 $x (- (- (cube $x) (* 2 $x)) 3)) 1 2)
    1.89306640625)

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

; FIXME: Requires correct lambda type to work (see note to the lambda2 definition above). Works currently with no typedef.
;!(assertEqual
;    (fixed-point sqr 0.5)
;    0.00390625)
; Sqrt approximation using fixed-point function
;!(assertEqual
;    (fixed-point (lambda1 $y (average $y (/ 2 $y))) 1)
;    1.4166666666666665)


; Exercise 1.35.
;
; Show that the golden ratio Phi (section 1.2.2) is a fixed point of the
; transformation x ->  1 + 1/x, and use this fact to compute by means of the fixed-point procedure.

; FIXME: Requires correct lambda2 type to work (see note to the lambda2 definition above). Works currently with no typedef.
;!(assertEqual
;    (fixed-point (lambda1 $x (inc (/ 1 $x))) 1)
;    1.6)

; -----------------------End of Exercise 1.35----------------------------

; Exercise 1.36.
;
; Modify fixed-point so that it prints the sequence of approximations
; it generates, using the newline and display primitives shown in exercise 1.22.
; Then find a solution to x^x = 1000 by finding a fixed point of x -> log(1000)/log(x).
; (Use Scheme's primitive log procedure, which computes natural logarithms.)
; Compare the number of steps this takes with and without average damping.
; (Note that you cannot start fixed-point with a guess of 1, as this would cause division by log(1) = 0.)

; FIXME: Requires correct lambda2 type to work (see note to the lambda2 definition above). Works currently with no typedef.

; -----------------------End of Exercise 1.36----------------------------


; Exercise 1.37.
;
; a) An infinite continued fraction is an expression of the form
;
;         N1
; ---------------------
;             N2
; D1 +  ---------------
;               N3
;       D2 + ----------
;             D3 + ....
;
; As an example, one can show that the infinite continued fraction
; expansion with the Ni and the Di all equal to 1 produces 1/Phi, where Phi
; is the golden ratio (described in section 1.2.2).
; One way to approximate an infinite continued fraction is to truncate the
; expansion after a given number of terms. Such a truncation, so-called k-term
; finite continued fraction -- has the form
;
;         N1
; ---------------------
;             N2
; D1 +  ---------------
;               N3
;       D2 + ----------
;            .
;             .
;              .
;                 Nk
;                -----
;                  Dk
;
;
; Suppose that n and d are procedures of one argument (the term index i) that
; return the Ni and Di of the terms of the continued fraction. Define a procedure
; cont-frac such that evaluating (cont-frac n d k) computes the value of the k-term
; finite continued fraction. Check your procedure by approximating 1/Phi using
;
; (cont-frac (lambda1 (i) 1)
;            (lambda1 (i) 1)
;            k)
;
; for successive values of k. How large must you make k in order to get an approximation
; that is accurate to 4 decimal places?
;
; b) If your cont-frac procedure generates a recursive process, write one that generates an
; iterative process. If it generates an iterative process, write one that generates a recursive process.

; Recursive
(= (finite_continued_fraction $n $d $k)
    (let $rec
        (lambda2 $i $self
            (if (== $i $k)
                (/ ($n $i) ($d $i))
                (/ ($n $i) (+ ($d $i) ($self (inc $i) $self))) ))
    ($rec 0 $rec)))

!(assertEqual
    (finite_continued_fraction (lambda1 $x 1) (lambda1 $x 1) 10)
    0.6180555555555556)

; Iterative

(= (ifinite_continued_fraction $n $d $k)
    (let $iter (lambda3 $a $result $self-iter
        (if (== $a 0)
            (/ ($n $a) (+ ($d $a) $result))
            (if (== $a $k)
                ($self-iter (dec $a) (/ ($n $a) ($d $a)) $self-iter)
                ($self-iter (dec $a) (/ ($n $a) (+ ($d $a) $result)) $self-iter))))
    ($iter $k 0 $iter)))

!(assertEqual
    (ifinite_continued_fraction (lambda1 $x 1) (lambda1 $x 1) 10)
    0.6180555555555556)
; -----------------------End of Exercise 1.37----------------------------

; Exercise 1.38.
;
; In 1737, the Swiss mathematician Leonhard Euler published a memoir
; De Fractionibus Continuis, which included a continued fraction expansion
; for e - 2, where e is the base of the natural logarithms. In this fraction,
; the Ni are all 1, and the Di are successively 1, 2, 1, 1, 4, 1, 1, 6, 1, 1, 8, ....
; Write a program that uses your cont-frac procedure from exercise 1.37 to
; approximate e, based on Euler's expansion.

(= (incomplete_partial $a $b) (/ (- $a (remainder $a $b)) $b))

(= (euler_e $k)
    (let $n (lambda1 $a 1)
        (let $d (lambda1 $a2
                        (if (== (remainder $a2 3) 1)
                                            (* 2 (inc (incomplete_partial $a2 3)))
                                            1))
        (+ 2 (finite_continued_fraction $n $d $k)))))

!(assertEqual
    (euler_e 10)
    2.7182818352059925)

; -----------------------End of Exercise 1.38----------------------------

; Exercise 1.39.
; A continued fraction representation of the tangent function was published
; in 1770 by the German mathematician J.H. Lambert:
;
;                 x
; tan x =  ---------------------
;                       x^2
;           1 -  ---------------
;                         x^3
;                 3 - ----------
;                       5 - ....
;
; where x is in radians.
;
; Define a procedure (tan-cf x k) that computes an approximation to the tangent
; function based on Lambert's formula. K specifies the number of terms to compute,
; as in exercise 1.37.

; Iterative
(= (pow $x $y)
    (let $iter (lambda2 $a $self
                        (if (== $a 0)
                                1
                                (* $x ($self (dec $a) $self))))
    ($iter $y $iter)))

; Recursive
(= (rpow $x $y)
    (if (== $y 1)
        $x
        (* $x (rpow $x (dec $y)))))

(= (tan-cf $x $k)
  (let $n (lambda1 $a
             (if
                 (== $a 0)
                 $x
                 (* -1 (rpow $x (inc $a)))))
  (finite_continued_fraction $n (lambda1 $a2 (inc (* 2 $a2))) $k)))

!(assertEqual
    (tan-cf 1 10)
    1.557407724654902)

; -----------------------End of Exercise 1.39----------------------------

(= (average-damp $f)
    (lambda1 $x (average $x ($f $x))))

!(assertEqual
    ((average-damp sqr) 10)
    55)

(= (cube-root $x)
    (fixed-point (average-damp (lambda1 $y (/ $x (sqr $y)))) 1))

; FIXME: Requires correct lambda2 type to work (see note to the lambda2 definition above). Works currently with no typedef.
;!(assertEqual
;    (cube-root 5)
;    1.6799045138888888)

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

; FIXME: Requires correct lambda2 type to work (see note to the lambda2 definition above). Works currently with no typedef.
;!(assertEqual
;    (newton_sqrt 5)
;    2.238095396823653)

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

; FIXME: Requires correct lambda2 type to work (see note to the lambda2 definition above). Works currently with no typedef.
;!(assertEqual
;    (yet_another_sqrt 5)
;    2.238095238095238)

;!(assertEqual
;    (and_another_sqrt 5)
;    2.238095396823653)

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
  (lambda1 $x (+4 (cube $x) (* $a (sqr $x)) (* $b $x) $c)))

; FIXME: Requires correct lambda2 type to work (see note to the lambda2 definition above). Works currently with no typedef.
;!(assertEqual
;    (newtons-method (cubic 1 2 3) 1)
;    -1.2762090909231458)

; -----------------------End of Exercise 1.40----------------------------

; Exercise 1.41.
;
; Define a procedure double that takes a procedure of one argument
; as argument and returns a procedure that applies the original procedure
; twice. For example, if inc is a procedure that adds 1 to its argument,
; then (double inc) should be a procedure that adds 2. What value is returned by
;
; (((double (double double)) inc) 5)

(= (double_apply $f)
  (lambda1 $x ($f ($f $x))))

!(assertEqual
    ((double_apply inc) 1)
    3)

!(assertEqual
    (((double_apply (double_apply double_apply)) inc) 5)
    21)

; -----------------------End of Exercise 1.41----------------------------

; Exercise 1.42.
;
; Let f and g be two one-argument functions. The composition f after g is defined
; to be the function x -> f(g(x)). Define a procedure compose that implements composition.
; For example, if inc is a procedure that adds 1 to its argument,
;
; ((compose square inc) 6) to give 49 as result
;
; -------------------------------------------------

(= (compose $f $g)
  (lambda1 $x ($f ($g $x))))

!(assertEqual
    ((compose sqr inc) 6)
    49)
; -----------------------End of Exercise 1.42----------------------------


; Exercise 1.43.
;
; If f is a numerical function and n is a positive integer, then we can form
; the nth repeated application of f, which is defined to be the function whose
; value at x is f(f(...(f(x))...)). For example, if f is the function x ->  x + 1,
; then the nth repeated application of f is the function x ->  x + n. If f is the
; operation of squaring a number, then the nth repeated application of f is the function
; that raises its argument to the 2nth power. Write a procedure that takes as inputs a
; procedure that computes f and a positive integer n and returns the procedure that
; computes the nth repeated application of f. Your procedure should be able to be used as follows:
;
; ((repeated square 2) 5) and to produce 625 as result

(= (repeated_f $f $n)
    (if (== $n 1)
        $f
      (compose (repeated_f $f (dec $n)) $f)))

!(assertEqual
    ((repeated_f sqr 2) 5)
    625)

; -----------------------End of Exercise 1.43----------------------------


; Exercise 1.44.
;
; The idea of smoothing a function is an important concept in signal processing.
; If f is a function and dx is some small number, then the smoothed version of f
; is the function whose value at a point x is the average of f(x - dx), f(x), and f(x + dx).
;
; Write a procedure smooth that takes as input a procedure that computes f and returns a procedure that
; computes the smoothed f. It is sometimes valuable to repeatedly smooth a function (that is, smooth the
; smoothed function, and so on) to obtained the n-fold smoothed function.
; Show how to generate the n-fold smoothed function of any given function using smooth and repeated from exercise 1.43.

(= (smooth $f)
  (lambda1 $y
    (/ (+3 ($f $y) ($f (- $y (dx))) ($f (+ $y (dx)))) 3)))

!(assertEqual
    ((smooth sqr) 5)
    25.000000000066663)

!(assertEqual
    ((smooth (smooth sqr)) 5)
    (((repeated_f smooth 2) sqr) 5))

; -----------------------End of Exercise 1.44----------------------------

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

(= (n_root $n $x)
  (fixed-point-of-transform (lambda1 $y (/ $x (rpow $y (dec $n))))
                            (repeated_f average-damp (closest_pow2 $n))
                            1))

; FIXME: Requires correct lambda2 type to work (see note to the lambda2 definition above). Works currently with no typedef.
;!(assertEqual
;    (n_root 5 8)
;    1.5170557601762498)

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

; FIXME: Requires correct lambda2 type to work (see note to the lambda2 definition above). Works currently with no typedef.
;!(assertEqual
;    (ii_sqrt 2)
;    1.4142135623746899)

(= (new_fixed-point $f $first-guess)
    (let $close-enough?
        (lambda2 $v1 $v2
            (< (Abs (- $v1 $v2)) (tolerance)))
    ((iterative-improve $close-enough? $f) $first-guess)))

; FIXME: Requires correct lambda2 type to work (see note to the lambda2 definition above). Works currently with no typedef.
;!(assertEqual
;    (new_fixed-point sqr 0.3)
;    0.0081)

; -----------------------End of Exercise 1.46----------------------------