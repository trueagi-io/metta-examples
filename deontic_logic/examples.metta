(= (has-agent usr1) True)
(= (has-agent usr2) True)
(= (has-agent usr3) True)

(= (Eventuality Pay) usr2)
(= (Eventuality Seal) usr3)
(= (Eventuality Unseal) usr1)
(= (Eventuality Unseal) usr2)

;(Pay $x)
;(Seal $x)
;(Unseal $x)


(= (eus) (Eventuality Seal))
(= (euu) (Eventuality Unseal))
(= (eup) (Eventuality Pay))
(= (eo $x) (or (has-agent (eus)) (== (euu) (eup))))

!(eo usr3)

(rdf-type a1 event1)
(rdf-type a2 event1)
(rdf-type a3 event1)
(rdf-type a4 event2)
(rdf-type a1 event2)

(rdf-type event1 Eventuality)
(rdf-type event2 Eventuality)

! (match &self (, (rdf-type $a1 $c)
                  (rdf-type $a2 $c)
                  (rdf-type $c Eventuality))
         (if (== $a1 $a2) (empty) (NOT $a1 $a2)))

! (match &self (rdf-type $c Eventuality)
     (match &self (, (rdf-type $a1 $c)
                     (rdf-type $a2 $c))
                  (NOT $a1 $a2)))

;REXIST?

(= (false_if_undefined $input)
(if (== (get-type $input) %Undefined%) False True))

!(false_if_undefined a)
!(false_if_undefined 5)


