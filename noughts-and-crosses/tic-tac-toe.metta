;; ----------------------------------------
;; Game setup: declare players and their relationships
;; ----------------------------------------

;; Declare 'X' and 'O' as valid Player atoms
(: X Player) 
(: O Player)

;; Define the opponent function: returns the other player
(: opponent (-> Player Player))
(= (opponent X) O)
(= (opponent O) X)

;; ----------------------------------------
;; Entry point: Starts the game
;; ----------------------------------------

(= (ask-who-plays)
  (let* 
    ;; Prompt user to choose player or press Enter for AI vs AI
    (($_1 (println! "If you want AI to play by itself press enter, otherwise choose X or O."))
     ;; Read user input and assign human player if applicable
     ($_2 (case (read-atom)
          ((X (add-atom &self (is-human X)))
            (x (add-atom &self (is-human X)))
            (o (add-atom &self (is-human O)))
            (O (add-atom &self (is-human O)))
            ($_))
	           True)))))

;; Default behavior: start game with empty board and 'X' playing first
(= (play-now) (play-game (1 2 3 4 5 6 7 8 9) X))

;; ----------------------------------------
;; Main game loop
;; ----------------------------------------

(= (play-game $Board $Player)
  (let $_1 (display-board $Board) ;; Show current board state
      (let $Winner (collapse (winner $Board)) ;; Check for winner
        (if (non-empty $Winner)
          (println! ($Winner "wins!")) ;; 🏁 Game ends with winner
          (if (is-tie $Board)
            (println! ("It was a draw!")) ;; 🤝 Game ends in tie
            ;; Otherwise, choose move and continue playing
            (let $Move (choose-move $Board $Player)
              (let $_2 (println! ($Player Move $Move))
                (let $NewBoard (move $Board $Move $Player)
                  (play-game $NewBoard (opponent $Player))))))))))

;; ----------------------------------------
;; Display the board in a formatted grid
;; ----------------------------------------

