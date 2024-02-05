; Those three functions are not just wraps for convenient usage of car instead car-atom, but they will help to
; avoid necessity of usage of let in some functions where cons, car and cdr will be used in recursion scheme.

(= (cons $x $y)
    (cons-atom $x $y))

(= (car $x)
    (car-atom $x))

(= (cdr $x)
    (cdr-atom $x))

(= (cadr $x)
    (car (cdr $x)))

(= (cddr $x)
    (cdr (cdr $x)))

(= (caddr $x)
    (car (cddr $x)))

(= (null? $list)
    (== $list ()))

(= (list $varlist)
    (if (null? $varlist)
        ()
        (if (null? (cdr $varlist))
            ((car $varlist))
            (cons (car $varlist) (list (cdr $varlist))))))

(= (one-through-four) (list (1 2 3 4)))

!(assertEqual
    (one-through-four)
    (1 2 3 4))

; In Metta car-atom, cons-atom, cdr-atom are not evaluating their arguments. Because of that you can't use them as car,
; cdr, cons from something like Scheme:

!(assertEqual
    (car-atom (one-through-four))
    one-through-four)

; Usage of "let" can bypass this problem since in this case second argument of let is being evaluated:
!(assertEqual
    (let $list (one-through-four) (car-atom $list))
    1)

; But instead I've wrapped those -atom functions to functions car/cdr/cons respectively which helps to avoid
; over-complication with many "let"s:
!(assertEqual
    (car (one-through-four))
    1)

; Same goes here:
!(assertEqual
    (cdr-atom (one-through-four))
    ())

!(assertEqual
    (cdr (one-through-four))
    (2 3 4))

; Consequent application of car-atom, cdr-atom is also requires some extra "let"s:
!(assertEqual
    (car-atom (cdr-atom (one-through-four)))
    cdr-atom)

!(assertEqual
    (let $list (1 2 3 4)
        (let $tail (cdr-atom $list)
            (car-atom $tail)))
    2)

; But it is simpler to do this:

!(assertEqual
    (car (cdr (1 2 3 4)))
    2)

!(assertEqual
    (cons 10 (one-through-four))
    (10 1 2 3 4))

; Get n-th element from list:
(= (list-ref $items $n)
    (if (null? $items)
        (Error (list-ref $items $n) "Index out of bounds")
        (if (== $n 0)
            (car $items)
            (list-ref (cdr $items) (- $n 1)))))

(= (squares) (list (1 4 9 16 25)))

!(assertEqual
    (list-ref (squares) 3)
    16)

; Get list's length:
(= (length $items)
    (if (null? $items)
        0
        (+ 1 (length (cdr $items)))))

!(assertEqual
    (length (squares))
    5)

(= (odds) (list (1 3 5 7)))

!(assertEqual
    (length (odds))
    4)

; Append one list to the end of another:

(= (append $list1 $list2)
    (if (null? $list1)
        $list2
        (cons (car $list1) (append (cdr $list1) $list2))))

!(assertEqual
    (append (squares) (odds))
    (1 4 9 16 25 1 3 5 7))

!(assertEqual
    (append (odds) (squares))
    (1 3 5 7 1 4 9 16 25))


; Exercise 2.17.
; Define a procedure last-pair that returns the list that contains only the
; last element of a given (nonempty) list:
;
; Example: (last-pair (list 10 12 41 32)) -> 32

(= (last-pair $list)
    (if (null? (cdr $list))
        (car $list)
        (last-pair (cdr $list))))

!(assertEqual
    (last-pair (squares))
    25)

; -----------------------End of Exercise 2.17---------------------------

; Exercise 2.18.
; Define a procedure reverse that takes a list as argument and returns a list of the same elements in reverse order:
;
; Example: (reverse (list 1 4 9 16 25)) -> (25 16 9 4 1)

(= (reverse $list)
    (if (null? (cdr $list))
        ((car $list))
         (append (reverse (cdr $list)) ((car $list)))))

!(assertEqual
    (reverse (squares))
    (25 16 9 4 1))

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

!(assertEqual
    (cc 20 (us-coins))
    9)

!(assertEqual
    (cc 10 (uk-coins))
    50)
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

!(assertEqual
    (same-parity 1 (2 3 4 5 6 7))
    (3 5 7))

!(assertEqual
    (same-parity 2 (2 3 4 5 6 7))
    (2 4 6))
; -----------------------End of Exercise 2.20---------------------------

