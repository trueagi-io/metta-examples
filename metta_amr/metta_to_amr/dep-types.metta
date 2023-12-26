(: if (-> Bool Atom Atom %Undefined%))
(= (if True $then $else) $then)
(= (if False $then $else) $else)
(: match-else (-> Atom Atom Atom %Undefined%))
(= (match-else $pattern $template $else)
   (let $r (match &self $pattern $template)
        (if (== $r (superpose ()))
            $else
            $r)))

;!(match-else (likes-001 $x $y) (its $x $y) nothing)
;!(== (collapse (match &self (likes-01 $x $y) (its $x $y))) ())
;!(let $r (match &self (likes-01 $x $y) (its $x $y)) 1)

;!(match &self (likes-001 $x $y) (its $x $y))

!(bind! &bk (new-space))

(: Entity Type)
(: Person (-> Entity Type))
(: Name (-> (Person $t) String Type))
(: id-001 Entity)
(: person-001 (Person id-001))
(: name-001 (Name person-001 "Kim"))
(: id-002 Entity)
(: person-002 (Person id-002))
(: Father (-> (Person $e1) (Person $e2) Type))
(: father-001 (Father person-001 person-002))
;!(match &self (: $fact (Father person-001 $father)) $father)
; it's wrong, because Father takes exeplar of (Person $x), not itself
;(: father (-> (Person $e1) (Father (Person $e1) (Person $e2))))
;(father person-001)

(= (father person-001) father-001)
 (let* (($f (father person-001))
        ($t (get-type $f))
        ((Father $p1 $p2) $t))
       $p2)

(let (Father $x $y) (get-type (father person-001)) $y)
(get-type father)
!(get-type (father person-001))
