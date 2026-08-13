#!/bin/bash

sections() {
	declare start="${1:?Start string required}";

	__handleParts "grep '^$start' ${0@Q} | cut -b'$(( ${#start} + 1))-'"  "sed -n -e '/^$start'\$part'$/,/^--/{//!p}' ${0@Q}";
}

__handleParts() {
	declare partsFn="$1";
	declare sectionFn="$2";

	echo "$sectionFn";
	while read part; do
		echo "$part";
		eval "$sectionFn" <<<"$part";
	done < <(eval "$partsFn");
}