; Multiply every list's element by same $factor:
(= (scale-list $items $factor)
    (if (null? $items)
        ()
        (cons (* (car $items) $factor) (scale-list (cdr $items) $factor))))

!(assertEqual
    (scale-list (list (1 2 3 4 5)) 10)
    (10 20 30 40 50))

; Apply $proc to every $items element and return list of results:
(= (map $proc $items)
    (if (null? $items)
        ()
         (cons ($proc (car $items)) (map $proc (cdr $items)))))

(= (abs $x) (if (< $x 0) (* $x -1) $x))

!(assertEqual
    (map abs (list (-10 2.5 -11.6 17)))
    (10 2.5 11.6 17))

(: lambda1 (-> Variable Atom (-> $a $t)))
(= ((lambda1 $var $body) $val)
    (let (quote $var) (quote $val) $body) )

(= (square $x)
    (* $x $x))

!(assertEqual
    (map square (list (1 2 3 4)))
    (1 4 9 16))

; Redefinition of scale-list using map:
(= (scale-list-m $items $factor)
    (map (lambda1 $x (* $x $factor)) $items))

!(assertEqual
    (scale-list-m (list (1 2 3 4 5)) 10)
    (10 20 30 40 50))


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

!(assertEqual
    (square-list (1 2 3 4 5))
    (1 4 9 16 25))

!(assertEqual
    (square-list-m (1 2 3 4 5))
    (1 4 9 16 25))

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

; one way to implement for-each is:
;(= (for-each $proc $list)
;    (if (null? $list)
;        ()
;        (let*
;        (
;            (() ($proc (car $list)))
;            (() (for-each $proc (cdr $list)))
;        )
;        ())))

; This one was provided by Vitaly Bogdanov. And this implementation checks if there was an error during $proc call.
; This is helpful in exercise 2.49 when I'm using for-each to call python function.
(= (for-each $proc $list)
    (if (null? $list)
        ()
        (let $res ($proc (car $list))
            (unify $res (Error $_atom $_msg)
            $res
            (for-each $proc (cdr $list))))
        ))

; prints list
!(assertEqual
    (for-each println! (list (57 321 88)))
    ())
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

!(assertEqual
    (x)
    ((1 2) 3 4))

!(assertEqual
    (length (x))
    3)

!(assertEqual
    (count-leaves (x))
    4)

!(assertEqual
    (length (list ((x) (x))))
    2)

!(assertEqual
    (count-leaves (list ((x) (x))))
    8)


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

!(assertEqual
    (deep-reverse ((1 2) (3 4)))
    ((4 3) (2 1)))

!(assertEqual
    (deep-reverse ((1 2 3) (4 5 6) (7 8 9)))
    ((9 8 7) (6 5 4) (3 2 1)))

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

!(assertEqual
    (fringe (list ((list (1 2)) (list (3 4)))))
    (1 2 3 4))

!(assertEqual
    (fringe (list ((list ((list (1 2)) (list (3 4)))) (list ((list (1 2)) (list (3 4)))))))
    (1 2 3 4 1 2 3 4))

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

!(assertEqual
    (total-weight (more-complex-mobile))
    100)


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

!(assertEqual
    (isbalanced? (simple-mobile))
    True)

!(assertEqual
    (isbalanced? (more-complex-mobile))
    False)
; -----------------------End of Exercise 2.29---------------------------

; Same as scale-list, but for trees
(= (scale-tree $tree $factor)
    (if (null? $tree)
        ()
        (if (== (get-type $tree) Number)
            (* $tree $factor)
            (cons (scale-tree (car $tree) $factor)
                    (scale-tree (cdr $tree) $factor)))))

!(assertEqual
    (scale-tree (list (1 (list (2 (list (3 4)) 5)) (list (6 7)))) 10)
    (10 (20 (30 40) 50) (60 70)))

; Scale tree but using map for definition
(= (scale-tree-m $tree $factor)
    (map (lambda1 $sub-tree
        (if (== (get-type $sub-tree) Number)
            (* $sub-tree $factor)
            (scale-tree-m $sub-tree $factor)))
            $tree))

!(assertEqual
    (scale-tree-m (list (1 (list (2 (list (3 4)) 5)) (list (6 7)))) 10)
    (10 (20 (30 40) 50) (60 70)))


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

!(assertEqual
    (square-tree (list (1 (list (2 (list (3 4)) 5)) (list (6 7)))))
    (1 (4 (9 16) 25) (36 49)))


