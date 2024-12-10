;&forbidden{fence} :- not &permitted{fence}.
;&obligatory{white} :- fence, &forbidden{fence}.
;&permitted{fence} :- sea.

;1-st variant

(= (ifT True $x) $x)
(= (ifT $_ $x) Empty)


(= (Fence fence-001) True)
(= (Fence fence-002) True)
(= (Near-sea fence-002) True)
(= (forbidden $x)
   (ifT (Fence $x)
        (not (== (permitted $x) True))) ;Captures “unknown” (unreduced permitted) as False
)
(= (permitted $x)
   (ifT (Fence $x)
        (== (Near-sea $x) True))
)
(= (obligatory (White $x))
   (ifT (Fence $x)
        (forbidden $x)) ; supposing that forbidden will always be reduced
)


! (obligatory (White fence-001)) ; True
! (obligatory (White fence-002)) ; False
! (obligatory (White fence-003)) ; empty


;(obligate ?
;(own ? (corporation ?X) (cash ?Y))
;(distribute-dividend ?) (corporation ?X)))

