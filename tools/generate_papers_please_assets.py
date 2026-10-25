import os
import math
from PIL import Image, ImageDraw

TOOLS_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(TOOLS_DIR, ".."))
ASSETS_DIR = os.path.join(PROJECT_ROOT, "ASSETS")

def generate_all():
    os.makedirs(ASSETS_DIR, exist_ok=True)
    
    # -------------------------------------------------------------------------
    # COLOR PALETTES (Authentic Papers, Please values)
    # -------------------------------------------------------------------------
    C_DESK_DARK      = (25, 18, 18)       # Metal border / deep shadow
    C_DESK_SHADOW    = (50, 37, 37)       # Drop shadow
    C_DESK_MID       = (103, 108, 84)     # Shaded olive drab desk
    C_DESK_LIGHT     = (132, 138, 107)    # Classic olive desk surface
    C_DESK_HIGHLIGHT = (162, 169, 131)    # Edge highlight
    
    C_PAPER_BG       = (238, 235, 225)    # Clean off-white vintage newsprint
    C_PAPER_SHADE    = (212, 208, 196)    # Dither / shaded paper
    C_PAPER_BORDER   = (168, 160, 146)    # Document inner border
    
    C_INK_BLACK      = (24, 22, 22)       # Printer's black ink (newspaper title & eagles)
    C_INK_DARK       = (64, 62, 60)       # Medium dark ink / lines
    C_INK_MID        = (125, 120, 112)    # Newsprint dither text
    C_INK_LIGHT      = (188, 182, 172)    # Faint watermark & guidelines
    
    # MUTED SOVIET RED (Spento!)
    C_RED_DARK       = (52, 20, 20)       # Muted shadow
    C_RED_BANNER     = (82, 34, 34)       # Muted, dull, drab Soviet oxblood/burgundy
    C_RED_LIGHT      = (108, 48, 48)      # Muted highlight
    C_RED_STAMP_MUTE = (115, 48, 48)      # Faded vintage ink stamp for newspaper
    
    # OFFICIAL STAMP RED (Tranne per il rosso del timbro!)
    C_STAMP_PINK     = (245, 115, 115)    # Authentic official MOA stamp
    C_GOLD_TEXT      = (205, 195, 160)    # Sub-text on banner
    
    # -------------------------------------------------------------------------
    # Pixel Art Font: 5x7 Bitmap Font for authentic retro text
    # -------------------------------------------------------------------------
    FONT_5X7 = {
        'A': [" ### ", "#   #", "#   #", "#####", "#   #", "#   #", "#   #"],
        'B': ["#### ", "#   #", "#   #", "#### ", "#   #", "#   #", "#### "],
        'C': [" ####", "#    ", "#    ", "#    ", "#    ", "#    ", " ####"],
        'D': ["#### ", "#   #", "#   #", "#   #", "#   #", "#   #", "#### "],
        'E': ["#####", "#    ", "#    ", "#### ", "#    ", "#    ", "#####"],
        'F': ["#####", "#    ", "#    ", "#### ", "#    ", "#    ", "#    "],
        'G': [" ####", "#    ", "#    ", "# ###", "#   #", "#   #", " ####"],
        'H': ["#   #", "#   #", "#   #", "#####", "#   #", "#   #", "#   #"],
        'I': [" ### ", "  #  ", "  #  ", "  #  ", "  #  ", "  #  ", " ### "],
        'J': ["  ###", "    #", "    #", "    #", "    #", "#   #", " ### "],
        'K': ["#   #", "#  # ", "# #  ", "##   ", "# #  ", "#  # ", "#   #"],
        'L': ["#    ", "#    ", "#    ", "#    ", "#    ", "#    ", "#####"],
        'M': ["#   #", "## ##", "# # #", "#   #", "#   #", "#   #", "#   #"],
        'N': ["#   #", "##  #", "# # #", "#  ##", "#   #", "#   #", "#   #"],
        'O': [" ### ", "#   #", "#   #", "#   #", "#   #", "#   #", " ### "],
        'P': ["#### ", "#   #", "#   #", "#### ", "#    ", "#    ", "#    "],
        'Q': [" ### ", "#   #", "#   #", "#   #", "# # #", "#  ##", " ####"],
        'R': ["#### ", "#   #", "#   #", "#### ", "# #  ", "#  # ", "#   #"],
        'S': [" ####", "#    ", "#    ", " ### ", "    #", "    #", "#### "],
        'T': ["#####", "  #  ", "  #  ", "  #  ", "  #  ", "  #  ", "  #  "],
        'U': ["#   #", "#   #", "#   #", "#   #", "#   #", "#   #", " ### "],
        'V': ["#   #", "#   #", "#   #", "#   #", "#   #", " # # ", "  #  "],
        'W': ["#   #", "#   #", "#   #", "# # #", "# # #", "## ##", "#   #"],
        'X': ["#   #", "#   #", " # # ", "  #  ", " # # ", "#   #", "#   #"],
        'Y': ["#   #", "#   #", " # # ", "  #  ", "  #  ", "  #  ", "  #  "],
        'Z': ["#####", "    #", "   # ", "  #  ", " #   ", "#    ", "#####"],
        ' ': ["     ", "     ", "     ", "     ", "     ", "     ", "     "],
        '.': ["     ", "     ", "     ", "     ", "     ", " ##  ", " ##  "],
        ',': ["     ", "     ", "     ", "     ", "     ", " ##  ", "  #  "],
        '-': ["     ", "     ", "     ", "#####", "     ", "     ", "     "],
        ':': ["     ", " ##  ", " ##  ", "     ", " ##  ", " ##  ", "     "],
        '!': ["  #  ", "  #  ", "  #  ", "  #  ", "  #  ", "     ", "  #  "],
        '#': [" # # ", "#####", " # # ", " # # ", "#####", " # # ", "     "],
        '/': ["    #", "   # ", "  #  ", " #   ", "#    ", "     ", "     "],
        '0': [" ### ", "#  ##", "# # #", "# # #", "##  #", "#   #", " ### "],
        '1': ["  #  ", " ##  ", "  #  ", "  #  ", "  #  ", "  #  ", " ### "],
        '2': [" ### ", "#   #", "    #", "  ## ", " #   ", "#    ", "#####"],
        '3': ["#### ", "    #", "   # ", "  ## ", "    #", "#   #", "#### "],
        '4': ["   # ", "  ## ", " # # ", "#  # ", "#####", "   # ", "   # "],
        '5': ["#####", "#    ", "#### ", "    #", "    #", "#   #", "#### "],
        '6': [" ### ", "#    ", "#### ", "#   #", "#   #", "#   #", " ### "],
        '7': ["#####", "    #", "   # ", "  #  ", "  #  ", "  #  ", "  #  "],
        '8': [" ### ", "#   #", "#   #", " ### ", "#   #", "#   #", " ### "],
        '9': [" ### ", "#   #", "#   #", " ####", "    #", "    #", " ### "],
    }

    def draw_pixel_text(draw, x, y, text, color, align="l"):
        text = text.upper()
        total_w = len(text) * 6 - 1
        start_x = x
        if align == "c":
            start_x = x - total_w // 2
        elif align == "r":
            start_x = x - total_w
            
        cur_x = start_x
        for ch in text:
            glyph = FONT_5X7.get(ch, FONT_5X7[' '])
            for r, row in enumerate(glyph):
                for c, bit in enumerate(row):
                    if bit == '#':
                        draw.point((cur_x + c, y + r), fill=color)
            cur_x += 6

    # -------------------------------------------------------------------------
    # Pixel Art Helper: Arstotzka Eagle Crest
    # -------------------------------------------------------------------------
    def draw_eagle(draw, cx, cy, color, scale=1):
        eagle_bitmap = [
            "      #####      ",
            "   ###########   ",
            " ############### ",
            "#####  ###  #####",
            "###   #####   ###",
            "##   #######   ##",
            "#   #########   #",
            "    ### # ###    ",
            "     # ### #     ",
            "       ###       ",
            "       # #       ",
        ]
        h = len(eagle_bitmap)
        w = len(eagle_bitmap[0])
        ox = cx - (w * scale) // 2
        oy = cy - (h * scale) // 2
        for r, row in enumerate(eagle_bitmap):
            for c, ch in enumerate(row):
                if ch == '#':
                    for sx in range(scale):
                        for sy in range(scale):
                            draw.point((ox + c * scale + sx, oy + r * scale + sy), fill=color)

    # -------------------------------------------------------------------------
    # Pixel Art Helper: Circular Ministry Seal
    # -------------------------------------------------------------------------
    def draw_seal(draw, cx, cy, radius, color):
        for a in range(360):
            rad = math.radians(a)
            x = int(cx + radius * math.cos(rad))
            y = int(cy + radius * math.sin(rad))
            draw.point((x, y), fill=color)
            x_in = int(cx + (radius - 2) * math.cos(rad))
            y_in = int(cy + (radius - 2) * math.sin(rad))
            draw.point((x_in, y_in), fill=color)
        for a in range(0, 360, 15):
            rad = math.radians(a)
            x = int(cx + (radius - 5) * math.cos(rad))
            y = int(cy + (radius - 5) * math.sin(rad))
            draw.point((x, y), fill=color)
            draw.point((x + 1, y), fill=color)
        draw_eagle(draw, cx, cy, color, scale=1)

    # =========================================================================
    # 1. BOTTOM SCREEN BULLETIN BACKGROUND: BKG_BULLETIN_BTM.png (320 x 240)
    # =========================================================================
    btm = Image.new('RGB', (320, 240), C_DESK_LIGHT)
    d_btm = ImageDraw.Draw(btm)
    
    # Outer desk metal borders & bevels
    d_btm.rectangle([(0, 0), (319, 5)], fill=C_DESK_DARK)
    d_btm.line([(0, 6), (319, 6)], fill=C_DESK_MID)
    d_btm.rectangle([(0, 235), (319, 239)], fill=C_DESK_DARK)
    d_btm.line([(0, 234), (319, 234)], fill=C_DESK_MID)
    d_btm.rectangle([(0, 0), (5, 239)], fill=C_DESK_DARK)
    d_btm.line([(6, 0), (6, 239)], fill=C_DESK_MID)
    d_btm.rectangle([(314, 0), (319, 239)], fill=C_DESK_DARK)
    d_btm.line([(313, 0), (313, 239)], fill=C_DESK_MID)
    
    # Paper drop shadow
    d_btm.rectangle([(12, 10), (312, 232)], fill=C_DESK_DARK)
    d_btm.rectangle([(11, 9), (311, 231)], fill=C_DESK_SHADOW)
    
    # Paper base sheet (x=10..309, y=8..229)
    d_btm.rectangle([(10, 8), (309, 229)], fill=C_PAPER_BG)
    d_btm.rectangle([(10, 8), (309, 229)], outline=C_INK_DARK)
    d_btm.rectangle([(12, 10), (307, 227)], outline=C_PAPER_BORDER)
    
    # Top Muted Header Banner (y=11..44) - SPENTO!
    d_btm.rectangle([(13, 11), (306, 44)], fill=C_RED_BANNER)
    d_btm.line([(13, 11), (306, 11)], fill=C_RED_LIGHT)
    d_btm.line([(13, 44), (306, 44)], fill=C_RED_DARK)
    d_btm.line([(13, 45), (306, 45)], fill=C_INK_BLACK)
    
    # Eagle crests on header (warm off-white)
    draw_eagle(d_btm, 32, 27, (225, 218, 205), scale=1)
    draw_eagle(d_btm, 288, 27, (225, 218, 205), scale=1)
    
    # Faint Arstotzka Eagle Watermark in paper center
    draw_eagle(d_btm, 160, 108, C_INK_LIGHT, scale=3)
    
    # Subheader dividing bar
    d_btm.line([(18, 56), (301, 56)], fill=C_INK_DARK)
    d_btm.line([(18, 57), (301, 57)], fill=C_PAPER_SHADE)
    
    # Dotted guidelines for directive rules
    for gy in [76, 94, 112, 130]:
        for gx in range(24, 296, 4):
            d_btm.point((gx, gy), fill=C_INK_LIGHT)
            
    # Muted red bullet indicators on the left
    for by in [69, 87, 105, 123]:
        d_btm.rectangle([(20, by), (23, by + 3)], fill=C_RED_BANNER)
        
    # Circular Ministry seal stamp on bottom-right of sheet (TRANNE PER IL ROSSO DEL TIMBRO!)
    draw_seal(d_btm, 260, 148, radius=20, color=C_STAMP_PINK)
    
    # Divider above the action area
    d_btm.line([(18, 160), (301, 160)], fill=C_PAPER_BORDER)
    d_btm.line([(18, 161), (301, 161)], fill=C_INK_LIGHT)
    
    btm_path = os.path.join(ASSETS_DIR, 'BKG_BULLETIN_BTM.png')
    btm.save(btm_path, 'PNG')
    print(f'Saved {btm_path}: {btm.size}')

    # =========================================================================
    # 2. TOP SCREEN BULLETIN BACKGROUND: BKG_BULLETIN_TOP.png (400 x 240)
    # The Truth of Arstotzka - Authentic Retro Pixel Art Newspaper
    # =========================================================================
    top = Image.new('RGB', (400, 240), C_PAPER_BG)
    d_top = ImageDraw.Draw(top)
    
    # Outer newspaper borders
    d_top.rectangle([(0, 0), (399, 239)], outline=C_INK_BLACK)
    d_top.rectangle([(2, 2), (397, 237)], outline=C_PAPER_SHADE)
    
    # Double horizontal lines under top edge
    d_top.line([(8, 4), (391, 4)], fill=C_INK_BLACK)
    d_top.line([(8, 6), (391, 6)], fill=C_INK_DARK)
    
    # Load authentic Blackletter Masthead Title ("The Truth of Arstotzka")
    mast_path = os.path.join(ASSETS_DIR, 'MASTHEAD_TITLE.png')
    if not os.path.exists(mast_path) and os.path.exists('scratch_clean_masthead.png'):
        mast_path = 'scratch_clean_masthead.png'
        
    if os.path.exists(mast_path):
        mast_mask = Image.open(mast_path)
        start_x = (400 - mast_mask.width) // 2
        start_y = 9
        for my in range(mast_mask.height):
            for mx in range(mast_mask.width):
                if mast_mask.getpixel((mx, my)) > 128:
                    top.putpixel((start_x + mx, start_y + my), C_INK_BLACK)
    else:
        draw_pixel_text(d_top, 200, 18, "THE TRUTH OF ARSTOTZKA", C_INK_BLACK, "c")
        
    # Masthead Eagles in BLACK PRINTER'S INK
    draw_eagle(d_top, 60, 22, C_INK_BLACK, scale=1)
    draw_eagle(d_top, 340, 22, C_INK_BLACK, scale=1)
    
    # Decorative horizontal rules on sides
    for sy in range(11, 33, 3):
        d_top.line([(10, sy), (46, sy)], fill=C_INK_DARK)
        d_top.line([(354, sy), (390, sy)], fill=C_INK_DARK)
        
    # Masthead bottom double rules
    d_top.line([(8, 37), (391, 37)], fill=C_INK_DARK)
    d_top.line([(8, 39), (391, 39)], fill=C_INK_BLACK)
    
    # Subheader lines for date bar (clean spacing, no clipping)
    d_top.line([(8, 51), (391, 51)], fill=C_INK_DARK)
    d_top.line([(8, 53), (391, 53)], fill=C_INK_BLACK)
    
    # Checkpoint Photo Box (120x80 px) (x=14..136, y=85..165)
    d_top.rectangle([(14, 85), (136, 165)], fill=C_INK_BLACK)
    d_top.rectangle([(15, 86), (135, 164)], fill=(45, 47, 50))
    for py in range(86, 165):
        for px in range(15, 136):
            if py > 140:
                top.putpixel((px, py), (70, 68, 65) if (px + py) % 2 == 0 else (55, 54, 52))
            elif py > 122 and (px < 62 or px > 89):
                top.putpixel((px, py), (85, 83, 80) if (px % 4 == 0 or py % 5 == 0) else (65, 63, 60))
            elif py > 104 and 67 <= px <= 84:
                top.putpixel((px, py), (95, 93, 88) if (px + py) % 3 == 0 else (72, 70, 68))
            elif 72 <= px <= 79 and 110 <= py <= 116:
                top.putpixel((px, py), (225, 225, 185))
            else:
                top.putpixel((px, py), (32, 34, 38))
                
    # Searchlight beam radiating across border
    for py in range(115, 165):
        spread = int((py - 115) * 0.95)
        start_x = 75 + int((py - 115) * 0.28)
        for bx in range(start_x, min(135, start_x + spread)):
            orig = top.getpixel((bx, py))
            if (bx + py) % 2 == 0:
                top.putpixel((bx, py), (min(255, orig[0] + 65), min(255, orig[1] + 65), min(255, orig[2] + 45)))
                
    # Barbed wire coil
    for wx in range(15, 136, 4):
        d_top.point((wx, 121), fill=(185, 185, 185))
        d_top.point((wx + 2, 123), fill=(185, 185, 185))
        
    # Photo caption with PIXEL FONT
    draw_pixel_text(d_top, 15, 168, 'GRESTIN BORDER GATE, 06:00', C_INK_DARK, 'l')
    d_top.line([(15, 178), (135, 178)], fill=C_INK_MID)
    
    # Text beside photo (x=142..250, y=86..168)
    for ly in range(86, 168, 5):
        lw = 104 if (ly // 5) % 6 != 0 else 70
        for lx in range(142, 142 + lw):
            if lx % 4 != 0:
                d_top.point((lx, ly), fill=C_INK_DARK)
                d_top.point((lx, ly + 1), fill=C_INK_DARK)
                
    # Two newspaper columns below photo
    d_top.line([(132, 182), (132, 234)], fill=C_INK_LIGHT)
    for ly in range(183, 234, 5):
        lw1 = 110 if (ly // 5) % 5 != 0 else 75
        for lx in range(15, 15 + lw1):
            if lx % 4 != 0:
                d_top.point((lx, ly), fill=C_INK_DARK)
                d_top.point((lx, ly + 1), fill=C_INK_DARK)
        lw2 = 110 if (ly // 5) % 4 != 0 else 70
        for lx in range(138, 138 + lw2):
            if lx % 4 != 0:
                d_top.point((lx, ly), fill=C_INK_DARK)
                d_top.point((lx, ly + 1), fill=C_INK_DARK)
                
    # Vertical rule dividing left news from right column
    d_top.line([(256, 54), (256, 234)], fill=C_INK_DARK)
    d_top.line([(257, 54), (257, 234)], fill=C_PAPER_SHADE)
    
    # Right Column: Ministry Announcement with PIXEL FONT
    d_top.rectangle([(260, 56), (388, 68)], fill=C_PAPER_SHADE)
    d_top.rectangle([(260, 56), (388, 116)], outline=C_INK_DARK)
    draw_pixel_text(d_top, 324, 59, 'MINISTRY ANNOUNCEMENT', C_INK_BLACK, 'c')
    for ly in range(72, 114, 5):
        lw = 120 if (ly // 5) % 4 != 0 else 80
        for lx in range(264, 264 + lw):
            if lx % 4 != 0:
                d_top.point((lx, ly), fill=C_INK_DARK)
                d_top.point((lx, ly + 1), fill=C_INK_DARK)
                
    # Weather Box with PIXEL FONT
    d_top.rectangle([(260, 120), (388, 132)], fill=C_PAPER_SHADE)
    d_top.rectangle([(260, 120), (388, 166)], outline=C_INK_DARK)
    draw_pixel_text(d_top, 324, 123, 'THE WEATHER', C_INK_BLACK, 'c')
    d_top.rectangle([(268, 138), (284, 144)], fill=C_INK_DARK)
    for sx, sy in [(269, 148), (274, 152), (279, 148), (283, 153)]:
        d_top.point((sx, sy), fill=C_INK_DARK)
    draw_pixel_text(d_top, 292, 136, 'GRESTIN: -4 C', C_INK_DARK, 'l')
    draw_pixel_text(d_top, 292, 148, 'OVERCAST   SNOW', C_INK_MID, 'l')
    
    # State Notice Box with PIXEL FONT (MUTED RED!)
    d_top.rectangle([(260, 172), (388, 202)], fill=C_RED_BANNER)
    d_top.rectangle([(260, 172), (388, 202)], outline=C_RED_DARK)
    d_top.rectangle([(262, 174), (386, 200)], outline=C_RED_LIGHT)
    draw_eagle(d_top, 324, 180, (225, 218, 205), scale=1)
    draw_pixel_text(d_top, 324, 191, 'GLORY TO ARSTOTZKA', (225, 218, 205), 'c')
    
    # Faded vintage ink seal at bottom right (Muted sepia/maroon stamp)
    draw_seal(d_top, 324, 220, radius=12, color=C_RED_STAMP_MUTE)
    
    top_path = os.path.join(ASSETS_DIR, 'BKG_BULLETIN_TOP.png')
    top.save(top_path, 'PNG')
    print(f'Saved {top_path}: {top.size}')

    # =========================================================================
    # 3. GENERATE NEWS_DAY1..4.png with PIXEL FONT for texts
    # =========================================================================
    days_data = [
        (1, "23.11.1982", "GRESTIN BORDER REOPENS", "SIX-YEAR WAR WITH KOLECHIA IS OVER."),
        (2, "24.11.1982", "FOREIGNERS NOW ALLOWED", "MINISTRY PERMITS ENTRY FOR NON-CITIZENS."),
        (3, "25.11.1982", "SECURITY MEASURES TIGHTENED", "NEW ENTRY PERMIT REQUIRED FOR FOREIGNERS."),
        (4, "26.11.1982", "LABOR RESTRICTIONS IN EFFECT", "WORKERS REQUIRE ARSTOTZKAN WORK PASS.")
    ]
    for d_num, d_date, d_head, d_sub in days_data:
        day_img = top.copy()
        d_day = ImageDraw.Draw(day_img)
        
        # Masthead date bar with PIXEL FONT
        draw_pixel_text(d_day, 15, 42, d_date, C_INK_DARK, "l")
        draw_pixel_text(d_day, 200, 42, f"ISSUE #{d_num}", C_INK_DARK, "c")
        draw_pixel_text(d_day, 385, 42, "NO CHARGE", C_INK_DARK, "r")
        
        # Lead story headline with PIXEL FONT
        draw_pixel_text(d_day, 15, 57, d_head, C_INK_BLACK, "l")
        
        # Subline (if long, draw cleanly within 240px width)
        if len(d_sub) > 39:
            words = d_sub.split(' ')
            line1 = []
            line2 = []
            cur_len = 0
            for w in words:
                if cur_len + len(w) + 1 <= 38 and not line2:
                    line1.append(w)
                    cur_len += len(w) + 1
                else:
                    line2.append(w)
            draw_pixel_text(d_day, 15, 68, ' '.join(line1), C_INK_DARK, "l")
            draw_pixel_text(d_day, 15, 76, ' '.join(line2), C_INK_DARK, "l")
            d_day.line([(15, 84), (250, 84)], fill=C_INK_LIGHT)
        else:
            draw_pixel_text(d_day, 15, 69, d_sub, C_INK_DARK, "l")
            d_day.line([(15, 80), (250, 80)], fill=C_INK_LIGHT)
            
        nd_path = os.path.join(ASSETS_DIR, f'NEWS_DAY{d_num}.png')
        day_img.save(nd_path, 'PNG')
        print(f'Saved {nd_path}: {day_img.size}')

    # =========================================================================
    # 4. DAY SUMMARY BACKGROUNDS: BKG_DAYSUMMARY_TOP & BKG_DAYSUMMARY
    # =========================================================================
    sum_top = Image.new('RGB', (400, 240), (22, 20, 24))
    d_sum_top = ImageDraw.Draw(sum_top)
    sky_colors = [
        (22, 20, 24),
        (35, 28, 36),
        (58, 38, 44),
        (88, 48, 42),
        (118, 62, 44),
        (145, 78, 48),
        (165, 92, 52)
    ]
    for y in range(120):
        c_idx = min(len(sky_colors) - 1, int(y / 120 * len(sky_colors)))
        col = sky_colors[c_idx]
        d_sum_top.line([(0, y), (399, y)], fill=col)
        
    for bx, bw, bh in [(30, 25, 40), (60, 18, 55), (85, 30, 35), (280, 22, 45), (310, 35, 60), (355, 25, 38)]:
        d_sum_top.rectangle([(bx, 120 - bh), (bx + bw, 120)], fill=(30, 24, 28))
        
    d_sum_top.rectangle([(0, 110), (399, 239)], fill=(40, 38, 36))
    d_sum_top.rectangle([(130, 125), (270, 239)], fill=(30, 28, 26))
    for gy in range(130, 239, 4):
        d_sum_top.line([(132, gy), (268, gy)], fill=(48, 46, 42))
        
    d_sum_top.rectangle([(50, 80), (130, 239)], fill=(50, 48, 45))
    d_sum_top.rectangle([(270, 80), (350, 239)], fill=(50, 48, 45))
    d_sum_top.rectangle([(75, 95), (105, 110)], fill=(20, 20, 22))
    d_sum_top.rectangle([(295, 95), (325, 110)], fill=(20, 20, 22))
    
    for beam_x, beam_dir in [(125, 1), (275, -1)]:
        d_sum_top.rectangle([(beam_x - 3, 102), (beam_x + 3, 108)], fill=(120, 120, 120))
        d_sum_top.point((beam_x, 105), fill=(240, 240, 200))
        for ly in range(108, 220):
            w = int((ly - 108) * 0.4)
            for lx in range(beam_x, beam_x + w * beam_dir, beam_dir):
                if (lx + ly) % 2 == 0:
                    orig = sum_top.getpixel((lx, ly))
                    sum_top.putpixel((lx, ly), (min(255, orig[0] + 50), min(255, orig[1] + 50), min(255, orig[2] + 30)))
                    
    for wx in range(0, 400, 5):
        d_sum_top.point((wx, 108), fill=(160, 160, 160))
        d_sum_top.point((wx + 2, 110), fill=(160, 160, 160))
        
    # Muted crimson header banner (spento!)
    d_sum_top.rectangle([(20, 14), (380, 44)], fill=C_RED_BANNER)
    d_sum_top.rectangle([(20, 14), (380, 44)], outline=C_RED_DARK)
    d_sum_top.rectangle([(22, 16), (378, 42)], outline=C_RED_LIGHT)
    draw_eagle(d_sum_top, 40, 29, (225, 218, 205), scale=1)
    draw_eagle(d_sum_top, 360, 29, (225, 218, 205), scale=1)
    draw_pixel_text(d_sum_top, 200, 21, "MINISTRY OF ADMISSION", (225, 218, 205), "c")
    draw_pixel_text(d_sum_top, 200, 31, "GRESTIN BORDER CHECKPOINT - 18:00 CLOSED", C_GOLD_TEXT, "c")
    
    sum_top_path = os.path.join(ASSETS_DIR, 'BKG_DAYSUMMARY_TOP.png')
    sum_top.save(sum_top_path, 'PNG')
    print(f'Saved {sum_top_path}: {sum_top.size}')

    sum_btm = Image.new('RGB', (320, 240), C_DESK_LIGHT)
    d_sum_btm = ImageDraw.Draw(sum_btm)
    d_sum_btm.rectangle([(0, 0), (319, 5)], fill=C_DESK_DARK)
    d_sum_btm.rectangle([(0, 235), (319, 239)], fill=C_DESK_DARK)
    d_sum_btm.rectangle([(0, 0), (5, 239)], fill=C_DESK_DARK)
    d_sum_btm.rectangle([(314, 0), (319, 239)], fill=C_DESK_DARK)
    d_sum_btm.rectangle([(16, 12), (308, 234)], fill=C_DESK_DARK)
    d_sum_btm.rectangle([(15, 11), (307, 233)], fill=C_DESK_SHADOW)
    d_sum_btm.rectangle([(14, 10), (305, 231)], fill=C_PAPER_BG)
    d_sum_btm.rectangle([(14, 10), (305, 231)], outline=C_INK_DARK)
    d_sum_btm.rectangle([(16, 12), (303, 229)], outline=C_PAPER_BORDER)
    # Muted header banner (spento!)
    d_sum_btm.rectangle([(17, 13), (302, 46)], fill=C_RED_BANNER)
    d_sum_btm.line([(17, 13), (302, 13)], fill=C_RED_LIGHT)
    d_sum_btm.line([(17, 46), (302, 46)], fill=C_RED_DARK)
    draw_eagle(d_sum_btm, 36, 29, (225, 218, 205), scale=1)
    draw_eagle(d_sum_btm, 284, 29, (225, 218, 205), scale=1)
    draw_pixel_text(d_sum_btm, 160, 21, "MINISTRY OF ADMISSION", (225, 218, 205), "c")
    draw_pixel_text(d_sum_btm, 160, 33, "END OF SHIFT INSPECTION REPORT", C_GOLD_TEXT, "c")
    d_sum_btm.line([(24, 56), (296, 56)], fill=C_INK_DARK)
    for ly in [84, 104, 124]:
        d_sum_btm.line([(24, ly + 14), (296, ly + 14)], fill=C_PAPER_SHADE)
    # Circular stamp (tranne per il rosso del timbro!)
    draw_seal(d_sum_btm, 260, 114, radius=20, color=C_STAMP_PINK)
    
    sum_btm_path = os.path.join(ASSETS_DIR, 'BKG_DAYSUMMARY.png')
    sum_btm.save(sum_btm_path, 'PNG')
    sum_btm.save(os.path.join(ASSETS_DIR, 'DAY_SUMMARY_BKG.png'), 'PNG')
    print(f'Saved {sum_btm_path}: {sum_btm.size}')

if __name__ == '__main__':
    generate_all()
