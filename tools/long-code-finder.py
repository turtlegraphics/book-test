#
# Usage: long-code-finder.py <filenames>
#
# Find source R code inside a chunk with length greater than:
maxcol = 76

import sys
import re

def scanfile(filename):
    lines = [x.strip('\n') for x in open(filename).readlines()]
    in_chunk = False
    lnum = 0
    for line in lines:
        lnum += 1
        if line[:3] == '```':
            in_chunk = not in_chunk
            if in_chunk:
                echo = True
                # determine if this chunk will actually output
                if re.search(r'echo *= *F',line):
                    echo = False

        if in_chunk and echo:
            if len(line) > maxcol:
                print lnum,'   ',line[:50]+'...'

for f in sys.argv[1:]:
    print '-'*len(f)
    print f
    print '-'*len(f)
    scanfile(f)

