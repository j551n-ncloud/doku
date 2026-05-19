README — Antrag anpassen (Kurzanleitung)
=====================================

Zweck
-----
Diese Anleitung zeigt dir schnell, wie du den vorhandenen Projektantrag so anpasst, dass er deine persönlichen Daten, Betriebsdaten und Projektdetails enthält, und wie du die Änderungen lokal prüfst und versionierst.

Wichtig: Diese Schritte verändern nur die LaTeX‑Quellen im Repo. Kompilieren erfolgt per `kompiliere_mit_Docker.sh` (Docker erforderlich).

Schritte zum Anpassen
---------------------

1) Arbeitsbranch anlegen (sicher arbeiten)

```bash
cd /path/to/repo
git checkout -b feature/mein-antrag
```

2) Persönliche und Betriebsdaten ändern

- Öffne `Meta.tex` und `Deckblatt.tex` in deinem Editor.
- Wichtige Variablen in `Meta.tex` (ersetze die Werte): `\autorName`, `\autorAnschrift`, `\autorOrt`, `\projektStart`, `\projektEnde`, `\betriebName`, `\betriebAnschrift`, `\betriebOrt`, `\betriebLogo`.
- In `Deckblatt.tex` findest du Layout und ggf. Identnummern; passe `Prüflingsnummer` und `Ansprechpartner` an.

3) Projektbeschreibung übernehmen/anpassen

- Wenn du Inhalte aus einer Word/XML‑Datei (z.B. `Projektantrag_PBS_ODCF (2).xml`) übernommen hast, prüfe `Inhalt/02-Projektplanung.tex` und entferne oder passe importierte Abschnitte.
- Suche nach Abschnittsüberschriften `1. Projektbezeichnung` und `2. Projektbeschreibung` und editiere den Text nach Bedarf.

4) Tabellen und Zeitplanung

- Die Tabelle `Tabellen/Projektphasen.tex` enthält die Zeitplanung. Du kannst dort Stunden und Beschreibungen editieren.
- Wenn du die Tabelle im Fließtext statt als separate Datei haben willst, kopiere den LaTeX‑Block direkt in `Inhalt/02-Projektplanung.tex`.

5) Bilder/Logos

- Logos liegen im Ordner `Bilder/` oder als relativer Pfad in `\betriebLogo` definiert. Ersetze die Datei oder aktualisiere den Pfad und passe in `Deckblatt.tex` `width`/`height` an.

6) Kompilieren (lokal, Docker)

Erzeuge ein Test‑PDF mit dem beiliegenden Skript (PlantUML/Mermaid optional):

```bash
# ohne PlantUML/Mermaid (schneller)
COMPILE_PUML=no COMPILE_MERMAID=no OPEN_PDF=no bash ./kompiliere_mit_Docker.sh

# mit PlantUML (falls nötig)
COMPILE_PUML=yes COMPILE_MERMAID=no OPEN_PDF=no bash ./kompiliere_mit_Docker.sh
```

Die Ausgabe landet in `out/Projektdokumentation_Schmidberger_Fabian.pdf` (oder einem anderen Namen, siehe `Meta.tex`). Öffne die Datei und prüfe Deckblatt, Ansprechpartner, Identnummer, Daten und die Zeitplanung.

7) Änderungen committen und pushen

```bash
git add Meta.tex Deckblatt.tex Inhalt/02-Projektplanung.tex Tabellen/Projektphasen.tex Bilder/*
git commit -m "docs(antrag): passe Antrag auf Johannes Nguyen an"
git push -u origin feature/mein-antrag
```

Tipps / häufige Probleme
------------------------
- Fehlende Pakete: Das Docker‑Image enthält eine vollständige TeXLive; falls ein Paket fehlt, öffne Log (`out/*.log`) und installiere lokal oder ergänze Docker‑Image.
- Logos zu groß/klein: Verwende `\includegraphics[width=0.6\textwidth]{...}` oder `height=`.
- PlantUML/Mermaid: Wenn Diagramme nicht gerendert werden, setze `COMPILE_PUML=no` / `COMPILE_MERMAID=no` und teste die LaTeX‑Kompilierung ohne Diagramme, bis die Textteile korrekt sind.

Wenn du möchtest, erledige ich folgende Hilfen:
- Ich übertrage deine persönlichen Daten aus einer Vorlage in `Meta.tex`.
- Ich öffne und prüfe das erzeugte PDF, zeige dir die relevanten Stellen.
- Ich erstelle ein sauberes Branch + Merge Request auf deiner Remote (falls gewünscht).

---
Datei: README_ANTRAG_ANPASSEN.md
