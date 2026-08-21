#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

some_func() {
	echo "$1";

	. "$2";
}

commands --;

--abc
#!some_func "1 2 3"

echo 4;
