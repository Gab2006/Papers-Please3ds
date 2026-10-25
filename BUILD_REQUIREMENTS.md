# Requisiti di Build — Papers, Please 3DS

Questa guida descrive tutti i prerequisiti software e di sistema necessari per compilare ed effettuare il packaging di **Papers, Please 3DS** nei formati `.cxi` (per emulatore) e `.cia` (per console reale).

---

## 1. Ambiente Python

- **Python**: Versione 3.8 o superiore (testato con Python 3.10+ / 3.13)
- **Librerie Python**:
  Installabili tramite il file [`requirements.txt`](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/requirements.txt):
  ```bash
  pip install -r requirements.txt
  ```
  - `Pillow` (richiesto da [`tools/generate_papers_please_assets.py`](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/tools/generate_papers_please_assets.py) per la generazione procedurale degli asset grafici e dei quotidiani).
  - Lo script principale di build ([`tools/build.py`](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/tools/build.py)) e lo script audio ([`tools/optimize_sounds.py`](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/tools/optimize_sounds.py)) utilizzano esclusivamente moduli della Standard Library di Python (`os`, `sys`, `struct`, `hashlib`, `shutil`, `subprocess`, `wave`).

---

## 2. Toolchain Nintendo 3DS

Per completare il packaging RomFS, CXI e CIA sono necessari i seguenti binari:

| Tool | Scopo | Dove si trova |
|---|---|---|
| `mkromfs3ds.exe` | Compressione del filesystem RomFS di livello 3 | `C:\devkitPro\tools\bin\mkromfs3ds.exe` (installato con devkitPro) |
| `makerom.exe` | Packaging del file `.cia` finale | Incluso in [`tools/makerom.exe`](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/tools/makerom.exe) o in `devkitPro` |
| `3dstool.exe` | Compressione/decompressione BLZ per la patch `code.bin` | Incluso in [`tools/3dstool.exe`](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/tools/3dstool.exe) |

> [!NOTE]
> `makerom.exe` e `3dstool.exe` sono già inclusi nella cartella [`tools/`](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/tools/).
> L'unico tool esterno di sistema richiesto per il build completo è **devkitPro** (specificamente `mkromfs3ds.exe` situato nel percorso predefinito `C:\devkitPro\tools\bin\mkromfs3ds.exe`).

---

## 3. Esecuzione della Build

Una volta soddisfatti i requisiti:

### Su Windows (One-Click)
Fai doppio clic o esegui da prompt:
```bat
build.bat
```

### Da riga di comando (qualsiasi terminale)
```bash
python tools/build.py
```

I file generati saranno disponibili nella root del progetto:
- [`Papers Please.cxi`](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/Papers%20Please.cxi) (Emulatore Citra / Lime3DS)
- [`Papers Please.cia`](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/Papers%20Please.cia) (Console Nintendo 3DS con FBI / Luma3DS)
