; Careful, these first three can take a long time
; https://github.com/Jisco/gedcom.json/blob/master/examples/royal92.json
; !(import! &self royal92.metta)

; https://github.com/kennethreitz/context/blob/master/gedcom/biblical/adameve.ged
!(import! &self adameve.metta)

; https://github.com/Jisco/gedcom.json/blob/master/examples/lordOfTheRings.json
; !(import! &self lordOfTheRings.metta)

; https://github.com/Jisco/gedcom.json/blob/master/examples/simpsons.json
; !(import! &self simpsons.metta)

(= (transform_ $pattern $query) (match &self $pattern (let $_ (add-atom &self $query) $query)))
(= (transform $pattern $query) (match &self $pattern $query))
(= (? $pattern) (transform $pattern $pattern))

!(transform (Individuals $i (Fullname $name)) $name)

!(transform_ (,
        (Individuals $i (Id $id))
        (Individuals $i (Fullname $name)))
    (hasName $id $name)
)

!(transform_ (,
        (Individuals $i (Id $id))
        (Individuals $i (Fullname $name)))
    (hasId $name $id)
)

!(transform_ (,
        (Individuals $i (Id $id))
        (Individuals $i (Sex "M")))
    (male $id)
)

!(transform_ (,
        (Individuals $i (Id $id))
        (Individuals $i (Sex "F")))
    (female $id)
)

!(transform_ (,
        (Relations $r (Husband $id))
        (Relations $r (Children $lci $cid)))
    (parent $id $cid)
)

!(transform_ (,
        (Relations $r (Wife $id))
        (Relations $r (Children $lci $cid)))
    (parent $id $cid)
)
