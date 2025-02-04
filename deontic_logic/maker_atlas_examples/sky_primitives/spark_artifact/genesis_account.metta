;This account counts as controlling 100% of the circulating token supply for
;governance purposes,
;enabling editing of the spark artifact before creation of the Spark token

(= (preserve_mip_number amendment1 mip1) True)
(= (preserve_mip_number amendment2 mip1) False)

(= (preserve_mip_number amendment3 mip2) True)
(= (preserve_mip_number amendment4 mip2) False)

(= (permissible (modify $amendment $mip))
    (and (== (preserve_mip_number $amendment $mip) True) (== (exist $mip) True)))

(= (permissible (remove $mip))
    (== (inactive $mip) True))


(bind! &master_acc (new-state (supply percent 100)))

(bind! &enable_editing (new-state (token_emission True)))

(= (obliged (enable_editing $artifacts))
    ((== (proposal_alignment $artifacts) True) ))