from hyperon.atoms import OperationAtom, ValueAtom
from hyperon.ext import *

import random
random.seed(123)

import time

import math

def updateSeed():
    random.seed(getCurTime())

def getRandInt(start, end):
    updateSeed()
    return random.randint(start, end)

def getCurTime():
    return time.time_ns() / (10 ** 6)

def quotient(x, y):
    return x // y
def getSqrt(x):
    return math.sqrt(x)

def getAtan(x,y=1):
    return math.atan2(x, y)

def getCos(x):
    return math.cos(x)

def getSin(x):
    return math.sin(x)

@register_atoms
def my_glob_atoms():
    return {
        'randomint!': OperationAtom("randomint!", getRandInt),
        'timems!': OperationAtom("timems!", getCurTime),
        '//': OperationAtom("//", quotient),
        'sqrt': OperationAtom("sqrt", getSqrt),
        'atan': OperationAtom("atan", getAtan),
        'cos': OperationAtom("cos", getCos),
        'sin': OperationAtom("sin", getSin),
        }