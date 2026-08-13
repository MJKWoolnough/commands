#!/bin/bash

sections() {
	declare start="${1:?Start string required}";

	grep "^$start" $0 | cut -b"$(( ${#start} + 1))-";
}
