# Aunt Knowledge Graph

An exploration in knowledge graphs, raised by
[https://github.com/trueagi-io/metta-examples/issues/40](https://github.com/trueagi-io/metta-examples/issues/40)

The goal is to evaluate how expressive, intuitive, and performant MeTTa is for dealing with regular labeled graphs.


## Start here and Conceptual
True to the original issue we work with ancestral graphs.
The original hand-crafted graph is [toy_simple.metta]()
For more details, visit the issue link above.

## Data and conversion

Getting real-world data into MeTTa consists of several steps:
- Conversion from [GEDCOM](https://en.wikipedia.org/wiki/GEDCOM) to JSON.  
You can use the following tool https://codesandbox.io/p/sandbox/delicate-haze-2zv77m (based on https://github.com/Jisco/gedcom.json).
- Conversion from JSON to MeTTa files.  
Using the Python script [json_to_metta.py]().
- Conversion from the genealogical data to the simplified statements.  
Using the MeTTa script [simple_conversion.metta]().

## Benchmarks

The benchmark is to do every query (parent, mother, sister, aunt, predecessor) for every person.

### Hyperon-Experimental
WARNING: Outdated

Simpsons Dataset (11 people)  
[simple_conversion.metta]() 0m0.113s  
[baseline_formulation.metta]() 0m0.178s  
[sergey_rodionov_formulation.metta]() 0m1.028s  

Lord of the Rings Dataset (86 people)  
[simple_conversion.metta]() 0m2.171s  
[baseline_formulation.metta]() 0m4.872s  
[sergey_rodionov_formulation.metta]() 0m43.516s  

Adam and Eve Dataset (479 people)  
[simple_conversion.metta]() 0m31.144s  
[baseline_formulation.metta]() 0m53.724s  
[sergey_rodionov_formulation.metta]() 36m56.999s  

royal92 Dataset (2998 people)  
[simple_conversion.metta]() 36m52.226s  
[baseline_formulation.metta]() ERROR: thread 'main' has overflowed its stack  
[sergey_rodionov_formulation.metta]() IN PROGRESS (12h+)  

G37S-9NQ Dataset (8696 people)  
[simple_conversion.metta]() 252m46.136s (partial results)  
[baseline_formulation.metta]() ERROR: thread 'main' has overflowed its stack  
[sergey_rodionov_formulation.metta]() IN PROGRESS (12h+)


### CZ2
Simpsons Dataset (11 people)  
space-wide ops 0m0.005s

Lord of the Rings Dataset (86 people)  
space-wide ops 0m0.009s

Adam and Eve Dataset (479 people)  
space-wide ops 0m0.034s

royal92 Dataset (2998 people)  
space-wide ops 0m0.201s

G37S-9NQ Dataset (8696 people)  
space-wide ops 0m0.556s
