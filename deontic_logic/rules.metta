;Deontic modalities:

(DeonticModality $e1)
(Obligatory $e1)
(Permitted $e1)
(Optional $e1)

;explicit representation of contradictions, conflicts, violations
; and other undesirable consequences (fallacies, mistakes, etc.)

(is-in-contradiction-with $statement1 $statement2)

(is-in-conflict-with $statement1 $statement2)

(is-complied-with-by $statement1 $statement2)

(is-violated-by $statement1 $statement2)

(is-necessary-violated-by $statement1 $statement2)


;How to represent roles in metta? Triplets/ predicates, patterns or whatever?
(ThematicRole $e1)

;Inference rules at the 1st level (the level of the eventualities)
(= (subject $e1) $e2) ; list all subjects
(= (object $e1) $e2) ; list all objects

(= (where $e1) ( ))

(= (exist $e1) ( ))

(InferenceRule1 (not (== $e1 $e2))
    (where
      (subject $e2) (object $e1) let $tr
      (not (exist $tr (and (ThematicRole $tr) (not (== $tr $trn))) (not (exist $e2 $tr $tv2))))
      (not (exist $tr (and (ThematicRole $tr) (not (== $tr $trn))) (not (exist $e1 $tr $tv1))))
      (not (exist $tr (and (ThematicRole $tr) (not (== $tr $trn))) (not (== $tv1 $tv2)))))