(= (square-tree-m $tree)
    (map (lambda1 $sub-tree
        (if (== (get-type $sub-tree) Number)
            (* $sub-tree $sub-tree)
            (square-tree-m $sub-tree)))
            $tree))

!(assertEqual
    (square-tree-m (list (1 (list (2 (list (3 4)) 5)) (list (6 7)))))
    (1 (4 (9 16) 25) (36 49)))
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

!(assertEqual
    (square-tree-tm (list (1 (list (2 (list (3 4)) 5)) (list (6 7)))))
    (1 (4 (9 16) 25) (36 49)))
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


!(assertEqual
    (subsets (1 2 3))
    (() (3) (2) (3 2) (1) (3 1) (2 1) (3 2 1)))

; -----------------------End of Exercise 2.32---------------------------


; Functions in terms of signal processing. Kind of.

; Filter the $sequence using $predicate:
(= (filter $predicate $sequence)
    (if (null? $sequence)
        ()
        (let $car (car $sequence)
            (let $recrescdr (filter $predicate (cdr $sequence))
                (if ($predicate $car)
                    (cons $car $recrescdr)
                    $recrescdr)))))

(= (odd? $x) (== (% $x 2) 1))

!(assertEqual
    (filter odd? (1 2 3 4 5))
    (1 3 5))

; Function which accumulate items from $sequence using procedure $op and $initial as start of accumulation:
(= (accumulate $op $initial $sequence)
    (if (null? $sequence)
        $initial
        ($op (car $sequence) (accumulate $op $initial (cdr $sequence)))))

!(assertEqual
    (accumulate + 0 (list (1 2 3 4 5)))
    15)

!(assertEqual
    (accumulate * 1 (list (1 2 3 4 5)))
    120)

!(assertEqual
    (accumulate cons () (list (1 2 3 4 5)))
    (1 2 3 4 5))

; Return list with arranged numbers from $low to $high:
(= (enumerate-interval $low $high)
    (if (> $low $high)
        ()
        (cons $low (enumerate-interval (+ $low 1) $high))))

!(assertEqual
    (enumerate-interval 2 7)
    (2 3 4 5 6 7))

; Returns lists of the $tree:
(= (enumerate-tree $tree)
    (if (null? $tree)
        ()
        (if (== (get-type $tree) Number)
            (list ($tree))
            (append (enumerate-tree (car $tree)) (enumerate-tree (cdr $tree))))))

!(assertEqual
    (enumerate-tree (list (1 (list (2 (list (3 4)))) 5)))
    (1 2 3 4 5))

; Definition of some functions using accumulate and map. For example function which returns sum of squares of odd numbers
; from $tree:
(= (sum-odd-squares $tree)
    (accumulate +
        0
        (map square
            (filter odd?
                (enumerate-tree $tree)))))

!(assertEqual
    (sum-odd-squares (list (1 (list (2 (list (3 4)))) 5)))
    35)

; Just regular Fibonacci numbers generator:
(= (fib $n)
    (if (== $n 0)
        0
        (if (== $n 1)
            1
            (+ (fib (- $n 1)) (fib (- $n 2))))))

(= (even? $x)
    (== (% $x 2) 0))

; Function which outputs only even numbers from Fibonacci sequence:
(= (even-fibs $n)
    (accumulate cons
        ()
        (filter even?
            (map fib
                (enumerate-interval 0 $n)))))

!(assertEqual
    (even-fibs 8)
    (0 2 8))

; Returns list of squared Fibonacci numbers:
(= (list-fib-squares $n)
    (accumulate cons
    ()
    (map square
        (map fib
            (enumerate-interval 0 $n)))))

!(assertEqual
    (list-fib-squares 7)
    (0 1 1 4 9 25 64 169))


; Function which returns product of squares of odd numbers from $sequence:
(= (product-of-squares-of-odd-elements $sequence)
    (accumulate *
        1
        (map square
            (filter odd? $sequence))))

!(assertEqual
    (product-of-squares-of-odd-elements (list (1 2 3 4 5)))
    225)


; Exercise 2.33.
;
; Fill in the missing expressions to complete the following definitions of some
; basic list-manipulation operations as accumulations:

(: lambda2 (-> Variable Variable Atom (-> $a $b $t)))
(= ((lambda2 $var1 $var2 $body) $val1 $val2)
    (let (quote ($var1 $var2)) (quote ($val1 $val2)) $body))

(= (acc-map $p $sequence)
  (accumulate (lambda2 $x $y (cons ($p $x) $y)) () $sequence))

!(assertEqual
    (acc-map square (list (1 2 3 4 5)))
    (1 4 9 16 25))

