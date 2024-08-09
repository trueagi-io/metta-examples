; this takes a minute on hyperon-experimental.

; > (range 1 10 3))
; [1, 4, 7]
(= (range $start $end $step) (if (< $start $end) $start (empty)))
(= (range $start $end $step) (if (< $start $end) (range (+ $start $step) $end $step) (empty)))

; > (sumh (1 2 3))
; [6]
(= (sumh $xs) (if (== $xs ()) 0 (+ (sumh (cdr-atom $xs)) (car-atom $xs))))

(= (pcond $x $r) (if (== (% $r $x) 0) $x (empty)))
(= (psum $x) (sumh (collapse (pcond (range 1 (- $x 1) 1) $x))))
(= (isPerfect $x) (if (== (psum $x) $x) $x (empty)))

; > (allPerfect 50)
; [6, 28]
(= (allPerfect $n) (isPerfect (range 1 $n 1)))

!(allPerfect 50)
