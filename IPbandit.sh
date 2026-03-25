#!/bin/bash

######################################################################
#
# IPbandit : IP blacklist aggregator
#
######################################################################

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

BASEDIR=$(readlink -f $0 | xargs dirname)


if ! command -v curl >/dev/null; then
        echo "ERROR : You need to install package curl"
        exit 1
fi



# Calculate execution time
start_time=$(date +%s)
echo "IPbandit Start"


# Directory banned list storage
cd "$BASEDIR/list.d" 
rm -f *.list

# Copy list files in directory extras/list.d/ into directory to run
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

            if gunzip -c "$tmpfile" > "${i}.list"; then
                echo "Save (ungzip) in ${i}.list"
                ((i++))
            else
                echo "ERROR ungzip"
            fi
        else
            mv "$tmpfile" "${i}.list"
            echo "Save in ${i}.list"
            ((i++))
            continue
        fi

        rm -f "$tmpfile"
    else
        echo "ERROR download $url"
        rm -f "$tmpfile"
    fi

done < "$BASEDIR/IPbandit_custom.txt"



echo "Download lists finished"



# Fichier de sortie dans le répertoire parent
ALL_LISTS_FILE="IPbandit_all.txt"

# Vider le fichier de sortie s'il existe déjà
> "$ALL_LISTS_FILE"

# Boucle sur tous les fichiers .list du répertoire courant
for file in *.list; do
    # Vérifie qu'il existe au moins un fichier correspondant
    [ -e "$file" ] || continue
    
    cat "$file" >> "$ALL_LISTS_FILE"
done

echo "Concat finished in $ALL_LISTS_FILE"




sed -e 's/^#.*//' -e 's/;.*//' -e 's/!.*//' -e 's/\$.*//' -e 's/^:.*//' -e 's/[[:space:]].*//' -e 's/[[:space:]]//g' -e '/^$/d' "$ALL_LISTS_FILE" | sort -u > "tmp.txt" && mv "tmp.txt" "$ALL_LISTS_FILE"


if [[ -z "$ALL_LISTS_FILE" || ! -f "$ALL_LISTS_FILE" ]]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

IPV4_FILE="IPbandit_ipv4.txt"
IPV6_FILE="IPbandit_ipv6.txt"
IPV4_SUBNET_FILE="IPbandit_ipv4_subnet.txt"
IPV6_SUBNET_FILE="IPbandit_ipv6_subnet.txt"

> "$IPV4_FILE"
> "$IPV6_FILE"
> "$IPV4_SUBNET_FILE"
> "$IPV6_SUBNET_FILE"

TOTAL_LINES=$(wc -l < "$ALL_LISTS_FILE")
CURRENT=0

# Fonction barre de progression
progress_bar() {
    local progress=$1
    local total=$2
    local percent=$(( progress * 100 / total ))
    local filled=$(( percent / 2 ))
    local empty=$(( 50 - filled ))

    printf "\r["
    printf "%0.s#" $(seq 1 $filled)
    printf "%0.s-" $(seq 1 $empty)
    printf "] %d%% (%d/%d)" "$percent" "$progress" "$total"
}

# Lecture ligne par ligne (streaming)
while IFS= read -r line || [[ -n "$line" ]]; do
    ((CURRENT++))

    # Nettoyage
    line="${line%%#*}"                # Supprimer commentaire
    line="$(echo "$line" | xargs -0)"    # Trim
    [[ -z "$line" ]] && continue

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

    # Afficher progression toutes les 100 lignes (réduit CPU)
    if (( CURRENT % 100 == 0 )); then
        progress_bar "$CURRENT" "$TOTAL_LINES"
        sleep 0.01   # Petite pause pour éviter 100% CPU
    fi

done < "$ALL_LISTS_FILE"

# Barre finale 100%
progress_bar "$TOTAL_LINES" "$TOTAL_LINES"

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


# Directory banned list storage
cd "$BASEDIR/list.d" 
rm -f *.list



#Calculate execution time
end_time=$(date +%s)
duration=$((end_time - start_time))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
printf "Time execute : %02d:%02d:%02d\n" $hours $minutes $seconds
echo "IPbandit stop"
