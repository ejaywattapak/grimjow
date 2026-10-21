#!/bin/bash
# // wget https://github.com/${GitUser}/
GitUser="ejaywattapak"

# ===== FIX: guna fail TEMPATAN kalau ada (tak bergantung GitHub) =====
_SRC=""
for _c in "$(dirname "$0")/.." /root/grimjow-main /root/grimjow; do
  [ -f "$_c/menu/xraay.sh" ] && { _SRC="$(cd "$_c" && pwd)"; break; }
done
getf() {
  local rel="$1" dest="$2"
  if [ -n "$EJWATT_SRC" ] && [ -f "$EJWATT_SRC/$rel" ]; then cp -f "$EJWATT_SRC/$rel" "$dest" && return 0; fi
  if [ -n "$_SRC" ] && [ -f "$_SRC/$rel" ]; then cp -f "$_SRC/$rel" "$dest" && return 0; fi
  wget -q --timeout=30 --tries=3 -O "$dest" "https://raw.githubusercontent.com/${GitUser}/grimjow/main/$rel"
}

# // MY IPVPS
export MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -s ipinfo.io/ip )
MYIP=$(curl -sS ipv4.icanhazip.com)
MYIP=$(curl -sS ifconfig.me )

# // install socat
export DEBIAN_FRONTEND=noninteractive
apt-get install -y socat

# // EMAIL & DOMAIN
export emailcf=$(cat /usr/local/etc/xray/email)
export domain=$(cat /root/domain)

apt install iptables iptables-persistent -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
# ===== FIX: ntpdate dah DIBUANG dari Debian 13 ("no installation candidate").
# ===== Guna chrony sahaja (dipasang di bawah).
DEBIAN_FRONTEND=noninteractive apt-get install -y socat cron bash-completion >/dev/null 2>&1 || true
apt -y install chrony
mkdir -p /var/log/chrony  # REBORN v3: elak warning statoverride / log dir tak wujud
timedatectl set-ntp true
systemctl enable chronyd >/dev/null 2>&1; systemctl restart chronyd >/dev/null 2>&1 || true
systemctl enable chrony  >/dev/null 2>&1; systemctl restart chrony  >/dev/null 2>&1 || true
timedatectl set-timezone Asia/Kuala_Lumpur
# sync masa segera (ganti ntpdate)
chronyc makestep >/dev/null 2>&1 || true
chronyc sourcestats -v
chronyc tracking -v
date

# // MAKE FILE TROJAN TCP
mkdir -p /etc/xray
mkdir -p /usr/local/etc/xray/
mkdir -p /var/log/xray/
touch /usr/local/etc/xray/akunxtr.conf
touch /var/log/xray/access.log
touch /var/log/xray/error.log
# ===== FIX: xray jalan sebagai www-data. Dulu fail log dicipta sebagai root
# ===== -> xray mati: "failed to initialize access logger > permission denied"
chown -R www-data:www-data /var/log/xray
chmod 750 /var/log/xray
chmod 600 /var/log/xray/access.log /var/log/xray/error.log

# ===== FIX: systemd cipta/chown /var/log/xray automatik SETIAP start
mkdir -p /etc/systemd/system/xray@.service.d
printf '[Service]\nLogsDirectory=xray\nLogsDirectoryMode=0750\n' \
  > /etc/systemd/system/xray@.service.d/50-ejwatt-logs.conf

# // VERSION XRAY
export version="$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"

# // INSTALL CORE XRAY (LATEST)
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data

systemctl stop nginx >/dev/null 2>&1 || true

# // INSTALL CERTIFICATES
mkdir -p /root/.acme.sh
getf "acme.sh" /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
# ===== FIX: acme.sh upgrade selamat (elak "Text file busy" & ralat "@") =====
if [ -x /root/.acme.sh/acme.sh ]; then
  /root/.acme.sh/acme.sh --upgrade --auto-upgrade >/dev/null 2>&1 || true
