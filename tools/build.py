"""
Build script for Papers, Please 3DS Demake.
Rebuilds both the CXI (Citra/Lime3DS) and the installable CIA (Nintendo 3DS).
Usage:
    python build.py
"""

import os
import sys
import struct
import hashlib
import shutil
import subprocess

TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(TOOLS_DIR, ".."))
CXI_FILE = os.path.join(PROJECT_ROOT, "Papers Please.cxi")
CIA_FILE = os.path.join(PROJECT_ROOT, "Papers Please.cia")
STAGING_DIR = os.path.join(PROJECT_ROOT, "_build_staging")
ROMFS_TEMP = os.path.join(PROJECT_ROOT, "_temp.romfs")
MKROMFS_BIN = r"C:\devkitPro\tools\bin\mkromfs3ds.exe"
MAKEROM_CANDIDATES = [
    os.path.join(TOOLS_DIR, "makerom.exe"),
    os.path.join(PROJECT_ROOT, "tools", "makerom.exe"),
    r"C:\devkitPro\tools\bin\makerom.exe"
]

# -------------------------------------------------------------
# Metadata Configuration (Nintendo 3DS Home Menu & System Info)
# -------------------------------------------------------------
APP_TITLE = "Papers, Please"
APP_DESCRIPTION = "Papers, Please (3DS Demake)"
APP_AUTHOR = "Gab2006"
APP_VERSION_MAJOR = 0
APP_VERSION_MINOR = 2
APP_VERSION_MICRO = 1
APP_VERSION_RAW = ((APP_VERSION_MAJOR & 0x3F) << 10) | ((APP_VERSION_MINOR & 0x3F) << 4) | (APP_VERSION_MICRO & 0x0F)
APP_VERSION_STRING = f"v{APP_VERSION_MAJOR}.{APP_VERSION_MINOR}.{APP_VERSION_MICRO}"


