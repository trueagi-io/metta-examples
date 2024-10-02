(has-agent usr1)

(= (Eventuality Pay) usr1)
(= (Eventuality Seal) usr1)
(= (Eventuality Unseal) usr1)

(Pay $x)
(Seal $x)
(Unseal $x)


(= (eus $x) (match (Eventuality Seal) $x $x))
(= (euu $x) (match (Eventuality Unseal) $x $x))
(= (eup $x) (match (Eventuality Pay) $x $x))
(= (eo $x) (or (eus $x) (and (euu $x) (eup $x))))