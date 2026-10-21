# fix/ — EJAYWATT VPS FIX

Pembaik untuk isu yang dijumpai pada VPS production (87.76.160.198 & 113.29.231.246).
Semua perubahan **tak sentuh akaun customer** dan **idempotent** (boleh jalan berulang kali).

Skrip ini **self-contained** — `xp-autodel.py` dan systemd unit ditanam di dalam
`ejwatt-fix.sh`, jadi tak perlu fail sokongan lain.

## Isu yang dibetulkan

| # | Isu | Kesan | Fix |
|---|-----|-------|-----|
| 1 | **Xray duplicate** — `xray.service` dan `xray@config` dua-dua jalankan `config.json` (SO_REUSEPORT) | Trafik dibelah 50/50; user baru gagal connect ~50% cubaan. Cipta semula setiap reboot. | Drop-in `10-donot_touch_single_conf.conf` dinyahaktif + `xray.service` jadi *compat shim* |
| 2 | **Cron jalankan binary menu interaktif** — `0 2 root xp`, `0 3 root /usr/bin/xp`, `0 1 root delete`, `0 4 root /usr/bin/delete` | Tanpa TTY → EOF → `exec` loop → **fork storm**. Diukur: PID 18,004 → 449,202 → **1,299,800** (~1.28 juta proses) antara 02:00–05:00. | Baris cron dikomen |
| 3 | **`clear-log.service` gagal** — `ExecStart=/bin/bash /usr/bin/clear-log`, tapi `clear-log` itu binary ELF | Status 126. Log tak pernah clear → `/var/log` membengkak. | `ExecStart=/usr/bin/clear-log` |
| 4 | **`"loglevel": "info"`** | Setiap connection tulis 6–8 baris log. error.log 54 MB/hari. | Tukar ke `warning` (turun ke 0 B/s) |
| 5 | **tun MTU 1500 tanpa `mssfix`** | User OpenVPN kena fragmentation → tersekat-sekat, retransmit tinggi. | `mssfix 1400` + `txqueuelen 2000` |
| 6 | **journald tak dicap** | `/var/log/journal` 339–448 MB. | Cap 200 MB + vacuum |
| 7 | **Auto-delete user expired tak jalan** (cron panggil `xp` interaktif) | User expired masih boleh connect. | `xp-autodel` + systemd timer (tak perlu cron) |

## Guna

```bash
bash fix/ejwatt-fix.sh --dry-run            # tengok dulu apa akan diubah
bash fix/ejwatt-fix.sh                      # buat semua
bash fix/ejwatt-fix.sh --only xray,cron     # bahagian tertentu
```

Bahagian: `xray` · `cron` · `autodel` · `log` · `ovpn` · `journal`

Backup automatik ke `/root/ejwatt-fix-backup-<tarikh>/`.

## Auto-delete (xp-autodel)

- Jalan **setiap jam** (`xp-autodel.timer`), tiada `cron` diperlukan
- Handle marker: `#vms` `#vls` `#vls-http` `#vls-xhttp` `#vxtls` `#trx` `#trws` + `akunxtr.conf`
- Buang marker + blok client dari **config.json DAN none.json** (penting: kalau
  buang satu je, user expired masih boleh connect ikut port `none.json`)
- Backup dulu → `xray -test` → **rollback automatik** kalau rosak
- Log: `/var/log/xp-autodel.log`
- Backup 40 terakhir: `/usr/local/etc/xray/autodel-backup/`
- Sekali jalan, ia juga **guard**: bunuh proses xray berganda kalau ada

Test tanpa ubah apa-apa:

```bash
python3 /usr/local/bin/xp-autodel.py --dry-run
```

## Kenapa `xray.service` jadi "shim"?

Beberapa tool (`/usr/bin/xp`, `/usr/bin/delete`, `/usr/bin/menu`) adalah **binary ELF**
yang tak boleh dipatch, dan ada yang panggil `systemctl restart xray.service`.

Dengan menukar `xray.service` kepada:

```ini
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/systemctl restart xray@config.service xray@none.service
```

semua pemanggil (script mahupun binary) tetap berfungsi, tetapi restart itu pergi ke
unit yang betul dan **tidak boleh lagi cipta duplicate**.

`xray.service` juga `disabled` dari boot supaya masa reboot hanya
`xray@config` + `xray@none` yang start.

## Rollback

Fail asal disimpan dalam `/root/ejwatt-fix-backup-<tarikh>/`.
Untuk pulihkan `xray.service` kepada asal:

```bash
cd /etc/systemd/system/xray.service.d
mv 10-donot_touch_single_conf.conf.disabled-ejwatt 10-donot_touch_single_conf.conf
cp /root/ejwatt-fix-backup-*/etc__systemd__system__xray.service /etc/systemd/system/xray.service
systemctl daemon-reload
systemctl enable --now xray.service
```
