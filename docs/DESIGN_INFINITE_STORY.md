# Design Specifications: Infinite Story Mode & Complexity Escalation
> **Papers, Please: 3DS Homebrew Demake**  
> Validation Date: October 2026

---

## 1. Understanding Summary

* **What we are creating**: A procedural engine for **Infinite Days (Day 5, 6... N)** for the Story/Campaign Mode, featuring continuous difficulty progression, new geopolitical directives, Most Wanted criminal lists, transcript cross-verification, and a daily economic balance sheet with family subsistence expenses.
* **Why it exists**: Previously, Story Mode ended at Day 4 with a "CAMPAIGN COMPLETE!" notice. This system makes the border inspector career virtually limitless and progressively more demanding, faithfully reproducing the managerial depth and bureaucratic tension of the original game.
* **Target Audience**: Players of *Papers, Please* on Nintendo 3DS / 2DS / New 3DS via the Lua Player Plus (LPP-3DS) homebrew environment.
* **Key Mechanics**:
  1. **Procedural Day Generator (`GET_DAY_CONFIG`)**: Replaces the static table for `day >= 5`, calculating date, headline, bulletin rules, embargoes, and wanted fugitives deterministically.
  2. **Rotating Geopolitical Embargo**: Temporary diplomatic bans ordering the categorical denial of citizens from a specific foreign nation.
  3. **'Most Wanted' Fugitive List**: High-profile criminals flagged in the morning MOA bulletin that must be denied to prevent severe infractions.
  4. **Transcript Cross-Verification**: Matching checks between traveler verbal statements (visit purpose and duration) and submitted documents (Entry Permit / Work Pass).
  5. **Family Subsistence Balance**: End-of-shift deductions for fixed living costs (Rent, Food, Heating) to prevent passive credit hoarding and maintain the threat of debt arrest (`SCORE < 0`).
* **Core Technical Constraints**:
  * VRAM limits on Old 3DS: no additional PNG assets loaded for individual infinite days; uses procedural typographic rendering for newspapers and bulletins.
  * Full compatibility with the SD card save format (`sdmc:/3ds/papersplease_save.dat`).
  * Steady 60 FPS execution without massive allocations or sudden garbage collection spikes mid-shift.
* **Non-Goals**:
  * Branching story paths with multiple EZIC Order endings (the focus is infinite border simulation).
  * New physical touch accessories (X-ray scanner or biometric fingerprint scanner).

---

## 2. Assumptions & Progression Parameters

1. **Canonical Continuity (Days 1–4)**:
   * The first 4 days remain untouched as historical tutorials (using static graphic assets `NEWS_DAY1.png` .. `NEWS_DAY4.png` and fixed directives).
2. **Tier-Based Escalation System**:
   * **Tier 1 (Days 5–8)**: Low tension. Subsistence expenses = **20 credits**. Introduces occasional transcript discrepancies or diplomatic embargoes.
   * **Tier 2 (Days 9–15)**: Moderate tension. Subsistence expenses = **25 credits**. Activates the *Most Wanted* list (1 flagged fugitive) and strict document verification.
   * **Tier 3 (Days 16+)**: High alert. Subsistence expenses = **30 credits**. Up to 2 concurrent restrictions active (embargo + wanted fugitive + all documents required).
3. **Day Determinism**:
   * Configuration for day `N` (date, headline, rules, wanted criminal, embargo) is derived from the day number seed (`day`), ensuring that replaying the shift (*RETRY DAY*) yields the identical scenario.
4. **Inspection Rates vs. Expenses**:
   * Earning per correct clearance: **+5 credits**.
   * With expenses between 20 and 30 credits, the inspector must successfully clear at least **4–6 clean inspections** per shift to break even.

---

## 3. Decision Log

| Decision | Options Considered | Rationale |
|---|---|---|
| **Infinite Architecture** | Procedural shifts (Day 5..N) vs 31 fixed days vs cyclic New Game+ | Provides immediate infinite replayability with zero impact on Nintendo 3DS VRAM. |
| **Complexity Vectors** | Embargo + Most Wanted + Transcript vs New physical documents | Deepens mental verification and leverages existing assets without cluttering the small touchscreen (320x240). |
| **Subsistence Economy** | End-of-shift living costs (Rent/Food) vs mistake penalties only | Introduces genuine time pressure: working too slowly leads to debt arrest even without committing errors. |
| **Day 5+ Newspaper Rendering** | Procedural typography on Top Screen vs continuous PNG generation | Rock-solid 60 FPS performance and zero heap memory fragmentation on Old 3DS. |

