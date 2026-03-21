#!/bin/bash

# Calculate execution time
start_time=$(date +%s)
echo "IPbandit Start"


# Directory banned list storage
cd "/etc/infogiciel/IPbandit/list.d" 
rm -f *.list

# Array sources list : "name|url"
SOURCES=(
"get_bruteforce|http://lists.blocklist.de/lists/bruteforcelogin.txt"
#"get_abuser|https://iplists.firehol.org/files/firehol_abusers_1d.netset"
#"get_datashield|https://raw.githubusercontent.com/duggytuxy/Data-Shield_IPv4_Blocklist/refs/heads/main/prod_data-shield_ipv4_blocklist.txt"
#"get_ipsum|https://raw.githubusercontent.com/stamparm/ipsum/master/levels/3.txt"
#"get_blocklistde|https://lists.blocklist.de/lists/all.txt"
#"get_uceprotect|http://wget-mirrors.uceprotect.net/rbldnsd-all/dnsbl-1.uceprotect.net.gz"
)


# Array lists in extras directory
LISTS=(
infogiciel.list
#censys-scanner.list
);

for entry in "${LISTS[@]}"; do
 cp "/etc/infogiciel/IPbandit/extras/lists/$entry" "/etc/infogiciel/IPbandit/list.d/$entry"
done

# Boucle sur chaque entrée du tableau
for entry in "${SOURCES[@]}"; do

    # Séparation nom et url
    IFS="|" read -r name url <<< "$entry"

    output_file="${name}.list"

    # Téléchargement avec curl
    if curl -fsSL "$url" -o "$output_file"; then
        echo "OK : $output_file donwloaded"
    else
        echo "ERROR download :  $url"
    fi

done

echo "Download lists finished"



# Fichier de sortie dans le répertoire parent
ALL_LISTS_FILE="IPbandit_all.txt"

# Vider le fichier de sortie s'il existe déjà
> "$ALL_LISTS_FILE"

# Boucle sur tous les fichiers .list du répertoire courant
#for file in "$OUTPUT_DIR/"*.list; do
for file in *.list; do
    # Vérifie qu'il existe au moins un fichier correspondant
    [ -e "$file" ] || continue
    
    cat "$file" >> "$ALL_LISTS_FILE"
done

echo "Concat finished in $ALL_LISTS_FILE"




INPUT_FILE="$ALL_LISTS_FILE"

if [[ -z "$INPUT_FILE" || ! -f "$INPUT_FILE" ]]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

IPV4_FILE="IPbandit_ipv4.txt"
#IPV6_FILE="IPbandit_ipv6.txt"
IPV4_SUBNET_FILE="IPbandit_ipv4_subnet.txt"
#IPV6_SUBNET_FILE="IPbandit_ipv6_subnet.txt"

> "$IPV4_FILE"
#> "$IPV6_FILE"
> "$IPV4_SUBNET_FILE"
#> "$IPV6_SUBNET_FILE"

TOTAL_LINES=$(wc -l < "$INPUT_FILE")
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
    line="$(echo "$line" | xargs)"    # Trim
    [[ -z "$line" ]] && continue

    # IPv4 subnet
    if [[ $line =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        echo "$line" >> "$IPV4_SUBNET_FILE"

    # IPv4 simple
    elif [[ $line =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "$line" >> "$IPV4_FILE"

    # IPV6 OPTIONS
    # IPv6 subnet
    #elif [[ $line =~ ^([0-9a-fA-F:]+)/[0-9]{1,3}$ ]]; then
    #    echo "$line" >> "$IPV6_SUBNET_FILE"
    # IPv6 simple
    #elif [[ $line =~ ^[0-9a-fA-F:]+$ ]]; then
    #    echo "$line" >> "$IPV6_FILE"

    fi

    # Afficher progression toutes les 100 lignes (réduit CPU)
    if (( CURRENT % 100 == 0 )); then
        progress_bar "$CURRENT" "$TOTAL_LINES"
        sleep 0.01   # Petite pause pour éviter 100% CPU
    fi

done < "$INPUT_FILE"

# Barre finale 100%
progress_bar "$TOTAL_LINES" "$TOTAL_LINES"

sort -u -o "$IPV4_FILE" "$IPV4_FILE"
#sort -u -o "$IPV6_FILE" "$IPV6_FILE"
sort -u -o "$IPV4_SUBNET_FILE" "$IPV4_SUBNET_FILE"
#sort -u -o "$IPV6_SUBNET_FILE" "$IPV6_SUBNET_FILE"



IPV4_COUNT=$(wc -l < "$IPV4_FILE")
#IPV6_COUNT=$(wc -l < "$IPV6_FILE")
IPV4_SUBNET_COUNT=$(wc -l < "$IPV4_SUBNET_FILE")
#IPV6_SUBNET_COUNT=$(wc -l < "$IPV6_SUBNET_FILE")

echo "--------------------------------------"
echo " Summary :"
echo "--------------------------------------"
echo "IPv4 simples   : $IPV4_COUNT"
echo "IPv4 subnet    : $IPV4_SUBNET_COUNT"
#echo "IPv6 simples        : $IPV6_COUNT"
#echo "IPv6 avec subnet    : $IPV6_SUBNET_COUNT"
echo "--------------------------------------"
echo "Finish."


#Calculate execution time
end_time=$(date +%s)
duration=$((end_time - start_time))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
printf "Time execute : %02d:%02d:%02d\n" $hours $minutes $seconds
echo "IPbandit stop"
