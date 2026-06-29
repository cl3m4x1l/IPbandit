#! /usr/bin/env bash


######################################################################
# banlist aggregator 
######################################################################

# /opt/clemaxil/IPbandit/extras
BASEDIR=$(readlink -f $0 | xargs dirname) 

if ! command -v curl >/dev/null; then
        echo "ERROR : You need to install package curl"
        exit 1
fi

if ! command -v sipcalc >/dev/null; then
        echo "ERROR : You need to install package sipcalc"
        exit 1
fi


# Calculate execution time
start_time=$(date +%s)
echo "Banlist Aggregator Start"
echo "Basedir $BASEDIR"


# init files for IP
ALL_LISTS_FILE="$BASEDIR/../list.d/IPbandit_all.txt"
WHITELIST_FILE="$BASEDIR/../list.d/IPbandit_whitelist.txt"
IPV4_FILE="$BASEDIR/../list.d/IPbandit_ipv4.txt"
IPV4_CIDR_FILE="$BASEDIR/../list.d/IPbandit_ipv4_cidr.txt"
IPV6_CIDR_FILE="$BASEDIR/../list.d/IPbandit_ipv6_cidr.txt"
> "$ALL_LISTS_FILE"
> "$IPV4_FILE"
> "$IPV4_CIDR_FILE"
> "$IPV6_CIDR_FILE"


# Copy personal list files in directory extras/list.d/ into directory to run
cp "$BASEDIR"/list.d/*.list "$BASEDIR/../list.d/"
mv "$BASEDIR/../list.d/whitelist.list" "$BASEDIR/../list.d/$WHITELIST_FILE"

i=1
while IFS= read -r url; do
    # Supprime les espaces en début/fin
    url="$(echo "$url" | xargs)"

    # Ignore lignes vides et commentaires
    [[ -z "$url" || "$url" =~ ^# ]] && continue

    echo "Download $url ..."

    tmpfile=$(mktemp)

    # Téléchargement
    if curl -fsSL --retry 3 "$url" -o $tmpfile; then

        # Détection gzip via la commande file
        if file "$tmpfile" | grep -qi 'gzip'; then
            echo "gzip compressed detected, décompress..."

            if gunzip -c $tmpfile > "$BASEDIR/../list.d/${i}.list"; then
                echo "Save (ungzip) in ${i}.list"
                cat "$BASEDIR/../list.d/${i}.list" >> "$ALL_LISTS_FILE"
                ((i++))
            else
                echo "ERROR ungzip"
            fi
        else
            mv $tmpfile "$BASEDIR/../list.d/${i}.list"
            cat "$BASEDIR/../list.d/${i}.list" >> "$ALL_LISTS_FILE"
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


# Concatène tous les fichiers .list
find "$BASEDIR/../list.d" -type f -name "*.list" -exec cat {} + >> "$ALL_LISTS_FILE"

# Erase file list tmp
rm -f $BASEDIR/../list.d/*.list

echo "Download lists finished"


# clean all lines
sed -E '
/^[[:space:]]*:/d
s/[#;!$].*//
s/[[:space:]]+//g
/^$/d
' "$ALL_LISTS_FILE" | LC_ALL=C sort -u -o "$ALL_LISTS_FILE"



#Calculate execution time
end_time=$(date +%s)
duration=$((end_time - start_time))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
printf "Time execute : %02d:%02d:%02d\n" $hours $minutes $seconds

echo "In progress, please wait ..."


# filter the IP type line by line
while IFS= read -r line || [[ -n "$line" ]]; do

    # IPv4 subnet
    if [[ $line =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        echo "$line" >> "$IPV4_CIDR_FILE"

    # IPv4 simple
    elif [[ $line =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "$line" >> "$IPV4_FILE"

    # IPv6 subnet
    elif [[ $line =~ ^([0-9a-fA-F:]+)/[0-9]{1,3}$ ]]; then
        echo "$line" >> "$IPV6_CIDR_FILE"
    # IPv6 simple
    elif [[ $line =~ ^[0-9a-fA-F:]+$ ]]; then
        echo "$line" >> "$IPV6_CIDR_FILE"

    fi

done < "$ALL_LISTS_FILE"


# Convert IPv6 to subnet /64
tmpfile=$(mktemp)

while read -r ip; do
    [[ -z "$ip" ]] && continue

    sipcalc "$ip/64" 2>/dev/null \
        | awk -F'- ' '/Subnet/ {print $2}'

done < "$IPV6_CIDR_FILE" | sort -u > "$tmpfile"

mv "$tmpfile" "$IPV6_CIDR_FILE"



###### ADD sort u for ipv4, ipv4 cidr, ipv6 cidr file


IPV4_COUNT=$(wc -l < "$IPV4_FILE")
IPV4_CIDR_COUNT=$(wc -l < "$IPV4_CIDR_FILE")
IPV6_CIDR_COUNT=$(wc -l < "$IPV6_CIDR_FILE")

echo "--------------------------------------"
echo "IPv4       : $IPV4_COUNT"
echo "IPv4 CIDR  : $IPV4_CIDR_COUNT"
echo "IPv6 CIDR  : $IPV6_CIDR_COUNT"
echo "--------------------------------------"


#End execution time
end_time=$(date +%s)
duration=$((end_time - start_time))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
printf "Time execute : %02d:%02d:%02d\n" $hours $minutes $seconds
echo "Banlist Aggregator stop"
