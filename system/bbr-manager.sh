#!/bin/bash

# =========================================
# BBR Manager + Optimizer
# Date: 2025-12-11
# Original Author: NevermoreSSH + GPT
# (C) Copyright 2025 - 2026
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
number="\e[1;38;5;117m"        # Kuning gold (untuk nombor menu)
below="38;5;252"         # Putih lembut
reset="\e[0m"

# Colors
RED='\e[38;5;220m'
GREEN='\e[38;5;252m'
YELLOW='\e[1;38;5;220m'
BLUE='\e[38;5;117m'
NC='\e[0m' # No Color

# Add line if not exists
Add_Line_If_Not_Exist(){
    if [ "$(tail -n1 $1 | wc -l)" == "0" ]; then
        echo "" >> "$1"
    fi
    echo "$2" >> "$1"
}

# Check and add line if missing
Check_And_Add_Line(){
    if [ -z "$(grep -Fx "$2" "$1")" ]; then
        Add_Line_If_Not_Exist "$1" "$2"
    fi
}

# Check BBR status
check_status() {
    cc=$(sysctl -n net.ipv4.tcp_congestion_control)
    if [[ "$cc" == "bbr" ]]; then
        echo -e "${BLUE}Current congestion control: ${YELLOW}$cc${NC} (${GREEN}BBR ON${NC})"
    else
        echo -e "${BLUE}Current congestion control: ${YELLOW}$cc${NC} (${RED}BBR OFF${NC})"
    fi
}

# Enable BBR
enable_bbr() {
    echo -e "${GREEN}Enabling BBR...${NC}"
    modprobe tcp_bbr
    Add_Line_If_Not_Exist "/etc/modules-load.d/modules.conf" "tcp_bbr"
    sed -i '/net.ipv4.tcp_congestion_control\s*=\s*cubic/d' /etc/sysctl.conf
    Add_Line_If_Not_Exist "/etc/sysctl.conf" "net.core.default_qdisc = fq"
    Add_Line_If_Not_Exist "/etc/sysctl.conf" "net.ipv4.tcp_congestion_control = bbr"
    sysctl -p
    if lsmod | grep -q tcp_bbr && sysctl net.ipv4.tcp_congestion_control | grep -q bbr; then
        echo -e "${GREEN}BBR successfully enabled!${NC}"
    else
        echo -e "${RED}Failed to enable BBR!${NC}"
    fi
    check_status
}

# Disable BBR (switch to cubic)
disable_bbr() {
    echo -e "${RED}Disabling BBR (switching to cubic)...${NC}"
    sed -i '/net.ipv4.tcp_congestion_control\s*=\s*bbr/d' /etc/sysctl.conf
    sysctl -w net.ipv4.tcp_congestion_control=cubic
    sysctl -p
    echo -e "${RED}BBR is now disabled, using cubic.${NC}"
    check_status
}

# Optimize system parameters
optimize_parameters() {
    echo -e "${BLUE}Optimizing system parameters...${NC}"
    Check_And_Add_Line "/etc/security/limits.conf" "* soft nofile 51200"
    Check_And_Add_Line "/etc/security/limits.conf" "* hard nofile 51200"
    Check_And_Add_Line "/etc/security/limits.conf" "root soft nofile 51200"
    Check_And_Add_Line "/etc/security/limits.conf" "root hard nofile 51200"
    Check_And_Add_Line "/etc/sysctl.conf" "fs.file-max = 51200"
    Check_And_Add_Line "/etc/sysctl.conf" "net.core.rmem_max = 67108864"
    Check_And_Add_Line "/etc/sysctl.conf" "net.core.wmem_max = 67108864"
    Check_And_Add_Line "/etc/sysctl.conf" "net.core.netdev_max_backlog = 250000"
    Check_And_Add_Line "/etc/sysctl.conf" "net.core.somaxconn = 4096"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_syncookies = 1"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_tw_reuse = 1"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_fin_timeout = 30"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_keepalive_time = 1200"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.ip_local_port_range = 10000 65000"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_max_syn_backlog = 8192"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_max_tw_buckets = 5000"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_fastopen = 3"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_mem = 25600 51200 102400"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_rmem = 4096 87380 67108864"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_wmem = 4096 65536 67108864"
    Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_mtu_probing = 1"
    sysctl -p
    echo -e "${GREEN}System optimization completed.${NC}"
}

# Interactive menu
while true; do
    clear
    echo -e "\e[${line}m═══════════════════════════════════════════${reset}"
    echo -e "\e[${title}       [ BBR Manager + Optimizer ]         ${reset}"
    echo -e "\e[${line}m═══════════════════════════════════════════${reset}
\e[1;97mBBR Manager By ejaywattapak\e[0m
\e[1;97mTelegram : https://t.me/ejaywattapak \e[0m"
	echo -e " "
    check_status
	echo -e " "
    echo -e "\e[1;38;5;220mSelect an option:\e[0m"
    echo -e "\e[1;38;5;117m1)\e[0m \e[38;5;252mEnable BBR\e[0m"
    echo -e "\e[1;38;5;117m2)\e[0m \e[38;5;252mDisable BBR\e[0m"
    echo -e "\e[1;38;5;117m3)\e[0m \e[38;5;252mOptimize system parameters\e[0m"
    echo -e "\e[1;38;5;117m4)\e[0m \e[38;5;252mCheck BBR status\e[0m"
	echo -e " "
    echo -e "\e[1;38;5;117m0)\e[0m \e[38;5;252mBack to menu\e[0m"
    read -p "Enter choice [0-4]: " choice

    case $choice in
        1) enable_bbr ;;
        2) disable_bbr ;;
        3) optimize_parameters ;;
        4) check_status ;;
        0) menu ;;
		x) menu-tweak ;;
        *) echo -e "${RED}Invalid choice!${NC}" ; sleep 1 ;;
    esac
    read -p "Press Enter to return to menu..."
done
