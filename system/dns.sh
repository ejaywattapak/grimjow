#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Auther  : ejaywattapak
# (C) Copyright 2022
# =========================================
P='\e[38;5;214m'
B='\e[38;5;117m'
G='\e[38;5;252m'
NC='\e[0m'
N='\e[0m'
clear
echo -e "\e[1;38;5;220m╒════════════════════════════════════════════╕\e[0m"
echo -e " \e[48;5;236m\e[1;38;5;214m                 DNS CHANGER                \e[0m"
echo -e "\e[1;38;5;220m╘════════════════════════════════════════════╛\e[0m
\e[1;97mDNS Changer By ejaywattapak\e[0m
\e[1;97mTelegram : https://t.me/ejaywattapak \e[0m"
dnsfile="/root/dns"
if test -f "$dnsfile"; then
udns=$(cat /root/dns)
echo -e ""
echo -e "   Active DNS : \e[38;5;252m$udns\e[0m"
fi
echo -e "
 [\e[1;38;5;117m•1 \e[0m]  Temporary DNS
 [\e[1;38;5;117m•2 \e[0m]  Permanent DNS
 [\e[1;38;5;117m•3 \e[0m]  Reset DNS To Default
 [\e[1;38;5;117m•4 \e[0m]  Update resolv.conf Latest
 [\e[1;38;5;117m•5 \e[0m]  Back To Main Menu"
echo ""
echo -e "\e[38;5;252mPress [ Ctrl+C ] • To-Exit-Script\e[0m"
echo ""
read -p "Select From Options [ 1 - 5 ] :  " dns
echo -e ""
case $dns in
1)
clear
echo -e "\e[1;97mTemporary DNS - Back To Default DNS After Rebooting VPS\e[0m"
echo ""
read -p "Please Insert DNS : " dns1
if [ -z $dns1 ]; then
echo ""
echo "Please Insert DNS !"
sleep 1
clear
dns
fi
rm /etc/resolv.conf
touch /etc/resolv.conf
echo "$dns1" > /root/dns
echo "nameserver $dns1" >> /etc/resolv.conf
systemctl restart resolvconf.service
echo ""
echo -e "\e[38;5;252mDNS $dns1 sucessfully insert in VPS\e[0m"
echo ""
cat /etc/resolv.conf
sleep 1
clear
dns
;;
2)
clear
echo ""
read -p "Please Insert DNS : " dns2
if [ -z $dns2 ]; then
echo ""
echo "Please Insert DNS !"
sleep 1
clear
dns
fi
rm /etc/resolv.conf
rm /etc/resolvconf/resolv.conf.d/head
touch /etc/resolv.conf
touch /etc/resolvconf/resolv.conf.d/head
echo "$dns2" > /root/dns
echo "nameserver $dns2" >> /etc/resolv.conf
echo "nameserver $dns2" >> /etc/resolvconf/resolv.conf.d/head
systemctl restart resolvconf.service
echo ""
echo -e "\e[38;5;252mDNS $dns2 sucessfully insert in VPS\e[0m"
echo ""
cat /etc/resolvconf/resolv.conf.d/head
sleep 1
clear
dns
;;
3)
clear
echo ""
read -p "Reset To Default DNS [Y/N]: " -e answer
if [ "$answer" = 'y' ] || [ "$answer" = 'Y' ]; then
rm /root/dns
echo ""
echo -e "[ ${G}INFO${NC} ] Delete Resolv.conf DNS"
echo "nameserver 8.8.8.8" > /etc/resolv.conf
sleep 1
echo -e "[ ${G}INFO${NC} ] Delete Resolv.conf.d/head DNS"
echo "nameserver 8.8.8.8" > /etc/resolvconf/resolv.conf.d/head
sleep 1
else if [ "$answer" = 'n' ] || [ "$answer" = 'N' ]; then
echo -e ""
echo -e "[ ${G}INFO${NC} ] Operation Cancelled By User"
sleep 1
fi
fi
clear
dns
;;
4)
clear
apt install resolvconf
;;
5)
clear
menu
;;
*)
echo "Please enter an correct number"
clear
dns
;;
esac
