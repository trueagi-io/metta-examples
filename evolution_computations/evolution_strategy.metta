!(bind! &popsize 15)
!(bind! &mut_probability 0.5)
!(bind! &mut_variance 5)
!(bind! &num_of_children (* 3 &popsize))

(= (func $x) (* $x $x))

(= (cons $x $xs) (cons-atom $x $xs))
(= (car $x) (car-atom $x))
(= (cdr $x) (cdr-atom $x))


(= (make-pop-rec $size ($from $to) $iter)
    (if (>= $iter $size)
        ()
        (cons (random-float $from $to) (make-pop-rec $size ($from $to) (+ $iter 1)))))

; I thought this one will be faster (see SICP book, p 41) but no. I'll leave it just for info.
(= (make-pop-iter $size ($from $to) $iter $result)
    (if (>= $iter $size)
        $result
        (make-pop-iter $size ($from $to) (+ $iter 1) (cons (random-float $from $to) $result))))

(= (make-pop $size ($from $to))
    (make-pop-rec $size ($from $to) 0))

(= (choose-second-parent-random $id-first $popsize)
    (let $id-second (random-int 0 $popsize)
        (if (== $id-first $id-second)
            (choose-second-parent-random $id-first $popsize)
            $id-second)))

(= (choose-parents $set $popsize)
    (let $first-id (random-int 0 $popsize)
        (let $second (index-atom $set (choose-second-parent-random $first-id $popsize))
            (let $first (index-atom $set $first-id)
                ($first . $second)))))

(= (make-child ($p1 . $p2))
    (let $eps (random-float 0 1)
        (+ (* $eps $p1) (* (- 1 $eps) $p2))))

(= (make-children-rec $population $popsize $num_of_children $iter)
    (if (>= $iter $num_of_children)
        ()
        (cons (make-child (choose-parents $population $popsize)) (make-children-rec $population $popsize $num_of_children (+ $iter 1)))))

(= (make-children $population $popsize $num_of_children)
    (make-children-rec $population $popsize $num_of_children 0))

(= (mutate-population $population)
    (if (== () $population)
        ()
        (if (> (random-float 0 1) &mut_probability)
            (cons (car $population) (mutate-population (cdr $population)))
            (cons (+ (car $population) (random-float (* -1 &mut_variance) &mut_variance)) (mutate-population (cdr $population))))))

(= (calc_fit_for_population $population)
    (if (== () $population)
        ()
        (cons (func (car $population)) (calc_fit_for_population (cdr $population)))))

; TODO: max, min and size will be replaced after PR #792 in hyperon-experimental will be merged and, hopefully, it will increase performance
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

(= (weighted_fit $weights $max_fit)
    (if (== () $weights)
        ()
        (cons (/ (car $weights) $max_fit) (weighted_fit (cdr $weights) $max_fit))))

; (- 1 (car $weighted_fit_for_population)) since we are looking for minimum of fitness function
(= (select_new_population $population $weighted_fit_for_population $popsize $selected)
    (if (or (== () $population) (>= $selected $popsize))
        ()
        (if (> (- 1 (car $weighted_fit_for_population)) (random-float 0 1))
            (cons (car $population) (select_new_population (cdr $population) (cdr $weighted_fit_for_population) $popsize (+ $selected 1)))
            (select_new_population (cdr $population) (cdr $weighted_fit_for_population) $popsize (+ $selected 1)))))

(= (extend_pop_if_needed $new-pop $old-pop $popsize $newpopsize)
    (if (< $newpopsize $popsize)
        (extend_pop_if_needed (cons (car $old-pop) $new-pop) (cdr $old-pop) $popsize (+ 1 $newpopsize))
        $new-pop))

(= (choose-best $population $fit_for_population $bestfit $bestbreed)
    (if (== () $population)
        (Breed $bestbreed with fitness function $bestfit is best in current population)
        (if (< $bestfit (car $fit_for_population))
            (choose-best (cdr $population) (cdr $fit_for_population) $bestfit $bestbreed)
            (choose-best (cdr $population) (cdr $fit_for_population) (car $fit_for_population) (car $population)))))

(= (evolution-strat $iter $max-rec $population $popsize $num_of_children)
    (if (>= $iter $max-rec)
        (let $fit_for_population (calc_fit_for_population $population)
            (choose-best $population $fit_for_population (car $fit_for_population) (car $population)))
        (let*
            (
                ($children (make-children $population $popsize $num_of_children))
                ($mutated_children (mutate-population $children))
                ($fit_for_population (calc_fit_for_population $mutated_children))
                ($max_fit (max_element $fit_for_population))
                ($weighted_fit_for_population (weighted_fit $fit_for_population $max_fit))
                ($new-population (select_new_population $mutated_children $weighted_fit_for_population $popsize 0))
                ($new-population-ext (extend_pop_if_needed $new-population $population $popsize (sizeof $new-population)))
                ($fit_for_new_population (calc_fit_for_population $new-population-ext))
                ($best (choose-best $new-population-ext $fit_for_new_population (car $fit_for_new_population) (car $new-population-ext)))
                (() (println! $population))
                (() (println! $children))
                (() (println! $mutated_children))
                (() (println! $fit_for_population))
                (() (println! $max_fit))
                (() (println! $weighted_fit_for_population))
                (() (println! $new-population))
                (() (println! $new-population-ext))
                (() (println! $best))
;                (() (evolution-strat (+ $iter 1) $max-rec $new-population-ext $popsize $num_of_children))
            )
            ())))

!(bind! &population (make-pop &popsize (-100 100)))

!(evolution-strat 0 10 &population &popsize &num_of_children)
