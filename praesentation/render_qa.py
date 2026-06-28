#!/usr/bin/env python3
"""QA-Renderer: PPTX -> PDF (LibreOffice) -> PNG (PyMuPDF), zur visuellen Pruefung.

Aufruf:  python render_qa.py [1,5,7]   (Folien-Nummern, 1-basiert; ohne Argument alle)
PNGs landen in /tmp/pptx_work/qa_<nn>.png
"""
import sys, os, subprocess

PPTX = "/Users/johannesnguyen/Documents/doku/Praesentaion_Nguyen_Johannes.pptx"
OUT  = "/tmp/pptx_work"
SOFFICE = "/Applications/LibreOffice.app/Contents/MacOS/soffice"

os.makedirs(OUT, exist_ok=True)
pdf = os.path.join(OUT, os.path.splitext(os.path.basename(PPTX))[0] + ".pdf")
if os.path.exists(pdf):
    os.remove(pdf)

subprocess.run([SOFFICE, "--headless", "--convert-to", "pdf",
                "--outdir", OUT, PPTX], check=True)

import fitz
doc = fitz.open(pdf)
which = None
if len(sys.argv) > 1:
    which = {int(x) for x in sys.argv[1].split(",")}
for i in range(len(doc)):
    if which and (i+1) not in which:
        continue
    doc[i].get_pixmap(dpi=110).save(os.path.join(OUT, f"qa_{i+1:02d}.png"))
    print(f"  qa_{i+1:02d}.png")
