#!/bin/bash

__args=( "$@" );

sections() {
	declare start="${1:?Start string required}";

	__handleParts "grep '^$start' ${0@Q} | cut -b'$(( ${#start} + 1 ))-' | grep -v '^$'" "sed -n -e '/^$start'\${part:-}'$/,/^--/{//!p}' ${0@Q}";
}

files() {
	declare general="${1}";
	shift;
	declare -a sections=( "$@" );
	declare base="$(dirname "$0")/";

	printf -v list '%s\n' "${sections[@]}";
	printf -v in '|%q' "${sections[@]}";

	in="${in:1}";

	__handleParts "echo -en ${list@Q}" "case \${part:-} in \"\") $(
		if [ -n "$general" ]; then
			echo "cd ${base@Q};cat ${general@Q}";
		fi;
	);;$in) cd ${base@Q};cat \$part;;esac";
}

__description() {
	sed -n '/^#/!q; p' | sed -e '1{/^#!/d}' -e 's/^# *//';
}

__flags() {
	while read line; do
		printf "%s\0%s\0%s\0" "$(echo "$line" | cut -d' ' -f2)" "$(echo "$line" | cut -d'#' -f1 | cut -d' ' -f3)" "$(echo "$line" | cut -s -d'#' -f2-)";
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

__flag_type() {
	declare type="$(echo "$1" | sed -e 's/^\["//' -e 's/\]$//')";

	if [ "$type" != "boolean" ]; then
		echo " $type";
	fi;
}

__section_help() {
	declare sectionFn="$1";
	declare part="$2";
	declare additional=false;
	declare additionalDesc="";

	echo -n "Usage: $0 $part [--help]";

	while read -r -d '' flag && read -r -d '' type && read -r -d '' desc; do
		flag="${flag%,*}";

		if [ "$flag" = "..." ]; then
			additional=true;
			additionalDesc="$desc";
		elif [ "${type:0:1}" = "[" ]; then
			echo -n " [$flag$(__flag_type "${type:-value}")]";
		else
			echo -n " $flag$(__flag_type "${type:-value}")";
		fi;
	done < <(eval "$sectionFn" | __flags);

	if $additional; then
		echo " ARGS";
	fi;

	echo;

	eval "$sectionFn" | __description;

	declare maxLength="$(
		eval "$sectionFn" | __flags | while read -r -d '' flag && read -r -d '' && read -r -d ''; do
			echo "$flag";
		done | wc -L;
	)";

	echo -e "\nFlags:";

	while read -r -d '' flag && read -r -d '' type && read -r -d '' desc; do
		if [ -n "$desc" -a "$flag" != "..." ]; then
			printf "  %-${maxLength}s" "$flag";
			echo "  $desc";
		fi;
	done < <(eval "$sectionFn" | __flags);

	if [ -n "$additionalDesc" ]; then
		echo -e "\nArgs:\n$(echo "$additionalDesc" | sed -e 's/^/  /')";
	fi;
}

__handleParts() {
	declare partsFn="$1";
	declare sectionFn="$2";

	set -- "${__args[@]}";

	if [ "${1:-}" = "--help" ]; then
		__help "$partsFn" "$sectionFn";

		exit 0;
	fi;

	if [ -z "${1:-}" ]; then
		{
			echo -e "Error: Subcommand required\n";
			__help "$partsFn" "$sectionFn";

			exit 1;
		} >&2;
	fi;

	if [ -z "$(eval "$partsFn" | grep "^$1$")" ]; then
		{
			echo -e "Error: Unknown subcommand $1\n";
			__help "$partsFn" "$sectionFn";

			exit 1;
		} >&2;
	fi;

	declare part="$1";
	shift;

	declare -A flags=();
	declare -A required=();
	declare -A setFlags=();
	declare -A aliases=();
	declare -a args=();
	declare hasAdditional=false;

	while read -r -d '' flag && read -r -d '' type && read -r -d ''; do
		{
			read flag;

			while read alias; do
				aliases[$alias]="$flag";
			done;
		} < <(echo "$flag" | tr ',' '\n');

		if [ "$flag" = "..." ]; then
			hasAdditional=true;
		elif [ "$type" = "boolean" ]; then
			setFlags[$flag]="false";
		elif [ "${type:0:1}" = "[" -a "${type: -1}" = "]" ]; then
			flags[$flag]="${type:1:-1}";
		else
			required[$flag]=true;
			flags[$flag]="$type";
		fi;
	done < <(eval "$sectionFn" | __flags);

	while [ $# -gt 0 ]; do
		declare flag="$1";
		shift;

		if [ -v aliases[$flag] ]; then
			flag="${aliases[$flag]}";
		fi;

		if [ "$flag" = "--help" ]; then
			__section_help "$sectionFn" "$part";

			exit 0;
		elif [ ! -v flags[$flag] ]; then
			if $hasAdditional; then
				args+=( "$flag" );

				continue;
			else
				{
					echo -e "Error: Unknown flag: $flag\n";
					__section_help "$sectionFn" "$part";

					exit 2;
				} >&2;
			fi;
		fi;

		if [ "${flags[$flag]}" = "boolean" ]; then
			setFlags[$flag]="true";
		elif [ $# -eq 0 ]; then
			{
				echo -e "Error: Flag requires value: $flag\n";
				__section_help "$sectionFn" "$part";

				exit 2;
			} >&2;
		else
			setFlags[$flag]="$1";
		fi;

		shift;
	done;

	for flag in "${!required[@]}"; do
		if [ ! -v setFlags[$flag] ]; then
			{
				echo -e "Error: Required flag not set: $flag\n";
				__section_help "$sectionFn" "$part";

				exit 2;
			} >&2;
		fi;
	done;

	mapfile -d '' CMD < <(
		(
			eval "$sectionFn" | head -n1;
			unset part;
			eval "$sectionFn" | head -n1;
		) | {
			grep "^#!" | head -n1 | cut -b 3- || echo -n "$BASH";
		} | xargs printf '%s\0';
	);

	"${CMD[@]}" <(
		(
			unset part;
			eval "$sectionFn";
		)

		for flag in "${!setFlags[@]}"; do
			echo "declare $(echo "$flag" | tr -d '-')=${setFlags[$flag]@Q}";
		done;

		eval "$sectionFn";
	) "${args[@]}";
}
