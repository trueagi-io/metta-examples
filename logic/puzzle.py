from hyperon import *

from hyperon import MeTTa, E


"""
The bank employs three people: Boris, Ivan, Semyon
There are positions of supervisor, cashier, controller
The cashier has no siblings and is the shortest in stature.
Semyon is married to Boris's sister and is higher than the controller.
determine who has what position
"""

def test():
        program = '''
                (: quote (-> Atom Atom))

                ; convert (a b c) to (Cons a (Cons b (Cons c Nil)))
                (: makelist (-> Atom Atom))
                (= (makelist $x)
                    (if (== () $x) Nil (let $cdr (cdr-atom $x)
                                                (Cons (car-atom $x) (makelist $cdr)))
                    )
                )

                ; works like ,/2
                (: and2 (-> Atom Atom Bool))
                (= (and2 $first $second)
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

                ; suggested by Patrick Hammer
                (= (variable $x)
                   (case (let $x 1 True)
                         (($1 (case (let $x 2 True) (($2 $2) (%void% False))))
                          (%void% False))))

                (= (nth-var-top $index (Cons $H $Tail) $item $base)
                     (nth-var $Tail $item $H $base $index))
                (= (nth-var $List $item $item $base $base) True)
                (= (nth-var (Cons $H $Tail) $item $prev_head $N $base)
                     (let $M (+ $N 1) (nth-var $Tail $item $H $M $base)))

                (= (nth $index Nil $item $base) False)
                (= (nth $index (Cons $H $Tail) $item $base)
                   (if (variable $index)  (nth-var-top $index (Cons $H $Tail) $item $base) (nth-det $index (Cons
                   $H $Tail) $item $base)))

                ; works like nth0_det from swipl lists.pl, won't work with $index as variable
                (= (nth-det $index (Cons $H $Tail) $item $base)
                         (if (eq $index $base) (eq $H $item) (nth1 (- $index 1) $Tail $item)))

                (= (nth1 $index $list $item) (nth $index $list $item 1))
                    index 1) (eq $H $item) (nth1 (- $index 1) $Tail $item)))

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
                ;    Employers=[_ , _ , _],
                ;%    /Boris has sister/
                ;    member([boris, _ , has_sister], Employers),
                ;%    /cashier is the shortest and has no sister/
                ;    nth1(1, Employers, [ _ , cashier, no_sister]),
                ;%    /Semyon is higher than controller/
                ;    nextto([ _ , controller, _], [semyon, _ , _ ], Employers),
                ;    member([ivan, _ , _ ], Employers),
                ;    member([_, supervisor, _], Employers),
                ;    print(Employers), nl.


                (= (foo $Employers)
                            (and2 (eq $Employers (makelist ($A $B $C)))
                                (and2
                                    (memb (makelist (boris $Y has_sister)) $Employers)
                                    (and2
                                        (nth1 1 $Employers (makelist ($Z cashier no_sister)))
                                        (and2
                                            (nextto (makelist ($p controller $v))
                                                    (makelist (semyon $v1 $v2))
                                                    $Employers)
                                            (and2 (memb (makelist (ivan $v3 $v4)) $Employers)
                                                    (memb (makelist ($v5 supervisor $v6)) $Employers))
                                        )
                                    )
                                )
                            )
                )


                !(let $r (foo $Employers) (if $r $Employers None))
        '''
        runner = MeTTa()
        result = runner.run(program)
        print(result)
test()
