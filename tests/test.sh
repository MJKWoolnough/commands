#!/bin/bash

cd "$(dirname "$0")";

declare -A tests=(
	["1/test.sh"]="Error: Subcommand required

Usage: 1/test.sh [--help] SUBCOMMAND

Subcommands:
  abc  "
	["1/test.sh --help"]="Usage: 1/test.sh [--help] SUBCOMMAND

Subcommands:
  abc  "
  	["1/test.sh abc"]="1"
  	["1/test.sh abc --help"]="Usage: 1/test.sh [--help] abc"
);

for cmd in "${!tests[@]}"; do
	declare result="$($cmd 2>&1)";

	if [ "$result" != "${tests[$cmd]}" ]; then
		echo "Command: $cmd";
		echo "	Expecting: ${tests[$cmd]}";
		echo "	Got: $result";
	fi;
done;
