#!/bin/bash
# =========================================
# IPv4 + IPv6 Toggle
# Date: 2025-12-11
# Author: NevermoreSSH
# =========================================
# Warna
line="1;38;5;220"         # Oyen terang
GREEN="\e[38;5;220m" # hijau
WHITE="\e[1;97m"
PINK="\e[38;5;214m" # Pink terang
back_text="48;5;236"  # Putih + biru gelap
box="1;38;5;214"           # Putih bold
# ============================
# COLOR THEME PREMIUM
# ============================
text="1;97"          # Putih bold (info text)
title="\e[48;5;236m\e[1;38;5;214m"   # 30 = hitam, 107 = background putih
number="\e[1;38;5;117"        # Kuning gold (untuk nombor menu)
below="38;5;252"         # Putih lembut
reset="\e[0m"

# Detect IPv4
IPV4=$(hostname -I | awk '{print $1}')

# Detect IPv6 global (skip link-local fe80::)
IPV6=$(ip -6 addr show scope global | grep inet6 | awk '{print $2}' | head -n1)
[ -z "$IPV6" ] && IPV6="Not assigned"

# Detect IPv6 link-local
IPV6_LL=$(ip -6 addr show scope link | grep inet6 | awk '{print $2}' | head -n1)

# Cek status IPv6 kernel
STATUS_IPV6=$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)
[ "$STATUS_IPV6" -eq 0 ] && IPV6_STATUS="Enabled" || IPV6_STATUS="Disabled"
clear
echo ""
echo -e "\e[${line}m═══════════════════════════════════════════════${reset}"
echo -e "\e[${title}        [ IP Menu - IPv4 / IPv6 Toggle ]       ${reset}"
echo -e "\e[${line}m═══════════════════════════════════════════════${reset}
\e[1;97mIPv4v6 Changer By ejaywattapak\e[0m
\e[1;97mTelegram : https://t.me/ejaywattapak \e[0m"
echo ""

echo -e " IPv4 Address      : \e[38;5;220m$IPV4${reset}"
echo -e " IPv6 Link-Local   : \e[1;38;5;117m$IPV6_LL${reset}"
echo -e " IPv6 Global       : \e[1;38;5;117m$IPV6${reset}"
echo -e " IPv6 Status       : \e[1;38;5;220m$IPV6_STATUS${reset}"
echo ""

echo -e " [\e[1;38;5;117m•1\e[0m]  \e[${below}mIPv4 Only (Disable IPv6)${reset}"
echo -e " [\e[1;38;5;117m•2\e[0m]  \e[${below}mIPv4 + IPv6 (Enable IPv6)${reset}"
echo -e " [\e[1;38;5;117m•3\e[0m]  \e[${below}mReboot Server${reset}"
echo ""
echo -e " [\e[1;38;5;117m•0\e[0m]  \e[${below}mBack To Menu${reset}"
echo "
 Notes: 
 - Please restart / reboot server after change IPv4v6."
echo ""
echo -e "\e[38;5;252mPress [ Ctrl+C ] • To Exit Script${reset}"
echo ""
echo -e "\e[${below}m"

read -p " Select menu : " opt
echo -e ""

case $opt in
1)
    clear
    echo "Disabling IPv6..."
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1
    echo "IPv6 telah dimatikan. Hanya IPv4 aktif."
    sleep 2
    exec ip6menu
    ;;
3)
    clear
    reboot
    ;;
2)
    clear
    echo "Enabling IPv6..."
    sysctl -w net.ipv6.conf.all.disable_ipv6=0
    sysctl -w net.ipv6.conf.default.disable_ipv6=0
    echo -e ""
    echo "IPv6 telah diaktifkan. IPv4 + IPv6 aktif."
	read -n 1 -s -r -p "Press any key to reboot"
	reboot
    ;;
0|x)
    clear
    exec menu
    ;;
*)
    echo "Wrong Button"
    sleep 1
    exec ip6menu
    ;;
esac
