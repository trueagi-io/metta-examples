## What does this code do?

It redefines _unary_ atoms like `(a)` or `(Hi)` to perform queries on the space, matching all _binary_ instances like `(a 1)`, `(hi "friend")`, or `(probability (($Expression) %odds%))`, potentially applying a function to all wrapped values.

(mapping all results to 'wrapped' values of type `M`)

Usage:

```clojure
(= (add1 $n) (+ $n 1))

(A 1)
(A 2)

!(gimme A) ; outputs [1, 2]

!(to A add1)
!(gimme A) ; outputs [2, 3]

!(A) ; outputs [(mkM 2), (mkM 3)]
```

## How does it work? What are M and mkM ?

`M` is a type from any type `$U` to a new type `M $U` (just the original type, but wrapped in `M`)
You can instantiate a new type using the type-constructor `mkM`.

```clojure
!(get-type (mkM 1)) ; outputs [(: M Number)]
```

M has the special property that you can apply any function to the wrapped value by passing the function 'as first argument` to M.

```clojure
!((mkM 1) add1) ; outputs [(mkM 2)]
```

Since `((mkM A) B) == (mkM (B A))` under all circumstances, instances of `M` are functors, in particular when B is a morphism from `(get-type A)` to any type.

# Use cases

- simplified syntax
- easier querying
- groundwork for advanced control flow (Result, Success, Error, Maybe, Just)
- easy way to define new expressions that are more readable (e.g. `(from e1 to e2 add1)` will query all values of the form `(e1 $x)`, apply `add1` to each value, and store them under a new label `e2`) You can define such expressions in 1 line of code.
