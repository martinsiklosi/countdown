import json

def contains_common(exp1, exp2):
    for car in exp1:
        if car.isalpha() and car in exp2:
            return True
    return False

def exps(exp1, exp2):
    if not contains_common(exp1, exp2):
        subtracted = f"({exp1}-{exp2})"
        divided = f"{exp1}/({exp2})"
        if exp1 < exp2:
            added = f"({exp1}+{exp2})"
            multiplied = f"{exp1}*{exp2}"
        else:
            added = f"({exp2}+{exp1})"
            multiplied = f"{exp2}*{exp1}"
        return (added, multiplied, subtracted, divided,)
    return []

def add_perms(v1, v2):
    output = []
    for exp1 in v1:
        for exp2 in v2:
            output.extend(exps(exp1, exp2))
    return output

def right_order(exp):
    for i, car in enumerate(exp):
        if car == "*":
            if exp[i-1] > exp[i+1]:
                return False
    return True

def main():
    alg_sets = [set() for _ in range(6)]
    alg_sets[0] = set(("a","b","c","d","e","f",))

    for i in range(6):
        print(f"running permutation {i+1}")
        for j in range(i):
            perms = add_perms(alg_sets[j], alg_sets[i-j-1])
            for perm in perms:
                alg_sets[i].add(perm)
        alg_sets[i] = list(filter(right_order, alg_sets[i]))
        print(f"    {len(alg_sets[i])} new permutations")

    algs = []
    for v in alg_sets:
        algs.extend(v)
    print(f"found {len(algs)} expressions")

    with open("all_algs.json", "w") as outfile:
        json.dump(algs, outfile)
    print("wrote to file")

if __name__ == "__main__":
    main()
    