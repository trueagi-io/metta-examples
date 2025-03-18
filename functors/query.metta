;; type and data constructors 
(: M (-> $T Type))
(: mkM (-> $T (M $T)))

;; explicit bind function
(: bind (-> (M $T) (-> $T $U) (M $U))) 
(= (bind (mkM $val) $func) (mkM ($func $val)))

;; bind/apply: implicitly bound to 'default method' 
;; Q: should it be made explicit?
(= ((mkM $val) $func) (mkM ($func $val)))
(= ((mkM $val) effect $func) (let $_ ($func $val) (mkM $val)))

;; some function (add1)
(: add1 (-> Number Number))
(= (add1 $x) (+ $x 1))

;; example
(= (m) (mkM 42))
!(assertEqual ((m) effect add1) (mkM 42))
!(assertEqual ((m) add1) (mkM 43))

;; 'add-to-self' function (introduction)
;;  - adds a wrapped value to the space &self
;;  - should a separate space ideally be reserved for this?
;-------
(= (add-to-self $m $x) (add-atom &self ($m $x)))
(= ((add-to-self $m) $x) (add-to-self $m $x))

;; 'plain (A)' function (retrieval)
;;  - can be called to retrieve all instances of (A <something>) in the space
(= ($m) (mkM (match &self ($m $f) $f)))

;; 'from' function (copy into new alias)
;;  - usage: (from (A to B) <method>) 
;;      will transform all instances of (A $x) in the space to (B (<method> $x))
;;      will return new values as superposition of mkM monadic instances
(= (from ($s to $t) $func) ((($s) $func) effect (add-to-self $t)))

;; example
(e 1)
(e 2)
(e 5)
 
!(assertEqual (from (e to e1) add1) (e1))

;; apply "quote" to all values in the space stored as (e1 <something>)
!((e1) quote )


;--------
;; 'remove-from-self' function (elimination)
;;  - removes a specified wrapped value
;;  - 'inverse' of add-to-self

(= (remove-from-self $m $x) (remove-atom &self ($m $x)))
(= ((remove-from-self $m) $x) (remove-from-self $m $x))

;; 'to' function (transformation)
;;  - same as ((A) <method>), except application is persisted in the space
;;  - usage: (to A <method>) will change all instances of (A <something>) to (A (<method> <something>))
;;      will return mkM wrapped values with the _new_ result
(= (to $s $func) (((($s) effect (remove-from-self $s)) $func) effect (add-to-self $s))) 

!(to e1 add1)
;---------



; 'unwrap' function: when you want to access the values directly
(= (unwrap (mkM $b)) $b)

;; 'gimme' returns the values in unwrapped form
(= (gimme $s) (unwrap ($s)))
!(gimme e1)









