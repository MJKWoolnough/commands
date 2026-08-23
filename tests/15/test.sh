#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

commands --;

--abc
# The first subcommand
: --id id# # First flag
: --ver [version##] # Second flag

echo $id;
echo ${ver:-NONE};
