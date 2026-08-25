#!/bin/bash
: --flag [string] # Default: $key

declare key="ABC"

. "$(dirname "$0")/../../commands.sh";

commands;

echo ${flag:-$key};
