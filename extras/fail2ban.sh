#!/bin/bash

######################################################################
#
# Retrieves IPs banned by all fail2ban jails
#
######################################################################

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if ! command -v fail2ban-client >/dev/null; then
        echo "ERROR : You need to install package fail2ban"
        exit 1
fi


DIR=$(pwd)

OUTPUT_FILE="$DIR/lists/myfail2ban.list"

JAILS=$(fail2ban-client status | grep "Jail list" | cut -d: -f2 | tr ',' ' ')

for JAIL in $JAILS; do
    JAIL=$(echo "$JAIL" | xargs)  # remove unnecessary spaces

    fail2ban-client get "$JAIL" banip | tr ' ' '\n' >> "$OUTPUT_FILE"
done

sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"

