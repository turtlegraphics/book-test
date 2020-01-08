import sys
import re

usage = """\
usage: numberer [fix|unfix] <file>
   use fix to change @name to numbered list
   use unfix to change numbered list back to @name
"""

# Argument parsing
try:
    way = sys.argv[1]
    assert(way == "fix" or way == "unfix")
    filename = sys.argv[2]
    infile = open(filename)
except:
    sys.stderr.write(usage)
    sys.exit()

# Read file
lines = infile.readlines()
infile.close()

# Build dictionary of @problems (if fixing)
exnum = 1
exercises = {}
if way == "fix":
    for l in lines:
        match = re.match(r'^@(\w+)\.',l)
        if match:
            exercises[match.group(1)] = exnum
            exnum += 1

# Convert
def replace_definition(match):
    """Given a match to @word. at start of line, return the exercise
    number with  a following comment #.<!--@word.-->
    If word is not an exercise, leave it unchanged."""
    if match.group(1) in exercises:
        r = str(exercises[match.group(1)])
        r += match.expand(r'. <!--\1.-->')
    else:
        r = match.group(0)
    return r

def replace_reference(match):
    """Given a match to @word, return the exercise number with
    a following comment <!--@word-->. If word is not an exercise,
    leave it unchanged."""
    if match.group(1) in exercises:
        r = str(exercises[match.group(1)])
        r += match.expand(r'<!--@\1-->')
    else:
        r = match.group(0)
    return r

for l in lines:
    if way == "fix":
        newl = re.sub(r'^@(\w+).',replace_definition,l)
        newl = re.sub(r'@(\w+)',replace_reference, newl)
    else:
        newl = re.sub(r'^[0-9]+. <!--(\w+).-->',r'@\1.',l)
        newl = re.sub(r'[0-9]+<!--@(\w+)-->',r'@\1',newl)

    sys.stdout.write(newl)
