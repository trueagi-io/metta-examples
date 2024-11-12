from hyperon.atoms import OperationAtom, ValueAtom
from hyperon.ext import *
from hyperon import *

import random
random.seed(123)

import time

import math

def updateSeed():
    random.seed(getCurTime())

def getRandBinaryArray(len):
    updateSeed()
    res = (ValueAtom(random.randint(0, 1)) for _ in range(len.get_object().value))
    return [E(*res)]

def binToDec(*args):
    barr = args[0].iterate()
    sign = barr[0]
    res = sum(int(val.get_object().value) * (2 ** idx) for idx, val in enumerate(reversed(barr[1:])))
    if sign.get_object().value == 1:
        res *= -1
    return [ValueAtom(res)]

def decToBin(dec):
    binstr = "{:b}".format(dec.get_object().value)
    if binstr[0] == "-":
        binstr = binstr.replace("-", "1")
    else:
        binstr = "0" + binstr
    res = (ValueAtom(int(c)) for c in binstr)
    return [E(*res)]

def getRandInt(start, end):
    updateSeed()
    return random.randint(start, end)

def getCurTime():
    return time.time_ns() / (10 ** 6)

@register_atoms
def my_glob_atoms():
    return {
        'randomint!': OperationAtom("randomint!", getRandInt),
        'randombarr!': OperationAtom("randombarr!", getRandBinaryArray, unwrap=False),
        'bintodec!': OperationAtom("bintodec!", binToDec, unwrap=False),
        'dectobin!': OperationAtom("dectobin!", decToBin, unwrap=False)
        }