#!/bin/bash

cd "$(dirname "$0")";

completions() {
	declare CMD="$1";
	declare COMP_CWORD="$2";
	shift 2;
	declare -a COMP_WORDS=( "$CMD" "$@" );
	declare COMP_LINE="$@";

	declare -a COMPREPLY;

	. <("$CMD" --completions);

	declare tmpDir="$(mktemp -d)";

	trap "rm -rf ${tmpDir@Q}" EXIT;

	cd "$tmpDir";
	touch "$tmpDir/aFile";
	touch "$tmpDir/bFile";
	touch "$tmpDir/zFile";

	"$(declare -F | grep __do_completion | cut -d' ' -f3)";

	cd - > /dev/null;
	rm -rf "$tmpDir";

	echo "${COMPREPLY[@]}";
}

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
  	["8/test.sh abc --num -1"]="-1"
  	["9/test.sh --help"]="Usage: 9/test.sh [--help] SUBCOMMAND --global string

Subcommands:
  abc

Global Flags:
  --global  A global flag"
  	["9/test.sh abc --help"]="Usage: 9/test.sh [--help] abc --global string --another string

Flags:
  --another  Sub flag

Global Flags:
  --global  A global flag"
  	["9/test.sh abc --another string"]="Error: Required flag not set: --global

Usage: 9/test.sh [--help] abc --global string --another string

Flags:
  --another  Sub flag

Global Flags:
  --global  A global flag"
  	["9/test.sh abc --global Foo --another Bar"]="Foo -> Bar"
  	["10/test.sh abc"]="1 2 3
4"
  	["11/test.sh abc --help"]="Usage: 11/test.sh [--help] abc --alias string

Flags:
  --alias,-a  Aliased flag"
  	["11/test.sh abc --alias test"]="test"
  	["11/test.sh abc -a test"]="test"
  	["12/test.sh"]="Error: Required flag not set: --flag

Usage: 12/test.sh [--help]  --flag string
My command

Flags:
  --flag  A flag"
  	["12/test.sh --flag abc"]="abc
123"
  	["13/test.sh abc"]="123
echo \"123\";
cat \"\$0\";"
  	["13/test.sh def"]="456

echo \"456\";
cat \"\$0\";"
  	["14/test.sh abc -abc"]="true
true
true
false"
  	["14/test.sh abc -abce"]="Error: Unknown flag: -abce

Usage: 14/test.sh [--help] abc [-a] [--big] [-c] [-d] [-e string]"
  	["15/test.sh abc --id 123"]="123
NONE"
  	["15/test.sh abc --id 123.1"]="Error: Invalid flag value: --id 123.1

Usage: 15/test.sh [--help] abc --id id [--ver version]
The first subcommand

Flags:
  --id   First flag
  --ver  Second flag"
  	["15/test.sh abc --id 123 --ver 1.1"]="123
1.1"
  	["16/test.sh abc --flag 123"]="123"
  	["16/test.sh abc --flag 123 --flag 456"]="Error: Flag already set: --flag

Usage: 16/test.sh [--help] abc --flag string"
  	["17/test.sh abc --help"]="Usage: 17/test.sh [--help] abc [--flag string]... [--another]...
The first subcommand

Flags:
  --flag        First flag
  --another,-a  Second flag"

  	["17/test.sh abc"]="
NONE
NONE
0"
	["17/test.sh abc --flag a --flag b --another --another --another"]="a b
a
true
3"

	["17/test.sh abc --flag a -aaa --another --another"]="a
a
true
5"
	["18/test.sh --id 1 --id 20 --id 99"]="ID: 1
ID: 20
ID: 99"
	["18/test.sh --id 1 --id 20 --id bad"]="Error: Invalid flag value: --id bad

Usage: 18/test.sh [--help]  [--id id]...
List IDs

Flags:
  --id  ID"
	["19/test.sh --help"]="Usage: 19/test.sh [--help]  [--flag string]

Flags:
  --flag  Default: ABC"
	["19/test.sh"]="ABC"
	["19/test.sh --flag DEF"]="DEF"
	["completions 19/test.sh 1"]="--flag"
	["completions 19/test.sh 1 --"]="--flag"
	["completions 20/test.sh 1"]="abc def"
	["completions 20/test.sh 1 a"]="abc"
	["completions 20/test.sh 1 d"]="def"
	["completions 20/test.sh 2 abc --"]="--flag --flbg"
	["completions 20/test.sh 2 abc --fla"]="--flag"
	["completions 20/test.sh 2 abc --flb"]="--flbg"
	["completions 20/test.sh 2 def"]="--flag2"
	["completions 21/test.sh 1"]="abc def"
	["completions 21/test.sh 2 abc"]="--everywhere --global --numberFlag --stringFlag"
	["completions 21/test.sh 2 def"]="--everywhere --floatFlag --global aFile bFile zFile"
	["completions 21/test.sh 2 def --e"]="--everywhere"
	["completions 21/test.sh 2 def z"]="zFile"
	["completions 22/test.sh 2 abc"]="--everywhere --global --numberFlag --stringFlag aFile bFile zFile"
);

declare debug=false;

if [ "$1" = "--debug" ]; then
	debug=true;
fi;

declare code=0;

for cmd in "${!tests[@]}"; do
	declare result="$($cmd 2>&1)";

	if [ "$result" != "${tests[$cmd]}" ]; then
		echo "Command: $cmd";
		echo "Command: $cmd" | sed -e 's/./=/g';
		echo;
		echo -e "Expecting\n---------";
		$debug && xxd <<< "${tests[$cmd]}" || echo "${tests[$cmd]}";
		echo;
		echo -e "Got\n---";
		$debug && xxd <<< "$result" || echo "$result";
		echo;

		code=1;
	fi;
done;

exit $code;
