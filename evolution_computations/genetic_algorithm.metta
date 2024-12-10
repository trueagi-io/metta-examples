!(import! &self get-rand)

!(bind! &popsize 15)
!(bind! &mut_probability 0.5)
!(bind! &num_of_children (* 3 &popsize))
!(bind! &barr_len 7) ; first bit actually used as a sign in bintodec function. Optional.

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

; randomint! is currently used here instead of random-int due to some issues with == between rust_number (produced by random-int)
; and python_number (when launching script using "metta script.metta" every number is a python_number). Because of this
; issue mutate-breed holds forever since (== $mut-idx $iter) is never True.
(= (mutate-population $population)
    (if (== () $population)
        ()
        (if (> (random-float 0 1) &mut_probability)
            (cons (car $population) (mutate-population (cdr $population)))
            (cons (mutate-breed (car $population) (randomint! 0 (- &barr_len 1)) 0) (mutate-population (cdr $population))))))

(= (calc_fit_for_population $population $convert-func)
    (if (== () $population)
        ()
        (cons (func ($convert-func (car $population))) (calc_fit_for_population (cdr $population) $convert-func))))

(= (weighted_fit $fits $max_fit)
    (if (== () $fits)
        ()
        (cons (/ (car $fits) $max_fit) (weighted_fit (cdr $fits) $max_fit))))

(= (select_new_population $population $weighted_fit_for_population $selected)
    (if (or (== () $population) (>= $selected &popsize))
        ()
        (if (> (- 1 (car $weighted_fit_for_population)) (random-float 0 1))
            (cons (car $population) (select_new_population (cdr $population) (cdr $weighted_fit_for_population) (+ $selected 1)))
            (select_new_population (cdr $population) (cdr $weighted_fit_for_population) (+ $selected 1)))))

(= (extend_pop_if_needed $new-pop $old-pop $newpopsize)
    (if (< $newpopsize &popsize)
        (extend_pop_if_needed (cons (car $old-pop) $new-pop) (cdr $old-pop) (+ 1 $newpopsize))
        $new-pop))

(= (choose-best $population $fit_for_population $bestfit $bestbreed)
    (if (== () $population)
        (Breed $bestbreed with fitness function $bestfit is best in current population)
        (if (< $bestfit (car $fit_for_population))
            (choose-best (cdr $population) (cdr $fit_for_population) $bestfit $bestbreed)
            (choose-best (cdr $population) (cdr $fit_for_population) (car $fit_for_population) (car $population)))))

(= (genetic-algorithm $iter $max-rec $population $convert-func)
    (if (>= $iter $max-rec)
        (let $fit_for_population (calc_fit_for_population $population $convert-func)
            (choose-best $population $fit_for_population (car $fit_for_population) (car $population)))
        (let*
            (
                ($children (make-children $population))
                ($mutated_children (mutate-population $children))
                ($fit_for_population (calc_fit_for_population $mutated_children $convert-func))
                ($max_fit (max-atom $fit_for_population))
                ($weighted_fit (weighted_fit $fit_for_population $max_fit))
                ($new-population (select_new_population $mutated_children $weighted_fit 0))
                ($new-population-ext (extend_pop_if_needed $new-population $population (size-atom $new-population)))
                ($fit_for_new_population (calc_fit_for_population $new-population-ext $convert-func))
                ($best (choose-best $new-population-ext $fit_for_new_population (car $fit_for_new_population) (car $new-population-ext)))
                (() (println! $best))
                (() (genetic-algorithm (+ $iter 1) $max-rec $new-population-ext $convert-func))
            )
            ())))


!(bind! &population (make-pop))

!(genetic-algorithm 0 10 &population bintodec!)
