# Develop Artificial Intelligence as a child from birth to youth, using proactive interaction with external environment and gathering experience in knowledge graph with linked nodes. 
Aleksei Isaev (aleksey.isaev@gmail.com)

## Develop AI as a child 
Main idea is to develop the intellectual abilities of Artificial Intelligence (AI) in accordance with the stages of child development based on the theory of J. Piaget(1). He believed that the development of the mind occurs in the process of socialization. The experience is stored in the form of actions schemes. At a certain point in the child's development, action patterns turn into operations. In his theory, J. Piaget describes intelligence as a system of operations.<br/>
Child interacts with external environment from birth. Sensory perception is done through the coordination between sense (hearing, vision, taste, smell, and touch) organs and the brain. Sensory perception involves detecting, recognizing, characterizing and responding to stimuli.
It is proposed to teach AI by sending sensory information of different types as the input and modeling interaction with the external environment.<br/> 
To prepare training dataset we can use the exercises for children from the book “ Education of the sensory culture of a child from birth to 6 years”(2),  from “Planning as a central component of theoretical thinking”(3) and school textbooks. There is no need to model the entire external environment. It needs to create training data for the concrete exercises to accumulate experience of sensory standards. Sensory standards are generally accepted samples of the external properties of objects: color (red, yellow, green, blue), size (large, medium, small), shape (circle, square, triangle, rectangle), part of whole, spatial characteristics, mutual location. Main goal is to gain experience to move to the next level of AI development (presented below). <br/>
• From birth to 4 years are developed entities as perception, object, skill, symbol. Perception is the knowledge child acquires about objects and their movements as a result of contact with them. According to L.A. Wenger(2), “manipulating objects, children continue to get acquainted with various properties: size, shape, color. In most cases, child initially performs the task by accident. Gradually, from repeated chaotic actions, child moves on to planning steps.”
Skill is an entity that groups a sequence of actions and results leading to the achievement of the goal. 
Z. Piaget wrote(1): "To have a concept of an object means to attribute the perceived figure to a permanent basis, thanks to which the figure continues to exist outside the field of perception.” 
Symbol appears when child, by "sticking" a label, defines a name as something inherent in the thing being called. The formation of the Symbol coincides with the ability to speak and hang labels. Special attention at this age is paid to the assimilation and correct use of the names of the properties of objects (colors, shapes, sizes). <br/>
• In the period from 4 to 7-8 years, intuitive (visual) thinking is formed.
Wenger wrote(2): "In the fifth year of life, children are taught to analyze complex (composite) shapes, decompose them into elements corresponding to geometric patterns. In the middle group, introducing preschoolers to the magnitude, it is recommended to offer them more complex tasks: to highlight the height, width of objects and other parameters of the magnitude."
There is a transition to the level of Imagination of the nearest Real experience. Representation of particular cases of reality, real actions, reactions and results. Recall (find) a similar real experience to achieve a result. Mentally do a real experiment. <br/>
• From 7-8 to 11-12 years, specific operations are formed, i.e. operational groupings of thinking related to objects that can be manipulated.
Z. Piaget wrote(1): "The appearance of operational is precisely characterized by a clear differentiation of logical and mathematical operations that have become independent (classes, operations and numbers unrelated to space) and spatio–temporal operations (creation of an object, part-whole). <br/>
• Finally, from the age of 11-12 and throughout the adolescent period, formal thinking is developed.
Z. Piaget wrote(1): "The formal thinking when person becomes able to reason hypothetically–deductively, i.e. on the basis of some general premises, without any apparent connection with reality or its own beliefs.

##  Knowledge graph with linked nodes
I propose to store experience in a knowledge graph format with triplets: Source node, Link edge, Destination node and use term Atom for nodes and links.
Node Atoms have different types and contain attributes to store information. Node Atoms can be saved in different Spaces. For example information from the brain should be saved in Memory Spaces. 

