(= (I $x) $x)
(= ((K $x) $y) $x)
(= (K $x $y) $x)
(= (S $x $y $z) ($x $z ($y $z)))

(= (B $x $y $z) ($x ($y $z)))
(= (C $x $y $z) ($x $y $z))
(= (W $x $y) ($x $y $y))

(= U (S I I))

(= Y (S (K (S I I)) (S (S (K S) K) (K (S I I)))))

(= Y (B U (C B U)))


; want to check equivalence between SKI and BCKW systems
!(assertEqual
  (S (K S) K x y z)
   (B x y z))

!(assertEqual
    (S (S (K (S (K S) K)) S) (K K) x y z)
    (C x y z))

!(assertEqual
    (S S (S K) x y z)
    (W x y z))

; How to implement factorial throughout Y-combinator and compare two definitions of it???
;(= (fact $x) (Y ( (lambda f)
;		  (lambda $x) (if (> $x 0) (* $x (f (- x 1))) 1))))

; to return function as an output of a function we can do stuff like that:
(: Lambda (-> $a $t))
(: lambda (-> Variable Atom Lambda))
(= ((lambda $var $body) $val)
    (let $var $val $body) )

(= (para $x $y) (+ ( $x $x) ( $y $y)))

(= (parax $y) (let $lam (lambda $x (para $x $y)) $lam))

; this work
!((parax 5) 6)

; but this one doesn't:

(= (fact $x)
    (Y ( let $nameless
        (lambda $f (let $nameless2
            (lambda $x (if (> $x 0)
                            (* $x ($f (- $x 1)))
                            1)))))))

!(fact 5)
;[(fact 5)]