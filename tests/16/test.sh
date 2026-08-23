#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

commands --;

--abc
: --flag string

echo "$flag";
