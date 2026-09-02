#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

some_func() {
	echo "FUNCTION";

	bash "$1";
}

commands --;

--func
#!some_func

echo "FUNC";

--bash
#!/bin/bash
# Description

echo BASH;

--perl
#!/usr/bin/perl

print(123)
