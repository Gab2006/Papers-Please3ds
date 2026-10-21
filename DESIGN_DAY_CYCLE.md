# Specifiche di Design: Modalità Storia a Giornate e Bollettino Quotidiano
> **Papers, Please: 3DS Homebrew Demake**  
> Data di validazione: Ottobre 2026

---

## 1. Understanding Summary

* **Cosa stiamo creando**: La modalità principale **"Story / Campagna"** articolata in giornate progressive (Giorni 1–4 per la prima milestone), completa di bollettino quotidiano mattutino, turno a tempo con orologio di frontiera (09:00–18:00), regole ed errori condizionati dal giorno, schermata di riepilogo a fine turno e salvataggio permanente su scheda SD.
* **Perché esiste**: Per superare l'attuale natura puramente arcade e riprodurre fedelmente la progressione, la tensione e la curva di apprendimento dell'opera originale di Lucas Pope.
* **A chi è rivolto**: Utenti di Nintendo 3DS / 2DS / New 3DS tramite homebrew LPP-3DS.
* **Vincoli tecnici principali**:
  * Risoluzioni hardware: Schermo superiore (400x240) e Schermo inferiore touch (320x240).
  * Storage: `romfs:/` è in sola lettura su console; i salvataggi devono risiedere su SD (`sdmc:/`).
  * Memoria e stabilità: Nessun caricamento/scaricamento dinamico di texture durante il gameplay su Old 3DS.
  * Architettura procedurale Lua 5.1 senza moduli o require esterni.
* **Non-obiettivi per questa milestone**:
  * Sistema economico/gestionale (affitto, riscaldamento, cibo, salute della famiglia).
  * Trama complessa con l'Ordine di Arstotzka (EZIC) e personaggi scriptati.
  * Meccaniche di scanner a raggi X e rilevamento impronte digitali.

---

## 2. Assunzioni e Regole per Giornata

1. **Giorno 1 (23.11.1982)**:
   * **Regola**: Ammessi esclusivamente i cittadini di Arstotzka (`passport == 2`).
   * **Documenti**: Solo passaporto e carta d'identità per Arstotzkiani; passaporto semplice per stranieri. Nessun Entry Permit generato.
   * **Esito**: Tutti gli stranieri devono ricevere timbro **DENIED (Rosso)**. Gli Arstotzkiani possono essere validi o avere errori interni (scadenza, città falsa, ecc.).
