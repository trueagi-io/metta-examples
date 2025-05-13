;https://mips.makerdao.com/mips/details/MIP101#2-3-scope-bounded-mutable-alignment-artifacts-gov3


;Scope Artifacts are continuously updated.
;Their updates must always be aligned with the specifications of the Atlas.

(= (update scope_artifacts) True)

(= (obliged (align_with_specs $artifacts))
    ((== (update $artifacts) True) ))