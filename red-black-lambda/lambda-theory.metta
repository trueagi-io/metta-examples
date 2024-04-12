(LambdaTheory ($B $V) (: Term Type))
(LambdaTheory ($B $V) (: Ground (-> $B Term)))
(LambdaTheory ($B $V) (: Mention (-> $V Term)))
(LambdaTheory ($B $V) (: Abstraction (-> $V (-> Term Term))))
(LambdaTheory ($B $V) (: Application (-> Term (-> Term Term))))
(LambdaTheory ($B $V) (: equivalent  (-> Term (-> Term Bool))))
(LambdaTheory ($B $V) (= ((equivalent $l) $r) ???))
(LambdaTheory ($B $V) (: reduce (-> Term (Option Term))))
(LambdaTheory ($B $V) (= (reduce $t) ???))

(= (LambdaTheoryF $F $B $V) (superpose (
(: ($F Term) Type)
(: ($F Ground) (-> $B ($F Term)))
(: ($F Mention) (-> $V ($F Term)))
(: ($F Abstraction) (-> $V (-> ($F Term) ($F Term))))
(: ($F Application) (-> ($F Term) (-> ($F Term) ($F Term))))
)))

; !(LambdaTheoryF RC BTheory String)