(= (display-board $Nine)
  (println! (format-args "\n
       {} | {} | {}
      -----------
       {} | {} | {}
      -----------
       {} | {} | {}

\n" $Nine)))

;; ----------------------------------------
;; Decide who makes the move — AI or Human
;; ----------------------------------------

(= (choose-move $Board $Player)
  (if (== () (collapse (match &self (is-human $Player) True)))
    (computer-move $Board $Player) ;; AI makes move
    (human-move $Player)))         ;; Human inputs move

;; Prompt human for move input (1–9)
(= (human-move $Player)
  (let $_ (println! ("Your move " $Player " (1–9):")) (read-atom)))

;; Parse user input into a usable atom
(= (read-atom)
  (let $s ((py-atom input)) (parse $s)))

;; ----------------------------------------
;; AI Move Logic with Visual Feedback
;; ----------------------------------------

(= (computer-move $Board $Player)
  (let $Opponent (opponent $Player)                             ;; Determine the opponent
    (let $Moves (available-moves $Board)                       ;; Get available positions
      (let $_ (println! ("Computer is moving as " $Player "...")) ;; Announce turn
        ;; Try to win if possible
        (let $Move (collapse (winning-move $Board $Player))
          (if (non-empty $Move)
            (let $_msg (println! ("🏆 Taking winning move for " $Player "!"))
              (car-atom $Move))                                ;; Take winning move
            ;; Otherwise, try to block opponent
            (let $Move2 (collapse (winning-move $Board $Opponent))
              (if (non-empty $Move2)
                (let $_msg (println! ("🛡️ Blocking " $Opponent " from winning!"))
                  (car-atom $Move2))                           ;; Block winning threat
                ;; Else pick random legal move
                (let $_msg (println! ("🎲 No win or threat — picking a random move."))
                  (random-atom $Moves))))))))))                ;; Default to random move

;; ----------------------------------------
;; Win prediction utilities
;; ----------------------------------------

;; Create a choice point over all possible move positions
(= (move-choices $Board)
    (let $Moves (available-moves $Board)
	   (superpose $Moves)))

;; Determine if a given move results in a win
(= (winning-move $Board $Player)
    (let $Place (move-choices $Board)
	  (let $newboard (move $Board $Place $Player)
        (let $Player (winner $newboard) 
		   $Place))))

;; Utility function: check if result is non-empty
(: non-empty (-> Expression Bool))
(= (non-empty $list) (not (== () $list)))

;; ----------------------------------------
;; Move validation and board state checks
;; ----------------------------------------

;; Helper: alternate way to get available numbered positions
(= (available-moves-mettalog-only $Board) (filter-atom $Board $x (eval (number-p $x))))

(: number-p (-> Atom Bool))
(= (number-p $v) (== Number (get-type $v))) ;; Atom is available if it's a Number

;; Recursive function to extract all unfilled positions
(= (available-moves $list)
  (if (== () $list)
	$list	
    (let* (($head (car-atom $list))
           ($rest (cdr-atom $list))
		   ($newrest (available-moves $rest)))
	   (if (== Number (get-type $head))
		  (cons-atom $head $newrest)
		  $newrest))))

;; A tie occurs when no valid moves remain
(= (is-tie $Board) (== () (available-moves $Board)))

;; ----------------------------------------
;; Winning combinations
;; ----------------------------------------

;; All 8 win conditions (3 rows, 3 columns, 2 diagonals)
(win-pos 1 2 3) (win-pos 4 5 6) (win-pos 7 8 9)
(win-pos 1 4 7) (win-pos 2 5 8) (win-pos 3 6 9)
(win-pos 1 5 9) (win-pos 3 5 7)

;; Determine winner by matching board values at win positions
(: winner (-> Expression Atom))
(= (winner $Board)
  (match &self (win-pos $A $B $C)
    (let $W (nth_x $Board $A)
	  (let $W (nth_x $Board $B)
		(let $W (nth_x $Board $C)
		   $W)))))

;; ----------------------------------------
;; List utilities: indexing and replacement
;; ----------------------------------------

;; Retrieve the Nth element in a list
(: nth_x (-> Expression Number Atom))
(= (nth_x $list $index)
   (if (== () $list) (empty)
  (if (== $index 1)
    (car-atom $list)
    (let* (($rest (cdr-atom $list))
           ($idx (- $index 1)))
         (nth_x $rest $idx)))))

;; Replace the Nth element in a list with a new value
(: move (-> Expression Number Atom Expression))
(= (move $list $index $replacement)
  (if (== $index 1)
    (let $rest (cdr-atom $list) (cons-atom $replacement $rest))
    (let* (($head (car-atom $list))
           ($rest (cdr-atom $list))
           ($idx (- $index 1))
           ($newrest (move $rest $idx $replacement)))
         (cons-atom $head $newrest))))

;; Choose a random value from a list
; (: random-atom (-> Expression Atom))
(= (random-atom $list)
 (if (== () $list) (empty)
  (let $len (size-atom $list)
    (let $i2 (+ $len 1)
	 (let $index (random-int &rng 1 $i2)
        (nth_x $list $index))))))

;; ----------------------------------------
;; Sanity tests (for development use only)
;; ----------------------------------------


(= (my-tests)
 (,
  (display-board (X X X 4 5 6 O O O)) ;; Should show X win on top row
  (set-random-seed &rng 0)
  (random-atom (1 2 3 4 5 6 7 8 9))   ;; Random move demo
  (random-int &rng 1 10)
  (assertEqualToResult (random-atom (1)) (1)) ;; Edge case: only one option
  (assertEqualToResult (random-atom ()) ())   ;; Edge case: no options
  (assertEqualToResult (winner (O O 3 4 5 6 X X X)) (X)) ;; X wins in bottom row
  (assertEqualToResult (available-moves (O O 3 4 5 6 X X X)) ((3 4 5 6)))
  (assertEqualToResult (move-choices (O O 3 4 5 6 X X X)) (6 5 4 3)) ;; Should list in reverse
  (assertEqualToResult (winning-move (O O 3 4 5 6 7 8 9) O) (3))     ;; O can win
  (assertEqualToResult (winning-move (O O 3 4 5 6 7 8 9) X) ())      ;; X cannot win
  (assertEqualToResult (winning-move (O O 3 4 5 6 7 X X) X) (7))     ;; X can win with 7
))

;; ----------------------------------------
;; Entry point: starts AI vs AI by default
;; ----------------------------------------

;; Optionally, uncomment one of these to **force the human to play as X or O**:
; (is-human X)  ;; Human goes first (as X)
; (is-human O)  ;; Human goes second (as O)

;; Or, uncomment this to **ask at runtime** who should play:
; !(ask-who-plays)

;; Or, uncomment to run test cases:
; !(my-tests)

!(set-random-seed &rng 0)
!(random-int &rng 1 10)
!(random-int &rng 1 10)
!(random-int &rng 1 10)

!(assertEqualToResult (play-now) (()))

; !(repl!)
!(random-int &rng 1 10)
!(random-int &rng 1 10)
!(random-int &rng 1 10)

