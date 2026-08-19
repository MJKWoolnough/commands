#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

sections --;

--abc
# The first subcommand
: --flag string # First flag
: --another boolean # Second flag

echo "${flag:-BAD}"
echo "${another:-BAD}"

--defgh
# The second subcommand
: --flag [string] # First flag
: --another number # Second flag

echo "${flag:-GOOD}"
echo "${another:-BAD}"
