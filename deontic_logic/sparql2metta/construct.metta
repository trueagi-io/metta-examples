;@prefix  foaf:  <http://xmlns.com/foaf/0.1/> .
;
;_:a    foaf:name   "Alice" .
;_:a    foaf:mbox   <mailto:alice@example.org> .
;PREFIX foaf:    <http://xmlns.com/foaf/0.1/>
;PREFIX vcard:   <http://www.w3.org/2001/vcard-rdf/3.0#>
;CONSTRUCT   { <http://example.org/person#Alice> vcard:FN ?name }
;WHERE       { ?x foaf:name ?name }
;
;<http://example.org/person#Alice> vcard:FN "Alice" .


(a name Alice)
(a mbox mailtoAlice)

!(match &self ($x name $name) (add-atom &self (exampleAlice FN $name)))
;!(let $atom (match &self ($x name $name) (exampleAlice FN $name)) (add-atom &self $atom))

!(match &self (exampleAlice FN Alice) (exampleAlice FN Alice))