# In this chapter lists of symbols will be used. I will use (Cons 1 (Cons 2 Nil)) notation to prevent code duplication
# as it was in previous chapter.

(= (null? $expr)
    (== $expr ()))

(= (null-list? $list)
    (== $list Nil))

(= (cons $x $y)
    (cons-atom $x $y))

(= (car $x)
    (car-atom $x))

(= (cdr $x)
    (cdr-atom $x))

(= (cddr $x)
    (cdr (cdr $x)))

(= (cadr $x)
    (car (cdr $x)))

(= (caddr $x)
    (car (cdr (cdr $x))))

(= (list $expr)
   (if (== (get-metatype $expr) Expression)
       (if (null? $expr)
           Nil
           (Cons (list (car $expr)) (list (cdr $expr))))
       $expr)
)

(= (makelist $x)
    (if (null? $x)
        Nil
        (Cons (car $x) (makelist (cdr $x)))))


(= (car-list (Cons $x $xs))
    $x)

(= (car-list (Nil))
    Nil)

(= (cdr-list (Cons $x $xs))
    $xs)

(= (cdr-list (Nil))
    Nil)

(= (cadr-list $x)
    (car-list (cdr-list $x)))

(= (cddr-list $x)
    (cdr-list (cdr-list $x)))

(= (caddr-list $x)
    (car-list (cddr-list $x)))

(= (cdar-list $x)
    (cdr-list (car-list $x)))


;!(assertEqual
;    (list (a (b c)))
;    (Cons a (Cons (Cons b (Cons c Nil)) Nil)))

;!(assertEqual
;    (cdr-list (list (a (b c))))
;    (Cons (Cons b (Cons c Nil)) Nil))

;!(assertEqual
;    (car-list (list (a (b c))))
;    a)

; function memq checks if symbol $item is in list $x and returns sublist of $x starting with $item first appearance.
; False in other case.
(= (memq $item $x)
    (if (null-list? $x)
        False
        (if (== $item (car-list $x))
            $x
            (memq $item (cdr-list $x)))))

;!(assertEqual
;    (memq apple (list (pear banana prune)))
;    False)

;!(assertEqual
;    (memq apple (list (x (apple sauce) y apple pear)))
;    (list (apple pear)))

; Exercise 2.54.
;
; Two lists are said to be equal? if they contain equal elements
; arranged in the same order. For example,

; (equal? '(this is a list) '(this is a list))

; is true, but

; (equal? '(this is a list) '(this (is a) list))

; is false. To be more precise, we can define equal? recursively in
; terms of the basic eq? equality of symbols by saying that a and b are
; equal? if they are both symbols and the symbols are eq?, or if they
; are both lists such that (car a) is equal? to (car b) and (cdr a) is
; equal? to (cdr b). Using this idea, implement equal? as a procedure.

(= (and$ $list)
    (if (null? $list)
        True
        (and (car $list) (and$ (cdr $list)))))

(= (equal? $x $y)
    (if (and (== (get-metatype $x) Symbol)
            (== (get-metatype $y) Symbol))
            (if (== $x $y)
                True
                False)
            (if (or (== (get-metatype $x) Symbol)
                (== (get-metatype $y) Symbol))
                False
                (and (equal? (car-list $x) (car-list $y))
                     (equal? (cdr-list $x) (cdr-list $y))))))



;!(assertEqual
;    (equal? (list (a (b c))) (list (a (b c))))
;    True)
; But actually we can just use Metta's '==' function to get same results
;!(assertEqual
;    (== (list (a (b c))) (list (a (b c))))
;    True)

(= (list1) (list (this (is a) list)))
(= (list2) (list (this is a list)))

;!(assertEqual
;    (equal? (list (this is a list)) (list (this (is a) list)))
;    False)

;!(assertEqual
;    (== (list (this is a list)) (list (this (is a) list)))
;    False)
; -----------------------End of Exercise 2.54---------------------------

; Symbolic differentiation


; Everywhere "'" symbol is added to the "*" and "+" signs to prevent correspondent functions to be evaluated.
(= (deriv $exp $var)
      (if (number? $exp)
            0
            (if (variable? $exp)
                (if (same-variable? $exp $var) 1 0)
                (if (sum? $exp)
                     (make-sum (deriv (addend $exp) $var)
                               (deriv (augend $exp) $var))
                     (if (product? $exp)
                         (make-sum
                              (make-product (multiplier $exp)
                                            (deriv (multiplicand $exp) $var))
                              (make-product (deriv (multiplier $exp) $var)
                                            (multiplicand $exp)))
                         (Error (deriv $exp $var) "Unknown expression type"))))))

(= (number? $x) (and (== (get-type $x) Number) (not (== (get-metatype $x) Expression))))

(= (variable? $x) (== (get-metatype $x) Symbol))

(= (same-variable? $v1 $v2)
    (and$ ((variable? $v1) (variable? $v2) (== $v1 $v2))))

