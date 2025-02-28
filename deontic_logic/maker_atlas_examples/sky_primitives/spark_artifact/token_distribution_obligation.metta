;# A.S1.P5
;
;Name: Token Distribution Obligation
;
;Spark is required to distribute 0.2% of
;its total token supply per year to USDS holders.

(bind! &redist_const (new-state (value 0.2)))

(bind! &acc1 (new-state (usdt 100)))

(= (star_agent a1) &acc1)

(bind! &total_inc (new-state (usdt 100)))

(= (obliged (supply_token $artifacts))
    ((== (proposal_alignment $artifacts) True) ))

(= (obliged  (be-penalized $dao $ad))
    (and (and (== (Facilitator $dao) True) (== (misaligned $ad) True))
    (not (== (match &self (take-action $dao $ad) $ad) $ad))))

(= (redis_by_val_ $holder)
    (let (State ($asset_type $inc)) (&total_inc)
    (let (State (&_ $rc)) (&redist_const) (+ (* $inc $rc) (star_agent $holder))))
)

(= (redis_by_val $holder)
    (change-state! $holder (usdt (redis_by_val_ $holder)))
)

(= (redistribute $holder_list )

   (let $holder ($holder_list)(obliged (star_agent $holder)
    (redis_by_val $holder))
)

