; Those three functions are not just wraps for convenient usage of car instead car-atom, but they will help to
; avoid necessity of usage of let in some functions where cons, car and cdr will be used in recursion scheme.

(= (cons $x $y)
    (cons-atom $x $y))

(= (car $x)
    (car-atom $x))

(= (cdr $x)
    (cdr-atom $x))

(= (null? $list)
    (== $list ()))

(= (list $varlist)
    (if (null? $varlist)
        ()
        (if (null? (cdr $varlist))
            ((car $varlist))
            (cons (car $varlist) (list (cdr $varlist))))))

(= (one-through-four) (list (1 2 3 4)))

;!(assertEqual
;    (one-through-four)
;    (1 2 3 4))

;Not quite what you'll expect:

;!(assertEqual
;    (car-atom (one-through-four))
;    one-through-four)

; This is how it could be done in Metta (and it leads to code complication with those lets):
;!(assertEqual
;    (let $list (one-through-four) (car-atom $list))
;    1)

; But instead, I've done this:
;!(assertEqual
;    (car (one-through-four))
;    1)

; Same goes here:
;!(assertEqual
;    (cdr-atom (one-through-four))
;    ())

;!(assertEqual
;    (cdr (one-through-four))
;    (2 3 4))

; car-atom after cdr-atom should be done not like that in Metta too:
;!(assertEqual
;    (car-atom (cdr-atom (one-through-four)))
;    cdr-atom)

; It could be done like that:
;!(assertEqual
;    (let $list (1 2 3 4)
;        (let $tail (cdr-atom $list)
;            (car-atom $tail)))
;    2)

; But once again, it is simpler to do this:

;!(assertEqual
;    (car (cdr (1 2 3 4)))
;    2)

;!(assertEqual
;    (cons 10 (one-through-four))
;    (10 1 2 3 4))

(= (list-ref $items $n)
    (if (== $n 0)
        (car $items)
        (list-ref (cdr $items) (- $n 1))))

(= (squares) (list (1 4 9 16 25)))

;!(assertEqual
;    (list-ref (squares) 3)
;    16)

(= (length $items)
    (if (null? $items)
        0
        (+ 1 (length (cdr $items)))))

;!(assertEqual
;    (length (squares))
;    5)

(= (odds) (list (1 3 5 7)))

;!(assertEqual
;    (length (odds))
;    4)

(= (append $list1 $list2)
    (if (null? $list1)
        $list2
        (cons (car $list1) (append (cdr $list1) $list2))))

;!(assertEqual
;    (append (squares) (odds))
;    (1 4 9 16 25 1 3 5 7))

;!(assertEqual
;    (append (odds) (squares))
;    (1 3 5 7 1 4 9 16 25))


; Exercise 2.17.
; Define a procedure last-pair that returns the list that contains only the
; last element of a given (nonempty) list:
;
; Example: (last-pair (list 10 12 41 32)) -> 32

(= (last-pair $list)
    (if (null? (cdr $list))
        (car $list)
        (last-pair (cdr $list))))

;!(assertEqual
;    (last-pair (squares))
;    25)

; -----------------------End of Exercise 2.17---------------------------

; Exercise 2.18.
; Define a procedure reverse that takes a list as argument and returns a list of the same elements in reverse order:
;
; Example: (reverse (list 1 4 9 16 25)) -> (25 16 9 4 1)

;(= (reverse $list)
;    (if (null? (cdr $list))
;        ((car $list))
;         (append (reverse (cdr $list)) ((car $list)))))

;!(assertEqual
;    (reverse (squares))
;    (25 16 9 4 1))

; -----------------------End of Exercise 2.18---------------------------


; Exercise 2.19.
;
; Consider the change-counting program of section 1.2.2.
; It would be nice to be able to easily change the currency used by
; the program, so that we could compute the number of ways to change a
; British pound, for example. As the program is written, the knowledge of
; the currency is distributed partly into the procedure first-denomination
; and partly into the procedure count-change (which knows that there are five
; kinds of U.S. coins). It would be nicer to be able to supply a list of
; coins to be used for making change.

; We want to rewrite the procedure cc so that its second argument is a list of
; the values of the coins to use rather than an integer specifying which coins
; to use. We could then have lists that defined each kind of currency:

(= (us-coins) (list (50 25 10 5 1)))
(= (uk-coins) (list (100 50 20 10 5 2 1 0.5)))

; We could then call cc as follows:

; !(cc 100 (us-coins)) ; 292

; To do this will require changing the program cc somewhat. It will still have
; the same form, but it will access its second argument differently, as follows:

(= (cc $amount $coin-values)
    (if (== $amount 0)
        1
        (if (or (< $amount 0) (no-more? $coin-values))
            0
            (+ (cc $amount
                (except-first-denomination $coin-values))
                (cc (- $amount (first-denomination $coin-values))
                    $coin-values)))))

