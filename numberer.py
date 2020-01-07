import sys
import re

usage = """\
usage: numberer [fix|unfix] <file>
   use fix to change @name to numbered list
   use unfix to change numbered list back to @name
"""

try:
    way = sys.argv[1]
    assert(way == "fix" or way == "unfix")
    filename = sys.argv[2]
    infile = open(filename)
except:
    sys.stderr.write(usage)
    sys.exit()

lines = infile.readlines()
infile.close()

exercise = 1

def fix(l):
    global exercise
    newl = re.sub(r'^@([^ ]+)\.',r'<!--@\1-->',l)
    if l != newl:
        newl = ("%d. " % exercise) + newl
        exercise += 1
        sys.stderr.write(newl)
    return newl

def unfix(l):
    newl = re.sub(r'^[1-9]+\. <!--(@[^-]*)-->',r'\1.',l)
    if l != newl:
        sys.stderr.write(newl)
    return newl

for l in lines:
    if way == "fix":
        newl = fix(l)
    else:
        newl = unfix(l)

    sys.stdout.write(newl)

