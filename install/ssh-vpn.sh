#!/bin/bash

GitUser="ejaywattapak"
# ===== REBORN v2: fail tempatan (folder zip) diutamakan; GitHub hanya fallback =====
getf() {
  local rel="$1" dest="$2"
  if [ -n "$EJWATT_SRC" ] && [ -f "$EJWATT_SRC/$rel" ]; then
    cp -f "$EJWATT_SRC/$rel" "$dest" && return 0
  fi
  wget -q --timeout=30 --tries=3 -O "$dest" "https://raw.githubusercontent.com/${GitUser}/grimjow/main/$rel"
}


# // initializing var
export DEBIAN_FRONTEND=noninteractive
MYIP=$(wget -qO- icanhazip.com);
MYIP=$(curl -s ipinfo.io/ip )
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -sS ifconfig.me )
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

# // detail nama perusahaan
country="MY"
state="Kuala_Lumpur"
locality="Kuala_Lumpur"
organization="@ejaywattapak"
organizationalunit="@ejaywattapak"
commonname="ejaywattapak"
email="admin@ejaywattapak.com"

# // simple password minimal
getf "password" /etc/pam.d/common-password
chmod +x /etc/pam.d/common-password

# // go to root
cd

# // Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# // nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# // Ubah izin akses
chmod +x /etc/rc.local

# // enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# // disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# // update
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y

# // install wget and curl
apt -y install wget curl

# // install netstat
apt install net-tools -y

# // install dos2unix
apt install -y dos2unix

# // install iftop & htop
apt install iftop -y
apt install htop -y

# install git
apt install git -y

apt install irqbalance -y
systemctl enable --now irqbalance

# // set time GMT +8
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime

# // set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# // install
apt-get --reinstall --fix-missing install -y bzip2 gzip coreutils wget screen rsyslog iftop htop net-tools zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch git lsof
echo "clear" >> .profile
echo "menu" >> .profile

# // install webserver
apt -y install nginx
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/${GitUser}/grimjow/main/nginx.conf"
mkdir -p /home/vps/public_html
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/${GitUser}/grimjow/main/vps.conf"
/etc/init.d/nginx restart

# // install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/${GitUser}/grimjow/main/badvpn-udpgw64"
chmod +x /usr/bin/badvpn-udpgw
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500' /etc/rc.local
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 500

# // setting port ssh
cd
apt-get -y update
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g'

# /etc/ssh/sshd_config
sed -i '/Port 22/a Port 500' /etc/ssh/sshd_config
#sed -i '/Port 22/a Port 40000' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 51443' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 58080' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 200' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null || /etc/init.d/ssh restart 2>/dev/null || true

# install dropbear
apt update -y
apt install -y dropbear

# tulis ulang konfigurasi dropbear
cat > /etc/default/dropbear <<'EOF'
NO_START=0
DROPBEAR_PORT=143
DROPBEAR_EXTRA_ARGS="-p 109"
DROPBEAR_BANNER="/etc/issue.net"
EOF

# pastikan shell dibatasi untuk user tertentu (jika diperlukan)
grep -qxF "/bin/false" /etc/shells || echo "/bin/false" >> /etc/shells
grep -qxF "/usr/sbin/nologin" /etc/shells || echo "/usr/sbin/nologin" >> /etc/shells

# Systemd Dropbear Service
tee /etc/systemd/system/dropbear.service > /dev/null <<'EOF'
[Unit]
Description=Lightweight SSH server
Documentation=man:dropbear(8)
After=network.target

[Service]
Environment=DROPBEAR_PORT=22 DROPBEAR_RECEIVE_WINDOW=65536
EnvironmentFile=-/etc/default/dropbear

# Clear previous ExecStart and set new one that includes banner
ExecStart=/usr/sbin/dropbear -EF -p "$DROPBEAR_PORT" -W "$DROPBEAR_RECEIVE_WINDOW" -b "$DROPBEAR_BANNER" $DROPBEAR_EXTRA_ARGS

KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# ===== REBORN v2: jana dropbear host keys awal (elak service gagal) =====
mkdir -p /etc/dropbear
[ -f /etc/dropbear/dropbear_rsa_host_key ]     || dropbearkey -t rsa -s 4096 -f /etc/dropbear/dropbear_rsa_host_key >/dev/null 2>&1 || true
[ -f /etc/dropbear/dropbear_ecdsa_host_key ]   || dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key >/dev/null 2>&1 || true
[ -f /etc/dropbear/dropbear_ed25519_host_key ] || dropbearkey -t ed25519 -f /etc/dropbear/dropbear_ed25519_host_key >/dev/null 2>&1 || true
[ -f /etc/dropbear/dropbear_dss_host_key ]     || dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key >/dev/null 2>&1 || true

# enable & restart dropbear
systemctl enable dropbear
systemctl restart dropbear

