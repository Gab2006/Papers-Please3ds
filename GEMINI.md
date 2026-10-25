# GEMINI.md — Papers, Please: 3DS Homebrew Demake
> Documentazione tecnica, linee guida architetturali e memoria del progetto per l'agente AI e i contributori.

---

## 1. Project Overview

### Sintesi
Questo progetto e' un **demake homebrew** di *Papers, Please* (Lucas Pope, 2013) per **Nintendo 3DS**, scritto interamente in **Lua** e concepito per girare su **Lua Player Plus 3DS** (LPP-3DS) — l'interprete Lua homebrew che espone le API native del firmware 3DS (`Graphics`, `Controls`, `Screen`, `Timer`, `System`).

Il giocatore interpreta un ufficiale doganale di Arstotzka che deve ispezionare i documenti dei viaggiatori e decidere se lasciarli passare (timbro VERDE — APPROVED) o respingerli (timbro ROSSO — DENIED). Il progetto e' **self-contained** in `romfs/`: nessuna dipendenza esterna, nessun toolchain pesante per il build.

### Target Hardware
| Parametro | Valore |
|---|---|
| Piattaforma | Nintendo 3DS / New 3DS / 2DS |
| Runtime | Lua Player Plus 3DS (LPP-3DS) |
| Entry point | `romfs:/index.lua` |
| Percorso Salvataggi | `sdmc:/3ds/papersplease_save.dat` (fallback: `papersplease_save.dat`) |
| Lingua sorgente | Lua 5.1 (implementazione LPP-3DS) |

### Meccaniche implementate vs. originale
| Meccanica | Stato | Dettagli |
|---|---|---|
| Ispezione passaporti (multi-tipo) | Implementata | 8 layout nazioni, dati anagrafici, fototessera |
| Entry Permit | Implementata | Verifica nome, ID, data scadenza, sigillo MOA |
| ID Card | Implementata | Solo Arstotzka: altezza, peso, distretto, foto |
| Work Pass | Implementata | Settore lavorativo, data scadenza, sigillo MOL |
| Transcript | Implementata | Cronologia dialoghi viaggiatore |
| Rulebook | Implementata | 8 pagine regolamento sfogliabili |
| Sistema di timbri drag-on-document | Implementata | Collision detection dinamica con passaporto aperto |
| Generazione procedurale viaggiatori | Implementata | Volti (44+), nomi, altezze, pesi, date |
| Errori documentali randomizzati | Implementata | 17 tipologie di discrepanze |
| Dialogo dinamico viaggiatore | Implementata | Chat bubble system con animazione |
| Tre modalita' arcade classiche | Implementata | Time Mode, Perfect Mode, Score Mode |
| **Modalita' Storia / Campagna** | **Implementata** | Giornate progressive 1–4, date storiche, regole evolutive |
| **Bollettino Quotidiano & Giornale** | **Implementata** | *The Truth of Arstotzka* (top) + Direttive MOA (bottom) |
| **Turno Doganale a Tempo (09:00–18:00)** | **Implementata** | Orologio analogico frontiera sincronizzato, chiusura saracinesca |
| **Sistema Citazioni Ministeriali (M.O.A.)** | **Implementata** | Stampa meccanica a scatti, fisica bancone, scaglioni multa |
| **Suspense Delay (10 Secondi)** | **Implementata** | Verdetto e variazione punteggio ritardati di 10s per tensione |
| **Sistema Economico / Bilancio Crediti** | **Implementata** | Guadagno per ispezione (+5), sanzioni scalate, saldo `SCORE` |
| **Game Over per Insolvenza (Debito)** | **Implementata** | Schermata cupa ufficiale di arresto ministeriale se `SCORE < 0` |
| **Salvataggio e Ripresa Partita** | **Implementata** | Salvataggio tra giornate e mid-shift su scheda SD |
| **Audio / Effetti Sonori / Colonna Sonora** | **Progettata (Specifiche Pronte)** | Mappa SFX, tema intro, loop cabina, streaming OGG e WAV mono |

---

## 2. Project Architecture

### Mappa file sorgenti

