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

(= (cadddr-list $x)
    (car-list (cdr-list (cddr-list $x))))

(= (cdar-list $x)
    (cdr-list (car-list $x)))

; function memq checks if symbol $item is in list $x and returns sublist of $x starting with $item first appearance.
; False in other case.
(= (memq $item $x)
    (if (null-list? $x)
        False
        (if (== $item (car-list $x))
            $x
            (memq $item (cdr-list $x)))))

!(assertEqual
    (memq apple (list (pear banana prune)))
    False)

!(assertEqual
    (memq apple (tree (x (apple sauce) y apple pear)))
    (list (apple pear)))

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

!(assertEqual
    (equal? (tree (a (b c))) (tree (a (b c))))
    True)
; But actually we can just use Metta's '==' function to get same results quicker
!(assertEqual
    (== (tree (a (b c))) (tree (a (b c))))
    True)

!(assertEqual
    (equal? (list (this is a list)) (tree (this (is a) list)))
    False)

!(assertEqual
    (== (list (this is a list)) (tree (this (is a) list)))
    False)
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


(= (make-sum $a1 $a2) ('+ $a1 $a2))

(= (make-product $m1 $m2) ('* $m1 $m2))

(= (sum? $x)
    (and (== (get-metatype $x) Expression) (== (car $x) '+)))

(= (addend ('+ $x $y)) $x)

(= (augend ('+ $x $y)) $y)

(= (product? $x)
    (and (== (get-metatype $x) Expression) (== (car $x) '*)))

(= (multiplier ('* $x $y)) $x)

(= (multiplicand ('* $x $y)) $y)

!(assertEqual
    (deriv ('+ x 3) x)
    ('+ 1 0))

!(assertEqual
    ((deriv ('* x y) x))
    (('+ ('* x 0) ('* 1 y))))

!(assertEqual
    (deriv ('* ('* x y) ('+ x 3)) x)
    ('+ ('* ('* x y) ('+ 1 0))
        ('* ('+ ('* x 0) ('* 1 y))
        ('+ x 3))))

; Now we want to replace some of constructors so results will be simplified. Numbers will be evaluated (+ and *).
(= (deriv_simplified $exp $var)
      (if (number? $exp)
            0
            (if (variable? $exp)
                (if (same-variable? $exp $var) 1 0)
                (if (sum? $exp)
                     (make-sum_simplified (deriv_simplified (addend $exp) $var)
                               (deriv_simplified (augend $exp) $var))
                     (if (product? $exp)
                         (make-sum_simplified
                              (make-product_simplified (multiplier $exp)
                                                        (deriv_simplified (multiplicand $exp) $var))
                              (make-product_simplified (deriv_simplified (multiplier $exp) $var)
                                                        (multiplicand $exp)))
                         (Error (deriv_simplified $exp $var) "Unknown expression type"))))))

(= (make-sum_simplified $a1 $a2)
  (if (=number? $a1 0)
        $a2
        (if (=number? $a2 0)
            $a1
            (if (and (number? $a1) (number? $a2))
                (+ $a1 $a2)
                ('+ $a1 $a2)))))

(= (=number? $exp $num)
    (and (number? $exp) (== $exp $num)))

(= (make-product_simplified $m1 $m2)
  (if (or (=number? $m1 0) (=number? $m2 0))
        0
        (if (=number? $m1 1)
            $m2
            (if (=number? $m2 1)
                $m1
                (if (and (number? $m1) (number? $m2))
                    (* $m1 $m2)
                    ('* $m1 $m2))))))

!(assertEqual
    (deriv_simplified ('+ x 3) x)
    1)

!(assertEqual
    ((deriv_simplified ('* x y) x))
    (y))

!(assertEqual
    (deriv_simplified ('* ('* x y) ('+ x 3)) x)
    ('+ ('* x y) ('* y ('+ x 3))))

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
                     (make-sum_simplified (deriv2 (addend $exp) $var)
                               (deriv2 (augend $exp) $var))
                     (if (product? $exp)
                         (make-sum_simplified
                              (make-product_simplified (multiplier $exp)
                                            (deriv2 (multiplicand $exp) $var))
                              (make-product_simplified (deriv2 (multiplier $exp) $var)
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
                (make-product_simplified $exponent (make-product_simplified $base $dbase))
                (make-product_simplified (make-product_simplified $exponent (** $base (- $exponent 1))) $dbase)))))

!(assertEqual
    (deriv2 (** ('* x 3) 5) x)
    ('* ('* 5 (** ('* x 3) 4)) 3))

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
(= (deriv3 $exp $var)
      (if (number? $exp)
            0
            (if (variable? $exp)
                (if (same-variable? $exp $var) 1 0)
                (if (sum? $exp)
                     (make-sum_simplified (deriv3 (addend3 $exp) $var)
                               (deriv3 (augend3 $exp) $var))
                     (if (product? $exp)
                         (make-sum_simplified
                              (make-product_simplified (multiplier3 $exp)
                                            (deriv3 (multiplicand3 $exp) $var))
                              (make-product_simplified (deriv3 (multiplier3 $exp) $var)
                                            (multiplicand3 $exp)))
                         (if (exponentiation? $exp)
                            (make-exponentiation (base $exp) (deriv3 (base $exp) $var) (exponent $exp))
                            (Error (deriv3 $exp $var) "Unknown expression type")))))))

(= (exp) ('+ x y ('+ x 1)))

;On regular Metta this will output an error due to caching and equality of 1 and True. But it works on minimal metta.
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
                         (make-sum4
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

!(assertEqual
    (deriv4 (exp2) x)
    4)

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
                         (make-sum4
                              (make-product4 (multiplier5 $exp)
                                            (deriv5 (multiplicand5 $exp) $var))
                              (make-product4 (deriv5 (multiplier5 $exp) $var)
                                            (multiplicand5 $exp)))
                         (if (exponentiation? $exp)
                            (make-exponentiation (base $exp) (deriv5 (base $exp) $var) (exponent $exp))
                            (Error (deriv5 $exp $var) "Unknown expression type")))))))

(= (exp3) (x '+ 3 '* (x '+ y '+ 2)))

!(assertEqual
    (deriv5 (exp3) x)
    4)
; -----------------------End of Exercise 2.58---------------------------


; Representation of sets.
; Lists as representation of sets.

(= (element-of-set? $x Nil)
    False)
(= (element-of-set? $x (Cons $y $ys))
    (if (== $x $y)
        True
        (element-of-set? $x $ys)))

; Instead of this:
;(= (set1) (list (1 2 3)))
;(= (set2) (list (4 5 3)))
; I'll write this:
!(bind! &set1 (list (1 2 3)))
!(bind! &set2 (list (4 5 3)))
; Since first variant doesn't evaluate (set1) and every time we are using (set1) to manipulate with its value it will
; evaluate (list (1 2 3)) every time. bind! allow us to evaluate (list (1 2 3)) once and use it as &set1. Performance-wise
; it is better solution in my opinion. Of course (list (1 2 3)) is not that long to evaluate, but we will have another
; examples when one evaluation of something that needs to be used several times in different calls lasts several minutes.
; So using bind in such situations will save us time.

!(assertEqual
   (element-of-set? 3 &set1)
   True)

!(assertEqual
    (element-of-set? 4 &set1)
    False)

(= (adjoin-set $x $set)
    (if (element-of-set? $x $set)
        $set
        (Cons $x $set)))

!(assertEqual
    (adjoin-set 4 &set1)
    (list (4 1 2 3)))

!(assertEqual
    (adjoin-set 3 &set1)
    (list (1 2 3)))

(= (intersection-set Nil (Cons $x $xs))
    Nil)
(= (intersection-set (Cons $x $xs) Nil)
    Nil)
(= (intersection-set Nil Nil)
    Nil)
(= (intersection-set (Cons $x $xs) (Cons $y $ys))
    (if (element-of-set? $x (Cons $y $ys))
        (Cons $x (intersection-set $xs (Cons $y $ys)))
        (intersection-set $xs (Cons $y $ys))))

!(assertEqual
    (intersection-set &set1 &set2)
    (list (3)))


; Exercise 2.59.
;
; Implement the union-set operation for the
; unordered-list representation of sets.

(= (union-set Nil (Cons $x $xs))
    (Cons $x $xs))
(= (union-set (Cons $x $xs) Nil)
    (Cons $x $xs))
(= (union-set (Cons $x $xs) (Cons $y $ys))
    (if (element-of-set? $x (Cons $y $ys))
        (union-set $xs (Cons $y $ys))
        (Cons $x (union-set $xs (Cons $y $ys)))))

!(assertEqual
    (union-set &set2 &set1)
    (list (4 5 1 2 3)))
; -----------------------End of Exercise 2.59---------------------------

; Exercise 2.60.
;
; We specified that a set would be represented as a list
; with no duplicates. Now suppose we allow duplicates. For instance, the
; set {1,2,3} could be represented as the list (2 3 2 1 3 2 2). Design
; procedures element-of-set?, adjoin-set, union-set, and
; intersection-set that operate on this representation.

; element-of-set? is just the same. Other functions are different

(= (adjoin-set_2 $x $set)
    (Cons $x $set))

!(bind! &set3 (list (2 3 2 1 3 2 2)))

!(assertEqual
    (adjoin-set_2 5 &set3)
    (list (5 2 3 2 1 3 2 2)))

(= (union-set_2 Nil (Cons $x $xs))
    (Cons $x $xs))
(= (union-set_2 (Cons $x $xs) Nil)
    (Cons $x $xs))
(= (union-set_2 (Cons $x $xs) (Cons $y $ys))
    (Cons $x (union-set_2 $xs (Cons $y $ys))))

!(assertEqual
    (union-set_2 &set1 &set3)
    (list (1 2 3 2 3 2 1 3 2 2)))

; Probably this is not effective implementation but it works for general case when elements of sets could be symbols also.

(= (remove-element $el (Cons $x $xs))
    (if (== $el $x)
       $xs
       (Cons $x (remove-element $el $xs))))


(= (intersection-set_2 Nil Nil)
    Nil)
(= (intersection-set_2 (Cons $x $xs) Nil)
    Nil)
(= (intersection-set_2 Nil (Cons $x $xs))
    Nil)
(= (intersection-set_2 (Cons $x $xs) (Cons $y $ys))
    (if (element-of-set? $x (Cons $y $ys))
        (Cons $x (intersection-set_2 $xs (remove-element $x (Cons $y $ys))))
        (intersection-set_2 $xs (Cons $y $ys))))

!(assertEqual
    (intersection-set_2 &set3 &set1)
    (list (2 3 1)))

!(assertEqual
    (intersection-set &set1 &set3)
    (list (1 2 3)))
; -----------------------End of Exercise 2.60---------------------------


; New rule for the set's representation. Set elements should be ordered. For easiness, we will use only numbers. Then
; we can redefine some functions:

(= (element-of-set?_ordered $x Nil)
    False)
(= (element-of-set?_ordered $x (Cons $y $ys))
    (if (== $x $y)
        True
        (if (< $x $y)
            False
            (element-of-set?_ordered $x $ys))))

; Theoretically this one should be quicker than regular element-of-set? since we are stopping recursion as soon as
; current $x becomes less than current (car-list $set) (in case number is not in the set), while regular function will
; still cycle through entire set before outputting False. And it is true for the case below. But there are case when
; $x is greater than last element of $set. In that case, regular element-of-set is quicker due to lack of additional
; conditions.
!(assertEqual
    (element-of-set?_ordered 3 (list (0 1 2 4 5 6 7 8 9 10)))
    False)

; Redefinition of intersection-set:

(= (intersection-set_ordered Nil (Cons $x $xs))
    Nil)
(= (intersection-set_ordered (Cons $x $xs) Nil)
    Nil)
(= (intersection-set_ordered Nil Nil)
    Nil)
(= (intersection-set_ordered (Cons $x $xs) (Cons $y $ys))
    (if (== $x $y)
        (Cons $x (intersection-set_ordered $xs $ys))
        (if (< $x $y)
            (intersection-set_ordered $xs (Cons $y $ys))
            (intersection-set_ordered (Cons $x $xs) $ys))))

!(bind! &set4 (list (1 2 3 4)))
!(bind! &set5 (list (3 4 5 6)))

; This one works much faster than intersection-set due to our restrictions.
!(assertEqual
    (intersection-set_ordered &set4 &set5)
    (list (3 4)))


; Exercise 2.61.
;
; Give an implementation of adjoin-set using the ordered
; representation. By analogy with element-of-set? show how to take
; advantage of the ordering to produce a procedure that requires on the
; average about half as many steps as with the unordered representation.

; We need to re-implement this function since original one just Cons found element to the front of set which is
; incorrect in case of ordered sets.

(= (adjoin-set_ordered $x Nil)
    (list ($x)))
(= (adjoin-set_ordered $x (Cons $y $ys))
    (if (== $x $y)
        (Cons $y $ys)
        (if (< $x $y)
            (Cons $x (Cons $y $ys))
            (Cons $y (adjoin-set_ordered $x $ys)))))


!(assertEqual
    (adjoin-set_ordered 2 &set5)
    (list (2 3 4 5 6)))

!(assertEqual
    (adjoin-set_ordered 7 &set5)
    (list (3 4 5 6 7)))
; -----------------------End of Exercise 2.61---------------------------


; Exercise 2.62.
;
; Give a O(n) implementation of union-set for sets
; represented as ordered lists.

(= (union-set_ordered Nil Nil)
    Nil)
(= (union-set_ordered Nil (Cons $x $xs))
    (Cons $x $xs))
(= (union-set_ordered (Cons $x $xs) Nil)
    (Cons $x $xs))
(= (union-set_ordered (Cons $x $xs) (Cons $y $ys))
    (if (== $x $y)
        (Cons $x (union-set_ordered $xs $ys))
        (if (> $x $y)
            (Cons $y (union-set_ordered (Cons $x $xs) $ys))
            (Cons $x (union-set_ordered $xs (Cons $y $ys))))))

!(assertEqual
    (union-set_ordered &set5 &set4)
    (list (1 2 3 4 5 6)))
; -----------------------End of Exercise 2.62---------------------------


; Binary trees as sets representation. Each node has two children. Left is smaller than node, right - bigger.
; Each element of left branch will be smaller than node and each element of right branch will be bigger than node.

(= (entry $tree) (car-list $tree))

(= (left-branch $tree) (cadr-list $tree))

(= (right-branch $tree) (caddr-list $tree))

(= (make-tree $entry $left $right)
    (list ($entry $left $right)))

; Every tree should contain Nils as its leafs for function to work correctly. That is fair for Scheme code also
; (it won't work in other case).

!(bind! &simple_tree (make-tree 2 (make-tree 1 Nil Nil) (make-tree 3 Nil Nil)))
!(bind! &simple_tree2 (make-tree 6 (make-tree 5 Nil Nil) (make-tree 7 Nil Nil)))
!(bind! &complex_tree (make-tree 4 &simple_tree &simple_tree2))

(= (element-of-set?_binarytree $x Nil)
    False)
(= (element-of-set?_binarytree $x (Cons $y (Cons $yl (Cons $yr Nil))))
    (if (== $x $y)
        True
        (if (< $x $y)
            (element-of-set?_binarytree $x $yl)
            (element-of-set?_binarytree $x $yr))))

(Cons 2 (Cons (Cons 1 (Cons Nil (Cons Nil Nil))) (Cons (Cons 3 (Cons Nil (Cons Nil Nil))) Nil)))

!(assertEqual
    (element-of-set?_binarytree 7 &simple_tree)
    False)

!(assertEqual
    (element-of-set?_binarytree 2 &simple_tree)
    True)

(= (adjoin-set_binarytree $x Nil)
    (make-tree $x Nil Nil))
(= (adjoin-set_binarytree $x (Cons $y (Cons $yl (Cons $yr Nil))))
    (if (== $x $y)
        (Cons $y (Cons $yl (Cons $yr Nil)))
        (if (< $x $y)
            (make-tree $y (adjoin-set_binarytree $x $yl) $yr)
            (make-tree $y $yl (adjoin-set_binarytree $x $yr)))))

!(assertEqual
    (adjoin-set_binarytree 3 &simple_tree)
    &simple_tree)

!(assertEqual
    (adjoin-set_binarytree 3 (adjoin-set_binarytree 1 (make-tree 2 Nil Nil)))
    &simple_tree)

(= (append Nil $list2)
   $list2)
(= (append (Cons $x $xs) $list2)
   (Cons $x (append $xs $list2)))

; Procedure to convert binary tree to regular list. Two variants.
(= (tree->list-1 Nil)
    Nil)
(= (tree->list-1 (Cons $y (Cons $yl (Cons $yr Nil))))
    (append (tree->list-1 $yl) (Cons $y (tree->list-1 $yr))))

(: lambda3 (-> Variable Variable Variable Atom (-> $a $b $c $t)))
(= ((lambda3 $var1 $var2 $var3 $body) $val1 $val2 $val3)
    (let (quote ($v1 $v2 $v3 $b)) (sealed ($var1 $var2 $var3) (quote ($var1 $var2 $var3 $body))) (let (quote ($v1 $v2 $v3)) (quote ($val1 $val2 $val3)) $b)) )

(= (tree->list-2 $tree)
    (let $copy-to-list
        (lambda3 $subtree $result-list $self
            (if (null-list? $subtree)
                $result-list
                ($self (left-branch $subtree)
                        (Cons (entry $subtree)
                                ($self (right-branch $subtree) $result-list $self)) $self)))
    ($copy-to-list $tree Nil $copy-to-list)))

!(assertEqual
    (tree->list-1 &simple_tree)
    (list (1 2 3)))
!(assertEqual
    (tree->list-2 &simple_tree)
    (list (1 2 3)))

;Procedure to convert a list to balanced binary tree.

(= (length-list Nil)
    0)
(= (length-list (Cons $x $xs))
    (+ 1 (length-list $xs)))

(= (list->tree $elements)
    (car-list (partial-tree $elements (length-list $elements))))

; We need quotient. Currently I'm importing it from python.
!(import! &self additional_funcs)

(= (partial-tree $elts $n)
    (if (== $n 0)
        (Cons Nil $elts)
        (let*
            (($left-size (// (- $n 1) 2))
            ($left-result (partial-tree $elts $left-size))
            ($left-tree (car-list $left-result))
            ($non-left-elts (cdr-list $left-result))
            ($right-size (- $n (+ $left-size 1)))
            ($this-entry (car-list $non-left-elts))
            ($right-result (partial-tree (cdr-list $non-left-elts) $right-size))
            ($right-tree (car-list $right-result))
            ($remaining-elts (cdr-list $right-result)))
        (Cons (make-tree $this-entry $left-tree $right-tree) $remaining-elts))))

!(assertEqual
    (list->tree (list (1 2 3 4 5)))
    (make-tree 3 (make-tree 1 Nil (make-tree 2 Nil Nil)) (make-tree 4 Nil (make-tree 5 Nil Nil))))



; Exercise 2.65.
;
; Use the results of exercises 2.63 (tree->list) and 2.64 (list->tree) to give O(n)
; implementations of union-set and intersection-set for sets implemented as
; (balanced) binary trees.

(= (union-set_binarytree $tree1 $tree2)
    (list->tree (union-set_ordered (tree->list-1 $tree1) (tree->list-1 $tree2))))

(= (intersection-set_binarytree $tree1 $tree2)
    (list->tree (intersection-set_ordered (tree->list-1 $tree1) (tree->list-1 $tree2))))

!(assertEqual
    (union-set_binarytree &simple_tree &simple_tree)
    &simple_tree)
!(assertEqual
    (union-set_binarytree &simple_tree2 &simple_tree)
    (make-tree 3 (make-tree 1 Nil (make-tree 2 Nil Nil)) (make-tree 6 (make-tree 5 Nil Nil) (make-tree 7 Nil Nil))))

!(assertEqual
    (intersection-set_binarytree &simple_tree2 &simple_tree)
    Nil)

!(assertEqual
    (intersection-set_binarytree &simple_tree &complex_tree)
    &simple_tree)
; -----------------------End of Exercise 2.65---------------------------


; Sets and information search.

; Lookup searchs through set of records to find a record with a given key and returns it if found. False - otherwise.
; This lookup implementation is for unordered list as set's representation.

(= (key $x)
    (car-list $x))

(= (lookup $given-key Nil)
    False)
(= (lookup $given-key (Cons $x $xs))
    (if (== $given-key (key $x))
        $x
        (lookup $given-key $xs)))

!(bind! &simple_record_list (list ((list (5 Petrov)) (list (2 Sidorov)) (list (3 Ivanov)))))

!(assertEqual
    (lookup 3 &simple_record_list)
    (list (3 Ivanov)))
!(assertEqual
    (lookup 7 &simple_record_list)
    False)

; Exercise 2.66.
; Implement the lookup procedure for the case where the
; set of records is structured as a binary tree, ordered by the
; numerical values of the keys.

!(bind! &simple_record_binarytree (make-tree (list (3 Ivanov))
                                (make-tree (list (2 Sidorov)) Nil Nil)
                                (make-tree (list (5 Petrov)) Nil Nil)))

(= (lookup_binarytree $given-key Nil)
    False)
(= (lookup_binarytree $givenkey (Cons $y (Cons $yl (Cons $yr Nil))))
    (let $curkey (key $y)
        (if (== $givenkey $curkey)
            $y
            (if (< $givenkey $curkey)
                (lookup_binarytree $givenkey $yl)
                (lookup_binarytree $givenkey $yr)))))

; For some reason this lookup works slower than lookup on unordered list which is weird.
; This could be related to introduction of one more "if" in lookup and maybe lookup_binarytree will be faster on larger
; records.

!(assertEqual
    (lookup_binarytree 7 &simple_record_binarytree)
    False)
!(assertEqual
     (lookup_binarytree 5 &simple_record_binarytree)
     (list (5 Petrov)))
; -----------------------End of Exercise 2.66---------------------------

; Huffman coding trees.

(= (make-leaf $symbol $weight)
    (list (leaf $symbol $weight)))

(= (leaf? $object)
    (== (car-list $object) leaf))

(= (symbol-leaf (Cons leaf (Cons $symbol (Cons $weight Nil)))) $symbol)

(= (weight-leaf (Cons leaf (Cons $symbol (Cons $weight Nil)))) $weight)

(= (make-code-tree $left $right)
    (list ($left
            $right
            (append (symbols $left) (symbols $right))
            (+ (weight $left) (weight $right)))))

(= (left-branch_ct (Cons $left (Cons $right (Cons $symbols (Cons $weight Nil)))))
    $left)

(= (right-branch_ct (Cons $left (Cons $right (Cons $symbols (Cons $weight Nil)))))
    $right)

(= (symbols (Cons leaf (Cons $symbol (Cons $weight Nil))))
    (list ($symbol)))
(= (symbols (Cons $left (Cons $right (Cons $symbols (Cons $weight Nil)))))
  $symbols)
(= (weight (Cons leaf (Cons $symbol (Cons $weight Nil))))
    $weight)
(= (weight (Cons $left (Cons $right (Cons $symbols (Cons $weight Nil)))))
  $weight)

; Function which decodes bit sequence using Huffman's tree.
(= (decode-1 Nil $branch $tree)
    Nil)
(= (decode-1 (Cons $x $xs) $branch $tree)
    (let $next-branch
           (choose-branch $x $branch)
      (if (leaf? $next-branch)
          (Cons (symbol-leaf $next-branch)
                (decode-1 $xs $tree $tree))
          (decode-1 $xs $next-branch $tree))))
(= (decode $bits $tree)
   (decode-1 $bits $tree $tree))

(= (choose-branch $bit $tree)
  (case $bit
    ((0 (left-branch_ct $tree))
    (1 (right-branch_ct $tree))
    ($_ (Error (choose-branch $bit $tree) "Wrong bit. Only 0 and 1 allowed")))))


(= (adjoin-set_ct $x Nil)
    (list ($x)))
(= (adjoin-set_ct $x (Cons $y $ys))
    (if (< (weight $x) (weight $y))
        (Cons $x (Cons $y $ys))
        (Cons $y (adjoin-set_ct $x $ys))))

(= (make-leaf-set Nil)
    Nil)
(= (make-leaf-set (Cons $x $xs))
    (adjoin-set_ct (make-leaf (car-list $x) (cadr-list $x)) (make-leaf-set $xs)))


; Exercise 2.67.
;
; Define an encoding tree and a sample message:

!(bind! &sample-tree (make-code-tree (make-leaf A 4)
                                      (make-code-tree
                                       (make-leaf B 2)
                                       (make-code-tree (make-leaf D 1)
                                                       (make-leaf C 1)))))


(= (sample-message) (list (0 1 1 0 0 1 0 1 0 1 1 1 0)))

; Use the decode procedure to decode the message, and give the result.

!(assertEqual
    (decode (sample-message) &sample-tree)
    (list (A D A B B C A)))

; -----------------------End of Exercise 2.67---------------------------

; Exercise 2.68.
;
; The encode procedure takes as arguments a message and a tree and produces the
; list of bits that gives the encoded message.

; (define (encode message tree)
;   (if (null? message)
;       '()
;       (append (encode-symbol (car message) tree)
;               (encode (cdr message) tree))))

; Encode-symbol is a procedure, which you must write, that returns the list of
; bits that encodes a given symbol according to a given tree. You should design
; encode-symbol so that it signals an error if the symbol is not in the tree at
; all. Test your procedure by encoding the result you obtained in exercise 2.67
; with the sample tree and seeing whether it is the same as the original sample
; message.

(= (encode Nil $tree)
    Nil)
(= (encode (Cons $x $xs) $tree)
    (append (encode-symbol $x $tree)
            (encode $xs $tree)))

(= (r-encode-symbol $x (Cons leaf (Cons $symbol (Cons $weight Nil))) $code)
    $code)
(= (r-encode-symbol $x (Cons $left (Cons $right (Cons $symbols (Cons $weight Nil)))) $code)
    (if (element-of-set? $x (symbols $left))
        (r-encode-symbol $x $left (append $code (list (0))))
        (r-encode-symbol $x $right (append $code (list (1))))))

(= (encode-symbol $x $tree)
    (if (element-of-set? $x (symbols $tree))
        (r-encode-symbol $x $tree Nil)
        (Error (encode-symbol $x $tree) "No such symbol in code tree")))

!(assertEqual
    (encode (list (A D A B B C A)) &sample-tree)
    (list (0 1 1 0 0 1 0 1 0 1 1 1 0)))
; -----------------------End of Exercise 2.68---------------------------


; Exercise 2.69.
;
; The following procedure takes as its argument a list of
; symbol-frequency pairs (where no symbol appears in more than one pair) and
; generates a Huffman encoding tree according to the Huffman algorithm.

(= (generate-huffman-tree $pairs)
  (successive-merge (make-leaf-set $pairs)))

; Make-leaf-set is the procedure given above that transforms the list of pairs
; into an ordered set of leaves. Successive-merge is the procedure you must
; write, using make-code-tree to successively merge the smallest-weight
; elements of the set until there is only one element left, which is the
; desired Huffman tree. (This procedure is slightly tricky, but not really
; complicated. If you find yourself designing a complex procedure, then you are
; almost certainly doing something wrong. You can take significant advantage of
; the fact that we are using an ordered set representation.)


(= (sample-pairs)
    (list
      ((list (A 8))
      (list (B 3))
      (list (C 1))
      (list (D 1))
      (list (E 1))
      (list (F 1))
      (list (G 1))
      (list (H 1)))))

(= (successive-merge (Cons $x Nil))
    $x)
; $ee is for "everything else"
(= (successive-merge (Cons $p1 (Cons $p2 $ee)))
    (successive-merge (adjoin-set_ct (make-code-tree $p1 $p2) $ee)))


; I don't know how to make it more compact (of course i can reduce number of lines using consequent make-code-tree and
; make-leaf but I thought I'd better leave it like this since consequent make's could take some significant time):
!(assertEqual
    (generate-huffman-tree (sample-pairs))
    (Cons
        (Cons leaf (Cons A (Cons 8 Nil)))
        (Cons
            (Cons
                (Cons
                    (Cons
                        (Cons leaf (Cons H (Cons 1 Nil)))
                        (Cons
                            (Cons leaf (Cons G (Cons 1 Nil)))
                            (Cons (Cons H (Cons G Nil)) (Cons 2 Nil))))
                    (Cons
                        (Cons
                            (Cons leaf (Cons F (Cons 1 Nil)))
                            (Cons (Cons leaf (Cons E (Cons 1 Nil))) (Cons (Cons F (Cons E Nil)) (Cons 2 Nil))))
                        (Cons (Cons H (Cons G (Cons F (Cons E Nil)))) (Cons 4 Nil))))
                    (Cons
                        (Cons
                            (Cons
                                (Cons leaf (Cons D (Cons 1 Nil)))
                                (Cons (Cons leaf (Cons C (Cons 1 Nil))) (Cons (Cons D (Cons C Nil)) (Cons 2 Nil))))
                            (Cons
                                (Cons leaf (Cons B (Cons 3 Nil)))
                                (Cons (Cons D (Cons C (Cons B Nil))) (Cons 5 Nil))))
                        (Cons (Cons H (Cons G (Cons F (Cons E (Cons D (Cons C (Cons B Nil))))))) (Cons 9 Nil))))
            (Cons (Cons A (Cons H (Cons G (Cons F (Cons E (Cons D (Cons C (Cons B Nil)))))))) (Cons 17 Nil)))))
; -----------------------End of Exercise 2.69---------------------------


; Exercise 2.70.
;
; The following eight-symbol alphabet with associated relative
; frequencies was designed to efficiently encode the lyrics of 1950s rock
; songs. (Note that the ``symbols'' of an ``alphabet'' need not be individual
; letters.)

; A     2 NA   16
; BOOM  1 SHA  3
; GET   2 YIP  9
; JOB   2 WAH  1

; Use generate-huffman-tree (exercise 2.69) to generate a corresponding Huffman
; tree, and use encode (exercise 2.68) to encode the following message:

; Get a job

; Sha na na na na na na na na

; Get a job

; Sha na na na na na na na na

; Wah yip yip yip yip yip yip yip yip yip

; Sha boom

(= (rock-pairs)
    (list
        ((list (a 2))
         (list (boom 1))
         (list (Get 2))
         (list (job 2))
         (list (na 16))
         (list (Sha 3))
         (list (yip 9))
         (list (Wah 1)))))

; This bind takes ~ 5 mins on regular Metta on my laptop. So you'll have to wait a bit.
!(bind! &rock-huffman-tree (generate-huffman-tree (rock-pairs)))

!(assertEqual
    (encode (list (Get a job)) &rock-huffman-tree)
    (list (1 1 1 1 1 1 1 0 0 1 1 1 1 0)))

!(assertEqual
    (encode (list (Sha na na na na na na na na)) &rock-huffman-tree)
    (list (1 1 1 0 0 0 0 0 0 0 0 0)))

!(assertEqual
    (encode (list (Wah yip yip yip yip yip yip yip yip yip)) &rock-huffman-tree)
    (list (1 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0)))

!(assertEqual
    (encode (list (Sha boom)) &rock-huffman-tree)
    (list (1 1 1 0 1 1 0 1 1)))
; -----------------------End of Exercise 2.70---------------------------