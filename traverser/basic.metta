; https://tinkerpop.apache.org/docs/3.7.1/images/tinkerpop-modern.png
!(import! &self tinkerpop-modern.metta)

; what are all the id's
!(match &self (json $_ (id (@value $id))) $id)
; define nodes
!(match &self (, (json $i (id (@value $id))) (json $i (label $label))) (Node $label $id))
; define properties
!(match &self (, (json $i (id (@value $id)))
                 (json $i (properties (age 0 (value (@value $age)))))) (Prop age $age $id))
!(match &self (, (json $i (id (@value $id)))
                 (json $i (properties (name 0 (value $name))))) (Prop name $name $id))
; define edges
!(match &self (, (json $i (id (@value $src)))
                 (json $i ($edgeT ($label $k ($_ (@value $dst)))))
                 (json $i ($edgeT ($label $k (properties (weight (@value $weight))))))) ($edgeT $src $label $dst $weight))