```
romfs/
  index.lua                       # Entry point principale: gameloop, logica, rendering e stati (3180+ righe)
  DataFile.lua                    # Database statico: nomi, citta', distretti, errori, DAYS_CONFIG
  FontInfo.lua                    # Sistema font bitmap: glyph maps e GPU_DrawText() (336 righe)
  build.bat                       # Script batch one-click per build CXI e CIA su Windows
  docs/                           # Documentazione tecnica, specifiche architetturali e piani
    DESIGN_INFINITE_STORY.md      # Specifiche architetturali modalita' storia infinita
    PLAN_INFINITE_STORY.md        # Piano operativo e roadmap di sviluppo
  tools/                          # Toolchain di packaging, utility Python e binari 3DS
    build.py                      # Script di build automatizzato CXI/CIA e generatore RomFS IVFC
    optimize_sounds.py            # Normalizzatore audio e calibratore peak ceiling WAV a 12.000
    generate_papers_please_assets.py# Generatore asset procedurali (quotidiani, sfondi bollettino)
    makerom.exe / 3dstool.exe     # Binari 3DS per compressione blz e pacchettizzazione CIA
  ASSETS/                         # Risorse grafiche in formato PNG e audio WAV calibrati
    FONT/                         # Sprite sheet bitmap font (NORMAL_FONT, SMALL_FONT, DIGITS)
    SOUND/                        # File audio mono 22050Hz normalizzati (-8.7 dBFS)
    NEWS_DAY1.png .. NEWS_DAY4.png# Quotidiani The Truth of Arstotzka (400x240)
    BKG_BULLETIN_TOP.png / BTM    # Texture fallback bollettino mattutino
    BKG_DAYSUMMARY.png / TOP      # Texture cielo tramonto e pergamena riepilogo turno
    CITATIONinner.png             # Foglio citazione aperto sulla scrivania (183x80 px)
    CITATIONouter.png             # Foglio citazione compatto/ripiegato sul bancone (68x27 px)
    NEXTDAYbutton.png             # Pulsante avanzamento turno (sprite dual-state)
    OPENCHECKPOINTbutton.png      # Pulsante apertura frontiera (sprite dual-state)
    *.png                         # Texture documenti, timbri, volti, scrivania, monitor
```

### index.lua — Moduli e Funzioni Chiave
- **Inizializzazione & Salvataggio**: `LOAD_GAME()`, `SAVE_GAME()`, `START_STORY_MODE()`
- **Gestione Texture**: `loadtex()`, `GarbageCollection()`, lazy loading per stato
- **Rendering**: `LOAD_IMAGE()`, `LOAD_TEXT()`, `GPU_DrawText()`, `LOAD_FACE()`, `LOAD_CLOCK()`
- **Fisica Touch**: `TOUCH_CHECK()` con gestione priorità e transizioni bancone/scrivania
- **Timbro & Ispezione**: `STAMP_CODE()`, `CHECK_EMPTYTABLE()`, `HAS_TRAVELER_DOCS()`
- **Sistema Citazioni (M.O.A.)**: `SPAWN_CITATION()`, `CLEAR_CITATIONS()`, `IS_CITATION_PRINTING()`
- **Generazione Procedurale**: `RANDOMIZE()`, `NAMEGENERATOR()`, `DATEGENERATOR()`, ecc.
- **Game Loop Principale**: `while true do ... end` con state machine a variabile `menu`

### DataFile.lua
- `DAYS_CONFIG` — Configurazione giornate (data, titolo giornale, regole bollettino, permessi richiesti, durata turno)
- `WRONGTABLE` — 17 descrizioni formali degli errori documentali
- `CITY` / `FAKECITY` — Database città valide e contraffatte per tutte le 8 nazioni
- `FORDOCUMENT` / `FORDOCUMENTFAKE` — Mappatura ID passaporto -> città
- `MNAMES` / `FNAMES` — Pool anagrafico nomi maschili e femminili
- `DISTRICTS` / `FAKEDISTRICTS` — Distretti Arstotzka validi e falsi
- `FIELDS` — Settori lavorativi autorizzati per il Work Pass

---

## 3. Coding Conventions & Architectural Patterns

### Stile del Codice
- **Stile procedurale e imperativo puro**: Nessun metatabella OOP complessa, nessun `require()`. Tutto nel global scope LPP o localmente circoscritto.
- **Variabili globali**: `SCREAMING_SNAKE_CASE` (`SCORE`, `DAY_MISTAKES_COUNT`, `CITATIONS`, `PENDING_REWARDS`).
- **Funzioni**: `SCREAMING_SNAKE_CASE` (`SPAWN_CITATION`, `CHECK_EMPTYTABLE`, `SAVE_GAME`).
- **Variabili locali temporanee**: `lowercase` (`cit`, `rew`, `mistake_count`, `line`).
- **Nessuna concatenazione pesante nel game loop**: Evitare `string.format()` nei frame rate critici, usare `..` e passare numeri direttamente a `GPU_DrawText()`.

### Pattern Architetturali Appresi

