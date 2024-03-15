; too slow with HE, use another implementation for this generation
; https://github.com/Jisco/gedcom.json/blob/master/examples/royal92.json
; !(import! &self royal92.metta)

; https://github.com/Jisco/gedcom.json/blob/master/examples/lordOfTheRings.json
!(import! &self lordOfTheRings.metta)

(= (transform_ $pattern $query) (match &self $pattern (let $_ (add-atom &self $query) $query)))
(= (transform $pattern $query) (match &self $pattern $query))
(= (? $pattern) (transform $pattern $pattern))

!(transform (Individuals $i (Fullname $name)) $name)

!(transform_ (,
        (Individuals $i (Fullname $name))
        (Individuals $i (Sex "M")))
    (male $name)
)

!(transform_ (,
        (Individuals $i (Fullname $name))
        (Individuals $i (Sex "F")))
    (female $name)
)

!(transform_ (,
        (Individuals $i (Id $id))
        (Individuals $i (Fullname $pn))
        (Relations $r (Husband $id))
        (Relations $r (Children $lci $cid))
        (Individuals $ci (Id $cid))
        (Individuals $ci (Fullname $cn)))
    (parent $pn $cn)
)

!(transform_ (,
        (Individuals $i (Id $id))
        (Individuals $i (Fullname $pn))
        (Relations $r (Wife $id))
        (Relations $r (Children $lci $cid))
        (Individuals $ci (Id $cid))
        (Individuals $ci (Fullname $cn)))
    (parent $pn $cn)
)
