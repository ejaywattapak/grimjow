#!/bin/bash
GitUser="ejaywattapak"
#IZIN SCRIPT
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -s ipinfo.io/ip )
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -sS ifconfig.me )
clear
wsstunnel="$(cat ~/log-install.txt | grep -w "SSL(HTTPS)" | cut -d: -f2|sed 's/ //g')"
ssl="$(cat /etc/stunnel/stunnel.conf | grep -i accept | head -n 2 | cut -d= -f2 | sed 's/ //g' | tr '\n' ' ' | awk '{print $1}')"
ssl2="$(cat /etc/stunnel/stunnel.conf | grep -i accept | head -n 2 | cut -d= -f2 | sed 's/ //g' | tr '\n' ' ' | awk '{print $2}')"
echo -e "\e[1;38;5;220m.-----------------------------------------.\e[0m"
echo -e "\e[1;38;5;220m|         \e[1;38;5;214mCHANGE PORT STUNNEL/SSL\e[m         \e[1;38;5;220m|\e[0m"
echo -e "\e[1;38;5;220m'-----------------------------------------'\e[0m"
echo -e " \e[1;38;5;117m>>\e[0m\e[38;5;252mChange Port For Stunnel4/SSL:\e[0m"
echo -e "     \e[1;38;5;117m[1]\e[0m  \e[38;5;252mChange Port $ssl\e[0m"
echo -e "     \e[1;38;5;117m[2]\e[0m  \e[38;5;252mChange Port $ssl2\e[0m"
echo -e "\e[1;38;5;220m======================================\e[0m"
echo -e "     \e[1;38;5;117m[x]\e[0m  \e[38;5;252mBack To Menu Change Port\e[0m"
echo -e "     \e[1;38;5;117m[y]\e[0m  \e[38;5;252mGo To Main Menu\e[0m"
echo -e ""
read -p "     Select From Options [1-2 or x & y] :  " prot
echo -e ""
case $prot in
1)
read -p "New Port Stunnel4: " stl
if [ -z $stl ]; then
echo "Please Input Port"
exit 0
fi
cek=$(netstat -nutlp | grep -w $stl)
if [[ -z $cek ]]; then
sed -i "s/$ssl/$stl/g" /etc/stunnel/stunnel.conf
sed -i "s/   - Stunnel4                : $ssl, $ssl2/   - Stunnel4                : $stl, $ssl2/g" /root/log-install.txt
sed -i "s/   - Websocket SSL(HTTPS)    : $ssl/   - Websocket SSL(HTTPS)    : $stl/g" /root/log-install.txt
/etc/init.d/stunnel4 restart > /dev/null
echo -e "\e[38;5;252mPort $stl modified successfully\e[0m"
else
echo -e "\e[1;38;5;220mPort $stl is used\e[0m"
fi
;;
2)
read -p "New Port Stunnel4: " stl
if [ -z $stl ]; then
echo "Please Input Port"
exit 0
fi
cek=$(netstat -nutlp | grep -w $stl)
if [[ -z $cek ]]; then
sed -i "s/$ssl2/$stl/g" /etc/stunnel/stunnel.conf
sed -i "s/   - Stunnel4                : $ssl, $ssl2/   - Stunnel4                : $ssl, $stl/g" /root/log-install.txt
/etc/init.d/stunnel4 restart > /dev/null
echo -e "\e[38;5;252mPort $stl modified successfully\e[0m"
else
echo -e "\e[1;38;5;220mPort $stl is used\e[0m"
fi
;;
x)
clear
change-port
;;
y)
clear
menu
;;
*)
echo "Please enter an correct number"
;;
esac
