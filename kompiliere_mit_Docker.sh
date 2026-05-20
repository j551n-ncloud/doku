#!/usr/bin/env bash
set -euo pipefail

# kompiliere_mit_Docker.sh - Bash-Äquivalent von kompiliere_mit_Docker.ps1
# Usage:
#   COMPILE_PUML=yes OPEN_PDF=yes ./kompiliere_mit_Docker.sh
# If env vars not set, the script will ask interactively.

ROOT_DIR="$(pwd)"
PLANTUML_DIR="$ROOT_DIR/PlantUML"
ANHANG_DIR="$ROOT_DIR/Anhang"
# Relative output directory inside the repository (will be created if missing)
OUTDIR_REL="out"
OUTDIR="$ROOT_DIR/${OUTDIR_REL}"
TEXFILE="Projektdokumentation_Nguyen_Johannes"

# If the configured TEXFILE (without .tex) doesn't exist on disk,
# try a case-insensitive match, then fall back to any single
# .tex that contains a \documentclass declaration.
if [ ! -f "${ROOT_DIR}/${TEXFILE}.tex" ]; then
  echo "Hinweis: ${ROOT_DIR}/${TEXFILE}.tex nicht gefunden. Versuche Fallbacks..."
  # 1) case-insensitive filename match in repo root
  found=""
  for f in "${ROOT_DIR}"/*.tex; do
    [ -e "$f" ] || continue
    base=$(basename "$f" .tex)
    if [ "$(echo "$base" | tr '[:upper:]' '[:lower:]')" = "$(echo "$TEXFILE" | tr '[:upper:]' '[:lower:]')" ]; then
      TEXFILE="$base"
      found=1
      echo "Gefunden via case-insensitive Abgleich: $f"
      break
    fi
  done

  # 2) if still not found, search for a single .tex with \documentclass
  if [ -z "$found" ]; then
    # Use a POSIX-compatible way to populate the docs array (macOS bash lacks mapfile)
    docs=()
    while IFS= read -r line; do
      docs+=("$line")
    done < <(grep -RIl "\\\documentclass" --exclude-dir=.git --include="*.tex" "$ROOT_DIR" || true)
    if [ ${#docs[@]} -eq 1 ]; then
      TEXFILE=$(basename "${docs[0]}" .tex)
      echo "Gefunden Haupt-TeX: ${docs[0]} -> using ${TEXFILE}"
    elif [ ${#docs[@]} -gt 1 ]; then
      echo "Mehrere Kandidaten für Haupt-TeX gefunden:" >&2
      for c in "${docs[@]}"; do echo " - $c" >&2; done
      echo "Bitte setze TEXFILE in kompiliere_mit_Docker.sh oder rufe das Skript im richtigen Verzeichnis auf." >&2
      exit 1
    else
      echo "Kein geeignetes .tex mit \\documentclass gefunden und ${TEXFILE}.tex fehlt." >&2
      exit 1
    fi
  fi
fi

compile_puml() {
  echo "PlantUML: Suche .puml Dateien in ${PLANTUML_DIR}"
  shopt -s nullglob
  puml_files=("${PLANTUML_DIR}"/*.puml)
  if [ ${#puml_files[@]} -eq 0 ]; then
    echo "Keine .puml Dateien gefunden."
    return
  fi

  for f in "${puml_files[@]}"; do
    echo "Erzeuge SVG für $f"
    java -jar plantuml.jar -charset UTF-8 -svg "$f" || { echo "plantuml fehlgeschlagen für $f"; return 1; }
  done

  svg_files=("${PLANTUML_DIR}"/*.svg)
  if [ ${#svg_files[@]} -eq 0 ]; then
    echo "Keine SVG-Dateien erzeugt."
    return
  fi

  for s in "${svg_files[@]}"; do
    base="$(basename "$s" .svg)"
    pdfName="${ANHANG_DIR}/${base}.pdf"
    echo "Konvertiere $s -> $pdfName"
    inkscape --export-filename="${pdfName}" "$s" || { echo "inkscape fehlgeschlagen für $s"; return 1; }
  done

  echo "Entferne SVG-Dateien"
  for s in "${svg_files[@]}"; do
    rm -f "$s"
  done
}

# Entscheiden ob PlantUML kompiliert werden soll
if [ "${COMPILE_PUML-}" = "yes" ] || ( [ -z "${COMPILE_PUML-}" ] && (read -p "Sollen die PlantUML Diagramme kompiliert werden (y/n)? " ans && [ "$ans" = "y" ] ) ); then
  echo "Starte PlantUML-Kompilierung"
  compile_puml
else
  echo "PlantUML werden nicht kompiliert"
fi

# Optional: Mermaid Diagramme kompilieren
if [ "${COMPILE_MERMAID-}" = "yes" ] || ( [ -z "${COMPILE_MERMAID-}" ] && (read -p "Sollen die Mermaid Diagramme kompiliert werden (y/n)? " ansm && [ "$ansm" = "y" ] ) ); then
  echo "Starte Mermaid-Kompilierung"
  if [ -x "./tools/mermaid_compile.sh" ]; then
    ./tools/mermaid_compile.sh || { echo "Mermaid-Kompilierung fehlgeschlagen"; exit 1; }
  else
    echo "tools/mermaid_compile.sh nicht ausführbar oder nicht vorhanden"
  fi
else
  echo "Mermaid werden nicht kompiliert"
fi

# SVG-Bilder in Bilder/ vor dem LaTeX-Lauf zu PDFs konvertieren
# (z.B. cabling*.svg aus NetBox). Benötigt Inkscape im PATH.
if command -v inkscape >/dev/null 2>&1; then
  shopt -s nullglob
  for s in "${ROOT_DIR}/Bilder"/*.svg; do
    pdf="${s%.svg}.pdf"
    if [ ! -f "$pdf" ] || [ "$s" -nt "$pdf" ]; then
      echo "Konvertiere $s -> $pdf"
      inkscape --export-filename="$pdf" "$s" || { echo "inkscape fehlgeschlagen für $s"; exit 1; }
    fi
  done
  shopt -u nullglob
else
  echo "Hinweis: inkscape nicht im PATH; SVGs in Bilder/ werden nicht konvertiert."
fi

# LaTeX mit Docker (zweimal wie im Original)
mkdir -p "${OUTDIR}"

for i in 1 2; do
  echo "LaTeX-Durchlauf ${i} mit Docker (Ausgabe: ${OUTDIR_REL})"
  docker run -i --rm -w /data -v "${ROOT_DIR}:/data" texlive/texlive:latest latexmk "-g" "-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-pdf" "-outdir=./${OUTDIR_REL}" "${TEXFILE}" -f || { echo "latexmk fehlgeschlagen"; exit 1; }
  echo "Durchlauf ${i} beendet"
done

# Öffnen der PDF
if [ "${OPEN_PDF-}" = "yes" ] || ( [ -z "${OPEN_PDF-}" ] && (read -p "Soll die Datei geöffnet werden (y/n)? " ans2 && [ "$ans2" = "y" ] ) ); then
  pdfpath="${OUTDIR}/${TEXFILE}.pdf"
  if [ -f "$pdfpath" ]; then
    echo "Öffne $pdfpath"
    if command -v open >/dev/null 2>&1; then
      open "$pdfpath" || echo "Fehler beim Öffnen mit open"
    else
      echo "PDF befindet sich unter: $pdfpath"
    fi
  else
    # Versuch: falls PDF im Repository-Root liegt (ältere Ausführung), verschiebe sie in OUTDIR
    altpath="${ROOT_DIR}/${TEXFILE}.pdf"
    if [ -f "$altpath" ]; then
      echo "Verschiebe vorhandene PDF von $altpath nach ${OUTDIR}"
      mv "$altpath" "$OUTDIR/" || echo "Verschieben fehlgeschlagen"
      echo "PDF befindet sich jetzt unter: ${OUTDIR}/${TEXFILE}.pdf"
      if command -v open >/dev/null 2>&1; then
        open "${OUTDIR}/${TEXFILE}.pdf" || echo "Fehler beim Öffnen mit open"
      fi
    else
      echo "PDF ${pdfpath} nicht gefunden"
    exit 1
  fi
  fi
else
  echo "Script beendet ohne PDF-Öffnen"
fi
