import logging

import hyperon as hp

class MettaSpace:
    def __init__(self):
        self.log = logging.getLogger(__name__ + '.' + type(self).__name__)
        self.metta = hp.MeTTa()
        self.space = self.metta.space()
        self.cache = {}
        self.tokenizer = hp.Tokenizer()

    def add_triple(self, triple):
        hp_parser = hp.SExprParser(str(triple).replace(",", "").replace("'",""))
        self.space.add_atom(hp_parser.parse(self.tokenizer))

    def get_concept(self, value):
        results = self.metta.run(f"!(match &self ({value} :instance $concept)  $concept)")
        return results[0] if len(results) > 0 else None

    def get_atoms(self):
        return self.space.get_atoms()

    def get_amrsets_by_concept(self, concept):
        results = []
        if concept is not None:
            results = self.metta.run(f"!(match &self (, ($inst :instance {concept})\
            ($set :amr-set $inst)) ($set $inst))")
        return results[0] if len(results) > 0 else None


