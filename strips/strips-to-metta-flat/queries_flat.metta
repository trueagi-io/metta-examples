; !(import! &self blocks-domain.metta)
!(import! &self logistics-i-1_flat.metta)

; GET ALL PRECONDITIONS OF AN ACTION
(= (preconditions $action)
 (match &self (precondition $action $y) $y))

; !(preconditions pick-up)
!(preconditions FLY-AIRPLANE)       ; > (at airplane loc-from)


; GET ARITY OF PROPOSITION
(= (arity $prop)
    (match &self (arity $prop $n) $n))
!(arity at)                         ; > 2


; GET ALL PROPOSITIONS THAT HOLD IN A STATE
(= (holds $state)
    (match &self (holds $state $p) $p))

 !(holds init)                  ; >[(in-city pos2 cit2), (at obj23 pos2), (in-city pos1 cit1), (at tru1 pos1), (at obj11 pos1), (in-city apt1 cit1), (at obj21 pos2), (at tru2 pos2), (at apn1 apt2), (at obj13 pos1), (at obj22 pos2), (in-city apt2 cit2), (at obj12 pos1)]



; CHECK WHETHER PROPOSITION HOLDS IN A STATE
(= (holds $state $prop)
    (match &self (holds $state $prop) $prop))

!(holds init (at obj13 pos1))           ; > [(at obj13 pos1)]
!(holds init (at smt pos1))             ; > []
