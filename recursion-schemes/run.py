import os

from base import MeTTa

if __name__ == "__main__":
    print("MeTTa recursion scheme example\n")
    metta = MeTTa()
    metta.cwd = ["src"]
    for i, (expr, result_set) in enumerate(metta.lazy_import_file("examples/expression.metta")):
        if result_set:
            print(f"results of {expr}:")
            for result in result_set:
                print(result)
        else:
            print(f"no result for {expr}")
