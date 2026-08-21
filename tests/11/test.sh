#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

commands --;

--abc
: --alias,-a string # Aliased flag

echo $alias;
