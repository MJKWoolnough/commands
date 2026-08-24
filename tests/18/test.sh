#!/bin/bash
# List IDs
: --id id#[] # ID

. "$(dirname "$0")/../../commands.sh";

commands;

for i in "${id[@]}"; do
	echo "ID: $i";
done;
