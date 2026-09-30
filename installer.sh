#!/bin/bash

RED="\e[31m"
YELLOW="\e[1;33m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"

REPO="https://raw.githubusercontent.com/ejaywattapak/grimjow/main/setup.sh"

clear
echo -e "${YELLOW}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${YELLOW}${BOLD}║                 AUTOSCRIPT BY EJAYWATTAPAK                 ║${RESET}"
echo -e "${YELLOW}${BOLD}╠════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${YELLOW}${BOLD}║                   AUTO INSTALL SETUP.SH                    ║${RESET}"
echo -e "${YELLOW}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
echo

apt update -y && \
apt upgrade -y && \
apt dist-upgrade -y && \
apt update && \
apt install -y bzip2 gzip coreutils screen wget curl && \
wget -O setup.sh "$REPO" && \
chmod +x setup.sh && \
sed -i -e 's/\r$//' setup.sh && \
./setup.sh

status=$?

if [ "$status" -ne 0 ]; then
    echo
    echo -e "${RED}${BOLD}Installer gagal menjalankan setup.sh (exit code: $status).${RESET}"
    exit "$status"
fi

echo
echo -e "${YELLOW}${BOLD}setup.sh telah dijalankan.${RESET}"
exit 0
