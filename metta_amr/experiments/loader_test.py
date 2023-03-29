import os
import pathlib
import time

from amr_matching import AmrTemplateInstance
from experiments.amr_template_nlu import AmrTemplateNLU
from metta_space import PatternParser, MettaSpace

if __name__ == '__main__':
    amr_space = MettaSpace()
    amr_nlu = AmrTemplateNLU(amr_space)

    work_dir = pathlib.Path(__file__).parent.resolve().parent
    templates_dir = os.path.join(work_dir, "amr_templates")
    files = []
    if os.path.exists(templates_dir):
        for f in os.listdir(templates_dir):
            if f.endswith('.amr') and (f in ["activation.amr", "select-single.amr"]):
                files.append(os.path.join(templates_dir, f))
        amr_nlu.load_templates_from_files(files)
    #try:
    # amr_inst = AmrTemplateInstance()
    # amr_inst.amrset = "@guess-name-g"
    # amr_inst.vars = {'$user-name': {'@any-name': {'$name-op1': 'Sveta'}}}
    # amr_inst.subint = []
    #
    # res = amr_nlu.intent2text(amr_inst)
    print(amr_space.get_atoms("optrole"))
    print(amr_space.is_optional_role("name-000055", ":pos", "NNP"))

    #res = amr_nlu.text2intents("David")


    #print(res)
    # except Exception as ex:
    #     print(ex)

