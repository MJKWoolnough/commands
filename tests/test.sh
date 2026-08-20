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
	["4/test.sh"]="Error: Subcommand required

Usage: 4/test.sh [--help] SUBCOMMAND

Subcommands:
  abc    The first subcommand
  defgh  The second subcommand"
  	["4/test.sh abc --help"]="Usage: 4/test.sh [--help] abc --flag string [--another]
The first subcommand

Flags:
  --flag     First flag
  --another  Second flag"
  	["4/test.sh defgh --help"]="Usage: 4/test.sh [--help] defgh [--flag string] --another number
The second subcommand

Flags:
  --flag     First flag
  --another  Second flag"
  	["4/test.sh abc"]="Error: Required flag not set: --flag

Usage: 4/test.sh [--help] abc --flag string [--another]
The first subcommand

Flags:
  --flag     First flag
  --another  Second flag"
  	["4/test.sh abc --flag something"]="something
false"
  	["4/test.sh abc --flag somethingElse --another"]="somethingElse
true"
  	["4/test.sh abc --flag something --other"]="Error: Unknown flag: --other

Usage: 4/test.sh [--help] abc --flag string [--another]
The first subcommand

Flags:
  --flag     First flag
  --another  Second flag"
  	["4/test.sh defgh"]="Error: Required flag not set: --another

Usage: 4/test.sh [--help] defgh [--flag string] --another number
The second subcommand

Flags:
  --flag     First flag
  --another  Second flag"
  	["4/test.sh defgh --another"]="Error: Flag requires value: --another

Usage: 4/test.sh [--help] defgh [--flag string] --another number
The second subcommand

Flags:
  --flag     First flag
  --another  Second flag"
  	["4/test.sh defgh --another nan"]="Error: Invalid flag value: --another nan

Usage: 4/test.sh [--help] defgh [--flag string] --another number
The second subcommand

Flags:
  --flag     First flag
  --another  Second flag"
  	["4/test.sh defgh --another 123.45"]="GOOD
123.45"
	["5/test.sh func"]="FUNCTION
FUNC"
	["5/test.sh bash"]="BASH"
	["5/test.sh python"]="123"
	["6/test.sh"]="Error: Subcommand required

Usage: 6/test.sh [--help] SUBCOMMAND

Subcommands:
  abc  Description"
	["6/test.sh abc"]="123"
	["7/test.sh abc --help"]="Usage: 7/test.sh [--help] abc [--flag string] ARGS
Description

Args:
  Additional args

Flags:
  --flag  Optional flag"
	["7/test.sh abc"]="Global Func
123
ABC
0
No Arg
No Arg"
	["7/test.sh abc 1 2 3"]="Global Func
123
ABC
3
1
2"
	["7/test.sh def"]="123
DEF
0
No Arg
No Arg"
	["7/test.sh def 1 2 3"]="123
DEF
3
1
2"
  	["8/test.sh abc --num nan"]="Error: Invalid flag value: --num nan

Usage: 8/test.sh [--help] abc --num integer

Flags:
  --num  A number"
  	["8/test.sh abc --num 1.1"]="Error: Invalid flag value: --num 1.1

Usage: 8/test.sh [--help] abc --num integer

Flags:
  --num  A number"
  	["8/test.sh abc --num -1"]="-1");

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
