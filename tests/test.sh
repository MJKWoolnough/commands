#!/bin/bash

cd "$(dirname "$0")";

declare -A tests=(
	["1/test.sh"]="Error: Subcommand required

Usage: 1/test.sh [--help] SUBCOMMAND

Subcommands:
  abc"
	["1/test.sh --help"]="Usage: 1/test.sh [--help] SUBCOMMAND

Subcommands:
  abc"
	["1/test.sh abc"]="1"
	["1/test.sh abc --help"]="Usage: 1/test.sh [--help] abc"
	["2/test.sh"]="Error: Subcommand required

Usage: 2/test.sh [--help] SUBCOMMAND

Subcommands:
  abc
  def"
	["2/test.sh --help"]="Usage: 2/test.sh [--help] SUBCOMMAND

Subcommands:
  abc
  def"
	["2/test.sh abc"]="1"
	["2/test.sh def"]="2"
	["2/test.sh abc --help"]="Usage: 2/test.sh [--help] abc"
	["2/test.sh def --help"]="Usage: 2/test.sh [--help] def"
	["3/test.sh"]="Error: Subcommand required

Usage: 3/test.sh [--help] SUBCOMMAND

Subcommands:
  abc    The first subcommand
  defgh  The second subcommand"
  	["3/test.sh abc --help"]="Usage: 3/test.sh [--help] abc
The first subcommand"
  	["3/test.sh defgh --help"]="Usage: 3/test.sh [--help] defgh
The second subcommand"
);

declare debug=false;

if [ "$1" = "--debug" ]; then
	debug=true;
fi;

for cmd in "${!tests[@]}"; do
	declare result="$($cmd 2>&1)";

	if [ "$result" != "${tests[$cmd]}" ]; then
		echo "Command: $cmd";
		echo "Command: $cmd" | sed -e 's/./=/g';
		echo;
		echo -e "Expecting\n---------";
		$debug && xxd <<<"${tests[$cmd]}" || echo "${tests[$cmd]}";
		echo;
		echo -e "Got\n---";
		$debug && xxd <<<"$result" || echo "$result";
		echo;
	fi;
done;
