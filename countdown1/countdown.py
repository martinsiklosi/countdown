import re
import json
import pyximport; pyximport.install()
from countdown_utils import run_numbers

with open('all_algs.json', 'r') as openfile:
    algs = json.load(openfile)

print("a,b,c,d,e,f = ", end="")
a, b, c, d, e, f = map(int, re.split(r" , |, | ,|,|  | ",input()))
n = int(input("n = "))

best_exp, runtime = run_numbers(algs, a, b, c, d, e, f, n)
print(f"took {runtime:.2f}s")

output = ""
for char in best_exp:
    if char.isalpha():
        output += str(eval(char))
    else:
        output += char
print(f"{output} = {round(eval(best_exp))}")