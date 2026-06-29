# Präsentation: Build- und QA-Skripte

Skripte zum Erzeugen und Nachbearbeiten der Datei
`../Praesentaion_Nguyen_Johannes.pptx` (IHK Abschlusspräsentation, DKFZ Corporate Design).

Die Folien wurden mit `python-pptx` programmatisch aufgebaut und in mehreren
Schritten verfeinert. Die einzelnen Skripte sind Patch-Skripte, die auf die
bestehende PPTX angewandt werden.

## Abhängigkeiten

```bash
python3 -m venv venv
source venv/bin/activate
pip install python-pptx pymupdf
# Fuer QA-Rendering zusaetzlich LibreOffice (soffice)
```

## Skripte (Reihenfolge der Anwendung)

| Skript | Zweck |
|--------|-------|
| `rebuild_slides_7_8_12.py` | Baut Folien 7 (Analyse), 8 (Entscheidungen), 12 (Fazit) sauber neu auf und entfernt En-/Em-Dashes deckweit |
| `slide4.py` | Baut Folie 4 (Unternehmen) neu, Projektrahmen als grösserer Block |
| `slide5.py` | Baut Folie 5 (Ausgangssituation/Projektziel) neu, gleichmässige Abstände, einheitliche Marker |
| `fix_slide12_hours.py` | Baut Folie 12 mit den echten Zahlen aus `Tabellen/Zeitnachher.tex` (40 h / 34,5 h / -5,5 h), konsistent zu Folie 14 |
| `renumber_sections.py` | Setzt die Abschnittsnummern der Inhaltsfolien auf 01..11 (passend zur Gliederung) |
| `normalize_footer.py` | Fusszeile vereinheitlichen: Balken navy, Text weiss |
| `add_notes.py` | Sprechernotizen zu allen 15 Folien |
| `render_qa.py` | QA: PPTX -> PDF -> PNG zur visuellen Kontrolle |

## QA

Nach jeder Änderung Folien rendern und visuell prüfen:

```bash
python render_qa.py 4,5,7,8,12
```

Pfade in den Skripten sind absolut auf dieses Repo (`/Users/.../doku`) gesetzt.