#### 1. Macchina a Stati Estesa (`menu`)
```lua
menu = 0             -- Schermata Titolo (Main Menu)
menu = "Selection"   -- Selezione modalita' arcade
menu = "DayIntro"    -- Bollettino mattutino + Quotidiano The Truth of Arstotzka
menu = 2             -- Gameplay attivo al Checkpoint
menu = "DaySummary"  -- Riepilogo fine turno / Schermata cupa arresto se SCORE < 0
menu = "Pause"       -- Menu di pausa in-game (con salvataggio mid-shift)
menu = "GameOver"    -- Game Over arcade (Time, Perfect, Score)
menu = "Exit"        -- Uscita dall'homebrew
```

#### 2. Suspense Delay Pattern (10 Secondi / 600 Frame)
Nessuna modifica di punteggio o avviso di errore deve avvenire istantaneamente al rilascio del passaporto:
- **Decisione Corretta**: Registrata in `PENDING_REWARDS = { {delay = 600, points = plusPOINTS, is_story = ...} }`. Il counter resta congelato per 10 secondi; allo scadere del timer, `SCORE = SCORE + points` e `PLUSy = 80` (animazione verde).
- **Decisione Errata**: Genera una citazione in stato `DELAY` (`delay_max = 600`). Il counter resta intatto per 10 secondi, finché la citazione non emerge dal bancone.

#### 3. Mechanical Printer Feed Pattern ("A Scatti e Lentamente")
Le citazioni emergono realisticamente dal fondo del bancone come uscite da una stampante ad aghi:
- `step_feed = 8`: Movimento verso l'alto a 2 px/frame.
- `step_pause = 16`: Pausa meccanica di ~0.27 secondi tra un burst e l'altro.
- Al completamento della corsa, lo stato passa a `"IDLE"`. Se toccata dal giocatore durante la stampa, la citazione si sblocca istantaneamente per consentire il drag immediato.

#### 4. Counter-Shelf Transition & Physics (`now = 0` vs `now = 1`)
- **Sulla scrivania (`TOUCHy > 67`)**:
  - `now = 0`: Formato esteso aperto (183x80 px).
  - Movimento libero anche **sotto al ripiano del bancone** (`word.y` scorre verso il basso fino a `-40 px`).
  - **Ombra**: Disegnata solo quando il pennino sta premendo sul foglio (`TOUCH == key and Options["Shadow"] == 1`).
- **Attraversamento verso il bancone (`TOUCHy <= 67`)**:
  - `now = 1`: Transizione immediata in formato compatto/ripiegato (68x27 px, texture `CITATIONouter`).
  - Posizionamento sul ripiano superiore (`word.y` tra 5 e 60, trascinamento libero).
  - Rotazione leggera in diagonale (`rot = 0.15` o `-0.12`) tramite `Graphics.drawRotateImage`.
  - **Ombra**: Sempre visibile sul bancone con offset (+2, +2).
- **Margini laterali**: Libertà di movimento oltre i bordi dello schermo fino a metà larghezza (`x` tra `-half_w` e `320 - half_w`), identico al passaporto.
- **Rilascio e Slide di Rientro sul Bancone (`TOUCH ~= key and word.now == 1`)**:
  - Se rilasciata sporgente dal bordo inferiore (`y > 24`), scivola per gravità/accelerazione verso la quota ripiano `y = 23` come il passaporto.
  - Nessuno slide orizzontale o dal bordo superiore: libertà di posizionamento su tutta la campata del bancone (sinistra, destra, sopra).

#### 5. Sistema di Sanzioni a Scaglioni (Tiered Citations)
Il conteggio errori `mistake_count` calcola il tipo di citazione e la sanzione applicata nel frame esatto in cui inizia la stampa:
- **1ª e 2ª Citazione**: `"WARNING - NO PENALTY"` -> **0 punti/crediti** (nessuna variazione, `MINUSy` non si attiva).
- **3ª Citazione**: `"PENALTY: 5 CREDITS"` (Story) / `"PENALTY: -5 POINTS"` (Score) -> **-5 punti** (`LAST_MINUS_POINTS = 5`, `MINUSy = 80`).
- **4ª+ Citazione**: `"PENALTY: 10 CREDITS"` (Story) / `"PENALTY: -10 POINTS"` (Score) -> **-10 punti** (`LAST_MINUS_POINTS = 10`, `MINUSy = 80`).
- **Time Mode**: Primi 2 errori = 0s; dal 3° in poi = **-30 secondi** (`TIMEMINUS + 30000`, `TIMEy = 80`).
- **Perfect Mode**: 1° errore = `"FATAL INFRACTION - DISMISSED"` -> Game Over 2.5s dopo il termine della stampa.

