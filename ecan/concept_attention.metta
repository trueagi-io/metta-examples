; Step-by-step ECAN from MeTTa.
; pip install hyperon-ecan[hyperon]
; metta examples/concept_attention.metta
;
; After rent, STI 12 falls below the default focus cutoff (8), so infer
; would return none. 20 is enough for dog to stay in focus.

!(import! &self hyperon_ecan)
!(ecan-new)

; Knowledge. wolf has no Inheritance edge.
!(ecan-fact Inheritance dog mammal)
!(ecan-fact Inheritance mammal animal)
!(ecan-fact Inheritance cat mammal)
!(ecan-fact Inheritance oak tree)
!(ecan-add wolf)

; Neural groups: dog~wolf, oak~tree. Hashed n-grams will not do this alone.
!(ecan-cluster (dog wolf mammal) (oak tree))

; Empty working memory.
!(ecan-report dog wolf oak mammal animal)

; Pay dog, then one ECAN cycle (rent + Hebbian + spread).
!(ecan-stimulate dog 20)
!(ecan-cycle)
!(ecan-report dog wolf oak mammal animal)
!(neural-similar dog)

; dog and maybe mammal in focus. wolf STI > oak. oak still idle.
; Next inference step should be (Inheritance dog animal).
!(ecan-infer)
!(ecan-report dog wolf oak mammal animal)
