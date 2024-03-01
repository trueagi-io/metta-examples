# In this chapter lists of symbols will be used. I will use (Cons 1 (Cons 2 Nil)) notation to prevent code duplication
# as it was in previous chapter.

(= (null? $expr)
    (== $expr ()))

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

(= (cadddr $x)
    (car (cdr (cdr (cdr $x)))))

(= (list $expr)
   (if (null? $expr)
        Nil
        (Cons (car-atom $expr) (list (cdr-atom $expr)))))

(= (tree $expr)
   (if (null? $expr)
        Nil
        (let* (($head (car-atom $expr)) ($tail (cdr-atom $expr)))
            (if (== (get-metatype $head) Expression)
                (Cons (tree $head) (tree $tail))
                (Cons $head (tree $tail))))))

(= (null-list? $list)
    (== $list Nil))

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
;    (tree (a (b c)))
;    (Cons a (Cons (Cons b (Cons c Nil)) Nil)))

;!(assertEqual
;    (cdr-list (tree (a (b c))))
;    (Cons (Cons b (Cons c Nil)) Nil))

;!(assertEqual
;    (car-list (tree (a (b c))))
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
;    (memq apple (tree (x (apple sauce) y apple pear)))
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
;    (equal? (tree (a (b c))) (tree (a (b c))))
;    True)
; But actually we can just use Metta's '==' function to get same results quicker
;!(assertEqual
;    (== (tree (a (b c))) (tree (a (b c))))
;    True)

;!(assertEqual
;    (equal? (list (this is a list)) (tree (this (is a) list)))
;    False)

;!(assertEqual
;    (== (list (this is a list)) (tree (this (is a) list)))
;    False)
; -----------------------End of Exercise 2.54---------------------------

; Symbolic differentiation. For symbolic differentiation I'll use regular cons-atom, cdr-atom, car-atom since we are
; dealing with expressions here.

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

; Now we want to replace some of constructors so results will be simplified. Numbers will be evaluated (+ and *).
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
; Unfortunately I need to add two lets so augend3 and multiplicand3 works correctly inside deriv3.
(= (deriv3 $exp $var)
      (if (number? $exp)
            0
            (if (variable? $exp)
                (if (same-variable? $exp $var) 1 0)
                (if (sum? $exp)
                     (make-sum (deriv (addend3 $exp) $var)
                               (deriv (augend3 $exp) $var))
                     (if (product? $exp)
                         (make-sum
                              (make-product (multiplier3 $exp)
                                            (deriv (multiplicand3 $exp) $var))
                              (make-product (deriv (multiplier3 $exp) $var)
                                            (multiplicand3 $exp)))
                         (if (exponentiation? $exp)
                            (make-exponentiation (base $exp) (deriv3 (base $exp) $var) (exponent $exp))
                            (Error (deriv3 $exp $var) "Unknown expression type")))))))

(= (exp) ('+ x y ('+ x 1)))

;On regular Metta this could output an error due to caching and equality of 1 and True. But it works on minimal metta.
;!(assertEqual
;    (deriv3 (exp) x)
;    2)

; -----------------------End of Exercise 2.57---------------------------

; Exercise 2.58.
;
; Suppose we want to modify the differentiation program so that
; it works with ordinary mathematical notation, in which + and * are infix
; rather than prefix operators. Since the differentiation program is defined in
; terms of abstract data, we can modify it to work with different
; representations of expressions solely by changing the predicates, selectors,
; and constructors that define the representation of the algebraic expressions
; on which the differentiator is to operate.

; a. Show how to do this in order to differentiate algebraic expressions
; presented in infix form, such as (x + (3 * (x + (y + 2)))). To simplify the
; task, assume that + and * always take two arguments and that expressions are
; fully parenthesized.

; b. The problem becomes substantially harder if we allow standard algebraic
; notation, such as (x + 3 * (x + y + 2)), which drops unnecessary parentheses
; and assumes that multiplication is done before addition. Can you design
; appropriate predicates, selectors, and constructors for this notation such
; that our derivative program still works?

; a.

