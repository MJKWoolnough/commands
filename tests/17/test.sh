#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

commands --;

--abc
# The first subcommand
: --flag string[] # First flag
: --another,-a []    # Second flag

echo "${flag[@]}";
echo "${flag:-NONE}";

echo "${another:-NONE}";
echo "${#another[@]}";
