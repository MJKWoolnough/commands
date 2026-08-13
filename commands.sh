#!/bin/bash

__args=("$@");

sections() {
	declare start="${1:?Start string required}";

	__handleParts "grep '^$start' ${0@Q} | cut -b'$(( ${#start} + 1))-' | grep -v '^$'"  "sed -n -e '/^$start'\${part:-}'$/,/^--/{//!p}' ${0@Q}";
}

__description() {
	sed -n '/^#/!q; p' | sed -e 's/^# *//';
}

__help() {
	declare partsFn="$1";
	declare sectionFn="$2";

	echo "Usage: $0 [--help] SUBCOMAND";
	
	eval "$sectionFn" | __description;

	echo;

	declare maxLength="$(eval "$partsFn" | wc -L)";

	echo "Subcommands:";

	while read part; do
		printf "  %-${maxLength}s" "$part";
		echo -n "  ";

		echo "$(eval "$sectionFn" | __description)";
	done < <(eval "$partsFn");
}

__handleParts() {
	declare partsFn="$1";
	declare sectionFn="$2";

	if [ "${__args[0]:-}" = "--help" ]; then
		__help "$partsFn" "$sectionFn";

		exit 0;
	fi;

	if [ -z "${__args[0]}" ]; then
		{
			echo -e "Error: Subcommand required\n";
			__help "$partsFn" "$sectionFn";

			exit 1;
		} >&2;
	fi;

	if [ -z "$(eval "$partsFn" | grep "^${__args[0]}$")" ]; then
		{
			echo -e "Error: Unknown subcommand ${__args[0]}\n";
			__help "$partsFn" "$sectionFn";

			exit 1;
		} >&2;
	fi;
}
