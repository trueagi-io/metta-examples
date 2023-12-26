; I like music in general. However, I prefer electronic music.
; Among electronic music, I prefer cyber metal
; I don't know too much about ethnic electronic music, but I'd like to try it since it is electronic
(likes I MUSIC-001)

(context fact-001 (likes :ARG0 I))
(context fact-001 (likes :ARG1 music))
(context fact-001 (music :ARG1-of general))

; we want both likes-001 and Likes to be of the same type and appear in same positions
(is-a likes-001 Likes)
(is-a i-001 I)
(is-a Music-in-general Music)
(Music-in-general :ARG1-of General) ; :property ?
(likes-001 :ARG0 i-001) ; :subj instead of :ARG0 ?
(likes-001 :ARG1 Music-in-general) ; :obj ?
; we can introduce more roles
(likes-001 :degree Average) ; we can skip an instance here, because there is no concrete Average

(Fact likes-001 (TV 1 1))

(= (test $rel $subj)
    (match &self
            (, (is-a $r $rel)
               (is-a $s $subj)
               ($r :ARG0 $s)
               (Fact $r $tv))
            (, (match &self ($r $role $res)
                     ($r $role $res))
                $tv)
    )
)

!(test Likes I)