fi
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
if [ -f /usr/local/etc/xray/xray.crt ] && [ -f /usr/local/etc/xray/xray.key ]; then
  echo "[ins-xray] cert dah wujud - langkau acme issue"
elif [ -z "$domain" ]; then
  echo "[ins-xray] AMARAN: domain kosong - langkau acme issue"
else
  _V6=""
  [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null)" = "0" ] && _V6="--listen-v6"
  /root/.acme.sh/acme.sh --issue -d "$domain" -d "sshws.$domain" --standalone -k ec-256 $_V6 \
    || echo "[ins-xray] AMARAN: acme issue gagal - cert sedia ada dikekalkan"
fi
if [ -n "$domain" ]; then
  /root/.acme.sh/acme.sh --installcert -d "$domain" -d "sshws.$domain" \
    --fullchainpath /usr/local/etc/xray/xray.crt \
    --keypath /usr/local/etc/xray/xray.key --ecc \
    || echo "[ins-xray] AMARAN: installcert gagal"
else
  echo "[ins-xray] AMARAN: domain kosong - langkau installcert"
fi
chmod 755 /usr/local/etc/xray/xray.key;
service squid start >/dev/null 2>&1 || true
systemctl restart nginx >/dev/null 2>&1 || true
sleep 0.5;
clear;

# // UUID PATH
export uuid=$(cat /proc/sys/kernel/random/uuid)
export uuid1=$(cat /proc/sys/kernel/random/uuid)
export uuid2=$(cat /proc/sys/kernel/random/uuid)
export uuid3=$(cat /proc/sys/kernel/random/uuid)
export uuid4=$(cat /proc/sys/kernel/random/uuid)
export uuid5=$(cat /proc/sys/kernel/random/uuid)
export uuid6=$(cat /proc/sys/kernel/random/uuid)
export uuid7=$(cat /proc/sys/kernel/random/uuid)
export uuid8=$(cat /proc/sys/kernel/random/uuid)

# // JSON WS & TCP XTLS
cat > /usr/local/etc/xray/config.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
    "inbounds": [
        {
      "listen": "127.0.0.1",
      "port": 10085, # CEK USER QUOTA
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
            },
            {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "85454939-cd36-40f4-b9a5-1cc80bc557a7",
            "flow": "xtls-rprx-vision",
            "level": 0
#xray-vless-xtls-rprx-vision
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "name": "sshws.rnd.nil07.shop", # // SSHWS TLS
            "dest": 2091,
            "xver": 1
          },
          {
            "dest": 1211, # // TROJAN TCP TLS
            "xver": 1
          },
          {
            "path": "/vless", # // VLESS WS TLS
            "dest": 1212,
            "xver": 1
          },
          {
            "path": "/httpupgrade", # // HTTPUPGRADE TLS
            "dest": 1213,
            "xver": 1
          },
          {
            "path": "/vmess", # // VMESS WS TLS
            "dest": 1214,
            "xver": 1
          },
          {
            "path": "/trojanwstls", # // TROJAN WS TLS
            "dest": 1215,
            "xver": 1            
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "alpn": ["http/1.1"],
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/xray.crt",
              "keyFile": "/usr/local/etc/xray/xray.key"
            }
          ],
          "minVersion": "1.2"
        }
      }
    },
    {
      "port": 1211,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "7c374438-44ee-466c-929c-bf9e05915573"
#trojan
          }
        ],
        "fallbacks": [
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none",
        "tcpSettings": {
          "acceptProxyProtocol": true
        }
      }
    },
    {
      "port": 1212,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "53918212-d760-4622-ae19-25b7466d9523",
            "level": 0
#xray-vless-tls
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/vless"
        }
      }
    },
    {
      "port": 1214,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "037eb604-389b-4516-8b91-cc02556b1a81",
            "alterId": 0,
            "level": 0
#xray-vmess-tls
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/vmess"
        }
      }
    },
    {
      "port": 1215,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "304a78b4-9956-4775-8b2b-b2433863b122"
#xray-trojan-tls
          }
        ],
        "udp": true
      },
      "streamSettings":{
        "network": "ws",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/trojanwstls"
        }
      }
    },
    {
      "port": 1213,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "53918212-d760-4622-ae19-25b7466d9523",
            "level": 0
#httpupgrade-tls
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "httpupgrade",
        "security": "none",
        "httpupgradeSettings": {
          "acceptProxyProtocol": true,
          "path": "/httpupgrade"
        }
      }
    },
    {
      "port": 8443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "53918212-d760-4622-ae19-25b7466d9523"
#xray-vless-xhttp-tls 
          }           
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "tls",
        "tlsSettings": {
          "alpn": [ "h2", "http/1.1" ],
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/xray.crt",
              "keyFile": "/usr/local/etc/xray/xray.key"
            }
          ],
          "minVersion": "1.2"
        },
        "xhttpSettings": {
        "path": "/xhttp",
        "headers": {},
        "mode": "auto",
        "noSSEHeader": false,
        "scMaxEachPostBytes": "500000-1000000",
        "scMinPostsIntervalMs": "10-50",
        "scMaxBufferedPosts": 30
       }
      }
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "user": [
          "regexp:^blocked-"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "inboundTag": ["api"],
        "outboundTag": "api"
      },
      {
        "type": "field",
        "protocol": ["bittorrent"],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },

      /* ===== DOMAIN WARP (MUDAH BUANG) ===== */
      {
        "type": "field",
        "domain": [
          "domain:example.net"
        ],
        "outboundTag": "direct"
      }
    ]
  },

  "stats": {},

  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },

  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true
    }
  },

  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "direct"
    },
    {
      "protocol": "socks",
      "tag": "warp",
      "settings": {
        "servers": [
          {
            "address": "127.0.0.1",
            "port": 40000
          }
        ]
      }
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    },
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "api"
    }
  ]
}
END

