from time import monotonic_ns

from base import MeTTa, color_expr, underline


if __name__ == "__main__":
    print(underline("MeTTa recursion scheme example\n"))
    t0 = monotonic_ns()
    metta = MeTTa()
    metta.cwd = ["src"]
    for i, (expr, result_set) in enumerate(metta.lazy_import_file("examples/expression.metta")):
        if result_set:
            print(f"results of {color_expr(expr)}:")
            for result in result_set:
                print(color_expr(result))
        else:
            print(f"no result for {color_expr(expr)}")
    print(f"\nexecution took {(monotonic_ns() - t0)/1e9:.5} seconds")
