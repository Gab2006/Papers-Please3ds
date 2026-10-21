# GEMINI.md — Papers, Please: 3DS Homebrew Demake
> Documentazione tecnica e linee guida per l'agente AI e i contributori del progetto.

---

## 1. Project Overview

### Sintesi
Questo progetto e' un **demake homebrew** di *Papers, Please* (Lucas Pope, 2013) per **Nintendo 3DS**, scritto interamente in **Lua** e concepito per girare su **Lua Player Plus 3DS** (LPP-3DS) — l'interprete Lua homebrew che espone le API native del firmware 3DS (Graphics, Controls, Screen, Timer, System).

Il gioco riproduce la meccanica fondamentale dell'originale: il giocatore interpreta un ufficiale doganale di Arstotzka che deve ispezionare i documenti dei viaggiatori e decidere se lasciarli passare (timbro VERDE — APPROVED) o respingerli (timbro ROSSO — DENIED). Il progetto e' **self-contained** in romfs/: nessuna dipendenza esterna, nessun sistema di build.

### Target Hardware
| Parametro | Valore |
|---|---|
| Piattaforma | Nintendo 3DS / New 3DS / 2DS |
| Runtime | Lua Player Plus 3DS (LPP-3DS) |
| Entry point | romfs:/index.lua |
| Lingua sorgente | Lua 5.1 (implementazione LPP-3DS) |

### Meccaniche implementate vs. originale
| Meccanica | Stato |
|---|---|
| Ispezione passaporti (multi-tipo) | Implementata |
| Entry Permit | Implementata |
| ID Card | Implementata |
| Work Pass | Implementata |
| Transcript | Implementata |
| Rulebook | Implementata |
| Sistema di timbri drag-on-document | Implementata |
| Generazione procedurale viaggiatori | Implementata |
| Errori documentali randomizzati | Implementata (17 tipologie) |
| Dialogo dinamico viaggiatore | Implementata (chat bubble system) |
| Tre modalita' di gioco | Implementata (Time / Perfect / Score) |
| Progressione giornate narrative | Non implementata |
| Sistema economico / affitto / famiglia | Non implementato |
| Storyline / personaggi ricorrenti | Non implementata |
| Audio / musica | Non implementato |

---

## 2. Project Architecture

### Mappa file sorgenti

romfs/
  index.lua       # Entry point principale - tutto il gameloop, logica e rendering (1828 righe)
  DataFile.lua    # Database statico: nomi, citta', distretti, campi, tabella errori (260 righe)
  FontInfo.lua    # Sistema font bitmap: tabelle glyph e GPU_DrawText() (336 righe)
  ASSETS/         # Risorse grafiche (PNG)
    FONT/         # Sprite sheet font
    *.png         # Texture, sprite, UI elements

### index.lua
File monolitico con l'intera logica di gioco:
- Inizializzazione globale (colori, timer, stato)
- Caricamento/scaricamento texture: loadtex(), GarbageCollection()
- Rendering documenti: LOAD_IMAGE(), LOAD_TEXT()
- Sistema font: GPU_DrawText()
- Fisica touch documenti: TOUCH_CHECK()
- Logica timbro: STAMP_CODE()
- Generazione viaggiatore: RANDOMIZE()
- Generatori dati: NAMEGENERATOR(), DATEGENERATOR(), PURPOSEGENERATOR(), ecc.
- Sistema dialogo: DIALOG_SYSTEM()
- Score e modalita': CHECK_EMPTYTABLE()
- Game loop: while true do ... end (righe 1491-1828)
- State machine menu: menu = 0 | 2 | Selection | Pause | GameOver | Exit

### DataFile.lua
Database puramente dichiarativo (nessuna funzione):
- WRONGTABLE — 17 descrizioni errori documentali
- CITY / FAKECITY — Citta' valide e invalide per 8 nazioni
- FORDOCUMENT / FORDOCUMENTFAKE — Mapping passport-type -> city list
- MNAMES / FNAMES — Pool nomi maschili e femminili
- DISTRICTS / FAKEDISTRICTS — Distretti Arstotzka validi e falsi
- FIELDS — Settori lavorativi per Work Pass