; Define the procedures first-denomination, except-first-denomination, and no-more?
; in terms of primitive operations on list structures. Does the order of the list
; coin-values affect the answer produced by cc? Why or why not?

(= (first-denomination $coin-values)
    (car $coin-values))

(= (except-first-denomination $coin-values)
    (cdr $coin-values))

(= (no-more? $coin-values)
    (null? $coin-values))

;!(assertEqual
;    (cc 20 (us-coins))
;    9)

;!(assertEqual
;    (cc 10 (uk-coins))
;    50)
; -----------------------End of Exercise 2.19---------------------------

; Exercise 2.20.
;
; The procedures +, *, and list take arbitrary numbers of arguments. One way to
; define such procedures is to use define with 'dotted-tail notation'. In a procedure
; definition, a parameter list that has a dot before the last parameter name
; indicates that, when the procedure is called, the initial parameters (if any) will
; have as values the initial arguments, as usual, but the final parameter's value
; will be a list of any remaining arguments. For instance, given the definition
;
; (define (f x y . z) <body>)
;
; the procedure f can be called with two or more arguments. If we evaluate

; (f 1 2 3 4 5 6)

; then in the body of f, x will be 1, y will be 2, and z will be the list (3 4 5 6). Given the definition

; (define (g . w) <body>)

; the procedure g can be called with zero or more arguments. If we evaluate

; (g 1 2 3 4 5 6)

; then in the body of g, w will be the list (1 2 3 4 5 6).

; Use this notation to write a procedure same-parity that takes one or more integers and
; returns a list of all the arguments that have the same even-odd parity as the first argument. For example,

; (same-parity 1 2 3 4 5 6 7)
; (1 3 5 7)

; (same-parity 2 3 4 5 6 7)
; (2 4 6)

; Metta currently doesn't have such functionality. So, I'll use a workaround.

(= (same-parity $x $arglist)
    (if (null? $arglist)
        ()
        (let $recres (same-parity $x (cdr $arglist))
            (if (== (% $x 2) (% (car $arglist) 2))
                (cons (car $arglist) $recres)
                $recres))))

;!(assertEqual
;    (same-parity 1 (2 3 4 5 6 7))
;    (3 5 7))

;!(assertEqual
;    (same-parity 2 (2 3 4 5 6 7))
;    (2 4 6))
; -----------------------End of Exercise 2.20---------------------------


(= (scale-list $items $factor)
    (if (null? $items)
        ()
        (cons (* (car $items) $factor) (scale-list (cdr $items) $factor))))

;!(assertEqual
;    (scale-list (list (1 2 3 4 5)) 10)
;    (10 20 30 40 50))

(= (map $proc $items)
    (if (null? $items)
        ()
         (cons ($proc (car $items)) (map $proc (cdr $items)))))

(= (abs $x) (if (< $x 0) (* $x -1) $x))

;!(assertEqual
;    (map abs (list (-10 2.5 -11.6 17)))
;    (10 2.5 11.6 17))

(: lambda1 (-> Variable Atom (-> $a $t)))
(= ((lambda1 $var $body) $val)
    (let (quote $var) (quote $val) $body) )

(= (square $x)
    (* $x $x))

;!(assertEqual
;    (map square (list (1 2 3 4)))
;    (1 4 9 16))

(= (scale-list-m $items $factor)
    (map (lambda1 $x (* $x $factor)) $items))

;!(assertEqual
;    (scale-list-m (list (1 2 3 4 5)) 10)
;    (10 20 30 40 50))


; Exercise 2.21.
; The procedure square-list takes a list of numbers as argument and returns
; a list of the squares of those numbers.

; (square-list (list 1 2 3 4)) ; -> (1 4 9 16)

; Here are two different definitions of square-list. Complete both of them by filling in the missing expressions:

(= (square-list $items)
    (if (null? $items)
        ()
        (let $head (car $items)
            (cons (* $head $head) (square-list (cdr $items))))))

(= (square-list-m $items)
    (map square $items))

;!(assertEqual
;    (square-list (1 2 3 4 5))
;    (1 4 9 16 25))
;!(assertEqual
;    (square-list-m (1 2 3 4 5))
;    (1 4 9 16 25))

; -----------------------End of Exercise 2.21---------------------------


; Exercise 2.23.
; The procedure for-each is similar to map. It takes as arguments a procedure and a list of
; elements. However, rather than forming a list of the results, for-each just applies the
; procedure to each of the elements in turn, from left to right. The values returned by applying
; the procedure to the elements are not used at all -- for-each is used with
; procedures that perform an action, such as printing. For example,

; (for-each (lambda (x) (newline) (display x))
;           (list 57 321 88))
; 57
; 321
; 88