;; example
(probability ((John Eats Dog) 0.01))
(probability ((Faye Eats HotDog) 0.7))
(probability ((Jerry Likes Skiing) 0.2))
(probability ((Jerry Likes Eating) 0.5))
(probability ((Alice Likes Reading) 0.8))
(probability ((Bob Likes Running) 0.6))
(probability ((Charlie Likes Swimming) 0.4))
(probability ((Diana Likes Cooking) 0.7))
(probability ((Eve Likes Dancing) 0.5))
(probability ((Frank Likes Hiking) 0.3))
(probability ((Grace Likes Painting) 0.9))
(probability ((Hank Likes Singing) 0.2))
(probability ((Ivy Likes Traveling) 0.6))
(probability ((Jack Likes Fishing) 0.4))
(probability ((Karen Likes Gardening) 0.7))
(probability ((Leo Likes Cycling) 0.5))
(probability ((Mona Likes Yoga) 0.8))
(probability ((Nina Likes Writing) 0.6))
(probability ((Oscar Likes Drawing) 0.3))
(probability ((Paul Likes Gaming) 0.9))
(probability ((Quinn Likes Surfing) 0.4))
(probability ((Rita Likes Knitting) 0.7))
(probability ((Sam Likes Skiing) 0.5))
(probability ((Tina Likes Running) 0.6))
(probability ((Uma Likes Reading) 0.8))
(probability ((Vince Likes Cooking) 0.7))
(probability ((Wendy Likes Dancing) 0.5))
(probability ((Xander Likes Hiking) 0.3))
(probability ((Yara Likes Painting) 0.9))
(probability ((Zane Likes Singing) 0.2))
(probability ((Alice Likes Traveling) 0.6))
(probability ((Bob Likes Fishing) 0.4))
(probability ((Charlie Likes Gardening) 0.7))
(probability ((Diana Likes Cycling) 0.5))
(probability ((Eve Likes Yoga) 0.8))
(probability ((Frank Likes Writing) 0.6))
(probability ((Grace Likes Drawing) 0.3))
(probability ((Hank Likes Gaming) 0.9))
(probability ((Ivy Likes Surfing) 0.4))
(probability ((Jack Likes Knitting) 0.7))
(probability ((Karen Likes Skiing) 0.5))
(probability ((Leo Likes Running) 0.6))
(probability ((Mona Likes Reading) 0.8))
(probability ((Nina Likes Cooking) 0.7))
(probability ((Oscar Likes Dancing) 0.5))
(probability ((Paul Likes Hiking) 0.3))
(probability ((Quinn Likes Painting) 0.9))
(probability ((Rita Likes Singing) 0.2))
(probability ((Sam Likes Traveling) 0.6))
(probability ((Tina Likes Fishing) 0.4))
(probability ((Uma Likes Gardening) 0.7))
(probability ((Vince Likes Cycling) 0.5))
(probability ((Wendy Likes Yoga) 0.8))
(probability ((Xander Likes Writing) 0.6))
(probability ((Yara Likes Drawing) 0.3))
(probability ((Zane Likes Gaming) 0.9))
(probability ((Alice Likes Surfing) 0.4))
(probability ((Bob Likes Knitting) 0.7))
(probability ((Charlie Likes Skiing) 0.5))
(probability ((Diana Likes Running) 0.6))
(probability ((Eve Likes Reading) 0.8))
(probability ((Frank Likes Cooking) 0.7))
(probability ((Grace Likes Dancing) 0.5))
(probability ((Hank Likes Hiking) 0.3))
(probability ((Ivy Likes Painting) 0.9))
(probability ((Jack Likes Singing) 0.2))
(probability ((Karen Likes Traveling) 0.6))
(probability ((Leo Likes Fishing) 0.4))
(probability ((Mona Likes Gardening) 0.7))
(probability ((Nina Likes Cycling) 0.5))
(probability ((Oscar Likes Yoga) 0.8))
(probability ((Paul Likes Writing) 0.6))
(probability ((Quinn Likes Drawing) 0.3))
(probability ((Rita Likes Gaming) 0.9))
(probability ((Sam Likes Surfing) 0.4))
(probability ((Tina Likes Knitting) 0.7))
(probability ((Uma Likes Skiing) 0.5))
(probability ((Vince Likes Running) 0.6))
(probability ((Wendy Likes Reading) 0.8))
(probability ((Xander Likes Cooking) 0.7))
(probability ((Yara Likes Dancing) 0.5))
(probability ((Zane Likes Hiking) 0.3))
(probability ((Alice Likes Painting) 0.9))
(probability ((Bob Likes Singing) 0.2))
(probability ((Charlie Likes Traveling) 0.6))
(probability ((Diana Likes Fishing) 0.4))
(probability ((Eve Likes Gardening) 0.7))
(probability ((Frank Likes Cycling) 0.5))
(probability ((Grace Likes Yoga) 0.8))
(probability ((Hank Likes Writing) 0.6))
(probability ((Ivy Likes Drawing) 0.3))
(probability ((Jack Likes Gaming) 0.9))
(probability ((Karen Likes Surfing) 0.4))
(probability ((Leo Likes Knitting) 0.7))
(probability ((Mona Likes Skiing) 0.5))
(probability ((Nina Likes Running) 0.6))
(probability ((Oscar Likes Reading) 0.8))
(probability ((Paul Likes Cooking) 0.7))
(probability ((Quinn Likes Dancing) 0.5))
(probability ((Rita Likes Hiking) 0.3))
(probability ((Sam Likes Painting) 0.9))
(probability ((Tina Likes Singing) 0.2))
(probability ((Uma Likes Traveling) 0.6))
(probability ((Vince Likes Fishing) 0.4))
(probability ((Wendy Likes Gardening) 0.7))
(probability ((Xander Likes Cycling) 0.5))
(probability ((Yara Likes Yoga) 0.8))
(probability ((Zane Likes Writing) 0.6))

;; Right/Left return a n
(: Right (-> (, $T $U) $U))
(: Left (-> (, $T $U) $T))


(= (Right ($l $r)) $r)
(= (Left ($l $r)) $l)


!((((probability) Right) add1) add1)
