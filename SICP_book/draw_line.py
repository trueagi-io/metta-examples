from hyperon.atoms import OperationAtom, ValueAtom
from hyperon.ext import *
from hyperon.atoms import E

import turtle
import time

def drawLine(pt1, pt2):
    pt1 = (pt1.get_children()[0].get_object().content*100, pt1.get_children()[2].get_object().content*100)
    pt2 = (pt2.get_children()[0].get_object().content*100, pt2.get_children()[2].get_object().content*100)
    turtle.penup()
    turtle.goto(pt1)
    turtle.pendown()
    turtle.goto(pt2)
    turtle.penup()
    return [E()]

def finishDraw():
    # some time before turtle window will close just to see the result of drawing.
    time.sleep(5)
    turtle.clear()
    turtle.hideturtle()

@register_atoms
def my_glob_atoms():
    return {
        'drawline!': OperationAtom("drawline!", drawLine, unwrap=False),
        'finishdraw!': OperationAtom("finishdraw!", finishDraw),
        }