# // JSON WS NONE
cat > /usr/local/etc/xray/none.json << END
{
  "log" : {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
    "inbounds": [
        {
      "listen": "127.0.0.1",
      "port": 10086, # CEK USER QUOTA
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
            },
            {
      "port": 80,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "0eb24801-661a-4cd6-8505-a20087d4de5f"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 1301, # // VLESS NONE
            "xver": 1
          },
          {
            "path": "/httpupgrade", # // HTTPUPGRADE NONE
            "dest": 1302,
            "xver": 1			
          },
          {
            "path": "/vmess", # // VMESS NONE
            "dest": 1303,
            "xver": 1
          },
          {
             "path": "/trojanwsntls", # // TROJAN NONE
            "dest": 1304,
            "xver": 1
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none",
        "tlsSettings": {
          "alpn": ["http/1.1"]
        }
      }
    },
    {
      "port": "1301",
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "decryption":"none",
        "clients": [
          {
            "id": "a539d4bf-77bb-4f2d-8525-ae2eb63614d2"
#xray-vless-nontls
          }
        ]
      },
      "streamSettings":{
        "network": "ws",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/"
        }
      }
    },
    {
      "port": "1303",
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "44378ff7-a1c0-4484-91c1-0f10b1563aed",
            "alterId": 0
#xray-vmess-nontls
          }
        ]
      },
      "streamSettings":{
        "network": "ws",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/vmess"
        }
      }
    },
    {
      "port": "1304",
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "settings": {
        "decryption":"none",
        "clients": [
          {
            "password": "5be18eb2-3035-4e4d-9c21-807152af7dd9"
#xray-trojan-nontls
          }
        ],
        "udp": true
      },
      "streamSettings":{
        "network": "ws",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/trojanwsntls"
        }
      }
    },
    {
      "port": 1302,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "decryption": "none",
        "clients": [
          {
            "id": "a539d4bf-77bb-4f2d-8525-ae2eb63614d2",
            "level": 0
#httpupgrade-nontls
          }
        ]
      },
      "streamSettings": {
        "network": "httpupgrade",
        "security": "none",
        "httpupgradeSettings": {
          "acceptProxyProtocol": true,
          "path": "/httpupgrade"
        }
      }
    },
    {
      "port": 8080,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "a539d4bf-77bb-4f2d-8525-ae2eb63614d2"
#xray-vless-xhttp-nontls         
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "none",
        "xhttpSettings": {
          "path": "/xhttp",
          "headers": {},
          "scMaxBufferedPosts": 20,
          "scMaxEachPostBytes": 800000,
          "noSSEHeader": false,
          "xPaddingBytes": "100-1000",
          "mode": "auto"
        }
      }
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "user": [
          "regexp:^blocked-"
        ],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "inboundTag": ["api"],
        "outboundTag": "api"
      },
      {
        "type": "field",
        "protocol": ["bittorrent"],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },

      /* ===== DOMAIN WARP (MUDAH BUANG) ===== */
      {
        "type": "field",
        "domain": [
          "domain:example.net"
        ],
        "outboundTag": "direct"
      }
    ]
  },

  "stats": {},

  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },

  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true
    }
  },

  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "direct"
    },
    {
      "protocol": "socks",
      "tag": "warp",
      "settings": {
        "servers": [
          {
            "address": "127.0.0.1",
            "port": 40000
          }
        ]
      }
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    },
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "api"
    }
  ]
}
END