; The value returned by the call to for-each (not illustrated above) can
; be something arbitrary, such as true. Give an implementation of for-each.

(= (for-each $proc $list)
    (if (null? $list)
        ()
        (let*
        (
            (() ($proc (car $list)))
            (() (for-each $proc (cdr $list)))
        )
        ())))

; prints list
;!(assertEqual
;    (for-each println! (list (57 321 88)))
;    ())
; -----------------------End of Exercise 2.23---------------------------

; Procedure to count leaves on Scheme looks like this:
;(define (count-leaves x)
;    (cond ((null? x) 0)
;        ((not (pair? x)) 1)
;        (else (+ (count-leaves (car x))
;            (count-leaves (cdr x))))))

; But in Metta, we do not have function pair? So, I'm using a workaround - checking type of current input. List in Metta
; will be something like that (Number Number (Number Number)) for list (1 5 (6 4)). So, when we are reaching "not-pair?"
; we are actually reaching just Number in our program. Of course this check won't work if we are working with list of
; letters not numbers, but this is a workaround I've got in mind. Feel free to share your vision.

(= (count-leaves $x)
    (if (null? $x)
        0
        (if (== (get-type $x) Number)
            1
            (+ (count-leaves (car $x))
                (count-leaves (cdr $x))))))

(= (x) (let $list2 (list (3 4)) (cons (list (1 2)) $list2)))

;!(assertEqual
;    (x)
;    ((1 2) 3 4))

;!(assertEqual
;    (length (x))
;    3)

;!(assertEqual
;    (count-leaves (x))
;    4)

;!(assertEqual
;    (length (list ((x) (x))))
;    2)

;!(assertEqual
;    (count-leaves (list ((x) (x))))
;    8)


; Exercise 2.27.
;
; Modify your reverse procedure of exercise 2.18
; to produce a deep-reverse procedure that takes a
; list as argument and returns as its value the list with
; its elements reversed and with all sublists deep-reversed as well. For example,

; (= (x) (list ((list (1 2)) (list (3 4)))))
; !(x) -> ((1 2) (3 4))

; !(reverse (x)) -> ((3 4) (1 2))

; !(deep-reverse (x)) -> ((4 3) (2 1))

(= (deep-reverse $list)
    (if (null? $list)
        ()
        (if (== (get-type $list) Number)
            $list
                (append (deep-reverse (cdr $list)) (list ((deep-reverse (car $list))))))))

;!(assertEqual
;    (deep-reverse ((1 2) (3 4)))
;    ((4 3) (2 1)))

;!(assertEqual
;    (deep-reverse ((1 2 3) (4 5 6) (7 8 9)))
;    ((9 8 7) (6 5 4) (3 2 1)))

; -----------------------End of Exercise 2.23---------------------------

; Exercise 2.28.
; Write a procedure fringe that takes as argument a tree
; (represented as a list) and returns a list whose elements are
; all the leaves of the tree arranged in left-to-right order. For example,

; (= (x) (list ((list (1 2)) (list (3 4)))))

; !(fringe (x)) -> (1 2 3 4)

; !(fringe (list (x x))) -> (1 2 3 4 1 2 3 4)

(= (fringe $list)
    (if (null? $list)
        ()
        (if (== (get-type $list) Number)
            ($list)
            (append (fringe (car $list)) (fringe (cdr $list))))))

;!(assertEqual
;    (fringe (list ((list (1 2)) (list (3 4)))))
;    (1 2 3 4))

;!(assertEqual
;    (fringe (list ((list ((list (1 2)) (list (3 4)))) (list ((list (1 2)) (list (3 4)))))))
;    (1 2 3 4 1 2 3 4))

; -----------------------End of Exercise 2.28---------------------------



; Exercise 2.29.
;
; A binary mobile consists of two branches, a left branch and a right branch.
; Each branch is a rod of a certain length, from which hangs either a weight or
; another binary mobile. We can represent a binary mobile using compound data by
; constructing it from two branches (for example, using list):

(= (make-mobile $left $right)
  (list ($left $right)))

; A branch is constructed from a length (which must be a number) together
; with a structure, which may be either a number (representing a simple weight) or another mobile:

(= (make-branch $length $structure)
  (list ($length $structure)))

; a.  Write the corresponding selectors left-branch and right-branch,
;     which return the branches of a mobile, and branch-length and
;     branch-structure, which return the components of a branch.
; b.  Using your selectors, define a procedure total-weight that returns
;     the total weight of a mobile.
; c.  A mobile is said to be balanced if the torque applied by its top-left
;     branch is equal to that applied by its top-right branch (that is, if the
;     length of the left rod multiplied by the weight hanging from that rod is
;     equal to the corresponding product for the right side) and if each of the
;     submobiles hanging off its branches is balanced. Design a predicate that
;     tests whether a binary mobile is balanced.
; d.  Suppose we change the representation of mobiles so that the constructors are

