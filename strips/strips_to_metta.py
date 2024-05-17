import pddl.parser.domain
from pddl.action import Action
from pddl.logic.predicates import Predicate
from pddl.logic.effects import AndEffect
from pddl.logic.base import Formula, And, Not
from pddl import parse_domain
from pddl.parser.domain import Domain


def predicate_to_metta(p: Predicate) -> str:
    s = f"(predicate {p.name}) \n" \
        f"(arity {p.name} {p.arity}) \n"
    for i in range(p.arity):
        if p.terms[i].type_tags:
            for t in p.terms[i].type_tags:  # show every different type tag in a new statement, not sure about this
                s += f"(var {p.name} {i + 1} {t}) \n"
        else:
            s += f"(var {p.name} {i + 1} untyped) \n"
    return s


"""
def term_to_metta(t: Term, object, index):
    s = ""
    if t.type_tags:
        for tag in p.type_tags:  # show every different type tag in a new statement, not sure about this
            s += f"(var {object.name} {index} {tag}) \n"
    else:
        s += f"(var {object.name} {index} untyped) \n"
"""


def types_to_metta(type_dict: dict['name', 'Optional[name]']) -> str:
    s = "(type object) \n"     # in PDDL, 'object' is the default type, all other types are also objects
    for subtype, type in type_dict.items():
        s += f"(type {subtype}) \n"
        s += f"(isa {subtype} {type})\n"
    return s


def action_to_metta(a: Action) -> str:
    s = f"(action {a.name}) \n"

    for p in a.parameters:
        if p.type_tags:
            for t in p.type_tags:  # show every different type tag in a new statement, not sure about this
                s += f"(var {a.name} {p.name} {t}) \n"
        else:
            s += f"(var {a.name} {p.name} untyped) \n"

    s += precondition_to_metta(a.precondition, a.name)
    s += effect_to_metta(a.effect, a.name)
    return s


def precondition_to_metta(p: Formula, action_name: str) -> str:
    def match_formula(f):
        match f:
            case Predicate():
                return f"(precondition {action_name} {f.name} {''.join([f'{t.name} ' for t in f.terms])}) \n"
            case And():
                return "".join([match_formula(op) for op in f.operands])
            case _:
                raise NotImplementedError("So far, only conjunctions and predicates are allowed in preconditions")

    return match_formula(p)


def effect_to_metta(e: Formula, action_name: str) -> str:
    def match_formula(eff):
        s = ""
        match eff:
            case AndEffect():
                for op in eff.operands:
                    match op:
                        case Predicate():
                            s += f"(pos_effect {action_name} {op.name} {''.join([f'{t.name} ' for t in op.terms])}) \n"
                        case Not():
                            op2 = op.argument
                            s += f"(negative_effect {action_name} {op2.name} {''.join([f'{t.name} ' for t in op2.terms])}) \n"
        return s

    return match_formula(e)


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


if __name__ == '__main__':
    domain: Domain = parse_domain("logistics.pddl")
    print(domain_to_metta(domain))
