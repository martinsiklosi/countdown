#cython: language_level=3
from time import perf_counter

def run_numbers(algs, int a, int b, int c, int d, int e, int f, int n):

    before = perf_counter()

    cdef float best_diff = float(n)
    cdef str best_exp = ""
    cdef str exp
    cdef float result
    for exp in algs:
        try:
            result = eval(exp)
        except ZeroDivisionError:
            continue
        if result % 1 < 0.00000001 and abs(n - result) < best_diff:
            best_exp = exp
            best_diff = abs(n - result)
            if best_diff == 0:
                break

    runtime = perf_counter() - before

    return best_exp, runtime