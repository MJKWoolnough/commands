#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

commands --;

--abc
: -a boolean
: --big,-b boolean
: -c boolean
: -d boolean

echo "$a";
echo "$big";
echo "$c";
echo "$d";
