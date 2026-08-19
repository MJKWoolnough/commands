#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

some_func() {
	echo "FUNCTION";

	bash "$1";
}

sections --;

--func
#!some_func

echo "FUNC";

--bash
#!/bin/bash
# Description

echo BASH;

--python
#!/usr/bin/python

print(123)