### FontInfo.lua
Sistema font bitmap hand-rolled con tre font:
- glyph_l/r/w (NORMAL_FONT, size=8) — solo UPPERCASE + punteggiatura
- glyph_l2/r2/w2 (SMALL_FONT, size=7) — UPPERCASE + lowercase + simboli
- glyph_l3/r3/w3 (DIGITS, size=5) — solo cifre e punto
- GPU_DrawText(x, y, text, color, align, screen_w, font_image, size) — allineamento l, r, c

ATTENZIONE: FontInfo.lua ricarica le texture font anche se gia' caricate da index.lua (righe 34-36).
Questo spreca memoria. Gia' compensato da GarbageCollection(), ma da risolvere in refactoring.

### Mappa ASSETS/

Font (ASSETS/FONT/):
- NORMAL_FONT.png  — Testo documenti (caps-only), glyph size 8px
- SMALL_FONT.png   — HUD, dialoghi, UI, glyph size 7px
- DIGITS.png       — Orologio, date, counter, glyph size 5px

Sfondi e ambienti:
- BKG_TPS.png       — Sfondo superiore (mappa/esterno), ~570px per scroll orizzontale
- BKG_BTMS.png      — Sfondo inferiore (scrivania doganale)
- BKG_MONITORS.png  — Monitor overlay schermo superiore (HUD bordi)
- WALL.png          — Muro dietro il viaggiatore
- CAGE.png          — Shutter doganale — sprite sheet 6 segmenti (180x120 px)
- SHADOW.png        — Ombra proiettata

Pattern documenti: ogni documento ha _TEX (aperto) e _TEX2 (chiuso/thumbnail):
- PASSPORT_TEX.png / PASSPORT_TEX2.png
- ENTRYTICKET_TEX.png / ENTRYTICKET_TEX2.png
- ENTRYPERMIT_TEX.png / ENTRYPERMIT_TEX2.png
- IDCARD_TEX.png / IDCARD_TEX2.png
- WORKPASS_TEX.png / WORKPASS_TEX2.png
- RULEBOOK_TEX.png / RULEBOOK_TEX2.png
- TRANSCRIPT_TEX.png / TRANSCRIPT_TEX2.png / TRANSCRIPT_LINE.png

Sprite sheet principali:
- PASSPORTSHEET.png      — 8 layout passaporto (130x162 px, 4 col x 2 righe)
- NOTPASSPORTSHEET.png   — Thumbnail passaporti (30x40 px)
- RULEBOOKSHEETS.png     — 8 pagine regolamento (238x158 px, 2 col x 4 righe)
- STMP_SPRITE.png        — Sprite timbro (barra, gomma rossa, gomma verde)
- FACE_1.png / FACE_2.png — Volti viaggiatori (150x120 px, 6 per riga)
- FACE_3.png / FACE_4.png — Versioni ombra/silhouette dei volti
- FACE_5.png             — Thumbnail volti per documenti (40x48 px, 11 per riga)
- EMOA.png               — Emblemi Entry Permit (35x35 px per tile)
- EMOL.png               — Emblemi Work Pass (35x35 px per tile)

UI Elements:
- Title.png, MODES.png, MODE1.png — Schermate menu
- *button.png (tutti)    — Sprite sheet con due stati (meta' superiore=normale, meta'=pressed)
- CHECKBOX.png           — Checkbox 15x15 px (top=unchecked, bottom=checked)
- YESSTAMP.png / NOSTAMP.png — Timbro apposto sul passaporto
- SB.png, GIVE.png       — Speech bubble, icona restituzione documento
- clockHOUR.png / clockMINUTE.png — Lancette orologio analogico
- manstay1.png / manstay2.png — Asset non referenziati (probabilmente legacy)

---

## 3. Coding Conventions & Patterns

