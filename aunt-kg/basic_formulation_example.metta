(parent Tom Bob)
(parent Pam Bob)
(parent Tom Liz)
(parent Bob Ann)
(parent Bob Pat)
(parent Pat Jim)
(female Pam)
(male Tom)
(male Bob)
(female Liz)
(female Pat)
(female Ann)
(male Jim)

; !(match &self (parent $x Bob) $x)
; Tom, Pam

; !(match &self (parent $x Bob) (match &self (female $x) $x)) ; mother
; Pam

; !(match &self (parent $x Ann) (match &self (parent $x $y) (match &self (female $y) $y))) ; sister
; Pat

; !(match &self (parent $p Jim) (match &self (parent $gp $p) (match &self (parent $gp $q) (match &self (female $q) $q)))) ; aunt
; Ann

(= (pred $x) (match &self (parent $p $x) $p))
(= (pred $x) (match &self (parent $p $x) (pred $p)))

; !(pred Ann)
; Tom, Pam, Bob