# // install squid (REBORN v2: squid3 dah tiada pada OS baharu)
apt -y install squid3 >/dev/null 2>&1 || apt -y install squid
getf "squid3.conf" /etc/squid/squid.conf
sed -i $MYIP2 /etc/squid/squid.conf

# // setting vnstat
apt -y install vnstat
/etc/init.d/vnstat restart
apt -y install libsqlite3-dev
wget https://github.com/ejaywattapak/addons/releases/download/vnstat-2.6/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install
cd
vnstat -u -i $NET
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
rm -f /root/vnstat-2.6.tar.gz
rm -rf /root/vnstat-2.6

# Ws-Ovpn EnvironmentFile
tee /etc/default/ws-ovpn > /dev/null <<'EOF'
# PORT for ws-ovpn
WS_OVPN_PORT="2097"
# Extra args (optional)
WS_OVPN_OPTS=""
EOF

# // install stunnel
apt install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
pid = /var/run/stunnel4/stunnel.pid
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 222
connect = 127.0.0.1:22

[dropbear]
accept = 777
connect = 127.0.0.1:109

[openvpn]
accept = 442
connect = 127.0.0.1:1194

[ws-stunnel]
accept = 2096
connect = 127.0.0.1:2091
END

groupadd stunnel
useradd -r -g stunnel -s /usr/sbin/nologin stunnel

mkdir -p /var/run/stunnel4
chown stunnel:stunnel /var/run/stunnel4

# // make a certificate
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# // konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/lib/systemd/systemd-sysv-install enable stunnel4
systemctl start stunnel4
/etc/init.d/stunnel4 restart

# // OpenVPN
wget https://raw.githubusercontent.com/${GitUser}/grimjow/main/vpn.sh &&  chmod +x vpn.sh && ./vpn.sh

# // install lolcat
wget https://raw.githubusercontent.com/${GitUser}/grimjow/main/lolcat.sh &&  chmod +x lolcat.sh && ./lolcat.sh

# // install fail2ban
apt -y install fail2ban

# // Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'

# // banner /etc/issue.net
wget -O /etc/issue.net "https://raw.githubusercontent.com/${GitUser}/grimjow/main/banner/bannerssh.conf"
echo "Banner /etc/issue.net" >>/etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER="/etc/issue.net"@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear

# // Bannerku menu
wget -O /usr/bin/bannerku https://raw.githubusercontent.com/${GitUser}/grimjow/main/banner/bannerku && chmod +x /usr/bin/bannerku

# // install bbr
wget https://raw.githubusercontent.com/${GitUser}/grimjow/main/system/bbr.sh && chmod +x bbr.sh && ./bbr.sh

# // blockir torrent
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# // download script
#cd /usr/local/sbin
#getf "quota-xray/xray-quota.sh" "xray-quota.sh"
#getf "quota-xray/menu-quota-vmess.sh" "menu-quota-vmess.sh"
#chmod +x xray-quota.sh
#chmod +x menu-quota-vmess.sh
#sed -i 's/\r$//' /usr/local/sbin/xray-quota.sh
#sed -i 's/\r$//' /usr/local/sbin/menu-quota-vmess.sh
#xray-quota.sh

