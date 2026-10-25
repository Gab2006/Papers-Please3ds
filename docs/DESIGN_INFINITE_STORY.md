# Specifiche di Design: Modalità Storia Infinita & Escalation di Complessità
> **Papers, Please: 3DS Homebrew Demake**  
> Data di validazione: Ottobre 2026

---

## 1. Understanding Summary

* **Cosa stiamo creando**: Un motore procedurale di **Giornate Infinite (Day 5, 6... N)** per la Modalità Storia/Campagna, dotato di una progressione continua di difficoltà, nuove direttive geopolitiche, liste di ricercati, controlli incrociati sul transcript e un bilancio economico giornaliero con spese di sussistenza.
* **Perché esiste**: Attualmente la modalità storia termina al Giorno 4 con la scritta "CAMPAIGN COMPLETE!". Questo sistema rende la carriera dell'ispettore doganale virtualmente illimitata e progressivamente più complessa, riproducendo la profondità gestionale e la tensione burocratica dell'opera originale.
* **A chi è rivolto**: Giocatori di *Papers, Please* su Nintendo 3DS / 2DS / New 3DS tramite homebrew Lua Player Plus (LPP-3DS).
* **Meccaniche Chiave**:
  1. **Generatore Procedurale di Giornata (`GET_DAY_CONFIG`)**: Sostituisce la tabella statica per `day >= 5`, calcolando data, headline, regole del bollettino, embargo e ricercati in modo deterministico.
  2. **Embargo Geopolitico a Rotazione**: Divieti diplomatici temporanei che ordinano il respingimento categorico dei cittadini di una specifica nazione straniera.
  3. **Lista 'Most Wanted' (Ricercati Ministeriali)**: Profili segnalati nel bollettino MOA del mattino con obbligo di diniego per evitare gravi sanzioni.
  4. **Verifica Incrociata nel Transcript**: Controllo di concordanza tra le dichiarazioni del viaggiatore (scopo e durata della visita) e i documenti esibiti (Entry Permit / Work Pass).
  5. **Bilancio di Sussistenza Familiare**: Detrazione di spese fisse a fine turno (Affitto, Cibo, Riscaldamento) per prevenire l'accumulo passivo di crediti e mantenere viva la minaccia dell'arresto per debito (`SCORE < 0`).
* **Vincoli Tecnici Principali**:
  * Limiti di memoria VRAM su Old 3DS: nessun asset PNG aggiuntivo caricato per i singoli giorni infiniti; utilizzo del rendering tipografico procedurale per quotidiano e bollettino.
  * Compatibilità totale con il file di salvataggio su SD (`sdmc:/3ds/papersplease_save.dat`).
  * Esecuzione a 60 FPS senza allocazioni massive o garbage collection improvvise durante il turno.
* **Non-Obiettivi**:
  * Trama ramificata con finali multipli dell'Ordine EZIC (il focus è la simulazione doganale infinita).
  * Nuovi accessori touch fisici (scanner a raggi X o scanner impronte digitali).

---

## 2. Assunzioni e Parametri di Progressione

1. **Continuità Canonica (Giorni 1–4)**:
   * I primi 4 giorni restano intatti come tutorial storico (utilizzando i file grafici `NEWS_DAY1.png` .. `NEWS_DAY4.png` e le direttive statiche).
2. **Escalation a Scaglioni (Tier System)**:
   * **Tier 1 (Giorni 5–8)**: Bassa tensione. Spese di sussistenza = **20 crediti**. Compare la prima incongruenza nel transcript o un embargo occasionale.
   * **Tier 2 (Giorni 9–15)**: Media tensione. Spese di sussistenza = **25 crediti**. Si attiva la lista *Most Wanted* (1 ricercato segnalato) e controlli documentali rigorosi.
   * **Tier 3 (Giorni 16+)**: Massima allerta. Spese di sussistenza = **30 crediti**. Fino a 2 restrizioni simultanee attive (embargo + ricercato + tutti i documenti obbligatori).
