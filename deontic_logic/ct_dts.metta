
;Top typer:

(: Eventuality Base)
(: Modality Base)
(: ThematicRole Base)

;Rexist modality:

(: Rexist Modality)

;negation, conjunction, and disjunction of eventualities:

(: not1 Eventuality)
(: and1 Eventuality)
(: and2 Eventuality)
(: or1 Eventuality)
(: or2 Eventuality)

;Deontic modalities:

(: DeonticModality Modality)
(: Obligatory DeonticModality)
(: Permitted DeonticModality)
(: Optional DeonticModality)

;2nd-level classes and properties - classical logic operators
;metta has booleans and classic logic operators, but not the alethic
;modal logic operators of necessity (□) and possibility (◊)


(: hold Statement)
(: necessary Statement)
(: possible Statement)

(: disjunction Statement)

;3rd-level - explicit representation of contradictions, conflicts, violations,
;and other undesirable consequences (fallacies, mistakes, etc.)

(: is-in-contradiction-with Statement)
(: is-in-conflict-with Statement)
(: is-complied-with-by Statement)
(: is-violated-by Statement)
(: is-necessary-violated-by Statement)

;Rules

;The following rule infers that if two eventualities are direct instantiations
; of the same abstract eventuality (i.e., they both describe the
; same action/state with the same thematic roles) but for at least one thematic role,
; for which it is asserted that one of the two eventualities
; has a certain value on that thematic role while the other one does not,
; then the two eventualities are connected by the "not" property.

(: not1 Eventuality)
(: and1 Eventuality)
(: and2 Eventuality)


!(match )
