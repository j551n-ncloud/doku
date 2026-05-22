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
- PBS → SMTP (DKFZ-No-Reply Mailrelay)C
- PBS → prometheus 
- Separater Backup-Server + TSM/Tape (bleibt parallel)
> ANTWORT (Korrekturen / Ergänzungen): habe ergänzt

### 1.2 Netzwerk-/VLAN-Diagramm (empfohlen, PlantUML)

- LACP-Bond geht zu welchem Switch / welcher Switch-Paar?
> ANTWORT: sehe cabling1.svg cabling2.svg

- An welche VLANs ist der PBS angebunden? (nur server, oder auch andere?)
> ANTWORT:ServerS

### 1.3 Storage-Layout-Schema (empfohlen, PlantUML/TikZ)

Bestätigung: 2× Disk RAID 1 für System, 6×4 TB RAID 5 für Datastore?
Konkretes Modell der Disks?
> ANTWORT:IBM ST4000nM033 4tb 

### 1.4 Screenshots (musst du machen, PNG ~1600 px Breite, Geheimnisse schwärzen)

Welche willst du beisteuern? (`[x]` ankreuzen)
- [x] PBS Web-UI Dashboard
- [x] PBS Datastore-Detailansicht (Verify/Prune/Belegung)
- [x] PVE Storage-Konfiguration (PBS-Eintrag, Token geschwärzt)
- [x] PVE Backup-Job-Konfiguration (Beispiel kritisch)
- [x] PVE Restore-Dialog (File-Restore oder VM-Restore)
- [x] PBS LDAP-Realm-Konfiguration


---

## 2 · Analysephase (03)

### 2.1 Restore-Pain-Points der bisherigen Lösung

- Wie oft wurden zuletzt Restores gemacht?
> ANTWORT:von kritischen vm 2 mal am tag

- Wie lange dauert ein typischer Restore aus TSM/Tape?
> ANTWORT: 2-6 minuten auf local storage von Nodes, neue vxrail nodes haben keinen localen storage

- Gab es Fehlschläge / unvollständige Restores?
> ANTWORT: ja bei migration von großen vms auf andere nodes und wenn backup storage voll ist dann. oder vxrails

- Bekannte Probleme mit dem Ceph-RBD-Backup?
> ANTWORT: schreibe um backups werden auf local storage gemacht nicht ceph rbd

### 2.2 Wirtschaftlichkeit – echte Zahlen

Aktuell stehen Platzhalter (25 €/h Azubi, 80 €/h Senior, 200 € Strom).

- Stundensatz Azubi am DKFZ?
> ANTWORT: idk

- Stundensatz Frank Thommen (Betreuung)?
> ANTWORT:idk

- Strom-/Standkosten x3755 (Schätzung pro Monat reicht)?
> ANTWORT:idk

- Platzhalter beibehalten oder durch echte Zahlen ersetzen?
> ANTWORT:ja behalten vorerst

---

## 3 · Entwurfsphase (04)

### 3.1 Retention Test-VMs

- Frequenz (z. B. 1×/Tag, 1×/Woche, gar nicht)?
> ANTWORT:2 mal am tag

- Wie viele Backups aufbewahren?
> ANTWORT: 3

- VMs/CTs, die explizit **nicht** gesichert werden?
> ANTWORT:idk muss nur aufsetzen

### 3.2 Backup-Konzept – Detailpunkte

- Client-seitige Verschlüsselung der Backups gewünscht?
> ANTWORT:nicht in scope

- Bandwidth-Limit zwischen PVE und PBS?
> ANTWORT: 10 gig

- Verify-Job-Frequenz (z. B. wöchentlich)?
> ANTWORT: ja

---

## 4 · Implementierung (05)

### 4.1 CLI-Snippets zum Reinpasten (werden zu lstlisting)

#### Datastore anlegen
```
PASTE: per webui bild kommt 
```

#### LDAP-Realm-Konfiguration (UI-Werte oder /etc/proxmox-backup/domains.cfg)
```
PASTE: pam: pam
        comment Linux PAM standard authentication
        type pam

pbs: pbs
        comment Proxmox Backup authentication server
        type pbs

ad: dkfz-heidelberg.de
        base-dn DC=ad,DC=dkfz-heidelberg,DC=de
        bind-dn ldap@ad.dkfz-heidelberg.de
        default true
        filter (&(objectClass=user)(memberOf=CN=ODCF-SysAdmins,OU=Kst-W610,OU=Fsp-W,OU=DKFZ,DC=ad,DC=dkfz-heidelberg,DC=de))
        mode ldaps
        port 636
        server1 ldap1.dkfz-heidelberg.de
        sync-attributes email=mail,firstname=givenName,lastname=sn
        user-classes user
```

#### API-Token anlegen
```
PASTE:kann bild schicken
```

#### PVE Storage-Eintrag (/etc/pve/storage.cfg)
```
PASTE:root@odcf-fs04:~# cat /etc/proxmox-backup/datastore.cfg 
datastore: backup
        path /mnt/datastore/backup
```

#### Beispiel-Backup-Job
```
PASTE:bild kommt 
```