# // IPTABLE TCP 
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8880 -j ACCEPT


# // IPTABLE UDP
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8080 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8880 -j ACCEPT
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# // ENABLE XRAY TCP XTLS 80/443
# ===== FIX: JANGAN hidupkan xray.service. Dulu xray.service DAN xray@config
# ===== dua-dua jalankan config.json (SO_REUSEPORT) -> trafik dibelah 50/50,
# ===== user baru gagal connect ~50% cubaan, dan duplicate cipta semula tiap reboot.
# ===== xray.service ditukar jadi "compat shim" supaya tool lama
# ===== (xp/delete/menu) yang panggil `restart xray.service` tetap berfungsi.
systemctl daemon-reload
systemctl disable xray.service >/dev/null 2>&1 || true
systemctl stop    xray.service >/dev/null 2>&1 || true
cat > /etc/systemd/system/xray.service <<'SHIM'
[Unit]
Description=Xray Service (compat shim -> xray@config + xray@none)
After=xray@config.service xray@none.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/systemctl restart xray@config.service xray@none.service

[Install]
WantedBy=multi-user.target
SHIM
systemctl daemon-reload

# ===== REBORN v3: pasang TEMPLATE xray@.service DAHULU (SEBELUM enable) =====
# install-release.sh rasmi kadang tak letak template ini ->
# "Unit file xray@none.service does not exist". Susunan ni PENTING:
# enable/restart xray@none mesti selepas template wujud.
id www-data >/dev/null 2>&1 || useradd -r -M -s /usr/sbin/nologin www-data 2>/dev/null || useradd -r -M -s /sbin/nologin www-data 2>/dev/null || true
if [ ! -f /etc/systemd/system/xray@.service ]; then
cat > /etc/systemd/system/xray@.service <<'XRAYUNIT'
[Unit]
Description=Xray Service (instance: %i)
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -c /usr/local/etc/xray/%i.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
XRAYUNIT
fi
mkdir -p /etc/systemd/system/xray@.service.d
[ -f /etc/systemd/system/xray@.service.d/50-ejwatt-logs.conf ] || printf '[Service]\nLogsDirectory=xray\nLogsDirectoryMode=0750\n' > /etc/systemd/system/xray@.service.d/50-ejwatt-logs.conf
systemctl daemon-reload

# // ENABLE XRAY NONE TLS (template dah wujud)
systemctl enable xray@none
systemctl restart xray@none || true

# // ENABLE XRAY WS TLS && NONE TLS
systemctl enable xray@config
systemctl restart xray@config || true

