#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"

clear

# ============================================================
# Yellow double-line header — 58 columns, aligned
# ============================================================
echo -e "${YELLOW}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo -e "${YELLOW}${BOLD}║             AUTOSCRIPT BY EJAYWATTAPAK                ║${RESET}"
echo -e "${YELLOW}${BOLD}╠════════════════════════════════════════════════════════╣${RESET}"
echo -e "${YELLOW}${BOLD}║                 XRAY / SSH WEBSOCKET.                 ║${RESET}"
echo -e "${YELLOW}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo

# Auto install setup.sh — no option/menu.
    apt update -y && \
    apt upgrade -y && \
    apt dist-upgrade -y && \
    apt update && \
    apt install -y bzip2 gzip coreutils screen wget curl && \
    wget https://raw.githubusercontent.com/ejaywattapak/grimjow/main/setup.sh && \
    chmod +x setup.sh && \
    sed -i -e 's/\r$//' setup.sh && \
    screen -S setup ./setup.sh

 then
    echo
    echo -e "${RED}${BOLD}Installer gagal menjalankan setup.sh (exit code: ${exit_code}).${RESET}"
    exit "$exit_code"
fi

exit 0
