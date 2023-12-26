(Has Person Name)
(Has Person Age)
(Has Person Father)
(Has Person Mother)

(is-a user Person)

(= (find-prop $x)
   (match &self (, (is-a $x $Role)
                   (Has $Role $Prop))
                $Prop))

(find-prop user)

(is-a person-001 Person)
(Mother user person-001)
(Name user "Bill")
;(Age user 25)
(Name person-001 "Margeret")

(= (get-prop $x)
   (let $prop (find-prop $x)
     (match &self ($prop $x $y) ($prop $y))))

(= (get-prop-value $prop $x)
   (match &self ($prop $x $y) $y))

;!(get-prop user)
;!(find-prop person-001)

(= (amr (Name $x))
   (n / name-01 :op1 (get-prop-value Name $x)))
(= (amr (Mother $x))
   (let $mother (get-prop-value Mother $x)
      (p / person
         :name (amr (Name $mother))
         :domain (p2 / person
            :ARG0-of (h / have-rel-role-91 :ARG1 (amr (Name $x)))
            :ARG2 (m / mother))))
)

!(amr (Mother user))
