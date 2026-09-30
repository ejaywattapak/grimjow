#!/bin/bash

# Warna untuk teks
RED='\e[38;5;220m'
GREEN='\e[38;5;252m'
YELLOW='\e[1;38;5;220m'
BLUE='\e[38;5;117m'
PURPLE='\e[38;5;214m'
CYAN='\e[38;5;117m'
NC='\e[0m' # Tiada warna (reset)

print_user_table() {
    local user="$1"
    local expiry="$2"
    local left="$3"
    printf "\n${YELLOW}%-18s %-12s %-9s${NC}\n" "USERNAME" "EXPIRY" "LEFT"
    printf '%s\n' "---------------------------------------------"
    printf "%-18s %-12s %-9s\n" "$user" "$expiry" "$left"
    printf '\n'
}

CONFIG_FILE="/etc/noobzvpns/config.toml"

edit_config() {
    echo -e "\e[1;97mMenu Edit Config /etc/noobzvpns/config.toml\e[0m"
    echo -e "\e[1;38;5;117m1.\e[0m \e[38;5;252mEdit identifier\e[0m"
    echo -e "\e[1;38;5;117m2.\e[0m \e[38;5;252mBuka config file location\e[0m"
    echo -e "\e[1;38;5;117m0.\e[0m \e[38;5;252mKembali ke menu utama\e[0m"
    read -p "Pilih nombor: " choice

    case $choice in
        1)
            current_id=$(sed -n 's/^identifier = "\(.*\)"/\1/p' "$CONFIG_FILE")
            echo -e "${YELLOW}Identifier sekarang:${NC} $current_id"
            read -p "Masukkan identifier baru: " new_id
            if [[ -z "$new_id" ]]; then
                echo -e "${RED}Identifier tidak boleh kosong.${NC}"
            else
                sed -i "s/^identifier = \".*\"/identifier = \"$new_id\"/" "$CONFIG_FILE"
                echo -e "${GREEN}Identifier telah dikemaskini ke $new_id${NC}"
            fi
            ;;
        2)
            echo -e "${CYAN}Buka config file location${NC}"
            sudo nano "$CONFIG_FILE"
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}Pilihan tidak sah!${NC}"
            ;;
    esac
    read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali..."
}

