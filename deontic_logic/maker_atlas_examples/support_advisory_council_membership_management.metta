;https://mips.makerdao.com/mips/details/MIP106#1-1-1-support-advisory-council-membership-management

;1.1.1: Support Advisory Council Membership Management
;Members of the Advisory Council are directly approved by
;Maker Governance through a governance poll, and
;must fulfill specific criteria.
;
;1.1.1.1
;The Support Facilitators must ensure that
;potential Advisory Council Members can apply to be approved by
;Maker Governance, using an open process with clear instructions
;as per 1.1.1.3.
;
;1.1.1.2
;Advisory Council Members must be ecosystem actors that are not involved
;in any business, political, or other governance-related activity that
;could result in a conflict of interest, either directly or indirectly.
;They must also have relevant skills for providing professional expert input
;on the content that the Support Scope is covering.
;
;1.1.1.3
;The Support Facilitators must periodically,
;when it is relevant, review the Advisory Council Applications,
;and if they find applications that are suitable, bring them to
;a vote through an MKR governance poll.
;When Advisory Council Applications are posted on the Maker Forum,
;which must follow the template as per 1.1.2.4.1A,
;the Support Facilitators have a review period of 30 days.
;During this review period, the applicant must host a Community Q&A and
;shall answer as many questions and doubts as possible.
;
;1.1.1.3.1
;The Support Facilitators can extend this deadline,
;if necessary, by 15 days, provided they posted the justification
;in the Maker Forum.
;
;1.1.1.3.2
;Once the review period is ended, the Support Facilitators must publish
;the response to the application on the Forum, along with a description of
;the reasoning behind the decision. If approved, the application will
;continue with the Governance Process and proceed to a vote as per 1.1.1.3.
;
;1.1.1.3.3
;Upon a successful vote, the Support Facilitators must arrange
;a service contract with the Advisory Council member,
;which must be made public. Approved Advisory Council Members are
;added to 1.1.1.6.1A.
;
;1.1.1.3.4
;Approved Advisory Council members have a term of service of 18 months from
;the time they are approved by Maker Governance.
;If desired, the Advisory Council Member can submit a new application for
;re-election when their term has between 60 and 30 days remaining.
;The re-election application must also fulfill 1.1.2 requirements and
;will open a new review period of 30 days where the Maker Community can
;provide feedback. The applicant shall again host a Community Q&A and
;respond to as many questions and doubts as possible.
;If approved, the re-election application will continue with the
;Governance Process and proceed to a vote as per 1.1.1.3.
;
;1.1.1.4
;The Support Facilitators may, if they deem it necessary,
;hold a vote to remove an Advisory Council Member.
;If an Advisory Council Member has not done any paid work for the Scope for
;at least 1 year, then the Support Facilitators can choose to remove them at
;will, if they deem it necessary.

;(= (support_council_member m1) True)

(= (approved m1) True)
(= (approved m2) True)
(= (approved m3) False)

(= (ecosystem-actor m1) True)
(= (ecosystem-actor m2) False)
(= (ecosystem-actor m3) False)

(= (side-engagement m1) True)
(= (side-engagement m2) False)
(= (side-engagement m3) False)

(= (paid-work-under-last-year m1) True)
(= (paid-work-under-last-year m2) False)

(= (obliged  (support_council_member $m))
    (and (== (approved $m) True)
    (and (== (ecosystem-actor $m) True)
    (not (== (side-engagement $m) True)))))

!(obliged (support_council_member m1)) ;False

(= (permissible (remove $m))
    (== (paid-work-under-last-year $m) False))

!(permissible (remove m3))

;How to remove a member from support council?
;Store a predicate for every potential member and turn them false?
;Or do an atomspace rewrite?
