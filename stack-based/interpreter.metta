(= ((basic $s) (put $x)) (basic ($s $x)))
(= ((basic (($s $x) $y)) add) (basic ($s (+ $x $y))))
(= ((basic ($s $x)) say) (let $_ (println! $x) (basic $s)))


(= (f1 $int) (((($int (put 2)) (put 3)) add) say))


!(f1 (basic E))