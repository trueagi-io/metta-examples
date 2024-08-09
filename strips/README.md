# STRIPS/PDDL to MeTTa translation

## STRIPS 
[The Stanford Research Institute Problem Solver (STRIPS)](https://en.wikipedia.org/wiki/Stanford_Research_Institute_Problem_Solver) is an early automated planner with a formal input language (also referred to as STRIPS). A STRIPS specification consists of 
* A set of propositions P
* A set of operators O (or actions) with each
  * The preconditions Pre ⊆ P; the propositions that need to hold in a state for the action to be executed
  * The positive effects Eff+ ⊆ P; the propositions that become true after executing the action
  * The negative effects Eff- ⊆ P; the propositions that become false after executing the action
* An initial state I ⊆ P
* A goal state G ⊆ P

Often, an extension of STRIPS is used in which propositions and actions can contain variables. In this case, an extra set of objects needs to be added that can be used to substitute the parameters.


## PDDL 
[The Planning Domain Description Language (PDDL)](https://en.wikipedia.org/wiki/Planning_Domain_Definition_Language) is a standardized specification language for AI planning environments and planning tasks that further generalizes STRIPS. 
In PDDL specifications, initial states, preconditions, and effects can contain negations and disjunctions. 

A planning task is described in two different PDDL files: 
* a domain file describing the parameterized types, predicates, and actions that build up the environment, 
* an instance or problem file that specifies the objects, initial state, and goal of the planning task. 

## IPC Examples
Through the years, many PDDL environments were developed as benchmarks for the International Planning Competition (IPC), the benchmark environments were provided as PDDL files.
The following GitHub repository collected all these environments.
https://github.com/potassco/pddl-instances/

The files can also be downloaded via the official website of the IPC. 

All the PDDL domains and instances we use for testing originate from the IPC benchmarks. 

## MeTTa translation of STRIPS
For now, we focussed on translating STRIPS environments, specified in PDDL files, to MeTTa. 
We support typed variables in the predicate and action specifications.

As example cases we show 
* the blocks domain ([PDDL](blocks/domain.pddl), [MeTTa](strips-to-metta-improved/blocks-i-1.metta))
* the logistics domain together with an instance ([PDDL](logistics), [MeTTa](strips-to-metta-improved/logistics-i-1.metta))

MeTTa queries and tests on the blocks domain can be found [here](strips-to-metta-improved/queries.metta). 
We managed to use the MeTTa language to construct a transition system graph from the domain specification. 
