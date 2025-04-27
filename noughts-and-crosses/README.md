---

# MeTTa Tic-Tac-Toe Simulation

This project demonstrates a **Tic-Tac-Toe** game where two AI players ("X" and "O") play against each other using different inference engines.

---

## Table of Contents
- [Game Overview](#game-overview)
- [Performance Comparison](#performance-comparison)
- [Playing Against the Computer](#playing-against-the-computer)
- [Notes](#notes)
- [Full Playthrough Log](#full-playthrough-log)

---

## Game Overview

The Tic-Tac-Toe board is represented like this:

```
 1 | 2 | 3
-----------
 4 | 5 | 6
-----------
 7 | 8 | 9
```

Each number corresponds to a cell, and players take turns marking a cell (`X` or `O`).

### Sample Playthrough Summary

- **First Move**: X plays at cell 5 (random).
- **O's Move**: O plays at cell 9 (random).
- **X's Move**: X plays at cell 4.
- **O's Move**: O blocks X by playing at cell 6.
- **X's Move**: X blocks O by playing at cell 3.
- **O's Move**: O blocks X by playing at cell 7.
- **X's Move**: X blocks O by playing at cell 8.
- **O's Move**: O blocks X by playing at cell 2.
- **X's Move**: X plays at cell 1.

**Result**:  
The game ended in a **draw**.

---

## Performance Comparison

| Engine               | Time Taken | Usage                                      |
|----------------------|------------|--------------------------------------------|
| MeTTaLog Compiler     | 0.04s      | `mettalog --compile=full tic-tac-toe.metta` |
| MeTTaLog Interpreter  | 6.21s      | `mettalog tic-tac-toe.metta`               |
| Hyperon Experimental  | 62.06s     | `metta tic-tac-toe.metta`                  |

- **Compiler** is extremely fast.
- **Interpreter** is slower but playable.
- **Hyperon Experimental** is 1500x slower (on 4/26/2025)

---

## Playing Against the Computer

By default, the simulation runs **AI vs AI**.

You can **optionally** change this by editing the bottom of [**`tic-tac-toe.metta`**](./tic-tac-toe.metta):

```lisp
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

;; Optionally drop into a REPL after the game (mettalog only):
; !(repl!)

!(random-int &rng 1 10)
!(random-int &rng 1 10)
!(random-int &rng 1 10)
```

---

### Available Options:

| Option                  | Behavior                                                |
|--------------------------|---------------------------------------------------------|
| ``(is-human X)``          | Force human to play as **X** (you go first).            |
| ``(is-human O)``          | Force human to play as **O** (you go second).           |
| ``!(ask-who-plays)``      | Ask interactively at game start if a human will play.   |
| ``!(my-tests)``           | Run internal test cases instead of a normal game.       |
| ``!(repl!)``              | (Optional) Drop into a REPL **after** the game finishes (**mettalog only**). |

---

### Example: Play as Human (Second Player)

To play as **O** (human goes second):

1. Uncomment this line:
   ```lisp
   (is-human O)
   ```
2. Save the file and rerun:

   ```bash
   mettalog --compile=full tic-tac-toe.metta
   # or
   mettalog tic-tac-toe.metta
   # or
   metta tic-tac-toe.metta
   ```

---

## Notes

- The AI checks for winning moves and blocks the opponent if necessary.
- If no immediate threat or opportunity is found, it selects a random move.
- This simulation demonstrates basic **threat detection** and **blocking strategies**.
- Randomness is seeded using ``!(set-random-seed &rng 0)`` for reproducibility.
- The game starts using ``(play-now)``, verified cleanly by ``!(assertEqualToResult ...)``.
- You can optionally drop into an interactive REPL afterward using ``!(repl!)`` (**only with `mettalog`**).

---

## Full Playthrough Log

```
; MeTTaLog-Compiler:  0.04 seconds.
; MeTTaLog-Interpeter:  6.21 seconds.
; Hyperon-Experimatal: 62.06 seconds.

       1 | 2 | 3
      -----------
       4 | 5 | 6
      -----------
       7 | 8 | 9

("Computer is moving as " X "...")
("? No win or threat — picking a random move.")
(X Move 5)

       1 | 2 | 3
      -----------
       4 | X | 6
      -----------
       7 | 8 | 9

("Computer is moving as " O "...")
("? No win or threat — picking a random move.")
(O Move 9)

       1 | 2 | 3
      -----------
       4 | X | 6
      -----------
       7 | 8 | O

("Computer is moving as " X "...")
("? No win or threat — picking a random move.")
(X Move 4)

       1 | 2 | 3
      -----------
       X | X | 6
      -----------
       7 | 8 | O

("Computer is moving as " O "...")
("?? Blocking " X " from winning!")
(O Move 6)

       1 | 2 | 3
      -----------
       X | X | O
      -----------
       7 | 8 | O

("Computer is moving as " X "...")
("?? Blocking " O " from winning!")
(X Move 3)

       1 | 2 | X
      -----------
       X | X | O
      -----------
       7 | 8 | O

("Computer is moving as " O "...")
("?? Blocking " X " from winning!")
(O Move 7)

       1 | 2 | X
      -----------
       X | X | O
      -----------
       O | 8 | O

("Computer is moving as " X "...")
("?? Blocking " O " from winning!")
(X Move 8)

       1 | 2 | X
      -----------
       X | X | O
      -----------
       O | X | O

("Computer is moving as " O "...")
("?? Blocking " X " from winning!")
(O Move 2)

       1 | O | X
      -----------
       X | X | O
      -----------
       O | X | O

("Computer is moving as " X "...")
("? No win or threat — picking a random move.")
(X Move 1)

       X | O | X
      -----------
       X | X | O
      -----------
       O | X | O

("It was a draw!")
```


