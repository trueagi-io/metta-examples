!(import! &self lordOfTheRings_simple.metta)

(: and-seq (-> Atom Atom Bool))
(= (and-seq $first $second)
    (if $first $second False))



(= (_parent $x $y) (unify &self (parent $x $y) True False))
(= (_male $x) (unify &self (male $x) True False))
(= (_female $x) (unify &self (female $x) True False))
(= (_mother $x $y) (and-seq
                            (_parent $x $y)
                            (_female $x)))
(= (_father $x $y) (and-seq
                            (_parent $x $y)
                            (_male $x)))

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



(= (same $X $X) True)
(= (eq $X $Y)
    (let $C (same $X $Y) (if (== $C True) True False)))

(= (_aunt $aunt $y)
    (and-seq
        (_parent $p $y)
        (_sister $aunt $p))
)




!(let $r (_aunt $x "Frodo Gardner") (if $r $x (empty)))
