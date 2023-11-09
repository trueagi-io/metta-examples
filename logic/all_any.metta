(: foldl (->  Atom Atom Atom $T))
(= (foldl $list $init $op)
   (if (== () $list) $init
       (let* (($head (car-atom $list))
              ($tail (cdr-atom $list)))
              ($op $head (foldl $tail $init $op)))
   )
)

(: all (-> Atom Bool))
(= (all $A)
   (foldl $A True and))

(: any (-> Atom Bool))
(= (any $A)
   (if (== () $A) False
        (let* ( ($tail (cdr-atom $A))
                ($head (car-atom $A))
               )
            (if $head True (any $tail))))
)

!(any (False False False False))
!(all (True True True False))
