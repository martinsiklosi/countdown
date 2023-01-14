#cython: language_level=3
from cpython cimport bool
import re
from time import perf_counter


cdef bool is_valid(double val):
    if val % 1 != 0:
        return False
    if val <= 0:
        return False
    return True

cdef bool contains_common(str con1, str con2):
    for var in con1:
        if var in con2:
            return True
    return False

cdef tuple add(tuple exp1, tuple exp2, str con):
    cdef double val = exp1[1] + exp2[1]
    cdef str exp = f"({exp1[0]}+{exp2[0]})"
    return (exp, val, con,)

cdef tuple multiply(tuple exp1, tuple exp2, str con):
    cdef double val = exp1[1] * exp2[1]
    cdef str exp = f"{exp1[0]}*{exp2[0]}"
    return (exp, val, con,)

cdef tuple subtract(tuple exp1, tuple exp2, str con):
    cdef double val = exp1[1] - exp2[1]
    cdef str exp = f"({exp1[0]}-{exp2[0]})"
    return (exp, val, con,)

cdef tuple divide(tuple exp1, tuple exp2, str con):
    cdef double val 
    if exp2[1] == 0:
        val = 0
    else:
        val = exp1[1] / exp2[1]
    cdef str exp = f"{exp1[0]}/({exp2[0]})"
    return (exp, val, con,)

cdef list valid_combs(tuple exp1, tuple exp2, set id_set):
    cdef list output = []
    cdef str con
    if not contains_common(exp1[2], exp2[2]):
        con = exp1[2] + exp2[2]
        combs = (
            add(exp1, exp2, con),
            multiply(exp1, exp2, con),
            subtract(exp1, exp2, con),
            divide(exp1, exp2, con)
        )
        for comb in combs:
            if is_valid(comb[1]) and create_id(comb[1], comb[2]) not in id_set:
                output.append(comb)
    return output

cdef str create_id(val, str con):
    return str(val) + str(sorted(con))

cdef list add_perms(list v1, list v2, set id_set):
    cdef list output = []
    for exp1 in v1:
        for exp2 in v2:
            output.extend(valid_combs(exp1, exp2, id_set))
            for perm in output:
                id_set.add(create_id(perm[1], perm[2]))
    return output

def run():
    print("a,b,c,d,e,f = ", end="")
    cdef int a, b, c, d, e, f, n
    a, b, c, d, e, f = map(int, re.split(r" , |, | ,|,|  | ",input()))
    n = int(input("n = "))

    before = perf_counter()

    cdef list exp_sets = [[] for _ in range(6)]
    exp_sets[0] = [
        ("a", a, "a",),
        ("b", b, "b",),
        ("c", c, "c",),
        ("d", d, "d",),
        ("e", e, "e",),
        ("f", f, "f",)
    ]
    id_set = set([create_id(exp[1], exp[2]) for exp in exp_sets[0]])

    for i in range(6):
        print(f"length {i+1}: ", end="")
        for j in range(i):
            exp_sets[i].extend(add_perms(exp_sets[j], exp_sets[i-j-1], id_set))
        print(f"{len(exp_sets[i])} perms")

    cdef list exps = []
    for v in exp_sets:
        exps.extend(v)
    print(f"total: {len(exps)} perms")


    exps.sort(key=lambda exp: abs(n - exp[1]))
    best_exp = exps[0]

    print(f"time: {perf_counter() - before:.2f}s")

    output = ""
    for char in best_exp[0]:
        if char.isalpha():
            output += str(eval(char))
        else:
            output += char
    print(f"{output} = {round(best_exp[1])}")