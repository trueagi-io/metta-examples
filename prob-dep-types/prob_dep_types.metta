(: Distribution (-> Type Type))
(: Union (-> Type Type Type))
(= (Union $t1 $t2) $t1)
(= (Union $t1 $t2) $t2)
(: random (-> $t1 $t2 (Union $t1 $t2)))
(= (random $a $b) $a)
(= (random $a $b) $b)
(: sample (-> (Distribution $t1) $t1))
;(: thunk (-> $t1 (Distribution $t1)))
(: thunk (-> Atom (Distribution $t1)))
(= (sample (thunk $a)) $a)

;;; Bernoulli example

(: Bool Type)
(: True Bool)
(: False Bool)
(: Bernoulli (Distribution Bool))
(= (Bernoulli) (thunk (random True False)))

!(sample (Bernoulli))
!(assertEqualToResult
  (sample (Bernoulli))
  (True False))

;;; Colors example

(: Color Type)
(: Red Color)
(: Green Color)
(: Blue Color)
(: ColDist (Distribution Color))
(= (ColDist) (thunk (random Red (random Green Blue))))

!(sample (ColDist))
!(assertEqualToResult
  (sample (ColDist))
  (Red Green Red Blue))

;;; Hybrid example

(= (f True) (sample (Bernoulli)))
(= (f False) (sample (ColDist)))
(: Bool_U_Color Type)
(= (Bool_U_Color) (Union Bool Color))
(: HybridDist (Distribution (Bool_U_Color)))
(= (HybridDist) (thunk (f (sample (Bernoulli)))))

!(sample (HybridDist))
!(assertEqualToResult
  (sample (HybridDist))
  (True False Red Green Red Blue))

;;; Permutation example

(: Not (-> Bool Bool))
(= (Not True) False)
(= (Not False) True)
(: ColPerm (-> Color Color))
(= (ColPerm Red) Green)
(= (ColPerm Green) Blue)
(= (ColPerm Blue) Red)
(: HybridPerm (-> (Bool_U_Color) (Bool_U_Color)))
(= (HybridPerm $a) (Not $a))
(= (HybridPerm $a) (ColPerm $a))

!(HybridPerm (sample (HybridDist)))
!(assertEqualToResult
  (HybridPerm (sample (HybridDist)))
  (False True Green Blue Green Red))

;;; Second-order color example

(: ColDistPermuted (Distribution Color))
(= (ColDistPermuted) (thunk (ColPerm (sample (ColDist)))))
(: SecondOrderColDist (Distribution (Distribution Color)))
(= (SecondOrderColDist) (thunk (random (ColDist) (ColDistPermuted))))
(: FlattenedColDist (Distribution Color))
(= (FlattenedColDist) (thunk (sample (sample (SecondOrderColDist)))))

!(sample (SecondOrderColDist))
!(assertEqualToResult
  (sample (SecondOrderColDist))
  ((thunk (random Red (random Green Blue))) (thunk (ColPerm (sample (ColDist))))))
!(sample (FlattenedColDist))
!(assertEqualToResult
  (sample (FlattenedColDist))
  (Red Green Red Blue Green Blue Green Red))

;;; Second-order hybrid example

(: HybridDistPermuted (Distribution (Bool_U_Color)))
(= (HybridDistPermuted) (thunk (HybridPerm (sample (HybridDist)))))
(: SecondOrderHybridDist (Distribution (Distribution (Bool_U_Color))))
(= (SecondOrderHybridDist) (thunk (random (HybridDist) (HybridDistPermuted))))
(: FlattenedHybridDist (Distribution (Bool_U_Color)))
(= (FlattenedHybridDist) (thunk (sample (sample (SecondOrderHybridDist)))))

!(sample (SecondOrderHybridDist))
!(assertEqualToResult
  (sample (SecondOrderHybridDist))
  ((thunk (f (sample (Bernoulli)))) (thunk (HybridPerm (sample (HybridDist))))))
!(sample (FlattenedHybridDist))
!(assertEqualToResult
  (sample (FlattenedHybridDist))
  (True False Red Green Red Blue False True Green Blue Green Red))