#### 6. Waiting Guards (`IS_CITATION_PRINTING()`)
Il cambio di stato a fine turno (ore 18:00) o il passaggio alla schermata riassuntiva **non deve mai interrompere** un'ispezione o una citazione in corso:
`IS_CITATION_PRINTING()` restituisce `true` se `PENDING_REWARDS` contiene elementi o se una citazione ha `status == "DELAY"` o `"PRINTING"`. Il turno attende il completamento della stampa prima di abbassare la tapparella ed eseguire il fade out.

#### 7. Somber Debt Game Over (Ending per Insolvenza Ministeriale)
Se a fine giornata (18:00) il contatore scende in negativo (`SCORE < 0`):
- Il gioco **non** mostra il cielo al tramonto né la pergamena beige standard.
- Mostra una schermata cupa e plumbea ispirata all'Ending da arresto di *Papers, Please*:
  - **Top Screen**: Dossier ministeriale scuro con status *"DISMISSED & DETAINED"*, infrazioni totali e saldo in rosso vivo (*"FINAL ACCOUNT BALANCE: -X CREDITS"*).
  - **Bottom Screen**: Mandato di cattura in antracite metallico con narrativa ufficiale a macchina da scrivere (*"Your account has fallen into a negative balance... You are under arrest for non-payment... GLORY TO ARSTOTZKA"*).
  - **Pulsanti**: `RETRY DAY (A)` (ripristina `DAY_START_SCORE` e ricarica il giorno) e `MAIN MENU (B)`.

---

## 4. 3DS Constraints & Rules

### Risoluzioni e Layout
| Schermo | Risoluzione | API | Funzione Gameplay |
|---|---|---|---|
| Top Screen | 400 x 240 px | `TOP_SCREEN` | Ambiente esterno, viaggiatore, monitor HUD, orologio, quotidiano |
| Bottom Screen | 320 x 240 px | `BOTTOM_SCREEN` | Scrivania touch, documenti interattivi, timbri, bollettino MOA |

### Gestione Memoria (Regola d'Oro Old 3DS)
- Memoria texture VRAM/RAM limitata: totale bitmap scompresse preferibilmente sotto i **4 MB**.
- **Lazy loading obbligatorio**: Non caricare sfondi del bollettino o del riassunto turno all'avvio. Caricarli solo all'ingresso nello stato e deallocarli con `Graphics.freeImage()` all'uscita.
- **Evitare duplicati font**: Non ricaricare `NORMAL_FONT`, `SMALL_FONT`, `DIGITS` se già in memoria.

### Struttura Frame Loop
```lua
Screen.refresh()
Screen.clear(TOP_SCREEN)
Screen.clear(BOTTOM_SCREEN)

-- 1. Input snapshot
TOUCHx, TOUCHy = Controls.readTouch()
STICK.x, STICK.y = Controls.readCirclePad()
pad = Controls.read()

-- 2. Logica & Rendering Bottom Screen
Graphics.initBlend(BOTTOM_SCREEN)
  -- Aggiornamento PENDING_REWARDS (suspense timer)
  -- Aggiornamento CITATIONS (delay & printing feed)
  -- Disegno scrivania BKG_BTMS
  -- LOAD_IMAGE per documenti now == 0 (aperti)
  -- Disegno ripiano superiore bancone
  -- LOAD_IMAGE per documenti now == 1 (compatti sul bancone)
  -- Disegno STAMP rack
Graphics.termBlend()

-- 3. Logica & Rendering Top Screen
Graphics.initBlend(TOP_SCREEN)
  -- Disegno sfondo, muro, volto viaggiatore LOAD_FACE()
  -- Disegno tapparella CAGE
  -- Monitor overlay BKG_MONITORS con punteggio e orologio
  -- Effetti fluttuanti PLUSy / MINUSy / TIMEy
  -- Fade overlay se FADE_ALPHA > 0
Graphics.termBlend()

Screen.flip()
Screen.waitVblankStart()
oldpad = pad
```

---

## 5. Key Data Structures & Models

### CITATIONS — Registro Citazioni Ministeriali
```lua
cit = {
    key              = "CITATION_1",
    is_cit           = true,
    reason           = "INVALID EXPIRATION DATE",
    penalty          = "PENALTY: 5 CREDITS",
    penalty_mode     = 4,            -- Modalità in cui è stata emessa
    penalty_pts      = 5,            -- Crediti da sottrarre all'arrivo
    penalty_time     = 0,            -- Millisecondi da sottrarre (Time Mode)
    now              = 0,            -- 0=aperto su scrivania, 1=compatto su bancone
    x                = 12,
    y                = 240,
    target_y         = 160,          -- Quota di arresto della stampa
    status           = "DELAY",      -- "DELAY" -> "PRINTING" -> "IDLE"
    delay_frames     = 0,            -- Timer suspense (600 frame = 10s)
    delay_max        = 600,
    step_feed        = 0,
    step_pause       = 0,
    is_fatal         = false,        -- True per Perfect Mode
    rot              = 0.15,         -- Inclinazione sul bancone
    tex              = CITATIONinner,-- Texture 183x80
    tex2             = CITATIONouter -- Texture 68x27
}
```

