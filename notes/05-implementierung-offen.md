# 05 – Implementierungsphase: offene Punkte

Aktuell ist alles textuell beschrieben. Code-Listings würden die
Implementierung greifbarer machen.

## 1. CLI-Befehle / Konfigurationen

Wenn du die wichtigsten Befehle oder Config-Snippets hier reinpastest,
übertrage ich die als `\begin{lstlisting}`-Blöcke in die LaTeX-Doku.

### Datastore-Anlage (proxmox-backup-manager datastore create …)
```
PASTE:
```

### LDAP-Realm-Konfiguration (relevante Felder aus /etc/proxmox-backup/domains.cfg oder UI-Werte)
```
PASTE:
```

### API-Token-Anlage (proxmox-backup-manager user generate-token …)
```
PASTE:
```

### Storage-Eintrag im PVE (/etc/pve/storage.cfg)
```
PASTE:
```

### Beispiel-Backup-Job (vzdump / Backup-Job-Definition aus dem PVE-UI)
```
PASTE:
```

### LACP / Network-Konfiguration (/etc/network/interfaces)
```
PASTE:
```

## 2. Konkrete Werte

- Name des Datastores im PBS?
  > ANTWORT:

- Name des API-Tokens (z. B. `pve@pbs!backup`)?
  > ANTWORT:

- Name des Storage-Eintrags im PVE?
  > ANTWORT:

- LDAP-Realm-Name?
  > ANTWORT:

- E-Mail-Empfänger für PBS-Benachrichtigungen?
  > ANTWORT:

- SMTP-Relay des DKFZ (Hostname)?
  > ANTWORT:
