;(1) "AC is prohibited to be operational in more than one role", encoded as "AC is not permitted to be operational in more than one role".
;From (1), it is derived:
;(2) "AC is not obliged to be operational in more than one role" and
;(3) "AC is obliged to not be operational in more than one role".
;Then, from (3) it is also derived:
;(4) "AC is permitted to not be operational in more than one role".

(= (AC ac-001) True)

(= (permitted (more-roles $ac))
   (not (== (AC $ac) True)))
(= (permitted (NOT (more-roles $ac)))
   (== (AC $ac) True))

(= (obliged $x)
   (permitted $x))

!(obliged (more-roles ac-001)) ; False
!(obliged (NOT (more-roles ac-001))) ; True
!(permitted (NOT (more-roles ac-001))) ; True