#!/usr/bin/env python3
"""
optimize_sounds.py — Batch audio converter & optimizer for Papers, Please: 3DS.
Converts raw audio assets from `sounds/` to:
1. Short SFX: 16-bit PCM Mono WAV @ 22050 Hz (zero-latency, tiny RAM footprint).
2. Peak volume normalization to 12,000 (out of 32,768, ~36.6% / -8.7 dBFS).
   This perfectly compensates for LPP-3DS's hardcoded CSND mono pan (0xFFFFFFFF = 200% volume),
   preventing 16-bit DAC register overflow / earrape while making quiet sounds clearly audible.
Output is saved to `ASSETS/SOUND/`.
"""

import os
import struct
import sys
import wave

TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(TOOLS_DIR, ".."))
# Look for sounds in project folder, parent Desktop folder, or tools folder
CANDIDATES = [
    os.path.join(PROJECT_ROOT, "sounds"),
    os.path.join(os.path.dirname(PROJECT_ROOT), "sounds"),
    os.path.join(TOOLS_DIR, "sounds")
]
SRC_DIR = None
for c in CANDIDATES:
    if os.path.exists(c):
        SRC_DIR = c
        break

DEST_DIR = os.path.join(PROJECT_ROOT, "ASSETS", "SOUND")

# Standardized aliases for gameplay SFX
SFX_ALIASES = {
    "paper-dragstart0.wav": "paper-dragstart.wav",
    "paper-dragstop0.wav": "paper-dragstop.wav",
    "paper-turnpage0.wav": "paper-turnpage.wav",
    "metal-dragstart0.wav": "metal-dragstart.wav",
    "metal-dragstop0.wav": "metal-dragstop.wav",
    "text-reveal0.wav": "text-reveal.wav",
}

def process_file(src_path, dst_path, target_peak=12000):
    with wave.open(src_path, "rb") as w_in:
        nchannels = w_in.getnchannels()
        sampwidth = w_in.getsampwidth()
        framerate = w_in.getframerate()
        nframes = w_in.getnframes()
        raw = w_in.readframes(nframes)

    if sampwidth != 2:
        print(f"Skipping {src_path}: unsupported bit depth")
        return

    samples = struct.unpack(f"<{len(raw)//2}h", raw)

    # Downmix stereo to mono
    if nchannels == 2:
        mono = [(samples[i * 2] + samples[i * 2 + 1]) // 2 for i in range(nframes)]
    else:
        mono = list(samples)

    # Resample 44100 Hz -> 22050 Hz
    if framerate == 44100:
        mono = mono[::2]

    # Normalize peak amplitude (capped at 15x gain for very quiet recordings)
    max_val = max(abs(s) for s in mono) if mono else 1
    if max_val == 0:
        max_val = 1
    gain = min(target_peak / max_val, 15.0)

    scaled = [max(-32767, min(32767, int(s * gain))) for s in mono]
    out_raw = struct.pack(f"<{len(scaled)}h", *scaled)

    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
    with wave.open(dst_path, "wb") as w_out:
        w_out.setnchannels(1)
        w_out.setsampwidth(2)
        w_out.setframerate(22050)
        w_out.writeframes(out_raw)

def main():
    if not SRC_DIR:
        print("Error: Source directory 'sounds' not found in workspace or Desktop.")
        sys.exit(1)

    os.makedirs(DEST_DIR, exist_ok=True)
    wav_files = [f for f in os.listdir(SRC_DIR) if f.lower().endswith(".wav")]
    print(f"Found {len(wav_files)} source WAV files in {SRC_DIR}")

    converted_count = 0
    for filename in sorted(wav_files):
        src_path = os.path.join(SRC_DIR, filename)
        dest_path = os.path.join(DEST_DIR, filename)

        process_file(src_path, dest_path)
        converted_count += 1

        if filename in SFX_ALIASES:
            alias_dest = os.path.join(DEST_DIR, SFX_ALIASES[filename])
            process_file(src_path, alias_dest)
            converted_count += 1

    print(f"\nOptimization complete! Processed {converted_count} clean normalized WAV effects in {DEST_DIR}.")

if __name__ == "__main__":
    main()
