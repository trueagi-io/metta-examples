; WIP

!(import! &LC lambda-theory.metta)

(= (RedLambda $RV $BLC) (RTheory (match &LC (LambdaTheory ($RV $BLC) $rhs) $rhs)))
(= (BlackLambda $BV $RLC) (BTheory (match &LC (LambdaTheory ($BV $RLC) $rhs) $rhs)))

!(RedLambda BTheory String)

(= (objectify (RTheory $x)) (RC $x))
(= (objectify (BTheory $x)) (BC $x))

!(objectify (RedLambda String BTheory))
!(objectify (BlackLambda String RTheory))

; (RedBlackLambda (rc (match &self (LambdaTheory ($RV $BLC) $rhs) $rhs)))
; (RedBlackLambda (: RBTerm))
; RBTerm = Either[RC.Term,BC.Term]
; (: RBTerm (Either (RC Term) (BC Term)))
;