### PENDING_REWARDS — Coda Ricompense Ispezione Corretta
```lua
reward = {
    delay    = 600,      -- Countdown 10 secondi (60 frame/sec)
    points   = 5,        -- Punti da accreditare a SCORE
    is_story = true      -- Incrementa DAY_CORRECT_COUNT
}
```

### DAYS_CONFIG — Database Giornate Story Mode (in DataFile.lua)
```lua
DAYS_CONFIG = {
    [1] = {
        date             = "23.11.1982",
        headline         = "GRESTIN BORDER REOPENS",
        subline          = "Six-year war with Kolechia is over.",
        bulletin_rules   = {
            "SOLO CITTADINI DI ARSTOTZKA AMMESSI",
            "RESPINGERE TUTTI GLI STRANIERI",
            "CONTROLLA SCADENZA E VALIDITA' DOCUMENTI"
        },
        allow_foreigners = false,
        require_permit   = false,
        require_workpass = false,
        duration_sec     = 180           -- 3 minuti di turno reale (09:00 - 18:00)
    },
    ...
}
```

### Struttura File di Salvataggio (`papersplease_save.dat`)
File di testo a coppie chiave-valore leggibile e robusto:
```ini
DAY=1
IN_PROGRESS=0
ELAPSED=0
INSPECTED=8
CORRECT=7
MISTAKES=1
SCORE=15
WRONGMANN=1
PEOPLESCORE=8
```

---

## 6. Guidelines for Future Development

### Regole Esistenti Consolidate
* **Regola #1 (Nuovo Passaporto)**: Aggiornare `PASSPORTSHEET.png`, `NOTPASSPORTSHEET.png`, `LOAD_TEXT()`, mapping `FORDOCUMENT` in `DataFile.lua` ed esclusione in `RANDOMIZE()`.
* **Regola #2 (Nuovo Documento)**: Creare `_TEX` e `_TEX2`, aggiungere in `LOAD_ITEMS()`, `loadtex()`, `GarbageCollection()`, `RANDOMIZE()`, `LOAD_IMAGE()`, `LOAD_TEXT()`, `TOUCH_CHECK()`.
* **Regola #3 (Nuovo Errore Documentale)**: Aggiungere stringa a `WRONGTABLE[N]`, gestire corruzione in `RANDOMIZE()`, preservare indici `Nothing`.
* **Regola #4 (Nomi/Città/Distretti)**: Mantenere massimo 3 città per nazione (`math.random(1,3)` hardcoded).
* **Regola #5 (Volti Viaggiatori)**: Aggiornare range in `GENDERGENERATOR()` e altezze in `HEIGHTGENERATOR()`.
* **Regola #6 (Coordinate Rendering)**: Rispettare rigorosamente 400x240 (Top) e 320x240 (Bottom).

### Nuove Regole Apprese e Cruciali

#### Regola #11 — Aggiungere una Nuova Giornata Narrativa (Story Mode)
1. Aggiungere la voce `[N]` in `DAYS_CONFIG` in `DataFile.lua` specificando data, headline, subline, array `bulletin_rules`, flag documenti e durata turno.
2. Inserire il quotidiano `ASSETS/NEWS_DAY<N>.png` (formato 400x240 px a 24-bit RGB non interlacciato).
3. In `RANDOMIZE()`: verificare che le nuove regole condizionali della giornata (es. sequestro passaporti, verifiche vaccini, sigilli speciali) siano agganciate a `CURRENT_DAY`.
4. In `CHECK_EMPTYTABLE()`: collegare eventuali nuove condizioni di respingimento obbligatorio alla giornata attiva.

#### Regola #12 — Maneggiare il Ciclo di Vita delle Citazioni
- Per emettere una citazione, invocare sempre `SPAWN_CITATION(reason_text, penalty_text, penalty_mode, penalty_pts, penalty_time)`.
- **Non alterare mai `SCORE` o `TIMEMINUS` dentro `CHECK_EMPTYTABLE()`**: qualsiasi detrazione deve avvenire unicamente all'interno del loop `menu == 2` quando `cit.delay_frames >= cit.delay_max`.
- Invocare `CLEAR_CITATIONS()` ad ogni reset turno, cambio giornata o uscita al menu principale per evitare memory leak o citazioni fantasma.

