(= (has-agent usr1) True)

(= (Eventuality Pay) usr1)
(= (Eventuality Seal) usr1)
(= (Eventuality Unseal) usr1)

(Pay $x)
(Seal $x)
(Unseal $x)


(= (eus $x) (Eventuality Seal))
(= (euu $x) (Eventuality Unseal))
(= (eup $x) (Eventuality Pay))
(= (eo $x) (or (has-agent (eus $x)) (== (euu $x) (eup $x))))

!(eo $x)