;; Sudoku Solver
;; Written by Roy Ward, 2025
;; Author contact: roy@orange-kiwi.com
;; License: MIT

;; Usage: an inital board is needed that is an array of arrays, with each element being a
;; number from 0 to Sudoku size inclusive for the known values, and anything else for the
;; value to be solved. (I suggest "x" without the quotes for this).
;; For a 9x9, use the function sudoku as given in this example:
;; !(sudoku (
;;    (x x x x 2 x 3 5 x)
;;    (3 9 x 8 x x 7 6 x)
;;    (x x x x x x x x 9)
;;    (x x x 6 x 5 x 9 x)
;;    (5 8 x x x 4 x 2 6)
;;    (x x x 2 x 9 5 8 3)
;;    (4 x x 5 x 8 9 3 x)
;;    (x x 1 3 4 2 6 x 8)
;;    (6 x x 1 x 7 2 x 5) ))
;; For a different size (currently only 4x4 and 9x9 are supported), call sudoku-nm quth the
;; square root of the size (the size of a cell) given as a parameter:
;; !(sudoku-n 2 (
;;    (x x x x)
;;    (x x 1 2)
;;    (2 4 x x)
;;    (x x x x)))
;; If there is more than one solution, they will all be given.
;; This runs under both
;;  - Hyperon Experimental: https://github.com/trueagi-io/hyperon-experimental
;;  - Mettalog: https://github.com/trueagi-io/metta-wam

;; Sizes handled:
;; It will solve Sudoku puzzles of various sizes: currently 4x4 and 9x9.
;; It will also handle 0x0 and 1x1, but these are trivial and only of interest as test cases
;; It could be expanded to 16x16 or larger by adding more cases to transpose-block-board, but
;; the running time for this might be large.

;; Approach:
;; Languges such as MeTTa and Prolog that handle nondeterminism lend themselves to easily
;; expressing solutions to problems such as Suduko, but unfortunately a full naive backtracking
;; approach will take an excessive amount of time to run - 4x4 is feasible, but 9x9 is not.
;; At the other end of the spectrum, there are many heuristics that can be used to solve
;; Sudoku without having to do any backtracking - many of these can be found at
;; https://sudoku.com/sudoku-rules.
;; However, many of these require a substantial amount of pattern matching to detect.
;; My approach is to use two of the simplest heuristics to constrain the solutions, and use
;; backtracking when these are insufficient to reach a solution. In practice, even the most
;; difficult solutions only require a very small number of choice points. This very
;; occasional backtracking will be much faster than doing the more complicated checks.
;; The two heuristics that I use:
;;   - Track which values each cell can have have based by eliminating known values that occur
;;     in the same row, column or block. If a cell has one value remaining, that is the value.
;;     This is https://sudoku.com/sudoku-rules/last-possible-number/
;;   - If a cell has the only occurence of a number in a row, block or column, then it must be
;;     that number. This checked by generating a simplified histogram (0 1 or many values).
;;     This is https://sudoku.com/sudoku-rules/last-remaining-cell/
;; (Note that https://sudoku.com/sudoku-rules/last-free-cell/ is subsumed by last possible number)

;; Noteworthy code features:
;; Sudoko involves checking for properties in rows, columns and 3x3 (in the case of 9x9 Sudoku)
;; blocks. The usual way of doing this would be to write a row checker, a column checker and a
;; block checker. What I did instead was to write a row checker, then write transformations for
;; the whole puzzle so that a column or block maps onto a row, do the row checking, then
;; transform back. There is a small cost in efficiency doing this, but it makes the code
;; substantially smaller.
;; Another thing that I do is to break this into iterations, where each iteration has a list of
;; singletons generated from the last iteration, applies them on rows, columns and blocks,
;; and generates a new list of singletons. This is repeated until there are no non-singletons
;; left (solved) or a fixed point is reached, at which point a cell is picked to try all the
;; values non-deterministically. If there is more than one solution, they will all be returned.

;; Example of execution internals:
;;    (x x x x)
;;    (x x 1 2)
;;    (2 4 x x)
;;    (x x x x)
;;
;; This is how it is looks at the start in the internal form (board and singletons):
;; (
;;   ((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4))
;;   ((1 2 3 4) (1 2 3 4) (1      ) (  2    ))
;;   ((  2    ) (      4) (1 2 3 4) (1 2 3 4))
;;   ((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4)))
;; ((1 3 2) (1 2 1) (2 1 4) (2 0 2))
;; This is the board and new singletons from processing the rows:
;; (
;;   ((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4))
;;   ((    3 4) (    3 4) (1      ) (  2    ))
;;   ((  2    ) (      4) (1   3  ) (1   3  ))
;;   ((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4)))
;; ()
;; This is the board and new singletons from processing the columns:
;;   ((1   3 4) (1 2 3  ) (  2 3 4) (1   3 4))
;;   ((    3 4) (    3  ) (1      ) (  2    ))
;;   ((  2    ) (      4) (    3  ) (1   3  ))
;;   ((1   3 4) (1 2 3  ) (  2 3 4) (1   3 4)))
;; ((1 1 3) (2 2 3))
;; This is the board and new singletons from processing the blocks:
;;   ((1   3 4) (  2    ) (    3 4) (    3 4))
;;   ((    3 4) (    3  ) (1      ) (  2    ))
;;   ((  2    ) (      4) (    3  ) (1   3  ))
;;   ((1   3  ) (1   3  ) (  2    ) (1   3 4)))
;; ((0 1 2) (3 2 2))
;; So the next interation will have the last board above, and the new singletons:
;; ((1 1 3) (2 2 3) (0 1 2) (3 2 2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Debugging
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; leave the first line uncommented out to supress debug spam, second line uncommented out for testing
;(= (assertEqualOpt $a $b) ())
(= (assertEqualOpt $a $b) (assertEqual $a $b))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General Utilities
;; These are generic functions that should (or possibly do) in Metta that could have applicability elsewhere
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; append two lists to create a resulting list
;; Parameters:
;;  - list of type $a
;;  - list of type $a
;; Returns
;;  - list of type $a

(: append (-> Expression Expression Expression))
(= (append $a $b)
    (if-decons-expr $a $h $t
        (let $tail (append $t $b) (cons-atom $h $tail))
        $b)
)

!(assertEqualOpt (append () (1 2 3 4)) (1 2 3 4))
!(assertEqualOpt (append (1 2) (3 4)) (1 2 3 4))
!(assertEqualOpt (append (1 2 3 4) ()) (1 2 3 4))

;; append-all appends each item in a list of lists to create a resulting list
;; Parameters:
;;  - list of lists of type $a
;; Returns
;;  - list of type $a

(: append-all (-> Expression Expression))
(= (append-all $l)
    (if-decons-expr $l $h $t
        (let $tail (append-all $t)
            (append $h $tail))
        ()
    )
)

!(assertEqualOpt (append-all (() ((1 2 1) (1 3 2)) ((2 0 2) (2 1 4)) ())) ((1 2 1) (1 3 2) (2 0 2) (2 1 4)))

;; dup-list creates a list containing $n instances of some value
;; Parameters:
;;  - integer size of resulting list
;;  - value to populate lust
;; Returns
;;  - list of that value repeated

(: dup-list (-> Number Atom Expression))
(= (dup-list $n $v)
    (if (== $n 0) () (let $t (dup-list (- $n 1) $v) (cons-atom $v $t)))
)

!(assertEqualOpt (dup-list 5 a) (a a a a a))

;; divmod takes two integers and returns a tuple of the quotient and the remainder
;; Parameters:
;;  - integer dividend
;;  - integer divisor
;; Returns
;;  - (integer, integer) which is (integer quotient, remainder)


(: divmod (-> Number Number Expression))
(= (divmod $x $y) (let $m (% $x $y) ((/ (- $x $m) $y) $m)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cell internals
;; A Cell is the term for a box in the Sudoku that should contain a single number.
;; It is stored as an ordered list of the possible remaining values that the cell can take. If there
;; is only one possible value (the number is known), we call that a singleton.
;; Most of the code dealing with cell internals is kept together in this section, so if there was ever
;; a more efficient implementation (say an array of booleans, or an integer to treat as a bit mask),
;; the modifications could be kept in one place.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; default-empty-cell sets a default value for the empty (ambiguous) cell on output. This would really
;; only be of any use for debugging, as this doesn't return until all the cells are filled on. Any value
;; not an integer in the range 1 to N^2 inclusive is taken to mean an empty cell for input

(: default-empty-cell (-> Atom))
(= (default-empty-cell) x)

;; cell-populate-all create a list of all the integers (1 .. <sudoku_size>)
;; Parameters:
;;  - integer (always pass 1)
;;  - integer size of the Sudoku (4 or 9)
;; Returns
;;  - Cell with all possiblities set

(: cell-populate-all (-> Number Number Expression))
(= (cell-populate-all $i $N2)
    (if (== $i $N2)
        ($N2)
        (let $t (cell-populate-all (+ $i 1) $N2) (cons-atom $i $t))))

!(assertEqualOpt (cell-populate-all 1 9) (1 2 3 4 5 6 7 8 9))

;; cell-remove returns a value from a given cell and return the modified cell. The $changed variable is set to True
;; or False depending on whether the value was in the initial cell to be removed.
;; Parameters:
;;  - Cell to remove values from
;;  - Integer to remove
;;  - Bool changed value (output)
;; Returns:
;;  - Cell with value removed

(: cell-remove (-> Expression Number Bool Expression))
(= (cell-remove $c $v $changed)
    (if-decons-expr $c $h $t
        (if (== $h $v)
            ; Found one to remove. Set changed to True and we are done
            (let $changed True $t)
            ; Keep looking
            (if (> $h $v)
                ; if the head is larger than the value, there is nothing to remove (as list os ordered)
                ; so return the list
                (let $changed False $c)
                ; recursively check the next element of the list
                (let $rest (cell-remove $t $v $changed) (cons-atom $h $rest))
            )
        )
        ;; Nothing to remove from an empty list
        (let $changed False ())
    )
)

!(assertEqualOpt (let $c (cell-remove (1 2 3 4) 8 $changed) ($changed $c)) (False (1 2 3 4)))
!(assertEqualOpt (let $c (cell-remove (2 3 4) 1 $changed) ($changed $c)) (False (2 3 4)))
!(assertEqualOpt (let $c (cell-remove (1 2 3 4) 3 $changed) ($changed $c)) (True (1 2 4)))
!(assertEqualOpt (let $c (cell-remove (1 2 4) 3 $changed) ($changed $c)) (False (1 2 4)))

;; cell-length returns the number of possible values that a cell can still have. This will be at least 1
;; Parameters:
;;  - Cell
;; Returns:
;;  - Integer size

(: cell-length (-> Expression Number))
(= (cell-length $c) (size-atom $c))

;; value-to-cell convert an input value to a cell. Two cases:
;;  - a number $x in the range of the sudoku size will be returned as ($x) (a singleton)
;;  - anything else will be return the results of cell-populate-all (1 .. <sudoku_size>)
;; Parameters:
;;  - Integer size of the Sudoku (4 or 9)
;;  - Any atomic value to be converted
;; Returns:
;;  - Cell

(: value-to-cell (-> Number Atom Expression))
(= (value-to-cell $N2 $v)
    (if (== (get-type $v) Number)
        ; have to do this separately, as HE won't short circuit, then will give type error
        (if (and (< 0 $v) (<= $v $N2))
            ; create singleton
            ($v)
            ; not in range - Empty cell
            (cell-populate-all 1 $N2)
        )
        ; not a number - Empty cell
        (cell-populate-all 1 $N2)
    )
)

!(assertEqualOpt (value-to-cell 9 0) (1 2 3 4 5 6 7 8 9))
!(assertEqualOpt (value-to-cell 9 10) (1 2 3 4 5 6 7 8 9))
!(assertEqualOpt (value-to-cell 9 x) (1 2 3 4 5 6 7 8 9))
!(assertEqualOpt (value-to-cell 9 -) (1 2 3 4 5 6 7 8 9))
!(assertEqualOpt (value-to-cell 9 7) (7))

;; cell-to-value converts a cell to an input value. Two cases:
;;  - a singleton ($x) will have the single value returned
;;  - anything will return the default-empty-cell value
;; Parameters:
;;  - Cell
;; Returns:
;;  - display value for that cell (either a number or default empty value)

(: cell-to-value (-> Expression Atom))
(= (cell-to-value $c)
    (let ($t $u) (decons-atom $c)
        (if (== $u ()) $t (default-empty-cell))
    )
)

!(assertEqualOpt (cell-to-value (7)) 7)
!(assertEqualOpt (cell-to-value (2 7)) (default-empty-cell))
!(assertEqualOpt (map-atom (0 0 1 2) $v (value-to-cell 4 $v)) ((1 2 3 4) (1 2 3 4) (1) (2)))

;; remove-singletons removes singleton values from all other cells, and indicates
;; whether a change happened
;; Parameters:
;;  - Cell to remove singletons from
;;  - Integer associated with the cell position
;;  - list of pairs of integers - each pair is (position, value)
;;  - Bool changed value (output)
;; Returns:
;;  - Cell with singletons removed

(: remove-singletons (-> Expression Number Expression Bool Expression))
(= (remove-singletons $c $n $singletons $changed)
    (if-decons-expr $singletons $sh $st
        (let* (
            (($shi $shv) $sh)
            ($c1 (remove-singletons $c $n $st $changed1))
            ($c2
                (if (== $shi $n)
                    (let $changed2 False $c1)
                    (cell-remove $c1 $shv $changed2)
                )
            )
            )
            (let $changed (or $changed1 $changed2) $c2)
        )
        (let $changed False $c)
    )
)

!(assertEqualOpt (let $c (remove-singletons (2) 0 () $changed) ($changed $c)) (False (2)))
!(assertEqualOpt (let $c (remove-singletons (2) 0 ((1 4) (0 2)) $changed) ($changed $c)) (False (2)))
!(assertEqualOpt (let $c (remove-singletons (4) 1 ((1 4) (0 2)) $changed) ($changed $c)) (False (4)))
!(assertEqualOpt (let $c (remove-singletons (1 2 3 4) 2 ((1 4)) $changed) ($changed $c)) (True (1 2 3)))
!(assertEqualOpt (let $c (remove-singletons (1 2 3 4) 2 ((0 2)) $changed) ($changed $c)) (True (1 3 4)))
!(assertEqualOpt (let $c (remove-singletons (1 2 3 4) 2 ((1 4) (0 2)) $changed) ($changed $c)) (True (1 3)))
!(assertEqualOpt (let $c (remove-singletons (1 2 3 4) 2 ((0 2) (1 4)) $changed) ($changed $c)) (True (1 3)))
!(assertEqualOpt (let $c (remove-singletons (1 2 3) 2 ((1 4)) $changed) ($changed $c)) (False (1 2 3)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Row processing
;; The fundamental tests in Sudoku are defined on rows. For this purpose, a row is one of:
;;  - an actual row
;;  - a column
;;  - one of the 2x2 or 3x3 blocks
;; In all cases, this will be turned into a list of cells before being passed to the code in this section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Histograms:
;; One of the heuristics used is to check for each number if there are any numbers that occur only one in
;; row, in which case the cell having that value must have that number
;; For instance, in the row:
;;  ((1 3 4) (2) (3 4) (3 4))
;; the value 1 only appears in the first cell, so that must be the value of that cell
;; The histogram is an Sudokuo row sized array where each entry can have one of three values:
;;  - None: this value has not been encountered yet
;;  - a (position value) pair: that indicates this value has been found once so far
;;  - NoProcess: indicates that the corresponding number occured multiple times, or is already a singleton
;;      in which case it will be processed elsewhere
;; At the end of processing a histogram, it will be an error of any values are None - this means a value
;; can't exist in that row.

;; collect-histogram-aux1 is a helper fuction for collect-histogram-aux that processes a single potential
;; value inside a cell for producing a histogram
;; Parameters:
;;  - Integer representing a cell position to incorporate into the histogram tuple
;;  - The previous histogram value for that cell
;;  - Integer representing the cell value
;; Returns:
;;  - The new histogram value for that cell

(: collect-histogram-aux1 (-> Number Atom Number Atom))
(= (collect-histogram-aux1 $n $v $nv)
    (if (== $v None)
        ($nv $n)
        NoProcess
    )
)

!(assertEqualOpt (collect-histogram-aux1 0 None 3) (3 0))
!(assertEqualOpt (collect-histogram-aux1 0 (4 0) 3) NoProcess)
!(assertEqualOpt (collect-histogram-aux1 0 NoProcess 3) NoProcess)

;; collect-histogram-aux processes a single cell against a histogram. It steps through the the elements
;; of the cell and the elements of the histogram, updating the histogram as it goes
;; Parameters:
;;  - list of values representing a histogram
;;  - Integer representing the cell number in a row (zero indexed)
;;  - Integer representing the position in the histogram - set to to 1 when calling this
;;  - Integer that is the head of the list of values making up a cell
;;  - list that is the tail of the list of values making up a cell
;; Returns:
;;  - The new histogram with the values of the cell aggregated into it

(: collect-histogram (-> Expression Number Number Number Expression Expression))
(= (collect-histogram $histogram $nv $n $cellh $cellt)
    ; Split one element off the head of the histogram
    (let ($hh $ht) (decons-atom $histogram)
        (if (< $n $cellh)
            ; If haven't reached the cell head, skip to the next value
            (let $hist2 (collect-histogram $ht $nv (+ $n 1) $cellh $cellt)
                (cons-atom $hh $hist2)
            )
            (let* (
                    ($hist3
                        (if-decons-expr $cellt $ch $ct
                            ; if there are values left in $cellt, split off the next head, and continue
                            (collect-histogram $ht $nv (+ $n 1) $ch $ct)
                            ; otherwise we are done, so return the remaing histogram
                            $ht
                        )
                    )
                    ; Do the aggregation for the head that we had
                    ($newh (collect-histogram-aux1 $n $hh $nv))
                )
                ; put the updated element of the histogram back with the rest of the histogram
                (cons-atom $newh $hist3)
            )
        )
    )
)

!(assertEqualOpt (collect-histogram (None None None None) 3 1 1 (3)) ((3 1) None (3 3) None))
!(assertEqualOpt (collect-histogram ((3 1) None (3 3) None) 2 1 2 (3)) ((3 1) (2 2) NoProcess None))

;; collect-histogram-singleton processes a singleton cell against a histogram. This is handled
;; specially because the histogram entry should be set to NoProcess in that case
;; Parameters:
;;  - list of values representing a histogram
;;  - Integer representing the position in the histogram - set to to 1 when calling this
;;  - Integer that is the value of the singleton
;; Returns:
;;  - The new histogram with the values of the cell aggregated into it

(= (collect-histogram-singleton $histogram $n $c)
    (let ($h $t) (decons-atom $histogram)
        (if (< $n $c)
            (let $hist2 (collect-histogram-singleton $t (+ $n 1) $c)
                (cons-atom $h $hist2)
            )
            (cons-atom NoProcess $t)
        )
    )
)

;; process-board-one-row-aux is a helper function for process-board-one-row
;; Parameters:
;;  - list of Cells representing the row
;;  - Integer position in the row (set initally to 0)
;;  - Integer size of the board
;;  - list of input singletons
;;  - Boolean indicating whether changed (output)
;;  - list of generated singletons (output)
;;  - list of values representing a histogram (output)
;; Result:
;;  - list of Cells representing the new row

(= (process-board-one-row-aux $row $n $N2 $singletons $changed $newsing $histogram)
    (if-decons-expr $row $rh $rt
        (let* (
                ; recursively call the rest of the row
                ($row1 (process-board-one-row-aux $rt (+ $n 1) $N2 $singletons $changed1 $newsing1 $histogram1))
                ; remove the singletons from all other cells
                ($cell (remove-singletons $rh $n $singletons $changed2))
                ; changed if changed in either of the aboce two operations
                ($changed (if $changed1 True $changed2))
                ; put the row back together
                ($newrow (cons-atom $cell $row1))
                ; collect histogram information
                ($histogram
                    (if-decons-expr $cell $ch $ct
                        (if (== $ct ())
                            ; singleton case - no need to process this value
                            (collect-histogram-singleton $histogram1 1 $ch)
                            ; non singleton case - update the histogram
                            (collect-histogram $histogram1 $n 1 $ch $ct)
                        )
                        ; cell is completely empty, so fail
                        (empty)
                    ))
            )
            ; check if cound a new singleton
            (if (and $changed2 (== (cell-length $cell) 1))
                (let* (
                        ; add it to the singletons list
                        (($f) $cell)
                        ($newsing (cons-atom ($n $f) $newsing1))
                    )
                    ; return the new row
                    $newrow
                )
                ; no singleton change and return the new row
                (let $newsing $newsing1 $newrow)
            )
        )
        ; For the base (empty) case, there are no changes, no new singletons and the histogram is all None
        (let* (
                ($changed False)
                ($newsing ())
                ($histogram (dup-list $N2 None))
            )
            ()
        )
    )
)

!(assertEqualOpt (let $c (process-board-one-row-aux ((1 2 3 4) (1 2 3 4) (1) (2)) 0 4 () $changed $ns $h) ($changed $c $ns $h))
    (False ((1 2 3 4) (1 2 3 4) (1) (2)) () (NoProcess NoProcess NoProcess NoProcess)))
!(assertEqualOpt (let $c (process-board-one-row-aux ((1 2 3 4) (1 2 3 4) (1) (2)) 0 4 ((3 2) (2 1)) $changed $ns $h) ($changed $c $ns $h))
    (True ((3 4) (3 4) (1) (2)) () (NoProcess NoProcess NoProcess NoProcess)))
!(assertEqualOpt (let $c (process-board-one-row-aux ((3 4) (3 4) (1) (2)) 0 4 ((3 2) (2 1)) $changed $ns $h) ($changed $c $ns $h))
    (False ((3 4) (3 4) (1) (2)) () (NoProcess NoProcess NoProcess NoProcess)))
!(assertEqualOpt (let $c (process-board-one-row-aux ((1 2 3) (1 2 3 4) (1) (2)) 0 4 ((3 2) (2 1)) $changed $ns $h) ($changed $c $ns $h))
    (True ((3) (3 4) (1) (2)) ((0 3)) (NoProcess NoProcess NoProcess (1 4))))
!(assertEqualOpt (let $c (process-board-one-row-aux ((1 2 3) (1 2 4) (1 2) (1 2)) 0 4 () $changed $ns $h) ($changed $c $ns $h))
    (False ((1 2 3) (1 2 4) (1 2) (1 2)) () (NoProcess NoProcess (0 3) (1 4))))

;; hist-cleanup takes a histogram with possible NoProcess and None entries, and removes the NoProcess
;; entries, and fails of there are any None entries, which would indicate an unfillable cell
;; Parameters
;;  - list repesenting the histogram
;; Result
;;  - cleaned up histogram (or fail)

(= (hist-cleanup $hist)
    (if-decons-expr $hist $h $t
        (let $tail (hist-cleanup $t)
            (if (== $h NoProcess)
                $tail
                (if (== $h None)
                    (Empty)
                    (cons-atom $h $tail)
                )
            )
        )
        ()
    )
)

!(assertEqualOpt (hist-cleanup (NoProcess (0 3) (1 4) NoProcess)) ((0 3) (1 4)))

;; apply-singleton sets the a single cell of a row to ($x) where $x is the value of the singleton
;; Parameters
;;  - Integer indicating the position in the row (start with this set to 0)
;;  - list of Cells representing a row
;;  - Pair (Integer Integer) representing a singleton - the position in row and the singleton value
;; Returns
;;  - list of Cells representing a row with singleton applied

(= (apply-singleton $n $row $sing)
    (let* (
            ; extract $entry and $value from the singleton parameter
            (($entry $value) $sing)
            ; split the row for this iteration
            (($h $t) (decons-atom $row))
        )
        (if (< $n $entry)
            ; not at entry yet, so go to the next one
            (let $tail (apply-singleton (+ $n 1) $t $sing) (cons-atom $h $tail))
            ; put the singleton in the row, and we are done
            (cons-atom ($value) $t)
        )
    )
)

!(assertEqualOpt (apply-singleton 0 ((1 2 3) (1 2 4) (1 2) (1 2)) (1 4)) ((1 2 3) (4) (1 2) (1 2)))
!(assertEqualOpt (foldl-atom ((1 4) (0 3)) ((1 2 3) (1 2 4) (1 2) (1 2)) $a $b (apply-singleton 0 $a $b)) ((3) (4) (1 2) (1 2)))

;; process-board-one-row applies both heuristics we use to a row
;; each cell and collecting the results
;; Parameters:
;;  - list of Cells representing the row
;;  - Integer size of the board
;;  - list of input singletons
;;  - Boolean indicating whether changed (output)
;;  - list of generated singletons (output)
;; Result:
;;  - list of Cells representing the new row

(= (process-board-one-row $row $N2 $singletons $changed $newsing)
    (let* (
            ; collect the new singleton and histogram data for this row
            ($newrow0 (process-board-one-row-aux $row 0 $N2 $singletons $changed0 $newsing0 $hist))
            ; clean up the histogram to get only the results that will result in new singletons
            ($newhist (hist-cleanup $hist))
            ; combine changed flags
            ($changed (or $changed0 (not (== $newhist ()))))
            ; combine new singleton lists
            ($newsing (append $newsing0 $newhist))
        )
        ; for the singletons generated by the second heuristic (from the histogram), apply them to the row
        (foldl-atom $newhist $newrow0 $a $b (apply-singleton 0 $a $b))
    )
)

!(assertEqualOpt (let $c (process-board-one-row ((1 2 3 4) (1 2 3 4) (1) (2)) 4 () $changed $ns) ($changed $c $ns))
    (False ((1 2 3 4) (1 2 3 4) (1) (2)) ()))
!(assertEqualOpt (let $c (process-board-one-row ((1 2 3 4) (1 2 3 4) (1) (2)) 4 ((3 2) (2 1)) $changed $ns) ($changed $c $ns))
    (True ((3 4) (3 4) (1) (2)) ()))
!(assertEqualOpt (let $c (process-board-one-row ((3 4) (3 4) (1) (2)) 4 ((3 2) (2 1)) $changed $ns) ($changed $c $ns))
    (False ((3 4) (3 4) (1) (2)) ()))
!(assertEqualOpt (let $c (process-board-one-row ((1 2 3) (1 2 3 4) (1) (2)) 4 ((3 2) (2 1)) $changed $ns) ($changed $c $ns))
    (True ((3) (4) (1) (2)) ((0 3) (1 4))))
!(assertEqualOpt (let $c (process-board-one-row ((1 2 3) (1 2 4) (1 2) (1 2)) 4 () $changed $ns) ($changed $c $ns))
    (True ((3) (4) (1 2) (1 2)) ((0 3) (1 4))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Board processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; process-board-aux processes the row by calling process-board-one-row to process each row
;; each cell and collecting the results
;; Parameters:
;;  - list of list of Cells representing the board
;;  - Integer representing which row to work on (should be set to 0 initially)
;;  - Integer size of the board
;;  - list of input singletons
;;  - Boolean indicating whether changed (output)
;;  - list of generated singletons (output)
;; Result:
;;  - list of list of Cells representing the new board

(= (process-board-aux $board $n $N2 $singletons $changed $newsing)
    ; get the first row of the board, if it exists
    (if-decons-expr $board $boardh $boardt
       (let* (
                ; split off the singletons for this row
                (($singh $singt) (decons-atom $singletons))
                ; process one row of the board
                ($newrow (process-board-one-row $boardh $N2 $singh $changedh $newsingh))
                ; turn a two tuple singleton to a three tuple singleton by prepending with row number
                ($newsinghp (map-atom $newsingh $v (cons-atom $n $v)))
                ; recursive call for subsequent rows
                ($tail (process-board-aux $boardt (+ $n 1) $N2 $singt $changedt $newsingt))
                ; combine changed flags
                ($changed (or $changedh $changedt))
                ; combine singleton lists
                ($newsing (append $newsinghp $newsingt))
            )
            (cons-atom $newrow $tail)
        )
        ; if empty board, then not changed and no new singletons
        (let* (($changed False) ($newsing ())) ())
    )
)

!(assertEqualOpt (let $c (process-board-aux (((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4)) ((1 2 3 4) (1 2 3 4) (1) (2)) ((2) (4) (1 2 3 4) (1 2 3 4)) ((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4))) 0 4 (() ((3 2) (2 1)) ((1 4) (0 2)) ()) $changed $newsing) ($changed $c $newsing))
    (True (((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4)) ((3 4) (3 4) (1) (2)) ((2) (4) (1 3) (1 3)) ((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4))) ()))
!(assertEqualOpt (let $c (process-board-aux (((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4)) ((1 2 4) (1 2 3 4) (1) (2)) ((2) (4) (1 2 3 4) (1 2 3 4)) ((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4))) 0 4 (() ((3 2) (2 1)) ((1 4) (0 2)) ()) $changed $newsing) ($changed $c $newsing))
    (True (((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4)) ((4) (3) (1) (2)) ((2) (4) (1 3) (1 3)) ((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4))) ((1 0 4) (1 1 3))))

;; There are two self inverting transformations used to transform the board for row proceesing:
;;  - a straight transpose that converts between columsn and rows
;;  - another transformation that converts between blocks and rows

;; A simple transpose
;; Parameters:
;;  - list of list of cells (a board)
;; Returns:
;;  - list of list of cells (a transposed board)

(: transpose (-> Expression Expression))
(= (transpose-board $b)
    (let* (
            ($h (map-atom $b $v0 (car-atom $v0)))
            ($t (map-atom $b $v0 (cdr-atom $v0)))
            ($tail
                (if (== (car-atom $t) ())
                    ()
                    (transpose-board $t)
                )
            )
        )
        (cons-atom $h $tail)
    )
)

!(assertEqualOpt (transpose-board ((1 2 3) (4 5 6) (7 8 9))) ((1 4 7) (2 5 8) (3 6 9)))

;; The coordinate transform that goes with a transpose - just swap row and column
;; Parameters:
;;  - (row column value) triple
;; Returns:
;;  - transposed (row column value) triple


(: transpose-coordinate (-> Expression Expression))
(= (transpose-coordinate ($x $y $v)) ($y $x $v))

!(assertEqualOpt (transpose-coordinate (1 2 3)) (2 1 3))

;; transpose-block-board is a self-inverting transformation that maps each block onto a row
;; Parameters:
;;  - list of list of cells (a board)
;; Returns:
;;  - list of list of cells (a transformed board)

(: transpose-block-board (-> Expression Expression))
; 0x0 board (only useful as an edge case)
(= (transpose-block-board ()) ())
; 1x1 board (only useful as an edge case)
(= (transpose-block-board (($x))) (($x)))
; 4x4 board
(= (transpose-block-board (
    ($a1 $a2 $a3 $a4)
    ($b1 $b2 $b3 $b4)
    ($c1 $c2 $c3 $c4)
    ($d1 $d2 $d3 $d4)
    )) (
    ($a1 $a2 $b1 $b2)
    ($a3 $a4 $b3 $b4)
    ($c1 $c2 $d1 $d2)
    ($c3 $c4 $d3 $d4)
))
; 9x9 board
(= (transpose-block-board (
    ($a1 $a2 $a3 $a4 $a5 $a6 $a7 $a8 $a9)
    ($b1 $b2 $b3 $b4 $b5 $b6 $b7 $b8 $b9)
    ($c1 $c2 $c3 $c4 $c5 $c6 $c7 $c8 $c9)
    ($d1 $d2 $d3 $d4 $d5 $d6 $d7 $d8 $d9)
    ($e1 $e2 $e3 $e4 $e5 $e6 $e7 $e8 $e9)
    ($f1 $f2 $f3 $f4 $f5 $f6 $f7 $f8 $f9)
    ($g1 $g2 $g3 $g4 $g5 $g6 $g7 $g8 $g9)
    ($h1 $h2 $h3 $h4 $h5 $h6 $h7 $h8 $h9)
    ($i1 $i2 $i3 $i4 $i5 $i6 $i7 $i8 $i9)
    )) (
    ($a1 $a2 $a3 $b1 $b2 $b3 $c1 $c2 $c3)
    ($a4 $a5 $a6 $b4 $b5 $b6 $c4 $c5 $c6)
    ($a7 $a8 $a9 $b7 $b8 $b9 $c7 $c8 $c9)
    ($d1 $d2 $d3 $e1 $e2 $e3 $f1 $f2 $f3)
    ($d4 $d5 $d6 $e4 $e5 $e6 $f4 $f5 $f6)
    ($d7 $d8 $d9 $e7 $e8 $e9 $f7 $f8 $f9)
    ($g1 $g2 $g3 $h1 $h2 $h3 $i1 $i2 $i3)
    ($g4 $g5 $g6 $h4 $h5 $h6 $i4 $i5 $i6)
    ($g7 $g8 $g9 $h7 $h8 $h9 $i7 $i8 $i9)
))

!(assertEqualOpt (transpose-block-board ((1 2 3 4) (5 6 7 8) (9 10 11 12) (13 14 15 16))) ((1 2 5 6) (3 4 7 8) (9 10 13 14) (11 12 15 16)))

;; transpose-block-coordinate is the corresponding coordinate tranformation to transpose-block-board
;; Parameters:
;;  - Integer with square root of the Sudoku size
;;  - (row column value) triple
;; Returns:
;;  - transformed (row column value) triple

(: transpose-block-coordinate (-> Number Expression Expression))
(= (transpose-block-coordinate $N ($y $x $value))
    (let* (
            (($xh $xl) (divmod $x $N))
            (($yh $yl) (divmod $y $N))
        )
        ((+ (* $N $yh) $xh) (+ (* $N $yl) $xl) $value)))

!(assertEqualOpt (map-atom ((0 0 0) (0 1 1) (0 2 2) (0 3 3) (1 0 10) (1 1 11) (1 2 12) (1 3 13) (2 0 20) (2 1 11) (2 2 22) (2 3 23) (3 0 30) (3 1 31) (3 2 32) (3 3 33)) $x (transpose-block-coordinate 2 $x))
    ((0 0 0) (0 1 1) (1 0 2) (1 1 3) (0 2 10) (0 3 11) (1 2 12) (1 3 13) (2 0 20) (2 1 11) (3 0 22) (3 1 23) (2 2 30) (2 3 31) (3 2 32) (3 3 33)))

;; sort-singleton, given a singleton triple (row column value) and a list of lists of singleton pairs,
;; takes the row element of the singleton and uses that to determine which list of the list of lists of
;; singleton pairs to append the column and value to.
;; Parameters:
;;  - (row column value) triple
;;  - list of list of 2 value singletons
;; Returns:
;;  - list of list of 2 value singletons

(: sort-singleton (-> %Undefined% %Undefined% %Undefined%))
(= (sort-singleton ($s1 $s2 $s3) $a)
    (let ($h $t) (decons-atom $a)
        (if (== $s1 0)
            (let $h2 (cons-atom ($s2 $s3) $h) (cons-atom $h2 $t))
            (let $t2 (sort-singleton ((- $s1 1) $s2 $s3) $t) (cons-atom $h $t2))
        )
    )
)

!(assertEqualOpt (sort-singleton (2 3 2) (() () () ())) (() () ((3 2)) ()))
!(assertEqualOpt (foldl-atom () (() () () ()) $a $b (sort-singleton $a $b)) (() () () ()))
!(assertEqualOpt (foldl-atom ((1 2 1)) (() () () ()) $a $b (sort-singleton $b $a)) (() ((2 1)) () ()))
!(assertEqualOpt (foldl-atom ((1 2 1) (1 2 2) (3 2 1)) (() () () ()) $a $b (sort-singleton $b $a)) (() ((2 2) (2 1)) () ((2 1))))

;; sort-singleton-list is used to group a list of 3 pair singletons to a list of lists of 2 pair singletons
;; This is useful for having each row processed separately
;; Parameters:
;;  - Number represeiting the size of the Sudiku
;;  - list of 3 value singletons
;; Returns:
;;  - list of list of 2 value singletons

(: sort-singleton-list (-> Number Expression Expression))
(= (sort-singleton-list $N2 $singletons)
    (let $empty-sing (dup-list $N2 ()) (foldl-atom $singletons $empty-sing $a $b (sort-singleton $b $a))))

!(assertEqualOpt (sort-singleton-list 4 ((1 3 2) (1 2 1) (2 1 4) (2 0 2))) (() ((2 1) (3 2)) ((0 2) (1 4)) ()))

;; process-board-single-iteration does a single iteration of the heuristics on each dimension (row, column, block)
;; to reduce the values that cells can have and find any singletons
;; Parameters:
;;  - list of list of Cells (a board)
;;  - Integer representing square root of the board size
;;  - list of singletons not yet processed
;;  - Bool to indicate if any change occurred (output)
;;  - list of new singletons found
;; Returns:
;;  - altered list of list of Cells (a board)

(: process-board-single-iteration (-> Expression Number Expression Bool Expression Expression))
(= (process-board-single-iteration $board $N $singletons $changed $newsing)
    (let* (
            ; determine board size from suqare root of board size
            ($N2 (* $N $N))

            ; first rows
            ; divide the singletons out into rows
            ($singsorted (sort-singleton-list $N2 $singletons))
            ; apply heuristics to the rows, reporting any change or new singletons
            ($board0 (process-board-aux $board 0 $N2 $singsorted $changed0 $newsing0))

            ; columns
            ; transform the board so that we can investigate columns
            ($board0t (transpose-board $board0))
            ; similiarly, transform the singletons
            ($singletonst (map-atom $singletons $v0 (transpose-coordinate $v0)))
            ; divide the singletons out into columns (transformed into rows)
            ($singletonstsorted (sort-singleton-list $N2 $singletonst))
            ; apply heuristics to the columns (transformed into rows), reporting any change or new singletons
            ($board1t (process-board-aux $board0t 0 $N2 $singletonstsorted $changed1 $newsing1t))
            ; transform the board back to original orientation
            ($board1 (transpose-board $board1t))
            ; transform any singletons found back to the original orientation
            ($newsing1 (map-atom $newsing1t $v1 (transpose-coordinate $v1)))

            ; the blocks
            ; transform the board so that we can investigate blocks
            ($board1u (transpose-block-board $board1))
            ; similiarly, transform the singletons
            ($singletonsu (map-atom $singletons $v2 (transpose-block-coordinate $N $v2)))
            ; divide the singletons out into blocks (transformed into rows)
            ($singletonsusorted (sort-singleton-list $N2 $singletonsu))
            ; apply heuristics to the blocks (transformed into rows), reporting any change or new singletons
            ($board2u (process-board-aux $board1u 0 $N2 $singletonsusorted $changed2 $newsing2u))
            ; transform the board back to original orientation
            ($board2 (transpose-block-board $board2u))
            ; transform any singletons found back to the original orientation
            ($newsing2 (map-atom $newsing2u $v3 (transpose-block-coordinate $N $v3)))

            ; combine the change flags and new singletons
            ($changed (or $changed0 (or $changed1 $changed2)))
            ($newsing (append $newsing0 (append $newsing1 $newsing2)))
        )
        ; return the resulting board
        $board2
    )
)

; !(let $c (process-board-single-iteration (((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4)) ((1 2 3 4) (1 2 3 4) (1) (2)) ((2) (4) (1 2 3 4) (1 2 3 4)) ((1 2 3 4) (1 2 3 4) (1 2 3 4) (1 2 3 4))) 2 ((1 3 2) (1 2 1) (2 1 4) (2 0 2)) $changed $newsing) ($changed $c $newsing))

;; process-board-fixed repeats calls to process-board-single-iteration until a fixed point is reached
;; Parameters:
;;  - Integer representing the iteration count
;;  - Integer for number of non-singleton (ambiguous) cels left
;;  - list of list of Cells (a board)
;;  - Integer representing square root of the board size
;;  - list of singletons not yet processed
;; Returns:
;;  - altered list of list of Cells (a board)

(: process-board-fixed (-> Number Number Number Expression Number Expression Expression))
(= (process-board-fixed $iteration $left $leftout $board $N $singletons)
    (if (== $left (size-atom $singletons))
        (let $leftout 0 $board)
        (let* (
                ($newleft (- $left (size-atom $singletons)))
                (() (println! (format-args "Iteration:{}, cells left {}" ($iteration $newleft))))
                ($board2 (process-board-single-iteration $board $N $singletons $changed $newsing))
            )
            (if $changed
                (process-board-fixed (+ $iteration 1) $newleft $leftout $board2 $N $newsing)
                (let $leftout (- $newleft (size-atom $newsing)) $board2)
            )
        )
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backtracking support
;; These are functions that pick the smallest non singleton cell in a board
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; smallest-multicell-row returns the lowest cardinality in a row that is not a singleton
;; Parameters:
;;  - list of Cells
;;  - Integer position in the row - always start with zero
;;  - smallest cardinality greater than one (1000 if not found)
;; Returns:
;;  - a pair consisting of a position and a cell of the form (column, cell) corresponding with the
;; cardinality, or () if the cardinality is 1000.

(: smallest-multicell-row (-> Expression Number Number Expression))
(= (smallest-multicell-row $row $n $smallest)
    (if-decons-expr $row $h $t
        (let* (
                ($best (smallest-multicell-row $t (+ $n 1) $smallest0))
                ($len (size-atom $h))
            )
            (if (and (< 1 $len) (<= $len $smallest0))
                (let $smallest $len ($n $h))
                (let $smallest $smallest0 $best)
            )
        )
        (let $smallest 1000 ())
    )
)

!(assertEqualOpt (smallest-multicell-row (() (1) (3 2) (1) (4 3) (5)) 0 $smallest) (2 (3 2)))

;; smallest-multicell returns the lowest cardinality in a board that is not a singleton
;; Parameters:
;;  - list of list of Cells (a board)
;;  - Integer column position - always start with zero
;;  - smallest cardinality greater than one (1000 if not found)
;; Returns:
;;  - a triple consisting of a position and a cell of the form (row column cell) corresponding with
;; the cardinality, or () if the cardinality is 1000.

(= (smallest-multicell $board $n $smallest)
    (if-decons-expr $board $h $t
        (let* (
                ($best (smallest-multicell $t (+ $n 1) $smallest0))
                ($bestrow (smallest-multicell-row $h 0 $smallestrow))
            )
            (if (< $smallestrow $smallest0)
                (let $smallest $smallestrow (cons-atom $n $bestrow))
                (let $smallest $smallest0 $best)
            )
        )
        (let $smallest 1000 ())
    )
)

!(assertEqualOpt (smallest-multicell (() ((4)) (() (1) (3 2) (1) (4 3) (5)) ((3))) 0 $smallest) (2 2 (3 2)))
!(assertEqualOpt (smallest-multicell (((4)) (() (1) (3 2) (1) (4 3) (5))) 0 $smallest) (1 2 (3 2)))

;; update-row takes a row, a position and a value, and replaces that position (counting from 0) by the value
;; Parameters:
;;  - list Cells (a row)
;;  - Integer position (0 indexed)
;;  - replacement value
;; Returns:
;;  - altered list Cells (a row)

(: update-row (-> Expression Number Expression Expression))
(= (update-row $row $n $value)
    (let ($h $t) (decons-atom $row)
        (if (> $n 0)
            (let $tail (update-row $t (- $n 1) $value) (cons-atom $h $tail))
            (cons-atom $value $t)
        )
    )
)

!(assertEqualOpt (update-row (() (1) (3 2) (1) (4 3) (5)) 2 xxx) (() (1) xxx (1) (4 3) (5)))

;; update-row takes a board, row and column positions, and a value, and replaces that position
;; (counting from 0) by the value
;; Parameters:
;;  - list of list of Cells (a board)
;;  - Integer row (0 indexed)
;;  - Integer column (0 indexed)
;;  - replacement value
;; Returns:
;;  - altered list of list of Cells (a board)

(: update-board (-> Expression Number Number Expression Expression))
(= (update-board $board $r $c $value)
    (let ($h $t) (decons-atom $board)
        (if (> $r 0)
            (let $tail (update-board $t (- $r 1) $c $value) (cons-atom $h $tail))
            (let $nv (update-row $h $c $value) (cons-atom $nv $t))
        )
    )
)

!(assertEqualOpt (update-board (() ((4)) (() (1) (3 2) (1) (4 3) (5)) ((3))) 2 2 xxx) (() ((4)) (() (1) xxx (1) (4 3) (5)) ((3))))

;; process-board-backtrack does the main work, it takes an incomplete board and returns a solution.
;; It calls process-board-fixed to solve the board as far as possible using its heuristics
;; If there are still cells that are not singletons, a cell is plcked and all its values are tried
;; by calling this recursively
;; Parameters:
;;  - Integer representing the iteration count
;;  - Integer for number of non-singleton (ambiguous) cels left
;;  - list of list of Cells (a board)
;;  - square root of the board size
;;  - list of singletons not yet processed
;; Returns:
;;  - altered list of list of Cells (a board)

(: process-board-backtrack (-> Number Number Expression Number Expression Expression))
(= (process-board-backtrack $iteration $left $board $N $singletons)
    ; solve the board as far as possible using the basic heuristics
    (let $bnext (process-board-fixed $iteration $left $leftout $board $N $singletons)
        ; see of there are any cells left to solve
        (if (== $leftout 0)
            ; we are done, so return the solved board
            $bnext
            ; find the smallest ambiguous cell
            (let* (
                    ; pick a cell (with lowest cardinality in a row that is not a singleton)
                    (($r $c $values) (smallest-multicell $bnext 0 $_smallest))
                    ; try each balue from a cell. This is where the backtracking happens
                    ($v (superpose $values))
                    (() (println! "backtracking"))
                    ; update board with the chosen value
                    ($bupdate (update-board $bnext $r $c ($v)))
                    ; call process-board-backtrack with the new board, and the tried value
                    ; as the new unprocessed singletin list
                    ($bfinal (process-board-backtrack 0 $leftout $bupdate $N (($r $c $v))))
                )
                $bfinal
            )
        )
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Get singletons on startup
;; This is only done once - on later iterations, the singletons are generated from the last pass
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; extract-singletons gets all the singletons from the initial board
;; Parameters:
;;  - list of list of Cells - the sudoku board to solve
;; Returns:
;;  - list of triples of integers - the singletons

(: extract-singletons (-> Expression Expression))
(= (extract-singletons $B)
    (let* (
            ($c (map-atom $B $r (collect-singleton1 0 $r)))
            ($x (collect-singleton2 0 $c))
        )
        (append-all $x)
    )
)

;; collect-singleton2 gets all the singletons from a single row
;; Parameters:
;;  - Integer position (pass in 0)
;;  - list of Cells - a row of the sudoku board to solve
;; Returns:
;;  - list of pairs of integers - the singletons

(: collect-singleton1 (-> Number Expression Expression))
(= (collect-singleton1 $n $r)
    (if-decons-expr $r $h $t
        (let* (
                ($tail (collect-singleton1 (+ $n 1) $t))
                (($v $tt) (decons-atom $h))
            )
            (if (== $tt ()) (cons-atom ($n $v) $tail) $tail))
        ()
    )
)

;; collect-singleton2 gets all the singletons from a single row
;; Parameters:
;;  - Integer position (pass in 0)
;;  - list of list of pairs of integers - the singletons, grouped by row
;; Returns:
;;  - list of triples of integers - all the singletons with row information

(: collect-singleton2 (-> Number Expression Expression))
(= (collect-singleton2 $n $r)
    (if-decons-expr $r $h $t
        (let* (
                ($tail (collect-singleton2 (+ $n 1) $t))
                ($m (map-atom $h $v (cons-atom $n $v)))
            )
            (cons-atom $m $tail)
        )
        ()
    )
)

;; sudoku-n is where everything gets tied together
;; Parameters:
;;  - the square root of the board size (2 or 3)
;;  - list of list of values - the sudoku board to solve
;; Returns:
;;  - The solutions

(: sudoku-n (-> Number Expression Expression))
(= (sudoku-n $N $B)
    (let* (
            ; Determine the size of the Sudoku from the size of the block
            ($N2 (* $N $N))
            ; Convert from input form to internal form
            ($bx (map-atom $B $r (map-atom $r $v (value-to-cell $N2 $v))))
            ; Extract the initial singletons (this is done only once)
            ($singletons (extract-singletons $bx))
            ; Solve the Sudoku. All the heavy lifting happens here
            ($bxf (process-board-backtrack 1 (* $N2 $N2) $bx $N $singletons))
            ; convert from internal form to display form
            ($bx2 (map-atom $bxf $rx (map-atom $rx $vx (cell-to-value $vx))))
            ; Display the results
            ($_ (map-atom $bx2 $x (let () (println! $x) ())))
        )
        $bx2
    )
)

;; Suduku normally means the 9x9 case, so lets create a case where the size doesn't need to be specified. This is nondetermisintic
;; Parameters:
;;  - list of list of values - the sudoku board to solve
;; Returns:
;;  - The solutions

(: sudoku (-> Expression Expression))
(= (sudoku $B) (sudoku-n 3 $B))

;; Test some edge cases

!(assertEqualOpt (sudoku-n 0 ()) ())

;; comment out this test because it returns output
;!(assertEqualOpt (sudoku-n 1 ((x))) ((1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Examples
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A 4x4

!(sudoku-n 2 ((x x x x) (x x 1 2) (2 4 x x) (x x x x)))

;    (x x x x)
;    (x x 1 2)
;    (2 4 x x)
;    (x x x x)

;; An underspecified 4x4, so it will have to backtrack to get all the solutions

;!(sudoku-n 2 ((x x x x) (x x 1 2) (2 x x x) (x x x x)))

;    (x x x x)
;    (x x 1 2)
;    (2 x x x)
;    (x x x x)

;; Return all the possible 4x4 Sudokus (specifying 4 elements to factor out substitution)

;!(sudoku-n 2 ((1 2 3 4) (x x x x) (x x x x) (x x x x)))

;; An easy 9x9. No backtracking required

;!(sudoku ( (x x x x 2 x 3 5 x) (3 9 x 8 x x 7 6 x) (x x x x x x x x 9) (x x x 6 x 5 x 9 x) (5 8 x x x 4 x 2 6) (x x x 2 x 9 5 8 3) (4 x x 5 x 8 9 3 x) (x x 1 3 4 2 6 x 8) (6 x x 1 x 7 2 x 5) ))

;    (x x x x 2 x 3 5 x)
;    (3 9 x 8 x x 7 6 x)
;    (x x x x x x x x 9)
;    (x x x 6 x 5 x 9 x)
;    (5 8 x x x 4 x 2 6)
;    (x x x 2 x 9 5 8 3)
;    (4 x x 5 x 8 9 3 x)
;    (x x 1 3 4 2 6 x 8)
;    (6 x x 1 x 7 2 x 5)

;; A really hard 9x9. Backtracking is required here

;!(sudoku ( (3 x 8 5 x 4 9 x x) (9 x x x x x x 2 x) (x x x 1 x x x x x) (x 6 x x x x x x 7) (x x 5 9 x 8 2 x x) (x x x x 3 x x x x) (x x x x 1 x 4 x x) (x x 3 x 2 x x x x) (x 5 x 4 x 3 x 6 x) ))

;    (3 x 8 5 x 4 9 x x)
;    (9 x x x x x x 2 x)
;    (x x x 1 x x x x x)
;    (x 6 x x x x x x 7)
;    (x x 5 9 x 8 2 x x)
;    (x x x x 3 x x x x)
;    (x x x x 1 x 4 x x)
;    (x x 3 x 2 x x x x)
;    (x 5 x 4 x 3 x 6 x)

;; Return all the possible 9x9 Sudokus (specifying 4 elements to factor out substitution). NOTE: this will not complete in any reasonable length of time

;!(sudoku ((1 2 3 4 5 6 7 8 9) (x x x x x x x x x) (x x x x x x x x x) (x x x x x x x x x) (x x x x x x x x x) (x x x x x x x x x) (x x x x x x x x x) (x x x x x x x x x) (x x x x x x x x x)))