#### Regola #13 — Gestione del Bilancio Economico e Schermata di Debito
- All'inizio di ogni giornata, salvare sempre `DAY_START_SCORE = SCORE`.
- A fine turno (`DAY_OVER`):
  - Se `SCORE >= 0`: mostrare il regolare riepilogo solare e consentire `NEXT DAY (A)`.
  - Se `SCORE < 0`: attivare la **schermata cupa** di mandato di cattura per insolvenza ministeriale.
- Nel pulsante `RETRY DAY (A)`, ripristinare sempre `SCORE = DAY_START_SCORE or 0` e salvare lo stato a inizio giornata: l'ufficiale deve poter riprovare il turno conservando i risparmi accumulati nei giorni precedenti.

#### Regola #14 — Timing, Suspense e Prevenzione Desincronizzazioni
- L'HUD orologio (`LOAD_CLOCK()`) in Story Mode calcola l'angolo lancette proporzionalmente all'elapsed time del turno (dalle 09:00 alle 18:00): non alterare la formula sinusoidale.
- Le animazioni numeriche fluttuanti (`PLUSy`, `MINUSy`, `TIMEy`) devono utilizzare `LAST_PLUS_POINTS` e `LAST_MINUS_POINTS` per mostrare fedelmente l'importo calcolato, mai formule hardcoded moltiplicate per contatori di sessione.

