#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

sections --;

--abc
: --alias,-a string # Aliased flag

echo $alias;
