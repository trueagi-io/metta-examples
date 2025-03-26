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


### Explaining Red and Black Lambda Calculus at a Middle School Level

Hey there! Let’s talk about something cool called "Red and Black Lambda Calculus." Don’t let the fancy name scare you—it’s just a fun way to think about building things, kind of like playing with two different sets of Lego blocks: one red and one black.

#### What’s It All About?
Imagine you have two teams: the Red Team and the Black Team. Each team has its own set of building blocks (we’ll call them "terms"), and they use these blocks to create stuff—like little structures or machines. These blocks can be simple or fancy:

- **Simple Blocks** (called "ground terms"): These are like plain pieces that don’t change, like a solid red square or a solid black triangle.
- **Naming Blocks** (called "mentions"): These are like labels, such as "x" or "y," that stand for something else.
- **Function Blocks** (called "abstractions"): These are like instructions that say, "Take this piece and do something with it."
- **Combo Blocks** (called "applications"): These are when you stick two blocks together to make something new.

So far, it’s like each team is building their own creations with their own colored blocks. But here’s the twist!

#### The Cool Twist: Mixing Colors
The Red Team and the Black Team don’t just stay separate—they mix things up! A red block can have a black block inside it, and a black block can have a red block inside it. Picture this:

- A red box with a black box inside it.
- Then, inside that black box, there’s another red box.
- And it could keep going like that!

It’s like a game of hide-and-seek with boxes inside boxes, where the colors keep switching back and forth.

#### Making the Rules
To keep everything organized, we use a kind of "rulebook" written in a computer language called MeTTa. Here’s what the rulebook does:

1. **Sets Up the Teams**: It says, “Red Team has red blocks, and Black Team has black blocks.” Each team’s blocks are special and different from the other team’s.
2. **Keeps Them Unique**: We add little tags—like “RC” for Red and “BC” for Black—so we don’t mix up the colors by accident.
3. **Explains the Mixing**: It tells us that a red block can hold a black block inside, and a black block can hold a red block. That’s the fun part!
4. **Works with Both**: Sometimes we want to talk about a block without caring about its color. The rulebook lets us say, “This is just a block—it could be red or black.”
5. **Plays with the Blocks**:
   - We can check if two blocks are the same, but only if they’re the same color (no comparing red to black directly!).
   - We can also "simplify" a block. If it’s a red block with a black block inside, we look at the black block next, and keep switching colors as we go.

#### Why Does This Matter?
Think of this like a puzzle game where red and black pieces depend on each other. It’s a way to figure out how things—like instructions or machines—work together when they’re connected in tricky ways. People who study computers and math use ideas like this to understand how to build programs or solve big problems.

#### The Big Idea
At its heart, Red and Black Lambda Calculus is like playing with two colorful teams of building blocks that can fit inside each other. It’s a fun, creative way to explore how parts of a system can team up and switch roles, all while following some simple rules. Cool, right?
