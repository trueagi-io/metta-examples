; This cond is not a part of a chapter 2.1 but I wanted to implement this for further usage.

(= (cond $com_list)
    (if (== $com_list ())
        (empty)
        (case (car-atom $com_list)
        (
            ((Else $res) $res)
            (($cond $res) (if $cond $res (cond (cdr-atom $com_list))))
        ) )))

(: Else (-> Atom Atom))
(: fib_cond (-> Number Number))
(= (fib_cond $n)
    (cond
    (
        ((== $n 0) 0)
        ((== $n 1) 1)
        (Else (+ (fib_cond (- $n 1)) (fib_cond (- $n 2))))
    )))

(= (fib $n)
    (if (== $n 0)
        0
        (if (== $n 1)
            1
            (+ (fib (- $n 1)) (fib (- $n 2))))))

; Currently metta has no cond so I've decided to write it myself. Thanks to Vitaly Bogdanov, i was able to.
; Though regular fib is much faster so cond won't be used further unfortunately.

!(assertEqual
    (fib_cond 5)
    (fib 5))

(= (make-pair $x $y) ($x . $y))

(= (first-pair $x) (let ($a . $b) $x $a))
(= (second-pair $x) (let ($a . $b) $x $b))

(= (make-rat $x $y) (make-pair $x $y))

(= (add-rat $x $y)
  (make-rat (+ (* (numer $x) (denom $y))
               (* (numer $y) (denom $x)))
            (* (denom $x) (denom $y))))

(= (sub-rat $x $y)
  (make-rat (- (* (numer $x) (denom $y))
               (* (numer $y) (denom $x)))
            (* (denom $x) (denom $y))))

(= (mul-rat $x $y)
  (make-rat (* (numer $x) (numer $y))
            (* (denom $x) (denom $y))))

(= (div-rat $x $y)
  (make-rat (* (numer $x) (denom $y))
            (* (denom $x) (numer $y))))

(= (equal-rat? $x $y)
  (= (* (numer $x) (denom $y))
     (* (numer $y) (denom $x))))

; get-rat func is introduced to use assertEqual instead of print-rat.
(= (get-rat $x)
    ((numer $x)/(denom $x)))
(= (print-rat $x)
    (println! (get-rat $x)))

(= (one-half) (make-rat 1 2))

(= (numer $x) (let ($a . $b) $x $a))

(= (denom $x)
    (let ($a . $b) $x $b))

; This line should print [(1 / 2)]
;!(print-rat (make-rat 1 2))
!(assertEqual
    (get-rat (make-rat 1 2))
    (1 / 2))


(= (one-third) (make-rat 1 3))

!(assertEqual
    (get-rat (add-rat (one-half) (one-third)))
    (5 / 6))

!(assertEqual
    (get-rat (mul-rat (one-half) (one-third)))
    (1 / 6))

!(assertEqual
    (get-rat (add-rat (one-third) (one-third)))
    (6 / 9))

(= (remainder $x $y) (% $x $y))

(= (gcd $a $b)
    (if (== $b 0)
        $a
        (gcd $b (remainder $a $b))))

(= (make-rat2 $n $d)
    (let $g (gcd $n $d)
        (make-pair (/ $n $g) (/ $d $g))))

(= (add-rat2 $x $y)
  (make-rat2 (+ (* (numer $x) (denom $y))
               (* (numer $y) (denom $x)))
            (* (denom $x) (denom $y))))

!(assertEqual
    (get-rat (add-rat2 (one-third) (one-third)))
    (2.0 / 3.0))

; Exercise 2.1.
;
; Define a better version of make-rat that handles both positive and negative arguments.
; make-rat should normalize the sign so that if the rational number is positive, both the numerator and
; denominator are positive, and if the rational number is negative, only the numerator is negative.

(= (Abs $x) (if (< $x 0) (* $x -1) $x))

(= (better_make-rat $n $d)
    (let $g (gcd $n $d)
        (if (or (< $n 0) (< $d 0))
            (make-pair (/ $n $g) (Abs (/ $d $g)))
            (make-pair (/ $n $g) (/ $d $g)))))

!(assertEqual
    (get-rat (better_make-rat 1 2))
    (1.0 / 2.0))

!(assertEqual
    (get-rat (better_make-rat -1 2))
    (-1.0 / 2.0))

!(assertEqual
    (get-rat (better_make-rat 1 -2))
    (-1.0 / 2.0))

!(assertEqual
    (get-rat (better_make-rat -1 -2))
    (1.0 / 2.0))


