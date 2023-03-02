#cython: language_level=3
#cython: profile=False
import re
import sys

cdef tuple add(tuple exp1, tuple exp2, long con):
    cdef long val = exp1[1] + exp2[1]
    cdef str exp = f"({exp1[0]}+{exp2[0]})"
    return (exp, val, con,)

cdef tuple multiply(tuple exp1, tuple exp2, long con):
    if exp1[1] == 1 or exp2[1] == 1:
        return ("", 0, 0b0,)
    cdef long val = exp1[1] * exp2[1]
    cdef str exp = f"{exp1[0]}*{exp2[0]}"
    return (exp, val, con,)

cdef tuple subtract(tuple exp1, tuple exp2, long con):
    if exp2[1] >= exp1[1]:
        return ("", 0, 0b0,)
    cdef long val = exp1[1] - exp2[1]
    cdef str exp = f"({exp1[0]}-{exp2[0]})"
    return (exp, val, con,)

cdef tuple divide(tuple exp1, tuple exp2, long con):
    if exp2[1] == 1 or exp1[1] % exp2[1] != 0:
        return ("", 0, 0b0,)
    cdef long val = exp1[1] // exp2[1]
    cdef str exp = f"{exp1[0]}/({exp2[0]})"
    return (exp, val, con,)

cdef tuple valid_combs(tuple exp1, tuple exp2):
    cdef long con = exp1[2] | exp2[2]
    return (
        add(exp1, exp2, con),
        multiply(exp1, exp2, con),
        subtract(exp1, exp2, con),
        divide(exp1, exp2, con)
    )

cdef str create_id(long val, long con):
    return f"{val}_{con}"

cdef list add_perms(list v1, list v2, set id_set):
    '''Returns all valid combinations of expressions in v1 and v2.'''
    cdef list output = []
    cdef tuple exp1, exp2, perm, new_combs, comb
    cdef str my_id
    for exp1 in v1:
        for exp2 in v2:
            if not exp1[2] & exp2[2]:
                for comb in valid_combs(exp1, exp2):
                    if comb[2]:
                        my_id = create_id(comb[1], comb[2])
                        if my_id not in id_set:
                            output.append(comb)
                            id_set.add(my_id)
    return output

def run_numbers():
    # Take input
    print("numbers = ", end="")
    separators = r" , |, | ,|,|  | "
    numbers = re.split(separators, input().strip())
    try:
        numbers = list(map(int, numbers))
        n = int(input("target = "))
    except ValueError:
        sys.exit("error: invalid input")

    # Create list with base expression and set of uniqe id strings for each expression
    exp_sets = [[] for _ in numbers]
    exp_sets[0] = [(f"{num}", num, 2**i) for i, num in enumerate(numbers)]
    id_set = set([create_id(exp[1], exp[2]) for exp in exp_sets[0]])

    # Extend the list of expression
    for i, _ in enumerate(numbers):
        for j in range(i):
            exp_sets[i].extend(add_perms(
                exp_sets[j], 
                exp_sets[i-j-1], 
                id_set
            ))

    # Collect all expressions and pick the closest to target
    exps = []
    for v in exp_sets:
        exps.extend(v)
    exps.sort(key=lambda exp: abs(n - exp[1]))
    best_exp = exps[0]
    print(f"{best_exp[0]} = {round(best_exp[1])}")
