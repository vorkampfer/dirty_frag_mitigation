#!/usr/bin/env bash


function ctrl_c(){
    echo -e "\n\n${redColour}[+] Exiting the function...${endColour}\n"
    exit 1
}


# Ctrl+C
trap ctrl_c SIGINT

# Colors
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
whiteColour="\e[0;97m\033[1m"

function show_help(){
    local script_name
    script_name="$(basename "$0")"

    echo "Usage: $script_name [OPTIONS]"
    echo
    echo "Mitigate dirty frag by creating /etc/modprobe.d/dirtyfrag.conf"
    echo
    echo "Options:"
    echo "  -h, --help       Show this help menu"
    echo "  -r, --rollback   Remove /etc/modprobe.d/dirtyfrag.conf"
    echo
    echo "Examples:"
    echo "  sudo ./$script_name"
    echo "  sudo ./$script_name --rollback"
    echo "  ./$script_name --help"
}

action="apply"

case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    -r|--rollback)
        action="rollback"
        ;;
    "")
        ;;
    *)
        echo -e "${redColour}[-] Invalid option: $1${endColour}"
        echo
        show_help
        exit 1
        ;;
esac


if [ "$(id -u)" -ne 0 ]; then
    echo -e "${redColour}[-] Please run this script as root.${endColour}"
    exit 1
fi

if [ "$action" = "rollback" ]; then
    if [ -f /etc/modprobe.d/dirtyfrag.conf ]; then
        echo -e "${redColour}[!] Warning: rolling back changes. This will make you vulnerable again.${endColour}"
        rm -f /etc/modprobe.d/dirtyfrag.conf
        wait
        echo -e "${greenColour}[+] Changes rolled back successfully.${endColour}"
    else
        echo -e "${yellowColour}[*] Nothing to roll back. dirtyfrag.conf was not found.${endColour}"
    fi
    exit 0
fi

if [ -f /etc/modprobe.d/dirtyfrag.conf ]; then
    echo -e "${yellowColour}[*] dirtyfrag.conf already exists, skipping creation.${endColour}"
    exit 0
fi

cat <<-EOF > /etc/modprobe.d/dirtyfrag.conf
install esp4 /bin/false
install esp6 /bin/false
install rxrpc /bin/false
EOF
wait
echo 3 > /proc/sys/vm/drop_caches
wait
echo -e "${greenColour}[+] dirtyfrag.conf created successfully.${endColour}"
cat /etc/modprobe.d/dirtyfrag.conf