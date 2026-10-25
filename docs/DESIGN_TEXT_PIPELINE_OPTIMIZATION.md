# Architettura & Specifiche Tecniche: Ottimizzazione Pipeline Testo e Fluidità 60 FPS

## 1. Contesto & Obiettivi
Durante il gameplay sulla scrivania del checkpoint (`menu == 2`), quando sono aperti contemporaneamente due o più documenti (Passaporto, Entry Permit, ID Card, Work Pass, Rulebook, Transcript), la console Nintendo 3DS evidenzia un calo percepibile del frame rate rispetto al target di 60 FPS. Questo rallentamento impatta la reattività del trascinamento a pennino (`drag`) e rallenta l'animazione di apertura/chiusura del carrello dei timbri (`STAMP_CODE()`).

L'obiettivo è portare e mantenere il frame rate a **60 FPS stabili** anche con tutti i documenti aperti sul tavolo, preservando al contempo **l'identità grafica al 100%** (stessi font bitmap, layout, colori e ombre).

---

## 2. Analisi dei Colli di Bottiglia

1. **Allocazioni Eccessive di Stringhe Temporanee (GC Stutter)**:
   In `LOAD_TEXT()`, ad ogni frame vengono eseguite ripetutamente chiamate a `string.upper()` su tutti i campi anagrafici dei documenti aperti (`string.upper(PERSON.permitname)`, `string.upper(PERSON.permitpurpose)`, etc.). In Lua 5.1 ogni stringa creata alloca memoria nella heap gestita dal Garbage Collector. Con 2+ documenti aperti, vengono create decine di stringhe per frame, innescando cicli frequenti di Garbage Collection che causano micro-freeze e cali di FPS.

2. **Doppio Passaggio di Misurazione nei Testi Allineati**:
   In `GPU_DrawText()`, per i testi centrati (`option == "c"`) e allineati a destra (`option == "r"`), viene eseguito un primo ciclo su tutti i caratteri per calcolare la larghezza totale (`total_w`), seguito da un secondo ciclo per inviare i glifi alla GPU. Questa misurazione è completamente ridondante poiché i testi anagrafici sono invarianti per tutto il turno del viaggiatore.

3. **Chiamate GPU Non Filtrate (Mancanza di Counter Occlusion Culling)**:
   Quando un documento aperto si trova parzialmente sotto la campata superiore del bancone (`y < 67`), `GPU_DrawText()` invia comunque i comandi di disegno per tutte le righe di testo superiori, che vengono poi immediatamente sovrascritte dalla texture di sfondo del bancone (`BKG_BTMS`).

4. **Loop di Ricerca Oggetti O(N×M)**:
   La scansione degli oggetti aperti sulla scrivania (`DESKTOP` e `ALLITEMS`) viene eseguita con loop annidati $O(N \times M)$ più volte per frame.

---

## 3. Decision Log

| ID | Decisione Presa | Alternative Considerate | Motivazione Tecnica |
|---|---|---|---|
| **DEC-01** | **Zero-Allocation Text Pipeline (Descrittori Statici)** | Pre-baking su texture RAM (Render-to-Texture), LOD dinamico durante drag | LPP-3DS non supporta FBO/Render-to-Texture da Lua; il LOD dinamico avrebbe degradato la fedeltà visiva. I descrittori statici mantengono la grafica al 100% e azzerano il carico CPU/GC. |
| **DEC-02** | **Pre-calcolo Larghezze in `RANDOMIZE()`** | Misurazione on-demand con memoization per stringa | Pre-calcolare direttamente all'ingresso del viaggiatore evita qualsiasi branching o hashing a runtime durante il frame loop a 60 FPS. |
| **DEC-03** | **Counter-Shelf Occlusion Culling (`y < 65`)** | Disegno indiscriminato con overdraw | Scartare le righe di testo che finiscono dietro la fascia del bancone risparmia fino a 40–60 chiamate `Graphics.drawPartialImage()` per documento. |
| **DEC-04** | **Lookup Diretto Oggetti O(1)** | Mantenimento della ricerca lineare annidata su `ALLITEMS` | Mappatura diretta `ITEMS_MAP[key]` che elimina completamente le iterazioni ridondanti nel loop di rendering. |

---

## 4. Architettura Tecnica Dettagliata

### 4.1 Modello Dati `DOC_TEXT_CACHE`
In `index.lua`, all'atto della generazione del viaggiatore in `RANDOMIZE()`, viene popolata la struttura centralizzata:

```lua
DOC_TEXT_CACHE = {
    PASSPORT = {
        -- Campi specifici per il layout del passaporto attivo (1..8)
        fields = {
            { text = "...", x_off = 8, y_off = 138, color = BROWN, font = SMALL_FONT, size = 7, align = "l", w = 0 },
            ...
        }
    },
    ENTRYPERMIT = {
        fields = {
            { text = "...", x_off = 75, y_off = 89, color = ENTRYTICKET_BROWN, font = NORMAL_FONT, size = 8, align = "c", w = 64 },
            ...
        }
    },
    IDCARD = { ... },
    WORKPASS = { ... },
    TRANSCRIPT = { ... }
}
```

### 4.2 Ottimizzazione `GPU_DrawText()` in `FontInfo.lua`
La funzione `GPU_DrawText` accetta un parametro opzionale `precomputed_w`:
- Se fornito, salta il primo ciclo di scansione della stringa e calcola direttamente l'offset di allineamento:
  - `option == "c"`: `local px = x - math.floor(precomputed_w / 2) + str_width`
  - `option == "r"`: `local px = x - precomputed_w + str_width`
- Se `y > 240` o `y < 65` (per elementi sotto il ripiano sulla scrivania `now == 0`), la riga di testo viene scartata prima di iterare sui caratteri.

### 4.3 Rendering Unificato in `LOAD_TEXT(key)`
`LOAD_TEXT` accede a `DOC_TEXT_CACHE[key]`:
- Per ogni campo memorizzato:
  ```lua
  local actual_y = doc.y + field.y_off
  if actual_y >= 65 and actual_y <= 240 then
      GPU_DrawText(doc.x + field.x_off, actual_y, field.text, field.color, field.align, 320, field.font, field.size, field.w)
  end
  ```
- Zero string allocation per frame.
- Zero passaggi ridondanti.
- Scarto matematico delle righe coperte dal bancone.

---

## 5. Piano di Verifica e Criteri di Successo

1. **Fluidità 60 FPS**: Durante il drag di 2 o più documenti aperti sul tavolo, il frame rate percepito rimane stabile e senza stutter su Nintendo 3DS.
2. **Reattività Cassetto Timbri**: L'apertura e chiusura del cassetto scorre alla velocità prevista senza alcun rallentamento quando i documenti sono aperti.
3. **Integrità Visiva**: Nessuna differenza di pixel, colore, font, spaziatura o ombre rispetto alla versione precedente.