### Stile Lua
- Variabili globali: SCREAMING_SNAKE_CASE (PERSON, STAMP, TOUCH, SWITCHER, SCORE)
- Funzioni: SCREAMING_SNAKE_CASE (LOAD_FACE, STAMP_CODE, CHECK_EMPTYTABLE)
- Variabili locali: lowercase (wrong, faces, a, b, c)
- Colori: costanti globali (RED, GREEN, WHITE, SHADOW, BROWN2)
- Nessun modulo/namespace: tutto nel global scope. Non esiste require().
- dofile() usato per caricare file ausiliari come include inline.

### Pattern architetturali

1. State Machine a variabile 'menu':
  menu = 0           -- Schermata titolo
  menu = Selection -- Selezione modalita'
  menu = 2           -- Gameplay attivo
  menu = Pause     -- Pausa
  menu = GameOver  -- Game Over
  menu = Exit      -- Uscita app

2. Desktop/ALLITEMS - Ordered Item Stack (array paralleli):
  DESKTOP  = {RULEBOOK, PASSPORT, ...}  -- chiavi stringa
  ALLITEMS = {RULEBOOK,   PASSPORT,   ...}  -- riferimenti tabella
  L'ordine determina Z-order. Item toccato: rimosso + reinserito in testa.
  Item restituito al viaggiatore: rimosso da DESKTOP.

3. Dual-State Document (now = 0 | 1):
  now == 1 -> chiuso (thumbnail tex2, posizione di riposo)
  now == 0 -> aperto (texture completa tex, trascinabile)

4. TOUCH arbitration (variabile stringa globale):
  ACTIVE  — touch screen premuto, nessun item agganciato
  NOTHING — transizione (primo frame touch senza target)
  STAMP   — rack timbro selezionato
  ACTIVE3 — timbro premuto su area stamping
  PASSPORT, IDCARD, ecc. — documento specifico agganciato

5. Lazy Texture Loading:
  Texture UI e font: caricate all'avvio in variabili globali.
  Texture gameplay (pesanti): caricate alla prima partita via loadtex(),
  chiamata da ScreenButton() con key==2. Guard: if BKG_BTMS==nil then loadtex() end

6. Options flags per performance:
  Options[Shadow]      = 0|1 -- Ombre documenti
  Options[TextAlign]   = 0|1 -- Testo centrato (GPU intensive)
  Options[NiceShutter] = 0|1 -- Animazione tapparella multi-segmento
  Options[Car]         = 0|1 -- Auto decorativa
  Options[Dialog]      = 0|1 -- Chat bubble system
  System.getModel() rileva New 3DS (model==2 o >3) per abilitare tutte le opzioni.

---

## 4. 3DS Constraints & Rules

### Display
| Schermo | Risoluzione | Variabile API |
|---|---|---|
| Superiore (Top) | 400 x 240 px | TOP_SCREEN |
| Inferiore touch (Bottom) | 320 x 240 px | BOTTOM_SCREEN |

### Distribuzione UI

Schermo superiore (TOP_SCREEN):
- Sfondo ambientale BKG_TPS con scroll orizzontale (BKG_TPSX: 0 a -170)
- Viaggiatore LOAD_FACE() con animazione idle sinusoidale
- Tapparella/shutter CAGE_MOVE()
- Monitor overlay con HUD: score, timer, people count, orologio analogico
- Fumetti di dialogo DIALOG_SYSTEM()

Schermo inferiore (BOTTOM_SCREEN):
- Sfondo scrivania BKG_BTMS
- Documenti drag & drop interattivi
- Rack del timbro STAMP_CODE()
- Pulsanti UI (menu/pausa)

### Input
| API | Uso |
|---|---|
| Controls.read() | Legge tasti fisici (snapshot frame) |
| Controls.check(pad, KEY_X) | Controlla tasto premuto nel frame |
| Controls.readTouch() | Restituisce TOUCHx, TOUCHy (0,0 = nessun tocco) |
| Controls.readCirclePad() | Restituisce STICK.x, STICK.y (deadzone ~15) |

Tasti:
- KEY_A      — Chiama prossimo viaggiatore (CheckPoint==1)
- KEY_R      — Toggle tapparella (SWITCHER)
- KEY_L      — Screenshot (System.takeScreenshot)
- KEY_START  — Apre pausa durante gameplay
- KEY_SELECT — Debug/Tech menu (commentato in produzione)
- Touch      — Drag documenti, pulsanti, timbro
- Circle Pad — Scroll mappa sfondo superiore

