;the Traditional Scheme

;=======================

;it is obligatory that (OB)

(: ob (-> Bool Bool))



;it is permissible that (PE)

(= (pe &p) (not (ob (not &p))))

;it is impermissible that (IM)

(= (im &p) (ob (not &p)))

;it is omissible that (OM)

(= (om &p) (not (ob &p)))

;it is optional that (OP)

(= (op &p) (and (om &p) (pe &p)))

;it is non-optional that (NO)

(= (no &p) (or (ob &p) (im &p)))

;=========================

(= (om work) )