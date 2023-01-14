import re
import json
from time import perf_counter

class my_exp:
    #__slots__ = ("exp", "val", "con", "my_id")
    def __init__(self, exp, val, con):
        self.exp = exp
        self.val = val
        self.con = con
        self.my_id = create_id(val, con)

    def is_valid(self, val):
        if val % 1 != 0:
            return False
        if not 0 < val < 1000:
            return False
        return True

    def contains_common(self, exp2):
        for var in self.con:
            if var in exp2.con:
                return True
        return False
    
    def add(self, exp2, id_list):
        val = self.val + exp2.val
        if not self.is_valid(val):
            return None
        exp = f"({self.exp}+{exp2.exp})"
        con = self.con + exp2.con
        temp_id = create_id(val, con)
        if temp_id in id_list:
            return None
        return my_exp(exp, val, con)

    def multiply(self, exp2, id_list):
        val = self.val * exp2.val
        if not self.is_valid(val):
            return None
        exp = f"{self.exp}*{exp2.exp}"
        con = self.con + exp2.con
        temp_id = create_id(val, con)
        if temp_id in id_list:
            return None
        return my_exp(exp, val, con)

    def subtract(self, exp2, id_list):
        val = self.val - exp2.val
        if not self.is_valid(val):
            return None
        exp = f"({self.exp}-{exp2.exp})"
        con = self.con + exp2.con
        temp_id = create_id(val, con)
        if temp_id in id_list:
            return None
        return my_exp(exp, val, con)

    def divide(self, exp2, id_list):
        try:
            val = self.val / exp2.val
        except ZeroDivisionError:
            return None
        if not self.is_valid(val):
            return None
        exp = f"{self.exp}/({exp2.exp})"
        con = self.con + exp2.con
        temp_id = create_id(val, con)
        if temp_id in id_list:
            return None
        return my_exp(exp, val, con)

    def valid_combs(self, exp2, id_list):
        output = []
        if not self.contains_common(exp2):
            combs = (
                self.add(exp2, id_list),
                self.multiply(exp2, id_list),
                self.subtract(exp2, id_list),
                self.divide(exp2, id_list)
            )
            for comb in combs:
                if comb:
                    output.append(comb)
        return output

def create_id(val, con):
    return str(val) + str(sorted(con))

def add_perms(v1, v2, id_list):
    output = []
    for exp1 in v1:
        for exp2 in v2:
            output.extend(exp1.valid_combs(exp2, id_list))
            for perm in output:
                id_list.append(perm.my_id)
    return output

print("a,b,c,d,e,f = ", end="")
a, b, c, d, e, f = map(int, re.split(r" , |, | ,|,|  | ",input()))
n = int(input("n = "))

before = perf_counter()

exp_sets = [[] for _ in range(6)]
exp_sets[0] = [
    my_exp("a", a, "a"),
    my_exp("b", b, "b"),
    my_exp("c", c, "c"),
    my_exp("d", d, "d"),
    my_exp("e", e, "e"),
    my_exp("f", f, "f"),
]
id_list = [exp.my_id for exp in exp_sets[0]]

for i in range(6):
    print(f"running permutation {i+1}")
    for j in range(i):
        exp_sets[i].extend(add_perms(exp_sets[j], exp_sets[i-j-1], id_list))
    print(f"    {len(exp_sets[i])} new permutations")

exps = []
for v in exp_sets:
    exps.extend(v)
print(f"found {len(exps)} expressions")


exps.sort(key=lambda exp: abs(n - exp.val))
best_exp = exps[0]

print(f"took {perf_counter() - before:.2f}s")

output = ""
for char in best_exp.var:
    if char.isalpha():
        output += str(eval(char))
    else:
        output += char
print(f"{output} = {round(best_exp.val)}")