; following https://github.com/barry-jay-personal/tree-calculus/blob/master/tree_book.pdf
; exponential notation utility
(= ($m ^ $k $n) (if (> $k 1) ($m ($m ^ (- $k 1) $n)) ($m $n)))
; can be used to encode natural numbers
(= (nat $x) (Δ ^ $x Δ))
; reduction rules
(= (((Δ Δ) $y) $z) $y) ; K
(= (((Δ (Δ $x)) $y) $z) (($y $z) ($x $z))) ; S
(= (((Δ ((Δ $w) $x)) $y) $z) (($z $w) $x))  ; F
; combinator shorthands
(= (K) (Δ Δ))
(= (I) ((Δ (Δ Δ)) (Δ Δ)))
(= (D) ((Δ (Δ Δ)) ((Δ Δ) Δ)))
(= (d $x) (Δ (Δ $x)))
; sanity checks
!(assertEqual (nat 5) (Δ (Δ (Δ (Δ (Δ Δ))))))
!(assertEqual (((K) y) z) y)
!(assertEqual ((I) x) x)
!(assertEqual ((((D) x) y) z) ((y z) (x z)))
; S combinator translation
(= (S) ((d ((K) (D))) ((d (K)) ((K) (D)))))
!(assertEqual ((((S) x) y) z) ((x z) (y z)))
; booleans
(= (TRUE) (K))
(= (FALSE) ((K) (I)))
(= (AND) (d ((K) ((K) (I)))))
(= (OR) ((d ((K) (K))) (I)))
(= (IMPLIES) (d ((K) (K))))
; todo: not, iff
!(assertEqual (((AND) (TRUE)) (FALSE)) (FALSE))

; todo ...

; reflection
(= (query $is0 $is1 $is2) ((d ((K) $is1)) ((d ((K) ^ 2 (I))) ((d ((K) ^ 5 $is2)) ((d ((K) ^ 3 $is0)) Δ)))))
(= (isLeaf) (query (K) ((K) (I)) ((K) (I))))
(= (isStem) (query ((K) (I)) (K) ((K) (I))))
(= (isFork) (query ((K) (I)) ((K) (I)) (K)))
!(assertEqual ((isLeaf) Δ) (TRUE))
!(assertEqual ((isLeaf) (Δ x)) (FALSE))
!(assertEqual ((isLeaf) ((Δ x) y)) (FALSE))

!(assertEqual ((isStem) Δ) (FALSE))
!(assertEqual ((isStem) (Δ x)) (TRUE))
!(assertEqual ((isStem) ((Δ x) y)) (FALSE))

!(assertEqual ((isFork) Δ) (FALSE))
!(assertEqual ((isFork) (Δ x)) (FALSE))
!(assertEqual ((isFork) ((Δ x) y)) (TRUE))