(= (acc-append $seq1 $seq2)
  (accumulate cons $seq2 $seq1))

!(assertEqual
    (acc-append (list (1 2 3 4 5)) (list (5 4 3 2 1)))
    (1 2 3 4 5 5 4 3 2 1))

(= (acc-length $sequence)
  (accumulate (lambda2 $x $y (+ 1 $y)) 0 $sequence))

!(assertEqual
    (acc-length (list (1 6 9 10 0)))
    5)
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

!(assertEqual
    (horner-eval 2 (list (1 3 0 5 0 1)))
    79)

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

!(assertEqual
    (count-leaves-acc (list (1 (list (2 (list (3 4)))) 5)))
    (count-leaves (list (1 (list (2 (list (3 4)))) 5))))

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

!(assertEqual
    (accumulate-n + 0 (list ((1 2 3) (4 5 6) (7 8 9) (10 11 12))))
    (list (22 26 30)))
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

; In Scheme there is a map from standard library which takes several sequences. In case of Metta I've wrote map2 which
; takes two $items:
(= (map2 $proc $items1 $items2)
    (if (or (null? $items1) (null? $items2))
        ()
         (cons ($proc (car $items1) (car $items2)) (map2 $proc (cdr $items1) (cdr $items2)))))

(= (dot-product $v $w)
  (accumulate + 0 (map2 * $v $w)))

(= (vec1) (list (1 3 -5)))
(= (vec2) (list (4 -2 -1)))
(= (mat) ((vec2) (vec1) (vec2)))

!(assertEqual
    (dot-product (vec1) (vec2))
    3)

(= (matrix-*-vector $m $v)
  (map (lambda1 $x (dot-product $x $v)) $m))

!(assertEqual
    (matrix-*-vector (mat) (vec1))
    (3 35 3))

(= (transpose $mat)
  (accumulate-n cons () $mat))

!(assertEqual
    (transpose (mat))
    ((4 1 4) (-2 3 -2) (-1 -5 -1)))

(= (matrix-*-matrix $m $n)
  (let $cols (transpose $n)
    (map (lambda1 $x (matrix-*-vector $cols $x)) $m)))

(= (mat2) ((1 3 5) (2 3 9) (2 4 7)))
(= (vec3) (1 2 3))

; this one takes long to compute
!(assertEqual
    (matrix-*-matrix (mat2) (mat))
    ((27 -3 -21) (47 -13 -26) (40 -6 -29)))


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

!(assertEqual
    (accumulate / 1 (list (1 2 3)))
    1.5)

!(assertEqual
    (fold-left / 1 (list (1 2 3)))
    0.16666666666666666)

!(assertEqual
    (accumulate list () (list (1 2 3)))
    (list 1 (list 2 (list 3 ()))))

!(assertEqual
    (fold-left list () (list (1 2 3)))
    (list (list (list () 1) 2) 3))

; It should be noted, that in case of third and fourth asserts in Scheme we will get (1 (2 (3 ()))) and (((() 1) 2) 3)
; accordingly. But since function list in our case takes only one argument and we can't make function with random number
; of arguments yet I've left result as it is. Logically it is correct anyway.

; -----------------------End of Exercise 2.38---------------------------

; Exercise 2.39.
;
; Complete the following definitions of reverse
; (exercise 2.18) in terms of fold-right and fold-left from exercise 2.38:

(= (reverse-a $sequence)
    (accumulate (lambda2 $x $y (append $y ($x))) () $sequence))
(= (reverse-fl $sequence)
    (fold-left (lambda2 $x $y (cons $y $x)) () $sequence))

!(assertEqual
    (reverse-a (list (1 2 3)))
    (list (3 2 1)))

!(assertEqual
    (reverse-fl (list (1 2 3)))
    (list (3 2 1)))


; -----------------------End of Exercise 2.39---------------------------


(= (flatmap $proc $seq)
    (accumulate append () (map $proc $seq)))

; Prime? from the previous chapters.

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

; Function returns list of all pairs from 1 to $n which sum is odd number. Also function returns sum of elements for
; every pair.

(= (prime-sum-pairs $n)
    (map make-pair-sum
        (filter prime-sum?
            (flatmap
                (lambda1 $i
                    (map (lambda1 $j (list ($i $j)))
                        (enumerate-interval 1 (- $i 1))))
                    (enumerate-interval 1 $n)))))

