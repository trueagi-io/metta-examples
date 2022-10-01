; Wrapping and unwrapping for the recursion
; Fix F = F (Fix F)
(= (unFix (Fix $x)) $x)

; identity function, useful in the combinators due to lack of
(= (identity $x) $x)
