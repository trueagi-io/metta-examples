import os
import pathlib
from opencog.utilities import (push_default_atomspace)
from opencog.type_constructors import *
#from amratom import AmrTemplateInstance
from amr_template_nlu import AmrTemplateNLU
import hyperon as hp


if __name__ == '__main__':

    amr_nlu = AmrTemplateNLU()

    work_dir = pathlib.Path(__file__).parent.resolve().parent
    templates_dir = os.path.join(work_dir, "amr_templates")
    if os.path.exists(templates_dir):
        for f in os.listdir(templates_dir):
            if f.endswith('.amr') and (f == "test.amr"):
                amr_nlu.load_templates_from_file(os.path.join(templates_dir, f))
                break
    #text = input()
    #res = amr_nlu.text2intents(text)
    print("----- The atomspace contains:\n\n---", amr_nlu.amr_space.get_atoms())

    print(amr_nlu.amr_space.get_amrsets_by_concept('person'))