; Pair (2 1) sum - 3. Result (2 1 3). And so on.
!(assertEqual
    (prime-sum-pairs 5)
    (list ((2 1 3) (3 2 5) (4 1 5) (4 3 7) (5 2 7))))


; Remove item from $sequence:
(= (remove $item $sequence)
    (filter (lambda1 $x (not (== $x $item)))
        $sequence))

; Returns all permutations for input $s'equence:
(= (permutations $s)
    (if (null? $s)
        (())
        (flatmap
            (lambda1 $x
                (map (lambda1 $p (cons $x $p))
                    (permutations (remove $x $s))))
            $s)))

!(assertEqual
    (permutations (list (2 1 5)))
    ((2 1 5) (2 5 1) (1 2 5) (1 5 2) (5 2 1) (5 1 2)))


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

!(assertEqual
    (prime-sum-pairs-up 5)
    (list ((2 1 3) (3 2 5) (4 1 5) (4 3 7) (5 2 7))))

; -----------------------End of Exercise 2.40---------------------------


; Exercise 2.41.
;
; Write a procedure to find all ordered triples of distinct positive integers i, j, and k
; less than or equal to a given integer n that sum to a given integer s.

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

; Since this takes long to evaluate this one I've put 3 here. And only one triple's sum equals to 3 - (1 1 1).
!(assertEqual
    (triples-sum 3)
    (list ((1 1 1))))
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
        ((empty-board))
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

(= (select-k $k $positions)
    (if (== $k 1)
        (car $positions)
        (select-k (- $k 1) (cdr $positions))))

(= (row-safe? $k-col $k-row $positions)
    (null? (filter
                (lambda1 $x (and (== (cdr $x) (list ($k-row))) (not (== (car $x) $k-col))))
                $positions)))

(= (col-safe? $k-row $positions)
    (let $iter (lambda3 $cur $pos $self
        (if (null? $pos)
            True
            (if (or (== (cdr (car $pos)) ((- $k-row $cur)))
                    (== (cdr (car $pos)) ((+ $k-row $cur))))
                False
                ($self (+ $cur 1) (cdr $pos) $self))))
    ($iter 1 (cdr (reverse $positions)) $iter)))

(= (safe? $k $positions)
    (let ($k-col $k-row) (select-k $k $positions)
        (and (col-safe? $k-row $positions) (row-safe? $k-col $k-row $positions))))


;it works but I wasn't able to wait till it finishes calculations for (queens 4), though I've waited for ~12 hours.
;!(queens 4)

;Since (queens 4) is tough enough for current state of metta interpreter I've tried to run first two iterations to see
;if everything is fine. Below is the second iteration and it gives right result:
;(((1 1) (2 3)) ((1 1) (2 4)) ((1 2) (2 4)) ((1 3) (2 1)) ((1 4) (2 1)) ((1 4) (2 2)))
;but it takes ~1.5 hours to compute so I'll leave it commented out.

;!(assertEqual
;    (filter
;     (lambda1 $positions (safe? 2 $positions))
;     (flatmap
;      (lambda1 $rest-of-queens
;        (map (lambda1 $new-row
;               (adjoin-position $new-row 2 $rest-of-queens))
;             (enumerate-interval 1 4)))
;      (((1 1)) ((1 2)) ((1 3)) ((1 4)))))
;    (((1 1) (2 3)) ((1 1) (2 4)) ((1 2) (2 4)) ((1 3) (2 1)) ((1 4) (2 1)) ((1 4) (2 2))))

; -----------------------End of Exercise 2.42---------------------------

; Next part of chapter 2_2 is about drawing. For that reason we need a function to draw line. I've made a py-script
; that uses python's turtle to draw and I'm calling it using "drawline!". Every time drawing is finished we need to call
; "finishdraw!" or every exercise will draw its result on the previous drawings. I've shuffled exercise order in this
; section a bit since some exercises uses results of not implemented yet functions
; (since they are implemented during further exercises).

!(extend-py! draw_line)

; Exercise 2.46.  A two-dimensional vector v running from the origin to
; a point can be represented as a pair consisting of an x-coordinate and
; a y-coordinate. Implement a data abstraction for vectors by giving a
; constructor make-vect and corresponding selectors xcor-vect and
; ycor-vect. In terms of your selectors and constructor, implement
; procedures add-vect, sub-vect, and scale-vect that perform the
; operations vector addition, vector subtraction, and multiplying a
; vector by a scalar:
;
; (x1, y1) + (x2, y2) = (x1 + x2, y1 + y2)
; (x1, y1) - (x2, y2) = (x1 - x2, y1 - y2)
; s*(x, y) = (s*x, s*y)