3. **Determinismo del Giorno**:
   * La configurazione del giorno `N` (data, titolo, regole, ricercato, embargo) è determinata dal seed locale del giorno (`day`), garantendo che riavviando il turno (*RETRY DAY*) lo scenario rimanga identico.
4. **Tariffa Ispezioni vs Spese**:
   * Guadagno per ispezione corretta: **+5 crediti**.
   * Con spese tra 20 e 30 crediti, l'ufficiale deve completare con successo almeno **4–6 ispezioni pulite** a turno per non finire in perdita.

---

## 3. Decision Log (Registro delle Decisioni)

| Decisione | Opzioni Considerate | Motivazione della Scelta |
|---|---|---|
| **Architettura Infinita** | Giornate procedurali (Day 5..N) vs 31 giorni fissi vs New Game+ ciclico | Raggiunge rigiocabilità infinita immediata con impatto zero sulla memoria VRAM del Nintendo 3DS. |
| **Vettori di Complessità** | Embargo + Most Wanted + Transcript vs Nuovi documenti fisici | Approfondisce le verifiche mentali e sfrutta gli asset esistenti senza affollare eccessivamente il piccolo touchscreen (320x240). |
| **Economia di Sussistenza** | Spese vive a fine turno (Affitto/Cibo) vs Solo sanzioni per errori | Introduce una reale pressione temporale: lavorare lentamente porta all'arresto per insolvenza anche senza commettere errori. |
| **Rendering Quotidiani 5+** | Layout tipografico procedurale Top Screen vs Generazione continua file PNG | Prestazioni perfette a 60 FPS e zero deallocazioni/frammentazione memoria heap su Old 3DS. |

---

## 4. Specifiche Tecniche e Architetturali

### 4.1. Funzione `GET_DAY_CONFIG(day)`
Sostituisce gli accessi a `DAYS_CONFIG[CURRENT_DAY]`:
```lua
function GET_DAY_CONFIG(day)
    if day <= 4 and DAYS_CONFIG and DAYS_CONFIG[day] then
        return DAYS_CONFIG[day]
    end

    -- Generatore Deterministico Giorni 5+
    local tier = 1
    local daily_expenses = 20
    if day >= 16 then
        tier = 3
        daily_expenses = 30
    elseif day >= 9 then
        tier = 2
        daily_expenses = 25
    end

    -- Calcolo Data (base: 27.11.1982)
    local offset = day - 5
    local d_day = 27 + (offset % 30)
    local d_month = 11 + math.floor((27 + offset) / 30) % 12
    local d_year = 1982 + math.floor(offset / 365)
    local date_str = string.format("%02d.%02d.%04d", d_day, d_month, d_year)

    -- Determinazione Regole Speciali (Embargo & Most Wanted)
    local prng = (day * 1103515245 + 12345) % 2147483648
    local embargo_nation = nil
    local wanted_name = nil
    local bulletin_rules = {
        "ALL FOREIGNERS REQUIRE ENTRY PERMIT",
        "WORKERS REQUIRE VALID WORK PASS"
    }

    local FOREIGN_NATIONS = { "ANTEGRIA", "IMPOR", "KOLECHIA", "REPUBLIA", "UF", "OBRISTAN" }

    if tier >= 1 and (prng % 3 == 0) then
        local nat_idx = ((prng / 7) % #FOREIGN_NATIONS) + 1
        embargo_nation = FOREIGN_NATIONS[math.floor(nat_idx)]
        table.insert(bulletin_rules, "DENY ALL CITIZENS OF " .. embargo_nation)
    end

    if tier >= 2 and (prng % 2 == 0) then
        local w_first = MNAMES.FN[math.floor((prng / 13) % #MNAMES.FN) + 1]
        local w_last = MNAMES.LN[math.floor((prng / 17) % #MNAMES.LN) + 1]
        wanted_name = w_first .. " " .. w_last
        table.insert(bulletin_rules, "WANTED CRIMINAL: " .. wanted_name)
    end

    table.insert(bulletin_rules, "VERIFY PURPOSE AND DURATION IN TRANSCRIPT")

    return {
        date             = date_str,
        headline         = embargo_nation and ("RESTRICTIONS ON " .. embargo_nation) or "BORDER SECURITY TIGHTENED",
        subline          = "Ministry of Admission issues high alert directives.",
        bulletin_rules   = bulletin_rules,
        allow_foreigners = true,
        require_permit   = true,
        require_workpass = true,
        embargo_nation   = embargo_nation,
        wanted_name      = wanted_name,
        daily_expenses   = daily_expenses,
        duration_sec     = 180
    }
end
```

