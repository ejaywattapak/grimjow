#!/bin/bash
# ==========================================================================
#  EJAYWATT VPS FIX  —  pembaik untuk autoscript grimjow
#  Membetulkan isu yang buat VPS lemab / user tak boleh connect.
#  SELAMAT: backup dulu, idempotent (boleh jalan berulang kali).
#  SELF-CONTAINED: xp-autodel.py + systemd unit ditanam dalam fail ini.
#
#  Guna:
#     ejwatt-fix.sh                 # buat semua
#     ejwatt-fix.sh --dry-run       # tengok dulu, tak ubah apa-apa
#     ejwatt-fix.sh --only xray,cron
#     bahagian: xray | cron | autodel | watchdog | log | ovpn | journal
# ==========================================================================
set -uo pipefail

XDIR=/usr/local/etc/xray
CFG=$XDIR/config.json
NONE=$XDIR/none.json
XRAYBIN=/usr/local/bin/xray
TS=$(date +%Y%m%d-%H%M%S)
BK=/root/ejwatt-fix-backup-$TS
DRY=0
ONLY=""
CHANGED=0

R=$'\e[31m'; G=$'\e[32m'; Y=$'\e[33m'; C=$'\e[36m'; B=$'\e[1m'; N=$'\e[0m'

say(){ printf '%s\n' "$*"; }
ok(){  printf '%s  [ ok ]%s %s\n' "$G" "$N" "$*"; }
warn(){ printf '%s  [warn]%s %s\n' "$Y" "$N" "$*"; }
fix(){
  if [ "$DRY" = 1 ]; then
    printf '%s  [plan]%s %s\n' "$C" "$N" "$*"
  else
    printf '%s  [ FIX]%s %s\n' "$C" "$N" "$*"; CHANGED=1
  fi
}
head2(){ printf '\n%s== %s ==%s\n' "$B" "$*" "$N"; }
die(){ printf '%s[FAIL]%s %s\n' "$R" "$N" "$*" >&2; exit 1; }
want(){ [ -z "$ONLY" ] && return 0; case ",$ONLY," in *",$1,"*) return 0;; esac; return 1; }
skip(){ [ "$DRY" = 1 ] && { say "        (dry-run) $*"; return 0; }; return 1; }
need_bin(){ command -v "$1" >/dev/null 2>&1; }

bk(){
  local f=$1 d
  [ "$DRY" = 1 ] && return 0
  [ -e "$f" ] || return 0
  mkdir -p "$BK"
  d="$BK/$(printf '%s' "$f" | sed 's|^/||; s|/|__|g')"
  cp -a "$f" "$d" 2>/dev/null && say "        backup -> $d"
}

# put_file <dest> <mode>   (kandungan dari stdin)
# return 0 = berubah / perlu tulis, 1 = sudah sama
put_file(){
  local dest=$1 mode=$2 tmp
  tmp=$(mktemp) || return 1
  cat > "$tmp"
  if [ -f "$dest" ] && cmp -s "$tmp" "$dest"; then
    rm -f "$tmp"; return 1
  fi
  if [ "$DRY" = 1 ]; then rm -f "$tmp"; return 0; fi
  mkdir -p "$(dirname "$dest")"
  install -m "$mode" "$tmp" "$dest"
  rm -f "$tmp"
  return 0
}

# ---------------------------------------------------------------- xray ----
restart_xray(){
  skip "restart xray@config + xray@none" && return 0
  systemctl restart xray@config.service xray@none.service >/dev/null 2>&1
  sleep 1
}