Memory Space Node Atoms store identification and attribute information in a special code (Key Code). This Key Code can be in Sparse Distributed format. I suggest to research ideas from: [Sparse distributed memory](https://en.wikipedia.org/wiki/Sparse_distributed_memory) and [Sparse distributed representations](https://numenta.com/neuroscience-research/sparse-distributed-representations/)

The coding mechanism is an open question. It makes sense to use the numerous developments of neural networks. However it’s important to provide a reverse decoding ability. It needs for the process of imagination, when a child can imagine objects stored in the brain and operate with them.
To search Atoms in Memory Space by the input code, the Match Ratio (similarity) of the the input and saved Atoms Key Codes is used. Match Ratio algorithm for Key Code is an open question.

Node Atoms have links / associations with each other. Link is a Link / Edge type of Atom.  Every Link Atom has a weights attribute, showing the strength of the relationship. The more weights value the more linked (associated) nodes. Weight is an analogue of the probability of choosing the link among others when searching connected Atoms.
We can use weights to determine the most appropriate action to achieve the goal. The strongest link between the goal with all possible related actions is selected. 
Another example is a prediction of the next Object using the hightest Next type Link with the current Object. 
The strengthening (boosting) of links occurs not only during real sensory perception of Atoms, but also during thinking (imagination).

The brain is in constant search of balance. Child actions depend on the needs (goals) that are set by an internal motivation of curiosity, physiological needs, tasks from an adult. In the process of gaining experience links between Atoms (Goal, Action, Reaction, Result) are formed. 
The success of the action should be clear from the reaction. If the action is to catch the object by hand, then a successful reaction means that the object must be held in the hand. The item has certain kinesthetic reaction identifiers for successful hand actions. Success occurs when the object reaction parameters and the hand action parameters are matched (palm opening, angle of rotation of the hand, elbow extension, and others). 
In the process of completing tasks, actions are adjusted to achieve success. The parameters of the action are initially tuned by trials and errors.  All attempts are stored in memory where successful actions boosting with higher links weights. The experience of obtaining a successful result is accumulated and a Skill is formed.  It appears an understanding of the physics of the external environment (shape, part / whole, size, space, etc.), what can be done with objects, what are reactions.

Atoms (Nodes and Links) are the basis for gathering experience and structuring information in the brain. The transition to the next level of intelligence occurs after reaching a certain number of Atoms (Nodes and Links) of specific types.
## Source code examples
Idea is on initial Proof of Concept (PoC) stage use Python as a simple and well known programming language with many Data Science libraries.
[Current python source code](child_ai.py) is a simplified example of implementation of sensory perception exercise for child: Catching the toy from the hands of an adult. Child pays attention on the new toy by hearing the voice of an adult, then look at this toy and try to catch it by hand. This Python code is independent from Hyperon libraries.

At this stage there are no all possible variants and steps implemented as this source code is a draft and not a final production version. Most of training data are hard-coded. Torch training dataset is used as an example of possible external environment and can be changed to the concrete tasks. Atom Key Code vector creation and Match Ratio algorithm are placeholders.
I suggest Plan-Do-Check-Act approach to achieve the result from the goal and corresponding functions are developed. 

After concrete idea is proven or architecture is fixed we can move some functionality in Hyperon Rust library(5). It can increase performance and we can reuse Space / Atoms functionality. 
I propose several functions to implement in Rust and its [Rust source code are placed here](graph_kb.rs).
They duplicate similar functions in [Python](child_ai.py) and have the same names.
This Rust code is dependent from Rust [Hyperon libraries](https://github.com/trueagi-io/hyperon-experimental). To run it you need:
1) Create "child_ai" folder in hyperon-experimental/lib/src/ and place there graph_kb.rs file <br/>  
2) Create mod.rs file with code "pub mod graph_kb;" <br/>
3) Add "pub mod child_ai;" code in lib.rs file <br/>
4) Add in Cargo.toml file: ndarray = "0.15.6"  <br/>


