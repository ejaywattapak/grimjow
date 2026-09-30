#!/bin/bash
GitUser="ejaywattapak"
#IZIN SCRIPT
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -s ipinfo.io/ip )
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -sS ifconfig.me )
clear
rm -r /root/mail.conf
clear
cd /root
read -e -p " Masukan Domain :$domain" domain
read -e -p " Masukan Email Cloudflare :" email
read -e -p " Masukan Api Key :" key
echo -e "domain=$domain" >> /root/mail.conf
echo -e "email=$email" >> /root/mail.conf
echo -e "key=$key" >> /root/mail.conf
echo -e "### $domain $email" >> /root/mail.conf
clear
echo -e "\e[38;5;252mDONE\e[0m"
echo -e "\e[38;5;220mYour ID Cloudflare\e[0m"
echo -e "\e[1;38;5;117m===============================\e[0m"
echo -e "\e[38;5;117mDOMAIN         :\e[0m $domain"
echo -e "\e[38;5;117mEmail          :\e[0m $email"
echo -e "\e[38;5;117mApi Key        :\e[0m $key"
echo -e "\e[1;38;5;117m===============================\e[0m"
echo -e "\e[38;5;252mNow you can use & add subdomain.\e[0m"
echo -e "\e[38;5;252mGo to main menu and chosee Add Subdomain to you ID Cloudflare or Pointing IP\e[0m"
echo -e "\e[38;5;252mto you ID Cloudflare\e[0m"
