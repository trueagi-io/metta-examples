; (n / name-01
;      :ARG1 (ii / i)
;      :ARG2 (p / person
;            :name (n2 / name
;                  :op1 "Sophia")))
(has-name I Sophia)
(CONNECT (has-name WHO NAME) name-01)

(ROLE name-01 :ARG1 WHO)
(ROLE name-01 :ARG2 NAME)

(= (get-role $concept $v)
   (match &self (ROLE $concept $role $v) $role))

(= (tell ($pred $arg0 $arg1))
   (match &self (CONNECT ($pred $v0 $v1) $concept)
          ($concept ((get-role $concept $v0) $arg0)
                    ((get-role $concept $v1) $arg1))))

!(tell (has-name I Sophia))