; (= (make-mobile $left $right)
;   (cons $left $right))
; (= (make-branch $length $structure)
;   (cons $length $structure))

; Q: How much do you need to change your programs to convert to the new representation?
; A: We will need to redefine functions left-branch, right-branch, branch-length and
; branch-structure.

(= (left-branch $mobile)
    (car $mobile))

(= (right-branch $mobile)
    (car (cdr $mobile)))

(= (branch-structure $branch)
    (car (cdr $branch)))

(= (branch-length $branch)
    (car $branch))

(= (simple-mobile)
    (make-mobile
        (make-branch 2 15)
        (make-branch 3 10)))

(= (complex-mobile) (make-mobile
                        (make-branch 4 (simple-mobile))
                        (make-branch 2 (simple-mobile))))

(= (more-complex-mobile) (make-mobile
                            (make-branch 7 (complex-mobile))
                             (make-branch 8 (complex-mobile))))

(= (total-weight $mobile)
    (if (== (get-type $mobile) Number)
        $mobile
        (+ (total-weight (branch-structure (left-branch $mobile)))
            (total-weight (branch-structure (right-branch $mobile))))))

;!(assertEqual
;    (total-weight (more-complex-mobile))
;    100)


(= (isbalanced? $mobile)
     (if (== (get-type $mobile) Number)
        True
        (let*
        (
            ($left-br (left-branch $mobile))
            ($right-br (right-branch $mobile))
            ($left-br-str (branch-structure $left-br))
            ($right-br-str (branch-structure $right-br))
            ($left-br-len (branch-length $left-br))
            ($right-br-len (branch-length $right-br))
        )
        (if (== (* $left-br-len (total-weight $left-br-str))
                (* $right-br-len (total-weight $right-br-str)))
                (and (isbalanced? $left-br-str) (isbalanced? $right-br-str))
                False))))

;!(assertEqual
;    (isbalanced? (simple-mobile))
;    True)

;!(assertEqual
;    (isbalanced? (more-complex-mobile))
;    False)
; -----------------------End of Exercise 2.29---------------------------


(= (scale-tree $tree $factor)
    (if (null? $tree)
        ()
        (if (== (get-type $tree) Number)
            (* $tree $factor)
            (cons (scale-tree (car $tree) $factor)
                    (scale-tree (cdr $tree) $factor)))))

;!(assertEqual
;    (scale-tree (list (1 (list (2 (list (3 4)) 5)) (list (6 7)))) 10)
;    (10 (20 (30 40) 50) (60 70)))

(= (scale-tree-m $tree $factor)
    (map (lambda1 $sub-tree
        (if (== (get-type $sub-tree) Number)
            (* $sub-tree $factor)
            (scale-tree-m $sub-tree $factor)))
            $tree))

;!(assertEqual
;    (scale-tree-m (list (1 (list (2 (list (3 4)) 5)) (list (6 7)))) 10)
;    (10 (20 (30 40) 50) (60 70)))


; Exercise 2.30.
;
; Define a procedure square-tree analogous to the square-list procedure
; of exercise 2.21. That is, square-list should behave as follows:

; !(square-tree
;  (list (1 (list (2 (list (3 4)) 5)) (list (6 7)))))

; (1 (4 (9 16) 25) (36 49))

; Define square-tree both directly (i.e., without using any higher-order procedures)
; and also by using map and recursion.

;Directly

(= (square-tree $tree)
    (if (null? $tree)
        ()
        (if (== (get-type $tree) Number)
            (* $tree $tree)
                (cons (square-tree (car $tree)) (square-tree (cdr $tree))))))

;!(assertEqual
;    (square-tree (list (1 (list (2 (list (3 4)) 5)) (list (6 7)))))
;    (1 (4 (9 16) 25) (36 49)))


(= (square-tree-m $tree)
    (map (lambda1 $sub-tree
        (if (== (get-type $sub-tree) Number)
            (* $sub-tree $sub-tree)
            (square-tree-m $sub-tree)))
            $tree))

;!(assertEqual
;    (square-tree-m (list (1 (list (2 (list (3 4)) 5)) (list (6 7)))))
;    (1 (4 (9 16) 25) (36 49)))
; -----------------------End of Exercise 2.30---------------------------


; Exercise 2.31.
;
; Abstract your answer to exercise 2.30 to produce a procedure tree-map
; with the property that square-tree could be defined as

; (= (square-tree $tree) (tree-map square $tree))

(= (tree-map $proc $tree)
    (if (null? $tree)
        ()
        (if (== (get-type $tree) Number)
            ($proc $tree)
            (cons (tree-map $proc (car $tree)) (tree-map $proc (cdr $tree))))))

