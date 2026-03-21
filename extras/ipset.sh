#!/bin/bash

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if ! command -v ipset >/dev/null; then
	echo "ERROR : You need to install package ipset"
	exit 1
fi
