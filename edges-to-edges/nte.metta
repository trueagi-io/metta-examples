; https://apps.adamv.be/HEdit/?uri=examples/InteractiveDisneyStrategy.json&hide_gray&selected=[0]&hide_help&show_information
!(import! &self InteractiveDisneyStrategy.metta)

(= (transform__ $pattern $query) (match &self $pattern (add-atom &self $query)))
(= (transform_ $pattern $query) (match &self $pattern (let $_ (add-atom &self $query) $query)))
(= (transform $pattern $query) (match &self $pattern $query))
(= (? $pattern) (transform $pattern $pattern))

!(transform__ (, (conn $_ 0 $pid)
                (conn $_ 1 0 $sid)
                (conn $_ 1 1 $oid)
                (data $sind (id $sid)) (data $sind (data $s))
                (data $pind (id $pid)) (data $pind (data $p))
                (data $oind (id $oid)) (data $oind (data $o)))
             (NTE $s $p $o))

; everything flowing into DISNEYLAND
!(? (NTE $s $p "DISNEYLAND"))
; how the talent flows
!(? (NTE $s "provides talent" $o))
; everything TV does for MUSIC
!(transform (NTE "TV" $p "MUSIC") $p)