;(= (make-sum $a1 $a2) ('+ $a1 $a2))

;(= (make-product $m1 $m2) ('* $m1 $m2))

(= (sum? $x)
    (and (== (get-metatype $x) Expression) (== (car $x) '+)))

(= (addend ('+ $x $y)) $x)

(= (augend ('+ $x $y)) $y)

(= (product? $x)
    (and (== (get-metatype $x) Expression) (== (car $x) '*)))

(= (multiplier ('* $x $y)) $x)

(= (multiplicand ('* $x $y)) $y)

;!(assertEqual
;    (deriv ('+ x 3) x)
;    ('+ 1 0))

;!(assertEqual
;    ((deriv ('* x y) x))
;    (('+ ('* x 0) ('* 1 y))))

;!(assertEqual
;    (deriv ('* ('* x y) ('+ x 3)) x)
;    ('+ ('* ('* x y) ('+ 1 0))
;        ('* ('+ ('* x 0) ('* 1 y))
;        ('+ x 3))))

; Now we want to replace some of constructors to more simplified results where numbers will be evaluated (+ and *).
; Since we are replacing make-sum and make-product previous ones I'll comment and asserts won't work with new implementations.

(= (make-sum $a1 $a2)
  (if (=number? $a1 0)
        $a2
        (if (=number? $a2 0)
            $a1
            (if (and (number? $a1) (number? $a2))
                (+ $a1 $a2)
                ('+ $a1 $a2)))))

(= (=number? $exp $num)
    (and (number? $exp) (== $exp $num)))

(= (make-product $m1 $m2)
  (if (or (=number? $m1 0) (=number? $m2 0))
        0
        (if (=number? $m1 1)
            $m2
            (if (=number? $m2 1)
                $m1
                (if (and (number? $m1) (number? $m2))
                    (* $m1 $m2)
                    ('* $m1 $m2))))))

;!(assertEqual
;    (deriv ('+ x 3) x)
;    1)

;!(assertEqual
;    ((deriv ('* x y) x))
;    (y))

;!(assertEqual
;    (deriv ('* ('* x y) ('+ x 3)) x)
;    ('+ ('* x y) ('* y ('+ x 3))))

; Exercise 2.56.
;
; Show how to extend the basic differentiator to handle more kinds of
; expressions. For instance, implement the differentiation rule
;
; d(u^n)/dx = n*u^(n-1)*du/dx

; by adding a new clause to the deriv program and defining appropriate
; procedures exponentiation?, base, exponent, and make-exponentiation. (You may
; use the symbol ** to denote exponentiation.) Build in the rules that anything
; raised to the power 0 is 1 and anything raised to the power 1 is the thing
; itself.

; I'll name extended deriv "deriv2" so it will be possible to call previous asserts.

(= (deriv2 $exp $var)
      (if (number? $exp)
            0
            (if (variable? $exp)
                (if (same-variable? $exp $var) 1 0)
                (if (sum? $exp)
                     (make-sum (deriv2 (addend $exp) $var)
                               (deriv2 (augend $exp) $var))
                     (if (product? $exp)
                         (make-sum
                              (make-product (multiplier $exp)
                                            (deriv2 (multiplicand $exp) $var))
                              (make-product (deriv2 (multiplier $exp) $var)
                                            (multiplicand $exp)))
                         (if (exponentiation? $exp)
                            (make-exponentiation (base $exp) (deriv2 (base $exp) $var) (exponent $exp))
                            (Error (deriv2 $exp $var) "Unknown expression type")))))))

(= (base (** $x $y))
    $x)

(= (exponent (** $x $y))
    $y)

(= (exponentiation? $exp)
    (== (car $exp) **))

(= (make-exponentiation $base $dbase $exponent)
    (let $newe (- $exponent 1)
        (if (== $newe 0)
            $dbase
            (if (== $newe 1)
                (make-product $exponent (make-product $base $dbase))
                (make-product (make-product $exponent (** $base (- $exponent 1))) $dbase)))))

;!(assertEqual
;    (deriv2 (** ('* x 3) 5) x)
;    ('* ('* 5 (** ('* x 3) 4)) 3))

; -----------------------End of Exercise 2.56---------------------------


; Exercise 2.57.
;
; Extend the differentiation program to handle sums and
; products of arbitrary numbers of (two or more) terms. Then the last example
; above could be expressed as

; (deriv '(* x y (+ x 3)) 'x)

; Try to do this by changing only the representation for sums and products,
; without changing the deriv procedure at all. For example, the addend of a sum
; would be the first term, and the augend would be the sum of the rest of the
; terms.

(= (length $items)
    (if (null? $items)
        0
        (+ 1 (length (cdr $items)))))

; Well actually it is not third implementation but just to make naming consistent with deriv3.
(= (addend3 $x) (cadr $x))

(: augend3 (-> %Undefined% %Undefined%))
(= (augend3 $x)
    (if (> (length $x) 3)
        (cons '+ (cddr $x))
        (caddr $x)))

(= (multiplier3 $x) (cadr $x))

(= (multiplicand3 $x)
    (if (> (length $x) 3)
        (cons '* (cddr $x))
        (cddr $x)))

; Once again I'm copying deriv implementation and renaming it so every (almost) previous asserts will work correctly.
(= (deriv3 $exp $var)
      (if (number? $exp)
            0
            (if (variable? $exp)
                (if (same-variable? $exp $var) 1 0)
                (if (sum? $exp)
                     (make-sum (deriv3 (addend3 $exp) $var)
                               (deriv3 (augend3 $exp) $var))
                     (if (product? $exp)
                         (make-sum
                              (make-product (multiplier3 $exp)
                                            (deriv3 (multiplicand3 $exp) $var))
                              (make-product (deriv3 (multiplier3 $exp) $var)
                                            (multiplicand3 $exp)))
                         (if (exponentiation? $exp)
                            (make-exponentiation (base $exp) (deriv3 (base $exp) $var) (exponent $exp))
                            (Error (deriv3 $exp $var) "Unknown expression type")))))))

(= (exp) ('+ x 1))
(augend3 ('+ x 1))
!(let $exp ('+ x ('+ x 1)) (deriv3 $exp x))
(augend3 (exp))
(get-type x)