kill_dupes(){
  local unit cfg main pid exe n=0
  for pair in "xray@config.service:config.json" "xray@none.service:none.json"; do
    unit=${pair%%:*}; cfg=${pair##*:}
    main=$(systemctl show -p MainPID --value "$unit" 2>/dev/null); main=${main:-0}
    for pid in $(pgrep -f "[x]ray run -config $XDIR/$cfg" 2>/dev/null); do
      [ "$pid" = "$main" ] && continue
      exe=$(readlink -f "/proc/$pid/exe" 2>/dev/null || true)
      [ "$exe" = "$XRAYBIN" ] || continue
      if [ "$DRY" = 1 ]; then
        fix "akan bunuh proses xray berganda pid $pid ($cfg)"
      else
        kill -TERM "$pid" 2>/dev/null && { fix "bunuh proses xray berganda pid $pid ($cfg)"; n=$((n+1)); }
      fi
    done
  done
  [ "$n" = 0 ] && ok "tiada proses xray berganda"
  return 0
}

# ------------------------------------------------------------- xraydeps ----
install_xray_core(){
  # Pasang Xray core rasmi (kalau installer autoscript gagal pasang)
  local arch url tmpd
  case "$(uname -m)" in
    x86_64|amd64) arch="64" ;;
    aarch64|arm64) arch="arm64-v8a" ;;
    *) warn "arkitektur $(uname -m) tak disokong — pasang manual"; return 1 ;;
  esac
  url="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-${arch}.zip"
  need_bin curl || need_bin wget || { warn "curl/wget tiada"; return 1; }
  need_bin unzip || { warn "unzip tiada"; return 1; }

  tmpd=$(mktemp -d) || return 1
  say "        memuat turun Xray core: $url"
  if need_bin curl; then
    curl -fL --max-time 180 -o "$tmpd/x.zip" "$url" >/dev/null 2>&1 || { warn "muat turun gagal"; rm -rf "$tmpd"; return 1; }
  else
    wget -q -T 180 -O "$tmpd/x.zip" "$url" || { warn "muat turun gagal"; rm -rf "$tmpd"; return 1; }
  fi
  unzip -o -q "$tmpd/x.zip" -d "$tmpd" 2>/dev/null || { warn "unzip gagal (fail rosak?)"; rm -rf "$tmpd"; return 1; }
  [ -f "$tmpd/xray" ] || { warn "binary xray tiada dalam zip"; rm -rf "$tmpd"; return 1; }
  install -m 0755 "$tmpd/xray" "$XRAYBIN" || { rm -rf "$tmpd"; return 1; }
  rm -rf "$tmpd"
  [ -x "$XRAYBIN" ]
}

write_units(){
  if [ ! -f /etc/systemd/system/xray@.service ]; then
    if [ "$DRY" = 0 ]; then
      cat > /etc/systemd/system/xray@.service <<'U1'
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/%i.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
RuntimeDirectory=xray-%i
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target
U1
    fi
    fix "unit xray@.service dicipta (tiada selepas install)"
  else
    ok "unit xray@.service ada"
  fi

  if [ ! -f /etc/systemd/system/xray.service ]; then
    if [ "$DRY" = 0 ]; then
      cat > /etc/systemd/system/xray.service <<'U2'
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
RuntimeDirectory=xray
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target
U2
    fi
    fix "unit xray.service dicipta (tiada selepas install)"
  else
    ok "unit xray.service ada"
  fi
}

fix_xraydeps(){
  head2 "0. Kebergantungan Xray (binary / unit / config)"
  local bad=0

  if [ -x "$XRAYBIN" ]; then
    ok "binary xray ada: $("$XRAYBIN" version 2>/dev/null | head -1 | cut -d' ' -f1-2)"
  else
    warn "binary xray TIADA: $XRAYBIN"
    if [ "$DRY" = 1 ]; then
      fix "akan pasang Xray core rasmi (XTLS/Xray-core)"
    elif install_xray_core; then
      fix "Xray core dipasang: $("$XRAYBIN" version 2>/dev/null | head -1 | cut -d' ' -f1-2)"
    else
      warn "gagal pasang Xray core — pasang manual kemudian jalankan skrip semula"
      bad=1
    fi
  fi

  write_units

  if [ -f "$CFG" ] && [ -f "$NONE" ]; then
    ok "config.json + none.json ada"
  else
    warn "config xray tiada di $XDIR — jalankan installer autoscript dulu"; bad=1
  fi

  if [ "$DRY" = 0 ] && [ -f /etc/systemd/system/xray@.service ]; then
    systemctl daemon-reload
    systemctl enable xray@config.service xray@none.service >/dev/null 2>&1 || true
  fi

  [ "$bad" = 1 ] && warn "ada kebergantungan belum selesai (lihat mesej di atas)"
  return 0
}