while true; do
    clear
    echo -e "\e[1;38;5;220m==================================\e[0m"
    echo -e "\e[48;5;236m\e[1;38;5;214m           NOOBZVPN MENU            \e[0m"
    echo -e "\e[1;38;5;220m==================================\e[0m"
    echo -e "\e[1;38;5;117m1.\e[0m  \e[38;5;252mAdd User\e[0m"
    echo -e "\e[1;38;5;117m2.\e[0m  \e[38;5;252mEdit User\e[0m"
    echo -e "\e[1;38;5;117m3.\e[0m  \e[38;5;252mRename User\e[0m"
    echo -e "\e[1;38;5;117m4.\e[0m  \e[38;5;252mBlock User\e[0m"
    echo -e "\e[1;38;5;117m5.\e[0m  \e[38;5;252mUnblock User\e[0m"
    echo -e "\e[1;38;5;117m6.\e[0m  \e[38;5;252mRenew User\e[0m"
    echo -e "\e[1;38;5;117m7.\e[0m  \e[38;5;252mReset User\e[0m"
    echo -e "\e[1;38;5;117m8.\e[0m  \e[38;5;252mRemove User\e[0m"
    echo -e "\e[1;38;5;117m9.\e[0m  \e[38;5;252mShow User\e[0m"
    echo -e "${GREEN}10.${NC} Show All Users"
    echo -e "${GREEN}11.${NC} OPTS (Advanced Dangerous Ops)"
    echo -e "${GREEN}12.${NC} Developer/Test Mode"
    echo -e "${GREEN}13.${NC} Start Service"
    echo -e "${GREEN}14.${NC} Restart Service"
    echo -e "${GREEN}15.${NC} Stop Service"
    echo -e "${GREEN}16.${NC} Enable Auto Start Service"
    echo -e "${GREEN}17.${NC} Disable Auto Start Service"
    echo -e "${GREEN}18.${NC} Check Service Status"
    echo -e "${GREEN}19.${NC} Change identifier or open config file"
    echo -e "\e[1;38;5;117m0.\e[0m  \e[38;5;252mExit\e[0m"
    echo -e "\e[1;38;5;220m==================================\e[0m"
    read -p "Sila pilih menu: " opt

    case $opt in
        1)
            read -p "Masukkan USERNAME: " username
            read -s -p "Masukkan PASSWORD: " password
            echo
            read -p "Expired days (kosong/skip untuk default): " exp
            read -p "Bandwidth GB (kosong/skip untuk default): " bw
            read -p "Device Limit (kosong/skip untuk default): " dev

            cmd="noobzvpns add $username -p $password"
            [[ ! -z "$exp" ]] && cmd="$cmd -e $exp"
            [[ ! -z "$bw" ]] && cmd="$cmd -b $bw"
            [[ ! -z "$dev" ]] && cmd="$cmd -d $dev"

            echo -e "${CYAN}Command: $cmd${NC}"
            eval $cmd

            user="$username"
            if [[ -n "$exp" ]]; then
                expiry=$(date -d "+$exp days" +"%Y-%m-%d")
                left="${exp} days"
            else
                expiry="(never)"
                left="-"
            fi

            print_user_table "$user" "$expiry" "$left"
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        2)
            read -p "USERNAME yang hendak diedit: " username
            read -s -p "Password baru (tinggal kosong untuk tak ubah): " password
            echo
            read -p "Expired days (kosong/skip untuk default): " exp
            read -p "Bandwidth GB (kosong/skip untuk default): " bw
            read -p "Device Limit (kosong/skip untuk default): " dev

            cmd="noobzvpns edit $username"
            [[ ! -z "$password" ]] && cmd="$cmd -p $password"
            [[ ! -z "$exp" ]] && cmd="$cmd -e $exp"
            [[ ! -z "$bw" ]] && cmd="$cmd -b $bw"
            [[ ! -z "$dev" ]] && cmd="$cmd -d $dev"

            echo -e "${CYAN}Command: $cmd${NC}"
            eval $cmd
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        3)
            read -p "USERNAME asal: " username
            read -p "USERNAME baru: " newusername
            cmd="noobzvpns rename $username $newusername"
            echo -e "${CYAN}Command: $cmd${NC}"
            eval $cmd
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        4)
            read -p "USERNAME (boleh multiple, ruang): " users
            cmd="noobzvpns block $users"
            echo -e "${CYAN}Command: $cmd${NC}"
            eval $cmd
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        5)
            read -p "USERNAME (boleh multiple, ruang): " users
            cmd="noobzvpns unblock $users"
            echo -e "${CYAN}Command: $cmd${NC}"
            eval $cmd
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        6)
            read -p "USERNAME (boleh multiple, ruang): " users
            read -p "Masukkan bilangan hari untuk set expired selepas renew (contoh: 30): " days
            if [[ -z "$days" ]]; then
                echo -e "${RED}Bilangan hari tidak dibenarkan kosong!${NC}"
            else
                for user in $users; do
                    echo -e "${GREEN}Renewing user: $user${NC}"
                    noobzvpns renew "$user"
                    cmd="noobzvpns edit $user -e $days"
                    echo -e "${CYAN}Command: $cmd${NC}"
                    eval $cmd
                done
            fi
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        7)
            read -p "USERNAME (boleh multiple, ruang): " users
            cmd="noobzvpns reset $users"
            echo -e "${CYAN}Command: $cmd${NC}"
            eval $cmd
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        8)
            read -p "USERNAME (boleh multiple, ruang): " users
            cmd="noobzvpns remove $users"
            echo -e "${CYAN}Command: $cmd${NC}"
            eval $cmd
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        9)
            read -p "USERNAME (boleh multiple, ruang): " users
            cmd="noobzvpns print $users"
            echo -e "${CYAN}Command: $cmd${NC}"
            eval $cmd
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        10)
            cmd="noobzvpns print-all"
            echo -e "${CYAN}Command: $cmd${NC}"
            eval $cmd
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        11)
            echo -e "\e[1;38;5;117m1.\e[0m \e[38;5;252mRenew All User\e[0m"
            echo -e "\e[1;38;5;117m2.\e[0m \e[38;5;252mReset All Statistic\e[0m"
            echo -e "\e[1;38;5;117m3.\e[0m \e[38;5;252mRemove All User\e[0m"
            read -p "Pilih (1/2/3): " adv
            case $adv in
                1) eval "noobzvpns opts --renew-all" ;;
                2) eval "noobzvpns opts --reset-all" ;;
                3) eval "noobzvpns opts --delete-all" ;;
            esac
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        12)
            echo -e "${CYAN}Developer/Test Mode: Running in foreground with debug${NC}"
            eval "noobzvpns -d start-server"
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        13)
            echo -e "${GREEN}Starting noobzvpns.service...${NC}"
            systemctl start noobzvpns.service
            echo -e "${GREEN}Service started.${NC}"
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        14)
            echo -e "${GREEN}Restarting noobzvpns.service...${NC}"
            systemctl restart noobzvpns.service
            echo -e "${GREEN}Service restarted.${NC}"
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        15)
            echo -e "${RED}Stopping noobzvpns.service...${NC}"
            systemctl stop noobzvpns.service
            echo -e "${RED}Service stopped.${NC}"
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        16)
            echo -e "${GREEN}Enabling auto-start for noobzvpns.service...${NC}"
            systemctl enable noobzvpns.service
            echo -e "${GREEN}Auto-start enabled.${NC}"
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        17)
            echo -e "${RED}Disabling auto-start for noobzvpns.service...${NC}"
            systemctl disable noobzvpns.service
            echo -e "${RED}Auto-start disabled.${NC}"
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        18)
            echo -e "${CYAN}Checking noobzvpns.service status...${NC}"
            systemctl status noobzvpns.service -l
            read -n 1 -s -r -p "Tekan sebarang kekunci untuk kembali ke menu..."
            ;;
        19)
            edit_config
            ;;
        0)
            echo -e "${YELLOW}Terima Kasih...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak sah! Sila cuba lagi.${NC}"
            sleep 1
            ;;
    esac
done