(= (square-tree-tm $tree) (tree-map square $tree))

;!(assertEqual
;    (square-tree-tm (list (1 (list (2 (list (3 4)) 5)) (list (6 7)))))
;    (1 (4 (9 16) 25) (36 49)))
; -----------------------End of Exercise 2.31---------------------------

; Exercise 2.32.
;
; We can represent a set as a list of distinct elements, and we can
; represent the set of all subsets of the set as a list of lists.
; For example, if the set is (1 2 3), then the set of all subsets is
; (() (3) (2) (2 3) (1) (1 3) (1 2) (1 2 3)). Complete the following
; definition of a procedure that generates the set of subsets of a set
; and give a clear explanation of why it works:

(= (subsets $s)
    (if (null? $s)
        (list (()))
        (let $rest (subsets (cdr $s))
            (append $rest (map (lambda1 $x (append $x (list ((car $s))))) $rest)))))


;!(assertEqual
;    (subsets (1 2 3))
;    (() (3) (2) (3 2) (1) (3 1) (2 1) (3 2 1)))

; -----------------------End of Exercise 2.32---------------------------


; Functions in terms of signal processing. Kind of.

(= (filter $predicate $sequence)
    (if (null? $sequence)
        ()
        (let $car (car $sequence)
            (let $recrescdr (filter $predicate (cdr $sequence))
                (if ($predicate $car)
                    (cons $car $recrescdr)
                    $recrescdr)))))

(= (odd? $x) (== (% $x 2) 1))

;!(assertEqual
;    (filter odd? (1 2 3 4 5))
;    (1 3 5))

(= (accumulate $op $initial $sequence)
    (if (null? $sequence)
        $initial
        ($op (car $sequence) (accumulate $op $initial (cdr $sequence)))))

;!(assertEqual
;    (accumulate + 0 (list (1 2 3 4 5)))
;    15)

;!(assertEqual
;    (accumulate * 1 (list (1 2 3 4 5)))
;    120)

;!(assertEqual
;    (accumulate cons () (list (1 2 3 4 5)))
;    (1 2 3 4 5))

(= (enumerate-interval $low $high)
    (if (> $low $high)
        ()
        (cons $low (enumerate-interval (+ $low 1) $high))))

;!(assertEqual
;    (enumerate-interval 2 7)
;    (2 3 4 5 6 7))


(= (enumerate-tree $tree)
    (if (null? $tree)
        ()
        (if (== (get-type $tree) Number)
            (list ($tree))
            (append (enumerate-tree (car $tree)) (enumerate-tree (cdr $tree))))))

;!(assertEqual
;    (enumerate-tree (list (1 (list (2 (list (3 4)))) 5)))
;    (1 2 3 4 5))

(= (sum-odd-squares $tree)
    (accumulate +
        0
        (map square
            (filter odd?
                (enumerate-tree $tree)))))

;!(assertEqual
;    (sum-odd-squares (list (1 (list (2 (list (3 4)))) 5)))
;    35)

(= (fib $n)
    (if (== $n 0)
        0
        (if (== $n 1)
            1
            (+ (fib (- $n 1)) (fib (- $n 2))))))

(= (even? $x)
    (== (% $x 2) 0))

(= (even-fibs $n)
    (accumulate cons
        ()
        (filter even?
            (map fib
                (enumerate-interval 0 $n)))))

;!(assertEqual
;    (even-fibs 8)
;    (0 2 8))


(= (list-fib-squares $n)
    (accumulate cons
    ()
    (map square
        (map fib
            (enumerate-interval 0 $n)))))

;!(assertEqual
;    (list-fib-squares 10)
;    (0 1 1 4 9 25 64 169 441 1156 3025))

(= (product-of-squares-of-odd-elements $sequence)
    (accumulate *
        1
        (map square
            (filter odd? $sequence))))

;!(assertEqual
;    (product-of-squares-of-odd-elements (list (1 2 3 4 5)))
;    225)


; Exercise 2.33.
;
; Fill in the missing expressions to complete the following definitions of some
; basic list-manipulation operations as accumulations:

(: lambda2 (-> Variable Variable Atom (-> $a $b $t)))
(= ((lambda2 $var1 $var2 $body) $val1 $val2)
    (let (quote ($var1 $var2)) (quote ($val1 $val2)) $body))

(= (acc-map $p $sequence)
  (accumulate (lambda2 $x $y (cons ($p $x) $y)) () $sequence))

;!(assertEqual
;    (acc-map square (list (1 2 3 4 5)))
;    (1 4 9 16 25))

(= (acc-append $seq1 $seq2)
  (accumulate cons $seq2 $seq1))

