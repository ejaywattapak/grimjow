#!/bin/bash
# Grimjow VLESS usage monitor — Xray StatsService
set -Eeuo pipefail

XRAY_BIN="${XRAY_BIN:-$(command -v xray || true)}"
XRAY_SERVER="${XRAY_SERVER:-127.0.0.1:10085}"
CONFIG_FILES=(/usr/local/etc/xray/config.json /usr/local/etc/xray/none.json)
STATE_DIR="/var/lib/grimjow-usage"
STATE_FILE="$STATE_DIR/usage.json"
CRON_FILE="/etc/cron.d/grimjow-usage"

die() { printf 'Ralat: %s\n' "$*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "Jalankan sebagai root."
[[ -n "$XRAY_BIN" && -x "$XRAY_BIN" ]] || die "Binari xray tidak dijumpai."
command -v python3 >/dev/null 2>&1 || die "Python 3 diperlukan untuk membaca data JSON."

get_stats() {
    "$XRAY_BIN" api statsquery --server="$XRAY_SERVER" -pattern 'user>>>' 2>/dev/null
}

ensure_sampler() {
    mkdir -p "$STATE_DIR"
    chmod 700 "$STATE_DIR"
    # Sampling setiap 5 minit supaya penggunaan harian tidak bergantung pada
    # kekerapan menu dibuka. Fail cron khusus, tidak mengubah crontab sedia ada.
    if [[ ! -f "$CRON_FILE" ]] || ! grep -Fq -- "$0 --snapshot" "$CRON_FILE" 2>/dev/null; then
        local script_path
        script_path="$(readlink -f "$0")"
        printf '*/5 * * * * root %q --snapshot >/dev/null 2>&1\n' "$script_path" > "$CRON_FILE"
        chmod 644 "$CRON_FILE"
        if command -v systemctl >/dev/null 2>&1; then
            systemctl restart cron 2>/dev/null || systemctl restart crond 2>/dev/null || true
        fi
    fi
}

process_stats() {
    local raw
    raw="$(get_stats)" || die "Tidak dapat membaca Xray StatsService di $XRAY_SERVER."
    [[ -n "$raw" ]] || die "Xray tidak memulangkan statistik. Pastikan StatsService aktif."
    RAW_XRAY_STATS="$raw" python3 - "$STATE_FILE" "${CONFIG_FILES[@]}" "$1" <<'PY'
import sys, json, re, os, datetime, tempfile

state_path = sys.argv[1]
config_paths = sys.argv[2:-1]
mode = sys.argv[-1]
raw = os.environ.get("RAW_XRAY_STATS", "")
try:
    response = json.loads(raw)
except Exception:
    print("Ralat: output Xray bukan JSON yang sah. Semak Xray API.")
    sys.exit(1)

stats = response.get("stat", [])
if not isinstance(stats, list):
    print("Ralat: format statistik Xray tidak dikenali.")
    sys.exit(1)

# Ambil nama pengguna VLESS daripada penanda yang memang digunakan Grimjow.
users = []
seen = set()
for path in config_paths:
    try:
        with open(path, encoding="utf-8") as f:
            for line in f:
                m = re.match(r"^#(?:vls|vxtls)\s+(\S+)", line)
                if m and m.group(1) not in seen:
                    seen.add(m.group(1))
                    users.append(m.group(1))
    except FileNotFoundError:
        continue

if not users:
    print("Tiada pengguna VLESS dijumpai dalam config.json / none.json.")
    sys.exit(0)

current = {u: 0 for u in users}
for item in stats:
    name = item.get("name", "")
    value = item.get("value", 0)
    # Nama statistik Xray: user>>>EMAIL>>>traffic>>>uplink/downlink
    m = re.match(r"^user>>>(.+?)>>>traffic>>>(?:uplink|downlink)$", name)
    if not m:
        continue
    user = m.group(1)
    if user in current:
        try:
            current[user] += max(0, int(value))
        except (TypeError, ValueError):
            pass

today = datetime.date.today().isoformat()
yesterday = (datetime.date.today() - datetime.timedelta(days=1)).isoformat()
try:
    with open(state_path, encoding="utf-8") as f:
        state = json.load(f)
except (FileNotFoundError, json.JSONDecodeError, OSError):
    state = {"last_date": today, "last": {}, "days": {}, "total": {}}

last = state.setdefault("last", {})
days = state.setdefault("days", {})
totals = state.setdefault("total", {})

# Kira delta daripada sampel terdahulu. Jika Xray restart dan counter turun,
# anggap nilai semasa sebagai delta baharu, bukan nilai negatif.
for user in users:
    now_value = current.get(user, 0)
    previous = last.get(user)
    if previous is None:
        delta = 0
    elif now_value >= previous:
        delta = now_value - previous
    else:
        delta = now_value
    days.setdefault(today, {})
    days[today][user] = int(days[today].get(user, 0)) + delta
    totals[user] = int(totals.get(user, 0)) + delta
    last[user] = now_value

state["last_date"] = today
# Simpan data secara atomik untuk mengelakkan fail rosak jika proses terhenti.
os.makedirs(os.path.dirname(state_path), mode=0o700, exist_ok=True)
fd, temp_path = tempfile.mkstemp(prefix=".usage-", dir=os.path.dirname(state_path))
try:
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump(state, f, ensure_ascii=False)
        f.write("\n")
    os.chmod(temp_path, 0o600)
    os.replace(temp_path, state_path)
finally:
    if os.path.exists(temp_path):
        os.unlink(temp_path)

if mode == "--snapshot":
    sys.exit(0)

def human(n):
    n = max(0, int(n))
    units = ["B", "KB", "MB", "GB", "TB", "PB"]
    value = float(n)
    idx = 0
    while value >= 1024 and idx < len(units)-1:
        value /= 1024
        idx += 1
    if idx == 0:
        return f"{int(value)} {units[idx]}"
    return f"{value:.2f} {units[idx]}"

print("MONITOR PENGGUNA VLESS — XRAY")
print("=" * 44)
for i, user in enumerate(users, 1):
    print(f"{i}. {user}")
    print(f"   Today     : {human(days.get(today, {}).get(user, 0))}")
    print(f"   Yesterday : {human(days.get(yesterday, {}).get(user, 0))}")
    print(f"   Total     : {human(totals.get(user, 0))}")
    print()
print("Nota: data harian mula dikumpul selepas monitor ini diaktifkan.")
PY
}

ensure_sampler
if [[ "${1:-}" == "--snapshot" ]]; then
    process_stats --snapshot
else
    clear 2>/dev/null || true
    process_stats --display
    echo
    read -r -n 1 -s -p "Tekan mana-mana kekunci untuk kembali ke menu VLESS..."
    echo
    exec xraay
fi
