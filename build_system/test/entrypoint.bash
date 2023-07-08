#!/bin/bash -i

echo
pwd
tree -L 3
echo

exec "${@}"
