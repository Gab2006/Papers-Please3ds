# Papers, Please — Nintendo 3DS Demake

<div align="center">

![Platform](https://img.shields.io/badge/Platform-Nintendo%203DS%20%7C%202DS%20%7C%20New%203DS-red?style=for-the-badge&logo=nintendo-3ds)
![Engine](https://img.shields.io/badge/Engine-Lua%20Player%20Plus%203DS-blue?style=for-the-badge)
![Format](https://img.shields.io/badge/Format-.CIA%20%7C%20.CXI-brightgreen?style=for-the-badge)
![Audio](https://img.shields.io/badge/Audio-CSND%20Hardware%20PCM-orange?style=for-the-badge)
![License](https://img.shields.io/badge/Type-Non--Commercial%20Homebrew%20Demake-lightgrey?style=for-the-badge)

<br/>

> *"Congratulations. The October labor lottery is complete. Your name was pulled.*  
> *For immediate placement, report to the Ministry of Admission at Grestin Border Checkpoint.*  
> *An apartment will be provided for you and your family in East Grestin. Expect an 8-class dwelling.*  
> ***Glory to Arstotzka.***"

</div>

---

## 📋 Table of Contents
- [About the Project](#-about-the-project)
- [Key Features](#-key-features)
- [Gameplay & Mechanics](#-gameplay--mechanics)
  - [Daily Story Shift (09:00 – 18:00)](#daily-story-shift-0900--1800)
  - [Ministry of Admission (M.O.A.) Citations](#ministry-of-admission-moa-citations)
  - [Economic Balance & Somber Debt Arrest](#economic-balance--somber-debt-arrest)
  - [Document Examination & Discrepancies](#document-examination--discrepancies)
  - [Arcade Modes](#arcade-modes)
- [Controls](#-controls)
- [Audio & Sound Subsystem](#-audio--sound-subsystem)
- [Installation Guide](#-installation-guide)
  - [Physical Console (Nintendo 3DS / 2DS)](#1-physical-console-3ds--2ds--new-3ds)
  - [Emulators (Citra / Lime3DS)](#2-emulators-citra--lime3ds)
- [Building from Source](#-building-from-source)
- [Repository Structure](#-repository-structure)
- [Credits & Legal Disclaimer](#-credits--legal-disclaimer)

---

## 🛂 About the Project

**Papers, Please 3DS** is an authentic, standalone homebrew demake of Lucas Pope’s critically acclaimed 2013 dystopian documentary thriller, crafted from scratch in **Lua** to run on **Lua Player Plus 3DS (LPP-3DS)**.

Designed specifically to take full advantage of the Nintendo 3DS hardware:
* **Top Screen (400 × 240)**: Displays the atmospheric Grestin border post, queue of travelers, the animated metal security shutter, synchronized analog border clock, Ministry HUD monitor, dialog bubbles, and the daily issue of *The Truth of Arstotzka*.
* **Bottom Screen (320 × 240 Touchscreen)**: Serves as the tactile inspector desk. Players physically arrange passports, entry permits, work passes, Arstotzkan ID cards, and the rulebook; slide the mechanical stamp rack; inspect transcripts; and pick up printed Ministry citations.

Tested and optimized to run at a silky **60 FPS** on both original **Old 3DS / 2DS** and **New 3DS** models, with strict VRAM budgets and hardware CSND audio support.

---

## ✨ Key Features

- 📖 **Infinite Story / Campaign Mode**: Progressive daily shifts starting with the historical 4-day tutorial (*The Truth of Arstotzka*), seamlessly transitioning into infinite procedural shifts (Day 5+) with escalating 3-tier complexity, rotating diplomatic embargoes, Most Wanted criminal lookout lists, and transcript cross-verifications.
- 📰 **Procedural Newspaper Engine (*The Arstotzkan Tribune*)**: Dynamic typographic newspaper generation for Day 5+ on the Top Screen rendering real-time dates, national alert headlines, and Ministry directives with zero additional VRAM consumption.
- 🖨️ **Realistic Ministry Citation System**:
  - **10-Second Suspense Delay**: Verdicts and errors are not revealed immediately; the player waits in tension as travelers depart.
  - **Stepped Dot-Matrix Print Feed**: Mechanical burst animations and sound effects as infraction slips emerge from the desk.
  - **Tiered Penalties**: First 2 errors act as warnings; 3rd error costs 5 credits; 4th+ errors deduct 10 credits.
- 💸 **Economic Balancing, Subsistence Expenses & Debt Arrest**:
  - Earn 5 credits per valid passport cleared.
  - Daily family subsistence expenses (Rent & Food: 20, 25, or 30 credits depending on tier) automatically deducted at 18:00.
  - Fall into negative balance (`SCORE < 0`) at shift end to trigger a somber Ministry Arrest dossier ending.
  - Infinite career advancement: keep earning savings and advance across Day 5, 6, 7... N via `NEXT DAY (A)`.
- 📂 **Multi-Document Verification**:
  - **8 National Passports**: Arstotzka, Antegria, Impor, Kolechia, Obristan, Republia, United Federation.
  - **Entry Permits**: Traveler names, ID codes, expiry dates, purpose, entry duration, and official MOA seals.
  - **Work Passes**: Authorized labor fields, expiration limits, and Ministry of Labor (MOL) seals.
  - **Arstotzkan ID Cards**: Domestic biometric records with district verification, height, weight, and portrait comparison.
  - **Flippable Rulebook & Transcript Log**: Inspect regulations and dialogue logs in real-time.
- 🏷️ **Interactive Physical Desk & Shelf Physics**:
  - Dual-state documents: open flat on the desk (`now = 0`), or fold compactly when dragged up onto the upper counter shelf (`now = 1`).
  - Realistic slide-back gravity when items are dropped along shelf edges.
  - Sliding stamp drawer with dynamic collision detection on open passports.
- 🕹️ **Arcade Modes**:
  - **Time Mode**: 10-minute shift with -30s penalties for repeated mistakes.
  - **Perfect Mode**: Single infraction triggers immediate dismissal and termination.
  - **Score Mode**: High-score challenge without daily narrative limits.
- 🔊 **Native Hardware Audio Engine**:
  - Custom-patched CSND audio handling in `code.bin`.
  - 19+ authentic sound effects (stamps, mechanical shutters, paper handling, printer feeds, footsteps, booth chatter).
  - Headroom-calibrated 16-bit mono WAV playback preventing hardware DAC clipping.
- 💾 **Persistent Save System**:
  - State preservation across shifts and mid-game pauses saved directly to SD card (`sdmc:/3ds/papersplease_save.dat`).

---

## 🎮 Gameplay & Mechanics

### Daily Story Shift (09:00 – 18:00)
Every day starts with the morning bulletin:
1. **The Truth of Arstotzka (Top Screen)**: Highlights the state-approved narrative of current events.
2. **Ministry of Admission Directives (Bottom Screen)**: Lists official regulations for the day. Touch **OPEN CHECKPOINT** or press `A` to raise the booth shutter and begin your shift.
3. **The Clock**: The synchronized analog clock on the top monitor tracks the shift from 09:00 to 18:00. When 18:00 strikes, the shutter lowers, waiting for any pending citations to finish printing before transitioning to the Daily Inspection Report.

### Ministry of Admission (M.O.A.) Citations
Mistakes are penalized by the Ministry:
* Approving an unauthorized traveler or wrongfully denying a valid citizen will trigger an M.O.A. citation.
* **Suspense Timer**: Citations do not spawn instantly; an internal 10-second (600 frame) delay maintains psychological tension while the traveler walks away.
* **Mechanical Printing**: Infractions emerge step-by-step from the counter with typewriter/printer sounds.
* **Tiered Sanctions**:
  - Infraction 1 & 2: `WARNING - NO PENALTY` (0 credits)
  - Infraction 3: `PENALTY: 5 CREDITS` (-5 credits)
  - Infraction 4+: `PENALTY: 10 CREDITS` (-10 credits)

### Economic Balance & Somber Debt Arrest
Your salary directly funds your livelihood:
* **Approved Entrant**: +5 credits (credited after suspense delay).
* At 18:00, if your balance drops below zero (`SCORE < 0`), the Ministry arrests you for non-payment:
  - Top Screen shows the official ministry case dossier with stamp `DISMISSED & DETAINED`.
  - Bottom Screen renders the arrest warrant detailing the family eviction and internment.
  - You can select **RETRY DAY (A)** to replay the day with your starting balance or return to **MAIN MENU (B)**.

### Document Examination & Discrepancies
Procedural generation creates random discrepancies across 17 distinct violation categories:
* Expired passport or permit dates.
* Counterfeit issuing cities or forged district names.
* Invalid issuing seals (MOA or MOL).
* Mismatched names, birthdates, or ID numbers across documents.
* Identity fraud (face mismatch between passport, ID card, and traveler).
* Discrepancies in declared height or weight vs. biometric card data.

---

## 🕹️ Controls

| Input | Action |
|---|---|
| **Stylus / Touchscreen** | Drag & drop documents between desk and counter shelf; open/close rulebook; flip rulebook pages; drag stamp rack; stamp passports; tap menu buttons |
| **A Button** | Call next entrant into the booth (`Press A to Call next`); confirm selections; proceed to next day |
| **B Button** | Return to previous menu / Main Menu; cancel prompts |
| **START Button** | Pause menu (allows toggling in-game settings: audio, text alignment, shadows, dialogue bubbles) |
| **R Button** | Quick-toggle stamp drawer bar open / closed |
| **L Button** | Capture clean screenshot (saved directly to SD card root as `PapersPlease-H-M-S.bmp`) |

---

## 🔊 Audio & Sound Subsystem

The game incorporates a custom low-level audio implementation designed around the Nintendo 3DS CSND hardware:
* **Binary CSND Fix**: The compiled LPP-3DS `code.bin` executable is patched at offset `0xd1e4` to initialize `mem_size = 0` in non-streaming WAV handles, completely preventing memory corruptions, infinite loops, and static noise bursts.
* **Anti-Clipping Calibration**: LPP-3DS mono playback forces maximum channel registers (`0xFFFFFFFF`), doubling sample amplitudes. All sound effects in `ASSETS/SOUND/` are normalized with a peak ceiling of 12,000 / 32,768 (-8.7 dBFS via `tools/optimize_sounds.py`), providing pristine clarity and 8,000+ units of anti-clipping headroom.
* **On-Demand SFX Cache**: Sound handles are loaded lazily upon first trigger to prevent exhausting the 3DS OS file descriptor limit (`FOPEN_MAX`).

---

## 📦 Installation Guide

Pre-built binaries are available directly in this repository:
* [Papers Please.cia](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/Papers%20Please.cia) — Installable package for physical Nintendo 3DS family systems.
* [Papers Please.cxi](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/Papers%20Please.cxi) — CTR Executable Image for emulators (Citra, Lime3DS).

### 1. Physical Console (3DS / 2DS / New 3DS)
*Requires a console with Custom Firmware (Luma3DS).*
1. Copy [Papers Please.cia](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/Papers%20Please.cia) to your SD card (e.g. `SD:/cias/`).
2. Insert the SD card into your console and open **FBI**.
3. Navigate to `SD` -> `cias` -> select `Papers Please.cia` -> choose **Install CIA** (or **Install and delete CIA**).
4. Press `HOME` to exit FBI. Unbox the newly installed gift on your HOME Menu and launch the game!

### 2. Emulators (Citra / Lime3DS)
1. Download or clone this repository.
2. In Citra / Lime3DS:
   - Click **File** -> **Open File...** -> select [Papers Please.cxi](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/Papers%20Please.cxi) (or simply drag and drop the `.cxi` into the emulator window).
   - Alternatively: Click **File** -> **Install CIA...** and select [Papers Please.cia](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/Papers%20Please.cia).

---

## 🛠️ Building from Source

The project includes a fully automated build pipeline that compiles the Lua RomFS filesystem and packages both `.cxi` and `.cia` formats.

### Prerequisites
* **Python 3.8+**
* Nintendo 3DS SDK tools (bundled in `tools/` or installed in `C:\devkitPro\tools\bin\`):
  * `makerom.exe`
  * `3dstool.exe`
  * `mkromfs3ds.exe` (optional, built-in IVFC RomFS generator included in `tools/build.py`)

### Compiling
Run the one-click build script:
```bat
build.bat
```
Or run the Python build script directly:
```bash
python tools/build.py
```

#### What `build.py` does automatically:
1. Re-generates IVFC level 1, 2, and 3 hash containers for the RomFS filesystem.
2. Applies the binary patch for LPP-3DS CSND audio stability to `code.bin`.
3. Packages `Papers Please.cxi` with executable banners and icons.
4. Generates `Papers Please.cia` using `makerom`.

---

## 📁 Repository Structure

```
.
├── index.lua                       # Core game logic, state machine, rendering & touch physics
├── DataFile.lua                    # Static game databases (DAYS_CONFIG, names, cities, rules)
├── FontInfo.lua                    # Custom bitmap glyph rendering engine (GPU_DrawText)
├── build.bat                       # One-click Windows build script (calls tools/build.py)
├── GEMINI.md                       # Comprehensive technical documentation & project memory
├── README.md                       # Project presentation & installation guide
├── docs/                           # Architecture, design specifications & planning
│   ├── DESIGN_INFINITE_STORY.md    # Infinite campaign mode architecture
│   └── PLAN_INFINITE_STORY.md      # Implementation tasks and milestones
├── tools/                          # Build pipeline, Python utility scripts & 3DS tools
│   ├── build.py                    # Automated CXI/CIA packaging & IVFC RomFS builder
│   ├── optimize_sounds.py          # Audio normalizer & WAV peak ceiling calibrator
│   ├── generate_papers_please_assets.py # Automated texture & graphic asset generator
│   ├── makerom.exe                 # 3DS CIA generation tool
│   ├── 3dstool.exe                 # RomFS/ExeFS extraction and compression tool
│   └── *.txt                       # Encryption keys & tool config
└── ASSETS/                         # Textures, sprite sheets, bitmap fonts, and WAV sound effects
    ├── FONT/                       # Bitmap font sprite sheets
    ├── SOUND/                      # Calibrated 16-bit mono WAV sound effects
    └── *.png                       # Passports, stamps, documents, and UI graphics
```

---

## ⚖️ Credits & Legal Disclaimer

* **Original Game & Concept**: *Papers, Please* was created by **Lucas Pope** / **3909 LLC**. All visual concepts, document designs, lore, and audio inspirations are intellectual property of Lucas Pope and 3909 LLC. This is a non-commercial, fan-made educational homebrew demake.
* **3DS Demake Developer**: **Gab2006** ([GitHub Profile](https://github.com/Gab2006))
* **Lua Player Plus 3DS (LPP-3DS)**: Developed by **Rinnegatamante**
* **Audio Engineering & Build Architecture**: Built using `makerom`, `3dstool`, and custom Python IVFC packaging pipelines.

---

<div align="center">
  <b>GLORY TO ARSTOTZKA.</b>
</div>