;!(assertEqual
;    (acc-append (list (1 2 3 4 5)) (list (5 4 3 2 1)))
;    (1 2 3 4 5 5 4 3 2 1))

(= (acc-length $sequence)
  (accumulate (lambda2 $x $y (+ 1 $y)) 0 $sequence))

;!(assertEqual
;    (acc-length (list (1 6 9 10 0)))
;    5)
; -----------------------End of Exercise 2.33---------------------------

; Exercise 2.34.
;
; Evaluating a polynomial in x at a given value of x can be
; formulated as an accumulation. We evaluate the polynomial
;
; An*x^n + An-1*x^n-1 + ... + A0
;
; using a well-known algorithm called Horner's rule, which structures the computation as
;
; (...(An*x + An-1)*x + ... + A1)*x + A0
;
; In other words, we start with An, multiply by x, add An-1, multiply by x, and so on,
; until we reach A0. Fill in the following template to produce a procedure that evaluates
; a polynomial using Horner's rule. Assume that the coefficients of the polynomial are arranged in a sequence,
; from A0 through An.

(= (horner-eval $x $coefficient-sequence)
    (accumulate (lambda2 $this-coeff $higher-terms (+ $this-coeff (* $x $higher-terms)))
        0
        $coefficient-sequence))

;For example, to compute 1 + 3x + 5x^3 + x^5 at x = 2 you would evaluate
;

;!(assertEqual
;    (horner-eval 2 (list (1 3 0 5 0 1)))
;    79)

; -----------------------End of Exercise 2.34---------------------------


; Exercise 2.35.
;
; Redefine count-leaves from section 2.2.2 as an accumulation:

; (= (count-leaves $t)
;   (accumulate <??> <??> (map <??> <??>)))

(= (count-leaves-acc $t)
  (accumulate +
    0
    (map (lambda1 $x 1) (enumerate-tree $t))))

;!(assertEqual
;    (count-leaves-acc (list (1 (list (2 (list (3 4)))) 5)))
;    (count-leaves (list (1 (list (2 (list (3 4)))) 5))))

; -----------------------End of Exercise 2.35---------------------------


; Exercise 2.36.
;
; The procedure accumulate-n is similar to accumulate except that it takes as
; its third argument a sequence of sequences, which are all assumed to have
; the same number of elements. It applies the designated accumulation procedure
; to combine all the first elements of the sequences, all the second elements
; of the sequences, and so on, and returns a sequence of the results.
;
; For instance, if s is a sequence containing four sequences,
; ((1 2 3) (4 5 6) (7 8 9) (10 11 12)), then the value of (accumulate-n + 0 s)
; should be the sequence (22 26 30).
;
; Fill in the missing expressions in the following definition of accumulate-n:



(= (accumulate-n $op $init $seqs)
  (if (null? (car $seqs))
      ()
      (cons (accumulate $op $init (map (lambda1 $x (car $x)) $seqs))
            (accumulate-n $op $init (map (lambda1 $x (cdr $x)) $seqs)))))

;!(assertEqual
;    (accumulate-n + 0 (list ((1 2 3) (4 5 6) (7 8 9) (10 11 12))))
;    (list (22 26 30)))
; -----------------------End of Exercise 2.36---------------------------


; Exercise 2.37.
;
; Suppose we represent vectors v = (vi) as sequences of numbers, and matrices m = (mij) as sequences
; of vectors (the rows of the matrix). For example, the matrix:
;
; | 1 2 3 4 |
; | 4 5 6 6 |
; | 6 7 8 9 |


; is represented as the sequence ((1 2 3 4) (4 5 6 6) (6 7 8 9)).
; With this representation, we can use sequence operations to concisely express the basic matrix
; and vector operations. These operations (which are described in any book on matrix algebra) are the following:
;
; (dot-product v w) ; returns the sum SUMi(vi*wi)
; (matrix-*-vector m v) ; returns vector t where ti = SUMj(mij*vj)
; (matrix-*-matrix m n) ; returns matrix p where pij = SUMk(mik*nkj)
; (transpose m) ; returns matrix n where nij = mji

; We can define the dot product as

;(= (dot-product $v $w)
;  (accumulate + 0 (map * $v $w))) ; map here is more general function (provided by Scheme) than map in current script.

; Fill in the missing expressions in the following procedures for computing the
; other matrix operations. (The procedure accumulate-n is defined in exercise 2.36.)

; (= (matrix-*-vector $m $v)
;   (map <??> $m))
; (= (transpose $mat)
;   (accumulate-n <??> <??> $mat))
; (= (matrix-*-matrix $m $n)
;   (let $cols (transpose $n)
;     (map <??> $m)))


(= (map2 $proc $items1 $items2)
    (if (or (null? $items1) (null? $items2))
        ()
         (cons ($proc (car $items1) (car $items2)) (map2 $proc (cdr $items1) (cdr $items2)))))

