from hyperon.atoms import OperationAtom, ValueAtom
from hyperon.ext import *

import random
random.seed(123)

import time

def updateSeed():
    random.seed(getCurTime())

def getRandInt(start, end):
    updateSeed()
    return random.randint(start, end)

def getCurTime():
    return time.time_ns() / (10 ** 6)

def quotient(x, y):
    return x // y

@register_atoms
def my_glob_atoms():
    return {
        'randomint!': OperationAtom("randomint!", getRandInt),
        'timems!': OperationAtom("timems!", getCurTime),
        '//': OperationAtom("//", quotient),
        }