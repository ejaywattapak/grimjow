#!/bin/bash

RED="\e[38;5;220m"
YELLOW="\e[1;38;5;220m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"

REPO="https://raw.githubusercontent.com/ejaywattapak/grimjow/main/setup.sh"

clear
printf '%b\n' "${YELLOW}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
printf '%b\n' "${YELLOW}${BOLD}║             AUTOSCRIPT BY EJAYWATTAPAK                ║${RESET}"
printf '%b\n' "${YELLOW}${BOLD}╠════════════════════════════════════════════════════════╣${RESET}"
printf '%b\n' "${YELLOW}${BOLD}║                 XRAY / SSH WEBSOCKET                  ║${RESET}"
printf '%b\n' "${YELLOW}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
printf '\n'

# Remove the obsolete Ookla packagecloud repository before any apt update.
sed -i '/packagecloud\.io\/ookla\/speedtest-cli/d' /etc/apt/sources.list 2>/dev/null || true
for f in /etc/apt/sources.list.d/*; do
    [ -f "$f" ] || continue
    grep -q 'packagecloud\.io/ookla/speedtest-cli' "$f" 2>/dev/null || continue
    rm -f "$f"
done

# Refresh package lists first, then restore coreutils in case an older
# installation overwrote /usr/bin/test with banner-font text.
apt-get update -y && \
apt-get install --reinstall -y coreutils && \
apt-get upgrade -y && \
apt-get dist-upgrade -y && \
apt-get update -y && \
apt-get install -y bzip2 gzip coreutils screen wget curl && \
wget -O setup.sh "$REPO" && \
chmod +x setup.sh && \
sed -i -e 's/\r$//' setup.sh && \
./setup.sh

status=$?
echo
if [ "$status" -ne 0 ]; then
    echo -e "${RED}${BOLD}Installer gagal menjalankan setup.sh (exit code: $status).${RESET}"
    exit "$status"
fi

echo -e "${YELLOW}${BOLD}setup.sh telah dijalankan.${RESET}"
exit 0