(= (make-pair $x $y) ($x . $y))

(= (first-pair $x) (let ($a . $b) $x $a))
(= (second-pair $x) (let ($a . $b) $x $b))

(= (make-vect $x $y) (make-pair $x $y))

(= (xcor-vect $vec) (first-pair $vec))
(= (ycor-vect $vec) (second-pair $vec))

(= (add-vect $vec1 $vec2)
  (make-vect (+ (xcor-vect $vec1) (xcor-vect $vec2)) (+ (ycor-vect $vec1) (ycor-vect $vec2))))

(= (sub-vect $vec1 $vec2)
  (make-vect (- (xcor-vect $vec1) (xcor-vect $vec2)) (- (ycor-vect $vec1) (ycor-vect $vec2))))

(= (scale-vect $scale $vec)
  (make-vect (* (xcor-vect $vec) $scale) (* (ycor-vect $vec) $scale)))

(= (vect1) (make-vect 5 2))

(= (vect2) (make-vect 1 3))

; -----------------------End of Exercise 2.46---------------------------

; Exercise 2.47.  Here are two possible constructors for frames:

(= (make-frame $origin $edge1 $edge2)
    (list ($origin $edge1 $edge2)))

(= (make-frame_2 $origin $edge1 $edge2)
    (cons $origin (cons $edge1 $edge2)))

; For each constructor supply the appropriate selectors to produce an
; implementation for frames.

(= (frame1) (make-frame (vect1) (vect2) (add-vect (vect1) (vect2))))
(= (frame2) (make-frame_2 (vect1) (vect2) (add-vect (vect1) (vect2))))

(= (origin-frame $frame)
  (car $frame))

(= (edge1-frame $frame)
  (cadr $frame))

(= (edge2-frame $frame)
  (caddr $frame))

;the only difference in selector function is edge2-frame for these two cases of make-frame
(= (edge2-frame_2 $frame)
  (cddr $frame))

!(assertEqual
    (origin-frame (frame1))
    (5 . 2))

!(assertEqual
    (origin-frame (frame2))
    (5 . 2))

!(assertEqual
    (edge1-frame (frame1))
    (1 . 3))

!(assertEqual
    (edge1-frame (frame2))
    (1 . 3))

!(assertEqual
    (edge2-frame (frame1))
    (6 . 5))

!(assertEqual
    (edge2-frame_2 (frame2))
    (6 . 5))

; -----------------------End of Exercise 2.47---------------------------

; Exercise 2.48.  A directed line segment in the plane can be
; represented as a pair of vectors -- the vector running from the origin
; to the start-point of the segment, and the vector running from the
; origin to the end-point of the segment. Use your vector representation
; from exercise 2.46 to define a representation for segments with a
; constructor make-segment and selectors start-segment and end-segment.

(= (make-segment $vec1 $vec2)
  (make-pair $vec1 $vec2))

(= (start-segment $seg)
  (first-pair $seg))

(= (end-segment $seg)
  (second-pair $seg))

; -----------------------End of Exercise 2.48---------------------------

; Every painter requires frame to draw its content to. So I've defined (baseframe) for this purpose.
(= (baseframe) (make-frame (make-vect 0 0) (make-vect 1 0) (make-vect 0 1)))

; Returns function which maps input vector to a new basis ($frame):
(= (frame-coord-map $frame)
  (lambda1 $v
    (add-vect
     (origin-frame $frame)
     (add-vect (scale-vect (xcor-vect $v)
                           (edge1-frame $frame))
               (scale-vect (ycor-vect $v)
                           (edge2-frame $frame))))))

; Using drawline! returns function which draws segment using $frame as basis:
(= (segments_painter $segment-list)
  (lambda1 $frame
    (for-each
     (lambda1 $segment
       (drawline!
        ((frame-coord-map $frame) (start-segment $segment))
        ((frame-coord-map $frame) (end-segment $segment))))
     $segment-list)))

; Exercise 2.49.  Use segments->painter to define the following
; primitive painters:

; a.  The painter that draws the outline of the designated frame.

; b.  The painter that draws an 'X' by connecting opposite corners of the frame.

; c.  The painter that draws a diamond shape by connecting the midpoints of the sides of the frame.

; d.  The wave painter.

; a
(= (rect-paint)
    (segments_painter (list ((make-segment (make-vect 0 0) (make-vect 1 0))
                              (make-segment (make-vect 1 0) (make-vect 1 1))
                              (make-segment (make-vect 1 1) (make-vect 0 1))
                              (make-segment (make-vect 0 1) (make-vect 0 0))))))

