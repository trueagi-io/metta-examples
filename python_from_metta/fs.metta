; input output streaming
; EXPERIMENTAL 
; ---------------

; > How to mute output while executing?

;(= (_BUFFER) (:: ()))
;(= (_BUFSIZE) 1024)

(= (STREAM) "stdout")

(= (shell-command) (py-list (
    "echo" 
    "Hello this is a shell"
    )))

; > Make imports a bit more readable
; ----------------------------------
    
(= (import $y as $x) 
    (bind! $x (py-atom $y)))
(= (import $x) 
    (import $x as $x))

; > Python imports
; ---------------

!(import str as ::str)
!(import subprocess.run as bash)
!(import subprocess.Popen as open)
!(import subprocess.PIPE as PIPE)

; sleep: useful for debugging!
; !(import time.sleep as sleep)

; > python 'inspect'. Highly recommend using this for debugging.
; -------------------------
!(import getattr)

(= (inspect $x) (getattr $x "__dict__"))        




(= (Popen) ( open ( Kwargs 
    (args (shell-command))
    (stdout (py-atom (PIPE)))
)))

; function to extract the std attribute
; --------------------------------

(: buffer BinaryIO)
(= (buffer) 
    (getattr (Popen) (STREAM))
)

(= (extract $buffer from $var to $name )
    (bind! $name 
        (getattr $buffer $var)
        ))
(= (extract $buffer to $name )
    (extract $buffer from (Literal $name) to $name))

!(extract (buffer) from "mode" to mode)
!(:mode mode)


!(extract (buffer) from "read" to read)
!(extract (buffer) from "writable" to writable)
!(extract (buffer) from "__next__" to next)


; > I want to catch the StopIteration?
; > otherwise just match and custom stop in stream. Possibly match b''?
;(= (Error $x $y $z) (a))
;(extract (next) from "__dir__" to poll)
;(= (poll) (next))

!(import b'' as _stop)


(: _stop StopIteration)
(: (read $n) (-> Number (IO Byte)))

(: :: (-> (IO Byte) Atom))

(= (:: _stop) STOP)
(= (:: $a) $a)


;(= (:: ($x $xs))
 ;   (a)
;)

;!(read 5)
;!(read 2)

(: while (-> Bool Atom $a))
(= (while $bool $do)
    (if $bool ( 
            $do ( while $bool $do ) ) ())
    )

;; > Read from buffer in a loop. This gets incrementally slower, by the way! why?
!(while True (
    let $buf (:: (read 1)) (
        println! ($buf)
        )
    ))

;; (: untill (-> Atom Atom $a))
;; (= (untill $stop $do) 
;;     (if (== ($do) ($stop))
;;     (println! (hi))
;;     (!(println! ($do)) (untill $stop $do))
;;     ))

;; !(untill _stop (
;;     let $buf (:: (read 1))
    ;; (println! ($buf))
    ;; ))
