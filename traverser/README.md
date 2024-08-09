# Basic Graph Traverser

Based on https://tinkerpop.apache.org/docs/current/tutorials/getting-started/ and https://arxiv.org/abs/1508.03843.

## Example
We take Tinkerpop's toy graph [tinkerpop-modern.json](tinkerpop-modern.json) and convert it to MeTTa with the generic json converter [json_to_metta.py](json_to_metta.py), which produces [tinkerpop-modern.metta](tinkerpop-modern.metta).
![see tinkerpop-modern.json](https://tinkerpop.apache.org/docs/current/images/tinkerpop-modern.png)

**Following [basic.metta](basic.metta).**\
Then we extract the properties we're interested in:
```scheme
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
```
In practice, this translates raw JSON statements like 
`(json 4 (id 5)); (json 4 (label software))` into a more idiomatic knowledge graph statement `(Node software 5)`.

A toy Gremlin-like DSL is formulated as follows:
```scheme
(= (E) (? (Outgoing $src $label $dst $weight)))
(= (V) (? (Node $label $id)))
(= (V $id) (? (Node $label $id)))
(= (values $p (Node $label $id)) (transform (Prop $p $v $id) $v))
(= (outE $l (Node $label $id)) (? (Outgoing $id $l $dst $weight)))
(= (inV (Outgoing $id $l $dst $weight)) (? (Node $_ $dst)))
(= (out $l (Node $_1 $src)) (transform (Outgoing $src $l $dst $w) (Node $_ $dst)))
(= (has $l $cond (Node $_1 $src)) (_has $cond (Node $_1 $src) (values $l (Node $_1 $src))))
(= (_has $cond (Node $_1 $src) $v) (if ($cond $v) (Node $_1 $src) (empty)))
```

This language can be used for the examples:
```scheme
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
```

---
**[creation.metta](creation.metta) goes over inserting nodes in the graph using a traversal.**



