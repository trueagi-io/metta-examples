;Rudimental Informal Modal Logic

;==================================

(: a Object)

(: %Undefined% Type)

;it is necessary (necessarily true) that

(: necessary (-> Object Bool))
(= (necessary a) True)
(= (necessary b) False)

;It is possible that p

(= (possible &p) (not (necessary (not &p))))

;It is impossible that p

(= (impossible &p) (necessary (not &p)))

;It is non-necessary that p

(= (non-necessary &p) (not (necessary &p)))

;It is contingent that

(= (contingent &p) (and (not (necessary &p)) (possible &p)))

;It is non-contingent that p

(= (non-contingent &p) (or (necessary &p) (impossible &p)))

;==================================

;!(get-type (necessary a))
!(necessary 5)

