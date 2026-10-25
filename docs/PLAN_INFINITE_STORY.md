# Piano di Implementazione: Modalità Storia Infinita
> **Target**: Nintendo 3DS (Lua Player Plus - LPP-3DS)  
> **Documento di riferimento**: [DESIGN_INFINITE_STORY.md](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/DESIGN_INFINITE_STORY.md)  
> **Stato**: Completato e Validato

---

## 1. Mappa dei File Coinvolti

| File | Responsabilità | Modifiche Previste |
|---|---|---|
| [DataFile.lua](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/DataFile.lua) | Database e configurazione giornate | Implementazione di `GET_DAY_CONFIG(day)`, pool frasi transcript, estensione tabella errori `WRONGTABLE`. |
| [index.lua](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/index.lua) | Gameloop, ispezione e rendering | Sostituzione accessi statici con `GET_DAY_CONFIG()`, controlli embargo/ricercati in `CHECK_EMPTYTABLE()`, spese in `DaySummary`, rimozione blocco Giorno 4. |
| [GEMINI.md](file:///c:/Users/Gabriele%20Tosti/Desktop/romfs/GEMINI.md) | Memoria architetturale del progetto | Aggiornamento documentazione con le nuove regole doganali e modello a scaglioni. |

---

## 2. Fasi di Implementazione Sequenziali

### Fase 1: Motore Procedurale e Database (`DataFile.lua`)
- [x] **1.1. Funzione `GET_DAY_CONFIG(day)`**:
  - Mantenere i Giorni 1–4 instradati su `DAYS_CONFIG[day]` (tutorial storico).
  - Per `day >= 5`, generare determinata matematicamente dal numero del giorno (`day`):
    - Data progressiva (a partire da `27.11.1982`).
    - Scaglione di difficoltà (Tier 1: 5–8, Tier 2: 9–15, Tier 3: 16+).
    - Spese di sussistenza giornaliere (`daily_expenses`: 20, 25 o 30 crediti).
    - Eventuale nazione sotto embargo diplomatico (`embargo_nation`).
    - Eventuale criminale ricercato (`wanted_name`).
    - Titoli di giornale e direttive burocratiche per il bollettino.
- [x] **1.2. Estensione Motivi di Sanzione**:
  - Mappare nuove motivazioni formali per le citazioni MOA:
    - `"VIOLATION OF DIPLOMATIC SANCTIONS"` (approvazione nazione in embargo).
    - `"WANTED FUGITIVE ADMITTED"` (approvazione fuggitivo segnalato).
    - `"ENTRY PERMIT DURATION MISMATCH"` (discrepanza tra transcript e permesso).
- [x] **1.3. Pool Frasi Transcript**:
  - Introdurre risposte del viaggiatore relative alla durata del soggiorno (*"Visiting for 2 days"*, *"Stay for 14 days"*, *"Transit only"*, *"Here for employment"*).

---

### Fase 2: Generazione Dinamica Viaggiatore (`RANDOMIZE()` in `index.lua`)
- [x] **2.1. Switch a `GET_DAY_CONFIG()`**:
  - Sostituire ogni istanza di `DAYS_CONFIG[CURRENT_DAY]` con `GET_DAY_CONFIG(CURRENT_DAY)`.
- [x] **2.2. Spawn Condizionale del Ricercato**:
  - Se `day_cfg.wanted_name` è presente, assegnare al 20–25% dei viaggiatori il nome del criminale segnalato nel bollettino.
- [x] **2.3. Generazione Discrepanze nel Transcript**:
  - Sincronizzare le battute del dialogo `CHAT` con i documenti generati:
    - Impostare casi corretti (es. dichiara 14 giorni ed Entry Permit riporta 14 giorni).
    - Impostare casi con discrepanza (es. dichiara 30 giorni ma il permesso segna 2 giorni, o dichiara "lavoro" senza Work Pass).

---

### Fase 3: Logica di Ispezione (`CHECK_EMPTYTABLE()` in `index.lua`)
- [x] **3.1. Rilevamento Violazione Embargo**:
  - Se `day_cfg.embargo_nation` è attivo e il viaggiatore proviene da quella nazione (`PERSON.passport`), approvare con timbro verde scatena una citazione per violazione sanzioni. Respingere è la decisione corretta.
- [x] **3.2. Rilevamento Fuggitivo Ricercato**:
  - Se il nome del viaggiatore corrisponde a `day_cfg.wanted_name` e riceve approvazione, emettere citazione ministeriale per mancato arresto/diniego.
- [x] **3.3. Rilevamento Incongruenze Transcript**:
  - Verificare che lo scopo dichiarato coincida con i permessi e che la durata verbale coincida con l'Entry Permit. In caso di discrepanza, l'approvazione genera citazione.

---

### Fase 4: Bilancio Economico e Ciclo di Fine Turno (`DaySummary` in `index.lua`)
- [x] **4.1. Calcolo Spese di Sussistenza Familiari**:
  - Alle ore 18:00, dedurre le spese giornaliere:
    `SCORE = SCORE - (day_cfg.daily_expenses or 20)`.
- [x] **4.2. Aggiornamento Layout Scheda di Riepilogo**:
  - Mostrare nel foglio pergamena (Bottom Screen):
    - *Stipendio Ispezioni*: `+X CREDITS` (`DAY_CORRECT_COUNT * 5`).
    - *Spese di Sussistenza (Affitto/Cibo)*: `-Y CREDITS`.
    - *Saldo Risparmi Netto*: `SCORE CREDITS`.
- [x] **4.3. Avanzamento Infinito `NEXT DAY (A)`**:
  - Rimuovere la condizione limitante `if CURRENT_DAY < #DAYS_CONFIG`.
  - Permettere a `NEXT DAY (A)` di incrementare `CURRENT_DAY = CURRENT_DAY + 1` e salvare lo stato su scheda SD indefinitamente.
- [x] **4.4. Schermata Cupa di Debito / Game Over**:
  - Se `SCORE < 0`, mantenere attiva la schermata cupa ministeriale per insolvenza economica con pulsante `RETRY DAY (A)` per ritentare il turno ripartendo da `DAY_START_SCORE`.

---

### Fase 5: Rendering Procedurale Quotidiano e Bollettino (`menu == "DayIntro"`)
- [x] **5.1. Top Screen (Quotidiano Tipografico oltre il Giorno 4)**:
  - Per `CURRENT_DAY <= 4`: continuare a usare le texture esistenti `NEWS_DAY1.png` .. `NEWS_DAY4.png`.
  - Per `CURRENT_DAY >= 5`: utilizzare il renderer procedurale tipografico (`THE ARSTOTZKAN TRIBUNE`) visualizzando data storica, titolo embargo/sicurezza e sottotitolo generati da `GET_DAY_CONFIG()`, preservando la VRAM del 3DS.
- [x] **5.2. Bottom Screen (Direttive MOA)**:
  - Formattare dinamicamente le direttive del bollettino, evidenziando chiaramente nazioni sotto embargo e nomi dei ricercati.

---

### Fase 6: Protocollo di Test e Validazione
- [x] **Test 1**: Eseguire i Giorni 1–4 e verificare che rimangano identici all'esperienza originale.
- [x] **Test 2**: Completare il Giorno 4 e verificare che il gioco non si fermi su "CAMPAIGN COMPLETE", ma proponga `NEXT DAY (A)` portando al Giorno 5.
- [x] **Test 3**: Nel Giorno 5+, verificare la corretta comparsa nel bollettino delle nuove direttive e testare l'emissione delle citazioni per embargo, ricercato e transcript.
- [x] **Test 4**: Verificare che a fine turno vengano dedotte le spese di sussistenza e che un saldo negativo scateni fedelmente l'arresto ministeriale per debito.
- [x] **Test 5**: Verificare la stabilità dei 60 FPS e l'assenza di memory leak o picchi di Garbage Collection su Old 3DS.

