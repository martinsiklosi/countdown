#cython: language_level=3
#cython: profile=False
import re
from time import perf_counter

cdef tuple add(tuple exp1, tuple exp2, int con):
    cdef int val = exp1[1] + exp2[1]
    cdef str exp = f"({exp1[0]}+{exp2[0]})"
    return (exp, val, con,)

cdef tuple multiply(tuple exp1, tuple exp2, int con):
    cdef int val = exp1[1] * exp2[1]
    cdef str exp = f"{exp1[0]}*{exp2[0]}"
    return (exp, val, con,)

cdef tuple subtract(tuple exp1, tuple exp2, int con):
    cdef int val = exp1[1] - exp2[1]
    if val <= 0:
        return ("", 0, 0b0,)
    cdef str exp = f"({exp1[0]}-{exp2[0]})"
    return (exp, val, con,)

cdef tuple divide(tuple exp1, tuple exp2, int con):
    if exp1[1] % exp2[1] != 0:
        return ("", 0, 0b0,)
    cdef int val = exp1[1] / exp2[1]
    cdef str exp = f"{exp1[0]}/({exp2[0]})"
    return (exp, val, con,)

cdef list valid_combs(tuple exp1, tuple exp2, set id_set):
    cdef list output = []
    cdef int con
    con = exp1[2] | exp2[2]
    combs = (
        add(exp1, exp2, con),
        multiply(exp1, exp2, con),
        subtract(exp1, exp2, con),
        divide(exp1, exp2, con)
    )
    for comb in combs:
        if comb[0]:
            if create_id(comb[1], comb[2]) not in id_set:
                output.append(comb)
    return output

cdef int create_id(int val, int con):
    return val << 6 + con

cdef list add_perms(list v1, list v2, set id_set):
    cdef list output = []
    for exp1 in v1:
        for exp2 in v2:
            if not exp1[2] & exp2[2]:
                output.extend(valid_combs(exp1, exp2, id_set))
                for perm in output:
                    id_set.add(create_id(perm[1], perm[2]))
    return output

def run_numbers():
    print("a,b,c,d,e,f = ", end="")
    cdef int a, b, c, d, e, f, n
    a, b, c, d, e, f = map(int, re.split(r" , |, | ,|,|  | ",input()))
    n = int(input("n = "))

    before = perf_counter()

    cdef list exp_sets = [[] for _ in range(6)]
    exp_sets[0] = [
        ("a", a, 0b100000,),
        ("b", b, 0b010000,),
        ("c", c, 0b001000,),
        ("d", d, 0b000100,),
        ("e", e, 0b000010,),
        ("f", f, 0b000001,)
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