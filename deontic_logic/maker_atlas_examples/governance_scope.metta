;https://mips.makerdao.com/mips/details/MIP101#2-the-governance-scope-gov

;2.6.5.1.2
;If FacilitatorDAOs fail to take action against misaligned AD,
;they must be severely penalized.

;Aligned Delegate (AD)
;Aligned Delegates are Anonymous Alignment Conservers that
;use the Protocol Delegation System
;to enable regular MKR holders to easily
;and safely delegate their MKR voting power
;towards implementing the Aligned Governance Strategy of an AVC,
;while earning Governance Participation Rewards in the process.

;2.6.5.1
;If a FacilitatorDAO finds that an AD has performed a misaligned act
;or breached their requirements, they can derecognize the AD
;and confiscate their AD Buffer.
;The AD Buffer can be used as a whistleblower bounty in case
;an ecosystem actor provided useful data, information or evidence
;that led to the derecognition of the AD.
;GOV6 must specify sufficient safety mechanisms around the payment of
;the whistleblower bounty.

(= (Facilitator DAO) True)
(= (misaligned AD1) False)
(= (misaligned AD2) True)

(take-action DAO AD1)

(= (obliged  (take-action $dao $ad))
    (and (== (Facilitator $dao) True) (== (misaligned $ac) True)))

(= (obliged  (be-penalized $dao $ad))
    (and (and (== (Facilitator $dao) True) (== (misaligned $ac) True))
    (not (== (match &self (take-action $dao $ad) $ad) $ad))))

!(obliged (take-action DAO AD1))
!(obliged (be-penalized DAO AD1))
