#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

func() {
	declare script="$1";
	shift
	echo "Global Func";
	. "$script" ;
}

files global abc def;
