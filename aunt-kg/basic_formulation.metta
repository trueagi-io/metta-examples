!(import! &self lordOfTheRings_simple.metta)

; !(match &self (parent $x "Frodo Gardner") $x)

; It's not the in the database that Rose Cotton is female
; !(match &self (parent $x "Frodo Gardner") (match &self (female $x) $x)) ; mother

; !(match &self (parent $x "Frodo Gardner") (match &self (parent $x $y) (match &self (female $y) $y))) ; sister

!(match &self (parent $p "Frodo Gardner") (match &self (parent $gp $p) (match &self (parent $gp $q) (match &self (female $q) $q)))) ; aunt

(= (pred $x) (match &self (parent $p $x) $p))
(= (pred $x) (match &self (parent $p $x) (pred $p)))

; !(pred "Frodo Gardner")
