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

(= (infer (OR $x $y))
   (or (infer $x)
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

(= (infer $x)
   (case (infer-step (TV $x)) (
      ((TV True) True)
      ((TV False) False)
      ((TV $y) (infer $y))
    )
   )
)

;a. PE(p)⊢ ¬OB(¬p), via Modus Ponens.
;b. ¬OB(¬p)⊢ PE(p), via Modus Ponens.
;c. OB(¬p)⊢ ¬PE(p), via Modus Tollens.
;d. ¬PE(p)⊢ OB(¬p), via Modus Tollens.

(: ob (-> Atom Bool))

(:-- (pe &p) (NOT-TRUE (ob (NOT-TRUE &p))))

;it is impermissible that (IM)

(:-- (im &p) (ob (NOT-TRUE &p)))

;it is omissible that (OM)

(:-- (om &p) (NOT-TRUE (ob &p)))

;it is optional that (OP)

:-- (op &p) (AND (om &p) (pe &p)))

;it is non-optional that (NO)

(:-- (no &p) (OR (ob &p) (im &p)))
