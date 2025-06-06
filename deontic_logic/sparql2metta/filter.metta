;:book1  dc:title  "SPARQL Tutorial" .
;:book1  ns:price  42 .
;:book2  dc:title  "The Semantic Web" .
;:book2  ns:price  23 .

;SELECT  ?title ?price
;WHERE   { ?x ns:price ?price .
;          FILTER (?price < 30.5)
;          ?x dc:title ?title . }

;title	price
;"The Semantic Web"	23

(book1 title sprql-tutorial)
(book1 price 42)
(book2 title semantic-web)
(book2 price 23)

!(match &self ($x price $y)
            (if (< $y 30.5)
            (match &self ($x title $z) ($z $y))
            Empty))

