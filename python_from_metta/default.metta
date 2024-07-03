; Enable import statements
; -----------------------
(= (import $y as $x) 
    (bind! $x (py-atom $y)))
(= (import $x) 
    (import $x as $x))
