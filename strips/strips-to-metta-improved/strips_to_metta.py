from typing import AbstractSet, Set, List, Tuple

import pddl.parser.domain
from pddl.action import Action
from pddl.logic import Constant, Predicate
from pddl.logic.effects import AndEffect
from pddl.logic.base import Formula, And, Not
from pddl import parse_domain, parse_problem
from pddl.parser.domain import Domain
from pddl.parser.problem import Problem


def get_type(param):
    if len(param.type_tags) == 1:
        return " ".join(t for t in param.type_tags)
    if len(param.type_tags) > 1:
        raise NotImplementedError
    else:
        return "object"  # in PDDL, 'object' is the default type, all other types are also objects


def predicate_to_metta(p: Predicate) -> str:
    s = f"(predicate {p.name}) \n" \
        f"(arity {p.name} {p.arity}) \n"
    s += f"(types {p.name} ({', '.join([get_type(t) for t in p.terms])})) \n"
    return s


def types_to_metta(type_dict: dict['name', 'Optional[name]']) -> str:
    s = "(type object) \n"  # in PDDL, 'object' is the default type, all other types are also objects
    for subtype, type in type_dict.items():
        s += f"(type {subtype}) \n"
        s += f"(isa {subtype} {type})\n"
    return s


def action_to_metta(a: Action) -> str:
    s = f"(action {a.name}) \n"

    s += f"(types {a.name} ({' '.join([get_type(v) for v in a.terms])})) \n"

    s += precondition_to_metta(a.precondition, a)
    s += effect_to_metta(a.effect, a)
    return s


def get_predicates(f: Formula) -> List[Predicate]:
    s = list()
    match f:
        case Predicate():
            s.append(f)
        case And():
            for o in f.operands:
                s += get_predicates(o)
        case _:
            raise NotImplementedError(f"So far, only conjunctions and predicates are allowed in {f}")
    return s


# (= (pre (unstack $x $y))
#   (superpose ((on $x $y)
#               (clear $x))))

def precondition_to_metta(pre: Formula, action: Action) -> str:
    predicates = ' '.join([f"({p.name} {' '.join(['$' + v.name for v in p.terms])})" for p in get_predicates(pre)])
    return (f"(= (pre ({action.name} {' '.join(['$' + v.name for v in action.terms])})) "
            f"(superpose ({predicates}))) \n")
    # return ""


def split_pos_neg(eff: AndEffect) -> Tuple[List[Predicate], List[Predicate]]:
    pos = list()
    neg = list()
    # assert eff is AndEffect
    # for some reason AndEffects are not always parsed as AndEffects
    for op in eff.operands:
        match op:
            case Predicate():
                pos.append(op)
            case Not():
                neg.append(op.argument)
    return pos, neg


# (= (pos-post (unstack $x $y))
#    (superpose ((holding $x)
#                (clear $y))))

# (= (neg-post (unstack $x $y))
#    (superpose ((on $x $y)
#                (clear $x))))
def effect_to_metta(eff: Formula, action: Action) -> str:
    pos, neg = split_pos_neg(eff)

    pos_predicates = ' '.join([f"({p.name} {' '.join(['$' + v.name for v in p.terms])})" for p in pos])
    neg_predicates = ' '.join([f"({p.name} {' '.join(['$' + v.name for v in p.terms])})" for p in neg])

    return (f"(= (eff-pos ({action.name} {' '.join(['$' + v.name for v in action.terms])})) "
            f"(superpose ({pos_predicates}))) \n"
            f"(= (eff-neg ({action.name} {' '.join(['$' + v.name for v in action.terms])})) "
            f"(superpose ({neg_predicates}))) \n")


def domain_to_metta(domain: Domain) -> str:
    s = f"(domain {domain.name}) \n"

    for r in domain.requirements:
        assert r in {pddl.parser.domain.Requirements.STRIPS, pddl.parser.domain.Requirements.TYPING}
        # We do not support other requirements yet

    s += types_to_metta(domain.types)

    assert len(domain.constants) == 0  # we do not support constants yet

    for p in domain.predicates:
        s += predicate_to_metta(p)

    assert len(domain.derived_predicates) == 0  # we do not support derived predicates yet

    for a in domain.actions:
        s += action_to_metta(a)

    return s


def object_to_metta(obj: Constant) -> str:
    return f"(object {obj.name})\n" \
           f"(isa {obj.name} {obj.type_tag if obj.type_tag else "object"})\n"


# (= (valuation (state 1)) (superpose ((clear a)
#                                     (on a b)
#                                     (on b c))))
def state_to_metta(state: AbstractSet[Predicate], idx: int):
    props = " ".join([f"({p.name} {' '.join([str(t) for t in p.terms])})" for p in state])
    return f"(= (valuation (state {idx})) (superpose ({props}))) \n"


def goal_to_metta(g: Formula):
    return f"(goal {g})  \n"


def problem_to_metta(problem: Problem):
    s = f"(problem {problem.name}) \n"

    # s += f"(problemdomain {problem.name} {problem.domain_name})"
    # -> not necessary to specify yet since we work with one domain per file. If we want to put multiple
    # domains in one MeTTa file, we should add the domain name to each statement of the domain.

    for obj in problem.objects:
        s += object_to_metta(obj)

    s += "(init state 0) \n"
    s += state_to_metta(problem.init, 0)
    s += goal_to_metta(problem.goal)

    # problem.metric  # -> not supported yet

    return s


def to_file(domainfile, problemfile, outputfile):
    domain: Domain = parse_domain(domainfile)
    problem: Problem = parse_problem(problemfile)
    with open(outputfile, "w") as f:
        f.write(domain_to_metta(domain))
        f.write('\n')
        f.write(problem_to_metta(problem))


if __name__ == '__main__':
    # domain: Domain = parse_domain("blocks/domain.pddl")
    # problem: Problem = parse_problem("blocks/instance-1.pddl")
    # action = next(iter(domain.actions))
    # print(effect_to_metta(action.effect, action))
    to_file("blocks/domain.pddl", "blocks/instance-1.pddl", "strips-to-metta-improved/blocks-i-1.metta")
    to_file("blocks/domain.pddl", "blocks/instance-0.pddl", "strips-to-metta-improved/blocks-i-0.metta")
    to_file("logistics/domain.pddl", "logistics/instance-1.pddl", "strips-to-metta-improved/logistics-i-1.metta")