2. **Giorno 2 (24.11.1982)**:
   * **Regola**: Stranieri ammessi purché in possesso di passaporto valido e non scaduto.
   * **Documenti**: Solo passaporti (e carte d'identità per Arstotzkiani). Nessun Entry Permit ancora richiesto.
3. **Giorno 3 (25.11.1982)**:
   * **Regola**: Gli stranieri devono obbligatoriamente presentare l'Entry Permit.
   * **Documenti**: Passaporto + Entry Permit per tutti gli stranieri. Verifiche di concordanza (Nome, ID, data scadenza, sigillo MOA).
4. **Giorno 4 (26.11.1982)**:
   * **Regola**: Gli stranieri che dichiarano scopo di soggiorno lavorativo ("WORK") devono esibire anche il Work Pass valido.
   * **Documenti**: Passaporto + Entry Permit (+ Work Pass per lavoratori). Verifica sigillo MOL e scadenza.

---

## 3. Decision Log (Registro delle Decisioni)

| Decisione | Opzioni Considerate | Motivazione della Scelta |
|---|---|---|
| **Integrazione nel Menu** | Nuova modalità Campagna vs Sostituzione totale vs Course selector | Preserva completamente le modalità arcade esistenti (Time, Perfect, Score) senza rischi di regressione. |
| **Condizione Fine Turno** | Orologio di frontiera (09:00–18:00) vs Conteggio persone | Rispecchia fedelmente l'originale, creando il fattore di fretta e tensione decisionale. |
| **Presentazione Bollettino** | Dual-Screen (Top: Giornale, Bottom: Direttive) vs Schermo singolo | Valorizza la configurazione nativa a due schermi del 3DS con massima chiarezza e immersione. |
| **Architettura Regole** | Tabella dichiarativa `DAYS_CONFIG` vs if/else sparsi nel codice | Altamente estendibile (aggiungere i Giorni 5–31 richiederà solo nuove voci in tabella). |
| **Persistenza Salvataggio** | File su SD `sdmc:/3ds/papersplease/save.dat` vs Solo RAM | Consente di chiudere la console e riprendere dall'ultimo giorno sbloccato. |

---

## 4. Specifiche Tecniche di Implementazione

### 4.1. Modello Dati (`DAYS_CONFIG` in `DataFile.lua`)
```lua
DAYS_CONFIG = {
  [1] = {
    date = "23.11.1982",
    headline = "GRESTIN BORDER REOPENS",
    subline = "Six-year war with Kolechia is over.",
    bulletin_rules = {
      "SOLO CITTADINI DI ARSTOTZKA AMMESSI",
      "RESPINGERE TUTTI GLI STRANIERI",
      "CONTROLLA SCADENZA E VALIDITA' DOCUMENTI"
    },
    allow_foreigners = false,
    require_permit   = false,
    require_workpass = false,
    duration_sec     = 180
  },
  [2] = {
    date = "24.11.1982",
    headline = "FOREIGNERS NOW ALLOWED",
    subline = "Ministry permits entry for non-citizens.",
    bulletin_rules = {
      "STRANIERI AMMESSI CON PASSAPORTO VALIDO",
      "CONTROLLA DATA DI SCADENZA E CITTA'",
      "RESPINGI PASSAPORTI CONTRAFFATTI O SCADUTI"
    },
    allow_foreigners = true,
    require_permit   = false,
    require_workpass = false,
    duration_sec     = 180
  },
  [3] = {
    date = "25.11.1982",
    headline = "SECURITY MEASURES TIGHTENED",
    subline = "New entry permit required for foreigners.",
    bulletin_rules = {
      "STRANIERI DEVONO PRESENTARE ENTRY PERMIT",
      "CONFRONTA NOME E NUMERO ID TRA DOCUMENTI",
      "VERIFICA SIGILLO MINISTERO AMMISSIONE (MOA)"
    },
    allow_foreigners = true,
    require_permit   = true,
    require_workpass = false,
    duration_sec     = 180
  },
  [4] = {
    date = "26.11.1982",
    headline = "LABOR RESTRICTIONS IN EFFECT",
    subline = "Workers require valid Arstotzkan work pass.",
    bulletin_rules = {
      "SCOPO LAVORO RICHIEDE WORK PASS VALIDO",
      "VERIFICA SCADENZA E SIGILLO LAVORO (MOL)",
      "TUTTI I DOCUMENTI DEVONO COINCIDERE"
    },
    allow_foreigners = true,
    require_permit   = true,
    require_workpass = true,
    duration_sec     = 180
  }
}
```

### 4.2. Nuovi Stati della Macchina a Stati (`menu`)
* `menu = "DayIntro"`:
  * Top Screen (400x240): Disegna la texture autentica del quotidiano *The Truth of Arstotzka* (`NEWS_DAY1.png` .. `NEWS_DAY4.png` in `ASSETS/`, resampled Lanczos a 400x240 con unsharp mask), caricata in lazy-loading in base a `CURRENT_DAY` e deallocata all'apertura del checkpoint.
  * Bottom Screen (320x240): Disegna il bollettino ufficiale del Ministero dell'Ammissione con layout burocratico a pergamena, intestazione cremisi, direttive del giorno e pulsante touch/A "APRI CHECKPOINT", più shortcut (B) per il menu.
* `menu = 2` (Gameplay):
  * Gestisce il decremento del tempo dalle 09:00 alle 18:00 in base a `duration_sec`.
  * Alle 18:00, attende la restituzione dei documenti dell'ultimo viaggiatore, poi abbassa la saracinesca (`CAGE`), esegue un fade out progressivo a nero su entrambi gli schermi, e passa a `menu = "DaySummary"` con un fade in altrettanto fluido.
* `menu = "DaySummary"`:
  * Mostra il rendiconto del turno: Viaggiatori totali, decisioni corrette, infrazioni commesse.
  * Esegue `SAVE_GAME(CURRENT_DAY + 1)`.
  * Pulsante touch "PROSSIMO GIORNO" o "ESCI AL MENU".

### 4.3. Modifiche a `RANDOMIZE()` e `CHECK_EMPTYTABLE()`
* `RANDOMIZE()`:
  * Se `DAYS_CONFIG[CURRENT_DAY].require_permit == false`, non inserisce `ENTRYPERMIT` in `DESKTOP`/`ALLITEMS`.
  * Se `DAYS_CONFIG[CURRENT_DAY].require_workpass == false`, non inserisce `WORKPASS`.
* `CHECK_EMPTYTABLE()`:
  * Se `DAYS_CONFIG[CURRENT_DAY].allow_foreigners == false` e `PERSON.passport ~= 2`: il timbro corretto è tassativamente **NO (DENIED)**.

### 4.4. Modulo di Salvataggio e Ripresa (`SAVE_GAME()` e `LOAD_GAME()`)
* Salva in `/3ds/papersplease_save.dat` (o `papersplease_save.dat` locale come fallback).
* **Formato Dati**: Chiavi dichiarative (`DAY`, `IN_PROGRESS`, `ELAPSED`, `INSPECTED`, `CORRECT`, `MISTAKES`, `SCORE`, `WRONGMANN`, `PEOPLESCORE`). Retrocompatibile con file numerici legacy (`"1"` .. `"4"`).
* **Salvataggio In-Game Mid-Shift**:
  * Uscendo tramite "MAIN MENU" o "QUIT" dal menu di pausa in modalità storia, viene invocato automaticamente `SAVE_STORY_PROGRESS()`, che serializza `in_progress = 1` e il tempo trascorso (`DAY_TIME_OFFSET`), oltre ai contatori ispezioni, decisioni corrette ed errori.
* **Ripresa Partita**:
  * Avviando la Modalità Storia dal titolo, se è presente una sessione `in_progress == 1`, il gioco ripristina all'istante l'orologio doganale (tempo residuo sincronizzato con lancette e HUD), i punteggi e la scrivania al checkpoint (`CheckPoint = 1`), riprendendo direttamente il turno (`menu = 2`).
  * Se la sessione era terminata o tra giornate (`in_progress == 0`), il gioco apre regolarmente il bollettino mattutino (`menu = "DayIntro"`).
  * Opzione tasto `(X)` nella schermata titolo per azzerare il salvataggio e ricominciare la campagna dal Giorno 1.
* All'uscita dal Giorno 4, notifica il completamento della prima campagna iniziale.

---

## 5. Piano di Verifica e Test

1. **Test Giorno 1**:
   * Ammettere cittadino Arstotzka valido -> Esito positivo.
   * Ammettere viaggiatore straniero -> Violazione di protocollo / Errore.
   * Respingere viaggiatore straniero -> Esito positivo.
2. **Test Giorno 2**:
   * Ammettere viaggiatore straniero con passaporto valido -> Esito positivo (nessun permit richiesto).
3. **Test Giorno 3**:
   * Verificare comparsa dell'Entry Permit per tutti gli stranieri.
4. **Test Giorno 4**:
   * Verificare comparsa del Work Pass per viaggiatori stranieri con scopo lavorativo.
5. **Test Persistenza**:
   * Completare Giorno 1, chiudere il software e verificare riavvio automatico al Giorno 2.
