# Sprechertext zur Abschlusspräsentation

Proxmox Backup Server bei der ODCF am DKFZ
Johannes Nguyen, Fachinformatiker Systemintegration

Richtwert: rund 15 Minuten, etwa 1 Minute pro Inhaltsfolie. Die Texte sind als
Stichwort-Skript gedacht, nicht zum Wort-für-Wort-Ablesen.

---

## Folie 1: Titel

Guten Tag, mein Name ist Johannes Nguyen, ich bin Auszubildender zum
Fachinformatiker für Systemintegration am DKFZ. Ich stelle Ihnen heute mein
Abschlussprojekt vor: die Einrichtung eines dedizierten Proxmox Backup Servers
bei der ODCF. In den nächsten rund 15 Minuten zeige ich Ihnen die Ausgangslage,
meine Lösung und das Ergebnis.

## Folie 2: Gliederung

Kurz zum Ablauf: Zuerst der technische und betriebliche Kontext, dann Planung
und Analyse, anschließend Entwurf und Umsetzung, und am Ende Abnahme, Fazit und
Ausblick.

## Folie 3: Technologischer Hintergrund

Damit wir die gleiche Sprache sprechen, kurz die vier Kerntechnologien.
Proxmox VE ist die Virtualisierungsplattform, auf der unsere virtuellen
Maschinen und Container laufen, bei uns auf sechs Knoten. Der Proxmox Backup
Server ist die eigentliche Backup-Lösung, er sichert inkrementell und
dedupliziert. Ceph ist das verteilte Primär-Storage des Clusters. Und der
Unterschied zwischen Hardware-RAID und ZFS wird später bei einer Entscheidung
wichtig, weil der eingesetzte Server nur Hardware-RAID kann.

## Folie 4: Unternehmen und Projektumfeld

Das DKFZ ist die größte biomedizinische Forschungseinrichtung Deutschlands, mit
Sitz in Heidelberg. Die ODCF ist der interne IT-Dienstleister und betreibt unter
anderem den Proxmox-Cluster mit rund 60 virtuellen Maschinen. Wichtig: es ist
ein internes Projekt, Auftraggeber und Auftragnehmer sind beide das DKFZ.
Mein Auftraggeber war Frank Thommen.

## Folie 5: Ausgangssituation und Projektziel

Die Ausgangslage links: Die Backups lagen nur lokal auf den Hypervisoren, und
die VxRail-Knoten hatten gar keinen lokalen Speicher. Primär- und
Sicherungsdaten lagen zusammen, es gab keine zentrale Verwaltung, keine
automatische Integritätsprüfung, und Restores über das Tape-System waren
langsam. Das Ziel rechts: ein dedizierter, zentraler Backup-Server mit
inkrementellen Backups, Monitoring und Dokumentation. Wichtig ist der Scope:
Es handelt sich um eine Blueprint-Instanz, also kein Ersatz der bestehenden
Sicherung, sondern eine Referenz für den späteren Produktivbetrieb.

## Folie 6: Projektplanung

Das Gesamtbudget lag bei 40 Stunden, davon maximal 8 Stunden für die
Dokumentation. Der Balken zeigt die Aufteilung auf die Phasen von der Analyse
bis zur Dokumentation. Das Vorgehen war iterativ, nach jeder Phase gab es eine
kurze Abstimmung mit dem Betreuer. Die Hardware war Bestandshardware, die
Software ist komplett Open Source, daher fielen keine Lizenzkosten an.

## Folie 7: Analysephase

Aus dem Projektantrag und der Ist-Analyse ergeben sich funktionale und
nicht-funktionale Anforderungen, links sehen Sie die wichtigsten. Bei der
Wirtschaftlichkeit komme ich auf rund 1.600 Euro Projektkosten, im Wesentlichen
Arbeitszeit, da Hardware und Software nichts kosten. Der Nutzen rechts: deutlich
schnellere Restores, zentrale Verwaltung und Integritätsprüfung. Schon ein
einziger vermiedener mehrstündiger Restore amortisiert das Projekt.

## Folie 8: Begründete Entscheidungen

