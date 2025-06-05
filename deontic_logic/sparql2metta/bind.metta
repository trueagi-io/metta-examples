;@prefix dc:   <http://purl.org/dc/elements/1.1/> .
;@prefix :     <http://example.org/book/> .
;@prefix ns:   <http://example.org/ns#> .
;
;
;PREFIX  dc:  <http://purl.org/dc/elements/1.1/>
;PREFIX  ns:  <http://example.org/ns#>
;
;:book1  dc:title     "SPARQL Tutorial" .
;:book1  ns:price     42 .
;:book1  ns:discount  0.2 .
;
;:book2  dc:title     "The Semantic Web" .
;:book2  ns:price     23 .
;:book2  ns:discount  0.25 .

;SELECT  ?title ?price
;{  ?x ns:price ?p .
;   ?x ns:discount ?discount
;   BIND (?p*(1-?discount) AS ?price)
;   FILTER(?price < 20)
;   ?x dc:title ?title .
;}

;PREFIX  dc:  <http://purl.org/dc/elements/1.1/>
;PREFIX  ns:  <http://example.org/ns#>
;
;SELECT  ?title ?price
;{  { ?x ns:price ?p .
;     ?x ns:discount ?discount
;     BIND (?p*(1-?discount) AS ?price)
;   }
;   {?x dc:title ?title . }
;   FILTER(?price < 20)
;}

;title	price
; "The Semantic Web"	17.25

(book1 title sprql-tutorial)
(book1 price 42)
(book1 discount 0.2)
(book2 title semantic-web)
(book2 price 23)
(book2 discount 0.25)


;!(match &self ($x price $y) (match &self ($x discount $z)
;                            (let $price (* $y (- 1 $z))
;                                (if (< $price 20)
;                                (match &self ($x title $t) ($t $price))
;                                Empty))))

!(match &self (, ($x price $y) ($x discount $z))
                            (let $price (* $y (- 1 $z))
                                (if (< $price 20)
                                (match &self ($x title $t) ($t $price))
                                Empty)))

;!(match &self (, ($x price $y) ($x discount $z))
;                            (let $price (* $y (- 1 $z))
;                                 $price))