(= (dot-product $v $w)
  (accumulate + 0 (map2 * $v $w)))


(= (vec1) (list (1 3 -5)))
(= (vec2) (list (4 -2 -1)))
(= (mat) ((vec2) (vec1) (vec2)))

;!(assertEqual
;    (dot-product (vec1) (vec2))
;    3)

(= (matrix-*-vector $m $v)
  (map (lambda1 $x (dot-product $x $v)) $m))

;!(assertEqual
;    (matrix-*-vector (mat) (vec1))
;    (3 35 3))

(= (transpose $mat)
  (accumulate-n cons () $mat))

;!(assertEqual
;    (transpose (mat))
;    ((4 1 4) (-2 3 -2) (-1 -5 -1)))

(= (matrix-*-matrix $m $n)
  (let $cols (transpose $n)
    (map (lambda1 $x (matrix-*-vector $cols $x)) $m)))

(= (mat2) ((1 3 5) (2 3 9) (2 4 7)))
(= (vec3) (1 2 3))

; this one takes long to compute
;!(assertEqual
;    (matrix-*-matrix (mat2) (mat))
;    ((27 -3 -21) (47 -13 -26) (40 -6 -29)))


; -----------------------End of Exercise 2.37---------------------------

; Exercise 2.38.
;
; The accumulate procedure is also known as fold-right, because it
; combines the first element of the sequence with the result of combining
; all the elements to the right. There is also a fold-left, which is similar
; to fold-right, except that it combines elements working in the opposite direction:

(: lambda3 (-> Variable Variable Variable Atom (-> $a $b $c $t)))
(= ((lambda3 $var1 $var2 $var3 $body) $val1 $val2 $val3)
    (let (quote ($var1 $var2 $var3)) (quote ($val1 $val2 $val3)) $body))

(= (fold-left $op $initial $sequence)
  (let $iter (lambda3 $result $rest $self
    (if (null? $rest)
        $result
        ($self ($op $result (car $rest))
              (cdr $rest) $self)))
  ($iter $initial $sequence $iter)))

; What are the values of

;!(assertEqual
;    (accumulate / 1 (list (1 2 3)))
;    1.5)

;!(assertEqual
;    (fold-left / 1 (list (1 2 3)))
;    0.16666666666666666)

;!(assertEqual
;    (accumulate list () (list (1 2 3)))
;    (list 1 (list 2 (list 3 ()))))

;!(assertEqual
;    (fold-left list () (list (1 2 3)))
;    (list (list (list () 1) 2) 3))

; It should be noted, that in case of third and fourth asserts in Scheme we will get (1 (2 (3 ()))) and (((() 1) 2) 3)
; accordingly. But since function list in our case takes only one argument and we can't make function with random number
; of arguments yet. So I've left result as it is.

; -----------------------End of Exercise 2.38---------------------------

; Exercise 2.39.
;
; Complete the following definitions of reverse
; (exercise 2.18) in terms of fold-right and fold-left from exercise 2.38:

(= (reverse-a $sequence)
    (accumulate (lambda2 $x $y (append $y ($x))) () $sequence))
(= (reverse-fl $sequence)
    (fold-left (lambda2 $x $y (cons $y $x)) () $sequence))

;!(assertEqual
;    (reverse-a (list (1 2 3)))
;    (list (3 2 1)))

;!(assertEqual
;    (reverse-fl (list (1 2 3)))
;    (list (3 2 1)))


; -----------------------End of Exercise 2.39---------------------------


(= (flatmap $proc $seq)
    (accumulate append () (map $proc $seq)))

(= (cadr $x)
    (car (cdr $x)))

(= (sqr $x) (* $x $x))
(= (inc $x) (+ $x 1))

(= (smallest-divisor $n)
    (find-divisor $n 2))

(= (find-divisor $n $test-divisor)
    (if (> (sqr $test-divisor) $n)
        $n
        (if (divides? $test-divisor $n)
            $test-divisor
            (find-divisor $n (inc $test-divisor)))))

(= (divides? $a $b)
    (== (% $b $a) 0))

(= (prime? $n)
    (== $n (smallest-divisor $n)))

(= (prime-sum? $pair)
    (prime? (+ (car $pair) (cadr $pair))))

(= (make-pair-sum $pair)
    (list ((car $pair) (cadr $pair) (+ (car $pair) (cadr $pair)))))

(= (prime-sum-pairs $n)
    (map make-pair-sum
        (filter prime-sum?
            (flatmap
                (lambda1 $i
                    (map (lambda1 $j (list ($i $j)))
                        (enumerate-interval 1 (- $i 1))))
                    (enumerate-interval 1 $n)))))

