#!/bin/bash

. "$(dirname "$0")/../../commands.sh";

commands --;

--abc
echo "123";
cat "$0";

--def

echo "456";
cat "$0";
