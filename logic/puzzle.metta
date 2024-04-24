

;  The bank employs three people: Boris, Ivan, Semyon
;  There are positions of supervisor, cashier, controller
;  The cashier has no siblings and is the shortest in stature.
;  Semyon is married to Boris's sister and is higher than the controller.
;  determine who has what position



(: List (-> $t Type))
(: Nil (List $t))
(: Cons (-> $t (List $t) (List $t)))

; convert (a b c) to (Cons a (Cons b (Cons c Nil)))
(: makelist (-> Atom (List $t)))
(= (makelist $x)
    (if (== () $x) Nil (let $cdr (cdr-atom $x)
                                (Cons (car-atom $x) (makelist $cdr)))
    )
)

; works like ,/2
(: and-seq (-> Atom Atom Bool))
(= (and-seq $first $second)
    (if $first $second False))

; direct translation of prolog code for member/2
(= (memb $X Nil) False)

; member(X, [X|_]).
(= (memb $X (Cons $X $Tail)) True)

;member(X, [_|Tail]) :-
;  member(X, Tail).
(= (memb $X (Cons $H $Tail))
    (memb $X $Tail))


(= (same $X $X) True)
; works like =/2
(= (eq $X $Y)
    (let $C (same $X $Y) (if (== $C True) True False)))

(= (is-variable $x)
    (let $type (get-metatype $x) (if (== $type Variable) True False)))
(= (nth-var-iter $index (Cons $H $Tail) $item $base)
        (nth-var $Tail $item $H $base $index))
(= (nth-var $List $item $item $base $base) True)
(= (nth-var (Cons $H $Tail) $item $prev_head $N $base)
        (let $M (+ $N 1) (nth-var $Tail $item $H $M $base)))


(= (nth $index Nil $item $base) False)
(= (nth $index (Cons $H $Tail) $item $base)
    (if (is-variable $index)
            (nth-var-iter $index (Cons $H $Tail) $item $base)
            (nth-det $index (Cons $H $Tail) $item $base)) )

; works like nth0_det from swipl lists.pl, won't work with $index as variable
(= (nth-det $index Nil $item $base) False)
(= (nth-det $index (Cons $H $Tail) $item $base)
        (if (eq $index $base) (eq $H $item) (nth-det (- $index 1) $Tail $item 1)))


(= (nth1 $index $list $item) (nth $index $list $item 1))

(= (nextto $x $y $list)
    (let $r (nextto-impl $x $y $list)
            (if (== $r True) $r False)))

; nextto(X, Y, [X,Y|_]).
(= (nextto-impl $x $y (Cons $x (Cons $y $Tail))) True)

; nextto(X, Y, [_|Zs]) :-
;      nextto(X, Y, Zs).
(= (nextto-impl $x $y (Cons $head $Tail))
    (nextto-impl $x $y $Tail))




;foo :-
;    Employees=[_ , _ , _],
;%    /Boris has sister/
;    member([boris, _ , has_sister], Employees),
;%    /cashier is the shortest and has no sister/
;    nth1(1, Employees, [ _ , cashier, no_sister]),
;%    /Semyon is higher than controller/
;    nextto([ _ , controller, _], [semyon, _ , _ ], Employees),
;    member([ivan, _ , _ ], Employees),
;    member([_, supervisor, _], Employees),
;    print(Employees), nl.


(= (foo $Employees)
            (and-seq (eq $Employees (makelist ($A $B $C)))
                (and-seq
                    (memb (makelist (boris $Y has_sister)) $Employees)
                    (and-seq
                        (nth1 1 $Employees (makelist ($Z cashier no_sister)))
                        (and-seq
                            (nextto (makelist ($p controller $v))
                                    (makelist (semyon $v1 $v2))
                                    $Employees)
                            (and-seq (memb (makelist (ivan $v3 $v4)) $Employees)
                                    (memb (makelist ($v5 supervisor $v6)) $Employees))
                        )
                    )
                )
            )
)

!(let $r (foo $Employees) (if $r $Employees None))
