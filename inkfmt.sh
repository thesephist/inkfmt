#!/bin/sh
#
# This is a thin wrapper around https://github.com/thesephist/ink
# to give me two CLI commands when this script is placed
# in /usr/local/bin.
#
# 1. I can type `inkfmt file.ink` to see any formatting changes
#    needed in file.ink.
# 2. I can type `inkfmt fix file.ink` to make the script fix
#    all formatting errors in file.ink in-place of the file.

# NOTE: replace this with the path to your local fmt.ink
INKFMT=/home/thesephist/src/inkfmt/fmt.ink

if [[ $1 == "fix" ]]; then
    for file in "${@:2}"
    do
        echo 'inkfmt fix: '$file
        $INKFMT < $file > /tmp/_inkfmt_fix.ink
        cp /tmp/_inkfmt_fix.ink $file
    done
else
    for file in "$@"
    do
        echo 'inkfmt changes in '$file':'
        $INKFMT < $file | diff $file - --color
    done
fi
