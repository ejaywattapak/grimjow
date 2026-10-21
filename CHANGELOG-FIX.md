# CHANGELOG — pembaikan oleh Zafiro (2026-10-21)

Berasaskan siasatan pada 2 VPS production:
- 87.76.160.198 (mys.ejwtpkvpn.my)
- 113.29.231.246 (sgs.ejwtpkvpn.my)

## Fail yang DIUBAH

### `more-option/xraay`  (script bash — dipasang sebagai /usr/bin/xraay)

4 tempat restart `xray.service` sahaja (fungsi vxtls: add, add+sni, delete, renew):

```diff
-systemctl restart xray.service
+systemctl restart xray@config.service xray@none.service
```

Baris: 1329, 1422, 1483, 1535.

Sebab: bila `xray@config` yang pegang port 443, restart `xray.service` sahaja
menyebabkan perubahan vxtls TIDAK apply.

## Fail BARU

```
install.sh              (6.4 KB)  wrapper: installer asal + auto fix
fix/ejwatt-fix.sh       (18.2 KB) skrip pembaik (self-contained)
fix/README.md                     dokumentasi
CHANGELOG-FIX.md                  fail ini
```

### install.sh

Satu langkah: jalankan `installer.sh` asal, kemudian automatik jalankan fixer.

```bash
bash install.sh --dry-run   # tunjuk rancangan
bash install.sh             # tanya, kemudian install + fix
bash install.sh --yes       # terus jalan
```

Kalau VPS reboot masa install (sebelum fix sempat jalan), satu systemd unit
`ejwatt-fix-once` akan jalankan fixer pada boot berikutnya dan kemudian
matikan dirinya sendiri.

## Fail yang TIDAK diusik

README.md tidak diusik. Semua fail lain adalah **binary ELF** (dikompil) dan
tidak boleh dipatch — sebab itu pembaikan dibuat oleh `fix/ejwatt-fix.sh`
yang mengubah state sistem (systemd unit, cron, config) ketika dijalankan di VPS.

## Isu yang dibetulkan oleh `fix/ejwatt-fix.sh`

| # | Isu | Bukti pada VPS |
|---|-----|----------------|
| 1 | `xray.service` + `xray@config` dua-dua jalankan config.json (SO_REUSEPORT) | `ss -lntp` tunjuk 2 pid pada *:443. Drop-in `10-donot_touch_single_conf.conf` paksa ExecStart. Cipta semula setiap reboot. |
| 2 | Cron jalankan `xp`/`delete` (menu interaktif) tanpa TTY | PID: 18,004 (02:00) → 449,202 (03:00) → 1,299,800 (04:00). ~1.28 juta proses. Hilang hanya bila reboot 05:00. |
| 3 | `clear-log.service` = `ExecStart=/bin/bash /usr/bin/clear-log` | status 126 setiap kali (binary ELF) → log tak pernah clear |
| 4 | `"loglevel": "info"` | error.log naik 656 B/s (54 MB/hari) |
| 5 | tun MTU 1500, tiada `mssfix` | retransmit 0.67% (1,386,748), RX dropped 157k |
| 6 | journald tak dicap | /var/log/journal 339–448 MB |
| 7 | Auto-delete expired tak jalan | User expired masih boleh connect |
| 8 | `/etc/crontab` ada `0 1 delete`, `0 2 xp`, `0 3 /usr/bin/xp`, `0 4 /usr/bin/delete` | Ada pada KEDUA-DUA VPS. Di VPS-1 tidur sebab cron tak dipasang — bahaya kalau cron dipasang. |

## Pengesahan (dah diuji pada VPS hidup)

- `bash -n` semua script: OK
- `--dry-run` pada VPS-1 & VPS-2: laporan tepat, tiada perubahan
- Larian sebenar pada VPS-1 & VPS-2: berjaya
- **Larian kedua: SIFAR perubahan (idempotent)**
- `systemctl restart xray.service` selepas fix: 2 proses sahaja, port 443 tunggal
- `service xray restart` (cara binary ELF panggil): 2 proses sahaja
- Payload tertanam diuji: fail dibuang → fixer tulis semula (md5 sama, py_compile OK)
- `xp-autodel.py --guard-only`: senyap (tiada false positive)
- Customer masih connect selepas semua restart (270 sesi established)
