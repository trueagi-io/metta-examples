;_:a  dc10:title     "SPARQL Query Language Tutorial" .
;_:a  dc10:creator   "Alice" .
;
;_:b  dc11:title     "SPARQL Protocol Tutorial" .
;_:b  dc11:creator   "Bob" .
;
;_:c  dc10:title     "SPARQL" .
;_:c  dc11:title     "SPARQL (updated)" .

;PREFIX dc10:  <http://purl.org/dc/elements/1.0/>
;PREFIX dc11:  <http://purl.org/dc/elements/1.1/>
;
;SELECT ?title
;WHERE  { { ?book dc10:title  ?title } UNION { ?book dc11:title  ?title } }

;"SPARQL Protocol Tutorial"
;"SPARQL"
;"SPARQL (updated)"
;"SPARQL Query Language Tutorial"

(Entry (a title1 tutorial1))
(Entry (a creator Alice))
(Entry (b title2 tutorial2))
(Entry (b creator Bob))
(Entry (c title1 tutorial3))
(Entry (c title2 tutorial3Updated))


!(match &self (Entry ($x $y $title))
              (case $y
                  ((title1 $title)
                   (title2 $title)
                   ($_ Empty))))