#!/bin/bash
# My command
: --flag string # A flag

. "$(dirname "$0")/../../commands.sh";

commands;

echo "${flag:-BAD}";
echo 123;