; -----------------------End of Exercise 2.1----------------------------

; Exercise 2.2.
;
; Consider the problem of representing line segments in a plane. Each segment is
; represented as a pair of points: a starting point and an ending point. Define a constructor
; make-segment and selectors start-segment and end-segment that define the representation of
; segments in terms of points. Furthermore, a point can be represented as a pair of numbers: the x
; coordinate and the y coordinate. Accordingly, specify a constructor make-point and selectors
; x-point and y-point that define this representation. Finally, using your selectors and constructors,
; define a procedure midpoint-segment that takes a line segment as argument and returns its midpoint
; (the point whose coordinates are the average of the coordinates of the endpoints). To try your procedures,
; you'll need a way to print points

(= (make-segment $start $end) (make-pair $start $end))

(= (start-segment $seg) (first-pair $seg))
(= (end-segment $seg) (second-pair $seg))

(= (make-point $x $y) (make-pair $x $y))

(= (x-point $pt) (first-pair $pt))
(= (y-point $pt) (second-pair $pt))

!(assertEqual
    (make-point 5 2)
    (5 . 2))

!(assertEqual
    (make-segment (make-point 1 2) (make-point 5 7))
    ((1 . 2) . (5 . 7)))

(= (midpoint-segment $seg)
    (let*
    (
        ($xs (x-point (start-segment $seg)))
        ($ys (y-point (start-segment $seg)))
        ($xe (x-point (end-segment $seg)))
        ($ye (y-point (end-segment $seg)))
    )
    (make-point (/ (+ $xs $xe) 2) (/ (+ $ys $ye) 2))))

!(assertEqual
    (midpoint-segment (make-segment (make-point 1 2) (make-point 5 7)))
    (3.0 . 4.5))

; Same as get-rat
(= (get-point $p)
    ((x-point $p),(y-point $p)))
(= (print-point $p)
    (println! (get-point $p)))

; This one will print (3.0 , 4.5)
;!(print-point (midpoint-segment (make-segment (make-point 1 2) (make-point 5 7))))

!(assertEqual
    (get-point (midpoint-segment (make-segment (make-point 1 2) (make-point 5 7))))
    (3.0 , 4.5))

; -----------------------End of Exercise 2.2----------------------------


; Exercise 2.3. Implement a representation for rectangles in a plane. (Hint: You may want to make use of
; exercise 2.2.) In terms of your constructors and selectors, create procedures that compute the perimeter
; and the area of a given rectangle. Now implement a different representation for rectangles. Can you
; design your system with suitable abstraction barriers, so that the same perimeter and area procedures will
; work using either representation?


; First representation of rect will be four points (top-left, top-right, bottom-left, bottom-right).

(= (make-rect $top-left $top-right $bottom-left $bottom-right)
  ($bottom-left $top-left $top-right $bottom-right))

(= (simple_rect) (make-rect (make-point 1 3) (make-point 2 3) (make-point 1 2) (make-point 2 2)))

!(assertEqual
    (simple_rect)
    ((1 . 2) (1 . 3) (2 . 3) (2 . 2)))

(= (get-top-left $rect)
    (let ($bl $tl $tr $br) $rect $tl))

(= (get-top-right $rect)
    (let ($bl $tl $tr $br) $rect $tr))

(= (get-bottom-left $rect)
  (let ($bl $tl $tr $br) $rect $bl))

(= (get-bottom-right $rect)
    (let ($bl $tl $tr $br) $rect $br))

!(assertEqual
    (get-bottom-left (simple_rect))
    (1 . 2))

!(assertEqual
    (get-top-left (simple_rect))
    (1 . 3))

!(assertEqual
    (get-top-right (simple_rect))
    (2 . 3))

!(assertEqual
    (get-bottom-right (simple_rect))
    (2 . 2))

(= (rect-width $rect)
  (- (y-point (get-top-left $rect)) (y-point (get-bottom-left $rect))))

(= (rect-height $rect)
  (- (x-point (get-top-right $rect)) (x-point (get-top-left $rect))))

(= (calc-P $rect $get-width $get-height)
  (* 2 (+ ($get-width $rect) ($get-height $rect))))

!(assertEqual
    (calc-P (simple_rect) rect-width rect-height)
    4)

(= (calc-S $rect $get-width $get-height)
  (* ($get-height $rect) ($get-width $rect)))

!(assertEqual
    (calc-S (simple_rect) rect-width rect-height)
    1)

; Second representation is the top-left corner, width and height.

