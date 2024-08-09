; https://tinkerpop.apache.org/docs/3.7.1/images/tinkerpop-modern.png
!(import! &self tinkerpop-modern.metta)

(= (transform_ $pattern $query) (match &self $pattern (let $_ (add-atom &self $query) $query)))
(= (transform $pattern $query) (match &self $pattern $query))
(= (? $pattern) (transform $pattern $pattern))

; what are all the id's
!(transform (json $_ (id $id)) $id)
; define nodes
!(transform_ (, (json $i (id $id))
                (json $i (label $label)))
             (Node $label $id))
; define properties
!(transform_ (, (json $i (id $id))
                (json $i (properties (age 0 (value $age)))))
             (Prop age $age $id))
!(transform_ (, (json $i (id $id))
                (json $i (properties (name 0 (value $name)))))
             (Prop name $name $id))
; define edges
!(transform_ (, (json $i (id $src))
                (json $i (outE ($label $k (inV $dst))))
                (json $i (outE ($label $k (properties (weight $weight))))))
             (Outgoing $src $label $dst $weight))

(= (E) (? (Outgoing $src $label $dst $weight)))
(= (V) (? (Node $label $id)))
(= (V $id) (? (Node $label $id)))
(= (values $p (Node $label $id)) (transform (Prop $p $v $id) $v))
(= (outE $l (Node $label $id)) (? (Outgoing $id $l $dst $weight)))
(= (inV (Outgoing $id $l $dst $weight)) (? (Node $_ $dst)))
(= (out $l (Node $_1 $src)) (transform (Outgoing $src $l $dst $w) (Node $_ $dst)))
(= (has $l $cond (Node $_1 $src)) (_has $cond (Node $_1 $src) (values $l (Node $_1 $src))))
(= (_has $cond (Node $_1 $src) $v) (if ($cond $v) (Node $_1 $src) (empty)))

(= ((gt $x) $y) (< $x $y))

; g.V()
!(V)
; g.V(1)
!(V 1)
; g.V(1).values('name')
!(values name (V 1))
; g.V(1).outE('knows')
!(outE knows (V 1))
; g.V(1).outE('knows').inV().values('name')
!(values name (inV (outE knows (V 1))))
; g.V(1).out('knows').values('name')
!(values name (out knows (V 1)))
; g.V(1).out('knows').has('age', gt(30)).values('name')
!(values name (has age (gt 30) (out knows (V 1))))