### 4.2. Logica di Ispezione in `CHECK_EMPTYTABLE()`
Quando un viaggiatore riceve il timbro APPROVED (Verde):
1. **Verifica Embargo**: Se `day_cfg.embargo_nation` corrisponde alla nazione del passaporto (`PERSON.passport` mappato al nome nazione), la decisione è errata:
   * Errore: `"VIOLATION OF DIPLOMATIC SANCTIONS"`.
2. **Verifica Ricercato (Most Wanted)**: Se il nome completo del viaggiatore corrisponde a `day_cfg.wanted_name`, la decisione è errata:
   * Errore: `"WANTED FUGITIVE ADMITTED"`.
3. **Verifica Transcript (Durata e Scopo)**: Se la durata dichiarata a voce differisce dalla stringa `ENTRYPERMIT.duration`, o se lo scopo è lavorativo senza `WORKPASS`, la decisione è errata:
   * Errore: `"ENTRY PERMIT DURATION MISMATCH"`.

### 4.3. Calcolo Finanziario in `menu == "DaySummary"`
1. A fine giornata (18:00):
   ```lua
   local day_cfg = GET_DAY_CONFIG(CURRENT_DAY)
   local expenses = day_cfg.daily_expenses or 20
   SCORE = SCORE - expenses
   ```
2. Rendering del riepilogo su Bottom Screen:
   * Entrate: `"+" .. tostring(DAY_CORRECT_COUNT * 5) .. " CREDITS"`
   * Spese Famiglia (Affitto, Cibo): `"-" .. tostring(expenses) .. " CREDITS"`
   * Saldo Risparmi: `tostring(SCORE) .. " CREDITS"`
3. Pulsante **NEXT DAY (A)**:
   * Sempre disponibile se `SCORE >= 0`.
   * Incrementa `CURRENT_DAY = CURRENT_DAY + 1` e salva il nuovo giorno su SD (`sdmc:/3ds/papersplease_save.dat`).
4. Pulsante **RETRY DAY (A)**:
   * Attivo se `SCORE < 0` (schermata di debito/arresto).
   * Ripristina `SCORE = DAY_START_SCORE` e ricarica il giorno corrente con le stesse regole.

---

## 5. Piano di Validazione e Test

1. **Verifica Retrocompatibilità (Giorni 1–4)**:
   * Avviare la campagna dal Giorno 1 e verificare che i primi 4 giorni mantengano i quotidiani grafici e le regole originali.
2. **Transizione Giorno 4 -> Giorno 5**:
   * Completare il Giorno 4 e verificare che il pulsante mostri correttamente `NEXT DAY (A)` anziché bloccare il gioco su "CAMPAIGN COMPLETE!".
3. **Rendering Procedurale del Giornale (Giorno 5+)**:
   * Verificare che il Top Screen mostri l'intestazione tipografica, data calcolata, titolo e sottotitolo corretti senza crash di texture.
4. **Ispezione Embargo & Ricercati**:
   * Approvare un viaggiatore della nazione in embargo o il criminale segnalato nel bollettino per verificare l'emissione della citazione e la detrazione della multa dopo 10 secondi.
5. **Bilancio Spese & Arresto per Insolvenza**:
   * Terminare un turno processando 0 persone o subendo multe per testare l'attivazione della schermata cupa di arresto ministeriale per insolvenza economica.
