# Architecture & Technical Specifications: Text Pipeline Optimization and 60 FPS Fluidity

## 1. Context & Objectives
During gameplay on the checkpoint inspection desk (`menu == 2`), when two or more documents are open simultaneously (Passport, Entry Permit, ID Card, Work Pass, Rulebook, Transcript), the Nintendo 3DS console exhibits a noticeable frame rate drop below the 60 FPS target. This slowdown degrades stylus drag responsiveness and slows down the stamp tray sliding animation (`STAMP_CODE()`).

The objective is to achieve and maintain a **rock-solid 60 FPS** even with all documents open on the desk, while preserving **100% visual fidelity** (identical bitmap fonts, layouts, colors, and shadows).

---

## 2. Bottleneck Analysis

1. **Excessive Temporary String Allocations (GC Stutter)**:
   In `LOAD_TEXT()`, every frame repeatedly invoked `string.upper()` across all metadata fields of open documents (`string.upper(PERSON.permitname)`, `string.upper(PERSON.permitpurpose)`, etc.). In Lua 5.1, every newly created string allocates heap memory managed by the Garbage Collector. With 2+ open documents, dozens of strings were instantiated per frame, triggering frequent Garbage Collection cycles that caused micro-freezes and frame drops.

2. **Dual-Pass Measurement in Aligned Text**:
   In `GPU_DrawText()`, for centered (`option == "c"`) and right-aligned (`option == "r"`) text, a first pass iterated through all glyphs to calculate the total line width (`total_w`), followed by a second pass submitting glyph quads to the GPU. This measurement was completely redundant, as demographic paperwork fields remain invariant throughout the entrant's turn.

3. **Unfiltered GPU Draw Calls (Lack of Counter Occlusion Culling)**:
   When an open document was dragged partially beneath the upper counter shelf (`y < 67`), `GPU_DrawText()` continued dispatching draw commands for hidden text lines, which were subsequently overwritten by the counter background texture (`BKG_BTMS`).

4. **O(N×M) Item Lookup Loops**:
   Scanning open desk items (`DESKTOP` and `ALLITEMS`) was performed using nested $O(N \times M)$ loops multiple times per frame.

---

## 3. Decision Log

| ID | Decision | Alternatives Considered | Technical Rationale |
|---|---|---|---|
| **DEC-01** | **Zero-Allocation Text Pipeline (Static Descriptors)** | Pre-baking to VRAM texture (Render-to-Texture), dynamic LOD during drag | LPP-3DS does not support FBO/Render-to-Texture from Lua; dynamic LOD would degrade visual quality. Static descriptors retain 100% graphics fidelity and eliminate CPU/GC overhead. |
| **DEC-02** | **Precomputed Text Widths in `RANDOMIZE()`** | On-demand measurement with string memoization | Precomputing immediately upon entrant generation eliminates runtime branching and hashing during the 60 FPS frame loop. |
| **DEC-03** | **Counter-Shelf Occlusion Culling (`y < 65`)** | Indiscriminate drawing with overdraw | Discarding text lines hidden behind the counter shelf saves 40–60 `Graphics.drawPartialImage()` draw calls per document. |
| **DEC-04** | **Direct O(1) Item Lookup Map** | Maintaining nested linear scans over `ALLITEMS` | Direct table mapping `ITEMS_MAP[key]` completely eliminates redundant loop iterations in the rendering pipeline. |

---

## 4. Detailed Technical Architecture

### 4.1 Data Model `DOC_TEXT_CACHE`
In `index.lua`, during entrant generation in `RANDOMIZE()`, the centralized cache structure is populated:

```lua
DOC_TEXT_CACHE = {
    PASSPORT = {
        -- Specific fields for active passport layout (1..8)
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

### 4.2 Optimization of `GPU_DrawText()` in `FontInfo.lua`
The `GPU_DrawText` function accepts an optional parameter `precomputed_w`:
- If supplied, it bypasses the initial string measurement loop and directly evaluates alignment coordinates:
  - `option == "c"`: `local px = x - math.floor(precomputed_w / 2) + str_width`
  - `option == "r"`: `local px = x - precomputed_w + str_width`
- If `y > 240` or `y < 65` (for items positioned under the desk counter `now == 0`), text lines are culled before iterating over characters.

### 4.3 Unified Rendering in `LOAD_TEXT(key)`
`LOAD_TEXT` accesses `DOC_TEXT_CACHE[key]`:
- For each cached descriptor field:
  ```lua
  local actual_y = doc.y + field.y_off
  if actual_y >= 65 and actual_y <= 240 then
      GPU_DrawText(doc.x + field.x_off, actual_y, field.text, field.color, field.align, 320, field.font, field.size, field.w)
  end
  ```
- Zero string allocations per frame.
- Zero redundant passes.
- Instant mathematical culling of shelf-occluded lines.

---

## 5. Verification Plan & Success Criteria

1. **60 FPS Fluidity**: While dragging 2 or more open documents across the desk, perceived frame rate remains steady and stutter-free on Nintendo 3DS hardware.
2. **Stamp Drawer Responsiveness**: Opening and closing the stamp rack animates at full speed without lag when multiple documents are open.
3. **Visual Integrity**: No pixel shifts, color anomalies, font mismatches, spacing discrepancies, or shadow regressions compared to original visuals.