#### LACP / Netzwerk-Konfig (/etc/network/interfaces)
```
PASTE:
cat /etc/network/interfaces
auto lo
iface lo inet loopback

iface nic0 inet manual
iface nic1 inet manual
iface nic2 inet manual
iface nic3 inet manual

auto nic4
iface nic4 inet manual

auto nic5
iface nic5 inet manual

auto bond0
iface bond0 inet static
        address 10.131.196.78/22
        gateway 10.131.196.97
        bond-slaves nic4 nic5
        bond-miimon 100
        bond-mode 802.3ad
        bond-xmit-hash-policy layer3+4
        bond-lacp-rate fast

source /etc/network/interfaces.d/*
```

### 4.2 Konkrete Namen

- Datastore-Name im PBS?
> ANTWORT:see above

- API-Token-Name (z. B. `pve@pbs!backup`)?
> ANTWORT:

- Storage-Name im PVE?
> ANTWORT:see above

- LDAP-Realm-Name?
> ANTWORT:see above

- E-Mail-Empfänger für PBS-Benachrichtigungen?
> ANTWORT:später

- SMTP-Relay des DKFZ (Hostname)?
> ANTWORT:später

---

## 5 · Einführungsphase / Übergabe (07)

### 5.1 An wen wird übergeben?

- Welches Team / welche Personen?
> ANTWORT:Stefan Becker

- Wer bekommt Admin-Zugänge (PBS, API-Token, root)?
> ANTWORT:memberOf=CN=ODCF-SysAdmins

### 5.2 Was wird übergeben?

- Root-Passwort – über welches Vault (KeePass / Bitwarden / …)?
> ANTWORT:Bitwarden

- API-Token-Geheimnisse – wie übergeben?
> ANTWORT:neu gemacht is blueprint

- Betriebs-Doku-Link?
> ANTWORT:muss gemacht werden. 

### 5.3 Schulung / Einweisung

- Findet eine Einweisung statt? Termin, Dauer?
> ANTWORT:nein nur DOku

- Inhalte (Stichpunkte)?
> ANTWORT:

### 5.4 Parallelbetrieb

- TSM/Tape bleibt aktiv? Wenn ja, wie lange?
> ANTWORT:ja als backup von PBShost 

- Ceph-RBD-Backup: abschalten oder parallel?
> ANTWORT:abschalten

- Geplanter Stichtag für Komplettumstellung?
> ANTWORT:blueprint

---

## 6 · Dokumentation (08)

### 6.1 Wo liegt die Betriebs-Doku?

- Plattform (Confluence / DKFZ-Wiki / Markdown im Git / …)?
> ANTWORT:DOKU-WIki

- Falls Wiki/Confluence: Space + Seitentitel oder Link?
> ANTWORT:noch nicht 

- Falls Git: Repo + Pfad?
> ANTWORT:noch nicht 

### 6.2 Kapitelstruktur der Betriebs-Doku

`[x]` ankreuzen, was drin ist; eigene Kapitel ergänzen.
- [x] Übersicht / Architektur
- [x] Hardware-Setup (x3755, RAID, SFP/LACP)
- [x] Installation PBS 4
- [x] LDAP-Anbindung
- [x] Anbindung an PVE (rootpassword, Fingerprint)
- [x] Datastore-Verwaltung (Anlegen, Verify, Prune)
- [x] Backup-Jobs (kritisch / Test)
- [x] Restore-Verfahren (File / ganze VM)
- [x] Monitoring / CheckMK
- [x] Troubleshooting / FAQ
- [x] Übergabe / Zuständigkeiten

Eigene Ergänzungen:
> ANTWORT:

### 6.3 Adressaten

> ANTWORT:????

### 6.4 Anhang-Auszug

Welche 1–2 Seiten aus der Betriebs-Doku sollen in den Anhang
(`Anhang/AnhangAdminDoku.tex`)? Vorschlag: 1× Restore-Szenario +
1× Job-Beispielkonfiguration.
> ANTWORT: würde alle machen kommt noch .

---

## 7 · Anhang Lastenheft

- Variante A (Antrag-Punkte als Aufzählung übernehmen) oder
  Variante B (eigene Anforderungsliste)?
> ANTWORT:müssen wir erstellen

Falls Variante B – Anforderungsliste hier rein:
```
PASTE:
```

- Wurde mit Frank ein formales Lastenheft besprochen?
> ANTWORT:nein

---

## 8 · Anhang Betriebs-Doku-Auszug

Stichpunkte für den Auszug – `[x]` ankreuzen:
- [x] Datastore anlegen (CLI-Beispiel)
- [x] Backup-Job-Definition
- [x] Restore einer einzelnen Datei
- [x] Restore einer ganzen VM
- [x] Verify-Job manuell starten
- [x] Prune-Logik debuggen
- [x] Was tun bei vollem Datastore

Eigener Vorschlag:
> ANTWORT: mache die noch füge sie dann hinten dran.

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
> ERLEDIGT? (ja / nein / nicht nötig): mache ich noch 

- Untertitel auf dem Deckblatt: „Einrichtung eines Proxmox Backup
  Servers und Integration in die ODCF PVE-Umgebung" – passt?
> ANTWORT:ja

- „Summer 2026" auf „Sommer 2026" ändern?
> ANTWORT:ja

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
