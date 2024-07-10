# Basic stack interpreter and rewriter

## Interpreter example
[interpreter.metta](interpreter.metta)
A stack interpreter is defined tail-recursively as processing a provided stack.
For example:
```scheme
(= ((basic $s) (put $x)) (basic ($s $x)))
(= ((basic (($s $x) $y)) add) (basic ($s (+ $x $y))))
(= ((basic ($s $x)) say) (let $_ (println! $x) (basic $s)))
```

Then, a program is a stack waiting for an interpreter to be applied:
```scheme
(= (f1 $int) (((($int (put 2)) (put 3)) add) say))
```
which does the obvious thing `!(f1 (basic E))` results in `5` being printed and `(basic E)` being returned (no more work).

This could be an interpreter defined as a grounded function is Rust, or embed a domain-specific stack language like [Uiua](https://www.uiua.org/).

## Rewriter example
[rewrites.metta](rewrites.metta)

We can rewrite the instruction stream with constant folding operations.
For example, some stack manipulation:
```scheme
(= (($s $x) dup) (($s $x) $x))
(= ((($s $x) $y) swap) (($s $y) $x))
(= (($s $x) drop) $s)
(= (((($s $x) $y) $z) rot) ((($s $y) $z) $x))
(= ((($s $x) $y) over) ((($s $x) $y) $x))
```
rewrites `!((((($int (put 2)) dup) mul) (put 5)) swap)` to `(($int 5) 4)`.