;!(assertEqual
;    (prime-sum-pairs 5)
;    (list ((2 1 3) (3 2 5) (4 1 5) (4 3 7) (5 2 7))))

(= (remove $item $sequence)
    (filter (lambda1 $x (not (== $x $item)))
        $sequence))

(= (permutations $s)
    (if (null? $s)
        (())
        (flatmap
            (lambda1 $x
                (map (lambda1 $p (cons $x $p))
                    (permutations (remove $x $s))))
            $s)))

;!(assertEqual
;    (permutations (list (2 1 5)))
;    ((2 1 5) (2 5 1) (1 2 5) (1 5 2) (5 2 1) (5 1 2)))


; Exercise 2.40.
;
; Define a procedure unique-pairs that, given an integer n, generates the
; sequence of pairs (i,j) with 1< j< i<= n. Use unique-pairs to simplify
; the definition of prime-sum-pairs given above.

(= (unique-pairs $n)
    (flatmap
        (lambda1 $i
            (map (lambda1 $j (list ($i $j)))
                (enumerate-interval 1 (- $i 1))))
            (enumerate-interval 1 $n)))

(= (prime-sum-pairs-up $n)
    (map make-pair-sum
        (filter prime-sum?
            (unique-pairs $n))))

;!(assertEqual
;    (prime-sum-pairs-up 5)
;    (list ((2 1 3) (3 2 5) (4 1 5) (4 3 7) (5 2 7))))

; -----------------------End of Exercise 2.40---------------------------


; Exercise 2.41.
;
; Write a procedure to find all ordered triples of distinct positive integers i, j, and k
; less than or equal to a given integer n that sum to a given integer s.

;(= (triples-sum $s)
;
;    )

(= (unique-triples $s)
    (flatmap
        (lambda1 $i
            (map (lambda1 $jk (cons $i $jk))
                (flatmap
                    (lambda1 $j
                        (map (lambda1 $k (list ($k $j)))
                            (enumerate-interval 1 $j)))
                        (enumerate-interval 1 $i))))
        (enumerate-interval 1 $s)))

(= (triples-sum $s)
    (filter
        (lambda1 $triple (== (+ (car $triple) (+ (cadr $triple) (cadr (cdr $triple)))) $s))
        (unique-triples $s)))

;!(assertEqual
;    (triples-sum 3)
;    (list (1 1 1))


; -----------------------End of Exercise 2.41---------------------------

; Exercise 2.42.

; The ``eight-queens puzzle'' asks how to place eight queens on a
; chessboard so that no queen is in check from any other
; (i.e., no two queens are in the collides row, column, or diagonal).
; One way to solve the
; puzzle is to work across the board, placing a queen in each column. Once
; we have placed k - 1 queens, we must place the kth queen in a position
; where it does not check any of the queens already on the board. We can
; formulate this approach recursively: Assume that we have already
; generated the sequence of all possible ways to place k - 1 queens in the
; first k - 1 columns of the board. For each of these ways, generate an
; extended set of positions by placing a queen in each row of the kth
; column. Now filter these, keeping only the positions for which the queen
; in the kth column is safe with respect to the other queens. This
; produces the sequence of all ways to place k queens in the first k
; columns. By continuing this process, we will produce not only one
; solution, but all solutions to the puzzle.

; We implement this solution as a procedure queens, which returns a
; sequence of all solutions to the problem of placing n queens on an n×
; n chessboard. Queens has an internal procedure queen-cols that returns
; the sequence of all ways to place queens in the first k columns of the
; board.

(= (queens $board-size)
  (let $queen-cols (lambda2 $k $self
    (if (== $k 0)
        (list (empty-board))
        (filter
         (lambda1 $positions (safe? $k $positions))
         (flatmap
          (lambda1 $rest-of-queens
            (map (lambda1 $new-row
                   (adjoin-position $new-row $k $rest-of-queens))
                 (enumerate-interval 1 $board-size)))
          ($self (- $k 1) $self)))))
  ($queen-cols $board-size $queen-cols)))

; In this procedure rest-of-queens is a way to place k - 1 queens in the
; first k - 1 columns, and new-row is a proposed row in which to place
; the queen for the kth column. Complete the program by implementing the
; representation for sets of board positions, including the procedure
; adjoin-position, which adjoins a new row-column position to a set of
; positions, and empty-board, which represents an empty set of
; positions. You must also write the procedure safe?, which determines
; for a set of positions, whether the queen in the kth column is safe
; with respect to the others. (Note that we need only check whether the
; new queen is safe -- the other queens are already guaranteed safe with
; respect to each other.)

(= (empty-board)
    ())

(= (adjoin-position $new-row $k $rest-of-queens)
    (append $rest-of-queens (($k $new-row))))

!(adjoin-position 8 5 ((1 2) (2 3) (4 6)))























