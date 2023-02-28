import re

_number_or_string_pattern = re.compile(r'\d+(\.\d+)?|"[^\"]+"|-|\+')
class TypeDetector:
    @staticmethod
    def is_instance(triple):
        return triple[1] == ':instance'

    @staticmethod
    def is_instance_role(word):
        return word == ':instance'

    @staticmethod
    def is_unknown(triple):
        return TypeDetector.is_instance(triple) and triple[2] == 'amr-unknown'

    @staticmethod
    def is_amr_set(triple):
        return triple[1] == ':amr-set'

    @staticmethod
    def is_const(word):
        return _number_or_string_pattern.fullmatch(word)

    @staticmethod
    def is_variable(word):
        return word == '*' or word.startswith('$')

    @staticmethod
    def is_amrset_name(word):
        return word.startswith('@')