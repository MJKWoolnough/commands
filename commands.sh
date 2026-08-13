#!/bin/bash

__args=("$@");

sections() {
	declare start="${1:?Start string required}";

	__handleParts "grep '^$start' ${0@Q} | cut -b'$(( ${#start} + 1))-' | grep -v '^$'"  "sed -n -e '/^$start'\${part:-}'$/,/^--/{//!p}' ${0@Q}";
}

__description() {
	sed -n '/^#/!q; p' | sed -e 's/^# *//';
}

__flags() {
	while read line; do
		printf "%s\0%s\0%s\0" "$(echo "$line" | cut -d' ' -f2)" "$(echo "$line" | cut -d' ' -f3)" "$(echo "$line" | cut -d'#' -f2-)";
	done < <(sed -n '1,/^[^#:]/p' | grep "^: ");
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

__section_help() {
	declare sectionFn="$1";
	declare part="$2";

	echo "Usage: $0 $part [--help]";

	eval "$sectionFn" | __description;

	echo;

	declare maxLength="$(eval "$sectionFn" | __flags | cut -d '' -f1 | wc -L)";

	while read -r -d '' flag && read -r -d '' type && read -r -d '' desc; do
		printf "  %-${maxLength}s" "$flag";
		echo "  $desc";
	done < <(eval "$sectionFn" | __flags);
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

	__section_help "$sectionFn" "${__args[0]}";
}