(= (make-rect2 $top $left $width $height)
    ($top $left $width $height))

(= (simple_rect2) (make-rect2 1 2 4 6))

!(assertEqual
    (simple_rect2)
    (1 2 4 6))

(= (rect-height2 $rect)
    (let ($x $y $w $h) $rect
        $h))

(= (rect-width2 $rect)
    (let ($x $y $w $h) $rect
        $w))

!(assertEqual
    (calc-S (simple_rect2) rect-height2 rect-width2)
    24)

!(assertEqual
    (calc-P (simple_rect2) rect-height2 rect-width2)
    20)

; -----------------------End of Exercise 2.3----------------------------


(: lambda1 (-> Variable Atom (-> $a $t)))
(= ((lambda1 $var $body) $val)
    (let (quote ($v $b)) (sealed ($var) (quote ($var $body))) (let (quote $v) (quote $val) $b)) )

(= (cons $x $y)
  (let $dispatch (lambda1 $m
    (if (== $m 0)
        $x
        (if (== $m 1)
            $y
            (Error (cons $x $y) "Argument to cons should be only 0 or 1"))))
            $dispatch))

(= (car $z) ($z 0))

(= (cdr $z) ($z 1))

!(assertEqual
    (car (cons 2 5))
    2)

!(assertEqual
    (cdr (cons 2 5))
    5)

