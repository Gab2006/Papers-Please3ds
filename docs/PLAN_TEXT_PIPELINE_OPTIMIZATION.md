# Piano Operativo di Implementazione: Ottimizzazione Fluidità 60 FPS

## Roadmap delle Fasi

- [x] **Fase 1: Ottimizzazione del Motore di Rendering Testo (`FontInfo.lua`)**
  - [x] Implementare `GPU_MeasureText(text, size)` per il calcolo statico immediato della larghezza in pixel.
  - [x] Estendere `GPU_DrawText()` per accettare `precomputed_w`: eliminazione del primo ciclo di scansione per testi centrati (`"c"`) e allineati a destra (`"r"`).
  - [x] Garantire retrocompatibilità 100% per le chiamate prive del parametro opzionale.

- [x] **Fase 2: Creazione del Sottosistema Descrittori Statici (`index.lua`)**
  - [x] Implementare `BUILD_DOC_TEXT_CACHE()` per pre-generare e normalizzare tutti i testi anagrafici del viaggiatore in `RANDOMIZE()`.
  - [x] Configurare i campi per tutti gli 8 layout di passaporto (`PERSON.passport == 1..8`).
  - [x] Configurare i campi per `ENTRYPERMIT`, `IDCARD` e `WORKPASS`.
  - [x] Configurare la cache dinamica per `TRANSCRIPT` (dialoghi) e `CITATIONS` (citazioni MOA).

- [x] **Fase 3: Refactoring di `LOAD_TEXT()` e Counter Occlusion Culling**
  - [x] Riscrivere `LOAD_TEXT(key)` per iterare sui descrittori pre-compilati senza allocare stringhe né chiamare `string.upper()`.
  - [x] Inserire il filtro di scarto ripiano: `if actual_y >= 65 and actual_y <= 240`.
  - [x] Preservare il rendering delle fototessere e del timbro doganale (`YES` / `NO`).

- [x] **Fase 4: Ottimizzazione Lookup Oggetti e Loop Main**
  - [x] Creare la mappa O(1) `ITEM_BY_KEY` per eliminare i loop nidificati su `ALLITEMS`.
  - [x] Ottimizzare la cadenza dell'animazione del cassetto timbri in `STAMP_CODE()`.

- [x] **Fase 5: Build, Validazione e Rilascio Pacchetti**
  - [x] Rebuild completo di `Papers Please.cxi` e `Papers Please.cia`.
  - [x] Verifica assenza di regressioni o anomalie visive.

