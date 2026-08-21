#!/bin/bash
# My command
: --flag string # A flag

. "$(dirname "$0")/../../commands.sh";

solo;

echo "${flag:-BAD}";
echo 123;
