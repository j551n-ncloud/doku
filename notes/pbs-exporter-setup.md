## PBS Exporter auf `odcf-fs04`

Prometheus-Exporter für Proxmox Backup Server, installiert direkt auf dem PBS-Host via systemd.

### Übersicht

| | Wert |
|---|---|
| Host | `odcf-fs04` |
| PBS-Version | 4.2 |
| Exporter | [natrontech/pbs-exporter](https://github.com/natrontech/pbs-exporter) v0.8.0 |
| Port | `9100` (TCP) |
| Metrics-Pfad | `/metrics` |
| Service | `prometheus-pbs-exporter.service` (enabled, auto-start) |
| Run-User | `pbs-exporter` (system user, nologin) |
| Status | ✅ läuft, `pbs_up = 1` |

> ⚠️ Hinweis: Port `9100` ist eigentlich der Default von `node_exporter`. Aktuell nicht relevant, da das PBS-Dashboard die OS-Metriken abdeckt — falls später doch `node_exporter` dazukommen soll, muss einer der beiden den Port wechseln (pbs-exporter Default wäre `10019`).

### Dateien auf dem Host

```
/opt/pbs-exporter/
├── pbs-exporter-linux-amd64        # Binary (entpackt aus Release-Tarball)
├── pbs-exporter_v0.8.0_linux_amd64.tar.gz
├── CHANGELOG.md
├── LICENSE
└── README.md

/etc/pbs-exporter.env               # Environment / Credentials (0640, root:pbs-exporter)
/etc/systemd/system/prometheus-pbs-exporter.service
```

### `/etc/pbs-exporter.env`

```ini
PBS_API_TOKEN=<secret>
PBS_API_TOKEN_NAME=pbs-exporter
PBS_USERNAME=root@pam
PBS_ENDPOINT=https://odcf-fs04:8007
PBS_INSECURE=true
PBS_LISTEN_ADDRESS=:9100
```

Token-ID auf PBS-Seite: `root@pam!pbs-exporter` (Privilege Separation = Yes, eigenständige Permission gesetzt).

### `/etc/systemd/system/prometheus-pbs-exporter.service`

```ini
[Unit]
Description=Prometheus PBS Exporter
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=pbs-exporter
Group=pbs-exporter
EnvironmentFile=/etc/pbs-exporter.env
ExecStart=/opt/pbs-exporter/pbs-exporter-linux-amd64
Restart=on-failure
RestartSec=5s

NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true

[Install]
WantedBy=multi-user.target
```

### PBS-seitige Konfiguration

Im PBS-Web-UI (`https://odcf-fs04:8007`) gesetzt:

1. **API-Token** `root@pam!pbs-exporter` erstellt unter
   *Configuration → Access Control → API Token*.
2. **Permission** für den Token gesetzt unter
   *Configuration → Access Control → Permissions → Add → API Token Permission*:
   - Path: `/`
   - API Token: `root@pam!pbs-exporter`
   - Role: `Audit`
   - Propagate: ✓

Ohne Schritt 2 lieferte der Exporter HTTP 403 bei jedem authentifizierten Call (`pbs_up = 0`, nur `pbs_version` sichtbar).

### Installation (was gemacht wurde)

```bash
# 1. Binary holen und entpacken
mkdir -p /opt/pbs-exporter
cd /opt/pbs-exporter
wget https://github.com/natrontech/pbs-exporter/releases/download/v0.8.0/pbs-exporter_v0.8.0_linux_amd64.tar.gz
tar xfvz pbs-exporter_v0.8.0_linux_amd64.tar.gz
chmod +x /opt/pbs-exporter/pbs-exporter-linux-amd64

# 2. Service-User
useradd -r -s /sbin/nologin pbs-exporter

# 3. Env-File schreiben + locken
cat > /etc/pbs-exporter.env <<'EOF'
PBS_API_TOKEN=<secret>
PBS_API_TOKEN_NAME=pbs-exporter
PBS_USERNAME=root@pam
PBS_ENDPOINT=https://odcf-fs04:8007
PBS_INSECURE=true
PBS_LISTEN_ADDRESS=:9100
EOF
chown root:pbs-exporter /etc/pbs-exporter.env
chmod 640 /etc/pbs-exporter.env

# 4. Systemd-Unit (siehe oben) schreiben

# 5. Starten
systemctl daemon-reload
systemctl enable --now prometheus-pbs-exporter.service
```

### Verifikation

```bash
# Service-Status
systemctl status prometheus-pbs-exporter.service

# Direktcheck der Metriken
curl -s http://localhost:9100/metrics | grep -E '^pbs_(up|version)'
# Erwartet:
#   pbs_up 1
#   pbs_version{...,version="4.2"} 1

# Token gegen PBS-API testen (Debugging)
curl -k -H "Authorization: PBSAPIToken=root@pam!pbs-exporter:<secret>" \
  https://odcf-fs04:8007/api2/json/status/datastore-usage
```

### Verfügbare Metriken (Auszug)

Funktionierende Metriken auf PBS 4.2 (offiziell ist nur 3.x getestet — 4.2 läuft aber problemlos):

- **Datastore:** `pbs_size`, `pbs_used`, `pbs_available` (Label: `datastore`)
- **Snapshots:** `pbs_snapshot_count`, `pbs_snapshot_vm_count`, `pbs_snapshot_vm_last_timestamp`, `pbs_snapshot_vm_last_verify` (Labels: `datastore`, `namespace`, `vm_id`, `vm_name`)
- **Host:** `pbs_host_cpu_usage`, `pbs_host_memory_*`, `pbs_host_swap_*`, `pbs_host_disk_*` (root-FS), `pbs_host_load{1,5,15}`, `pbs_host_io_wait`, `pbs_host_uptime`
- **Subscription:** `pbs_host_subscription_status`, `pbs_host_subscription_info`, `pbs_host_subscription_due_timestamp_seconds`
- **Meta:** `pbs_up`, `pbs_version`

### Firewall (firewalld)

Konfiguriert mit `firewalld`, Default-Zone `public`. Endzustand:

```
services: dhcpv6-client ssh
ports:    8007/tcp 9100/tcp
rich rules: (keine)
```

| Port / Service | Scope | Zweck |
|---|---|---|
| `ssh` (22/tcp) | offen | Adminzugang |
| `8007/tcp` | offen | PBS Web-UI & Backup-Clients |
| `9100/tcp` | offen | pbs-exporter Metrics (Prometheus-Scrape) |
| `dhcpv6-client` | offen | Default |

Wichtige Punkte:
- `cockpit`, `http`, `https` wurden bewusst entfernt.
- SSH war beim ersten Härten kurz mit-entfernt worden und wurde danach wieder freigegeben — bei künftigen Änderungen daran denken, sonst Lockout.
- Port `9100` ist aktuell **weltweit offen**. Wenn das später härter abgesichert werden soll, Port-Eintrag entfernen und durch Rich-Rule mit `source address=<prometheus-ip>/32` ersetzen.

Befehle, die den Endzustand erzeugen (idempotent):

```bash
set -e
systemctl enable --now firewalld
firewall-cmd --set-default-zone=public

# Unerwünschte Default-Services entfernen (nicht-fatal, falls nicht aktiv)
for svc in cockpit http https; do
  firewall-cmd --permanent --zone=public --remove-service=$svc || true
done

# SSH offen halten
firewall-cmd --permanent --zone=public --add-service=ssh

# PBS Web-UI / Backup-Clients
firewall-cmd --permanent --zone=public --add-port=8007/tcp

# pbs-exporter
firewall-cmd --permanent --zone=public --add-port=9100/tcp

firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

### Offen / nächste Schritte (Prometheus-Seite)

Auf dem Prometheus-Host:

1. **Scrape-Job** in `prometheus.yml`:
   ```yaml
   scrape_configs:
     - job_name: pbs
       static_configs:
         - targets: ['odcf-fs04:9100']
           labels:
             instance: odcf-fs04
   ```
2. **Grafana-Dashboard** importieren aus
   [`grafana-dashboard/`](https://github.com/natrontech/pbs-exporter/tree/main/grafana-dashboard) im Repo.

### Nützliche PromQL-Queries

```promql
# Datastore-Füllgrad in %
100 * pbs_used / pbs_size

# Alter des letzten Backups pro VM (Stunden)
(time() - pbs_snapshot_vm_last_timestamp) / 3600

# Alert: Verify fehlgeschlagen
pbs_snapshot_vm_last_verify == 0

# Alert: Backup älter als 26h (verpasstes Daily)
(time() - pbs_snapshot_vm_last_timestamp) > 26 * 3600
```

### Troubleshooting-Notizen

- **HTTP 403** → Token hat keine Permission. Token in PBS hat Privilege Separation = Yes, daher muss die Permission explizit auf den Token gesetzt werden, nicht auf `root@pam`.
- **`pbs_up = 0`, `pbs_version` da** → Public-Endpoint funktioniert, authentifizierte Calls schlagen fehl → fast immer Permission-Problem (siehe oben).
- **Debug-Logging** an/aus: `PBS_LOGLEVEL=debug` in `/etc/pbs-exporter.env`, danach Service restart. Loggt u.a. das Token im Klartext — nach dem Debuggen wieder entfernen.
- **Service-Logs:** `journalctl -u prometheus-pbs-exporter.service -f`
