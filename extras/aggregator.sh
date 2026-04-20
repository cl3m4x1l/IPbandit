#!/bin/bash

######################################################################
# banlist aggregator 
######################################################################

BASEDIR=$(readlink -f $0 | xargs dirname)

if ! command -v curl >/dev/null; then
        echo "ERROR : You need to install package curl"
        exit 1
fi




# Calculate execution time
start_time=$(date +%s)
echo "Banlist Aggregator Start"



# init files for IP
ALL_LISTS_FILE="$BASEDIR/list.d/IPbandit_all.txt"
IPV4_FILE="$BASEDIR/list.d/IPbandit_ipv4.txt"
IPV6_FILE="$BASEDIR/list.d/IPbandit_ipv6.txt"
IPV4_SUBNET_FILE="$BASEDIR/list.d/IPbandit_ipv4_subnet.txt"
IPV6_SUBNET_FILE="$BASEDIR/list.d/IPbandit_ipv6_subnet.txt"
> "$ALL_LISTS_FILE"
> "$IPV4_FILE"
> "$IPV6_FILE"
> "$IPV4_SUBNET_FILE"
> "$IPV6_SUBNET_FILE"


# Copy personal list files in directory extras/list.d/ into directory to run
cp "$BASEDIR/extras/list.d"/*.list "$BASEDIR/list.d"/ 2>/dev/null

i=1

while IFS= read -r url; do
    # Supprime les espaces en début/fin
    url="$(echo "$url" | xargs)"

    # Ignore lignes vides et commentaires
    [[ -z "$url" || "$url" =~ ^# ]] && continue

    echo "Download $url ..."

    tmpfile=$(mktemp)

    # Téléchargement
    if curl -fsSL --retry 3 "$url" -o "$tmpfile"; then

        # Détection gzip via la commande file
        if file "$tmpfile" | grep -qi 'gzip'; then
            echo "gzip compressed detected, décompress..."

            if gunzip -c "$tmpfile" > "$BASEDIR/list.d/${i}.list"; then
                echo "Save (ungzip) in ${i}.list"
                cat "$BASEDIR/list.d/${i}.list" >> "$ALL_LISTS_FILE"
                ((i++))
            else
                echo "ERROR ungzip"
            fi
        else
            mv "$tmpfile" "$BASEDIR/list.d/${i}.list"
            cat "$BASEDIR/list.d/${i}.list" >> "$ALL_LISTS_FILE"
            echo "Save in ${i}.list"
            ((i++))
            continue
        fi

        rm -f "$tmpfile"
    else
        echo "ERROR download $url"
        rm -f "$tmpfile"
    fi

done < "$BASEDIR/custom.txt"


# Erase file list tmp
rm -f $BASEDIR/list.d/*.list

echo "Download lists finished"


# clean all lines
sed -E '
/^[[:space:]]*:/d
s/[#;!$].*//
s/[[:space:]]+//g
/^$/d
' "$ALL_LISTS_FILE" | LC_ALL=C sort -u -o "$ALL_LISTS_FILE"

TOTAL_LINES=$(wc -l < "$ALL_LISTS_FILE")
CURRENT=0




#Calculate execution time
end_time=$(date +%s)
duration=$((end_time - start_time))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
printf "Time execute : %02d:%02d:%02d\n" $hours $minutes $seconds

echo "In progress, please wait ..."

# Function for viz
# progress_bar() {
#     local progress=$1
#     local total=$2
#     local percent=$(( progress * 100 / total ))
#     local filled=$(( percent / 2 ))
#     local empty=$(( 50 - filled ))

#     printf "\r["
#     printf "%0.s#" $(seq 1 $filled)
#     printf "%0.s-" $(seq 1 $empty)
#     printf "] %d%% (%d/%d)" "$percent" "$progress" "$total"
# }

# filter the IP type line by line
while IFS= read -r line || [[ -n "$line" ]]; do
    ((CURRENT++))

    # IPv4 subnet
    if [[ $line =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        echo "$line" >> "$IPV4_SUBNET_FILE"

    # IPv4 simple
    elif [[ $line =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "$line" >> "$IPV4_FILE"

    # IPv6 subnet
    elif [[ $line =~ ^([0-9a-fA-F:]+)/[0-9]{1,3}$ ]]; then
        echo "$line" >> "$IPV6_SUBNET_FILE"
    # IPv6 simple
    elif [[ $line =~ ^[0-9a-fA-F:]+$ ]]; then
        echo "$line" >> "$IPV6_FILE"

    fi

    # only 100 lines view progress
    #if (( CURRENT % 100 == 0 )); then
    #    progress_bar "$CURRENT" "$TOTAL_LINES"
    #fi

done < "$ALL_LISTS_FILE"

# End of progress 100%
#progress_bar "$TOTAL_LINES" "$TOTAL_LINES"

IPV4_COUNT=$(wc -l < "$IPV4_FILE")
IPV6_COUNT=$(wc -l < "$IPV6_FILE")
IPV4_SUBNET_COUNT=$(wc -l < "$IPV4_SUBNET_FILE")
IPV6_SUBNET_COUNT=$(wc -l < "$IPV6_SUBNET_FILE")

echo "--------------------------------------"
echo "IPv4 simple   : $IPV4_COUNT"
echo "IPv4 subnet   : $IPV4_SUBNET_COUNT"
echo "IPv6 simple   : $IPV6_COUNT"
echo "IPv6 subnet   : $IPV6_SUBNET_COUNT"
echo "--------------------------------------"


#End execution time
end_time=$(date +%s)
duration=$((end_time - start_time))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
printf "Time execute : %02d:%02d:%02d\n" $hours $minutes $seconds
echo "Banlist Aggregator stop"

