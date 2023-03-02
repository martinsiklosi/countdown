import pyximport; pyximport.install()
from countdown_utils import run_numbers

PROFILE = False

if PROFILE:    
    import pstats, cProfile
    cProfile.runctx("run_numbers()", globals(), locals(), "Profile.prof")
    s = pstats.Stats("Profile.prof")
    s.strip_dirs().sort_stats("time").print_stats()
else:
    run_numbers()
