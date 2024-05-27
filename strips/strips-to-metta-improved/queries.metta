; !(import! &self logistics-i-1)
!(import! &self blocks-i-1)

; UTILITY
(= (fmap $f ($a $x $y) ) ($a ($f $x) ($f $y)))

!(valuation (state 0))
; > [(clear A), (ontable C), (clear B), (clear D), (ontable A), (ontable B), (handempty), (ontable D), (clear C)]

; GET ARITY OF A PROPOSITION
(= (arity $prop) (match &self (arity $prop $n) $n))

!(arity on)         ; > 2


; EXECUTE ACTION ON STATE
; apply an action on a state and get the resulting state
; TODO check whether preconditions are met
; TODO unique union
(= (eval (state $idx) $action)
  (union (subtraction (valuation (state $idx)) (eff-neg $action)) (eff-pos $action))
)

!(eff-pos (pick-up A))          ; > [(holding A)]
!(eff-neg (pick-up A))          ; > [(ontable A), (clear A), (handempty)]
!(eval (state 0) (pick-up A))     ; > [(holding A), (ontable C), (clear B), (clear D), (ontable B), (ontable D), (clear C)]


; SAVE NEW STATE
!(bind! state# (new-state 1))
(= (idx) (- (get-state state#) 1))

; TODO add only save if the state does not exist yet, otherwise give state index
(= (save $conditions)
   (let* (($current_id (get-state state#))
          ($_1 (add-atom &self (= (valuation (state $current_id))
                               (superpose $conditions))))
          ($_2 (change-state! state# (+ (get-state state#) 1))))
    $current_id))

; !(save (superpose ((test A) (test B))))
!(save ((on a b) (holding b)))
!(save ((on smt smt) (holding smt)))

!(valuation (state 1))                      ; > [(on a b), (holding b)]
!(valuation (state 2))                      ; > [(on smt smt), (holding smt)]

; GET ALL STATE NUMBERS AS SANITY CHECK
!(match &self (= (valuation (state $n)) $r) $n)     ; > [0, 1, 2]


; EXAMPLE: STACK BLOCKS A AND B

!(valuation (state (save (collapse (eval (state 0) (pick-up A))))))
!(unique (valuation (state (save (collapse (eval (state (idx)) (stack A B)))))))


; EXAMPLE MAKE TOWER A on B on C
(= (step $idx $action)
  (save (collapse (eval (state $idx) $action)))
)

!(step (state 0) (pick-up A))

!(valuation (state (step (step (step (step 0
                    (pick-up B))
                    (stack B C))
                    (pick-up A))
                    (stack A B))))


; CHECK WHETHER AN ACTION CAN BE APPLIED TO A STATE

; output True if $subset ⊆ $set, otherwise False
(= (subset $subset $set) (if (== (collapse (subtraction (superpose $subset) (intersection (superpose $set) (superpose $subset)))) ()) True False))

!(subset (a b) (a b c))         ; > True
!(subset (a b c) (a b d))       ; > False
!(subset  (collapse (pre (pick-up A))) (collapse (valuation (state 0))))        ; > True


; output True if $action can be applied in state $idx, otherwise False
(= (can-apply (state $idx) $action) (subset (collapse (pre $action)) (collapse (valuation (state $idx)))))

!(pre (pick-up A))
!(valuation (state 0))
!(can-apply (state 0) (pick-up A))      ; > True
!(can-apply (state 0) (stack A B))      ; > False

; FIND ALL ACTIONS
(= (all-actions) (match &self (action $name) $name))
!(all-actions)                          ; > [put-down, pick-up, unstack, stack]


; FIND ALL OBJECTS OF GIVEN TYPE
; TODO transitivity of types
(= (oftype $type) (match &self (isa $name $type) $name))
!(oftype object)                        ; > [A, C, B, D]


; GROUND ACTIONS
!(action (oftype object) (oftype object))       ; > [(action A A), (action A C), (action A B), (action A D), (action C A), (action C C), (action C B), (action C D), (action B A), (action B C), (action B B), (action B D), (action D A), (action D C), (action D B), (action D D)]


; (= (ground $action) (fmap oftype (match &self (types $action ($x $y)) ($action $x $y))))

(= (ground $action) (match &self (types $action ()) ($action)))
(= (ground $action) (match &self (types $action ($x)) ($action (oftype $x))))
(= (ground $action) (match &self (types $action ($x $y)) ($action (oftype $x) (oftype $y))))
(= (ground $action) (match &self (types $action ($x $y $z)) ($action (oftype $x) (oftype $y) (oftype $z))))

!(ground pick-up)           ; > [(pick-up A), (pick-up C), (pick-up B), (pick-up D)]
!(ground stack)             ; > [(stack A A), (stack A C), (stack A B), (stack A D), (stack C A), (stack C C), (stack C B), (stack C D), (stack B A), (stack B C), (stack B B), (stack B D), (stack D A), (stack D C), (stack D B), (stack D D)]


; FIND ALL ACTIONS THAT CAN BE APPLIED TO A STATE
