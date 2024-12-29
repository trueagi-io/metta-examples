;https://mips.makerdao.com/mips/details/MIP102#MIP102c1
;MIP102c1: Purpose Description
;Amendments
;MIP Amendments that preserve the MIP number can be performed
;to modify any aspect of an existing MIP, including MIP0.
;There are no restrictions on how an existing MIP can be amended.
;
;Multiple amendments to multiple MIPs are allowed to be submitted
;as a single subproposal.
;
;Removals
;MIP102 also enables the removal of one or multiple MIPs
;that are inactive as a part of the Endgame transition.
;
;Multiple MIPs may be removed in a single MIP Removal subproposal.

(= (exist mip1) True)

(= (inactive mip1) True)

(= (preserve_mip_number amendment1 mip1) True)
(= (preserve_mip_number amendment2 mip1) False)

(= (preserve_mip_number amendment3 mip2) True)
(= (preserve_mip_number amendment4 mip2) False)

(= (permissible (modify $amendment $mip))
    (and (== (preserve_mip_number $amendment $mip) True) (== (exist $mip) True)))

(= (permissible (remove $mip))
    (== (inactive $mip) True))

!(permissible (modify amendment1 mip1))
!(permissible (remove mip1))