#### Regola #15 — Gestione Audio e Sound System (LPP-3DS & CSND Hardware)
- **Patch Binaria `mem_size` in `code.bin` (CRITICO - Earrape, Loop Infinito e Ram Corruption)**: Nel codice sorgente di LPP-3DS (`luaSound.cpp`), la funzione `lua_openwav_old` presentava un gravissimo bug strutturale: nel ramo non-streaming (`mem_size == false`), l'interprete ometteva l'inizializzazione del campo `wav_file->mem_size = 0`. Essendo la struct allocata con `malloc` (che non azzera la memoria heap), `mem_size` conteneva numeri interi spazzatura positivi. All'invocazione di `Sound.play(handle, false)`, il controllo `if (src->mem_size > 0)` risultava vero per qualsiasi suono breve: LPP-3DS attivava forzatamente il flag hardware `SOUND_REPEAT` (loop infinito), spawnava un thread di streaming su file già chiuso e comandava al DMA di leggere `src->mem_size` byte (megabyte interi di RAM fisica arbitraria oltre il buffer WAV), generando un assordante rumore statico/earrape continuo che continuava anche a gioco chiuso. Il file eseguibile `code.bin` è stato decompresso, corretto all'offset `0xd1e4` con l'istruzione `str r3, [r4, #24]` (che forza `mem_size = 0`), ricompresso con BLZ via `3dstool` e reinserito in `Papers Please.cxi`. `tools/build.py` verifica e garantisce questa patch in modo completamente automatizzato.
- **Inizializzazione Obbligatoria (`Sound.init()`) all'Avvio**: In LPP-3DS all'avvio nativo C++ (`main()`), l'interprete esegue un test hardware chiamando `csndInit()` seguito immediatamente da `csndExit()`, lasciando il puntatore al buffer dei comandi condivisi CSND a NULL (`0x00000000`). Chiamare `Sound.play()` senza prima inizializzare il backend provoca un **Data Abort ARM11 immediato (`PC: 0x001EB7A8`, `FAR: 00000000`, `Translation - Section`)**. È **TASSATIVO** invocare all'avvio `if Sound and Sound.init then pcall(Sound.init) end`.
- **Divieto Assoluto di `Sound.term()` su Uscita Gioco (CRITICO - Double `csndExit()` Data Abort Crash)**: In LPP-3DS, la funzione nativa `main()` esegue autonomamente `csndExit()` / `ndspExit()` all'uscita dal processo. Invocare `Sound.term()` da Lua dealloca e smappa preventivamente il blocco di memoria condivisa CSND (`csndSharedMem`); quando poi l'interprete si chiude o viene chiamato `System.exit()`, la seconda chiamata a `csndExit()` tenta di accedere o smappare una sezione virtuale inesistente, scatenando un **Data Abort (translation - section) fatale**. `Sound.term()` non deve MAI essere invocato da Lua.
- **Divieto di `Sound.pause()` su Canali Non Ancora Avviati (`ch = 0xDEADBEEF`)**: Un suono caricato da `Sound.openWav` ma mai riprodotto possiede `ch = 0xDEADBEEF`. In libctru, `CSND_SetPlayState` esegue `chn & 31`, interpretando `0xDEADBEEF` come canale 15! Invocare `Sound.pause` prima che il suono sia stato riprodotto silenzia arbitrariamente il canale 15 di un altro suono attivo e sporca i registri DMA. `Sound.pause` deve essere invocato unicamente su suoni che sono già stati effettivamente avviati almeno una volta (`AUDIO.sfx_played[id] == true`).
- **Flag di Ripetizione Booleano (CRITICO)**: In `Sound.play(handle, loop)`, il secondo parametro deve essere un **booleano letterale** (`false` per `SOUND_ONE_SHOT`, `true` per `SOUND_REPEAT`). **Non passare mai interi come `NO_LOOP = 0`**, poiché in C `lua_toboolean(L, 2)` valuta qualsiasi intero (incluso 0) come `true`, costringendo il canale CSND a ripetere il suono all'infinito!
- **Architettura Full-WAV (No Streaming OGG su CSND)**: Non usare `Sound.openOgg(path, true)` né thread di streaming su backend CSND. In LPP-3DS, `streamOGG_CSND` presenta un grave bug di buffer sui file mono (`tmp_buf` non allocato che sovrascrive la RAM lineare) e genera deadlock con `while (closeStream){}` all'uscita, congelando l'intero 3DS. Tutti i suoni e brani di sottofondo (`booth-intro.wav`, `booth-ambient.wav`) devono essere campioni `.wav` non in streaming (`Sound.openWav(path, false)`), caricati direttamente in memoria lineare ed eseguiti via hardware CSND.
- **Divieto Assoluto di `Sound.close()` (CRITICO - Double Free Crash)**: In LPP-3DS con CSND, `lua_close_old` dealloca `tmp_buf` (`if (tmp_buf != NULL) linearFree(tmp_buf);`) senza reimpostare la variabile globale `tmp_buf = NULL`. Chiamare `Sound.close()` più di una volta esegue un double-free immediato che corrompe la heap lineare di `dlmalloc`, causando un Data Abort su indirizzo NULL (`crash_dump_xxxx.dmp`). Per silenziare o fermare i canali audio, invocare **esclusivamente `Sound.pause(handle)`**.
- **Lazy Loading On-Demand per gli Effetti Sonori**: Non caricare tutti i file WAV all'avvio in blocco via `Sound.openWav()`. Ogni chiamata a `Sound.openWav()` apre un `FILE*` nativo con `fopen()` che rimane persistente: caricare in massa file all'avvio rischia di saturare il limite dei file descriptor (`FOPEN_MAX`). Caricare ciascun SFX solo al primo utilizzo dentro `PLAY_SFX(id)` tramite cache `AUDIO.sfx[id]`.
- **Nessun `updateStream()` necessario**: Non invocare `Sound.updateStream()` nel game loop per eliminare qualsiasi overhead o sincronizzazione SVC.
- **Raddoppio Volume Hardware CSND Mono (`0xFFFFFFFF`) & Normalizzazione Peak a 12.000 (CRITICO - Headroom Anti-Clipping)**: In LPP-3DS con CSND (`luaSound.cpp`), tutti i suoni mono (`audiotype == 1`) invocano internamente `My_CSND_playsound(ch, ..., 1.0, 2.0)`. Il parametro `pan = 2.0` comanda a `CSND_SetChnRegs` un volume forzato a `0xFFFFFFFF` (`Left = 65535, Right = 65535`), moltiplicando per 2 l'ampiezza di ogni campione a 16-bit. Tutti i file WAV mono sono normalizzati a un picco massimo di **12.000** (su 32.768, ~36.6% / -8.7 dBFS via `tools/optimize_sounds.py`). Con il raddoppio hardware a 65535, l'uscita effettiva sul DAC raggiunge 24.000 (73%), garantendo un audio forte, nitido, corposo e con oltre 8.000 unità di headroom anti-clipping.
- **Header WAV Standard Pulito a 44 Byte**: I file WAV devono essere codificati senza blocchi di metadati (`LIST`, `ISFT`, etc.) per permettere a `lua_openwav_old` di terminare il ciclo di salto chunk al primissimo step e mappare l'offset dati `pos + 4 = 44` con precisione byte-per-byte.