def build_ivfc_romfs(l3_data):
    """
    Wraps raw Level 3 RomFS filesystem data into a Nintendo 3DS IVFC
    (Integrity Verification File Container) hash tree.
    This is strictly required by Nintendo 3DS firmware and romfsInit() to mount romfs:/.
    """
    l3_size = len(l3_data)
    l3_pad_len = (4096 - (l3_size % 4096)) % 4096
    l3_padded = l3_data + b"\x00" * l3_pad_len

    # Level 2 hashes: SHA-256 for each 4096-byte block of Level 3
    l2_hashes = []
    for i in range(len(l3_padded) // 4096):
        blk = l3_padded[i * 4096 : (i + 1) * 4096]
        l2_hashes.append(hashlib.sha256(blk).digest())
    l2_data = b"".join(l2_hashes)
    l2_size = len(l2_data)
    l2_pad_len = (4096 - (l2_size % 4096)) % 4096
    l2_padded = l2_data + b"\x00" * l2_pad_len

    # Level 1 hashes: SHA-256 for each 4096-byte block of Level 2
    l1_hashes = []
    for i in range(len(l2_padded) // 4096):
        blk = l2_padded[i * 4096 : (i + 1) * 4096]
        l1_hashes.append(hashlib.sha256(blk).digest())
    l1_data = b"".join(l1_hashes)
    l1_size = len(l1_data)
    l1_pad_len = (4096 - (l1_size % 4096)) % 4096
    l1_padded = l1_data + b"\x00" * l1_pad_len

    # Master hash: SHA-256 of first 4096 bytes of Level 1
    master_hash = hashlib.sha256(l1_padded[:4096]).digest()

    def align(x, n):
        return (x + n - 1) & ~(n - 1)

    l1_log_off = 0
    l2_log_off = align(l1_log_off + l1_size, 4096)
    l3_log_off = align(l2_log_off + l2_size, 4096)

    # IVFC Header (0x5C bytes)
    header = bytearray(0x5C)
    header[0x00:0x04] = b"IVFC"
    header[0x04:0x08] = struct.pack("<I", 0x10000)
    header[0x08:0x0C] = struct.pack("<I", 0x20)  # master hash size

    # Level 1 descriptor
    header[0x0C:0x14] = struct.pack("<Q", l1_log_off)
    header[0x14:0x1C] = struct.pack("<Q", l1_size)
    header[0x1C:0x20] = struct.pack("<I", 12)  # log2(4096) = 12

    # Level 2 descriptor
    header[0x24:0x2C] = struct.pack("<Q", l2_log_off)
    header[0x2C:0x34] = struct.pack("<Q", l2_size)
    header[0x34:0x38] = struct.pack("<I", 12)

    # Level 3 descriptor
    header[0x3C:0x44] = struct.pack("<Q", l3_log_off)
    header[0x44:0x4C] = struct.pack("<Q", l3_size)
    header[0x4C:0x50] = struct.pack("<I", 12)

    # Header size
    header[0x54:0x58] = struct.pack("<I", 0x5C)

    # Page 0: IVFC header (0x00 - 0x5C) + Master Hash (0x60 - 0x80)
    page0 = bytearray(4096)
    page0[0x00:0x5C] = header
    page0[0x60:0x80] = master_hash

    return bytes(page0) + l3_padded + l1_padded + l2_padded

def uncompress_3ds_blz(compressed):
    comp_size = len(compressed)
    footer = compressed[-8:]
    bufferTopAndBottom, originalBottom = struct.unpack('<II', footer)
    uTop = bufferTopAndBottom & 0xFFFFFF
    uBottom = (bufferTopAndBottom >> 24) & 0xFF
    uncomp_size = comp_size + originalBottom
    out = bytearray(compressed)
    out.extend(b'\x00' * originalBottom)
    pDest = uncomp_size
    pSrc = comp_size - uBottom
    pEnd = comp_size - uTop
    while pSrc > pEnd:
        pSrc -= 1
        uFlag = out[pSrc]
        for i in range(8):
            if (uFlag << i) & 0x80 == 0:
                pDest -= 1
                pSrc -= 1
                out[pDest] = out[pSrc]
            else:
                pSrc -= 1
                nSize = out[pSrc]
                pSrc -= 1
                b2 = out[pSrc]
                nOffset = (((nSize & 0x0F) << 8) | b2) + 3
                nSize = ((nSize >> 4) & 0x0F) + 3
                pData = pDest + nOffset
                for j in range(nSize):
                    pDest -= 1
                    pData -= 1
                    out[pDest] = out[pData]
            if pSrc <= pEnd:
                break
    return bytes(out)

def patch_cxi_code_if_needed(cxi_path):
    """
    Verifies and applies essential low-level binary patches to LPP-3DS .code executable:
      1. CSND mem_size patch (offset 0xd1e4, 20 bytes): Prevents audio earrape, heap corruption,
         and CSND DMA runaway by enforcing mem_size = 0 on non-streaming WAV sound descriptors.
      2. Sleep / aptMainLoop hook (offset 0x124b8, 40 bytes in Screen.waitVblankStart):
         LPP-3DS natively only called aptMainLoop() in outer main() before lua_dofile, leaving the
         game's inner while true do loop completely detached from APT notifications. When the 3DS
         clamshell lid was shut, the console stopped receiving VBlank interrupts, locking the
         system into a permanent black screen freeze. This patch inserts bl aptMainLoop (0x1eac70)
         into Screen.waitVblankStart so sleep/wake cycles and LCD power backlights are handled
         seamlessly every frame.
    """
    CSND_PATCH_OFFSET = 0xd1e4
    CSND_PATCH_BYTES = bytes.fromhex('0030a0e3 148084e5 103084e5 183084e5 203084e5')

    SLEEP_PATCH_OFFSET = 0x124b8
    SLEEP_PATCH_BYTES = bytes.fromhex(
        '10402de9 '  # push {r4, lr}
        'eb6103eb '  # bl 0x1eac70 (aptMainLoop)
        '0110a0e3 '  # mov r1, #1
        '0200a0e3 '  # mov r0, #2
        '2e6b03eb '  # bl 0x1ed188 (gspWaitForVBlank)
        '0000a0e3 '  # mov r0, #0
        '1080bde8 '  # pop {r4, pc}
        '0000a0e1 '  # nop
        '0000a0e1 '  # nop
        '0000a0e1'   # nop
    )

    TOOL_3DSTOOL = os.path.join(TOOLS_DIR, "3dstool.exe")
    if not os.path.exists(TOOL_3DSTOOL):
        TOOL_3DSTOOL = os.path.join(PROJECT_ROOT, "tools", "3dstool.exe")

    with open(cxi_path, 'r+b') as f:
        ncch_hdr = bytearray(f.read(512))
        exefs_off = struct.unpack('<I', ncch_hdr[0x1A0:0x1A4])[0] * 512
        f.seek(exefs_off)
        exefs_hdr = bytearray(f.read(512))
        code_sz = struct.unpack('<I', exefs_hdr[12:16])[0]
        f.seek(exefs_off + 512)
        code_comp = f.read(code_sz)

        dec = bytearray(uncompress_3ds_blz(code_comp))
        csnd_ok = (dec[CSND_PATCH_OFFSET : CSND_PATCH_OFFSET + 20] == CSND_PATCH_BYTES)
        sleep_ok = (dec[SLEEP_PATCH_OFFSET : SLEEP_PATCH_OFFSET + 40] == SLEEP_PATCH_BYTES)

        if csnd_ok and sleep_ok:
            print("  [+] LPP-3DS binary patches (CSND mem_size & Sleep aptMainLoop) already verified in CXI.")
            return

        print("  [*] Applying LPP-3DS binary patches to .code executable...")
        if not csnd_ok:
            print("      - Applying CSND mem_size patch (offset 0xd1e4)")
            dec[CSND_PATCH_OFFSET : CSND_PATCH_OFFSET + 20] = CSND_PATCH_BYTES
        if not sleep_ok:
            print("      - Applying Sleep/APT aptMainLoop hook patch (offset 0x124b8)")
            dec[SLEEP_PATCH_OFFSET : SLEEP_PATCH_OFFSET + 40] = SLEEP_PATCH_BYTES

        temp_code = os.path.join(PROJECT_ROOT, "_temp_code.bin")
        temp_comp = os.path.join(PROJECT_ROOT, "_temp_comp.bin")
        with open(temp_code, 'wb') as tf:
            tf.write(dec)

        if not os.path.exists(TOOL_3DSTOOL):
            print("  [WARN] tools/3dstool.exe not found for blz recompression!")
            return

        res = subprocess.run([TOOL_3DSTOOL, "-z", "--compress-type", "blz", "-f", temp_code, "--compress-out", temp_comp], capture_output=True)
        if res.returncode != 0:
            print("  [ERROR] 3dstool compression failed:", res.stderr)
            return

        with open(temp_comp, 'rb') as cf:
            new_comp = cf.read()

        new_code_sz = len(new_comp)
        # Update .code size in ExeFS header
        exefs_hdr[12:16] = struct.pack('<I', new_code_sz)

        f.seek(exefs_off + 512)
        f.write(new_comp)

        # Zero-pad remaining space up to banner section offset (0x154400)
        pad_len = 0x154400 - new_code_sz
        if pad_len > 0:
            f.write(b"\x00" * pad_len)

        code_hash = hashlib.sha256(new_comp).digest()
        exefs_hdr[0x1E0:0x200] = code_hash
        f.seek(exefs_off)
        f.write(exefs_hdr)

        exefs_super_hash = hashlib.sha256(exefs_hdr).digest()
        ncch_hdr[0x1C0:0x1E0] = exefs_super_hash
        f.seek(0)
        f.write(ncch_hdr)

        if os.path.exists(temp_code): os.remove(temp_code)
        if os.path.exists(temp_comp): os.remove(temp_comp)
        print(f"  [+] LPP-3DS binary patches successfully applied and verified! (code_sz: {new_code_sz})")

def update_cxi_metadata(cxi_path):
    """
    Updates the SMDH icon metadata (Title, Description, Publisher) in ExeFS,
    recalculates ExeFS section & super hashes, and sets the NCCH header title version.
    Returns raw updated SMDH bytes for CIA injection.
    """
    with open(cxi_path, "r+b") as f:
        ncch_hdr = bytearray(f.read(512))
        exefs_off = struct.unpack("<I", ncch_hdr[0x1A0:0x1A4])[0] * 512
        f.seek(exefs_off)
        exefs_hdr = bytearray(f.read(512))

        # Find 'icon' section in ExeFS
        icon_idx = -1
        icon_off = 0
        icon_sz = 0
        for i in range(8):
            sec_name = exefs_hdr[i * 16 : i * 16 + 8].decode("ascii", errors="ignore").strip("\x00")
            if sec_name == "icon":
                icon_idx = i
                icon_off = struct.unpack("<I", exefs_hdr[i * 16 + 8 : i * 16 + 12])[0]
                icon_sz = struct.unpack("<I", exefs_hdr[i * 16 + 12 : i * 16 + 16])[0]
                break

        if icon_idx == -1 or icon_sz < 0x2008:
            print("  [WARN] ExeFS icon (SMDH) section not found or invalid in CXI.")
            return None

        f.seek(exefs_off + 512 + icon_off)
        smdh = bytearray(f.read(icon_sz))

        # Format metadata strings in UTF-16LE with null-termination padding
        # In 3DS SMDH, each title entry is 0x200 (512) bytes:
        #   0x000..0x080: Short Title (128 bytes = 64 UTF-16 chars)
        #   0x080..0x180: Long Title / Description (256 bytes = 128 UTF-16 chars)
        #   0x180..0x200: Publisher / Author (128 bytes = 64 UTF-16 chars)
        short_bytes = APP_TITLE.encode("utf-16le").ljust(0x80, b"\x00")[:0x80]
        long_bytes = APP_DESCRIPTION.encode("utf-16le").ljust(0x100, b"\x00")[:0x100]
        pub_bytes = APP_AUTHOR.encode("utf-16le").ljust(0x80, b"\x00")[:0x80]

        # Populate all 16 languages (Japanese, English, French, German, Italian, Spanish, etc.)
        for lang in range(16):
            entry_off = 8 + lang * 0x200
            smdh[entry_off : entry_off + 0x80] = short_bytes
            smdh[entry_off + 0x80 : entry_off + 0x180] = long_bytes
            smdh[entry_off + 0x180 : entry_off + 0x200] = pub_bytes

        # Write updated SMDH back to ExeFS
        f.seek(exefs_off + 512 + icon_off)
        f.write(smdh)

        # Update ExeFS section hash (stored in reverse order at end of ExeFS header)
        hash_off = 0x200 - (icon_idx + 1) * 32
        exefs_hdr[hash_off : hash_off + 32] = hashlib.sha256(smdh).digest()
        f.seek(exefs_off)
        f.write(exefs_hdr)

        # Update ExeFS super hash in NCCH header
        # NOTE: Do NOT touch ncch_hdr[0x112:0x114] (NCCH format version) — that field
        # must remain 2 (NCCH2 format). The application version is set via makerom flags.
        ncch_hdr[0x1C0:0x1E0] = hashlib.sha256(exefs_hdr).digest()

        f.seek(0)
        f.write(ncch_hdr)

    print(f"  + CXI metadata updated: Title='{APP_TITLE}', Publisher='{APP_AUTHOR}', Version={APP_VERSION_STRING}")

def build():
    print("=" * 60)
    print("Papers, Please 3DS - Full Builder (CXI & CIA)")
    print("=" * 60)

    if not os.path.exists(CXI_FILE):
        print(f"[ERROR] Base CXI file not found: {CXI_FILE}")
        sys.exit(1)

    if not os.path.exists(MKROMFS_BIN):
        print(f"[ERROR] mkromfs3ds tool not found: {MKROMFS_BIN}")
        print("Please ensure devkitPro is installed at C:\\devkitPro")
        sys.exit(1)

    # Ensure LPP-3DS code.bin has the CSND mem_size patch applied
    patch_cxi_code_if_needed(CXI_FILE)

    # 1. Clean and prepare staging directory with runtime files
    if os.path.exists(STAGING_DIR):
        shutil.rmtree(STAGING_DIR)
    os.makedirs(STAGING_DIR)

    print("[1/4] Gathering runtime files into RomFS staging...")
    runtime_files = ["index.lua", "DataFile.lua", "FontInfo.lua"]
    for f in runtime_files:
        src = os.path.join(PROJECT_ROOT, f)
        if os.path.exists(src):
            shutil.copy(src, os.path.join(STAGING_DIR, f))
            print(f"  + Added {f}")
        else:
            print(f"  [WARN] File {f} missing!")

    assets_dir = os.path.join(PROJECT_ROOT, "ASSETS")
    if os.path.exists(assets_dir):
        shutil.copytree(assets_dir, os.path.join(STAGING_DIR, "ASSETS"))
        print("  + Added ASSETS/ folder")
    else:
        print("  [ERROR] ASSETS/ directory missing!")
        sys.exit(1)

    # 2. Build RomFS binary
    print("[2/4] Packaging RomFS archive using mkromfs3ds...")
    res = subprocess.run([MKROMFS_BIN, STAGING_DIR, ROMFS_TEMP], capture_output=True, text=True)
    if res.returncode != 0:
        print("[ERROR] mkromfs3ds failed:", res.stderr)
        cleanup()
        sys.exit(1)

    with open(ROMFS_TEMP, "rb") as f:
        level3_romfs_data = f.read()

    # 3. Wrap RomFS into IVFC container and inject into NCCH / CXI
    print("[3/4] Wrapping RomFS into Nintendo IVFC container and updating NCCH...")
    new_romfs_data = build_ivfc_romfs(level3_romfs_data)

    # Align new RomFS to 512 bytes (media unit boundary)
    pad = (512 - (len(new_romfs_data) % 512)) % 512
    new_romfs_data += b"\x00" * pad

    with open(CXI_FILE, "rb") as f:
        cxi_header = bytearray(f.read(0x200))
        f.seek(0x1B0)
        romfs_offset_media = struct.unpack("<I", f.read(4))[0]
        romfs_offset = romfs_offset_media * 512
        f.seek(0x200)
        exefs_and_body = f.read(romfs_offset - 0x200)

    new_romfs_media = len(new_romfs_data) // 512
    total_media = romfs_offset_media + new_romfs_media

    # Update RomFS size in media units (offset 0x1B4)
    cxi_header[0x1B4:0x1B8] = struct.pack("<I", new_romfs_media)
    # Update RomFS hash region size in media units (offset 0x1B8, 1 media unit = 512 bytes)
    cxi_header[0x1B8:0x1BC] = struct.pack("<I", 1)
    # Update total content size in media units (offset 0x104)
    cxi_header[0x104:0x108] = struct.pack("<I", total_media)
    # Update RomFS superblock SHA-256 hash (offset 0x1E0: hash of first 512 bytes of IVFC container)
    cxi_header[0x1E0:0x200] = hashlib.sha256(new_romfs_data[:0x200]).digest()

    with open(CXI_FILE, "wb") as f:
        f.write(cxi_header)
        f.write(exefs_and_body)
        f.write(new_romfs_data)

    # Update metadata in CXI (SMDH with Title, Author, Description, and ExeFS hashes)
    update_cxi_metadata(CXI_FILE)

    print(f"  + CXI built successfully: {CXI_FILE} ({os.path.getsize(CXI_FILE):,} bytes)")

    # 4. Generate installable CIA
    print("[4/4] Building installable CIA package for Nintendo 3DS...")
    makerom_bin = None
    for cand in MAKEROM_CANDIDATES:
        if os.path.exists(cand):
            makerom_bin = cand
            break

    if makerom_bin:
        temp_cia = os.path.join(PROJECT_ROOT, "_pack_temp.cia")
        cmd = [
            makerom_bin,
            "-f", "cia",
            "-o", temp_cia,
            "-content", f"{CXI_FILE}:0:0",
            "-major", str(APP_VERSION_MAJOR),
            "-minor", str(APP_VERSION_MINOR),
            "-micro", str(APP_VERSION_MICRO),
            "-ignoresign",
            "-target", "t",
        ]
        res = subprocess.run(cmd, capture_output=True, text=True)

        if os.path.exists(temp_cia):
            if os.path.exists(CIA_FILE):
                os.remove(CIA_FILE)
            shutil.move(temp_cia, CIA_FILE)
            print(f"  + CIA built successfully: {CIA_FILE} ({os.path.getsize(CIA_FILE):,} bytes)")
        else:
            print("  [ERROR] makerom did not produce CIA output:")
            print("  Stdout:", res.stdout)
            print("  Stderr:", res.stderr)
            
        if os.path.exists(temp_cia):
            os.remove(temp_cia)
    else:
        print("  [WARN] makerom not found in tools/ or devkitPro, skipped CIA generation.")

    cleanup()

    print("=" * 60)
    print("BUILD COMPLETED SUCCESSFULLY!")
    print(f"  1. Emulator (Citra / Lime3DS):  'Papers Please.cxi'")
    print(f"  2. Nintendo 3DS Console (FBI):   'Papers Please.cia'")
    print("=" * 60)

def cleanup():
    if os.path.exists(STAGING_DIR):
        shutil.rmtree(STAGING_DIR, ignore_errors=True)
    if os.path.exists(ROMFS_TEMP):
        os.remove(ROMFS_TEMP)

if __name__ == "__main__":
    build()