# download script
cd /usr/bin
getf "change-port/port-xray.sh" port-xray
getf "cert.sh" certv2ray
getf "menu/trojaan.sh" trojaan
getf "menu/xraay.sh" xraay
chmod +x port-xray
chmod +x certv2ray
chmod +x trojaan
chmod +x xraay

# // Install XrayCore Mod V.25.10.15 (Custompath)
# ===== FIX: penggantian binari xray yang SELAMAT =====
# Dulu: `mv xray xray.bakk && wget ...` — kalau /usr/local/bin/xray tiada, `&&`
# short-circuit -> wget TAK jalan -> XRAY TIADA LANGSUNG.
# Kalau wget gagal, xray dah dipindah ke .bakk dan tak ada ganti -> XRAY HILANG.
# Sekarang: muat turun ke fail sementara, uji, baru tukar. Gagal = kekal yang asal.
CUSTOM_URL="https://github.com/howitzer07/xraycore/releases/download/v25.10.15/xray-linux-amd64"
TMPX="$(mktemp /tmp/xray-custom.XXXXXX 2>/dev/null || echo /tmp/xray-custom.$$)"
ok_custom=0
if wget -q -T 120 -O "$TMPX" "$CUSTOM_URL" && [ -s "$TMPX" ]; then
  chmod 755 "$TMPX"
  if "$TMPX" version >/dev/null 2>&1; then
    ok_custom=1
  else
    echo "[ins-xray] AMARAN: binari custom tak boleh jalan - guna Xray rasmi"
  fi
else
  echo "[ins-xray] AMARAN: gagal muat turun binari custom - guna Xray rasmi"
fi

if [ "$ok_custom" = "1" ]; then
  # simpan yang lama (kalau ada) sebagai .bakk, kemudian pasang yang baru
  [ -x /usr/local/bin/xray ] && cp -f /usr/local/bin/xray /usr/local/bin/xray.bakk 2>/dev/null || true
  mv -f "$TMPX" /usr/local/bin/xray && chmod 755 /usr/local/bin/xray
  echo "[ins-xray] Xray core CUSTOM dipasang: $(/usr/local/bin/xray version 2>/dev/null | head -1)"
else
  rm -f "$TMPX"
  # pastikan tetap ada binari yang berfungsi
  if [ ! -x /usr/local/bin/xray ] && [ -x /usr/local/bin/xray.bakk ]; then
    mv -f /usr/local/bin/xray.bakk /usr/local/bin/xray && chmod 755 /usr/local/bin/xray
    echo "[ins-xray] pulihkan xray daripada .bakk"
  fi
  [ -x /usr/local/bin/xray ] && echo "[ins-xray] guna Xray rasmi: $(/usr/local/bin/xray version 2>/dev/null | head -1)"
fi

# ===== FIX: kalau MASIH tiada binari, pasang dari XTLS rasmi =====
if [ ! -x /usr/local/bin/xray ]; then
  echo "[ins-xray] binari xray masih tiada - pasang Xray rasmi terus"
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data || true
fi

# ===== FIX: SAHKAN binari ada sebelum teruskan. Kalau tiada, BERHENTI. =====
if [ ! -x /usr/local/bin/xray ]; then
  echo "[ins-xray] GAGAL: /usr/local/bin/xray tidak wujud. Install dihentikan."
  exit 1
fi
echo "[ins-xray] OK: $(/usr/local/bin/xray version 2>/dev/null | head -1)"

cd
rm -f ins-xray.sh
# ===== FIX: jangan gagal kalau /root/domain tiada (elak ralat "cannot stat") =====
if [ -f /root/domain ]; then
  mv -f /root/domain /usr/local/etc/xray/domain
fi
[ -f /usr/local/etc/xray/domain ] || echo "" > /usr/local/etc/xray/domain
cp /usr/local/etc/xray/domain /etc/xray/domain
sleep 1
clear;