(= (sum4? $x)
    (and (== (get-metatype $x) Expression) (== (cadr $x) '+)))

(= (addend4 ($x '+ $y)) $x)

(= (augend4 ($x '+ $y)) $y)

(= (product4? $x)
    (and (== (get-metatype $x) Expression) (== (cadr $x) '*)))

(= (multiplier4 ($x '* $y)) $x)

(= (multiplicand4 ($x '* $y)) $y)

(= (make-sum4 $a1 $a2)
  (if (=number? $a1 0)
        $a2
        (if (=number? $a2 0)
            $a1
            (if (and (number? $a1) (number? $a2))
                (+ $a1 $a2)
                ($a1 '+ $a2)))))

(= (make-product4 $m1 $m2)
  (if (or (=number? $m1 0) (=number? $m2 0))
        0
        (if (=number? $m1 1)
            $m2
            (if (=number? $m2 1)
                $m1
                (if (and (number? $m1) (number? $m2))
                    (* $m1 $m2)
                    ($m1 '* $m2))))))

(= (deriv4 $exp $var)
      (if (number? $exp)
            0
            (if (variable? $exp)
                (if (same-variable? $exp $var) 1 0)
                (if (sum4? $exp)
                     (make-sum4 (deriv4 (addend4 $exp) $var)
                               (deriv4 (augend4 $exp) $var))
                     (if (product4? $exp)
                         (make-sum
                              (make-product4 (multiplier4 $exp)
                                            (deriv4 (multiplicand4 $exp) $var))
                              (make-product4 (deriv4 (multiplier4 $exp) $var)
                                            (multiplicand4 $exp)))
                         (if (exponentiation? $exp)
                            (make-exponentiation (base $exp) (deriv4 (base $exp) $var) (exponent $exp))
                            (Error (deriv4 $exp $var) "Unknown expression type")))))))

; In our case I've left '+ instead of + since for this (exp2) cdr-atom not working since its result should be
; (+ (3 '* (x + (y + 2)))) and metta tries to evaluate it as i understand. With '+, '* everything works fine.
(= (exp2) (x '+ (3 '* (x '+ (y '+ 2)))))

;!(assertEqual
;    (deriv4 (exp2) x)
;    4)

; b

(= (addend5 $x) (car $x))

(= (multiplier5 $x) (car $x))

(= (augend5 $x)
    (if (> (length $x) 3)
        (cddr $x)
        (caddr $x)))

(= (multiplicand5 $x)
    (if (> (length $x) 3)
        (cddr $x)
        (caddr $x)))

(= (deriv5 $exp $var)
      (if (number? $exp)
            0
            (if (variable? $exp)
                (if (same-variable? $exp $var) 1 0)
                (if (sum4? $exp)
                     (make-sum4 (deriv5 (addend5 $exp) $var)
                               (deriv5 (augend5 $exp) $var))
                     (if (product4? $exp)
                         (make-sum
                              (make-product4 (multiplier5 $exp)
                                            (deriv5 (multiplicand5 $exp) $var))
                              (make-product4 (deriv5 (multiplier5 $exp) $var)
                                            (multiplicand5 $exp)))
                         (if (exponentiation? $exp)
                            (make-exponentiation (base $exp) (deriv5 (base $exp) $var) (exponent $exp))
                            (Error (deriv5 $exp $var) "Unknown expression type")))))))

(= (exp3) (x '+ 3 '* (x '+ y '+ 2)))

;!(assertEqual
;    (deriv5 (exp3) x)
;    4)
; -----------------------End of Exercise 2.58---------------------------


; Representation of sets.
; Lists as representation of sets.

(= (element-of-set? $x $set)
  (if (null-list? $set)
    False
    (if (== $x (car-list $set))
        True
        (element-of-set? $x (cdr-list $set)))))

(= (set1) (list (1 2 3)))
(= (set2) (list (4 5 3)))

;!(assertEqual
;   (element-of-set? 3 (set1))
;   True)

;!(assertEqual
;    (element-of-set? 4 (set1))
;    False)

(= (adjoin-set $x $set)
    (if (element-of-set? $x $set)
        $set
        (Cons $x $set)))

;!(assertEqual
;    (adjoin-set 4 (set1))
;    (list (4 1 2 3)))

;!(assertEqual
;    (adjoin-set 3 (set1))
;    (list (1 2 3)))

(= (intersection-set $set1 $set2)
  (if (or (null-list? $set1) (null-list? $set2))
    Nil
    (if (element-of-set? (car-list $set1) $set2)
        (Cons (car-list $set1) (intersection-set (cdr-list $set1) $set2))
        (intersection-set (cdr-list  $set1) $set2))))

;!(assertEqual
;    (intersection-set (set1) (set2))
;    (list (3)))


; Exercise 2.59.
;
; Implement the union-set operation for the
; unordered-list representation of sets.

(= (union-set $set1 $set2)
    (if (null-list? $set1)
        $set2
        (if (null-list? $set2)
            $set1
            (if (element-of-set? (car-list $set1) $set2)
                (union-set (cdr-list $set1) $set2)
                (Cons (car-list $set1) (union-set (cdr-list $set1) $set2))))))

;!(assertEqual
;    (union-set (set2) (set1))
;    (list (4 5 1 2 3)))
; -----------------------End of Exercise 2.59---------------------------

; Exercise 2.60.
;
; We specified that a set would be represented as a list
; with no duplicates. Now suppose we allow duplicates. For instance, the
; set {1,2,3} could be represented as the list (2 3 2 1 3 2 2). Design
; procedures element-of-set?, adjoin-set, union-set, and
; intersection-set that operate on this representation.

; element-of-set? is just the same.

(= (adjoin-set_2 $x $set)
    (Cons $x $set))















