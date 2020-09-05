# Find @label. at start of line and replace with
# ::: {.exercise ex:label} <newline>

sed -E $'s/^@([^.]*)\. /::: {.exercise #ex:\\1}\\\n/'
