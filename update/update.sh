#!/bin/bash

#wget https://github.com/${GitUser}/
GitUser="ejaywattapak"
#IZIN SCRIPT
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -s ipinfo.io/ip )
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -sS ifconfig.me )
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
RED='\e[1;38;5;220m'
GREEN='\e[38;5;252m'
BLUE='\e[38;5;117m'
NC='\e[0m'
version=$(cat /home/ver)
ver=$( curl https://raw.githubusercontent.com/${GitUser}/version/main/version.conf )
clear
# CEK UPDATE
Green_font_prefix="\e[38;5;252m" && Red_font_prefix="\e[38;5;220m" && Green_background_prefix="\e[48;5;236m\e[97m" && Red_background_prefix="\e[48;5;236m\e[97m" && Font_color_suffix="\e[0m"
Info1="${Green_font_prefix}[$version]${Font_color_suffix}"
Info2="${Green_font_prefix}[LATEST VERSION]${Font_color_suffix}"
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

# Echo Shell
echo ""
echo ""
echo -e "   \e[$line--------------------------------------------------------\e[m"
echo -e "   \e[$back_text                 \e[30m[\e[$box UPDATE SCRIPT MENU\e[30m ]                 \e[m"
echo -e "   \e[$line--------------------------------------------------------\e[m"
echo -e "   \e[$below VERSION NOW >> $Info1"
echo -e "   \e[$below STATUS UPDATE >> $sts"
echo -e ""
echo -e "     \e[$number 1.\e[m \e[$below Change Banner SSH\e[m"
echo -e "     \e[$number 2.\e[m \e[$below Check Update/New Version Script\e[m"
echo -e ""
echo -e "   \e[$line--------------------------------------------------------\e[m"
echo -e "   \e[$back_text \e[$box x)   MENU                                             \e[m"
echo -e "   \e[$line--------------------------------------------------------\e[m"
echo -e "\e[$line"
read -p "     Select From Options [1-3 or x] :  " port
echo -e ""
case $port in
1)
message-ssh
;;
2)
run-update
;;
x)
clear
menu
;;
*)
clear
echo -e "\e[1;38;5;220mPlease enter an correct number, Try again.\e[0m"
sleep 2
update
;;
esac
