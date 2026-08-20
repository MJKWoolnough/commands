#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

sections --;

--
: --global string # A global flag

--abc
: --another string # Sub flag

echo "$global -> $another";
