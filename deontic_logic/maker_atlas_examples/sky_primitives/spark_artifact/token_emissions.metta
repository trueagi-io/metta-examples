;Token emissions
;
;Token emissions irreversibly disabled: True

(bind! &emissions_irreversibly (new-state (token_emission False)))



(= (obliged  (support_council_member $m))
    (and (== (approved $m) True)
    (and (== (ecosystem-actor $m) True)
    (not (== (side-engagement $m) True)))))

!(obliged (support_council_member m1)) ;False

(= (permissible (remove $m))
    (== (paid-work-under-last-year $m) False))

!(permissible (remove m3))