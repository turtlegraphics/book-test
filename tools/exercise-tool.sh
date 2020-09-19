#!/bin/bash

# Replace @label. exercises with new fenced exercises

# Find @label. at start of line and replace with
# :::
# 
# ::: {.exercise ex:label}
#
cat "${1:-/dev/stdin}" |\
grep -v '^[[:space:]]*&nbsp;[[:space:]]*$' |\
sed -E $'s/^@([^.]*)\. /:::\\\n\\\n::: {.exercise #ex:\\1}\\\n/'
