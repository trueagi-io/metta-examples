; !(import! &self toy_simple)
; !(import! &self royal92_simple)
!(import! &self adameve_simple)
; !(import! &self lordOfTheRings_simple)
; !(import! &self simpsons_simple)


; UTILITY
(: and-seq (-> Atom Atom Bool))
(= (and-seq $first $second)
    (if $first $second False))
(= (same $X $X) True)
(= (eq $X $Y)
    (let $C (same $X $Y) (if (== $C True) True False)))

; GENERATE EXTRA INDICES
!(match &self (parent $x $y) (child $y $x))

!(match &self (male $x) (add-atom &self (person $x)))
!(match &self (female $x) (add-atom &self (person $x)))

; GET ALL PARENTS
(= (_parent $x $y) (unify &self (parent $x $y) True False))
!(match &self (person $p) (let $r (_parent $x $p) (if $r (Parent $p $x) (empty))))

; GET ALL MOTHERS
(= (_male $x) (unify &self (male $x) True False))
(= (_mother $x $y) (and-seq
                            (_parent $x $y)
                            (_female $x)))
!(match &self (person $p) (let $r (_mother $x $p) (if $r (Mother $p $x) (empty))))

; GET ALL SISTERS
(= (_sister $x $y)
    (and-seq
            (_female $x)
            (and-seq
                (_parent $p $y)
                (and-seq (_parent $p $x)
                         (not (eq $x $y))
                )
            )
    )
)
!(match &self (person $p) (let $r (_sister $x $p) (if $r (Sister $p $x) (empty))))

; GET ALL AUNTS
(= (_aunt $aunt $y)
    (and-seq
        (_parent $p $y)
        (_sister $aunt $p))
)
!(match &self (person $p) (let $r (_aunt $x $p) (if $r (Aunt $p $x) (empty))))

; GET ALL PREDECESSORS
(= (_predecessor $x $z) (_parent $x $z))
(= (_predecessor $x $z) (and-seq (_parent $p $z)
                                 (_predecessor $x $p)))
!(match &self (person $p) (let $r (_predecessor $x $p) (if $r (Pred $p $x) (empty))))
