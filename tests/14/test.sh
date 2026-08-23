#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

commands --;

--abc
: -a
: --big,-b
: -c
: -d
: -e [string]

echo "$a";
echo "$big";
echo "$c";
echo "$d";