Pattern edge detection (pressed vs. held):
  if Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) then
      -- azione one-shot
  end
  oldpad = pad  -- aggiornato a fine loop

### Limiti memoria e texture
- Carica all'avvio: font, UI, titolo (variabili globali)
- Lazy load gameplay: loadtex() al primo avvio partita
- Garbage collection esplicita: GarbageCollection() chiama Graphics.freeImage() su tutto
- Non chiamare loadtex() piu' di una volta (guard: if BKG_BTMS==nil)
- Old 3DS: disabilitare Shadow, Dialog e TextAlign (gestito automaticamente)
- CPU clock esplicito: System.setCpuSpeed(NEW_3DS_CLOCK | OLD_3DS_CLOCK)

### Rendering order per frame

Screen.refresh()
Screen.clear(TOP_SCREEN)
Screen.clear(BOTTOM_SCREEN)
[Lettura input: TOUCHx/y, STICK, pad]

Graphics.initBlend(BOTTOM_SCREEN)
  [Logica touch + STAMP_CODE]
  [Draw scrivania inferiore]
  [LOAD_IMAGE per documenti now==0 (aperti)]
  [Draw fascia superiore scrivania]
  [LOAD_IMAGE per documenti now==1 (chiusi)]
  [Draw stamp rack]
Graphics.termBlend()

Graphics.initBlend(TOP_SCREEN)
  [Draw BKG_TPS, wall, face, cage, monitors, HUD, dialog]
Graphics.termBlend()

Screen.flip()
Screen.waitVblankStart()

---

## 5. Key Data Structures & Models

### PERSON — Stato del viaggiatore corrente