;b
(= (x-paint)
    (segments_painter
        (list
          ((make-segment (make-vect 0 0) (make-vect 1 1))
          (make-segment (make-vect 0 1) (make-vect 1 0))))))

;c
(= (rhomb-paint)
  (segments_painter
    (list
      ((make-segment (make-vect 0.5 0) (make-vect 1 0.5))
      (make-segment (make-vect 1 0.5) (make-vect 0.5 1))
      (make-segment (make-vect 0.5 1) (make-vect 0 0.5))
      (make-segment (make-vect 0 0.5) (make-vect 0.5 0))))))

; d is quite huge and requires too many lines and points. I'll pass this part. But for further exercises we need
; something not symmetrical. I've decided to make rectangular trapezoid

(= (rtrap-paint)
    (segments_painter (list ((make-segment (make-vect 0 0) (make-vect 0 1))
                              (make-segment (make-vect 0 1) (make-vect 0.6 0.75))
                              (make-segment (make-vect 0.6 0.75) (make-vect 0.6 0))
                              (make-segment (make-vect 0.6 0) (make-vect 0 0))))))



;those commands will draw rhomb, x and rectangle.
;(finishdraw!) is needed to remove previous paintings and close the window.

; Usage. Painting using segment_painter is quite long. So I won't uncomment those lines and leave them for possible
; readers to play around and launch them.

;!((rhomb-paint) (baseframe))
;!(finishdraw!)


; -----------------------End of Exercise 2.49---------------------------

; Using input $painter returns new painter which paints inside new basis:
(= (transform-painter $painter $origin $corner1 $corner2)
  (lambda1 $frame
    (let $m (frame-coord-map $frame)
      (let $new-origin ($m $origin)
        ($painter
         (make-frame $new-origin
                     (sub-vect ($m $corner1) $new-origin)
                     (sub-vect ($m $corner2) $new-origin)))))))

; Flip $painter by vertical axis.
(= (flip-vert $painter)
  (transform-painter $painter
     (make-vect 0.0 1.0)
     (make-vect 1.0 1.0)
     (make-vect 0.0 0.0)))

; Returns painter which draws its content in right top corner:
(= (shrink-to-upper-right $painter)
  (transform-painter $painter
                     (make-vect 0.5 0.5)
                     (make-vect 1.0 0.5)
                     (make-vect 0.5 1.0)))

; Rotates $painter by 90 degrees:
(= (rotate90 $painter)
  (transform-painter $painter
                     (make-vect 1.0 0.0)
                     (make-vect 1.0 1.0)
                     (make-vect 0.0 0.0)))

; Squashes painter so it draws smaller picture:
(= (squash-inwards $painter)
  (transform-painter $painter
                     (make-vect 0.0 0.0)
                     (make-vect 0.65 0.35)
                     (make-vect 0.35 0.65)))

; Usage example:
;!((flip-vert (rtrap-paint)) (baseframe))
;!(finishdraw!)

; Return combined painter which will draw $painter1 on the left and $painter2 on the right:
(= (beside $painter1 $painter2)
  (let $split-point (make-vect 0.5 0.0)
    (let* (($paint-left
           (transform-painter $painter1
                              (make-vect 0.0 0.0)
                              $split-point
                              (make-vect 0.0 1.0)))
          ($paint-right
           (transform-painter $painter2
                              $split-point
                              (make-vect 1.0 0.0)
                              (make-vect 0.5 1.0))))
      (lambda1 $frame
        (let* ((() ($paint-left $frame))
               (() ($paint-right $frame)))
               ())))))

; Will draw trapezoid (on the left) and 'X' (on the right):
;!((beside (rtrap-paint) (x-paint)) (baseframe))
;!(finishdraw!)


; Exercise 2.50.
;
; Define the transformation flip-horiz, which flips
; painters horizontally, and transformations that rotate painters
; counterclockwise by 180 degrees and 270 degrees.


(= (flip-horiz $painter)
  (transform-painter $painter
     (make-vect 1.0 0.0)
     (make-vect 0.0 0.0)
     (make-vect 1.0 1.0)))

(= (rotate180 $painter)
  (transform-painter $painter
                     (make-vect 1 1)
                     (make-vect 0 1)
                     (make-vect 1 0)))

(= (rotate270 $painter)
  (transform-painter $painter
                     (make-vect 0 1)
                     (make-vect 0 0)
                     (make-vect 1 1)))