---

## 4. Technical & Architectural Specifications

### 4.1. `GET_DAY_CONFIG(day)` Function
Replaces direct lookups into `DAYS_CONFIG[CURRENT_DAY]`:
```lua
function GET_DAY_CONFIG(day)
    if day <= 4 and DAYS_CONFIG and DAYS_CONFIG[day] then
        return DAYS_CONFIG[day]
    end

    -- Deterministic Generator for Days 5+
    local tier = 1
    local daily_expenses = 20
    if day >= 16 then
        tier = 3
        daily_expenses = 30
    elseif day >= 9 then
        tier = 2
        daily_expenses = 25
    end

    -- Date Calculation (base: 27.11.1982)
    local offset = day - 5
    local d_day = 27 + (offset % 30)
    local d_month = 11 + math.floor((27 + offset) / 30) % 12
    local d_year = 1982 + math.floor(offset / 365)
    local date_str = string.format("%02d.%02d.%04d", d_day, d_month, d_year)

    -- Special Rule Determination (Embargo & Most Wanted)
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

### 4.2. Inspection Logic in `CHECK_EMPTYTABLE()`
When a traveler receives an APPROVED (Green) stamp:
1. **Embargo Check**: If `day_cfg.embargo_nation` matches the passport nation (`PERSON.passport` mapped to nation name), the decision is an infraction:
   * Infraction: `"VIOLATION OF DIPLOMATIC SANCTIONS"`.
2. **Most Wanted Check**: If the full name of the traveler matches `day_cfg.wanted_name`, the decision is an infraction:
   * Infraction: `"WANTED FUGITIVE ADMITTED"`.
3. **Transcript Check (Duration and Purpose)**: If the stated verbal duration contradicts `ENTRYPERMIT.duration`, or if visit purpose is employment without a valid `WORKPASS`, the decision is an infraction:
   * Infraction: `"ENTRY PERMIT DURATION MISMATCH"`.

### 4.3. Financial Calculation in `menu == "DaySummary"`
1. At end of shift (18:00):
   ```lua
   local day_cfg = GET_DAY_CONFIG(CURRENT_DAY)
   local expenses = day_cfg.daily_expenses or 20
   SCORE = SCORE - expenses
   ```
2. Rendering report on Bottom Screen:
   * Income: `"+" .. tostring(DAY_CORRECT_COUNT * 5) .. " CREDITS"`
   * Family Expenses (Rent, Food): `"-" .. tostring(expenses) .. " CREDITS"`
   * Total Savings Balance: `tostring(SCORE) .. " CREDITS"`
3. **NEXT DAY (A)** Button:
   * Always available when `SCORE >= 0`.
   * Increments `CURRENT_DAY = CURRENT_DAY + 1` and saves to SD card (`sdmc:/3ds/papersplease_save.dat`).
4. **RETRY DAY (A)** Button:
   * Enabled when `SCORE < 0` (debt arrest screen).
   * Restores `SCORE = DAY_START_SCORE` and reloads current day with identical rules.

---

## 5. Validation & Test Plan

1. **Backwards Compatibility Check (Days 1–4)**:
   * Launch campaign from Day 1 and verify that the first 4 days retain historical newspapers and rules.
2. **Transition Day 4 -> Day 5**:
   * Complete Day 4 and confirm that the interface offers `NEXT DAY (A)` instead of halting on "CAMPAIGN COMPLETE!".
3. **Procedural Newspaper Rendering (Day 5+)**:
   * Ensure Top Screen properly displays typographic mastheads, calculated calendar dates, dynamic headlines, and subtitles without texture issues.
4. **Embargo & Wanted Criminal Inspection**:
   * Approve an entrant from an embargoed nation or the listed fugitive to confirm that an MOA citation is dispatched and fine deducted after 10 seconds.
5. **Subsistence Expenses & Debt Arrest**:
   * End shift processing 0 entrants or incurring heavy fines to confirm triggering the somber Ministry debt arrest dossier screen.