; Exercise 2.4.  Here is an alternative procedural representation of pairs. For this representation, verify that
;(car (cons x y)) yields x for any objects x and y.
;
;(define (cons x y)
;  (lambda (m) (m x y)))
;
;(define (car z)
;  (z (lambda (p q) p)))
;
; What is the corresponding definition of cdr? (Hint: To verify that this works, make use of the substitution model of
;section 1.

(: lambda2 (-> Variable Variable Atom (-> $a $b $t)))
(= ((lambda2 $var1 $var2 $body) $val1 $val2)
    (let (quote ($v1 $v2 $b)) (sealed ($var1 $var2) (quote ($var1 $var2 $body))) (let (quote ($v1 $v2)) (quote ($val1 $val2)) $b)) )

(= (cons2 $x $y)
  (lambda1 $m ($m $x $y)))

(= (car2 $z)
  ($z (lambda2 $p $q $p)))

(= (cdr2 $z)
  ($z (lambda2 $p $q $q)))

!(assertEqual
    (car2 (cons2 5 2))
    5)

!(assertEqual
    (cdr2 (cons2 5 2))
    2)
; -----------------------End of Exercise 2.4----------------------------


; Exercise 2.5.
;
; Show that we can represent pairs of nonnegative integers
; using only numbers and arithmetic operations if we represent
; the pair a and b as the integer that is the product 2^a 3^b.
; Give the corresponding definitions of the procedures cons, car, and cdr.


(= (even? $n)
    (== (% $n 2) 0))

(= (dec $x) (- $x 1))
(= (sqr $x) (* $x $x))

(= (fast-exp $b $n)
    (if (== $n 0)
        1
        (if (even? $n)
            (sqr (fast-exp $b (/ $n 2)))
            (* $b (fast-exp $b (dec $n))))))

(= (cons3 $a $b)
    (* (fast-exp 2 $a) (fast-exp 3 $b)))

!(assertEqual
    (cons3 1 2)
    18)

(: lambda3 (-> Variable Variable Variable Atom (-> $a $b $c $t)))
(= ((lambda3 $var1 $var2 $var3 $body) $val1 $val2 $val3)
    (let (quote ($v1 $v2 $v3 $b)) (sealed ($var1 $var2 $var3) (quote ($var1 $var2 $var3 $body))) (let (quote ($v1 $v2 $v3)) (quote ($val1 $val2 $val3)) $b)) )

(= (inc $x) (+ $x 1))

(= (count-factors $z $divisor)
    (let $iter (lambda3 $counter $x $self
        (if (== (% $x $divisor) 0)
            ($self (inc $counter) (/ $x $divisor) $self)
            $counter))
    ($iter 0 $z $iter)))

(= (car3 $z)
    (count-factors $z 2))

(= (cdr3 $z)
    (count-factors $z 3))

!(assertEqual
    (car3 (cons3 1 2))
    1)
!(assertEqual
    (cdr3 (cons3 1 2))
    2)

; -----------------------End of Exercise 2.5----------------------------



; Exercise 2.6.
;
; In case representing pairs as procedures wasn't mind-boggling enough, consider that,
; in a language that can manipulate procedures, we can get by without numbers (at least insofar
; as nonnegative integers are concerned) by implementing 0 and the operation of adding 1 as
;
;(define zero (lambda (f) (lambda (x) x)))
;
;(define (add-1 n)
;  (lambda (f) (lambda (x) (f ((n f) x)))))
;
; This representation is known as Church numerals, after its inventor, Alonzo Church,
; the logician who invented the lambda calculus.
;
; Define one and two directly (not in terms of zero and add-1).
; (Hint: Use substitution to evaluate (add-1 zero)). Give a direct definition of the
; addition procedure + (not in terms of repeated application of add-1).

(= (zero) (lambda1 $f (lambda1 $x $x)))

(= (add-1 $n)
    (lambda1 $f
        (lambda1 $x
            ($f (($n $f) $x)))))

;So, zero is actually just not applying anything to its input.
!(assertEqual
    (((zero) inc) 5)
    5)

;Zero plus one is application of input function once to the other input argument.
!(assertEqual
    (((add-1 (zero)) inc) 5)
    6)

; So, one and two will be application of input function to input argument once and twice accordingly.

(= (one)
    (lambda1 $f
        (lambda1 $x
            ($f $x))))

(= (two)
    (lambda1 $f
        (lambda1 $x
            ($f ($f $x)))))

!(assertEqual
    (((one) inc) 5)
    6)

!(assertEqual
    (((two) inc) 5)
    7)

(= (lsum $a $b)
    (lambda1 $f
        (lambda1 $x
            (($b $f) (($a $f) $x)))))

!(assertEqual
    (((lsum (two) (one)) inc) 5)
    8)
; -----------------------End of Exercise 2.6----------------------------

; Exercise 2.7.
;
; Alyssa's program is incomplete because she has not specified the implementation
; of the interval abstraction. Here is a definition of the interval constructor:

; (define (make-interval a b) (cons a b))

; Define selectors upper-bound and lower-bound to complete the implementation.

(= (add-interval $x $y)
  (make-interval (+ (lower-bound $x) (lower-bound $y))
                 (+ (upper-bound $x) (upper-bound $y))))

(= (mul-interval $x $y)
  (let*
  (
    ($p1 (* (lower-bound $x) (lower-bound $y)))
    ($p2 (* (lower-bound $x) (upper-bound $y)))
    ($p3 (* (upper-bound $x) (lower-bound $y)))
    ($p4 (* (upper-bound $x) (upper-bound $y)))
  )
    (make-interval (min ($p1 $p2 $p3 $p4))
                   (max ($p1 $p2 $p3 $p4)))))

(= (compareList $curbest $list $f)
    (if (== $list ())
        $curbest
        (let $cur (car-atom $list)
            (let $tail (cdr-atom $list)
                (if ($f $cur $curbest)
                    (compareList $cur $tail $f)
                    (compareList $curbest $tail $f))))))

(= (min $varlist)
    (compareList (car-atom $varlist) $varlist <))

(= (max $varlist)
    (compareList (car-atom $varlist) $varlist >))

!(assertEqual
    (max (5 2 4 6 1))
    6)

!(assertEqual
    (min (5 2 4 6 1))
    1)

(= (div-interval $x $y)
  (mul-interval $x
                (make-interval (/ 1.0 (upper-bound $y))
                               (/ 1.0 (lower-bound $y)))))

(= (make-interval $a $b) ($a . $b))

(= (upper-bound $interval) (let ($a . $b) $interval $b))
(= (lower-bound $interval) (let ($a . $b) $interval $a))

(= (r1) (make-interval 0.15 0.2))
(= (r2) (make-interval 0.9 1.1))

!(assertEqual
    (add-interval (r1) (r2))
    (1.05 . 1.3))

!(assertEqual
    (mul-interval (r1) (r2))
    (0.135 . 0.22000000000000003))

!(assertEqual
    (div-interval (r1) (r2))
    (0.13636363636363635 . 0.22222222222222224))
; -----------------------End of Exercise 2.7----------------------------

; Exercise 2.8.
;
; Using reasoning analogous to Alyssa's, describe how the difference of two
; intervals may be computed. Define a corresponding subtraction procedure, called sub-interval.

(= (sub-interval $x $y)
    (make-interval (- (lower-bound $x) (lower-bound $y))
                   (- (upper-bound $x) (upper-bound $y))))

!(assertEqual
    (sub-interval (r2) (r1))
    (0.75 . 0.9000000000000001))

; -----------------------End of Exercise 2.8----------------------------

; Exercise 2.9.
;
; The width of an interval is half of the difference between its upper and lower bounds.
; The width is a measure of the uncertainty of the number specified by the interval.
; For some arithmetic operations the width of the result of combining two intervals
; is a function only of the widths of the argument intervals, whereas for others the width
; of the combination is not a function of the widths of the argument intervals. Show that
; the width of the sum (or difference) of two intervals is a function only of the widths
; of the intervals being added (or subtracted). Give examples to show that this is not true
; for multiplication or division.

(= (interval-width $interval)
    (/ (- (upper-bound $interval) (lower-bound $interval)) 2))

!(assertEqual
    (interval-width (r2))
    0.10000000000000003)

(= (cmp-float $a $b)
    (let $diff (- $a $b)
        (if (< (Abs $diff) 1e-10) EQ
            (if (< $diff 0) LT GT))))

; Well, width of sum-intervals indeed equal to sum of widths, but due to rounding inside metta I can't directly compare
; results using assertEqual. Thanks to Vitaly's advice, we can use cmp-float to do that.

!(assertEqual
    (cmp-float (interval-width (add-interval (r1) (r2))) (+ (interval-width (r2)) (interval-width (r1))))
    EQ)

; Same here

!(assertEqual
    (cmp-float (interval-width (sub-interval (r2) (r1))) (- (interval-width (r2)) (interval-width (r1))))
    EQ)


; Different results for multiplication and division:
!(assertEqual
    (cmp-float (interval-width (mul-interval (r2) (r1))) (* (interval-width (r2)) (interval-width (r1))))
    GT)

!(assertEqual
    (cmp-float (interval-width (div-interval (r2) (r1))) (/ (interval-width (r2)) (interval-width (r1))))
    LT)

; -----------------------End of Exercise 2.9----------------------------

; Exercise 2.10.
;
; Ben Bitdiddle, an expert systems programmer, looks over Alyssa's shoulder and
; comments that it is not clear what it means to divide by an interval that spans zero.
; Modify Alyssa's code to check for this condition and to signal an error if it occurs.


(= (better-div-interval $x $y)
    (if (or (and (< (upper-bound $y) 0) (> (lower-bound $y) 0))
             (and (< (lower-bound $y) 0) (> (upper-bound $y) 0)))
        (Error (better-div-interval $x $y) "Divisor interval spans zero")
        (mul-interval $x
                (make-interval (/ 1.0 (upper-bound $y))
                               (/ 1.0 (lower-bound $y))))))

!(assertEqual
    (better-div-interval (r1) (r2))
    (0.13636363636363635 . 0.22222222222222224))

(= (r3) (make-interval -0.4 0.5))

!(assertEqual
    (better-div-interval (r1) (r3))
    (Error (better-div-interval (0.15 . 0.2) (-0.4 . 0.5)) "Divisor interval spans zero"))

; -----------------------End of Exercise 2.10---------------------------

; Exercise 2.11.
; In passing, Ben also cryptically comments: ``By testing the signs of the endpoints of the intervals,
; it is possible to break mul-interval into nine cases, only one of which requires more than two
; multiplications.'' Rewrite this procedure using Ben's suggestion.

(= (and4 $a $b $c $d) (and (and $a $b) (and $c $d)))

(= (better-mul-interval $int1 $int2)
  (let*
  (
    ($x1 (lower-bound $int1))
    ($x2 (lower-bound $int2))
    ($y1 (upper-bound $int1))
    ($y2 (upper-bound $int2))
  )
    (if (and4 (< $x1 0) (>= $y1 0) (< $x2 0) (>= $y2 0))
        (make-interval (min ((* $x1 $y2) (* $y1 $x2))) (* $y1 $y2))
    (if (and4 (< $x1 0) (< $y1 0) (< $x2 0) (>= $y2 0))
        (make-interval (* $y1 $y2) (* $y1 $x2))
    (if (and4 (>= $x1 0) (>= $y1 0) (< $x2 0) (>= $y2 0))
        (make-interval (* $y1 $x2) (* $y1 $y2))
    (if (and4 (< $x1 0) (>= $y1 0) (< $x2 0) (< $y2 0))
        (make-interval (* $y1 $y2) (* $x1 $y2))
    (if (and4 (< $x1 0) (< $y1 0) (< $x2 0) (< $y2 0))
        (make-interval (* $y1 $y2) (* $x1 $x2))
    (if (and4 (>= $x1 0) (>= $y1 0) (< $x2 0) (< $y2 0))
        (make-interval (* $y1 $y2) (* $x1 $x2))
    (if (and4 (< $x1 0) (>= $y1 0) (>= $x2 0) (>= $y2 0))
        (make-interval (* $x1 $y2) (* $y1 $y2))
    (if (and4 (< $x1 0) (< $y1 0) (>= $x2 0) (>= $y2 0))
        (make-interval (* $y1 $y2) (* $x1 $x2))
    (if (and4 (>= $x1 0) (>= $y1 0) (>= $x2 0) (>= $y2 0))
        (make-interval (* $x1 $x2) (* $y1 $y2))
        (Error (better-mul-interval $int1 $int2) "Unknown variant"))))))))))))

!(assertEqual
    (mul-interval (r3) (r2))
    (better-mul-interval (r3) (r2)))
; -----------------------End of Exercise 2.11---------------------------


; For interval presented in the following form: 3.5 +- 0.15:
(= (make-center-width $c $w)
    (make-interval (- $c $w) (+ $c $w)))

(= (center $i)
    (/ (+ (lower-bound $i) (upper-bound $i)) 2))

(define (width $i)
    (/ (- (upper-bound $i) (lower-bound $i)) 2))


; Exercise 2.12.
; Define a constructor make-center-percent that takes a center and a percentage
; tolerance and produces the desired interval. You must also define a selector
; percent that produces the percentage tolerance for a given interval. The center
; selector is the same as the one shown above.

(= (make-center-percent $mid $percent-deviance)
    (let $dev (* (/ $percent-deviance 100) $mid)
        (make-interval (- $mid $dev) (+ $mid $dev))))

!(assertEqual
    (make-center-percent 6 15)
    (5.1 . 6.9))

(= (percent $interval)
    (let $cntr (center $interval)
        (* (/ (- (upper-bound $interval) $cntr) $cntr) 100)))

!(assertEqual
    (percent (make-center-percent 6 15))
    15.000000000000005)
; -----------------------End of Exercise 2.12---------------------------

; Exercise 2.14.
;
; based on already defined methods for interval arithmetic we can try to calculate
; resistance of two parallel resistors in two ways.

(= (par1 $r1 $r2)
    (div-interval (mul-interval $r1 $r2)
    (add-interval $r1 $r2)))

(= (par2 $r1 $r2)
    (let $one (make-interval 1 1)
        (div-interval $one
            (add-interval (div-interval $one $r1)
            (div-interval $one $r2)))))

; Lem complains that Alyssa's program gives different answers for the two ways of computing. This is a serious complaint.
; Demonstrate that Lem is right. Investigate the behavior of the system on a variety of arithmetic expressions.
; Make some intervals A and B, and use them in computing the expressions A/A and A/B. You will get the most insight
; by using intervals whose width is a small percentage of the center value.
; Examine the results of the computation in center-percent form (see exercise 2.12).



(= (r_c1) (make-center-percent 10 1))
(= (r_c2) (make-center-percent 100 1))
(= (small-width-r1) (make-center-percent 10 0.01))
(= (small-width-r2) (make-center-percent 100 0.01))

; Indeed, results are different.
!(assertEqual
    (par1 (r_c1) (r_c2))
    (8.821782178217822 . 9.367309458218548))

!(assertEqual
    (par2 (r_c1) (r_c2))
    (9.0 . 9.181818181818182))

!(assertEqual
    (par1 (small-width-r1) (small-width-r2))
    (9.088182181781821 . 9.093636727309095))

!(assertEqual
    (par2 (small-width-r1) (small-width-r2))
    (9.090000000000002 . 9.091818181818182))

; Compute A/A

!(assertEqual
    (better-div-interval (r_c1) (r_c1))
    (0.9801980198019803 . 1.02020202020202))

!(assertEqual
    (better-div-interval (r_c2) (r_c2))
    (0.9801980198019802 . 1.0202020202020203))

!(assertEqual
    (better-div-interval (small-width-r1) (small-width-r1))
    (0.9998000199980004 . 1.000200020002))

!(assertEqual
    (better-div-interval (small-width-r2) (small-width-r2))
    (0.9998000199980001 . 1.0002000200020003))

; Compute A/B

!(assertEqual
    (better-div-interval (r_c1) (r_c2))
    (0.09801980198019802 . 0.10202020202020202))

!(assertEqual
    (better-div-interval (small-width-r1) (small-width-r2))
    (0.09998000199980002 . 0.10002000200020002))

; So, the smaller the width of interval, the preciser the results.

; -----------------------End of Exercise 2.14---------------------------