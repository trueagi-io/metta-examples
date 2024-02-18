(= (added-atom! $x) (let $_ (add-atom &self $x) $x))

(= (transform $pattern $query) (match &self $pattern $query))
(= (transform_ $pattern $query) (match &self $pattern (added-atom! $query)))
(= (? $pattern) (transform $pattern $pattern))
(= (unifyTo $x $x) $x)

(= (E) (? (Outgoing $src $label $dst $weight)))
(= (V) (? (Node $label $id)))
(= (V $id) (? (Node $label $id)))
(= (values $p (Node $label $id)) (transform (Prop $p $v $id) $v))
(= (outE $l (Node $label $id)) (? (Outgoing $id $l $dst $weight)))
(= (inV (Outgoing $id $l $dst $weight)) (? (Node $_ $dst)))
(= (out $l (Node $_1 $src)) (transform (Outgoing $src $l $dst $w) (Node $_ $dst)))
(= (has $l $cond (Node $_1 $src)) (_has $cond (Node $_1 $src) (values $l (Node $_1 $src))))
(= (_has $cond (Node $_1 $src) $v) (if ($cond $v) (Node $_1 $src) (empty)))

!(bind! node# (new-state 0))

(= (addV $label) (added-atom! (Node $label (get-state node#))))
(= (addV $label) (let $_ (change-state! node# (+ (get-state node#) 1)) (empty)))
(= (property $p $v (Node $l $id)) (let $_ (added-atom! (Prop $p $v $id)) (Node $l $id)))
(= (addE (Node $_1 $src) $label (Node $_2 $dst) $w) (added-atom! (Outgoing $label $src $label $dst $w)))

; v1 = g.addV("person").property(id, 1).property("name", "marko").property("age", 29).next()
!(bind! v1 (property age 29 (property name marko (addV person))))
; v2 = g.addV("software").property(id, 3).property("name", "lop").property("lang", "java").next()
!(bind! v2 (property lang java (property name lop (addV software))))
; g.addE("created").from(v1).to(v2).property(id, 9).property("weight", 0.4)
!(addE v1 created v2 0.4)

; view added nodes
!(? (Node $label $id))
; view added properties
!(? (Prop $p $v $id))