To demonstrate possible approaches how to use Graph knowledge base data with MeTTa I’ve made updates for Expression Atoms.
Typical Graph knowledge base consists of Edges with Nodes, and they can have features to store information of different types (sparse distributed vectors for code and weights, IDs, Names, Types etc).
Use case is to enter Edges with Nodes in MeTTa and then parse / interpret them in Graph knowledge base format that used in Child_AI idea.
For Edges with Nodes the expression is used “((LinksEdge Link1) (MemoryNode Node1) (MemoryNode Node2))”.
This is similar to OpenCog classic format expression "(EvaluationLink(PredicateNode eats) (ListLink (ConceptNode Sam)(ConceptNode flies)))"
In future we can change it to Type format like (: LINK Type).
I’ve modified the Rust file graph_kb.rs and have not changed any Python code. I’ve created several new functions ( GraphKB::parse_graph and others) in addition to the existing SexprParser / interpreter::interpret functions. In future, if we decide to include such functionality in MeTTa, we need to adapt the existing functions.
The existing Rust functions parse / interpret the expression “((LinksEdge Link1) (MemoryNode Node1) (MemoryNode Node2))” as Expression Atom with children Symbol Atoms. To use it with Graph knowledge base we need to convert them into Expression Atom with children Grounded Atoms (Link Edge, Source and Destination Nodes) .
The first step is to try to find Grounded Atoms by Symbol Link and Node Names. If no success, we create new edge and nodes, using Name from MeTTa Expression and default values for other fields.
If no need in interpretation we just add Expression Atom in Space.
To use interpretation we need to add special functions to work with Graph, similar to existing functions in Python self.add_atom(r"get-type", newGetAtomTypeAtom(self)).
We can return to MeTTa requested information from Grounded Atoms in addition to Symbol Names and execute requested actions (to find linked nodes for example).
There are two test cases: (1) when Grounded Atoms (Link1, Node1, Node2) exist,
(2) when Grounded Atoms (Link11, Node11, Node22) don't exist.

Below are possible Atoms in MeTTa(5) format after execution of curiosity_behavior() function: <br/> 
((LinksEdge Next) (MemoryNode Need) (MemoryNode Action)), ((LinksEdge Next) (MemoryNode Action) (MemoryNode Reaction)), ((LinksEdge Next) (MemoryNode Action) (MemoryNode Result)), ((LinksEdge Previous) (MemoryNode Result) (MemoryNode Action)) <br/>

((LinksEdge ObjectFor) (MemoryNode Object) (MemoryNode ReactionVisual)), ((LinksEdge ObjectFor) (MemoryNode Object) (MemoryNode ReactionHearing)), ((LinksEdge ObjectFor) (MemoryNode Object) (MemoryNode ReactionTouch))<br/>


Future architecture can look like: <br/>
• Python - Data preparation, Business logic, Data Science (ML libraries) <br/>
• Rust - Hyperon Space / Atoms management <br/>
• MeTTa – Train and test Child_AI on the last stages of AI development when Classes, Operations, Statements are formed from the previous earliest stage Atoms (Object, Skill, Sensory, Symbol).

## References
1. Piaget J., Psychology of intelligence. (Пиаже Ж. Психология интеллекта. СПб, 2003)
2. Wenger L.A., Education of the sensory culture of a child from birth to 6 years. (Воспитание сенсорной культуры ребенка от рождения до 6 лет / Под ред. Л. А. Венгера. М., 1988)
3. Isaev E.I., Planning as a central component of theoretical thinking. (Исаев Е.И. Планирование как центральный компонент теоретического мышления // Психологическая наука и образование. psyedu.ru. 2010. № 4)
4. Hawkins Jeff, On Intelligence. (Хоукинс Д., Блейксли С. Об интеллекте. М., 2007)
5. https://wiki.opencog.org/w/OpenCog_By_Way_of_Wikipedia
6. https://numenta.org/
