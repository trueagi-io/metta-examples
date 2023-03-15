import os
import pathlib
from metta_space import PatternParser, MettaSpace

if __name__ == '__main__':
    amr_space = MettaSpace()
    pattern_loader = PatternParser(amr_space)

    work_dir = pathlib.Path(__file__).parent.resolve().parent
    templates_dir = os.path.join(work_dir, "amr_templates")
    if os.path.exists(templates_dir):
        for f in os.listdir(templates_dir):
            if f.endswith('.amr'):
                pattern_loader.load_templates_from_file(os.path.join(templates_dir, f))
    #text = input()
    #res = amr_nlu.text2intents(text)
    print("----- The atomspace contains:\n\n---", amr_space.get_atoms())

    print(amr_space.get_concept('close-fam?-g-001860'))