; -----------------------End of Exercise 2.50---------------------------

; Exercise 2.51.
;
; Define the below operation for painters. Below takes
; two painters as arguments. The resulting painter, given a frame, draws
; with the first painter in the bottom of the frame and with the second
; painter in the top. Define below in two different ways -- first by
; writing a procedure that is analogous to the beside procedure given
; above, and again in terms of beside and suitable rotation operations
; (from exercise 2.50).

(= (below $painter1 $painter2)
  (let $split-point (make-vect 0 0.5)
    (let* (($paint-top
           (transform-painter $painter1
                              $split-point
                              (make-vect 1 0.5)
                              (make-vect 0 1)))
          ($paint-bottom
           (transform-painter $painter2
                              (make-vect 0 0)
                              (make-vect 1 0)
                              $split-point)))
      (lambda1 $frame
        (let* ((() ($paint-top $frame))
               (() ($paint-bottom $frame)))
               ())))))

(= (below-r $painter1 $painter2)
    (rotate90 (beside (rotate270 $painter2) (rotate270 $painter1))))

; Usage
;!((below-r (rtrap-paint) (x-paint)) (baseframe))
;!(finishdraw!)

; -----------------------End of Exercise 2.51---------------------------


; And now I'm returning to the start of the drawing section since now we have everything we need to run chapter's and
; exercises' code.

; Define new painters using current painter and transform function:
(= (rtrap2) (beside (rtrap-paint) (flip-vert (rtrap-paint))))
(= (rtrap4) (let $rt2 (rtrap2) (below $rt2 $rt2)))
(= (x-paint2) (below (x-paint) (flip-vert (x-paint))))
(= (x-paint4) (let $x2 (x-paint2) (below $x2 $x2)))

; Usage is the same as before:
;!((x-paint2) (baseframe))
;!(finishdraw!)

(= (flipped-pairs $painter)
    (let $painter2 (beside $painter (flip-vert $painter))
        (below $painter2 $painter2)))

(= (rtrap4-f) (flipped-pairs (rtrap-paint)))

(= (right-split $painter $n)
  (if (= n 0)
      painter
      (let ((smaller (right-split painter (- n 1))))
        (beside painter (below smaller smaller)))))

(= (corner-split $painter $n)
  (if (= $n 0)
      $painter
      (let* (($up (up-split $painter (- $n 1)))
            ($right (right-split $painter (- $n 1))))
        (let* (($top-left (beside $up $up))
              ($bottom-right (below $right $right))
              ($corner (corner-split $painter (- $n 1))))
          (beside (below $painter $top-left)
                  (below $bottom-right $corner))))))

(= (square-limit $painter $n)
  (let $quarter (corner-split $painter $n)
    (let $half (beside (flip-horiz $quarter) $quarter)
      (below (flip-vert $half) $half))))


; Exercise 2.44.  Define the procedure up-split used by corner-split. It
; is similar to right-split, except that it switches the roles of below
; and beside.

(= (up-split $painter $n)
  (if (== $n 0)
      $painter
      (let $smaller (up-split $painter (- $n 1))
        (below $painter (beside $smaller $smaller)))))

; -----------------------End of Exercise 2.44---------------------------

; Returns $painter which will draw four differently transformed painters in the square.
(= (square-of-four $tl $tr $bl $br)
  (lambda1 $painter
    (let* (($top (beside ($tl $painter) ($tr $painter)))
          ($bottom (beside ($bl $painter) ($br $painter))))
      (below $bottom $top))))

; using square-of-four we could redefine flipped-pairs and square-limit

(= (identity $x) $x)

(= (flipped-pairs-sof $painter)
  (let $combine4 (square-of-four identity flip-vert
                                  identity flip-vert)
    ($combine4 $painter)))

(= (square-limit-sof $painter $n)
  (let $combine4 (square-of-four flip-horiz identity
                                  rotate180 flip-vert)
    ($combine4 (corner-split $painter $n))))


; Exercise 2.45.  Right-split and up-split can be expressed as instances
; of a general splitting operation. Define a procedure split with the
; property that evaluating

;(= (right-split) (split beside below))
;(= (up-split) (split below beside))

; produces procedures right-split and up-split with the same behaviors
; as the ones already defined.

(= (split $func1 $func2)
  (lambda1 $painter
    ($func1 $painter ($func2 $painter $painter))))

(= (right-split-s) (split beside below))
(= (up-split-s) (split below beside))

; -----------------------End of Exercise 2.45---------------------------