#### Regola #16 — Architettura Modalità Storia Infinita (Day 5+)
- **Funzione `GET_DAY_CONFIG(day)` Obbligatoria**: Non accedere mai direttamente a `DAYS_CONFIG[CURRENT_DAY]`. Per `day <= 4` la funzione inoltra a `DAYS_CONFIG[day]` (tutorial storico); per `day >= 5` genera la giornata matematicamente dal seed del giorno in modo deterministico (calendario progressivo, headline, regole bollettino, sanzioni diplomatiche e ricercati).
- **Escalation di Complessità a Scaglioni (Tier System)**:
  - **Tier 1 (Giorni 5–8)**: Bassa tensione. Spese di sussistenza = **20 crediti**. Si attivano discrepanze nel transcript e primi embarghi diplomatici.
  - **Tier 2 (Giorni 9–15)**: Media tensione. Spese di sussistenza = **25 crediti**. Si attiva la lista *Most Wanted* con ricercati ministeriali segnalati nel bollettino MOA.
  - **Tier 3 (Giorni 16+)**: Massima allerta. Spese di sussistenza = **30 crediti**. Fino a 2 restrizioni simultanee attive (embargo diplomatico + criminale ricercato).
- **Nuovi Motivi di Violazione e Citazione**:
  - `"VIOLATION OF DIPLOMATIC SANCTIONS"`: Approvazione di un viaggiatore proveniente dalla nazione straniera sotto embargo (`day_cfg.embargo_nation`).
  - `"WANTED FUGITIVE ADMITTED"`: Approvazione di un criminale segnalato nella lista ricercati del bollettino (`day_cfg.wanted_name`).
  - `"ENTRY PERMIT DURATION MISMATCH"`: Discrepanza tra la durata dichiarata a voce nel transcript e il valore stampato su `ENTRYPERMIT.duration`.
- **Rendering Procedurale Tipografico Top Screen**: Per `CURRENT_DAY >= 5`, non caricare file PNG esterni per il giornale. Il quotidiano *The Arstotzkan Tribune* viene renderizzato interamente via codice su Top Screen con intestazione istituzionale, data progressiva, titolo di allerta e articoli di contesto burocratico, con impatto zero sulla VRAM limitata del Nintendo 3DS.
- **Bilancio Economico di Sussistenza & Avanzamento Illimitato**: Alle ore 18:00 vengono scalate le spese giornaliere di affitto e cibo (`SCORE = SCORE - expenses`). Se `SCORE >= 0`, la scheda di riepilogo su Bottom Screen mostra entrate, spese e saldo risparmi netto, e il pulsante `NEXT DAY (A)` incrementa indefinitamente `CURRENT_DAY` salvando lo stato su SD (`sdmc:/3ds/papersplease_save.dat`). Se `SCORE < 0`, scatta l'arresto ministeriale per insolvenza con opzione `RETRY DAY (A)`.

#### Regola #17 — Gestione del Clock Hardware e Normalizzazione Timer LPP-3DS (CRITICO - Turno da 1 Minuto su New 3DS)
- **Bug Strutturale del Divisore Tick in LPP-3DS**: Nel codice nativo di LPP-3DS (`luaTimer.cpp`), la funzione `Timer.getTime()` calcola i millisecondi trascorsi dividendo la differenza di tick hardware (`svcGetSystemTick()`) per una costante hardcoded tarata sul clock a 268 MHz del Nintendo 3DS standard (`268123.48`).
- **Comportamento a 804 MHz (New 3DS, New 2DS XL e Citra/Lime3DS)**: Se l'applicazione invoca `System.setCpuSpeed(NEW_3DS_CLOCK)` o se la console ha il clock boost forzato tramite Luma3DS ("Clock+L2"), il contatore hardware di ciclo avanza a 804 MHz (3 volte più veloce). Poiché LPP-3DS continua a dividere per 268 MHz, ogni secondo reale accumula **3000 ms nel timer software**: di conseguenza, il turno da 3 minuti reali (`duration_sec = 180`, 180.000 ms) scade in **esattamente 60 secondi reali (1 minuto)**.
- **Strategia di Correzione a Doppio Livello**:
  1. **Clock di Default a 268 MHz**: All'avvio in `index.lua`, impostare tassativamente `System.setCpuSpeed(OLD_3DS_CLOCK)` anche per i modelli New 3DS / New 2DS. Il motore 2D in Lua garantisce 60 FPS stabili senza alcun bisogno di overclock.
  2. **Wrapper di Normalizzazione Dinamica (`Timer.getTime`)**: Sovrascrivere la funzione globale `Timer.getTime` per rilevare la velocità effettiva della CPU tramite `System.getCpuSpeed()`. Se `spd > 400` (es. 804 MHz forzato a livello kernel o emulatore), il tempo viene scalato di `math.floor(ms * 268 / spd)`, garantendo che 1 secondo reale equivalga sempre e comunque a 1000 ms e che il turno duri esattamente **3 minuti reali (180s)** su qualsiasi modello hardware, revisione CFW o emulatore.



