# commands

[![CI](https://github.com/MJKWoolnough/commands/actions/workflows/go-checks.yml/badge.svg)](https://github.com/MJKWoolnough/commands/actions)

The command library provides a simple way to specify flags and subcommands for bash scripts.

## Highlights

 - Ability to specify required or optional flags with basic type checking.
 - Auto-generates usage and help text.
 - Subcommands allowing for isolation of code.
   - Each subcommand can specify its own shebang.
   - Subcommands can be inline, all within a single bash script, or in separate files.
   - Global flags that apply to all subcommands, and subcommand specific flags.
   - Global code that is shared between all subcommands.

## Usage

The command library can be used in three distinct ways; flag parsing for a single script; flag parsing and subcommand handling within a single script; or, flag parsing and subcommand handling where subcommands exist in different files.

All three share the same syntax for specifying command descriptions and flags:

```bash
#!shebang-command
# Description of my command 
: --flag type # Description of my flag
```

### Shebang

The shebang will be the command executed and provided a path to the generated script, as well as any additional arguments. The shebang can be a function declared previously in the script.

Unlike a normal shebang, it can contain any number of additional arguments which will be specified before the script path.

If a shebang isn't specified, then bash will be used, unless a shebang is specified in a 'global' script, in which case that one will be used.

NB: This is only handled for subcommands; when no subcommands are set execution simple continues after the `commands` call.

### Description

Multiple command description lines can be used as long as they're one after the other with no gaps.

Each subcommand can have its own description which is printed both as part of that subcommands help text and as part of the global help text.

A description at the top 

### Flags

Likewise, multiple flags can be specified one after the other; the description for a flag is optional.

For the `--flag`, this is a comma separated set of flags that all correspond to the same setting.

To read the value of a flag, the first flag name is stripped of prefixed dashes and that is set to the value given to the flag.

#### Types

If a flag specifies no type string, that flag is treated as a boolean flag; optional and does not process any value, just setting the flag var to `true` if set. Multiple, single-dash boolean flags can be specified as a combined flag:

```bash
command -a -b -c

# OR

command -abc
```

If a flag type ends in a hash, the flag value will be checked as an integer, throwing an error on a mismatch.

If a flag type ends in two hashes, the flag value will be checked as a float; again, throwing an error on a mismatch.

If a flag is surrounded by '[' and ']' that flag is treated as optional, and will be unset in the generated script if not specified.

If a flag ends in '[]' the flag will be parsed as an array. Each time the flag is specified its value gets added as a new item to that array.

The type string itself is otherwise arbitrary and should be used for documentation purposes.

## Examples

### Single script

```bash
#!/bin/bash
# Print IDs.
: --json,-j       # Print as JSON
: --id id#        # Numeric ID
: --desc [string] # An optional description

. ./commands.sh;

commands;

if $json; then
	echo "ID: $id"
	[ -n "$desc" ] && echo "Description: $desc";
else
	echo -n "{\"id\": \"$id\""
	[ -n "$desc" ] && echo " ,\"description\": $(printf "%q" "$desc")";
	echo "}";
fi;
```

The commands call in the above script will parse the specified flags and validate them from the arguments given to the script. On an error, or if `--help` is specified, the following help text will be generated:

```
Usage: ./example.sh [--help] [--json] --id id [--desc string]
Print IDs.

Flags:
  --json,-j  Print as JSON
  --id       Numeric ID
  --desc     An optional description
```

### Multiple Subcommands in a Single Script

```bash
#!/bin/bash

. ./commands.sh;

commands "##";

##
# A collection of simple scripts for managing a service.
: --service name # Name of service to manage

##restart
# Restart the named service
: --when [string] # Time/Date to restart the service; defaults to now.

restart_service "$service" "${when:-now}";

##update
# Update the named service

run_update "$service";
```

### Multiple Subcommands in a Multiple Files

`service.sh`:

```bash
#!/bin/bash

. ./commands.sh;

commands global restart update;
```

`global`:

```bash
# A collection of simple scripts for managing a service.
: --service name # Name of service to manage
```

`restart`:

```bash
# Restart the named service
: --when [string] # Time/Date to restart the service; defaults to now.

restart_service "$service" "${when:-now}";
```

`update`:

```bash
# Update the named service

run_update "$service";
```