PERSON = {
    face        = 1..44,         -- Index volto (sprite sheet FACE_1/FACE_2)
    realface    = 1..44,         -- Volto reale (puo' differire in errore #12)
    passport    = 1..8,          -- Tipo passaporto (layout visivo; 7 non usato)
    GNDR        = M|F,       -- Genere (derivato da face range)
    name        = Firstname Lastname,
    DOB         = DD.MM.YYYY,
    COL         = City Name,
    passEXP     = DD.MM.YYYY,  -- Scadenza passaporto
    ID          = XXXXX-XXXXX, -- 5 char alfanumerico uppercase per parte

    -- Solo passport==2 (Arstotzka ID Card):
    idcardfirstname = ...,
    idcardlastname  = ...,
    idcarddistrict  = District Name,
    idcardDOB       = DD.MM.YYYY,  -- Alterabile (errore #4)
    idcardheight    = 161..184,      -- cm (face-dependent)
    idcardweight    = 40..90,        -- kg
    idcardface      = 1..44,         -- Alterabile (errore #12)
    height          = 161..184,
    weight          = 40..90,

    -- Solo passport~=2 (Entry Permit):
    permitname      = Firstname Lastname,
    permitid        = XXXXX-XXXXX,
    permitpurpose   = TRANSIT|VISIT|IMMIGRATE|WORK,
    permitduration  = 2 DAYS|14 DAYS|1 MONTH|...,
    permitenterby   = DD.MM.YYYY,
    permitx         = 10..105,
    permity         = 11..23,
    permitMOA       = 1..2,          -- Valido: 1-2; Forged: 3-10 (errore #17)

    -- Solo purpose==WORK e passport~=2 (Work Pass):
    WORKPASSholder  = ...,
    WORKPASSfield   = Accounting|Agriculture|...,
    WORKPASSuntil   = DD.MM.YYYY,
    WORKPASSx       = 6..105,
    WORKPASSy       = 7..29,
    WORKPASSMOL     = 1..4,          -- Valido: 1-4; Forged: 5-10 (errore #16)
}

### Documento generico (PASSPORT, IDCARD, ecc.)

DOC = {
    key      = PASSPORT,   -- Chiave per lookup in DESKTOP/ALLITEMS
    now      = 0|1,          -- 0=aperto, 1=chiuso
    x        = number,       -- Posizione X (touch screen coords)
    y        = number,       -- Posizione Y
    rot      = float,        -- Rotazione radianti (solo chiuso)
    tex      = image,        -- Texture aperta
    tex2     = image,        -- Texture chiusa/thumbnail
    velocity = number,
    gravity  = number,
    oldtouchx = number|nil,
    oldtouchy = number|nil,
}

### WRONGTABLE — Indice errori documentali

WRONGTABLE = {
    [1]  = Nothing,                       -- Viaggiatore valido
    [2]  = Nothing,                       -- Viaggiatore valido
    [3]  = Nothing,                       -- Viaggiatore valido
    [4]  = Date of birth is inconsistent, -- DOB IDCard != DOB Passport
    [5]  = Invalid issuing city,          -- Citta' sul passaporto e' falsa
    [6]  = District name,                 -- Distretto IDCard e' falso
    [7]  = Name is inconsistent,          -- Nome permesso != nome passaporto
    [8]  = Invalid Sex,                   -- Genere alterato
    [9]  = ID number is inconsistent,     -- ID permesso != ID passaporto
    [10] = Invalid Height,                -- Altezza IDCard alterata
    [11] = Invalid Weight,                -- Peso IDCard alterato
    [12] = Non-matching photo,            -- Foto IDCard != volto reale
    [13] = Nothing,                       -- Viaggiatore valido
    [14] = Invalid expiration date,       -- Passaporto scaduto
    [15] = Invalid expiration date,       -- Permesso scaduto
    [16] = Forged or missing seal,        -- Emblema Work Pass fuori range
    [17] = Forged or missing seal,        -- Emblema Entry Permit fuori range
}

Indici Nothing: [1],[2],[3],[13] -> probabilita' viaggiatore valido ~23%.

### STAMP — Stato del timbro

STAMP = {
    x       = number,          -- Posizione X rack (310=nascosto, ~40=aperto)
    y       = 42,              -- Posizione Y fissa
    state   = CLOSED|OPENED,
    red     = 22..38,          -- Pressione timbro rosso (38 = attivato)
    green   = 22..38,          -- Pressione timbro verde (38 = attivato)
    velocity = number,
    gravity  = number,
}
Quando red>=38 o green>=38: collision detection con passaporto aperto.
Risultato: stamp=NO (DENIED) o stamp=YES (APPROVED)

### Modalita' di gioco

MODEselect = 1  -- TIME MODE: 10 minuti, ogni errore -30 secondi
MODEselect = 2  -- PERFECT MODE: game over al primo errore, punti decrescono
MODEselect = 3  -- SCORE MODE: no time limit, ogni errore scala il punteggio
COURSEselect = 1  -- unico corso disponibile

---

## 6. Guidelines for Future Development

### Regola #1 — Aggiungere un nuovo tipo di passaporto
1. Aggiungere layout PNG a PASSPORTSHEET.png (tile: 130x162 px, 4 per riga, max 16 totali).
2. Aggiungere thumbnail a NOTPASSPORTSHEET.png (30x40 px).
3. Aggiungere blocco if PERSON.passport==N then...end in LOAD_TEXT(PASSPORT, face)
   con le coordinate pixel esatte dei campi testo.
4. Collegare la nazione: FORDOCUMENT[N] e FORDOCUMENTFAKE[N] in DataFile.lua.
5. In RANDOMIZE(): esclusione tipo 7 usa while PERSON.passport==7 do end.
   Replicare per nuovi indici vuoti.

### Regola #2 — Aggiungere un nuovo documento
1. Creare ASSETS/NOME_TEX.png (aperto) e ASSETS/NOME_TEX2.png (thumbnail).
2. In LOAD_ITEMS(): aggiungere NOME = {key=NOME}
3. In loadtex(): NOME.tex = Graphics.loadImage(...) ; NOME.tex2 = Graphics.loadImage(...)
4. In GarbageCollection(): Graphics.freeImage(NOME.tex) ; Graphics.freeImage(NOME.tex2)
5. In RANDOMIZE(): table.insert in DESKTOP e ALLITEMS.
6. Aggiungere case in LOAD_IMAGE(word, key) e LOAD_TEXT(key).
7. Aggiungere case in TOUCH_CHECK(word, key).
   Limiti drag: X tra 35-285, Y tra 22-340 (bottom screen).

### Regola #3 — Aggiungere un nuovo errore documentale
1. Aggiungere stringa in WRONGTABLE[N] in DataFile.lua.
2. In RANDOMIZE(): aggiungere elseif wrong==N then con logica corruzione PERSON.
3. NON rimuovere i Nothing esistenti (bilanciano la difficolta').
4. Gli errori non applicabili devono avere fallback a wrong=1.
   Esempio: errori IDCard solo per passport==2.

### Regola #4 — Aggiungere nomi / citta' / distretti
- Pool nomi: aggiungere voci in MNAMES.FN, MNAMES.LN, FNAMES.FN, FNAMES.LN in DataFile.lua.
- Citta': aggiungere in CITY.NAZIONE E in FAKECITY.NAZIONE (variante volutamente sbagliata).
  NON superare 3 voci per nazione — math.random(1,3) e' hardcoded.
- Distretti: aggiungere in DISTRICTS e FAKEDISTRICTS.
- Settori lavorativi: aggiungere in FIELDS.

### Regola #5 — Aggiungere volti
- FACE_1.png: sprite 150x120 px, 6 per riga, indici 1-24.
- FACE_2.png: sprite 150x120 px, 6 per riga, indici 25-44+.
- FACE_5.png (thumbnail): 40x48 px, 11 per riga.
- FACE_3.png / FACE_4.png: versioni ombra corrispondenti a FACE_1/FACE_2.
- GENDERGENERATOR(): aggiornare i range face per genere dopo aggiunta.
  Attuale: face 1-4 e 29-44 = F; 5-28 = M
- HEIGHTGENERATOR(): aggiungere case elseif PERSON.face==N per ogni nuovo volto.

### Regola #6 — Rendering e coordinate
- Schermo superiore: x in 0..399, y in 0..239.
  Lo scroll usa BKG_TPSX (negativo) come offset.
- Schermo inferiore: x in 0..319, y in 0..239.
  Zona documenti: y > 67. Zona HUD scrivania: y <= 67.
- Coordinate touch: 0..319 x 0..239. Valore (0,0) = nessun tocco.
- NON usare coordinate > 320 per bottom screen o > 400 per top screen.

### Regola #7 — Gestione memoria
- MAI chiamare Graphics.loadImage() nel game loop (while true do).
- SEMPRE aggiungere Graphics.freeImage() in GarbageCollection() per ogni loadtex().
- I font sono caricati due volte (index.lua e FontInfo.lua) — non aggiungere ulteriori duplicati.
- Su Old 3DS: totale PNG sotto ~4 MB decompresso.

### Regola #8 — Aggiungere modalita' di gioco
1. Incrementare range in MODES.png (attualmente 3 righe da 70px).
2. Aggiungere elseif MODEselect==N then nella sezione HUD timer (righe ~1543-1556).
3. Aggiungere condizione Game Over (righe ~1692-1709).
4. La selezione usa step 70px: max 3 modalita' in 210px (bottom screen height 210).

### Regola #9 — Debug durante sviluppo
Il TECHMENU e' commentato nel loop (riga 1689: --TECHMENU()).
Per riattivarlo: decommentare. Mostra:
- Stato timbro (stamp), FaceId, SWITCHER
- Coordinate touch (TOUCHx, TOUCHy)
- Item attivo (TOUCH)
- Errore corrente (WRONGCONST) e precedente (LASTWRONGCONST)
- Verdetto correttezza scelta

### Regola #10 — Stile codice
- Mantenere stile imperativo e procedurale. No metatabelle OOP, no require().
- Nuove funzioni helper: SCREAMING_SNAKE_CASE globale.
- Nuove variabili temporanee: local, mai globali implicite.
- Commentare sezioni con -- [NOME SEZIONE].
- Evitare string.format() e funzioni string-heavy nel game loop.
  Usare concatenazione .. e GPU_DrawText() che accetta numeri direttamente.
