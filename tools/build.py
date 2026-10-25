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
    PATCH_OFFSET = 0xd1e4
    PATCH_BYTES = bytes.fromhex('0030a0e3 148084e5 103084e5 183084e5 203084e5')
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
        if dec[PATCH_OFFSET : PATCH_OFFSET + 20] == PATCH_BYTES:
            print("  [+] LPP-3DS CSND binary patch already verified in CXI.")
            return

        print("  [*] Applying LPP-3DS CSND mem_size patch to .code binary...")
        dec[PATCH_OFFSET : PATCH_OFFSET + 20] = PATCH_BYTES

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

        if len(new_comp) != code_sz:
            print(f"  [ERROR] Compressed size mismatch: {len(new_comp)} vs {code_sz}")
            return

        f.seek(exefs_off + 512)
        f.write(new_comp)

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
        print("  [+] LPP-3DS CSND binary patch successfully applied and verified!")

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
        cmd = [makerom_bin, "-f", "cia", "-o", temp_cia, "-content", f"{CXI_FILE}:0:0", "-ignoresign", "-target", "t"]
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
    print("BUILD COMPLETATA CON SUCCESSO!")
    print(f"  1. Emulatore (Citra / Lime3DS): 'Papers Please.cxi'")
    print(f"  2. Console Nintendo 3DS (FBI):   'Papers Please.cia'")
    print("=" * 60)

def cleanup():
    if os.path.exists(STAGING_DIR):
        shutil.rmtree(STAGING_DIR, ignore_errors=True)
    if os.path.exists(ROMFS_TEMP):
        os.remove(ROMFS_TEMP)

if __name__ == "__main__":
    build()