# // download script
cd /usr/bin
#getf "menu/quota-vless.sh" "quota-vless"
getf "system/proxy-warp.sh" "proxy-warp"
getf "system/change-dropbear.sh" "change-dropbear"
getf "system/menu-noobzvpn.sh" "menu-noobzvpn"
getf "system/add-host.sh" "add-host"
getf "system/about.sh" "about"
getf "menu.sh" "menu"
getf "add-user/add-ssh.sh" "add-ssh"
getf "add-user/trial.sh" "trial"
getf "delete-user/del-ssh.sh" "del-ssh"
getf "member.sh" "member"
getf "delete-user/delete.sh" "delete"
getf "cek-user/cek-ssh.sh" "cek-ssh"
getf "cek-user/cek-xray.sh" "cek-xray"
getf "system/restart.sh" "restart"
getf "system/speedtest_cli.py" "speedtest"
getf "system/info.sh" "info"
getf "system/ip6menu.sh" "ip6menu"
getf "system/ram.sh" "ram"
getf "renew-user/renew-ssh.sh" "renew-ssh"
getf "autokill.sh" "autokill"
getf "cek-user/ceklim.sh" "ceklim"
getf "tendang.sh" "tendang"
getf "clear-log.sh" "clear-log"
getf "change.sh" "change-port"
getf "change-port/port-ovpn.sh" "port-ovpn"
getf "change-port/port-ssl.sh" "port-ssl"
getf "change-port/port-squid.sh" "port-squid"
getf "change-port/port-websocket.sh" "port-websocket"
getf "webmin.sh" "wbmn"
getf "xp.sh" "xp"
getf "xp.sh" "xp2"
getf "kernel.sh" "kernel-updt"
getf "more-option/user-list.sh" "user-list"
getf "more-option/user-lock.sh" "user-lock"
getf "more-option/user-unlock.sh" "user-unlock"
getf "more-option/user-password.sh" "user-password"
getf "more-option/antitorrent.sh" "antitorrent"
getf "cloud/cfa.sh" "cfa"
getf "cloud/cfd.sh" "cfd"
getf "cloud/cfp.sh" "cfp"
getf "swapkvm.sh" "swap"
getf "system/running.sh" "check-sc"
getf "system/bbr-manager.sh" "bbr-manager"
getf "menu/ssh2.sh" "ssh2"
getf "system/autoreboot.sh" "autoreboot"
getf "system/bbr.sh" "bbr"
getf "change-port/port-ohp.sh" "port-ohp"
getf "change-port/port-xray.sh" "port-xray"
getf "menu/panel-domain.sh" "panel-domain"
getf "menu/system.sh" "system"
getf "menu/themes.sh" "themes"
getf "update/update.sh" "update"
getf "update/run-update.sh" "run-update"
getf "update/message-ssh.sh" "message-ssh"
getf "system/dns.sh" "dns"
getf "system/netf.sh" "netf"
chmod +x add-host
chmod +x menu
chmod +x add-ssh
chmod +x trial
chmod +x del-ssh
chmod +x member
chmod +x delete
chmod +x cek-ssh
chmod +x restart
chmod +x speedtest
chmod +x info
chmod +x about
chmod +x autokill
chmod +x tendang
chmod +x ceklim
chmod +x ram
chmod +x renew-ssh
chmod +x clear-log
chmod +x change-port
[ -f restore ] && chmod +x restore || true
chmod +x port-ovpn
chmod +x port-ssl
chmod +x port-squid
chmod +x port-websocket
chmod +x wbmn
chmod +x xp
chmod +x xp2
chmod +x kernel-updt
chmod +x user-list
chmod +x user-lock
chmod +x user-unlock
chmod +x user-password
chmod +x antitorrent
chmod +x cfa
chmod +x cfd
chmod +x cfp
chmod +x swap
chmod +x check-sc
chmod +x ssh2
chmod +x autoreboot
chmod +x bbr
chmod +x port-ohp
chmod +x port-xray
chmod +x panel-domain
chmod +x system
chmod +x themes
chmod +x update
chmod +x run-update
chmod +x message-ssh
chmod +x dns
chmod +x ip6menu
chmod +x netf
chmod +x bbr-manager
chmod +x menu-noobzvpn
chmod +x change-dropbear
chmod +x proxy-warp
chmod +x cek-xray
#chmod +x quota-vless
#sed -i 's/\r$//' /usr/bin/quota-vless
sed -i 's/\r$//' /usr/bin/proxy-warp
sed -i 's/\r$//' /usr/bin/menu-noobzvpn
sed -i 's/\r$//' /usr/bin/change-dropbear
# REBORN v2: install-figlet lama dibuang (figlet + font dipasang dalam setup.sh)
sed -i 's/\r$//' /usr/bin/cek-xray
#quota-vless
[ -x /usr/bin/install-figlet ] && install-figlet || true
echo "0 1 * * * root delete" >> /etc/crontab
echo "0 2 * * * root xp" >> /etc/crontab
echo "0 5 * * * root reboot" >> /etc/crontab
echo "0 14 * * * root backup" >> /etc/crontab
echo "0 23 * * * root clear-log" >> /etc/crontab
echo "0 5 * * * root clear-log" >> /etc/crontab
echo "0 12 * * * root clear-log" >> /etc/crontab
echo "0 18 * * * root clear-log" >> /etc/crontab
echo "0 1 * * * root backup" >> /etc/crontab
echo "0 3 * * * root /usr/bin/xp" >> /etc/crontab
echo "0 4 * * * root /usr/bin/delete" >> /etc/crontab
echo "0 9 * * * root /usr/bin/clear-log" >> /etc/crontab
#echo "10 23 * * * root /usr/bin/backup" >> /etc/crontab

# // remove unnecessary files
cd
apt autoclean -y
apt -y remove --purge unscd
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove bind9*;
apt-get -y remove sendmail*
apt autoremove -y

# // finishing
cd
chown -R www-data:www-data /home/vps/public_html
systemctl restart nginx
systemctl restart openvpn
systemctl restart cron
systemctl restart ssh
systemctl restart dropbear
systemctl restart fail2ban
systemctl restart vnstat
systemctl restart stunnel4
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 500
history -c
echo "unset HISTFILE" >> /etc/profile

cd
rm -f /root/key.pem
rm -f /root/cert.pem
rm -f /root/ssh-vpn.sh
clear
