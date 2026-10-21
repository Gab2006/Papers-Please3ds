NORMAL_FONT = Graphics.loadImage(System.currentDirectory().."ASSETS/FONT/NORMAL_FONT.png")
SMALL_FONT = Graphics.loadImage(System.currentDirectory().."ASSETS/FONT/SMALL_FONT.png")
DIGITS = Graphics.loadImage(System.currentDirectory().."ASSETS/FONT/DIGITS.png")
glyph_l = {}
glyph_r = {}
glyph_w = {}
glyph_l2 = {}
glyph_r2 = {}
glyph_w2 = {}
glyph_l3 = {}
glyph_r3 = {}
glyph_w3 = {}
function g_init(char, l, r) 
    glyph_l[char] = l
    glyph_r[char] = r
    glyph_w[char] = r-l+1
end
function g_init2(char, l, r) 
    glyph_l2[char] = l
    glyph_r2[char] = r
    glyph_w2[char] = r-l+1
end
function g_init3(char, l, r) 
    glyph_l3[char] = l
    glyph_r3[char] = r
    glyph_w3[char] = r-l+1
end
g_init('0',0,3)
g_init('1',5,6)
g_init('2',8,11)
g_init('3',13,16)
g_init('4',18,21)
g_init('5',23,26)
g_init('6',28,31)
g_init('7',33,36)
g_init('8',38,41)
g_init('9',43,46)
g_init('A',48,51)
g_init('B',53,56)
g_init('C',58,61)
g_init('D',63,66)
g_init('E',68,71)
g_init('F',73,76)
g_init('G',78,81)
g_init('H',83,86)
g_init('I',88,90)
g_init('J',92,95)
g_init('K',97,100)
g_init('L',102,105)
g_init('M',107,111)
g_init('N',113,116)
g_init('O',118,121)
g_init('P',123,126)
g_init('Q',128,131)
g_init('R',133,136)
g_init('S',138,141)
g_init('T',143,147)
g_init('U',149,152)
g_init('V',154,157)
g_init('W',159,163)
g_init('X',165,168)
g_init('Y',170,173)
g_init('Z',175,178)
g_init('.',180,180)
g_init(' ',181,181)
g_init('-',184,186)
--[[
g_init('a',221,225)
g_init('b',227,231)
g_init('c',233,237)
g_init('d',239,243)
g_init('e',245,249)
g_init('f',251,255)
g_init('g',257,261)
g_init('h',263,267)
g_init('i',269,270)
g_init('j',272,275)
g_init('k',277,280)
g_init('l',282,283)
g_init('m',285,289)
g_init('n',291,295)
g_init('o',297,301)
g_init('p',303,307)
g_init('q',309,313)
g_init('r',315,319)
g_init('s',321,325)
g_init('t',327,330)
g_init('u',332,336)
g_init('v',338,342)
g_init('w',344,348)
g_init('x',350,354)
g_init('y',356,360)
g_init('z',362,366)]]--
g_init2('0',0,3)
g_init2('1',5,6)
g_init2('2',8,11)
g_init2('3',13,16)
g_init2('4',18,21)
g_init2('5',23,26)
g_init2('6',28,31)
g_init2('7',33,36)
g_init2('8',38,41)
g_init2('9',43,46)
g_init2('A',75,78)
g_init2('B',80,83)
g_init2('C',85,88)
g_init2('D',90,93)
g_init2('E',95,98)
g_init2('F',100,103)
g_init2('G',105,108)
g_init2('H',110,113)
g_init2('I',115,117)
g_init2('J',119,122)
g_init2('K',124,127)
g_init2('L',129,131)
g_init2('M',133,137)
g_init2('N',139,142)
g_init2('O',144,147)
g_init2('P',149,152)
g_init2('Q',154,157)
g_init2('R',158,162)
g_init2('S',164,167)
g_init2('T',169,171)
g_init2('U',173,176)
g_init2('V',178,181)
g_init2('W',183,187)
g_init2('X',189,192)
g_init2('Y',194,197)
g_init2('Z',199,201)
g_init2('.',322,322)
g_init2(':',327,327)
g_init2('+',329,331)
g_init2(' ',198,198)
g_init2('-',324,326)
g_init2('a',203,206)
g_init2('b',208,211)
g_init2('c',213,215)
g_init2('d',217,220)
g_init2('e',222,225)
g_init2('f',227,229)
g_init2('g',231,234)
g_init2('h',236,239)
g_init2('i',241,241)
g_init2('j',243,244)
g_init2('k',246,249)
g_init2('l',251,251)
g_init2('m',253,257)
g_init2('n',259,262)
g_init2('o',264,267)
g_init2('p',269,272)
g_init2('q',274,277)
g_init2('r',279,281)
g_init2('s',283,286)
g_init2('t',288,290)
g_init2('u',292,295)
g_init2('v',297,300)
g_init2('w',302,306)
g_init2('x',308,310)
g_init2('y',312,315)
g_init2('z',317,320)
g_init3('.',0,0)
g_init3(' ',1,1)
g_init3('0',2,4)
g_init3('1',6,8)
g_init3('2',10,12)
g_init3('3',14,16)
g_init3('4',18,20)
g_init3('5',22,24)
g_init3('6',26,28)
g_init3('7',30,32)
g_init3('8',34,36)
g_init3('9',38,40)
function GPU_DrawText(x, y, text, font_color, option, text_screen, font, size)
	if option=="l" then
	local text_u
	if size==7 then
	text_u = text --my font system is caps-only.
	elseif size==8 then
	text_u = string.upper(text) --my font system is caps-only
	elseif size==5 then
	text_u = text
	end
    local i_str=0 --the current position in the string
    local i_chr='' --the current character in the string
    local str_width = 0 --width in pixels of the string
    local str_length = string.len(text)
    local cw --character width
    while i_str < str_length do
        i_str = i_str + 1
        i_chr = string.sub(text_u, i_str, i_str)
		if size==7 then
        cw = glyph_w2[i_chr]
		elseif size==8 then
		cw = glyph_w[i_chr]
		elseif size==5 then
		cw = glyph_w3[i_chr]
		end
        if cw ~= nil then --as long as the character exists
		if y<=240 and y>=(-1)*(size) and x+str_width>-5 and x+str_width<text_screen then
			if size==7 then
				Graphics.drawPartialImage(x+str_width, y, glyph_l2[i_chr], 0, cw, size, font, font_color)
			elseif size==8 then
				Graphics.drawPartialImage(x+str_width, y, glyph_l[i_chr], 0, cw, size, font, font_color)
			elseif size==5 then
				Graphics.drawPartialImage(x+str_width, y, glyph_l3[i_chr], 0, cw, size, font, font_color)
			end
		end
            str_width = str_width + cw + 1
		end
	end
	elseif option=="r" then
	if size==7 then
	text_u = text --my font system is caps-only.
	elseif size==8 then
	text_u = string.upper(text) --my font system is caps-only
	end
    local i_str=0 --the current position in the string
    local i_chr='' --the current character in the string
    local str_width = 0 --width in pixels of the string
    local str_length = string.len(text)
    local cw --character width
    while i_str < str_length do
        i_str = i_str + 1
        i_chr = string.sub(text_u, i_str, i_str)
        if size==7 then
        cw = glyph_w2[i_chr]
		elseif size==8 then
		cw = glyph_w[i_chr]
		elseif size==5 then
		cw = glyph_w3[i_chr]
		end
        if cw ~= nil then --as long as the character exists
            str_width = str_width + cw + 1
		end
	end
	local right = str_width
	if size==7 then
	text_u = text --my font system is caps-only.
	elseif size==8 then
	text_u = string.upper(text) --my font system is caps-only
	elseif size==5 then
	text_u = text
	end
    local i_str=0 --the current position in the string
    local i_chr='' --the current character in the string
    local str_width = 0 --width in pixels of the string
    local str_length = string.len(text)
    local cw --character width
    while i_str < str_length do
        i_str = i_str + 1
        i_chr = string.sub(text_u, i_str, i_str)
        if size==7 then
        cw = glyph_w2[i_chr]
		elseif size==8 then
		cw = glyph_w[i_chr]
		elseif size==5 then
		cw = glyph_w3[i_chr]
		end
        if cw ~= nil then --as long as the character exists
		if y<=240 and y>=(-1)*(size) and x-right+str_width>-5 and x-right+str_width<text_screen then
            if size==7 then
			Graphics.drawPartialImage(x-right+str_width, y, glyph_l2[i_chr], 0, cw, size, font, font_color)
			elseif size==8 then
			Graphics.drawPartialImage(x-right+str_width, y, glyph_l[i_chr], 0, cw, size, font, font_color)
			elseif size==5 then
			Graphics.drawPartialImage(x-right+str_width, y, glyph_l3[i_chr], 0, cw, size, font, font_color)
			end
		end
            str_width = str_width + cw + 1
		end
	end
	elseif option=="c" then
	if size==7 then
	text_u = text --my font system is caps-only.
	elseif size==8 then
	text_u = string.upper(text) --my font system is caps-only
	elseif size==5 then
	text_u = text
	end
    local i_str=0 --the current position in the string
    local i_chr='' --the current character in the string
    local str_width = 0 --width in pixels of the string
    local str_length = string.len(text)
    local cw --character width
    while i_str < str_length do
        i_str = i_str + 1
        i_chr = string.sub(text_u, i_str, i_str)
        if size==7 then
        cw = glyph_w2[i_chr]
		elseif size==8 then
		cw = glyph_w[i_chr]
		elseif size==5 then
		cw = glyph_w3[i_chr]
		end
        if cw ~= nil then --as long as the character exists
            str_width = str_width + cw + 1
		end
	end
	local center = str_width
	if size==7 then
	text_u = text --my font system is caps-only.
	elseif size==8 then
	text_u = string.upper(text) --my font system is caps-only
	elseif size==5 then
	text_u = text
	end
    local i_str=0 --the current position in the string
    local i_chr='' --the current character in the string
    local str_width = 0 --width in pixels of the string
    local str_length = string.len(text)
    local cw --character width
    while i_str < str_length do
        i_str = i_str + 1
        i_chr = string.sub(text_u, i_str, i_str)
        if size==7 then
        cw = glyph_w2[i_chr]
		elseif size==8 then
		cw = glyph_w[i_chr]
		elseif size==5 then
		cw = glyph_w3[i_chr]
		end
        if cw ~= nil then --as long as the character exists
		if y<=240 and y>=(-1)*(size) and x-math.floor(center/2)+str_width>-5 and x-math.floor(center/2)+str_width<text_screen then
		if size==7 then
            Graphics.drawPartialImage(x-math.floor(center/2)+str_width, y, glyph_l2[i_chr], 0, cw, size, font, font_color)
		elseif size==8 then
			Graphics.drawPartialImage(x-math.floor(center/2)+str_width, y, glyph_l[i_chr], 0, cw, size, font, font_color)
			elseif size==5 then
			Graphics.drawPartialImage(x-math.floor(center/2)+str_width, y, glyph_l3[i_chr], 0, cw, size, font, font_color)
		end
		end
            str_width = str_width + cw + 1
		end
	end
	end
end