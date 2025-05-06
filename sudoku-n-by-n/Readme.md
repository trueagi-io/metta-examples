# MeTTa Sudoku Solver

This is a Sudoku solver written in MeTTa. It solves 4x4 or 9x9 Sudoku, and could easily be expanded to deal with larger sizes
Written by Roy Ward, roy@orange-kiwi.com

## Usage: 

An inital board is needed that is an array of arrays, with each element being a number from 0 to Sudoku size inclusive for the known values, and anything else for the value to be solved. (I suggest "x" without the quotes for this).

For a 9x9, use the function sudoku as given in this example:
```
!(sudoku (
   (x x x x 2 x 3 5 x)
   (3 9 x 8 x x 7 6 x)
   (x x x x x x x x 9)
   (x x x 6 x 5 x 9 x)
   (5 8 x x x 4 x 2 6)
   (x x x 2 x 9 5 8 3)
   (4 x x 5 x 8 9 3 x)
   (x x 1 3 4 2 6 x 8)
   (6 x x 1 x 7 2 x 5) ))
```

For a different size (currently only 4x4 and 9x9 are supported), call sudoku-n with the square root of the size (the size of a cell) given as a parameter:

```
!(sudoku-n 2 (
   (x x x x)
   (x x 1 2)
   (2 4 x x)
   (x x x x) ))
```

## Targets

This runs under both:

* Hyperon Experimental: https://github.com/trueagi-io/hyperon-experimental
* Mettalog: https://github.com/trueagi-io/metta-wam
