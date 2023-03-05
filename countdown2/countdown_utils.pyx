#cython: language_level=3
#cython: profile=False
import re
import sys
from itertools import product

cdef tuple add(tuple exp1, tuple exp2, int con):
    cdef long val = exp1[1] + exp2[1]
    cdef str exp = f"({exp1[0]}+{exp2[0]})"
    return (exp, val, con,)

cdef tuple multiply(tuple exp1, tuple exp2, int con):
    if exp1[1] == 1 or exp2[1] == 1:
        return ("", 0, 0,)
    cdef long val = exp1[1] * exp2[1]
    cdef str exp = f"{exp1[0]}*{exp2[0]}"
    return (exp, val, con,)

cdef tuple subtract(tuple exp1, tuple exp2, int con):
    if exp2[1] >= exp1[1]:
        return ("", 0, 0,)
    cdef long val = exp1[1] - exp2[1]
    cdef str exp = f"({exp1[0]}-{exp2[0]})"
    return (exp, val, con,)

cdef tuple divide(tuple exp1, tuple exp2, int con):
    if exp2[1] == 1 or exp1[1] % exp2[1] != 0:
        return ("", 0, 0,)
    cdef long val = exp1[1] // exp2[1]
    cdef str exp = f"{exp1[0]}/({exp2[0]})"
    return (exp, val, con,)

cdef list useful_combs(tuple exp1, tuple exp2):
    '''Returns the useful combinations of two expressions.
    Non-useful combinations are returned with a id 0.'''
    cdef tuple methods = (add, multiply, subtract, divide)
    cdef int con = exp1[2] + exp2[2]
    cdef list output = []
    for method in methods:
        comb = method(exp1, exp2, con)
        if comb[2]:
            output.append(comb)
    return output

cdef long long create_id(tuple exp, char n_variables):
    return (exp[1] << n_variables) + exp[2]

cdef list add_permutations(list v1, list v2, set id_set, char n_variables):
    '''Returns all valid combinations of expressions in v1 and v2.'''
    cdef list output = []
    cdef tuple exp1, exp2, comb
    cdef long long exp_id
    for exp1, exp2 in product(v1, v2):
        if exp1[2] & exp2[2]:
            continue
        for comb in useful_combs(exp1, exp2):
            exp_id = create_id(comb, n_variables)
            if exp_id in id_set:
                continue
            output.append(comb)
            id_set.add(exp_id)
    return output

def run_numbers():
    # Take input
    print("numbers = ", end="")
    separators = r" , |, | ,|,|  | "
    numbers = re.split(separators, input().strip())
    try:
        numbers = list(map(int, numbers))
        target = int(input("target = "))
    except ValueError:
        sys.exit("error: invalid input")

    # Generate base expressions
    cdef char n_variables = len(numbers);
    expression_sets = [[] for _ in numbers]
    expression_sets[0] = [(f"{num}", num, 2**i) for i, num in enumerate(numbers)]
    id_set = set([create_id(exp, n_variables) for exp in expression_sets[0]])

    # Find all useful combinations
    for i in range(n_variables):
        for j in range(i):
            expression_sets[i].extend(add_permutations(
                expression_sets[j], 
                expression_sets[i-j-1], 
                id_set,
                n_variables,
            ))

    # Print the best expression
    expressions = []
    for v in expression_sets:
        expressions.extend(v)
    expressions.sort(key=lambda exp: abs(target - exp[1]))
    best_expression = expressions[0]
    print(f"{best_expression[0]} = {round(best_expression[1])}")
