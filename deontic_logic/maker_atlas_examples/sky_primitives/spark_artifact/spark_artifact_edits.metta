;A.S1.P1.1
;Name: Spark Artifact Edits

;Spark Artifact Edits require a simple majority of SPK holders in
;a weekly SPK Snapshot poll with a minimum quorum of 10% of circulating
;token supply. To propose a Spark Artifact Edit, an SPK holder must have
;at least 1% of the circulating token supply.
;When a proposal is made the Operational Facilitator must determine its
;alignment, and if it is considered in alignment with the Atlas and
;Spark Artifact, the edit proposal is put to a snapshot poll.
;If the poll is successful, the Facilitator must instruct the operational
;govops to carry out the artifact update.

(= (allow_spark_artifact_edits m1) False)

(= (spk_holder h1) 2)

(= (spk_holder h2) 4)

(= (spk_holder h3) 5)

(= (spk_holder h4) 2)

(= (spk_holder h5) 0.5)


(= (operational_facilitator o1) True)

(= (proposal_alignment prop1) True)
(= (proposal_alignment prop2) False)

(= (stake-size $participants)
   (let $lst (collapse (spk_holder (superpose $participants)))
       (foldl-atom $lst 0 $x $y (+ $x $y)))
)

(= (enough-stake-size? $participants $threshold)
   (>= (stake-size $participants) $threshold)
)

!(enough-stake-size? (h1 h3 h5) 7)
!(enough-stake-size? (h1 h3 h5) 8)

(= (obliged (align_with_atlas $artifacts))
    ((== (proposal_alignment $artifacts) True) ))

(= (vote $participants)
    True)

!(size-atom (h1 h3 h5))