fix_xray(){
  head2 "1. Xray duplicate (xray.service vs xray@config)"
  if [ ! -f /etc/systemd/system/xray@.service ]; then
    warn "xray@.service tiada — bukan autoscript ni, langkau"; return 0
  fi

  # (a) drop-in rasmi Xray yang paksa xray.service jalankan config.json
  local dropin=/etc/systemd/system/xray.service.d/10-donot_touch_single_conf.conf
  if [ -f "$dropin" ]; then
    bk "$dropin"
    if [ "$DRY" = 0 ]; then mv "$dropin" "$dropin.disabled-ejwatt"; fi
    fix "drop-in 10-donot_touch_single_conf.conf dinyahaktif (punca duplicate)"
  else
    ok "drop-in paksa config.json sudah tiada"
  fi

  # (b) xray.service -> compat shim
  local unit=/etc/systemd/system/xray.service
  if grep -qF 'compat shim' "$unit" 2>/dev/null; then
    ok "xray.service sudah jadi compat shim"
  else
    bk "$unit"
    if [ "$DRY" = 0 ]; then
      cat > "$unit" <<'SHIM'
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
      systemctl disable xray.service >/dev/null 2>&1 || true
      systemctl stop xray.service >/dev/null 2>&1 || true
    fi
    fix "xray.service ditukar jadi compat shim (script lama tetap jalan, tiada duplicate)"
  fi

  # (b2) kebenaran log: punca "permission denied" bila installer tak cipta fail log
  local ldir=/var/log/xray
  if [ ! -d "$ldir" ] || [ "$(stat -c '%U' "$ldir" 2>/dev/null)" != "www-data" ]; then
    if [ "$DRY" = 0 ]; then
      mkdir -p "$ldir"
      touch "$ldir/access.log" "$ldir/error.log"
      chown -R www-data:www-data "$ldir"
      chmod 750 "$ldir"; chmod 600 "$ldir"/*.log 2>/dev/null || true
    fi
    fix "/var/log/xray dimilik www-data (punca xray gagal start: permission denied)"
  else
    ok "/var/log/xray dimilik www-data"
  fi

  # (b3) LogsDirectory: systemd cipta + chown automatik setiap start (kekal)
  local ldrop=/etc/systemd/system/xray@.service.d
  if [ -f "$ldrop/50-ejwatt-logs.conf" ]; then
    ok "LogsDirectory xray sudah dipasang"
  else
    if [ "$DRY" = 0 ]; then
      mkdir -p "$ldrop"
      printf '[Service]\nLogsDirectory=xray\nLogsDirectoryMode=0750\n' > "$ldrop/50-ejwatt-logs.conf"
      systemctl daemon-reload
    fi
    fix "LogsDirectory=xray ditambah (log sentiasa boleh ditulis)"
  fi

  if [ "$DRY" = 0 ]; then
    systemctl enable xray@config.service xray@none.service >/dev/null 2>&1 || true
    systemctl is-active --quiet xray@config.service || systemctl start xray@config.service >/dev/null 2>&1
    systemctl is-active --quiet xray@none.service   || systemctl start xray@none.service   >/dev/null 2>&1
  fi
  kill_dupes

  if [ "$DRY" = 0 ]; then
    local n; n=$(pgrep -fc "[x]ray run -config $XDIR/" 2>/dev/null || echo 0)
    if [ "$n" -le 2 ]; then ok "proses xray = $n (betul)"; else warn "proses xray = $n — semak manual"; fi
  fi
}

# ---------------------------------------------------------------- cron ----
fix_cron(){
  head2 "2. Cron jalankan binary menu interaktif (xp / delete) -> fork storm"
  local f=/etc/crontab re
  re='^[^#].*root[[:space:]]+(/usr/bin/)?(xp|delete)[[:space:]]*$'
  if [ -f "$f" ] && grep -qE "$re" "$f"; then
    bk "$f"
    skip "komen cron xp/delete dalam /etc/crontab" || \
    sed -i -E "s@^([^#].*root[[:space:]]+(/usr/bin/)?(xp|delete)[[:space:]]*)\$@#DISABLED-ejwatt (interactive, fork-storm): \\1@" "$f"
    fix "cron xp/delete dalam /etc/crontab dikomen (punca fork storm 02:00-05:00)"
  else
    ok "/etc/crontab bersih"
  fi

  if need_bin crontab && crontab -l 2>/dev/null | grep -qE "$re"; then
    bk /var/spool/cron/crontabs/root 2>/dev/null || true
    if [ "$DRY" = 0 ]; then
      crontab -l 2>/dev/null | sed -E "s@^([^#].*root[[:space:]]+(/usr/bin/)?(xp|delete)[[:space:]]*)\$@#DISABLED-ejwatt: \\1@" | crontab -
    fi
    fix "cron xp/delete dalam crontab root dikomen"
  else
    ok "crontab root bersih"
  fi
}

# ------------------------------------------------------------- autodel ----
fix_autodel(){
  head2 "3. Auto-delete user expired (ganti cron xp yang rosak)"
  local need=0

  put_file /usr/local/bin/xp-autodel.py 0755 <<'PYAUTODEL'
#!/usr/bin/env python3
# ==========================================================================
#  xp-autodel.py — buang user XRAY yang tamat tempoh (non-interactive)
#  Ganti cron "xp" yang lama (interaktif -> fork storm).
#    - backup dulu, validate dengan "xray -test", rollback kalau rosak
#    - handle #vms #vls #vls-http #vls-xhttp #vxtls #trx #trws + akunxtr.conf
#    - guard: bunuh proses xray berganda
#  Guna: xp-autodel.py [--dry-run] [--guard-only]
# ==========================================================================
import os
import re
import sys
import shutil
import datetime
import subprocess
import time

XDIR   = "/usr/local/etc/xray"
CONFIGS = [XDIR + "/config.json", XDIR + "/none.json"]
XTR    = XDIR + "/akunxtr.conf"
BKDIR  = XDIR + "/autodel-backup"
LOG    = "/var/log/xp-autodel.log"
XRAY   = "/usr/local/bin/xray"
UNITS  = ["xray@config.service", "xray@none.service"]
TAGS   = {"vms", "vls", "vls-http", "vls-xhttp", "vxtls", "trx", "trws",
          "vmess", "trojan", "tr"}
PAT    = re.compile(
    r"^#([A-Za-z][A-Za-z0-9\-]*)\s+(\S+)\s+(\d{4}-\d{2}-\d{2})"
    r"\s+(\d{4}-\d{2}-\d{2})\s+([0-9a-fA-F\-]{36})\s*$")
XTRPAT = re.compile(r"^###\s+(\S+)\s+(\d{4}-\d{2}-\d{2})\b")


def log(msg):
    line = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") + " | " + msg
    try:
        with open(LOG, "a") as f:
            f.write(line + "\n")
    except Exception:
        pass
    print(line, flush=True)


def sh(cmd):
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=90)
        return (r.stdout or "").strip(), (r.stderr or "").strip()
    except Exception as e:
        return "", str(e)


def backup(path):
    os.makedirs(BKDIR, exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    dst = os.path.join(BKDIR, os.path.basename(path) + "." + stamp)
    shutil.copy2(path, dst)
    files = sorted((os.path.join(BKDIR, f) for f in os.listdir(BKDIR)),
                   key=os.path.getmtime)
    for old in files[:-40]:
        try:
            os.remove(old)
        except Exception:
            pass
    return dst


def validate(path):
    out, err = sh("%s -test -config '%s' 2>&1" % (XRAY, path))
    blob = out + err
    return ("Configuration OK" in blob), blob[-300:]


def sweep(path, today, dry):
    if not os.path.isfile(path):
        return []
    with open(path, "r", encoding="utf-8", errors="surrogateescape") as f:
        lines = f.read().split("\n")
    out, removed, i, n = [], [], 0, len(lines)
    while i < n:
        line = lines[i]
        m = PAT.match(line.strip())
        if m and m.group(1).lower() in TAGS:
            name, exp_s, uuid = m.group(2), m.group(3), m.group(5)
            try:
                expired = datetime.date.fromisoformat(exp_s) < today
            except ValueError:
                expired = False
            if expired:
                j = None
                for k in range(i + 1, min(i + 6, n)):
                    cand = lines[k]
                    if uuid in cand and "{" in cand and "}" in cand:
                        j = k
                        break
                if j is None:
                    log("WARN %s: client objek tak jumpa (%s)" % (name, path))
                elif lines[j].count("{") != 1 or lines[j].count("}") != 1:
                    log("WARN %s: objek bukan 1-baris, dilangkau (%s)" % (name, path))
                else:
                    removed.append((name, exp_s))
                    i = j + 1
                    continue
        out.append(line)
        i += 1

    if removed and not dry:
        bak = backup(path)
        with open(path, "w", encoding="utf-8", errors="surrogateescape") as f:
            f.write("\n".join(out))
        if path.endswith(".json"):
            good, tail = validate(path)
            if not good:
                shutil.copy2(bak, path)
                log("ROLLBACK %s tak valid -> dipulihkan. %s" % (os.path.basename(path), tail))
                return []
        log("EDIT OK %s (backup %s)" % (os.path.basename(path), bak))
    return removed


def sweep_xtr(path, today, dry):
    """akunxtr.conf: marker '### user exp ...' satu baris."""
    if not os.path.isfile(path):
        return []
    with open(path, "r", encoding="utf-8", errors="surrogateescape") as f:
        lines = f.read().split("\n")
    keep, removed = [], []
    for line in lines:
        m = XTRPAT.match(line.strip())
        if m:
            try:
                if datetime.date.fromisoformat(m.group(2)) < today:
                    removed.append((m.group(1), m.group(2)))
                    continue
            except ValueError:
                pass
        keep.append(line)
    if removed and not dry:
        backup(path)
        with open(path, "w", encoding="utf-8", errors="surrogateescape") as f:
            f.write("\n".join(keep))
        log("EDIT OK akunxtr.conf")
    return removed


STAMP_DIR = "/run/ejwatt-guard"
RATE = 600  # jangan restart unit yang sama lebih 1x setiap 10 minit


def _stamp(unit):
    return os.path.join(STAMP_DIR, unit.replace("/", "_"))


def recently_restarted(unit):
    try:
        return (time.time() - os.path.getmtime(_stamp(unit))) < RATE
    except Exception:
        return False


def touch_stamp(unit):
    try:
        if not os.path.isdir(STAMP_DIR):
            os.makedirs(STAMP_DIR, exist_ok=True)
        with open(_stamp(unit), "w") as f:
            f.write(str(int(time.time())))
    except Exception:
        pass


def guard():
    """Hidupkan balik unit yang mati. TIDAK sentuh unit yang sihat."""
    fixed = 0
    for unit in UNITS:
        cfg = "%s/%s.json" % (XDIR, unit.split("@")[1].replace(".service", ""))
        # (a) jangan ganggu kalau systemd tengah sibuk start/stop unit tu
        state, _ = sh("systemctl show -p ActiveState --value " + unit)
        if state in ("activating", "deactivating", "reloading", "refreshing"):
            log("GUARD skip %s (state=%s)" % (unit, state))
            continue
        mainpid, _ = sh("systemctl show -p MainPID --value " + unit)
        try:
            mainpid = int(mainpid)
        except ValueError:
            mainpid = 0
        pids, _ = sh("pgrep -f '[x]ray run -config %s'" % cfg)
        plist = []
        for x in pids.split():
            if not x.isdigit():
                continue
            try:
                exe = os.path.realpath("/proc/%s/exe" % x)
            except Exception:
                exe = ""
            if exe == os.path.realpath(XRAY):
                plist.append(int(x))
        for p in [x for x in plist if x != mainpid]:
            sh("kill -TERM %d" % p)
            log("GUARD bunuh proses xray berganda pid %d (%s)" % (p, os.path.basename(cfg)))
            fixed += 1
        if mainpid == 0 or mainpid not in plist:
            if recently_restarted(unit):
                log("GUARD skip %s (baru restart < %d saat)" % (unit, RATE))
                continue
            sh("systemctl restart " + unit)
            touch_stamp(unit)
            log("GUARD %s tiada proses utama -> restart" % unit)
            fixed += 1
    return fixed


def main():
    dry = "--dry-run" in sys.argv
    if "--guard-only" in sys.argv:
        guard()
        return 0
    today = datetime.date.today()
    found = []
    for p in CONFIGS:
        found.extend(sweep(p, today, dry))
    found.extend(sweep_xtr(XTR, today, dry))

    uniq, seen = [], set()
    for name, exp in found:
        if (name, exp) not in seen:
            seen.add((name, exp))
            uniq.append((name, exp))

    if dry:
        if uniq:
            log("DRY-RUN akan buang: " + ", ".join("%s (exp %s)" % t for t in uniq))
        else:
            log("DRY-RUN tiada user expired")
        return 0

    if uniq:
        log("DIBUANG %d user: %s" % (len(uniq), ", ".join("%s [exp %s]" % t for t in uniq)))
        for u in UNITS:
            sh("systemctl restart " + u)
        log("RESTART " + " ".join(UNITS))
    guard()
    return 0


if __name__ == "__main__":
    sys.exit(main())
PYAUTODEL
  [ $? -eq 0 ] && need=1

  put_file /etc/systemd/system/xp-autodel.service 0644 <<'UNIT_SVC'
[Unit]
Description=EJAYWATT xray auto-delete expired users
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/python3 /usr/local/bin/xp-autodel.py
UNIT_SVC
  [ $? -eq 0 ] && need=1

  put_file /etc/systemd/system/xp-autodel.timer 0644 <<'UNIT_TMR'
[Unit]
Description=EJAYWATT jalankan xray auto-delete setiap jam

[Timer]
OnBootSec=2min
OnUnitActiveSec=1h
AccuracySec=1min
Persistent=true

[Install]
WantedBy=timers.target
UNIT_TMR
  [ $? -eq 0 ] && need=1

  if ! systemctl is-enabled --quiet xp-autodel.timer 2>/dev/null; then need=1; fi

  if [ "$need" = 0 ]; then
    ok "xp-autodel sudah dipasang & terkini"
  else
    if [ "$DRY" = 0 ]; then
      systemctl daemon-reload
      systemctl enable --now xp-autodel.timer >/dev/null 2>&1
    fi
    fix "xp-autodel dipasang/dikemaskini (timer setiap jam + guard duplicate)"
  fi

  if need_bin crontab && crontab -l 2>/dev/null | grep -qE '^[^#].*xp-auto'; then
    bk /var/spool/cron/crontabs/root 2>/dev/null || true
    if [ "$DRY" = 0 ]; then
      crontab -l 2>/dev/null | sed -E 's@^([^#].*xp-auto.*)$@#DISABLED-ejwatt (ganti xp-autodel.py): \1@' | crontab -
    fi
    fix "cron xp-auto lama dikomen (elak bertindih dengan xp-autodel)"
  fi
  if [ -f /etc/crontab ] && grep -qE '^[^#].*xp-auto' /etc/crontab; then
    bk /etc/crontab
    if [ "$DRY" = 0 ]; then
      sed -i -E 's@^([^#].*xp-auto.*)$@#DISABLED-ejwatt (ganti xp-autodel.py): \1@' /etc/crontab
    fi
    fix "cron xp-auto dalam /etc/crontab dikomen"
  fi
  return 0
}

# ------------------------------------------------------------ watchdog ----
fix_watchdog(){
  head2 "3b. Watchdog (xray mati -> hidup balik automatik)"
  local need=0

  put_file /usr/local/bin/xp-watchdog 0755 <<'WD'
#!/bin/bash
# pastikan xray@config + xray@none hidup, bunuh yang berganda
[ -f /etc/ejwatt-watchdog.off ] && exit 0
exec /usr/bin/python3 /usr/local/bin/xp-autodel.py --guard-only
WD
  [ $? -eq 0 ] && need=1

  put_file /etc/systemd/system/xp-watchdog.service 0644 <<'WDS'
[Unit]
Description=EJAYWATT xray watchdog (pastikan servis hidup)
After=network.target xray@config.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/xp-watchdog
Nice=5
WDS
  [ $? -eq 0 ] && need=1

  put_file /etc/systemd/system/xp-watchdog.timer 0644 <<'WDT'
[Unit]
Description=EJAYWATT watchdog setiap 2 minit

[Timer]
OnBootSec=90s
OnUnitActiveSec=2min
AccuracySec=15s
Persistent=false

[Install]
WantedBy=timers.target
WDT
  [ $? -eq 0 ] && need=1

  if ! systemctl is-enabled --quiet xp-watchdog.timer 2>/dev/null; then need=1; fi

  if [ "$need" = 0 ]; then
    ok "watchdog sudah dipasang & terkini"
  else
    if [ "$DRY" = 0 ]; then
      systemctl daemon-reload
      systemctl enable --now xp-watchdog.timer >/dev/null 2>&1
      systemctl start xp-watchdog.timer >/dev/null 2>&1
    fi
    fix "watchdog dipasang (semak setiap 2 minit; matikan: touch /etc/ejwatt-watchdog.off)"
  fi
  return 0
}

# ---------------------------------------------------------------- log ----
fix_log(){
  head2 "4. loglevel xray (info -> warning)"
  local f changed=0 b
  for f in "$CFG" "$NONE"; do
    [ -f "$f" ] || continue
    if ! grep -q '"loglevel": *"info"' "$f"; then ok "$(basename "$f") sudah warning"; continue; fi
    bk "$f"
    if [ "$DRY" = 0 ]; then
      sed -i 's/"loglevel": *"info"/"loglevel": "warning"/' "$f"
      if need_bin "$XRAYBIN" && ! "$XRAYBIN" -test -config "$f" >/dev/null 2>&1; then
        b="$BK/$(printf '%s' "$f" | sed 's|^/||; s|/|__|g')"
        cp -a "$b" "$f"; warn "$(basename "$f") tak valid — dipulihkan"; continue
      fi
    fi
    fix "$(basename "$f") loglevel -> warning"; changed=1
  done
  [ "$changed" = 1 ] && restart_xray
  return 0
}

# --------------------------------------------------------------- ovpn ----
fix_ovpn(){
  head2 "5. OpenVPN mssfix / txqueuelen (MTU 1500 tanpa mssfix)"
  local f changed=0 s
  for f in /etc/openvpn/server/*.conf; do
    [ -f "$f" ] || continue
    if grep -q '^mssfix' "$f"; then ok "$(basename "$f") sudah ada mssfix"; continue; fi
    bk "$f"
    if [ "$DRY" = 0 ]; then
      if grep -q '^keepalive' "$f"; then
        sed -i '0,/^keepalive.*$/s//&\nmssfix 1400\ntxqueuelen 2000/' "$f"
      else
        printf 'mssfix 1400\ntxqueuelen 2000\n' >> "$f"
      fi
    fi
    fix "$(basename "$f"): +mssfix 1400 +txqueuelen 2000"; changed=1
  done
  if [ "$changed" = 1 ] && [ "$DRY" = 0 ]; then
    for s in $(systemctl list-units --type=service --state=active --no-legend 'openvpn-server@*' 2>/dev/null | awk '{print $1}'); do
      systemctl restart "$s" >/dev/null 2>&1 || true
    done
    ok "openvpn direstart"
  fi
  return 0
}

# ------------------------------------------------------------ journal ----
fix_journal(){
  head2 "6. journald (log system membengkak)"
  local d=/etc/systemd/journald.conf.d/99-ejwatt.conf
  if grep -rqs SystemMaxUse /etc/systemd/journald.conf.d/ /etc/systemd/journald.conf; then
    ok "journald sudah dicap"; return 0
  fi
  if [ "$DRY" = 0 ]; then
    mkdir -p /etc/systemd/journald.conf.d
    printf '[Journal]\nSystemMaxUse=200M\nSystemMaxFileSize=50M\n' > "$d"
    systemctl restart systemd-journald >/dev/null 2>&1 || true
    journalctl --vacuum-size=150M >/dev/null 2>&1 || true
  fi
  fix "journald dicap 200M + vacuum"
}

# --------------------------------------------------------------- main ----
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run|-n) DRY=1 ;;
    --only) shift; ONLY=${1:-} ;;
    -h|--help) sed -n '2,16p' "$0" 2>/dev/null || true; exit 0 ;;
    *) die "argumen tak dikenali: $1" ;;
  esac
  shift
done

[ "$(id -u)" = 0 ] || die "kena jalan sebagai root"
[ -f "$CFG" ] || die "$CFG tiada — bukan VPS xray?"

say "${B}EJAYWATT VPS FIX${N}   $(date '+%F %T')   dry-run=$DRY"
if [ "$DRY" = 0 ]; then mkdir -p "$BK"; say "backup folder: $BK"; fi

want xray    && fix_xraydeps
want xray    && fix_xray
want cron    && fix_cron
want autodel && fix_autodel
want watchdog && fix_watchdog
want log     && fix_log
want ovpn    && fix_ovpn
want journal && fix_journal

say ""
if [ "$DRY" = 1 ]; then
  say "${Y}Selesai (dry-run). Tak ada apa-apa diubah.${N}"
else
  say "${G}Selesai.${N} Backup: $BK"
  say "Log auto-delete: /var/log/xp-autodel.log"
fi