Hier die vier zentralen Entscheidungen mit Begründung. PBS statt Veeam oder
Bacula: vom Auftraggeber vorgegeben, keine Lizenzkosten und nativ in PVE
integriert. Der IBM x3755 als Server: Bestandshardware, keine Beschaffung nötig.
Hardware-RAID 5 statt ZFS: Der Server kann nur Hardware-RAID, ZFS bräuchte
direkten Zugriff auf die Platten. Bei neuerer Hardware wäre ZFS die bevorzugte
Lösung. Und ext4 folgt zwingend aus der RAID-Entscheidung; die Integrität sichert
stattdessen der PBS-eigene Verify-Job.

## Folie 9: Entwurfsphase

Zur Architektur: Der Backup-Server hängt im server-VLAN am PVE-Cluster,
angebunden über zwei gebündelte 10-Gigabit-Leitungen. Die Authentifizierung läuft
über das DKFZ-LDAP, ergänzt um einen lokalen root-Zugang für den Notfall. Das
Monitoring erfolgt über den pbs-exporter und Prometheus, Benachrichtigungen per
E-Mail. Unten sehen Sie das Backup-Konzept: zwei Klassen, beide werden zweimal
täglich gesichert, aufgehoben werden jeweils die letzten drei Sicherungen.

## Folie 10: Implementierungsphase

Die Umsetzung erfolgte in vier Schritten. Zuerst die Hardware-Vorbereitung mit
RAID-Controller und Netzwerkkarte; hier gab es Mehraufwand durch den
RAID-Controller. Dann die Installation und Grundkonfiguration des Backup-Servers.
Anschließend der Datastore und die LDAP-Anbindung. Und zuletzt die Integration in
den PVE-Cluster sowie die Einrichtung der Backup-Jobs, die ich vorher mit einem
Test-Backup geprüft habe.

## Folie 11: Abnahme und Tests

Alle Tests gegen das Backup-Konzept waren erfolgreich: Backup-Job, LDAP-Login,
E-Mail-Benachrichtigung, Monitoring und die Trennung der Speicher. Besonders
wichtig waren die Restore-Tests: einzelne Dateien, eine ganze VM und ein
Container, alle erfolgreich wiederhergestellt. Die Integritätsprüfung über den
Verify-Job war ebenfalls erfolgreich. Die Abnahme hat Frank Thommen erteilt, und
die Restores waren deutlich schneller als über das alte Tape-System.

## Folie 12: Fazit, Soll-Ist-Vergleich

Im Soll-Ist-Vergleich habe ich insgesamt 34,5 statt der geplanten 40 Stunden
gebraucht, also leicht unter Budget. Mehraufwand gab es bei Beschaffung und
Installation, dafür war ich bei Konfiguration und Anbindung schneller, weil PBS
und PVE sehr gut toolunterstützt sind. Die Lessons Learned: Eine frühe Abstimmung
mit dem Netzwerkteam ist wichtig, Altbestands-Hardware begrenzt die Wahl des
Dateisystems, und eine gute Betriebsdokumentation ist genauso wertvoll wie die
eigentliche Umsetzung.

## Folie 13: Ausblick

Zum Ausblick in drei Horizonten. Kurzfristig kann auf Basis des Blueprints eine
produktive Instanz aufgesetzt und schrittweise migriert werden. Mittelfristig
sind eine Off-Site-Replikation und die Ablösung der Tape-Sicherung denkbar.
Langfristig ein vollautomatisiertes Monitoring und regelmäßige Restore-Tests als
Standard.

## Folie 14: Zusammenfassung

Zusammengefasst: Das Projektziel wurde erreicht, alle Tests sind bestanden, ich
bin im Zeitrahmen geblieben, die Dokumentation ist vollständig, und es gibt einen
klaren Mehrwert für die ODCF. Damit ist die Basis für den späteren
Produktivbetrieb gelegt.

## Folie 15: Vielen Dank

Vielen Dank für Ihre Aufmerksamkeit. Ich freue mich auf Ihre Fragen und das
Fachgespräch, zum Beispiel zum Backup-Konzept, zur Entscheidung Hardware-RAID
gegen ZFS oder zur LDAP-Anbindung.
