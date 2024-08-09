; add a constant $x to the stack
(= ($s (put $x)) ($s $x))

; we could use whatever as the initial stack, I picked the ungrounded E
> !(E (put 2))
; [(E 2)]
; chaining works naturally
!((E (put 2)) (put 3))
; [((E 2) 3)]

; defining some arithmetic operations
(= ((($s $x) $y) add) ($s (+ $x $y)))
(= ((($s $x) $y) mul) ($s (* $x $y)))
; let's make use of being able to return more than one result!
(= ((($s $x) $y) divmod2) (($s (% $x $y)) (/ $x $y)))

!(((E (put 2)) (put 3)) add)
[(E 5)]
!(((((E (put 2)) (put 3)) mul) (put 5)) divmod2)
; [((E 1) 1)]

; defining some stack manipulation
(= (($s $x) dup) (($s $x) $x))
(= ((($s $x) $y) swap) (($s $y) $x))
(= (($s $x) drop) $s)
(= (((($s $x) $y) $z) rot) ((($s $y) $z) $x))
(= ((($s $x) $y) over) ((($s $x) $y) $x))

!(((((E (put 2)) dup) mul) (put 5)) swap)
; [((E 5) 4)]

; side effecting and destroying print
(= (($s $x) say) (let  $_ (println! $x) $s))
!((((E (put 2)) (put 3)) add) say)
; 5
; [E]

; first class functions
(= (($s (Cons $f $r)) apply) ((($s $f) $r) apply))
(= (($s Nil) apply) $s)
!(((E 6) (Cons dup (Cons mul Nil))) apply)
; [(E 36)]

; multi valued functions work as expected
!(((E (put (superpose (1 2)))) dup) add)
; [(E 2), (E 4)]
!(((E (put (superpose (3 5)))) dup) (superpose (add mul)))
; [(E 6), (E 9), (E 10), (E 25)]
