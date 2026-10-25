# Operational Implementation Plan: 60 FPS Fluidity Optimization

## Phase Roadmap

- [x] **Phase 1: Text Rendering Engine Optimization (`FontInfo.lua`)**
  - [x] Implement `GPU_MeasureText(text, size)` for fast static pixel width calculations.
  - [x] Extend `GPU_DrawText()` to accept `precomputed_w`: eliminating the initial scan pass for centered (`"c"`) and right-aligned (`"r"`) text.
  - [x] Guarantee 100% backwards compatibility for invocations without the optional width argument.

- [x] **Phase 2: Static Descriptor Subsystem Creation (`index.lua`)**
  - [x] Implement `BUILD_DOC_TEXT_CACHE()` to precompute and normalize entrant paperwork text fields during `RANDOMIZE()`.
  - [x] Configure descriptor fields for all 8 passport layouts (`PERSON.passport == 1..8`).
  - [x] Configure descriptor fields for `ENTRYPERMIT`, `IDCARD`, and `WORKPASS`.
  - [x] Configure dynamic descriptor caching for `TRANSCRIPT` dialogues and `CITATIONS` (MOA slips).

- [x] **Phase 3: Refactoring of `LOAD_TEXT()` & Counter Occlusion Culling**
  - [x] Rewrite `LOAD_TEXT(key)` to iterate over pre-compiled descriptors without heap string allocations or `string.upper()` calls.
  - [x] Implement shelf occlusion culling: `if actual_y >= 65 and actual_y <= 240`.
  - [x] Preserve rendering of biometric ID photos and border clearance stamps (`YES` / `NO`).

- [x] **Phase 4: Item Lookup Optimization & Main Loop**
  - [x] Introduce O(1) table `ITEM_BY_KEY` to eliminate nested linear iterations over `ALLITEMS`.
  - [x] Optimize stamp drawer animation timing in `STAMP_CODE()`.

- [x] **Phase 5: Build, Validation & Package Release**
  - [x] Full rebuild of `Papers Please.cxi` and `Papers Please.cia`.
  - [x] Validate zero visual regressions, stutter-free dragging, and 60 FPS fluidity.
