#!/bin/bash

# ==========================================
# IPbandit
# ==========================================


BASEDIR=$(readlink -f $0 | xargs dirname)


show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Available Options :"
    echo "  --fail2ban     Start the recovery of banned ips by fail2ban"
    echo "  --aggregator   Aggregate all banned lists"
    echo "  -h, --help     Print this help"
    echo ""
    echo "Exemples :"
    echo "  $0 --fail2ban"
    echo "  $0 --aggregator"
    echo "  $0 --fail2ban --aggregator"
}

run_script() {
    local script_name="$1"
    local script_path="$BASEDIR/extras/$script_name"

    echo "IPbandit START"

    if [[ -x "$script_path" ]]; then
        echo "Exécution $script_name..."
        "$script_path"
    else
        echo "Error : $script_path not found or not executable"
        exit 1
    fi

    echo "IPbandit STOP"
}



# Si aucun argument
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

# Boucle sur tous les arguments
for arg in "$@"; do
    case "$arg" in
        --fail2ban)
            run_script "fail2ban.sh"
            ;;
        --aggregator)
            run_script "aggregator.sh"
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option : $arg"
            echo ""
            show_help
            exit 1
            ;;
    esac
done
