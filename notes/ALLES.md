# Alles, was noch fehlt – zum Ausfüllen

Ein einziges Dokument mit allen offenen Fragen.
Antworte direkt unter den `> ANTWORT:` Zeilen oder im jeweiligen
Paste-Block. Du kannst `skip` / `später` schreiben, wenn etwas nicht
relevant ist.

`aufraeumen.md` (separate Datei) listet zusätzlich die Reste vom
alten Beispielprojekt – einfach `[x]` setzen, was raus darf.

---

## 1 · Bilder & Diagramme

### 1.1 Architektur-/Komponentendiagramm (empfohlen, mache ich als PlantUML)

Stimmen die Verbindungen so?
- PVE-Cluster (6 Knoten) → PBS `odcf-fs04` (Backup-Traffic, server-VLAN)
- PBS → LDAP (DKFZ-Verzeichnis)
- PBS → SMTP (DKFZ-Mailrelay)
- PBS → CheckMK (oder umgekehrt: CheckMK monitoring → PBS?)
- Separater Backup-Server + TSM/Tape (bleibt parallel)
> ANTWORT (Korrekturen / Ergänzungen):

### 1.2 Netzwerk-/VLAN-Diagramm (empfohlen, PlantUML)

- LACP-Bond geht zu welchem Switch / welcher Switch-Paar?
> ANTWORT:

- An welche VLANs ist der PBS angebunden? (nur server, oder auch andere?)
> ANTWORT:

### 1.3 Storage-Layout-Schema (empfohlen, PlantUML/TikZ)

Bestätigung: 2× Disk RAID 1 für System, 6×4 TB RAID 5 für Datastore?
Konkretes Modell der Disks?
> ANTWORT:

### 1.4 Screenshots (musst du machen, PNG ~1600 px Breite, Geheimnisse schwärzen)

Welche willst du beisteuern? (`[x]` ankreuzen)
- [ ] PBS Web-UI Dashboard
- [ ] PBS Datastore-Detailansicht (Verify/Prune/Belegung)
- [ ] PVE Storage-Konfiguration (PBS-Eintrag, Token geschwärzt)
- [ ] PVE Backup-Job-Konfiguration (Beispiel kritisch)
- [ ] PVE Restore-Dialog (File-Restore oder VM-Restore)
- [ ] CheckMK Service-Übersicht für odcf-fs04
- [ ] PBS LDAP-Realm-Konfiguration
- [ ] Foto Server / SFP-Karte (eher nicht für IHK-Doku)

---

## 2 · Analysephase (03)

### 2.1 Restore-Pain-Points der bisherigen Lösung

- Wie oft wurden zuletzt Restores gemacht?
> ANTWORT:

- Wie lange dauert ein typischer Restore aus TSM/Tape?
> ANTWORT:

- Gab es Fehlschläge / unvollständige Restores?
> ANTWORT:

- Bekannte Probleme mit dem Ceph-RBD-Backup?
> ANTWORT:

### 2.2 Wirtschaftlichkeit – echte Zahlen

Aktuell stehen Platzhalter (25 €/h Azubi, 80 €/h Senior, 200 € Strom).

- Stundensatz Azubi am DKFZ?
> ANTWORT:

- Stundensatz Frank Thommen (Betreuung)?
> ANTWORT:

- Strom-/Standkosten x3755 (Schätzung pro Monat reicht)?
> ANTWORT:

- Platzhalter beibehalten oder durch echte Zahlen ersetzen?
> ANTWORT:

---

## 3 · Entwurfsphase (04)

### 3.1 Retention Test-VMs

- Frequenz (z. B. 1×/Tag, 1×/Woche, gar nicht)?
> ANTWORT:

- Wie viele Backups aufbewahren?
> ANTWORT:

- VMs/CTs, die explizit **nicht** gesichert werden?
> ANTWORT:

### 3.2 Backup-Konzept – Detailpunkte

- Client-seitige Verschlüsselung der Backups gewünscht?
> ANTWORT:

- Bandwidth-Limit zwischen PVE und PBS?
> ANTWORT:

- Verify-Job-Frequenz (z. B. wöchentlich)?
> ANTWORT:

---

## 4 · Implementierung (05)

### 4.1 CLI-Snippets zum Reinpasten (werden zu lstlisting)

#### Datastore anlegen
```
PASTE:
```

#### LDAP-Realm-Konfiguration (UI-Werte oder /etc/proxmox-backup/domains.cfg)
```
PASTE:
```

#### API-Token anlegen
```
PASTE:
```

#### PVE Storage-Eintrag (/etc/pve/storage.cfg)
```
PASTE:
```

#### Beispiel-Backup-Job
```
PASTE:
```

#### LACP / Netzwerk-Konfig (/etc/network/interfaces)
```
PASTE:
```

### 4.2 Konkrete Namen

- Datastore-Name im PBS?
> ANTWORT:

- API-Token-Name (z. B. `pve@pbs!backup`)?
> ANTWORT:

- Storage-Name im PVE?
> ANTWORT:

- LDAP-Realm-Name?
> ANTWORT:

- E-Mail-Empfänger für PBS-Benachrichtigungen?
> ANTWORT:

- SMTP-Relay des DKFZ (Hostname)?
> ANTWORT:

---

## 5 · Einführungsphase / Übergabe (07)

### 5.1 An wen wird übergeben?

- Welches Team / welche Personen?
> ANTWORT:

- Wer bekommt Admin-Zugänge (PBS, API-Token, root)?
> ANTWORT:

### 5.2 Was wird übergeben?

- Root-Passwort – über welches Vault (KeePass / Bitwarden / …)?
> ANTWORT:

- API-Token-Geheimnisse – wie übergeben?
> ANTWORT:

- Betriebs-Doku-Link?
> ANTWORT:

### 5.3 Schulung / Einweisung

- Findet eine Einweisung statt? Termin, Dauer?
> ANTWORT:

- Inhalte (Stichpunkte)?
> ANTWORT:

### 5.4 Parallelbetrieb

- TSM/Tape bleibt aktiv? Wenn ja, wie lange?
> ANTWORT:

- Ceph-RBD-Backup: abschalten oder parallel?
> ANTWORT:

- Geplanter Stichtag für Komplettumstellung?
> ANTWORT:

---

## 6 · Dokumentation (08)

### 6.1 Wo liegt die Betriebs-Doku?

- Plattform (Confluence / DKFZ-Wiki / Markdown im Git / …)?
> ANTWORT:

- Falls Wiki/Confluence: Space + Seitentitel oder Link?
> ANTWORT:

- Falls Git: Repo + Pfad?
> ANTWORT:

### 6.2 Kapitelstruktur der Betriebs-Doku

`[x]` ankreuzen, was drin ist; eigene Kapitel ergänzen.
- [ ] Übersicht / Architektur
- [ ] Hardware-Setup (x3755, RAID, SFP/LACP)
- [ ] Installation PBS 4
- [ ] LDAP-Anbindung
- [ ] Anbindung an PVE (API-Token, Fingerprint)
- [ ] Datastore-Verwaltung (Anlegen, Verify, Prune)
- [ ] Backup-Jobs (kritisch / Test)
- [ ] Restore-Verfahren (File / ganze VM)
- [ ] Monitoring / CheckMK
- [ ] Troubleshooting / FAQ
- [ ] Übergabe / Zuständigkeiten

Eigene Ergänzungen:
> ANTWORT:

### 6.3 Adressaten

> ANTWORT:

### 6.4 Anhang-Auszug

Welche 1–2 Seiten aus der Betriebs-Doku sollen in den Anhang
(`Anhang/AnhangAdminDoku.tex`)? Vorschlag: 1× Restore-Szenario +
1× Job-Beispielkonfiguration.
> ANTWORT:

---

## 7 · Anhang Lastenheft

- Variante A (Antrag-Punkte als Aufzählung übernehmen) oder
  Variante B (eigene Anforderungsliste)?
> ANTWORT:

Falls Variante B – Anforderungsliste hier rein:
```
PASTE:
```

- Wurde mit Frank ein formales Lastenheft besprochen?
> ANTWORT:

---

## 8 · Anhang Betriebs-Doku-Auszug

Stichpunkte für den Auszug – `[x]` ankreuzen:
- [ ] Datastore anlegen (CLI-Beispiel)
- [ ] Backup-Job-Definition
- [ ] Restore einer einzelnen Datei
- [ ] Restore einer ganzen VM
- [ ] Verify-Job manuell starten
- [ ] Prune-Logik debuggen
- [ ] Was tun bei vollem Datastore

Eigener Vorschlag:
> ANTWORT:

Schon vorhandene Snippets zum Reinpasten:
```
PASTE:
```

---

## 9 · Org / Meta / Deckblatt

### 9.1 Bestätigt

- Prüflingsnummer 888336 ✅
- Abgabetermin 26.05.2026 ✅
- Prüfungstermin: Summer 2026 ✅
- Adresse: Heinrich-Böll-Straße 28, 68723 Oftersheim ✅
- Betrieb: DKFZ ✅
- Ansprechpartner: Frank Beat Thommen ✅

### 9.2 Noch offen

- Eigene Unterschrift als PNG/PDF in `Bilder/Unterschrift.png` ablegen?
> ERLEDIGT? (ja / nein / nicht nötig):

- Untertitel auf dem Deckblatt: „Einrichtung eines Proxmox Backup
  Servers und Integration in die ODCF PVE-Umgebung" – passt?
> ANTWORT:

- „Summer 2026" auf „Sommer 2026" ändern?
> ANTWORT:

---

## 10 · Was du selbst machst (laut Absprache)

- `Inhalt/06-Abnahmephase.tex` – Abnahmetest, Restore-Tests, Abnahme
  durch Frank.
- `Inhalt/09-Fazit.tex` – Soll-/Ist-Vergleich, Lessons Learned, Ausblick
  (frühestens nach Projektende sinnvoll).

Wenn du willst, kann ich für beide ein detaillierteres Skelett mit
gezielten Stichpunkten schreiben – sag Bescheid.

---

## Workflow

1. Du füllst hier so viel aus, wie dir gerade passt.
2. Du sagst mir „mach mal Abschnitt X" (oder „alles übertragen").
3. Ich übertrage in LaTeX, committe, push.
