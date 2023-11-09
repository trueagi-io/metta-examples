; list membership


 (: eq (-> Atom Atom Bool))
 (= (eq $X $Y) False)
 (= (eq $X $X) True)
 (= (memb $X Nil) False)
 (= (memb $X (Cons $H $Tail))
    (or (eq $X $H) (memb $X $Tail)))

; find X that is member of both lists
; outputs 5 results [[None, None, None, None, 2, None]] since (eq $X $Y) is False even if $X equals $Y
!(let $res (and (memb $X (Cons 0 (Cons 2 Nil))) (memb $X (Cons 2 (Cons 3 Nil))))   (if $res $X None))

