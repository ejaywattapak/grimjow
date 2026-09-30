#!/bin/bash

GitUser="ejaywattapak"
#IZIN SCRIPT
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -s ipinfo.io/ip )
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -sS ifconfig.me )
clear
# Status Version
Green_font_prefix="\e[38;5;252m" && Red_font_prefix="\e[38;5;220m" && Green_background_prefix="\e[48;5;236m\e[97m" && Red_background_prefix="\e[48;5;236m\e[97m" && Font_color_suffix="\e[0m"
InfoD="Default Version ${Green_font_prefix}[ON]${Font_color_suffix}"
Info1="Version 1 ${Green_font_prefix}[ON]${Font_color_suffix}"
Info2="Version 2 ${Green_font_prefix}[ON]${Font_color_suffix}"
Info3="Version 3 ${Green_font_prefix}[ON]${Font_color_suffix}"
Info4="Version 4 ${Green_font_prefix}[ON]${Font_color_suffix}"
Info5="Custom Version ${Green_font_prefix}[ON]${Font_color_suffix}"
Error="Banner SSH ${Red_font_prefix}[OFF]${Font_color_suffix}"
cek=$(cat /home/bannerssh)
function defaultv () {
rm -f /etc/issue.net
wget -O /etc/issue.net https://raw.githubusercontent.com/${GitUser}/grimjow/main/banner/bannerssh.conf && chmod +x /etc/issue.net
echo "0.1" > /home/bannerssh
clear
echo -e "Succesfully Use Default Version."
echo -e "\e[38;5;252mDone\e[0m"
echo -e " \e[1;38;5;220mReboot 3 Sec\e[0m"
sleep 3
reboot
}
function server_message_ssh1 () {
rm -f /etc/issue.net
wget -O /etc/issue.net https://raw.githubusercontent.com/${GitUser}/grimjow/main/banner/bannerssh.conf && chmod +x /etc/issue.net
echo "1" > /home/bannerssh
clear
echo -e "Succesfully Change Server Message Version 1 For SSH."
echo -e "\e[38;5;252mDone\e[0m"
echo -e " \e[1;38;5;220mReboot 3 Sec\e[0m"
sleep 3
reboot
}
function server_message_ssh2 () {
rm -f /etc/issue.net
wget -O /etc/issue.net https://raw.githubusercontent.com/${GitUser}/grimjow/main/banner/bannerssh.conf && chmod +x /etc/issue.net
echo "2" > /home/bannerssh
clear
echo -e "Succesfully Change Server Message Version 2 For SSH."
echo -e "\e[38;5;252mDone\e[0m"
echo -e " \e[1;38;5;220mReboot 3 Sec\e[0m"
sleep 3
reboot
}
function server_message_ssh3 () {
rm -f /etc/issue.net
wget -O /etc/issue.net https://raw.githubusercontent.com/${GitUser}/grimjow/main/banner/bannerssh.conf && chmod +x /etc/issue.net
echo "3" > /home/bannerssh
clear
echo -e "Succesfully Change Server Message Version 3 For SSH."
echo -e "\e[38;5;252mDone\e[0m"
echo -e " \e[1;38;5;220mReboot 3 Sec\e[0m"
sleep 3
reboot
}
function server_message_ssh4 () {
rm -f /etc/issue.net
wget -O /etc/issue.net https://raw.githubusercontent.com/${GitUser}/grimjow/main/banner/bannerssh.conf && chmod +x /etc/issue.net
echo "4" > /home/bannerssh
clear
echo -e "Succesfully Change Server Message Version 4 For SSH."
echo -e "\e[38;5;252mDone\e[0m"
echo -e " \e[1;38;5;220mReboot 3 Sec\e[0m"
sleep 3
reboot
}
function server_message_ssh5 () {
echo "5" > /home/bannerssh
nano /etc/issue.net
echo -e "Succesfully Customize Server Message For SSH."
echo -e "\e[38;5;252mDone\e[0m"
echo -e " \e[1;38;5;220mReboot 3 Sec\e[0m"
sleep 3
reboot
}
function stop () {
rm -f /etc/issue.net
sleep 0.5
echo > /home/bannerssh
echo -e "Server Message SSH has been successfully Turn Off."
echo -e "\e[38;5;252mDone\e[0m"
echo -e " \e[1;38;5;220mReboot 3 Sec\e[0m"
sleep 3
reboot
}

#Status Server Message
if [[ "$cek" = "0.1" ]]; then
sts="${InfoD}"
elif [[ "$cek" = "1" ]]; then
sts="${Info1}"
elif [[ "$cek" = "2" ]]; then
sts="${Info2}"
elif [[ "$cek" = "3" ]]; then
sts="${Info3}"
elif [[ "$cek" = "4" ]]; then
sts="${Info4}"
elif [[ "$cek" = "5" ]]; then
sts="${Info5}"
else
sts="${Error}"
fi
clear
echo ""
figlet " BANNER  SSH" | lolcat
echo -e "  ${BLUE}.---------------------------------------------------------. ${NC}" | lolcat
echo -e "  |              BANNER/SERVER MESSAGE FOR SSH              |" | lolcat
echo -e "  ${BLUE}'---------------------------------------------------------' ${NC}" | lolcat
echo -e "    \e[1;97mSTATUS BANNER\e[38;5;252m(USED) \e[1;97m:\e[0m $sts"
echo -e ""
echo -e "      \e[1;38;5;117m1.\e[0m \e[38;5;252mSet Default Banner\e[0m"
echo -e "      \e[1;38;5;117m2.\e[0m \e[38;5;252mSet Banner Version 1\e[0m"
echo -e "      \e[1;38;5;117m3.\e[0m \e[38;5;252mSet Banner Version 2\e[0m"
echo -e "      \e[1;38;5;117m4.\e[0m \e[38;5;252mSet Banner Version 3\e[0m"
echo -e "      \e[1;38;5;117m5.\e[0m \e[38;5;252mSet Banner Version 4\e[0m"
echo -e "      \e[1;38;5;117m6.\e[0m \e[38;5;252mEdit Banner SSH\e[0m"
echo -e "      \e[1;38;5;117m7.\e[0m \e[38;5;252mTurn Off Banner SSH\e[0m"
echo -e ""
echo -e "   ${BLUE}--------------------------------------------------------- ${NC}" | lolcat
echo -e "      \e[1;38;5;117mx.\e[0m \e[38;5;252mBack To Update Script Menu\e[0m"
echo -e "      \e[1;38;5;117my.\e[0m \e[38;5;252mBack To Main Menu\e[0m"
echo -e ""
read -rp "  Please Enter 1-7 or x & y : " -e num
if [[ "$num" = "1" ]]; then
defaultv
elif [[ "$num" = "2" ]]; then
server_message_ssh1
elif [[ "$num" = "3" ]]; then
server_message_ssh2
elif [[ "$num" = "4" ]]; then
server_message_ssh3
elif [[ "$num" = "5" ]]; then
server_message_ssh4
elif [[ "$num" = "6" ]]; then
server_message_ssh5
elif [[ "$num" = "8" ]]; then
stop
elif [[ "$num" = "x" ]]; then
update
elif [[ "$num" = "y" ]]; then
menu
else
clear
echo -e "\e[1;38;5;220mYou Entered The Wrong Number, Please Try Again!\e[0m"
sleep 2
message-ssh
fi
