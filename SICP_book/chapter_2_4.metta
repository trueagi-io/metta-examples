; This chapter is dedicated to generic procedures which works with different object representation, type tags and data-
; directed programming.

; Complex numbers.

; Two different representations for complex numbers - (real, imag) parts and (magnitude, angle).

; One way to implement complex numers' selectors:
; (all sqrt/square/cos/atan etc functions are builtin in Scheme. I'll use imports from python)

(= (square $x)
    (* $x $x))

!(import! &self additional_funcs)

(= (real-part (Cons $r $i)) $r)

(= (imag-part (Cons $r $i)) $i)

(= (magnitude $z)
    (sqrt (+ (square (real-part $z)) (square (imag-part $z)))))

(= (angle $z)
    (atan (imag-part $z) (real-part $z)))

(= (make-from-real-imag $r $i) (Cons $r $i))

(= (make-from-mag-ang $r $a)
    (Cons (* $r (cos $a)) (* $r (sin $a))))

; Another way to implement selectors:

(= (real-part_ $z)
    (* (magnitude_ $z) (cos (angle_ $z))))

(= (imag-part_ $z)
    (* (magnitude_ $z) (sin (angle_ $z))))

(= (magnitude_ (Cons $m $a)) $m)

(= (angle_ (Cons $m $a)) $a)

(= (make-from-real-imag_ $x $y)
    (Cons (sqrt (+ (square $x) (square $y))) (atan $y $x)))

(= (make-from-mag-ang_ $r $a) (Cons $r $a))

; We can possibly use any of those complex number's representations. Though if we need to use both then we need to
; make a type tag to distinguish which representation we are using right now.

(= (make-pair $x $y)
    (pair $x $y))

(= (first-pair (pair $x $y)) $x)
(= (second-pair (pair $x $y)) $y)

(= (pair? $x)
    (case $x
        (((pair $a $b) True)
         ($_ False))))

(= (attach-tag $type-tag $contents)
    (make-pair $type-tag $contents))

(= (type-tag $datum)
    (if (pair? $datum)
        (first-pair $datum)
        (Error (type-tag $datum) "Input is not a pair")))

(= (contents $datum)
    (if (pair? $datum)
        (second-pair $datum)
        (Error (contents $datum) "Input is not a pair")))

(= (rectangular? $z)
    (== (type-tag $z) rectangular))

(= (polar? $z)
    (== (type-tag $z) polar))

; So now we need to re-write functions for both types of complex number representations. For functions to be in one
; program their names will also be changed to represent their representation.

; Rectangular representation of complex number with type tag:

(= (real-part-rectangular (Cons $r $i)) $r)

(= (imag-part-rectangular (Cons $r $i)) $i)

(= (magnitude-rectangular $z)
    (sqrt (+ (square (real-part-rectangular $z))
             (square (imag-part-rectangular $z)))))

(= (angle-rectangular $z)
    (atan (imag-part-rectangular $z)
          (real-part-rectangular $z)))

(= (make-from-real-imag-rectangular $x $y)
    (attach-tag rectangular (Cons $x $y)))

(= (make-from-mag-ang-rectangular $r $i)
    (attach-tag rectangular
        (cons (* $r (cos $i)) (* $r (sin $i)))))

; Polar representation of complex number with type tag:

(= (real-part-polar $z)
    (* (magnitude-polar $z) (cos (angle-polar $z))))

(= (imag-part-polar $z)
    (* (magnitude-polar $z) (sin (angle-polar $z))))

(= (magnitude-polar (Cons $m $a)) $m)

(= (angle-polar (Cons $m $a)) $a)

(= (make-from-real-imag-polar $x $y)
    (attach-tag polar
        (Cons
            (sqrt (+ (square $x) (square $y)))
            (atan $y $x))))

(= (make-from-mag-ang-polar $r $a)
    (attach-tag polar (Cons $r $a)))

(= (real-part_general $z)
    (case $z
        (((pair rectangular $contents) (real-part-rectangular $contents))
         ((pair polar $contents) (real-part-polar $contents))
         ($_ (Error (real-part $z) "Unknown representation type")))))

(= (imag-part_general $z)
    (case $z
        (((pair rectangular $contents) (imag-part-rectangular $contents))
         ((pair polar $contents) (imag-part-polar $contents))
         ($_ (Error (real-part $z) "Unknown representation type")))))

(= (magnitude_general $z)
    (case $z
        (((pair rectangular $contents) (magnitude-rectangular $contents))
         ((pair polar $contents) (magnitude-polar $contents))
         ($_ (Error (real-part $z) "Unknown representation type")))))

(= (angle_general $z)
    (case $z
        (((pair rectangular $contents) (angle-rectangular $contents))
         ((pair polar $contents) (angle-polar $contents))
         ($_ (Error (real-part $z) "Unknown representation type")))))

; Now to use add-complex, sub-complex, mul-complex and div-complex we need to implement more general make-from-* functions:

(= (make-from-real-imag_general $r $i)
    (make-from-real-imag-rectangular $r $i))

(= (make-from-mag-ang_general $m $a)
    (make-from-mag-ang-polar $m $a))

(= (add-complex $z1 $z2)
    (make-from-real-imag_general
        (+ (real-part_general $z1) (real-part_general $z2))
        (+ (imag-part_general $z1) (imag-part_general $z2))))

(= (sub-complex $z1 $z2)
    (make-from-real-imag_general
        (- (real-part_general $z1) (real-part_general $z2))
        (- (imag-part_general $z1) (imag-part_general $z2))))

(= (mul-complex $z1 $z2)
    (make-from-mag-ang_general
        (* (magnitude_general $z1) (magnitude_general $z2))
        (+ (angle_general $z1) (angle_general $z2))))

(= (div-complex $z1 $z2)
    (make-from-mag-ang_general
        (/ (magnitude_general $z1) (magnitude_general $z2))
        (- (angle_general $z1) (angle_general $z2))))

; So now we have three independent parts of whole complex-number's arithmetics program: arithmetics (sub, mul, add, div),
; polar representation of complex-number and rectangular representation. Several asserts for current code.

!(assertEqual
    (make-from-real-imag_general 5 2)
    (pair rectangular (Cons 5 2)))

!(assertEqual
    (make-from-mag-ang_general 3 4)
    (pair polar (Cons 3 4)))

!(bind! &z1 (make-from-real-imag_general 5 2))
!(bind! &z2 (make-from-mag-ang_general 3 4))

!(assertEqual
    (real-part_general &z1)
    5)

!(assertEqual
    (real-part_general &z2)
    -1.960930862590836)

!(assertEqual
    (imag-part_general &z1)
    2)

!(assertEqual
    (imag-part_general &z2)
    -2.2704074859237844)

!(assertEqual
    (magnitude_general &z1)
    5.385164807134504)

!(assertEqual
    (magnitude_general &z2)
    3)

!(assertEqual
    (angle_general &z1)
    0.3805063771123649)

!(assertEqual
    (angle_general &z2)
    4)

!(assertEqual
    (div-complex &z1 &z2)
    (pair polar (Cons 1.7950549357115013 -3.619493622887635)))

!(assertEqual
    (sub-complex &z1 &z2)
    (pair rectangular (Cons 6.9609308625908355 4.270407485923784)))

!(assertEqual
    (add-complex &z1 &z2)
    (pair rectangular (Cons 3.039069137409164 -0.2704074859237844)))

!(assertEqual
    (mul-complex &z1 &z2)
    (pair polar (Cons 16.15549442140351 4.380506377112365)))

; Data driven programming.

; Problem of the previous complex number representation is that general functions real-part, angle, magnitude and
; imag-part should know which representations we have. And in case of a new representation we need to add couple of
; lines to that functions.

; Another problem - we need to check that functions in different representations have different name. In case of Scheme
; we will get an error. In case of Metta, we will get several outputs.

; We need a table of types and operations like this:

;    ______________________________________________________________
;    |                                     Types                  |
;    | Functions              Polar             Rectangular       |
;    |____________________________________________________________|
;    | real-part         real-part-polar     real-part-rectangular|
;    |                                                            |
;    | imag-part         imag-part-polar     imag-part-rectangular|
;    |                                                            |
;    | magnitude         magnitude-polar     magnitude-rectangular|
;    |                                                            |
;    | angle             angle-polar         angle-polar          |
;    |____________________________________________________________|

; In case of data driven programming we need a function which is using this sort of table to call necessary functions.

(: lambda1 (-> Variable Atom (-> $a $t)))
(= ((lambda1 $var $body) $val)
    (let (quote ($v $b)) (sealed ($var) (quote ($var $body))) (let (quote $v) (quote $val) $b)) )

(: lambda2 (-> Variable Variable Atom (-> $a $b $t)))
(= ((lambda2 $var1 $var2 $body) $val1 $val2)
    (let (quote ($v1 $v2 $b)) (sealed ($var1 $var2) (quote ($var1 $var2 $body))) (let (quote ($v1 $v2)) (quote ($val1 $val2)) $b)) )

(: lambda3 (-> Variable Variable Variable Atom (-> $a $b $c $t)))
(= ((lambda3 $var1 $var2 $var3 $body) $val1 $val2 $val3)
    (let (quote ($v1 $v2 $v3 $b)) (sealed ($var1 $var2 $var3) (quote ($var1 $var2 $var3 $body))) (let (quote ($v1 $v2 $v3)) (quote ($val1 $val2 $val3)) $b)) )

(= (car-list (Cons $x $xs))
    $x)

(= (car-list Nil)
    Nil)

(= (cdr-list (Cons $x $xs))
    $xs)

(= (cdr-list Nil)
    Nil)

(= (cadr-list $x)
    (car-list (cdr-list $x)))

; in the following code functions put and get are used. Those functions works with table and get/puts functions from/to
; it. Implementations of those functions is a part of further chapters so they won't be implemented here. So I'm not sure
; if this is something we need to leave here. Opinions?

(= (install-rectangular-package)
  ;; inner functions
  (let*
  (
    ($real-part (lambda1 $z (car-list $z)))
    ($imag-part (lambda1 $z (cdr-list $z)))
    ($make-from-real-imag (lambda2 $x $y (Cons $x $y)))
    ($magnitude (lambda1 $z (sqrt (+ (square ($real-part $z))
                                     (square ($imag-part $z))))))
    ($angle (lambda1 $z (atan ($imag-part $z) ($real-part $z))))
    ($make-from-mag-ang (lambda2 $r $a (Cons (* $r (cos $a)) (* $r (sin $a)))))
    ($tag (lambda1 $x (attach-tag rectangular $x)))
  )
      (let*
      (
        (() (put real-part (Cons rectangular Nil) $real-part))
        (() (put imag-part (Cons rectangular Nil) $imag-part))
        (() (put magnitude (Cons rectangular Nil) $magnitude))
        (() (put angle (Cons rectangular Nil) $angle))
        (() (put make-from-real-imag rectangular (lambda2 $x $y ($tag ($make-from-real-imag $x $y)))))
        (() (put make-from-mag-ang rectangular (lambda2 $r $a ($tag ($make-from-mag-ang $r $a)))))
      )
      ())))

(= (install-polar-package)
  ;; inner functions
  (let*
  (
    ($magnitude (lambda1 $z (car-list $z)))
    ($angle (lambda1 $z (cdr-list $z)))
    ($make-from-mag-ang (lambda2 $x $y (Cons $x $y)))
    ($real-part (lambda1 $z (* ($magnitude $z) (cos ($angle $z)))))
    ($imag-part (lambda1 $z (* ($magnitude $z) (sin ($angle $z)))))
    ($make-from-real-imag (lambda2 $x $y (Cons (sqrt (+ (square $x) (square $y))) (atan $y $x))))
    ($tag (lambda1 $x (attach-tag polar $x)))
  )
      (let*
      (
        (() (put real-part (Cons polar Nil) $real-part))
        (() (put imag-part (Cons polar Nil) $imag-part))
        (() (put magnitude (Cons polar Nil) $magnitude))
        (() (put angle (Cons polar Nil) $angle))
        (() (put make-from-real-imag polar (lambda2 $x $y ($tag ($make-from-real-imag $x $y)))))
        (() (put make-from-mag-ang polar (lambda2 $r $a ($tag ($make-from-mag-ang $r $a)))))
      )
      ())))

; This way we don't need to think about intersection of functions' names.

; Map function used here is the built-in Scheme function. Since this code due to not implemented put and get is sort of
; demonstration I won't implement it right now. Apply-generic is actually uses random number of arguments. In this case
; it should probably use some sort of car/cdr of $args but once again since this is a demonstrative code and I cant
; even launch it to check, I'll leave it like this.
(= (apply-generic $op $args)
    (let*
    (
        ($type-tags (map $type-tag $args))
        ($proc (get $op $type-tags))
    )
    (if $proc
        (apply $proc (map $contents $args))
        (Error (apply-generic $op $args) "No method for these types"))))

(= (real-part $z) (apply-generic real-part $z))
(= (imag-part $z) (apply-generic imag-part $z))
(= (magnitude $z) (apply-generic magnitude $z))
(= (angle $z) (apply-generic angle $z))

(= (make-from-real-imag $x $y)
    ((get make-from-real-imag rectangular) $x $y))

(= (make-from-mag-ang $r $a)
    ((get make-from-mag-ang polar) $r $a))


; Exercise 2.73.
;
; Section 2.3.2 described a program that performs
; symbolic differentiation:

;(= (deriv $exp $var)
;      (if (number? $exp)
;            0
;            (if (variable? $exp)
;                (if (same-variable? $exp $var) 1 0)
;                (if (sum? $exp)
;                     (make-sum (deriv (addend $exp) $var)
;                               (deriv (augend $exp) $var))
;                     (if (product? $exp)
;                         (make-sum
;                              (make-product (multiplier $exp)
;                                            (deriv (multiplicand $exp) $var))
;                              (make-product (deriv (multiplier $exp) $var)
;                                            (multiplicand $exp)))
;                         (Error (deriv $exp $var) "Unknown expression type"))))))

; We can regard this program as performing a dispatch on the type of the
; expression to be differentiated. In this situation the ``type tag'' of the
; datum is the algebraic operator symbol (such as +) and the operation being
; performed is deriv. We can transform this program into data-directed style by
; rewriting the basic derivative procedure as

(= (number? $x) (and (== (get-type $x) Number) (not (== (get-metatype $x) Expression))))

(= (variable? $x) (== (get-metatype $x) Symbol))

(= (same-variable? $v1 $v2)
    (and$ ((variable? $v1) (variable? $v2) (== $v1 $v2))))

(= (car $x)
    (car-atom $x))

(= (cdr $x)
    (cdr-atom $x))

(= (operator $exp) (car $exp))
(= (operands $exp) (cdr $exp))

(= (apply-deriv $exp $var)
   (if (number? $exp)
        0
        (if (variable? $exp)
            (if (same-variable? $exp $var) 1 0)
            ((get deriv (operator $exp)) (operands $exp) $var))))

; Write the procedures for derivatives of sums and products, and the
; auxiliary code required to install them in the table used by the program
; above.

; Choose any additional differentiation rule that you like, such as the one
; for exponents (exercise 2.56), and install it in this data-directed system.

(= (cadr $x)
    (car (cdr $x)))

(= (caddr $x)
    (car (cdr (cdr $x))))

(= (make-sum_simplified $a1 $a2)
  (if (=number? $a1 0)
        $a2
        (if (=number? $a2 0)
            $a1
            (if (and (number? $a1) (number? $a2))
                (+ $a1 $a2)
                ('+ $a1 $a2)))))

(= (make-product_simplified $m1 $m2)
  (if (or (=number? $m1 0) (=number? $m2 0))
        0
        (if (=number? $m1 1)
            $m2
            (if (=number? $m2 1)
                $m1
                (if (and (number? $m1) (number? $m2))
                    (* $m1 $m2)
                    ('* $m1 $m2))))))


; This one should probably add sum and project derivs to the table. I'll also added exponentiation here so I won't need
; to split this to another install function with duplicative make-product.
(= (install-sum-product-deriv)
  (let*
  (
    ($addend (lambda1 $exp (cadr $exp)))
    ($augend (lambda1 $exp (caddr $exp)))
    ($=number? (lambda2 $exp $num (and (number? $exp) (== $exp $num))))
    ($make-sum (lambda2 $a1 $a2
        (if ($=number? $a1 0)
            $a2
            (if ($=number? $a2 0)
                $a1
                (if (and (number? $a1) (number? $a2))
                    (+ $a1 $a2)
                    ('+ $a1 $a2))))))
    ($multiplier (lambda1 $exp (cadr $exp)))
    ($multiplicand (lambda1 $exp (caddr $exp)))
    ($make-product (lambda2 $m1 $m2
        (if (or ($=number? $m1 0) ($=number? $m2 0))
            0
            (if ($=number? $m1 1)
                $m2
                (if ($=number? $m2 1)
                    $m1
                    (if (and (number? $m1) (number? $m2))
                        (* $m1 $m2)
                        ('* $m1 $m2)))))))
    ($base (lambda1 $exp (cadr $exp)))
    ($exponent (lambda1 $exp (caddr $exp)))
    ($make-exponentiation (lambda3 $base $dbase $exponent
        (let $newe (- $exponent 1)
            (if (== $newe 0)
                $dbase
                (if (== $newe 1)
                    ($make-product $exponent ($make-product $base $dbase))
                    ($make-product ($make-product $exponent (** $base (- $exponent 1))) $dbase))))))
  )
      (let*
      (
        (() (put deriv '+ (lambda2 $exp $var ($make-sum (apply-deriv ($addend $exp) $var)
                               (apply-deriv ($augend $exp) $var)))))
        (() (put deriv '* (lambda2 $exp $var ($make-sum
                              ($make-product ($multiplier $exp)
                                            (apply-deriv ($multiplicand $exp) $var))
                              ($make-product (apply-deriv ($multiplier $exp) $var)
                                            ($multiplicand $exp))))))
        (() (put deriv ** (lambda2 $exp $var ($make-exponentiation ($base $exp) (apply-deriv ($base $exp) $var) ($exponent $exp)))))
      )
      ())))

; Once again I can't test it since we do not have put and get functions. So I'll call it an end of this exercise.

; -----------------------End of Exercise 2.73---------------------------

; Exercise 2.74.
;
; Insatiable Enterprises, Inc., is a highly decentralized
; conglomerate company consisting of a large number of independent divisions
; located all over the world. The company's computer facilities have just been
; interconnected by means of a clever network-interfacing scheme that makes the
; entire network appear to any user to be a single computer. Insatiable's
; president, in her first attempt to exploit the ability of the network to
; extract administrative information from division files, is dismayed to
; discover that, although all the division files have been implemented as data
; structures in Scheme, the particular data structure used varies from division
; to division. A meeting of division managers is hastily called to search for a
; strategy to integrate the files that will satisfy headquarters' needs while
; preserving the existing autonomy of the divisions.

; Show how such a strategy can be implemented with data-directed programming.
; As an example, suppose that each division's personnel records consist of a
; single file, which contains a set of records keyed on employees' names. The
; structure of the set varies from division to division. Furthermore, each
; employee's record is itself a set (structured differently from division to
; division) that contains information keyed under identifiers such as address
; and salary. In particular:

; a.  Implement for headquarters a get-record procedure that retrieves a
; specified employee's record from a specified personnel file. The procedure
; should be applicable to any division's file. Explain how the individual
; divisions' files should be structured. In particular, what type information
; must be supplied?

; b.  Implement for headquarters a get-salary procedure that returns the salary
; information from a given employee's record from any division's personnel
; file. How should the record be structured in order to make this operation
; work?

; c.  Implement for headquarters a find-employee-record procedure. This should
; search all the divisions' files for the record of a given employee and return
; the record. Assume that this procedure takes as arguments an employee's name
; and a list of all the divisions' files.

(= (null? $expr)
    (== $expr ()))

(= (list $expr)
   (if (null? $expr)
        Nil
        (Cons (car-atom $expr) (list (cdr-atom $expr)))))

(= (tree $expr)
   (if (null? $expr)
        Nil
        (let* (($head (car-atom $expr)) ($tail (cdr-atom $expr)))
            (if (== (get-metatype $head) Expression)
                (Cons (tree $head) (tree $tail))
                (Cons $head (tree $tail))))))

(= (null-list? $list)
    (== $list Nil))

; Division1 record file and insert function.
(= (division1-recordfile)
    (tree
        ((John John_address 1000$) (Jim Jim_address 300$))))

; This one should insert necessary functions to retrieve info from division1's record file.
(= (insert-division1-records)
    (let*
        (
            ($emp_name (lambda1 $record_file (car-list (car-list $record_file))))
            ($record_by_name (lambda3 $name $record_file $self
                (if (null-list? $record_file)
                    Nil
                    (if (== $name ($emp_name $record_file))
                        (car-list $record_file)
                        ($self $name (cdr-list $record-file) $self)))))
            ($salary (lambda1 $record (cadr-list $record)))
            ($address (lambda1 $record (car-list $record)))
        )
        (let*
        (
            (() (put get-record division1 (lambda2 $name $record_file ($record_by_name $name $record_file $record_by_name))))
            (() (put get-salary division1 (lambda1 $record ($salary $record))))
        ))))

; Division2 record file and insert function.

(= (division2-recordfile)
    (list
        ((Peter . Peter_address . 5200$) (Kane . Kane_address 1500$))))

(= (insert-division2-records)
    (let*
        (
            ($emp_name (lambda1 ($name . $address . $salary) $name))
            ($salary (lambda1 ($name . $address . $salary) $salary))
            ($address (lambda1 ($name . $address . $salary) $address))
            ($record_by_name (lambda3 $name $record_file $self
                (if (null-list? $record_file)
                    Nil
                    (if (== $name ($emp_name $record_file))
                        (car-list $record_file)
                        ($self $name (cdr-list $record-file) $self)))))
        )
        (let*
        (
            (() (put get-record division2 (lambda2 $name $record_file ($record_by_name $name $record_file $record_by_name))))
            (() (put get-salary division2 (lambda1 $record ($salary $record))))
        ))))

; a)
(= (get-record $emp_name $division $division_recordfile)
   ((get get-record $division) $emp_name $division_recordfile))

; b)
(= (get-salary $division $record)
    ((get get-salary $division) $record))

; c)
; Let division_recordfiles contain pairs ($division_name . $record_file). Output is the first entry of emp_name in any
; record file.
(= (find-employee-record $emp_name Nil)
    (Error (find-employee-record $emp_name Nil) "No such employee in input record files"))
(= (find-employee-record $emp_name (Cons ($division_name . $record_file) $tail))
    (let $get-rec-res (get-record $emp_name $division_name $record_file)
        (if (== $get-rec-res Nil)
            (find-employee-record $emp_name $tail)
            $get-rec-res)))
; -----------------------End of Exercise 2.74---------------------------


; Message passing style:

(= (make-from-real-imag_message $x $y)
  (let $dispatch (lambda1 $op
    (if (== $op real-part)
        $x
        (if (== $op imag-part)
            $y
            (if (== $op magnitude)
                (sqrt (+ (square $x) (square $y)))
                (if (== $op angle)
                    (atan $y $x)
                    (Error (make-from-real-imag_message $x $y) "Unknown operation"))))))
  $dispatch))

(= (apply-generic_message $op $arg) ($arg $op))

; Exercise 2.75.  Implement the constructor make-from-mag-ang in
; message-passing style. This procedure should be analogous to the
; make-from-real-imag procedure given.

(= (make-from-mag-ang_message $m $a)
  (let $dispatch (lambda1 $op
    (if (== $op real-part)
        (* $m (cos $a))
        (if (== $op imag-part)
            (* $m (sin $a))
            (if (== $op magnitude)
                $m
                (if (== $op angle)
                    $a
                    (Error (make-from-mag-ang_message $m $a) "Unknown operation"))))))
  $dispatch))

; Some asserts for those message passing functions:
!(bind! &m_z1 (make-from-real-imag_message 5 2))
!(bind! &m_z2 (make-from-mag-ang_message 3 4))

!(assertEqual
    (apply-generic_message real-part &m_z1)
    5)

!(assertEqual
    (apply-generic_message real-part &m_z2)
    -1.960930862590836)

!(assertEqual
    (apply-generic_message imag-part &m_z1)
    2)

!(assertEqual
    (apply-generic_message imag-part &m_z2)
    -2.2704074859237844)

!(assertEqual
    (apply-generic_message magnitude &m_z1)
    5.385164807134504)

!(assertEqual
    (apply-generic_message magnitude &m_z2)
    3)

!(assertEqual
    (apply-generic_message angle &m_z1)
    0.3805063771123649)

!(assertEqual
    (apply-generic_message angle &m_z2)
    4)
; -----------------------End of Exercise 2.75---------------------------