# Aunt Knowledge Graph

An exploration in knowledge graphs, raised by
https://github.com/trueagi-io/metta-examples/issues/40

The goal is to evaluate how expressive, intuitive, and performant MeTTa is for dealing with regular labeled graphs.



## Start here and Conceptual
True to the original issue we work with ancestral graphs.
The original hand-crafted graph is [toy_simple.metta]()

WIP

## Data and conversion

WIP

https://codesandbox.io/p/sandbox/delicate-haze-2zv77m

## Benchmarks

WIP

### Hyperon-Experimental

Simpsons Dataset (11 people)
[simple_conversion.metta]() 0m0.113s
[baseline_formulation.metta]() 0m0.178s
[sergey_rodionov_formulation.metta]() 0m1.028s

Lord of the Rings Dataset (86 people)
[simple_conversion.metta]() 0m2.171s
[baseline_formulation.metta]() ERROR: thread 'main' has overflowed its stack (at 8m26.809s and 16GiB)
[sergey_rodionov_formulation.metta]() 0m43.516s

Adam and Eve Dataset (479 people)
[simple_conversion.metta]() ERROR: Could not parse float: ParseFloatError { kind: Invalid }

royal92 Dataset (2998 people)
[simple_conversion.metta]() 36m52.226s
[baseline_formulation.metta]() ERROR: thread 'main' has overflowed its stack
[sergey_rodionov_formulation.metta]() IN PROGRESS

G37S-9NQ Dataset (8696 people)
[simple_conversion.metta]() IN PROGRESS

### CZ2
Simpsons Dataset (11 people)
space-wide ops 0m0.005s

Lord of the Rings Dataset (86 people)
space-wide ops 0m0.009s

royal92 Dataset (2998 people)
space-wide ops 0m0.201s
