# 04 – Entwurfsphase: offene Punkte

## 1. Retention für Test-VMs

Für kritische VMs steht: 2× täglich, `keep-last=3`.
Für Test-VMs ist die Retention noch offen.

- Wie oft sollen Test-VMs gesichert werden?
  (z. B. 1× täglich, 1× wöchentlich, gar nicht?)
  > ANTWORT:

- Wie viele Backups aufbewahren?
  > ANTWORT:

- Gibt es VMs/CTs, die explizit **nicht** gesichert werden sollen?
  > ANTWORT:

## 2. Netzwerk-/Architekturdiagramm

Ein PlantUML-Diagramm der Architektur wäre nett (PVE-Cluster ↔ PBS
↔ TSM/Tape). Soll ich eins anlegen?

- Diagramm gewünscht?  (ja / nein / später)
  > ANTWORT:

- Falls ja: stimmen die VLAN-Namen so?
  server / cluster / external / ceph
  > ANTWORT:

## 3. Backup-Konzept – sonstige Punkte

- Verschlüsselung der Backups gewünscht (PBS unterstützt
  client-seitige Verschlüsselung)?
  > ANTWORT:

- Bandwidth-Limit zwischen PVE und PBS nötig (damit Backups den
  Produktivbetrieb nicht stören)?
  > ANTWORT:

- Wie oft sollen Verify-Jobs laufen (z. B. wöchentlich / monatlich)?
  > ANTWORT:
