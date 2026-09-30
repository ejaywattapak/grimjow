#!/bin/bash
GitUser="ejaywattapak"
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi
echo ""
version=$(cat /home/ver)
ver=$( curl https://raw.githubusercontent.com/${GitUser}/version/main/version.conf )
clear
# LINE COLOUR
line=$(cat /etc/line)
# TEXT COLOUR BELOW
below=$(cat /etc/below)
# BACKGROUND TEXT COLOUR
back_text=$(cat /etc/back)
# NUMBER COLOUR
number=$(cat /etc/number)
# TEXT ON BOX COLOUR
box=$(cat /etc/box)
# CEK UPDATE
Green_font_prefix="\e[38;5;252m" && Red_font_prefix="\e[38;5;220m" && Green_background_prefix="\e[48;5;236m\e[97m" && Red_background_prefix="\e[48;5;236m\e[97m" && Font_color_suffix="\e[0m"
Info1="${Green_font_prefix}($version)${Font_color_suffix}"
Info2="${Green_font_prefix}(LATEST VERSION)${Font_color_suffix}"
Error="Version ${Green_font_prefix}[$ver]${Font_color_suffix} available${Red_font_prefix}[Please Update]${Font_color_suffix}"
version=$(cat /home/ver)
new_version=$( curl https://raw.githubusercontent.com/${GitUser}/version/main/version.conf | grep $version )
#Status Version
if [ $version = $new_version ]; then
sts="${Info2}"
else
sts="${Error}"
fi
clear
echo ""
echo -e "   \e[$line--------------------------------------------------------\e[m"
echo -e "   \e[$back_text                 \e[30m[\e[$box CHECK NEW UPDATE\e[30m ]                   \e[m"
echo -e "   \e[$line--------------------------------------------------------\e[m"
echo -e "   \e[$below VERSION NOW >> $Info1"
echo -e "   \e[$below STATUS UPDATE >> $sts"
echo -e ""
echo -e "       \e[1;97mWould you like to proceed?\e[0m"
echo ""
echo -e "            \e[1;38;5;214m[ Select Option ]\e[0m"
echo -e "     \e[$number [1]\e[m \e[$below Check Script Update Now\e[m"
echo -e "     \e[$number [x]\e[m \e[$below Back To Update Menu\e[m"
echo -e "     \e[$number [y]\e[m \e[$below Back To Main Menu\e[m"
echo -e ""
echo -e "   \e[$line--------------------------------------------------------\e[m"
echo -e "\e[$line"
read -p "Please Choose 1 or x & y : " option2
case $option2 in
1)
version=$(cat /home/ver)
new_version=$( curl https://raw.githubusercontent.com/${GitUser}/version/main/version.conf | grep $version )
if [ $version = $new_version ]; then
clear
echo ""
echo -e "\e[38;5;252mChecking New Version, Please Wait...!\e[0m"
sleep 3
clear
echo -e "\e[1;38;5;220mUpdate Not Available\e[m"
echo ""
clear
sleep 1
echo -e "\e[1;38;5;117mYou Have The Latest Version\e[m"
echo -e "\e[1;38;5;220mThankyou.\e[0m"
sleep 2
update
fi
clear
echo -e "\e[1;38;5;220mUpdate Available Now..\e[m"
echo -e ""
sleep 2
echo -e "\e[1;38;5;117mStart Update For New Version, Please Wait..\e[m"
sleep 2
clear
echo -e "\e[38;5;252mGetting New Version Script..\e[0m"
sleep 1
echo ""
# UPDATE RUN-UPDATE
cd /usr/bin
wget -O run-update "https://raw.githubusercontent.com/${GitUser}/grimjow/main/update/run-update.sh"
chmod +x run-update
# RUN UPDATE
echo ""
clear
echo -e "\e[38;5;252mPlease Wait...!\e[0m"
sleep 6
clear
echo ""
echo -e "\e[38;5;252mNew Version Downloading started!\e[0m"
sleep 2
cd /usr/bin
wget -O update "https://raw.githubusercontent.com/${GitUser}/grimjow/main/update/update.sh"
wget -O run-update "https://raw.githubusercontent.com/${GitUser}/grimjow/main/update/run-update.sh"
wget -O message-ssh "https://raw.githubusercontent.com/${GitUser}/grimjow/main/update/message-ssh.sh"
wget -O change-port "https://raw.githubusercontent.com/${GitUser}/grimjow/main/change.sh"
wget -O system "https://raw.githubusercontent.com/${GitUser}/grimjow/main/menu/system.sh"
wget -O menu "https://raw.githubusercontent.com/${GitUser}/grimjow/main/menu.sh"
wget -O add-host "https://raw.githubusercontent.com/${GitUser}/grimjow/main/system/add-host.sh"
wget -O check-sc "https://raw.githubusercontent.com/${GitUser}/grimjow/main/system/running.sh"
wget -O cert "https://raw.githubusercontent.com/${GitUser}/grimjow/main/cert.sh"
wget -O trojaan "https://raw.githubusercontent.com/${GitUser}/grimjow/main/menu/trojaan.sh"
wget -O xraay "https://raw.githubusercontent.com/${GitUser}/grimjow/main/menu/xraay.sh"
wget -O xp "https://raw.githubusercontent.com/${GitUser}/grimjow/main/xp.sh"
wget -O port-xray "https://raw.githubusercontent.com/${GitUser}/grimjow/main/change-port/port-xray.sh"
wget -O themes "https://raw.githubusercontent.com/${GitUser}/grimjow/main/menu/themes.sh"
wget -O autobackup "https://raw.githubusercontent.com/${GitUser}/grimjow/main/system/autobackup.sh"
wget -O backup "https://raw.githubusercontent.com/${GitUser}/grimjow/main/system/backup.sh"
wget -O bckp "https://raw.githubusercontent.com/${GitUser}/grimjow/main/system/bckp.sh"
wget -O restore "https://raw.githubusercontent.com/${GitUser}/grimjow/main/system/restore.sh"
chmod +x update
chmod +x run-update
chmod +x message-ssh
chmod +x change-port
chmod +x system
chmod +x menu
chmod +x add-host
chmod +x check-sc
chmod +x cert
chmod +x trojaan
chmod +x xraay
chmod +x xp
chmod +x port-xray
chmod +x themes
chmod +x autobackup
chmod +x backup
chmod +x bckp
chmod +x restore
clear
echo -e ""
echo -e "\e[38;5;252mDownloaded successfully!\e[0m"
echo ""
ver=$( curl https://raw.githubusercontent.com/${GitUser}/version/main/version.conf )
sleep 1
echo -e "\e[38;5;252mPatching New Update, Please Wait...\e[0m"
echo ""
sleep 2
echo -e "\e[38;5;252mPatching... OK!\e[0m"
sleep 1
echo ""
echo -e "\e[38;5;252mSucces Update Script For New Version\e[0m"
cd
echo "$ver" > /home/ver
rm -f update.sh
clear
echo ""
echo -e "\e[38;5;117m----------------------------------------\e[0m"
echo -e "\e[48;5;236m            SCRIPT UPDATED              \e[0m"
echo -e "\e[38;5;117m----------------------------------------\e[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
;;
x)
clear
update
;;
y)
clear
menu
;;
*)
clear
echo -e "\e[1;38;5;220mPlease Enter Option 1-2 or x & y Only..,Try again, Thank You..\e[0m"
sleep 2
run-update
;;
esac
