; PDDL instance from the 2nd International Planning Competition, 2000

(define (problem BLOCKS-4-0)
(:domain BLOCKS)
(:objects D B A C )
(:init (clear C) (clear A) (clear B) (clear D) (ontable C) (ontable A)
 (ontable B) (ontable D) (handempty))
(:goal (and (on D C) (on C B) (on B A)))
)