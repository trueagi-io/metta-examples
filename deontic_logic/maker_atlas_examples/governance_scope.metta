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

;(1) "AC is prohibited to be operational in more than one role", encoded as "AC is not permitted to be operational in more than one role".
;From (1), it is derived:
;(2) "AC is not obliged to be operational in more than one role" and
;(3) "AC is obliged to not be operational in more than one role".
;Then, from (3) it is also derived:
;(4) "AC is permitted to not be operational in more than one role".

(= (Facilitator DAO) True)
(= (misaligned AD1) False)
(= (misaligned AD2) True)

(take-action DAO AD1)

(= (obliged  (take-action $dao $ad))
    (and (== (Facilitator $dao) True) (== (misaligned $ac) True)))

(= (obliged  (be-penalized $dao $ad))
    (and (and (== (Facilitator $dao) True) (== (misaligned $ac) True))
    (not (== (match &self (take-action $dao $ad) $ad) $ad))))

;(= (AC ac-001) True)
;(= (permitted (more-roles $ac))
;   (not (== (AC $ac) True)))
;(= (permitted (NOT (more-roles $ac)))
;   (== (AC $ac) True))
;
;
;(= (obliged $x)
;   (permitted $x))


;!(obliged (more-roles ac-001)) ; False
;!(obliged (NOT (more-roles ac-001))) ; True
;!(permitted (NOT (more-roles ac-001)))

!(obliged (take-action DAO AD1))
!(obliged (be-penalized DAO AD1))
