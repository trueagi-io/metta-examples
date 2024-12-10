;&forbidden{fence} :- not &permitted{fence}.
;&obligatory{white} :- fence, &forbidden{fence}.
;&permitted{fence} :- sea.


;2-nd variant

(= (Near-sea fence-002) True)
(= (forbidden (Fence $x))
   (== (permitted (Fence $x)) True))
(= (permitted (Fence $x))
   (== (Near-sea $x) True))
(= (obligatory (White (Fence $x)))
   (forbidden (Fence $x)))

! (obligatory (White (Fence fence-001))) ; True
! (obligatory (White (Fence fence-002))) ; False
