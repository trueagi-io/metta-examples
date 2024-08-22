(= (I $x) $x)
(= ((K $x) $y) $x)
(= (((S $x) $y) $z) (($x $z) ($y $z)))

(= (((B $x) $y) $z) ($x ($y $z)))
(= (((C $x) $y) $z) (($x $z) $y))
; K combinator is the same
;(= ((K $x) $y) $x)
(= ((W $x) $y) (($x $y) $y))

(= (U $x) (((S I) I) $x))
(= (Y $x) (((B U) ((C B) U)) $x))
; Doesn't work not sure why, probably typo
;(= (Y $x) (((S (K ((S I) I))) ((S ((S (K S)) K)) (K ((S I) I)))) $x))


; Check equivalence between SKI and BCKW systems
!(assertEqual
  (((((S (K S)) K) x) y) z)
  (((B x) y) z))

!(assertEqual
  (((((S ((S (K ((S (K S)) K))) S)) (K K)) x) y) z)
  (((C x) y) z))

!(assertEqual
  ((((S S) (S K)) x) y)
  ((W x) y))


; Check self-application combinator
!(assertEqual
  (((S I) I) a)
  (a a))

!(assertEqual
  (U a)
  (a a))


; Non-recursive function defined using Y combinator
; Atom type is required type of the first argument otherwise
; implementation falls into infinite recursion
(: id' (-> Atom (-> $t $t)))
(= ((id' $f) $x) $x)
(= (id $x) ((Y id') $x))

!(assertEqual (id A) A)

; Recursive function defined using Y combinator
(: fac (-> Atom (-> Int Int)))
(= ((fac $f) $x) (if (> $x 0) (* $x ($f (- $x 1))) 1))
(= (fact $x) ((Y fac) $x))

!(assertEqual (fact 0) 1)
!(assertEqual (fact 5) 120)

; `quoted` guarantees argument is not executed
(: quoted (-> Atom Atom))

; We need to define lambda accurately in order to prevent Y combinator
; continue recursion infinitely. First we should assign Atom type to the
; lambda's argument and to the argument of the returned function. Otherwise
; (Y f) in ((lambda $f ...) (Y f)) will be calculated before call is made.
; Second we should quote $val inside let otherwise (Y f) will be calculated
; inside let.
(: lambda (-> Variable Atom (-> Atom $t)))
(= ((lambda $var $body) $val)
    (let (quoted $var) (quoted $val) $body))

; Non-recursive function defined using lambda and Y combinator
(= (id' $x) ((Y (lambda $f (lambda $x $x))) $x))

!(assertEqual (id' A) A)

; Recursive function defined using lambda and Y combinator
(= (fact' $y)
  ((Y
    (lambda $f
      (lambda $x
        (if (> $x 0) (* $x ($f (- $x 1))) 1) ))) $y))

!(assertEqual (fact' 0) 1)
; Doesn't work because values of the lambda arguments are sneaking via call
; stack and second lambda call has value as a first argument instead of
; variable.
; An example from log:
; (if (> 5 0) (* 5 ((U ((B (lambda $f#15367 (lambda 5 (if (> 5 0) (* 5 ($f#15367 (- 5 1))) 1)))) U)) (- 5 1))) 1)
;!(assertEqual (fact' 5) 120)
