# Build Requirements — Papers, Please 3DS

This guide details all software and system prerequisites required to build and package **Papers, Please 3DS** into `.cxi` (for emulators) and `.cia` (for physical consoles) formats.

---

## 1. Python Environment

- **Python**: Version 3.8 or higher (tested with Python 3.10+ / 3.13)
- **Python Libraries**:
  Installable via [`requirements.txt`](requirements.txt):
  ```bash
  pip install -r requirements.txt
  ```
  - `Pillow` (required by [`tools/generate_papers_please_assets.py`](tools/generate_papers_please_assets.py) for procedural generation of graphic assets and newspapers).
  - The main build script ([`tools/build.py`](tools/build.py)) and audio optimization script ([`tools/optimize_sounds.py`](tools/optimize_sounds.py)) use only Python Standard Library modules (`os`, `sys`, `struct`, `hashlib`, `shutil`, `subprocess`, `wave`).

---

## 2. Nintendo 3DS Toolchain

To complete the RomFS, CXI, and CIA packaging, the following binaries are required:

| Tool | Purpose | Location |
|---|---|---|
| `mkromfs3ds.exe` | Compresses Level 3 RomFS filesystem | `C:\devkitPro\tools\bin\mkromfs3ds.exe` (installed with devkitPro) |
| `makerom.exe` | Packages final `.cia` file | Included in [`tools/makerom.exe`](tools/makerom.exe) or in `devkitPro` |
| `3dstool.exe` | BLZ compression/decompression for the `code.bin` patch | Included in [`tools/3dstool.exe`](tools/3dstool.exe) |

> [!NOTE]
> `makerom.exe` and `3dstool.exe` are already included in the [`tools/`](tools/) folder.
> The only external system tool required for the complete build is **devkitPro** (specifically `mkromfs3ds.exe` located at the default path `C:\devkitPro\tools\bin\mkromfs3ds.exe`).

---

## 3. Running the Build

Once requirements are met:

### On Windows (One-Click)
Double-click or run from command prompt:
```bat
build.bat
```

### From Command Line (any terminal)
```bash
python tools/build.py
```

The generated files will be available in the project root:
- [`Papers Please.cxi`](Papers%20Please.cxi) (Citra / Lime3DS Emulator)
- [`Papers Please.cia`](Papers%20Please.cia) (Nintendo 3DS Console via FBI / Luma3DS)
