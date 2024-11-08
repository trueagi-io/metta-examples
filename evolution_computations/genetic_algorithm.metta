!(import! &self get-rand)

!(bind! &popsize 2)
!(bind! &mut_probability 0.5)
!(bind! &num_of_children (* 3 &popsize))
!(bind! &barr_len 7)

(= (func $x) (* $x $x))

(= (cons $x $xs) (cons-atom $x $xs))
(= (car $x) (car-atom $x))
(= (cdr $x) (cdr-atom $x))
(= (index $x $idx) (index-atom $x $idx))

(= (inverse-bin 0) 1)
(= (inverse-bin 1) 0)

(= (make-pop-rec $iter)
    (if (>= $iter &popsize)
        ()
        (cons (randombarr! &barr_len) (make-pop-rec (+ $iter 1)))))

(= (make-pop)
    (make-pop-rec 0))

(= (choose-second-parent-random $id-first)
    (let $id-second (random-int 0 &popsize)
        (if (== $id-first $id-second)
            (choose-second-parent-random $id-first)
            $id-second)))

(= (choose-parents $set)
    (let $first-id (random-int 0 &popsize)
        (let $second (index $set (choose-second-parent-random $first-id))
            ((index $set $first-id) . $second))))

(= (split-parents $p1 $p2 $split-point)
    (if (== $split-point 0)
        $p2
        (cons (car $p1) (split-parents (cdr $p1) (cdr $p2) (- $split-point 1)))))

(= (make-child ($p1 . $p2))
    (let $split-point (random-int 1 &barr_len)
        (split-parents $p1 $p2 $split-point)))

(= (make-children-rec $population $iter)
    (if (>= $iter &num_of_children)
        ()
        (cons (make-child (choose-parents $population)) (make-children-rec $population (+ $iter 1)))))

(= (make-children $population)
    (make-children-rec $population 0))

(= (mutate-breed $breed $mut-idx $iter)
    (if (== $mut-idx $iter)
        (cons (inverse-bin (car $breed)) (cdr $breed))
        (cons (car $breed) (mutate-breed (cdr $breed) $mut-idx (+ $iter 1)))))

(= (mutate-population $population)
    (if (== () $population)
        ()
        (if (> (random-float 0 1) &mut_probability)
            (cons (car $population) (mutate-population (cdr $population)))
            (cons (mutate-breed (car $population) (random-int 0 &barr_len) 0) (mutate-population (cdr $population))))))

(= (calc_fit_for_population $population $convert-func)
    (if (== () $population)
        ()
        (cons (func ($convert-func (car $population))) (calc_fit_for_population (cdr $population) $convert-func))))

(= (max_element_iter $set $max)
    (if (== () $set)
        $max
        (if (> $max (car $set))
            (max_element_iter (cdr $set) $max)
            (max_element_iter (cdr $set) (car $set)))))

(= (max_element $set)
    (if (== () $set)
        ()
        (max_element_iter (cdr $set) (car $set))))

(= (min_element_iter $set $min)
    (if (== () $set)
        $min
        (if (< $min (car $set))
            (min_element_iter (cdr $set) $min)
            (min_element_iter (cdr $set) (car $set)))))

(= (min_element $set)
    (if (== () $set)
        ()
        (min_element_iter (cdr $set) (car $set))))

(= (sizeof $set)
    (if (== $set ())
        0
        (+ 1 (sizeof (cdr $set)))))

(= (weighted_by_fit_population $weights $max_fit)
    (if (== () $weights)
        ()
        (cons (/ (car $weights) $max_fit) (weighted_by_fit_population (cdr $weights) $max_fit))))

!(bind! &population (make-pop))
!(&population)
!(mutate-breed (0 1 1 0 1 0 1) 5 0)
;mutate-population is not working right now for some reason. This exact part to be precise, though mutate-breed works. I'm investigating it.
;!(chain (eval (random-int 0 &barr_len)) $mut_idx (mutate-breed (0 1 1 0 1 0 1) $mut_idx 0))
