# The Red and Black Lambda calculus in MeTTa


ADT's are classically represented in MeTTa as follows:
```
; type M ::= B | V | lambda V.M | (M M)
(: Term Type)
(: Ground (-> B Term))
(: Mention (-> V Term))
(: Abstraction (-> V (-> Term Term)))
(: Application (-> Term (-> Term Term)))
```


For coloring the Lambda Calculus, we need to parametrize the above ADT in B and V.
The naive way to do this is wrapping the subspace in a function:
```
(= (LambdaTheory $B $V) (superpose (
(: Term Type)
(: Ground (-> $B Term))
(: Mention (-> $V Term))
(: Abstraction (-> $V (-> Term Term)))
(: Application (-> Term (-> Term Term)))
)))
```


In both cases, the terms are not contained in an encompassing theory:
`(: Application (-> Term (-> Term Term)))` does not know what parameters went into the function.
Computationally: if you can't tell the difference, does it matter?

In most languages, there's more to a type than just its inner name. 
In Scala, there's a qualified path to that name, see below for the example: `root.RedBlackLambda.RC.Term` and `root.RedBlackLambda.BC.Term` are different types.


We can wrap a result in a container, effectively resulting in a path:
`(RedLambda (LambdaTheory BTheory String))` results in
```
(RedLambda (: Term Type))
(RedLambda (: Ground (-> BTheory Term)))
(RedLambda (: Mention (-> String Term)))
(RedLambda (: Abstraction (-> String (-> Term Term))))
(RedLambda (: Application (-> Term (-> Term Term))))
(RedLambda (= ((equivalent $l) $r) ???)) ; added to make the result more tangible
```
It doesn't seem unreasonable to have functions wrapped in an object, especially if you consider prefix compression.
However, we get something different than we meant: we want to transport the types to the global namespace, but make them unique.


We could solve this by parametrization, take: 
```
(= (LambdaTheory $F $B $V) (superpose (
(: ($F Term) Type)
(: ($F Ground) (-> $B ($F Term)))
(: ($F Mention) (-> $V ($F Term)))
(: ($F Abstraction) (-> $V (-> ($F Term) ($F Term))))
(: ($F Application) (-> ($F Term) (-> ($F Term) ($F Term))))
)))
``` 
`(LambdaTheoryF RC BTheory String)` now results in
```
(: (RC Term) Type)
(: (RC Ground) (-> BTheory (RC Term)))
(: (RC Mention) (-> String (RC Term)))
(: (RC Abstraction) (-> String (-> (RC Term) (RC Term))))
(: (RC Application) (-> (RC Term) (-> (RC Term) (RC Term))))
```
A slightly higher level language, like the General Purpose (GP) language presented, could eliminate the syntactic overhead of this approach.


In the Scala code below we see all mechanisms at play at once:
- The LambdaTheory definition takes B and V type parameters and wraps the ADT.
- The {Red,Black}Lambda traits wraps three types: exposing the two arguments and the resulting parametrized LambdaTheory {R,B}Theory.
- A Scala object definition is final (can not be extended): this is what the execution has to deal with. RedBlackLambda extends both traits inheriting their definitions and obligations.
  - It fills in the inherited arguments, unified with all their occurrences in {Red,Black}Lambda: the parameters of LambdaTheory.
  - It makes both lambda theories final, making them usable on the value level.
  - It defines a value-level disjoint union on the path-qualified terms.
  - It implements the delegation functions.

---
The Scala version by Greg Meredith:

```scala
trait LambdaTheory[B,V] {
  trait Term
  case class Ground( b : B ) extends Term
  case class Mention( v : V ) extends Term
  case class Abstraction( v : V, body : Term ) extends Term
  case class Application( op : Term, arg : Term ) extends Term

  def equivalent( l : Term, r : Term ) : Boolean = ???

  def reduce( t : Term ) : Option[Term] = ???
}

trait RedLambda {
  type RV
  type BLC
  trait RTheory extends LambdaTheory[BLC,RV]
}
trait BlackLambda {
  type BV
  type RLC
  trait BTheory extends LambdaTheory[RLC,BV]
}

object RedBlackLambda extends RedLambda with BlackLambda {
  type BV = RV
  type BLC = BTheory
  type RLC = RTheory

  object RC extends RTheory 
  object BC extends BTheory 

  type RBTerm = Either[RC.Term,BC.Term]

  def equivalent( l : RBTerm, r : RBTerm ) : Boolean = {
    ( l, r ) match {
      case ( Left( t ), Left( u ) ) => {
        RC.equivalent( t, u )
      }
      case ( Right( t ), Right( u ) ) => {
        BC.equivalent( t, u )
      }
      case _ => false
    }
  }

  def reduce( t : RBTerm ) : Option[RBTerm] = {
    t match {
      case Left( lt ) => {
        RC.reduce( lt ) match {
          case Some( u : RC.Term ) => {
            u match {
              case RC.Ground( bu : BC.Term ) => reduce( Right( bu ) )
              case _ => Some( Left( u ) )
            }
          }
          case None => None
        }
      }
      case Right( rt ) => {
        BC.reduce( rt ) match {
          case Some( u : BC.Term ) => {
            u match {
              case BC.Ground( ru : RC.Term ) => reduce( Left( ru ) )
              case _ => Some( Right( u ) )
            }
          }
          case None => None
        }
      }
    }
  }
}
```