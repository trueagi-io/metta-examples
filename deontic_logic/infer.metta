(:-- True True)

; a way to stop evaluation of what is wrapped in TV
(: TV (-> Atom Atom))
(= (infer-step (TV $x))
   (match &self (:-- $x $y) (TV $y)))
; it could possibly be improved:
; it's enough for one of operands to be False (while the second can be empty)
(= (infer (AND $x $y))
   (and (infer $x)
        (infer $y))
)
(= (infer (NOT-TRUE $x))
   ; could it be done without case?
   (case (infer $x) ; a way to capture empty (unknown) results
     ((True False)
      ($_ True)))
)

(= (infer $x)
   (case (infer-step (TV $x)) (
      ((TV True) True)
      ((TV False) False)
      ((TV $y) (infer $y))
    )
   )
)

(:-- (Fence fence-001) True)
(:-- (Fence fence-002) True)

(:-- (Near-sea fence-002) True)

(:-- (permitted $x)
     (AND (Fence $x)
          (Near-sea $x))
)

(:-- (forbidden $x)
     ;(AND (Fence $x) ; it should not be related to fences only?
          (NOT-TRUE (permitted $x)) ; False or Unknown
     ;)
)

(:-- (obligatory (White $x))
     (AND (Fence $x)
          (forbidden $x))) ; supposing that forbidden will always be reduced


;!(infer (permitted fence-001))
;!(infer (Near-sea fence-002))
;!(infer (forbidden fence-001))

! (infer (obligatory (White fence-001))) ; True
! (infer (obligatory (White fence-002))) ; False
! (infer (obligatory (White fence-003))) ; empty
