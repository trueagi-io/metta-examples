; This chapter is dedicated to generic procedures which works with different object representation, type tags and data-
; directed programming.

; Complex numbers.

; Two different representations for complex numbers - (real, imag) parts and (magnitude, angle).

; One way to implement complex numers' selectors:
; (all sqrt/square/cos/atan etc functions are builtin in Scheme. I'll use imports from python)

(= (square $x)
    (* $x $x))

!(import! &self additional_funcs)

(= (sqrt $x)
    (sqrt! $x))

(= (atan $x $y)
    (atan! $x $y))

(= (cos $x)
    (cos! $x))

(= (sin $x)
    (sin! $x))


(= (real-part (Cons $r $i)) $r)

(= (imag-part (Cons $r $i)) $i)

(= (magnitude $z)
    (sqrt (+ (square (real-part $z)) (square (imag-part $z)))))

(= (angle $z)
    (atan (imag-part $z) (real-part $z)))

(= (make-from-real-imag $r $i) (Cons $r $i))

(= (make-from-mag-ang $r $a)
    (Cons (* $r (cos $a)) (* $r (sin $a))))

; Another way to implement selectors:

(= (real-part_ $z)
    (* (magnitude_ $z) (cos (angle_ $z))))

(= (imag-part_ $z)
    (* (magnitude_ $z) (sin (angle_ $z))))

(= (magnitude_ (Cons $m $a)) $m)

(= (angle_ (Cons $m $a)) $a)

(= (make-from-real-imag_ $x $y)
    (Cons (sqrt (+ (square $x) (square $y))) (atan $y $x)))

(= (make-from-mag-ang_ $r $a) (Cons $r $a))

; We can possibly use any of those complex number's representations. Though if we need to use both then we need to
; make a type tag to distinguish which representation we are using right now.

(= (make-pair $x $y)
    (pair $x $y))

(= (first-pair (pair $x $y)) $x)
(= (second-pair (pair $x $y)) $y)

(= (pair? $x)
    (case $x
        (((pair $a $b) True)
         ($_ False))))

(= (attach-tag $type-tag $contents)
    (make-pair $type-tag $contents))

(= (type-tag $datum)
    (if (pair? $datum)
        (first-pair $datum)
        (Error (type-tag $datum) "Input is not a pair")))

(= (contents $datum)
    (if (pair? $datum)
        (second-pair $datum)
        (Error (contents $datum) "Input is not a pair")))

(= (rectangular? $z)
    (== (type-tag $z) rectangular))

(= (polar? $z)
    (== (type-tag $z) polar))

; So now we need to re-write functions for both types of complex number representations. For functions to be in one
; program their names will also be changed to represent their representation.

; Rectangular representation of complex number with type tag:

(= (real-part-rectangular (Cons $r $i)) $r)

(= (imag-part-rectangular (Cons $r $i)) $i)

(= (magnitude-rectangular $z)
    (sqrt (+ (square (real-part-rectangular $z))
             (square (imag-part-rectangular $z)))))

(= (angle-rectangular $z)
    (atan (imag-part-rectangular $z)
          (real-part-rectangular $z)))

(= (make-from-real-imag-rectangular $x $y)
    (attach-tag rectangular (Cons $x $y)))

(= (make-from-mag-ang-rectangular $r $i)
    (attach-tag rectangular
        (cons (* $r (cos $i)) (* $r (sin $i)))))

; Polar representation of complex number with type tag:

(= (real-part-polar $z)
    (* (magnitude-polar $z) (cos (angle-polar $z))))

(= (imag-part-polar $z)
    (* (magnitude-polar $z) (sin (angle-polar $z))))

(= (magnitude-polar (Cons $m $a)) $m)

(= (angle-polar (Cons $m $a)) $a)

(= (make-from-real-imag-polar $x $y)
    (attach-tag polar
        (Cons
            (sqrt (+ (square $x) (square $y)))
            (atan $y $x))))

(= (make-from-mag-ang-polar $r $a)
    (attach-tag polar (Cons $r $a)))


(= (real-part_general $z)
    (case $z
        (((pair rectangular $contents) (real-part-rectangular $contents))
         ((pair polar $contents) (real-part-polar $contents))
         ($_ (Error (real-part $z) "Unknown representation type")))))

(= (imag-part_general $z)
    (case $z
        (((pair rectangular $contents) (imag-part-rectangular $contents))
         ((pair polar $contents) (imag-part-polar $contents))
         ($_ (Error (real-part $z) "Unknown representation type")))))

(= (magnitude_general $z)
    (case $z
        (((pair rectangular $contents) (magnitude-rectangular $contents))
         ((pair polar $contents) (magnitude-polar $contents))
         ($_ (Error (real-part $z) "Unknown representation type")))))

(= (angle_general $z)
    (case $z
        (((pair rectangular $contents) (angle-rectangular $contents))
         ((pair polar $contents) (angle-polar $contents))
         ($_ (Error (real-part $z) "Unknown representation type")))))

; Now to use add-complex, sub-complex, mul-complex and div-complex we need to implement more general make-from-* functions:

(= (make-from-real-imag_general $r $i)
    (make-from-real-imag-rectangular $r $i))

(= (make-from-mag-ang_general $m $a)
    (make-from-mag-ang-polar $m $a))

(= (add-complex $z1 $z2)
    (make-from-real-imag_general
        (+ (real-part_general $z1) (real-part_general $z2))
        (+ (imag-part_general $z1) (imag-part_general $z2))))

(= (sub-complex $z1 $z2)
    (make-from-real-imag_general
        (- (real-part_general $z1) (real-part_general $z2))
        (- (imag-part_general $z1) (imag-part_general $z2))))

(= (mul-complex $z1 $z2)
    (make-from-mag-ang_general
        (* (magnitude_general $z1) (magnitude_general $z2))
        (+ (angle_general $z1) (angle_general $z2))))

(= (div-complex $z1 $z2)
    (make-from-mag-ang_general
        (/ (magnitude_general $z1) (magnitude_general $z2))
        (- (angle_general $z1) (angle_general $z2))))

; So now we have three independent parts of whole complex-number's arithmetics program: arithmetics (sub, mul, add, div),
; polar representation of complex-number and rectangular representation. Several asserts for current code.

;!(assertEqual
;    (make-from-real-imag_general 5 2)
;    (pair rectangular (Cons 5 2)))

;!(assertEqual
;    (make-from-mag-ang_general 3 4)
;    (pair polar (Cons 3 4)))

;!(bind! &z1 (make-from-real-imag_general 5 2))
;!(bind! &z2 (make-from-mag-ang_general 3 4))

;!(assertEqual
;    (real-part_general &z1)
;    5)

;!(assertEqual
;    (real-part_general &z2)
;    -1.960930862590836)

;!(assertEqual
;    (imag-part_general &z1)
;    2)

;!(assertEqual
;    (imag-part_general &z2)
;    -2.2704074859237844)

;!(assertEqual
;    (magnitude_general &z1)
;    5.385164807134504)

;!(assertEqual
;    (magnitude_general &z2)
;    3)

;!(assertEqual
;    (angle_general &z1)
;    0.3805063771123649)

;!(assertEqual
;    (angle_general &z2)
;    4)

;!(assertEqual
;    (div-complex &z1 &z2)
;    (pair polar (Cons 1.7950549357115013 -3.619493622887635)))

;!(assertEqual
;    (sub-complex &z1 &z2)
;    (pair rectangular (Cons 6.9609308625908355 4.270407485923784)))

;!(assertEqual
;    (add-complex &z1 &z2)
;    (pair rectangular (Cons 3.039069137409164 -0.2704074859237844)))

;!(assertEqual
;    (mul-complex &z1 &z2)
;    (pair polar (Cons 16.15549442140351 4.380506377112365)))

; Data driven programming.

; Problem of the previous complex number representation is that general functions real-part, angle, magnitude and
; imag-part should know which representations we have. And in case of a new representation we need to add couple of
; lines to that functions.

; Another problem - we need to check that functions in different representations have different name. In case of Scheme
; we will get an error. In case of Metta, we will get several outputs.

; We need a table of types and operations like this:

;    ______________________________________________________________
;    |                                     Types                  |
;    | Functions              Polar             Rectangular       |
;    |____________________________________________________________|
;    | real-part         real-part-polar     real-part-rectangular|
;    |                                                            |
;    | imag-part         imag-part-polar     imag-part-rectangular|
;    |                                                            |
;    | magnitude         magnitude-polar     magnitude-rectangular|
;    |                                                            |
;    | angle             angle-polar         angle-polar          |
;    |____________________________________________________________|

; In case of data driven programming we need a function which is using this sort of table to call necessary functions.

(: lambda1 (-> Variable Atom (-> $a $t)))
(= ((lambda1 $var $body) $val)
    (let (quoted $var) (quoted $val) $body))

(= ((lambda2 $var1 $var2 $body) $val1 $val2)
    (let (quoted ($var1 $var2)) (quoted ($val1 $val2)) $body))

(= (car-list (Cons $x $xs))
    $x)

(= (car-list Nil)
    Nil)

(= (cdr-list (Cons $x $xs))
    $xs)

(= (cdr-list Nil)
    Nil)

; in the following code functions put and get are used. Those functions works with table and get/puts functions from/to
; it. Implementations of those functions is a part of further chapters so they won't be implemented here. So I'm not sure
; if this is something we need to leave here. Opinions?

(= (install-rectangular-package)
  ;; inner functions
  (let*
  (
    ($real-part (lambda1 $z (car-list $z)))
    ($imag-part (lambda1 $z (cdr-list $z)))
    ($make-from-real-imag (lambda2 $x $y (Cons $x $y)))
    ($magnitude (lambda1 $z (sqrt (+ (square ($real-part $z))
                                     (square ($imag-part $z))))))
    ($angle (lambda1 $z (atan ($imag-part $z) ($real-part $z))))
    ($make-from-mag-ang (lambda2 $r $a (Cons (* $r (cos $a)) (* $r (sin $a)))))
    ($tag (lambda1 $x (attach-tag rectangular $x)))
  )
      (let*
      (
        (() (put real-part (Cons rectangular Nil) $real-part))
        (() (put imag-part (Cons rectangular Nil) $imag-part))
        (() (put magnitude (Cons rectangular Nil) $magnitude))
        (() (put angle (Cons rectangular Nil) $angle))
        (() (put make-from-real-imag rectangular (lambda2 $x $y ($tag ($make-from-real-imag $x $y)))))
        (() (put make-from-mag-ang rectangular (lambda2 $r $a ($tag ($make-from-mag-ang $r $a)))))
      )
      ())))

(= (install-polar-package)
  ;; inner functions
  (let*
  (
    ($magnitude (lambda1 $z (car-list $z)))
    ($angle (lambda1 $z (cdr-list $z)))
    ($make-from-mag-ang (lambda2 $x $y (Cons $x $y)))
    ($real-part (lambda1 $z (* ($magnitude $z) (cos ($angle $z)))))
    ($imag-part (lambda1 $z (* ($magnitude $z) (sin ($angle $z)))))
    ($make-from-real-imag (lambda2 $x $y (Cons (sqrt (+ (square $x) (square $y))) (atan $y $x))))
    ($tag (lambda1 $x (attach-tag polar $x)))
  )
      (let*
      (
        (() (put real-part (Cons polar Nil) $real-part))
        (() (put imag-part (Cons polar Nil) $imag-part))
        (() (put magnitude (Cons polar Nil) $magnitude))
        (() (put angle (Cons polar Nil) $angle))
        (() (put make-from-real-imag polar (lambda2 $x $y ($tag ($make-from-real-imag $x $y)))))
        (() (put make-from-mag-ang polar (lambda2 $r $a ($tag ($make-from-mag-ang $r $a)))))
      )
      ())))

; This way we don't need to think about intersection of functions' names.

; Map function used here is the built-in Scheme function. Since this code due to not implemented put and get is sort of
; demonstration I won't implement it right now. Apply-generic is actually uses random number of arguments. In this case
; it should probably use some sort of car/cdr of $args but once again since this is a demonstrative code and I cant
; even launch it to check, I'll leave it like this.
(= (apply-generic $op $args)
    (let*
    (
        ($type-tags (map $type-tag $args))
        ($proc (get $op $type-tags))
    )
    (if $proc
        (apply $proc (map $contents $args))
        (Error (apply-generic $op $args) "No method for these types"))))

(= (real-part $z) (apply-generic real-part $z))
(= (imag-part $z) (apply-generic imag-part $z))
(= (magnitude $z) (apply-generic magnitude $z))
(= (angle $z) (apply-generic angle $z))

(= (make-from-real-imag $x $y)
    ((get make-from-real-imag rectangular) $x $y))

(= (make-from-mag-ang $r $a)
    ((get make-from-mag-ang polar) $r $a))


; Exercise 2.73.
;
; Section 2.3.2 described a program that performs
; symbolic differentiation:

;(= (deriv $exp $var)
;      (if (number? $exp)
;            0
;            (if (variable? $exp)
;                (if (same-variable? $exp $var) 1 0)
;                (if (sum? $exp)
;                     (make-sum (deriv (addend $exp) $var)
;                               (deriv (augend $exp) $var))
;                     (if (product? $exp)
;                         (make-sum
;                              (make-product (multiplier $exp)
;                                            (deriv (multiplicand $exp) $var))
;                              (make-product (deriv (multiplier $exp) $var)
;                                            (multiplicand $exp)))
;                         (Error (deriv $exp $var) "Unknown expression type"))))))

; We can regard this program as performing a dispatch on the type of the
; expression to be differentiated. In this situation the ``type tag'' of the
; datum is the algebraic operator symbol (such as +) and the operation being
; performed is deriv. We can transform this program into data-directed style by
; rewriting the basic derivative procedure as

(= (deriv $exp $var)
   (if (number? $exp)
        0)
         ((variable? exp) (if (same-variable? exp var) 1 0))
         (else ((get 'deriv (operator exp)) (operands exp)
                                            var))))
(define (operator exp) (car exp))
(define (operands exp) (cdr exp))

; a.  Explain what was done above. Why can't we assimilate the predicates
; number? and same-variable? into the data-directed dispatch?

; b.  Write the procedures for derivatives of sums and products, and the
; auxiliary code required to install them in the table used by the program
; above.

; c.  Choose any additional differentiation rule that you like, such as the one
; for exponents (exercise 2.56), and install it in this data-directed system.

; d.  In this simple algebraic manipulator the type of an expression is the
; algebraic operator that binds it together. Suppose, however, we indexed the
; procedures in the opposite way, so that the dispatch line in deriv looked
; like

((get (operator exp) 'deriv) (operands exp) var)

; What corresponding changes to the derivative system are required?




















