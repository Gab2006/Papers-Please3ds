-- [GAME METADATA & VERSION]
GAME_AUTHOR = "Gab2006"
GAME_VERSION_MAJOR = 1
GAME_VERSION_MINOR = 4
GAME_VERSION_MICRO = 2
GAME_VERSION = GAME_VERSION_MAJOR .. "." .. GAME_VERSION_MINOR .. "." .. GAME_VERSION_MICRO

Graphics.init()
oldpad = Controls.read()
STICK = {x = 0,y = 0}
CAGE = {y = {},OLDy=-17,min = 103,yshadow = -37}
RED = Color.new(255,80,80)
YELLOW = Color.new(255,255,80)
GREEN = Color.new(80,255,80)
GREEN_menu=Color.new(85,104,85)
WHITE = Color.new(255,255,255)
BLUE = Color.new(80,80,255)
BROWN = Color.new(87,72,72)
BLACK = Color.new(0,0,0)
MENU_RED = Color.new(255,0,0)
DOCUMENTS_WHITE = Color.new(237,224,216)
ENTRYTICKET_BROWN = Color.new(119,103,137)
IDCARD_BCOLOR=Color.new(61,57,77)
IDCARD_WCOLOR=Color.new(217,189,247)
WORKPASS_COLOR=Color.new(138,105,107)
BKG_BROWN = Color.new(25,18,18)
SHADOW = Color.new(0,0,0,150)
GRAY=Color.new(50,50,50)
BROWN2=Color.new(66,42,28)
BROWN3=Color.new(106,82,47)
TRANSCRIPTBROWN = Color.new(87,72,72)
TRANSCRIPTBLUE = Color.new(210,237,236)
CITATION_COLOR = Color.new(90,85,89)
-- [THEMATIC ARSTOTZKAN HUD PALETTE]
HUD_GREEN_BG = Color.new(24, 34, 22)
HUD_GREEN_BORDER = Color.new(55, 115, 50)
HUD_GREEN_TEXT = Color.new(125, 205, 110)
HUD_RED_BG = Color.new(36, 20, 20)
HUD_RED_BORDER = Color.new(140, 40, 40)
HUD_RED_TEXT = Color.new(220, 85, 85)
Th,Tm,Ts = System.getTime() -- Get System Time
today={} 
today.day_value,today.day,today.month,today.year = System.getDate() -- Get System Date
math.randomseed(Th*3600+Tm*60+Ts)
if System.currentDirectory() == "/" then
	System.currentDirectory("romfs:/")
end

-- [AUDIO SUBSYSTEM INITIALIZATION]
AUDIO_READY = false
if Sound and Sound.init then
	local ok = pcall(Sound.init)
	if ok then
		AUDIO_READY = true
	end
elseif Sound ~= nil then
	AUDIO_READY = true
end

AUDIO = {
	muted = false,
	sfx = {},
	sfx_played = {},
	bgm_cache = {},
	current_bgm = nil,
	current_bgm_name = nil,
	current_ambient = nil,
	current_ambient_name = nil
}

local SFX_MAP = {
	stamp_down = "stamp-down.wav",
	stamp_up = "stamp-up.wav",
	stampbar_open = "stampbar-open.wav",
	stampbar_close = "stampbar-close.wav",
	shutter_rise = "shutter-rise.wav",
	shutter_drop = "shutter-drop.wav",
	speech_announce = "speech-announce.wav",
	speech_entrant = "speech-entrant.wav",
	speech_inspector = "speech-inspector.wav",
	traveler_walkin = "traveler-walkin.wav",
	traveler_walkout = "traveler-walkout.wav",
	paper_dragstart = "paper-dragstart.wav",
	paper_dragstop = "paper-dragstop.wav",
	paper_turnpage = "paper-turnpage.wav",
	printer_feed = "printer-feed.wav",
	printer_line = "printer-line.wav",
	printer_tear = "printer-tear.wav",
	button_down = "button-down.wav",
	button_up = "button-up.wav",
	booth_intro = "booth-intro.wav",
	inspect_open = "inspect-open.wav",
	inspect_close = "inspect-close.wav",
	inspect_highlight = "inspect-highlight.wav",
	inspect_unhighlight = "inspect-unhighlight.wav",
	inspect_interrogateon = "inspect-interrogateon.wav",
	border_callguards = "border-callguards.wav",
	photo_print = "photo-print.wav"
}

function PLAY_SFX(id)
	if not AUDIO_READY or AUDIO.muted or (Options and Options["Sound"] == 0) then return end
	local s = AUDIO.sfx[id]
	if not s then
		local filename = SFX_MAP[id]
		if filename then
			local path = "romfs:/ASSETS/SOUND/" .. filename
			local ok, handle = pcall(Sound.openWav, path, false)
			if ok and handle then
				AUDIO.sfx[id] = handle
				s = handle
			end
		end
	end
	if s then
		-- In LPP-3DS CSND: loop argument must be literal boolean false for SOUND_ONE_SHOT.
		-- Sound.play already reconfigures and resets registers on played channels cleanly without needing Sound.pause.
		pcall(Sound.play, s, false)
		AUDIO.sfx_played[id] = true
	end
end

function PLAY_BGM(name, loop)
	if not AUDIO_READY or AUDIO.muted or (Options and Options["Sound"] == 0) then return end
	local wav_name = name:gsub("%.ogg$", ".wav")
	if AUDIO.current_bgm_name == wav_name and AUDIO.current_bgm then
		return
	end
	STOP_BGM()
	local handle = AUDIO.bgm_cache[wav_name]
	if not handle then
		local path = "romfs:/ASSETS/SOUND/" .. wav_name
		local ok, h = pcall(Sound.openWav, path, false)
		if ok and h then
			AUDIO.bgm_cache[wav_name] = h
			handle = h
		end
	end
	if handle then
		AUDIO.current_bgm = handle
		AUDIO.current_bgm_name = wav_name
		local should_loop = (loop == true)
		pcall(Sound.play, handle, should_loop)
	end
end

function STOP_BGM()
	if AUDIO.current_bgm then
		if Sound and Sound.pause then
			pcall(Sound.pause, AUDIO.current_bgm)
		end
		AUDIO.current_bgm = nil
		AUDIO.current_bgm_name = nil
	end
end

function PLAY_AMBIENT(name, loop)
	if not AUDIO_READY or AUDIO.muted or (Options and Options["Sound"] == 0) then return end
	local wav_name = name:gsub("%.ogg$", ".wav")
	if AUDIO.current_ambient_name == wav_name and AUDIO.current_ambient then
		return
	end
	STOP_AMBIENT()
	local handle = AUDIO.bgm_cache[wav_name]
	if not handle then
		local path = "romfs:/ASSETS/SOUND/" .. wav_name
		local ok, h = pcall(Sound.openWav, path, false)
		if ok and h then
			AUDIO.bgm_cache[wav_name] = h
			handle = h
		end
	end
	if handle then
		AUDIO.current_ambient = handle
		AUDIO.current_ambient_name = wav_name
		local should_loop = (loop == true)
		pcall(Sound.play, handle, should_loop)
	end
end

function STOP_AMBIENT()
	if AUDIO.current_ambient then
		if Sound and Sound.pause then
			pcall(Sound.pause, AUDIO.current_ambient)
		end
		AUDIO.current_ambient = nil
		AUDIO.current_ambient_name = nil
	end
end

function PAUSE_AUDIO()
	-- Only pause continuous background audio (BGM/ambient).
	-- Never pause short one-shot sound effects (SFX): doing so spams CSND command buffers in a tight loop,
	-- causing race conditions and fatal ARM11 Data Aborts in the 3DS 'csnd' system service (0004013000002702).
	if Sound and Sound.pause then
		if AUDIO.current_ambient then pcall(Sound.pause, AUDIO.current_ambient) end
		if AUDIO.current_bgm then pcall(Sound.pause, AUDIO.current_bgm) end
	end
end

function RESUME_AUDIO()
	if not AUDIO_READY or AUDIO.muted or (Options and Options["Sound"] == 0) then return end
	if Sound and Sound.resume then
		if AUDIO.current_ambient then pcall(Sound.resume, AUDIO.current_ambient) end
		if AUDIO.current_bgm then pcall(Sound.resume, AUDIO.current_bgm) end
	end
end

function TERM_AUDIO()
	if not AUDIO_READY then return end
	STOP_BGM()
	STOP_AMBIENT()
	-- DO NOT call Sound.term()! LPP-3DS main.cpp already calls csndExit()/ndspExit() on exit.
	-- Calling Sound.term() explicitly in Lua causes a double csndExit(), unmapping shared memory and causing Data Abort.
	AUDIO_READY = false
end



TITLEi=0
NORMAL_FONT = Graphics.loadImage(System.currentDirectory().."ASSETS/FONT/NORMAL_FONT.png")
SMALL_FONT = Graphics.loadImage(System.currentDirectory().."ASSETS/FONT/SMALL_FONT.png")
DIGITS = Graphics.loadImage(System.currentDirectory().."ASSETS/FONT/DIGITS.png")
MODE1 = Graphics.loadImage(System.currentDirectory().."ASSETS/MODE1.png")
MODES = Graphics.loadImage(System.currentDirectory().."ASSETS/MODES.png")
LINEver = Graphics.loadImage(System.currentDirectory().."ASSETS/LINEver.png")
LINEhor = Graphics.loadImage(System.currentDirectory().."ASSETS/LINEhor.png")
dofile(System.currentDirectory().."FontInfo.lua")
dofile(System.currentDirectory().."DataFile.lua")
DEMObutton = Graphics.loadImage(System.currentDirectory().."ASSETS/DEMObutton.png")
STORYMODEbutton = Graphics.loadImage(System.currentDirectory().."ASSETS/STORYMODEbutton.png")
EXITbutton = Graphics.loadImage(System.currentDirectory().."ASSETS/EXITbutton.png")
BACKbutton = Graphics.loadImage(System.currentDirectory().."ASSETS/BACKbutton.png")
QUITbutton = Graphics.loadImage(System.currentDirectory().."ASSETS/QUITbutton.png")
CHECKBOXbutton = Graphics.loadImage(System.currentDirectory().."ASSETS/CHECKBOX.png")
MAINMENUbutton = Graphics.loadImage(System.currentDirectory().."ASSETS/MAINMENUbutton.png")
SLEEPbutton = Graphics.loadImage(System.currentDirectory().."ASSETS/SLEEPbutton.png")
RESUMEbutton = Graphics.loadImage(System.currentDirectory().."ASSETS/RESUMEbutton.png")
STARTbutton = Graphics.loadImage(System.currentDirectory().."ASSETS/STARTbutton.png")
Title = Graphics.loadImage(System.currentDirectory().."ASSETS/Title.png")
textTextures={}
function loadtex()
	BKG_BTMS = Graphics.loadImage(System.currentDirectory().."ASSETS/BKG_BTMS.png")
	BKG_TPS = Graphics.loadImage(System.currentDirectory().."ASSETS/BKG_TPS.png")
	STMP_SPRITE = Graphics.loadImage(System.currentDirectory().."ASSETS/STMP_SPRITE.png")
	BKG_MONITORS = Graphics.loadImage(System.currentDirectory().."ASSETS/BKG_MONITORS.png")
	CAGE_TXR = Graphics.loadImage(System.currentDirectory().."ASSETS/CAGE.png")
	WALL_TXR = Graphics.loadImage(System.currentDirectory().."ASSETS/WALL.png")
	SHADOW_TXR = Graphics.loadImage(System.currentDirectory().."ASSETS/SHADOW.png")
	PASSPORT_SHEET = Graphics.loadImage(System.currentDirectory().."ASSETS/PASSPORTSHEET.png")
	NOTPASSPORT_SHEET = Graphics.loadImage(System.currentDirectory().."ASSETS/NOTPASSPORTSHEET.png")
	YESSTAMP=Graphics.loadImage(System.currentDirectory().."ASSETS/YESSTAMP.png")
	NOSTAMP=Graphics.loadImage(System.currentDirectory().."ASSETS/NOSTAMP.png")
	RULEBOOKSHEETS=Graphics.loadImage(System.currentDirectory().."ASSETS/RULEBOOKSHEETS.png")
	ENTRYTICKET.tex = Graphics.loadImage(System.currentDirectory().."ASSETS/ENTRYTICKET_TEX.png")
	ENTRYTICKET.tex2 = Graphics.loadImage(System.currentDirectory().."ASSETS/ENTRYTICKET_TEX2.png")
	ENTRYPERMIT.tex = Graphics.loadImage(System.currentDirectory().."ASSETS/ENTRYPERMIT_TEX.png")
	ENTRYPERMIT.tex2 = Graphics.loadImage(System.currentDirectory().."ASSETS/ENTRYPERMIT_TEX2.png")
	CARIMAGE = Graphics.loadImage(System.currentDirectory().."ASSETS/CARIMAGE.png")
	IDCARD.tex = Graphics.loadImage(System.currentDirectory().."ASSETS/IDCARD_TEX.png")
	IDCARD.tex2 = Graphics.loadImage(System.currentDirectory().."ASSETS/IDCARD_TEX2.png")
	PASSPORT.tex = Graphics.loadImage(System.currentDirectory().."ASSETS/PASSPORT_TEX.png")
	PASSPORT.tex2 = Graphics.loadImage(System.currentDirectory().."ASSETS/PASSPORT_TEX2.png")
	WORKPASS.tex = Graphics.loadImage(System.currentDirectory().."ASSETS/WORKPASS_TEX.png")
	WORKPASS.tex2 = Graphics.loadImage(System.currentDirectory().."ASSETS/WORKPASS_TEX2.png")
	RULEBOOK.tex = Graphics.loadImage(System.currentDirectory().."ASSETS/RULEBOOK_TEX.png")
	RULEBOOK.tex2 = Graphics.loadImage(System.currentDirectory().."ASSETS/RULEBOOK_TEX2.png")
	TRANSCRIPT.tex = Graphics.loadImage(System.currentDirectory().."ASSETS/TRANSCRIPT_TEX.png")
	TRANSCRIPT.tex2 = Graphics.loadImage(System.currentDirectory().."ASSETS/TRANSCRIPT_TEX2.png")
	TRANSCRIPT.tex3 = Graphics.loadImage(System.currentDirectory().."ASSETS/TRANSCRIPT_LINE.png")
	BULLETIN.tex = Graphics.loadImage(System.currentDirectory().."ASSETS/BULLETIN_TEX.png")
	BULLETIN.tex2 = Graphics.loadImage(System.currentDirectory().."ASSETS/BULLETIN_TEX2.png")
	EMOA = Graphics.loadImage(System.currentDirectory().."ASSETS/EMOA.png")
	EMOL = Graphics.loadImage(System.currentDirectory().."ASSETS/EMOL.png")
	GIVE = Graphics.loadImage(System.currentDirectory().."ASSETS/GIVE.png")
	SB = Graphics.loadImage(System.currentDirectory().."ASSETS/SB.png")
	clockHOUR = Graphics.loadImage(System.currentDirectory().."ASSETS/clockHOUR.png")
	clockMINUTE = Graphics.loadImage(System.currentDirectory().."ASSETS/clockMINUTE.png")
	CHSheet = Graphics.loadImage(System.currentDirectory().."ASSETS/CHSheet.png")
	FACE = {x=-24,y=104,Graphics.loadImage(System.currentDirectory().."ASSETS/FACE_1.png"), Graphics.loadImage(System.currentDirectory().."ASSETS/FACE_2.png"), Graphics.loadImage(System.currentDirectory().."ASSETS/FACE_3.png"), Graphics.loadImage(System.currentDirectory().."ASSETS/FACE_4.png"), Graphics.loadImage(System.currentDirectory().."ASSETS/FACE_5.png")}
	CITATIONinner = Graphics.loadImage(System.currentDirectory().."ASSETS/CITATIONinner.png")
	CITATIONouter = Graphics.loadImage(System.currentDirectory().."ASSETS/CITATIONouter.png")
	INSPECT_BTN_OPEN = Graphics.loadImage(System.currentDirectory().."ASSETS/InspectButtonOpen.png")
	INSPECT_BTN_CLOSE = Graphics.loadImage(System.currentDirectory().."ASSETS/InspectButtonClose.png")
	DETAIN_BTN_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/DetainButton.png")
	CLOCK_PIN_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/ClockPin.png")
	INSPECT_LINE_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/InspectLine.png")
	SCANNER_PAD_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/SCANNER_PAD.png")
	FINGERPRINTSLIP_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/FINGERPRINTSLIP_TEX.png")
	FINGERPRINTSLIP_TEX2 = Graphics.loadImage(System.currentDirectory().."ASSETS/FINGERPRINTSLIP_TEX2.png")
	IDENTITYRECORD_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/IDENTITYRECORD_TEX.png")
	IDENTITYRECORD_TEX2 = Graphics.loadImage(System.currentDirectory().."ASSETS/IDENTITYRECORD_TEX2.png")
	FINGERPRINTSHEET = Graphics.loadImage(System.currentDirectory().."ASSETS/FINGERPRINTSHEET.png")
end
function GarbageCollection()
	if BKG_BTMS~= nil then
		Graphics.freeImage(BKG_BTMS)
		Graphics.freeImage(BKG_TPS)
		Graphics.freeImage(STMP_SPRITE)
		Graphics.freeImage(BKG_MONITORS)
		Graphics.freeImage(CAGE_TXR)
		Graphics.freeImage(WALL_TXR)
		Graphics.freeImage(SHADOW_TXR)
		Graphics.freeImage(PASSPORT_SHEET)
		Graphics.freeImage(NOTPASSPORT_SHEET)
		Graphics.freeImage(YESSTAMP)
		Graphics.freeImage(NOSTAMP)
		Graphics.freeImage(RULEBOOKSHEETS)
		Graphics.freeImage(ENTRYTICKET.tex)
		Graphics.freeImage(ENTRYTICKET.tex2)
		Graphics.freeImage(ENTRYPERMIT.tex)
		Graphics.freeImage(ENTRYPERMIT.tex2)
		Graphics.freeImage(CARIMAGE)
		Graphics.freeImage(IDCARD.tex)
		Graphics.freeImage(IDCARD.tex2)
		Graphics.freeImage(PASSPORT.tex)
		Graphics.freeImage(PASSPORT.tex2)
		Graphics.freeImage(RULEBOOK.tex)
		Graphics.freeImage(RULEBOOK.tex2)
		Graphics.freeImage(WORKPASS.tex)
		Graphics.freeImage(WORKPASS.tex2)
		Graphics.freeImage(TRANSCRIPT.tex)
		Graphics.freeImage(TRANSCRIPT.tex2)
		Graphics.freeImage(TRANSCRIPT.tex3)
		if BULLETIN and BULLETIN.tex then
			Graphics.freeImage(BULLETIN.tex)
			BULLETIN.tex = nil
		end
		if BULLETIN and BULLETIN.tex2 then
			Graphics.freeImage(BULLETIN.tex2)
			BULLETIN.tex2 = nil
		end
		Graphics.freeImage(clockHOUR)
		Graphics.freeImage(clockMINUTE)
		if FACE and FACE[1] then
			Graphics.freeImage(FACE[1])
			Graphics.freeImage(FACE[2])
			Graphics.freeImage(FACE[3])
			Graphics.freeImage(FACE[4])
			FACE = {x = -24, y = 104}
		end
		Graphics.freeImage(EMOA)
		Graphics.freeImage(EMOL)
		Graphics.freeImage(GIVE)
		Graphics.freeImage(SB)
		Graphics.freeImage(CHSheet)
		if CITATIONinner ~= nil then
			Graphics.freeImage(CITATIONinner)
			CITATIONinner = nil
		end
		if CITATIONouter ~= nil then
			Graphics.freeImage(CITATIONouter)
			CITATIONouter = nil
		end
		if INSPECT_BTN_OPEN ~= nil then
			Graphics.freeImage(INSPECT_BTN_OPEN)
			INSPECT_BTN_OPEN = nil
		end
		if INSPECT_BTN_CLOSE ~= nil then
			Graphics.freeImage(INSPECT_BTN_CLOSE)
			INSPECT_BTN_CLOSE = nil
		end
		if DETAIN_BTN_TEX ~= nil then
			Graphics.freeImage(DETAIN_BTN_TEX)
			DETAIN_BTN_TEX = nil
		end
		if CLOCK_PIN_TEX ~= nil then
			Graphics.freeImage(CLOCK_PIN_TEX)
			CLOCK_PIN_TEX = nil
		end
		if INSPECT_LINE_TEX ~= nil then
			Graphics.freeImage(INSPECT_LINE_TEX)
			INSPECT_LINE_TEX = nil
		end
		if SCANNER_PAD_TEX ~= nil then
			Graphics.freeImage(SCANNER_PAD_TEX)
			SCANNER_PAD_TEX = nil
		end
		if FINGERPRINTSLIP_TEX ~= nil then
			Graphics.freeImage(FINGERPRINTSLIP_TEX)
			FINGERPRINTSLIP_TEX = nil
		end
		if FINGERPRINTSLIP_TEX2 ~= nil then
			Graphics.freeImage(FINGERPRINTSLIP_TEX2)
			FINGERPRINTSLIP_TEX2 = nil
		end
		if IDENTITYRECORD_TEX ~= nil then
			Graphics.freeImage(IDENTITYRECORD_TEX)
			IDENTITYRECORD_TEX = nil
		end
		if IDENTITYRECORD_TEX2 ~= nil then
			Graphics.freeImage(IDENTITYRECORD_TEX2)
			IDENTITYRECORD_TEX2 = nil
		end
		if FINGERPRINTSHEET ~= nil then
			Graphics.freeImage(FINGERPRINTSHEET)
			FINGERPRINTSHEET = nil
		end
	end
	Graphics.freeImage(NORMAL_FONT)
	Graphics.freeImage(SMALL_FONT)
	Graphics.freeImage(DIGITS)
	Graphics.freeImage(DEMObutton)
	Graphics.freeImage(STORYMODEbutton)
	Graphics.freeImage(EXITbutton)
	Graphics.freeImage(STARTbutton)
	Graphics.freeImage(BACKbutton)
	Graphics.freeImage(RESUMEbutton)
	Graphics.freeImage(MAINMENUbutton)
	if SLEEPbutton then Graphics.freeImage(SLEEPbutton) end
	Graphics.freeImage(QUITbutton)
	Graphics.freeImage(Title)
	Graphics.freeImage(MODE1)
	Graphics.freeImage(LINEhor)
	Graphics.freeImage(LINEver)
	if NEWS_TEX then
		Graphics.freeImage(NEWS_TEX)
		NEWS_TEX = nil
		NEWS_TEX_DAY = nil
	end
	if NEWS_EZIC_TEX then
		Graphics.freeImage(NEWS_EZIC_TEX)
		NEWS_EZIC_TEX = nil
	end
	if BULLETIN_BTM_TEX then
		Graphics.freeImage(BULLETIN_BTM_TEX)
		BULLETIN_BTM_TEX = nil
	end
	if OPENCHECKPOINT_TEX then
		Graphics.freeImage(OPENCHECKPOINT_TEX)
		OPENCHECKPOINT_TEX = nil
	end
	OPENCHECKPOINT_TRIED = nil
	if DAYSUMMARY_BKG_TEX then
		Graphics.freeImage(DAYSUMMARY_BKG_TEX)
		DAYSUMMARY_BKG_TEX = nil
	end
	if DAYSUMMARY_TOP_TEX then
		Graphics.freeImage(DAYSUMMARY_TOP_TEX)
		DAYSUMMARY_TOP_TEX = nil
	end
	if BUDGET_CHECK_TEX then
		Graphics.freeImage(BUDGET_CHECK_TEX)
		BUDGET_CHECK_TEX = nil
	end
	if APARTMENT_CLASS_TEX then
		Graphics.freeImage(APARTMENT_CLASS_TEX)
		APARTMENT_CLASS_TEX = nil
	end
end
function LOAD_ITEMS()
	PASSPORT={key="PASSPORT"} --Load Data for PASSPORT
	ENTRYTICKET={key="ENTRYTICKET"} --Load Data for ENTRYTICKET
	ENTRYPERMIT={key="ENTRYPERMIT"}	--Load Data for ENTRYPERMIT
	IDCARD={key="IDCARD"} --Load Data for IDCARD
	WORKPASS={key="WORKPASS"} --Load Data for WORKPASS
	TRANSCRIPT={key="TRANSCRIPT",now=1,x=16,y=-27} --Load Data for TRANSCRIPT
	RULEBOOK={state=2,key="RULEBOOK",now=1,x=5,y=23} --Load Data for RULEBOOK
	BULLETIN={key="BULLETIN",now=1,x=34,y=23} --Load Data for BULLETIN
	DESKTOP={"RULEBOOK","TRANSCRIPT","BULLETIN"} --NAMES OF THE ITEMS THAT ON TABLE
	ALLITEMS={RULEBOOK,TRANSCRIPT,BULLETIN} --TABLES OF ITEMS THAT IN DESKTOP table
	ITEM_BY_KEY={
		RULEBOOK = RULEBOOK,
		TRANSCRIPT = TRANSCRIPT,
		BULLETIN = BULLETIN,
		PASSPORT = PASSPORT,
		IDCARD = IDCARD,
		ENTRYPERMIT = ENTRYPERMIT,
		WORKPASS = WORKPASS,
		ENTRYTICKET = ENTRYTICKET
	}
end
LOAD_ITEMS()

INSPECTION = {
	active = false,
	selected = {},
	match_found = false,
	match_reason = nil,
	is_grave = false,
	interrogated = false,
	can_detain = false,
	detained = false,
	line_timer = 0,
	flash_timer = 0
}

SCANNER = {
	active = false,
	scanned = false,
	x = 75,
	y = 38,
	w = 32,
	h = 24
}
FINGERPRINTSLIP = nil
IDENTITYRECORD = nil

function CLEAR_FINGERPRINT_SLIP()
	if FINGERPRINTSLIP then
		for i = #DESKTOP, 1, -1 do
			if DESKTOP[i] == "FINGERPRINTSLIP" then
				table.remove(DESKTOP, i)
			end
		end
		for i = #ALLITEMS, 1, -1 do
			if ALLITEMS[i] == FINGERPRINTSLIP then
				table.remove(ALLITEMS, i)
			end
		end
		if ITEM_BY_KEY then
			ITEM_BY_KEY["FINGERPRINTSLIP"] = nil
		end
		FINGERPRINTSLIP = nil
	end
	if IDENTITYRECORD then
		for i = #DESKTOP, 1, -1 do
			if DESKTOP[i] == "IDENTITYRECORD" then
				table.remove(DESKTOP, i)
			end
		end
		for i = #ALLITEMS, 1, -1 do
			if ALLITEMS[i] == IDENTITYRECORD then
				table.remove(ALLITEMS, i)
			end
		end
		if ITEM_BY_KEY then
			ITEM_BY_KEY["IDENTITYRECORD"] = nil
		end
		IDENTITYRECORD = nil
	end
	SCANNER.active = false
	SCANNER.scanned = false
	if PERSON then
		PERSON.name_cleared = false
		PERSON.photo_cleared = false
	end
end

function SPAWN_FINGERPRINT_SLIP()
	if FINGERPRINTSLIP_TEX == nil or FINGERPRINTSLIP_TEX2 == nil or IDENTITYRECORD_TEX == nil or IDENTITYRECORD_TEX2 == nil then
		loadtex()
	end
	-- 1. Physical Fingerprint Slip from the applicant (170x60 px)
	FINGERPRINTSLIP = {
		key = "FINGERPRINTSLIP",
		is_fingerprint_slip = true,
		x = 10,
		y = 160,
		target_y = 160,
		now = 0,
		rot = -0.08,
		status = "IDLE",
		step_feed = 0,
		velocity = 0,
		gravity = 0,
		tex = FINGERPRINTSLIP_TEX,
		tex2 = FINGERPRINTSLIP_TEX2
	}
	-- 2. Official MOA Identity Record database dossier from printer (183x98 px)
	IDENTITYRECORD = {
		key = "IDENTITYRECORD",
		is_identity_record = true,
		x = 65,
		y = -100,
		target_y = 75,
		now = 0,
		rot = 0.10,
		status = "PRINTING",
		step_feed = 0,
		velocity = 0,
		gravity = 0,
		tex = IDENTITYRECORD_TEX,
		tex2 = IDENTITYRECORD_TEX2
	}
	if ITEM_BY_KEY then
		ITEM_BY_KEY["FINGERPRINTSLIP"] = FINGERPRINTSLIP
		ITEM_BY_KEY["IDENTITYRECORD"] = IDENTITYRECORD
	end
	table.insert(DESKTOP, 1, "IDENTITYRECORD")
	table.insert(ALLITEMS, 1, IDENTITYRECORD)
	table.insert(DESKTOP, 1, "FINGERPRINTSLIP")
	table.insert(ALLITEMS, 1, FINGERPRINTSLIP)
	PLAY_SFX("photo_print")

	-- If the biometric check is legitimate, clear the infraction flag immediately upon official verification!
	if PERSON then
		if PERSON.has_alias and PERSON.alias then
			PERSON.name_cleared = true
		end
		if PERSON.photo_verified then
			PERSON.photo_cleared = true
		end
	end
end

function RESET_INSPECTION()
	INSPECTION.active = false
	INSPECTION.selected = {}
	INSPECTION.match_found = false
	INSPECTION.match_reason = nil
	INSPECTION.is_grave = false
	INSPECTION.interrogated = false
	INSPECTION.interrogating = false
	INSPECTION.interrogation_queue = nil
	INSPECTION.can_detain = false
	INSPECTION.detained = false
	INSPECTION.line_timer = 0
	INSPECTION.flash_timer = 0
	CLEAR_FINGERPRINT_SLIP()
end

TRAVELER_DOCS = {
	["PASSPORT"] = true,
	["IDCARD"] = true,
	["ENTRYPERMIT"] = true,
	["WORKPASS"] = true,
	["ENTRYTICKET"] = true
}
function HAS_TRAVELER_DOCS()
	for i = 1, #DESKTOP do
		if TRAVELER_DOCS[DESKTOP[i]] then
			return true
		end
	end
	return false
end
BKG_TPSX = 0 --X coordinate of UPPER map
SWITCHER = 1 --Shutter will be closed from the beginning
PERSON={face=math.random(1,44),realface=math.random(1,44)}
STAMP={x=310,y=42,state="CLOSED",red=22,green=22,velocity=0}
FACE={x=-24,y=104}
CAR={} --Table for Car
LASTWRONGCONST="..."
WRONGCONST = "Nothing"
CHAT={} --Storage for dialog bubbles
CHATplace={} --1 - left; 2 - right
CHATx={} -- x coordinate for every dialog bubble
CHATy={}
CHATtime={}
CHATw={}
CHATframe={}

function CLEAR_CHAT()
	CHAT = {}
	CHATplace = {}
	CHATx = {}
	CHATy = {}
	CHATtime = {}
	CHATw = {}
	CHATframe = {}
	CHAT_U = {}
	CHAT_W = {}
end
ENTRYTICKET.rot = math.random(-4,4)/10
ENTRYPERMIT.rot =  math.random(-4,4)/10
IDCARD.rot =  math.random(-4,4)/10
PASSPORT.rot =  math.random(-4,4)/10
WORKPASS.rot =  math.random(-4,4)/10
notconst = 0
SCORE = 0
PEOPLESCORE = 0
CheckPoint = 1
stamp="YES" 
Options={
	["Shadow"] = 1, -- 0 - to Off Shadow; 1 - to On Shadow
	["TextAlign"] = 1, -- 0 - no align function (increases FPS(for Old3DS)); 1 - Turn on centered text
	["NiceShutter"] = 1, -- 0 - to Off Shutter Animation; 1 - to On Shutter Animation
	["Car"] = 1, -- 0 to Delete Car from Screen; 1 to Add it
	["Dialog"] = 1,
	["Sound"] = 1, -- 0 - Mute; 1 - Sound On
	["State"] = 0
}
model = System.getModel()
if model==2 or model>3 then
	Options["Shadow"] = 1
	Options["TextAlign"]=1
	Options["NiceShutter"]=1
	Options["Car"]=1
	Options["Dialog"] = 1
	System.setCpuSpeed(OLD_3DS_CLOCK)
else
	System.setCpuSpeed(OLD_3DS_CLOCK)
end
function BKG_SHDW() -- Adds shadow behind CAGE
	if SWITCHER == 1 and CAGE.yshadow < 103 then
		CAGE.yshadow = CAGE.yshadow + 8
	end
	if SWITCHER == 0 and CAGE.yshadow > -37 then
		CAGE.yshadow = CAGE.yshadow - 4
	end
	if CAGE.yshadow < -37 then
		CAGE.yshadow = -37
	end
	if CAGE.yshadow > 103 then
		CAGE.yshadow = 103
	end
	Graphics.drawImage(112,CAGE.yshadow,SHADOW_TXR)
end
pi=math.pi

-- [LPP-3DS HARDWARE TIMER NORMALIZATION]
-- In LPP-3DS, Timer.getTime() divides raw hardware ticks by 268123.48 (assuming 268 MHz O3DS).
-- If the CPU speed is set or forced to 804 MHz (N3DS mode / Citra / Luma3DS clock boost),
-- hardware ticks accumulate 3x faster, causing timers to advance 3000 ms per second.
-- Consequently, a 3-minute shift (180s = 180,000ms) expires in only 60 real seconds (1 minute).
-- We normalize Timer.getTime() so it always measures real wall-clock milliseconds regardless of CPU frequency.
if Timer and Timer.getTime then
	local _raw_Timer_getTime = Timer.getTime
	Timer.getTime = function(tm)
		if not tm then return 0 end
		local ms = _raw_Timer_getTime(tm)
		if System and System.getCpuSpeed then
			local spd = System.getCpuSpeed()
			if spd and spd > 400 then
				return math.floor(ms * 268 / spd)
			end
		end
		return ms
	end
end

timer = Timer.new()
STAMP_TIMER = Timer.new()
Clock = Timer.new()
GameTIME = Timer.new()
Timer.pause(GameTIME)
clockInt = 0
plusPOINTS = 10
CBtime= Timer.new()
activatescreenshot=0
menu=0
TITLEy=240
DEMO={}
STORYMODE={}
EXIT={}
BACK={}
START={}
MAINMENU={}
RESUME={}
QUIT={}
MODEselect=0
COURSEselect=0
CHECKBOX_init={}
TIMEmin = 0
WRONGMANn = 0
TIMEMINUS = 0
MINUSy=110
PLUSy=110
TIMEy=110

-- [STORY MODE STATE & PERSISTENCE]
IS_STORY_MODE = false
CURRENT_DAY = 1
DAY_INSPECTED_COUNT = 0
DAY_CORRECT_COUNT = 0
DAY_MISTAKES_COUNT = 0
DAY_TIME_LEFT = 180
DAY_TIME_OFFSET = 0
DAY_START_SCORE = 0
DAY_OVER = false
NEWS_TEX = nil
NEWS_TEX_DAY = nil
BULLETIN_BTM_TEX = nil
OPENCHECKPOINT_TEX = nil
OPENCHECKPOINT_TRIED = nil
FADE_STATE = "NONE"
FADE_ALPHA = 0
CURRENT_SAVE = { day = 1, in_progress = 0 }

-- [M.O.A. CITATION SYSTEM]
PERFECT_TIMER = Timer.new()
Timer.pause(PERFECT_TIMER)
PERFECT_GAMEOVER_ACTIVE = false
PERFECT_GAMEOVER_READY = false
CITATIONS = {}
CITATION_COUNT = 0
PENDING_REWARDS = {}
LAST_PLUS_POINTS = 1
LAST_MINUS_POINTS = 5

function CLEAR_CITATIONS()
	CITATIONS = {}
	CITATION_COUNT = 0
	PENDING_REWARDS = {}
	LAST_PLUS_POINTS = 1
	LAST_MINUS_POINTS = 5
	if RESET_INSPECTION then RESET_INSPECTION() end
	PERFECT_GAMEOVER_ACTIVE = false
	PERFECT_GAMEOVER_READY = false
	if PERFECT_TIMER then
		Timer.reset(PERFECT_TIMER)
		Timer.pause(PERFECT_TIMER)
	end
	if DESKTOP then
		local i = 1
		while i <= #DESKTOP do
			if string.sub(DESKTOP[i], 1, 9) == "CITATION_" then
				table.remove(DESKTOP, i)
			else
				i = i + 1
			end
		end
	end
	if ALLITEMS then
		local i = 1
		while i <= #ALLITEMS do
			if ALLITEMS[i] and ALLITEMS[i].is_cit then
				table.remove(ALLITEMS, i)
			else
				i = i + 1
			end
		end
	end
	if ITEM_BY_KEY then
		for k in pairs(ITEM_BY_KEY) do
			if type(k) == "string" and k:sub(1, 9) == "CITATION_" then
				ITEM_BY_KEY[k] = nil
			end
		end
	end
end

function IS_CITATION_PRINTING()
	if PENDING_REWARDS and #PENDING_REWARDS > 0 then
		return true
	end
	if CITATIONS then
		for _, cit in pairs(CITATIONS) do
			if cit.status == "DELAY" or cit.status == "PRINTING" then
				return true
			end
		end
	end
	return false
end

function SPAWN_CITATION(reason_text, penalty_text, penalty_mode, penalty_pts, penalty_time)
	if CITATIONinner == nil or CITATIONouter == nil then
		loadtex()
	end
	CITATION_COUNT = CITATION_COUNT + 1
	local id_str = "CITATION_" .. CITATION_COUNT
	
	local reason_u = string.upper(reason_text or "")
	local penalty_u = string.upper(penalty_text or "")

	local cit = {
		key              = id_str,
		is_cit           = true,
		reason           = reason_text,
		penalty          = penalty_text,
		reason_u         = reason_u,
		penalty_u        = penalty_u,
		title_w          = GPU_MeasureText("MINISTRY OF ADMISSION", 7),
		sub_w            = GPU_MeasureText("OFFICIAL CITATION", 7),
		reason_w         = GPU_MeasureText(reason_u, 7),
		penalty_w        = GPU_MeasureText(penalty_u, 7),
		penalty_mode     = penalty_mode,
		penalty_pts      = penalty_pts or 0,
		penalty_time     = penalty_time or 0,
		now              = 0,
		x                = 12,
		y                = 240,
		target_y         = math.max(100, 160 - (CITATION_COUNT - 1) * 6),
		status           = "DELAY",
		delay_frames     = 0,
		delay_max        = 600,
		step_feed        = 0,
		step_pause       = 0,
		is_fatal         = (MODEselect == 2),
		rot              = (CITATION_COUNT % 2 == 1 and 0.15 or -0.12),
		tex              = CITATIONinner,
		tex2             = CITATIONouter,
		velocity         = 0,
		gravity          = 0
	}
	
	CITATIONS[id_str] = cit
	if ITEM_BY_KEY then
		ITEM_BY_KEY[id_str] = cit
	end
	table.insert(DESKTOP, 1, id_str)
	table.insert(ALLITEMS, 1, cit)
end

function SAVE_GAME(save_data)
	local ok, res = pcall(function()
		local data = {
			day = CURRENT_DAY or 1,
			in_progress = 0,
			elapsed = 0,
			inspected = 0,
			correct = 0,
			mistakes = 0,
			score = 0,
			wrongmann = 0,
			peoplescore = 0
		}
		if type(save_data) == "table" then
			if save_data.day then data.day = math.floor(save_data.day) end
			if save_data.in_progress then data.in_progress = math.floor(save_data.in_progress) end
			if save_data.elapsed then data.elapsed = math.floor(save_data.elapsed) end
			if save_data.inspected then data.inspected = math.floor(save_data.inspected) end
			if save_data.correct then data.correct = math.floor(save_data.correct) end
			if save_data.mistakes then data.mistakes = math.floor(save_data.mistakes) end
			if save_data.score then data.score = math.floor(save_data.score) end
			if save_data.wrongmann then data.wrongmann = math.floor(save_data.wrongmann) end
			if save_data.peoplescore then data.peoplescore = math.floor(save_data.peoplescore) end
		elseif type(save_data) == "number" then
			data.day = math.floor(save_data)
			data.in_progress = 0
		end

		CURRENT_SAVE = data
		CURRENT_DAY = data.day

		local str = "DAY="..data.day.."\n"..
		            "IN_PROGRESS="..data.in_progress.."\n"..
		            "ELAPSED="..data.elapsed.."\n"..
		            "INSPECTED="..data.inspected.."\n"..
		            "CORRECT="..data.correct.."\n"..
		            "MISTAKES="..data.mistakes.."\n"..
		            "SCORE="..data.score.."\n"..
		            "WRONGMANN="..data.wrongmann.."\n"..
		            "PEOPLESCORE="..data.peoplescore.."\n"

		if System and System.createDirectory then
			pcall(function() System.createDirectory("/3ds") end)
			pcall(function() System.createDirectory("sdmc:/3ds") end)
		end

		local paths = {
			"/3ds/papersplease_save.dat",
			"sdmc:/3ds/papersplease_save.dat",
			"/papersplease_save.dat",
			"sdmc:/papersplease_save.dat"
		}
		local written = false
		for _, path in ipairs(paths) do
			if not written then
				local f = nil
				local flag = FCREATE or 2
				local success = pcall(function() f = io.open(path, flag) end)
				if not success or not f then
					pcall(function() f = io.open(path, "w") end)
				end
				if f then
					if io.write then
						io.write(f, 0, str, string.len(str))
						io.close(f)
						written = true
					elseif f.write then
						f:write(str)
						f:close()
						written = true
					end
				end
			end
		end
		return written
	end)
	return ok and res
end

function LOAD_GAME()
	local data = {
		day = 1,
		in_progress = 0,
		elapsed = 0,
		inspected = 0,
		correct = 0,
		mistakes = 0,
		score = 0,
		wrongmann = 0,
		peoplescore = 0
	}
	pcall(function()
		local paths = {
			"/3ds/papersplease_save.dat",
			"sdmc:/3ds/papersplease_save.dat",
			"/papersplease_save.dat",
			"sdmc:/papersplease_save.dat"
		}
		local content = nil
		for _, path in ipairs(paths) do
			if not content then
				local f = nil
				local flag = FREAD or 0
				local success = pcall(function() f = io.open(path, flag) end)
				if not success or not f then
					pcall(function() f = io.open(path, "r") end)
				end
				if f then
					if io.size and io.read then
						local sz = io.size(f) or 1024
						content = io.read(f, 0, sz)
						io.close(f)
					elseif f.read then
						content = f:read("*a")
						f:close()
					end
				end
			end
		end

		if content and type(content) == "string" and #content > 0 then
			if string.find(content, "=") then
				for line in string.gmatch(content, "[^\r\n]+") do
					local k, v = string.match(line, "^([%w_]+)%s*=%s*(.-)%s*$")
					if k and v then
						local num = tonumber(v)
						if k == "DAY" and num then data.day = math.floor(num)
						elseif k == "IN_PROGRESS" and num then data.in_progress = math.floor(num)
						elseif k == "ELAPSED" and num then data.elapsed = num
						elseif k == "INSPECTED" and num then data.inspected = math.floor(num)
						elseif k == "CORRECT" and num then data.correct = math.floor(num)
						elseif k == "MISTAKES" and num then data.mistakes = math.floor(num)
						elseif k == "SCORE" and num then data.score = math.floor(num)
						elseif k == "WRONGMANN" and num then data.wrongmann = math.floor(num)
						elseif k == "PEOPLESCORE" and num then data.peoplescore = math.floor(num)
						end
					end
				end
			else
				local d = tonumber(content)
				if d and d >= 1 then
					data.day = math.floor(d)
				end
			end
		end
	end)
	if not data.day or data.day < 1 then
		data.day = 1
	end
	CURRENT_SAVE = data
	CURRENT_DAY = data.day
	return data
end

function SAVE_STORY_PROGRESS()
	if not IS_STORY_MODE then return end
	local current_elapsed = 0
	if Timer and GameTIME then
		current_elapsed = Timer.getTime(GameTIME) + (DAY_TIME_OFFSET or 0)
	else
		current_elapsed = DAY_TIME_OFFSET or 0
	end
	local day_cfg = GET_DAY_CONFIG(CURRENT_DAY)
	local total_ms = (day_cfg and day_cfg.duration_sec or 180) * 1000
	if current_elapsed >= total_ms then
		current_elapsed = total_ms
	end
	SAVE_GAME({
		day = CURRENT_DAY,
		in_progress = 1,
		elapsed = current_elapsed,
		inspected = DAY_INSPECTED_COUNT,
		correct = DAY_CORRECT_COUNT,
		mistakes = DAY_MISTAKES_COUNT,
		score = SCORE,
		wrongmann = WRONGMANn,
		peoplescore = DAY_INSPECTED_COUNT
	})
end

function START_STORY_MODE()
	CLEAR_CITATIONS()
	IS_STORY_MODE = true
	MODEselect = 4
	local save_data = LOAD_GAME()
	if save_data and save_data.in_progress == 1 and save_data.day and save_data.day >= 1 then
		-- [RESUME IN-PROGRESS STORY MODE]
		CURRENT_DAY = save_data.day
		DAY_TIME_OFFSET = save_data.elapsed or 0
		DAY_INSPECTED_COUNT = save_data.inspected or 0
		DAY_CORRECT_COUNT = save_data.correct or 0
		DAY_MISTAKES_COUNT = save_data.mistakes or 0
		SCORE = save_data.score or 0
		WRONGMANn = save_data.wrongmann or 0
		PEOPLESCORE = save_data.peoplescore or DAY_INSPECTED_COUNT

		if BKG_BTMS == nil then
			loadtex()
		end
		Timer.reset(GameTIME)
		Timer.resume(GameTIME)
		Timer.reset(Clock)
		if CBtime then
			Timer.reset(CBtime)
			Timer.resume(CBtime)
		end
		clockInt = 0
		local day_cfg = GET_DAY_CONFIG(CURRENT_DAY)
		local total_ms = (day_cfg and day_cfg.duration_sec or 180) * 1000
		if DAY_TIME_OFFSET >= total_ms then
			DAY_OVER = true
			TIME = 0
		else
			DAY_OVER = false
			TIME = total_ms - DAY_TIME_OFFSET
		end
		TIMEsec = TIME/1000
		TIMEmin = math.floor(TIMEsec/60)
		TIMEsec = math.floor(TIMEsec - TIMEmin*60)
		FADE_STATE = "NONE"
		FADE_ALPHA = 0
		CheckPoint = 1
		stamp = "YES"
		if FACE then
			FACE.x = -24
			FACE.y = 104
		end
		SWITCHER = 1
		for i=1,#DESKTOP do table.remove(DESKTOP,1) end
		for i=1,#ALLITEMS do table.remove(ALLITEMS,1) end
		CLEAR_CHAT()
		table.insert(DESKTOP,1,"TRANSCRIPT")
		table.insert(ALLITEMS,1,TRANSCRIPT)
		table.insert(DESKTOP,1,"RULEBOOK")
		table.insert(ALLITEMS,1,RULEBOOK)
		table.insert(DESKTOP,1,"BULLETIN")
		table.insert(ALLITEMS,1,BULLETIN)
		RULEBOOK.x = 5
		RULEBOOK.y = 23
		RULEBOOK.now = 1
		BULLETIN.x = 34
		BULLETIN.y = 23
		BULLETIN.now = 1
		menu = 2
	else
		-- [START NEW DAY OR NOT IN PROGRESS]
		CURRENT_DAY = (save_data and save_data.day) or 1
		if CURRENT_DAY < 1 then
			CURRENT_DAY = 1
		end
		DAY_START_SCORE = (save_data and save_data.score) or 0
		SCORE = DAY_START_SCORE
		DAY_TIME_OFFSET = 0
		menu = "DayIntro"
	end
end

CURRENT_SAVE = LOAD_GAME()
CURRENT_DAY = CURRENT_SAVE.day

function CHECKBOX(x,y,wtc)
	CHECKBOX_init[wtc] = CHECKBOX_init[wtc] or Options[wtc]
	if TOUCHy>y and TOUCHy<y+15 and TOUCHx>x and TOUCHx<x+15 then
		if Options[wtc] == CHECKBOX_init[wtc] then
			if Options[wtc]==1 then 
				Options[wtc]=0
				if wtc=="Sound" then
					STOP_BGM()
					STOP_AMBIENT()
				end
			elseif Options[wtc]==0 then 
				Options[wtc]=1
				if wtc=="Sound" then
					-- Sound re-enabled
				end
			end	
		end
	else
		CHECKBOX_init[wtc]=Options[wtc]
	end
	if Options[wtc]==0 then	Graphics.drawPartialImage(x, y, 0, 0, 15, 15, CHECKBOXbutton)	elseif Options[wtc]==1 then	Graphics.drawPartialImage(x, y, 0, 15, 15, 15, CHECKBOXbutton)	end
end
function TITLE_MOVE()
	time = Timer.getTime(timer)
	if time>1000 then 
		if TITLEy>-265 then
			TITLEx=TITLEx or TITLEy-20
			else
			TITLEx=TITLEx or TITLEy+20
		end
		if TITLEy>TITLEx then 
			TITLEy=TITLEy-2 
			elseif TITLEx>TITLEy then
			TITLEy=TITLEy+2 
			elseif TITLEx==TITLEy then
			TITLEx=nil
			Timer.reset(timer)
			Timer.resume(timer)
		end
	end
end
function OptionsOP()
	if Controls.check(pad,KEY_DUP) and Controls.check(pad,KEY_A) and Controls.check(pad,KEY_B) and not Controls.check(oldpad,KEY_DUP) then
		if Options["State"]==1 then Options["State"]=0 elseif Options["State"]==0 then Options["State"]=1 end 
	end
	if Options["State"]==1 then
		Options["Shadow"] = 1
		Options["TextAlign"]=1
		Options["NiceShutter"]=1
		Options["Car"]=1
		Options["Dialog"] = 1
		elseif Options["State"]==0 then
		Options["Shadow"] = 1
		Options["TextAlign"]=0
		Options["NiceShutter"]=1
		Options["Car"]=1
		Options["Dialog"] = 0
	end
end
function ScreenButton(xbut,ybut,texture,key,word)
	word.TOUCHED=word.TOUCHED or "NO"
	if TOUCHx==0 and TOUCHy==0 and word.TOUCHED == "YES" and TOUCHer~="BB" then
		PLAY_SFX("button_down")
		if key==2 then
			STOP_BGM()
			if menu=="Selection" then
				CLEAR_CITATIONS()
				-- [ARCADE MODE INITIALIZATION]
				-- Endurance mode starts with 30 credits (authentic Papers, Please economy).
				-- All other arcade modes start at 0.
				WRONGMANn = 0
				DAY_MISTAKES_COUNT = 0
				DAY_CORRECT_COUNT = 0
				DAY_INSPECTED_COUNT = 0
				TIMEMINUS = 0
				if MODEselect == 3 then
					SCORE = 30
				else
					SCORE = 0
				end
				DAY_START_SCORE = SCORE
				PEOPLESCORE = 0
			end
			if BKG_BTMS==nil then
				loadtex()
			end
			Timer.resume(GameTIME)
			if CBtime then Timer.resume(CBtime) end
			RESUME_AUDIO()
		end
		if key==0 then
			CLEAR_CITATIONS()
			if IS_STORY_MODE and (menu=="Pause" or menu==2) then
				SAVE_STORY_PROGRESS()
			end
			STOP_AMBIENT()
			Timer.reset(GameTIME)
			Timer.reset(Clock)
			Timer.reset(timer)
			Timer.pause(GameTIME)
			MODEselect = 0
			COURSEselect = 0
			WRONGMANn = 0
			SCORE = 0
			PEOPLESCORE = 0
			CheckPoint = 1
			TIMEMINUS = 0
			stamp="YES"
			if FACE then
				FACE.x=-24
				FACE.y=104
			end
			IS_STORY_MODE = false
			DAY_OVER = false
			DAY_INSPECTED_COUNT = 0
			DAY_CORRECT_COUNT = 0
			DAY_MISTAKES_COUNT = 0
			DAY_TIME_OFFSET = 0
			FADE_STATE = "NONE"
			FADE_ALPHA = 0
			CURRENT_SAVE = LOAD_GAME()
			CURRENT_DAY = CURRENT_SAVE.day
			for i=1,#DESKTOP do table.remove(DESKTOP,1) end
			for i=1,#ALLITEMS do table.remove(ALLITEMS,1) end
			CLEAR_CHAT()
			table.insert(DESKTOP,1,"TRANSCRIPT")
			table.insert(ALLITEMS,1,TRANSCRIPT)
			table.insert(DESKTOP,1,"RULEBOOK")
			table.insert(ALLITEMS,1,RULEBOOK)
			table.insert(DESKTOP,1,"BULLETIN")
			table.insert(ALLITEMS,1,BULLETIN)
			BULLETIN.x = 34
			BULLETIN.y = 23
			BULLETIN.now = 1
			SWITCHER = 1
		end
		if key=="Exit" then
			TERM_AUDIO()
			if IS_STORY_MODE and (menu=="Pause" or menu==2) then
				SAVE_STORY_PROGRESS()
			end
		end
		if key=="Pause" then
			Timer.pause(GameTIME)
			PAUSE_AUDIO()
		end
		if key=="DayIntro" then
			STOP_BGM()
			STOP_AMBIENT()
			START_STORY_MODE()
			word.TOUCHED="NO"
			return
		end
		menu=key
		word.TOUCHED="NO"
	end
	if TOUCHx>0 and TOUCHy>0 then
		if TOUCHx>=xbut and TOUCHy>=ybut and TOUCHx<=xbut+Graphics.getImageWidth(texture) and TOUCHy<=ybut+(Graphics.getImageHeight(texture)/2) then
			word.TOUCHED="YES"
			else
			word.TOUCHED="NO"
		end
	end
	if word.TOUCHED=="NO" then
		Graphics.drawPartialImage(xbut, ybut, 0, 0, Graphics.getImageWidth(texture), (Graphics.getImageHeight(texture)/2), texture)
		elseif word.TOUCHED=="YES" then
		Graphics.drawPartialImage(xbut, ybut, 0, (Graphics.getImageHeight(texture)/2), Graphics.getImageWidth(texture), (Graphics.getImageHeight(texture)/2), texture)
	end
	
end
function screenshotmake()
	if activatescreenshot>0 then
		activatescreenshot=activatescreenshot-5
		Graphics.fillRect(0,400,0,320,Color.new(255,255,255,activatescreenshot))
	end
end
function CARs()
	CAR.randomo = CAR.randomo or math.random(300,900)
	CAR.y=CAR.y or -(CAR.randomo)
	if CAR.y<CAR.randomo then
		CAR.y=CAR.y+5
		else
		CAR.y = -(CAR.randomo)
		CAR.randomo = nil
	end
	
end
function makeString(l)
	if l < 1 then return nil end -- Check for l < 1
	local s = "" -- Start string
	for i = 1, l do
		s = s .. string.char(math.random(65, 90)) -- Generate random number from 32 to 126, turn it into character and add to string
	end
	return string.upper(s) -- Return string
end
function System.wait(milliseconds)
	tmp = Timer.new()
	while Timer.getTime(tmp) < milliseconds do end
	Timer.destroy(tmp)
end
function MAP_MOVE() -- Moving of map background (BKG_TPS)
	if math.abs(STICK.x) > 15 and BKG_TPSX > -170 and BKG_TPSX < 0 then
		BKG_TPSX = BKG_TPSX - STICK.x/25
	end
	if BKG_TPSX >= 0 then
		BKG_TPSX = -1
		elseif BKG_TPSX <= -170 then
		BKG_TPSX = -169
	end
end
function CAGE_MOVE() -- Adds an Shutter
	if PREV_SWITCHER == nil then PREV_SWITCHER = SWITCHER end
	if SWITCHER ~= PREV_SWITCHER then
		if SWITCHER == 0 then
			PLAY_SFX("shutter_rise")
		else
			PLAY_SFX("shutter_drop")
		end
		PREV_SWITCHER = SWITCHER
	end
	if Options["NiceShutter"]==1 then
		for i=1,6 do
			CAGE.y[i] = CAGE.y[i] or CAGE.min+20*(i-1)
			if CAGE.min<103 and SWITCHER==1 then 
				CAGE.min=CAGE.min+10
			end
			if CAGE.min>33 and SWITCHER==0 then 
				CAGE.min=CAGE.min-10
			end
			if CAGE.y[i]>CAGE.min+20*(i-1) and SWITCHER==1 then
				CAGE.y[i] = CAGE.min+20*(i-1)
			end
			if CAGE.y[i]<CAGE.min+10*(i-1) and SWITCHER==0 then
				CAGE.y[i] = CAGE.min+8*(i-1)
			end
			if SWITCHER==1 and CAGE.y[i]<CAGE.min+20*(i-1) then
				CAGE.y[i] = CAGE.y[i]+8
			end		
			if CAGE.y[6]~=nil then
				if SWITCHER==0 then
					if i>0 and i<6 then
						if CAGE.y[i+1]-10<CAGE.y[i] and CAGE.y[i]>CAGE.min+10*(i-1) then
							CAGE.y[i]=CAGE.y[i]-4
						end
						elseif i==6 then
						if CAGE.y[i]>CAGE.min+10*(i-1) then
							CAGE.y[i]=CAGE.y[i]-4
						end
					end
				end
				Graphics.drawPartialImage(112,CAGE.y[7-i],0,20*(6-i),180,20,CAGE_TXR)
			end
		end
		elseif Options["NiceShutter"]==0 then
		Graphics.drawImage(112,CAGE.OLDy,CAGE_TXR)
		if CAGE.OLDy<93 and SWITCHER==1 then
			CAGE.OLDy = CAGE.OLDy + 10
			elseif CAGE.OLDy>93 and SWITCHER==1 then
			CAGE.OLDy=CAGE.OLDy-1
		end
		if CAGE.OLDy>-17 and SWITCHER==0 then
			CAGE.OLDy=CAGE.OLDy-4
			elseif CAGE.OLDy<-17 and SWITCHER==0 then
			CAGE.OLDy=CAGE.OLDy+1
		end
	end
	if SWITCHER==1 then
		Graphics.drawPartialImage(262,120,252,123,28,23,STMP_SPRITE)
	end
	if SWITCHER==0 then
		Graphics.drawPartialImage(262,120,252,146,28,23,STMP_SPRITE)
	end
	if Controls.check(pad,KEY_R) and not Controls.check(oldpad,KEY_R) then
		if SWITCHER==1 then SWITCHER=0 elseif SWITCHER==0 then SWITCHER=1 end 
	end
end
function LOAD_FACE(num)
	if CAGE.yshadow~=103 then
		if num <= 24 then
			Graphics.drawPartialImage(FACE.x,FACE.y,150*(num - (6*(math.ceil((num-0.1)/6)-1)+1)),120*(math.ceil((num-0.1)/6)-1)+1,150,119, FACE[1])
			else
			Graphics.drawPartialImage(FACE.x,FACE.y,150*(num - (6*(math.ceil((num-24.1)/6)-1)+25)),120*(math.ceil((num-0.1)/6)-5)+1,150,119, FACE[2])
		end
	end
	if CAGE.yshadow<83 then
		if num <= 24 then
			Graphics.drawPartialImage(FACE.x,FACE.y,150*(num - (6*(math.ceil((num-0.1)/6)-1)+1)),120*(math.ceil((num-0.1)/6)-1)+1,150,CAGE.yshadow+36, FACE[3],Color.new(50,37,37))
			else
			Graphics.drawPartialImage(FACE.x,FACE.y,150*(num - (6*(math.ceil((num-24.1)/6)-1)+25)),120*(math.ceil((num-0.1)/6)-5)+1,150,CAGE.yshadow+36, FACE[4],Color.new(50,37,37))
		end
		else
		if num <= 24 then
			Graphics.drawPartialImage(FACE.x,FACE.y,150*(num - (6*(math.ceil((num-0.1)/6)-1)+1)),120*(math.ceil((num-0.1)/6)-1)+1,150,119, FACE[3],Color.new(50,37,37))
			else
			Graphics.drawPartialImage(FACE.x,FACE.y,150*(num - (6*(math.ceil((num-24.1)/6)-1)+25)),120*(math.ceil((num-0.1)/6)-5)+1,150,119, FACE[4],Color.new(50,37,37))
		end
	end
	if FACE.x~=126 and CAGE.yshadow~=103 then
		if num <= 24 then
			Graphics.drawPartialImage(FACE.x,FACE.y,150*(num - (6*(math.ceil((num-0.1)/6)-1)+1)),120*(math.ceil((num-0.1)/6)-1)+1,150,119, FACE[3],Color.new(25,18,18))
			else
			Graphics.drawPartialImage(FACE.x,FACE.y,150*(num - (6*(math.ceil((num-24.1)/6)-1)+25)),120*(math.ceil((num-0.1)/6)-5)+1,150,119, FACE[4],Color.new(25,18,18))
		end
	end
	notconst=notconst+0.02
	if notconst>2*pi then
		notconst=notconst-2*pi
	end
	FACE.y=104+2*math.floor(2*math.sin(notconst))
end
function TOUCH_CHECK(word,key)
	if word.is_cit then
		if word.status == "DELAY" then
			return
		end

		local w = (word.now == 1) and 68 or 183
		local h = (word.now == 1) and 27 or 80

		if TOUCHx > 0 and TOUCHy > 0 then
			local touch_y_min = (word.now == 0) and math.max(word.y, 68) or word.y
			if TOUCH == "ACTIVE" and TOUCHx >= word.x and TOUCHx <= word.x + w and TOUCHy >= touch_y_min and TOUCHy <= word.y + h then
				TOUCH = key
				word.oldtouchx = TOUCHx - word.x
				word.oldtouchy = TOUCHy - word.y
				word.velocity = 0
				word.gravity = 0
				if word.status == "PRINTING" then
					word.status = "IDLE"
					PLAY_SFX("printer_tear")
					if word.is_fatal and not PERFECT_GAMEOVER_READY then
						PERFECT_GAMEOVER_READY = true
						if PERFECT_TIMER == nil then PERFECT_TIMER = Timer.new() end
						Timer.reset(PERFECT_TIMER)
						Timer.resume(PERFECT_TIMER)
					end
				else
					PLAY_SFX("paper_dragstart")
				end
			end

			if TOUCH == key then
				word.oldtouchx = word.oldtouchx or (TOUCHx - word.x)
				word.oldtouchy = word.oldtouchy or (TOUCHy - word.y)

				-- Slide above counter: shrink citation to compact slip
				if TOUCHy <= 67 and word.now == 0 then
					word.now = 1
					w = 68
					h = 27
					word.oldtouchx = math.floor(w / 2)
					word.oldtouchy = math.floor(h / 2)
				-- Slide down onto desk: expand citation to full readable document
				elseif TOUCHy > 67 and word.now == 1 then
					word.now = 0
					w = 183
					h = 80
					word.oldtouchx = math.floor(w / 2)
					word.oldtouchy = math.floor(h / 2)
				end

				word.x = TOUCHx - word.oldtouchx
				word.y = TOUCHy - word.oldtouchy

				local half_w = math.floor(w / 2)

				if word.now == 1 then
					-- Shrunk on the counter: free placement anywhere on the counter shelf, can slide half-way off lateral edges
					if word.x < -half_w then word.x = -half_w end
					if word.x > 320 - half_w then word.x = 320 - half_w end
					if word.y < 5 then word.y = 5 end
					if word.y > 60 then word.y = 60 end
				else
					-- Expanded on the desk: allowed to slide underneath the counter ledge and exit lateral edges by half
					if word.x < -half_w then word.x = -half_w end
					if word.x > 320 - half_w then word.x = 320 - half_w end
					if word.y < -40 then word.y = -40 end
					if word.y > 220 then word.y = 220 end
				end
			end
		end

		if (TOUCHx == 0 and TOUCHy == 0) and TOUCH == key then
			word.oldtouchx = nil
			word.oldtouchy = nil
			PLAY_SFX("paper_dragstop")
		end

		if TOUCH ~= key and (word.oldtouchx ~= nil or word.oldtouchy ~= nil) then
			word.oldtouchx = nil
			word.oldtouchy = nil
		end

		if TOUCH ~= key and word.now == 1 then
			word.velocity = word.velocity or 0
			word.gravity = word.gravity or 0

			-- If protruding from lower counter edge: slide towards shelf height y = 23 (like passport and ID card)
			if word.y <= 23 then
				word.gravity = 0
				word.velocity = 0
			else
				word.gravity = 0.1
			end

			if word.y > 24 then
				word.velocity = word.velocity + word.gravity
				word.y = word.y - word.velocity
				if word.y <= 23 then
					word.y = 23
					word.velocity = 0
					word.gravity = 0
				end
			end
		end

		return
	end
	if word.is_fingerprint_slip or word.is_identity_record then
		local w = 170
		local h = 60
		if word.is_fingerprint_slip then
			w = (word.now == 1) and 87 or 170
			h = (word.now == 1) and 30 or 60
		else
			w = (word.now == 1) and 93 or 183
			h = (word.now == 1) and 44 or 98
		end

		if TOUCHx > 0 and TOUCHy > 0 then
			local touch_y_min = (word.now == 0) and math.max(word.y, 68) or word.y
			if TOUCH == "ACTIVE" and TOUCHx >= word.x and TOUCHx <= word.x + w and TOUCHy >= touch_y_min and TOUCHy <= word.y + h then
				TOUCH = key
				word.oldtouchx = TOUCHx - word.x
				word.oldtouchy = TOUCHy - word.y
				word.velocity = 0
				word.gravity = 0
				if word.status == "PRINTING" then
					word.status = "IDLE"
					PLAY_SFX("printer_tear")
				else
					PLAY_SFX("paper_dragstart")
				end
			end

			if TOUCH == key then
				word.oldtouchx = word.oldtouchx or (TOUCHx - word.x)
				word.oldtouchy = word.oldtouchy or (TOUCHy - word.y)

				if TOUCHy <= 67 and word.now == 0 then
					word.now = 1
					if word.is_fingerprint_slip then
						w, h = 87, 30
					else
						w, h = 93, 44
					end
					word.oldtouchx = math.floor(w / 2)
					word.oldtouchy = math.floor(h / 2)
				elseif TOUCHy > 67 and word.now == 1 then
					word.now = 0
					if word.is_fingerprint_slip then
						w, h = 170, 60
					else
						w, h = 183, 98
					end
					word.oldtouchx = math.floor(w / 2)
					word.oldtouchy = math.floor(h / 2)
				end

				word.x = TOUCHx - word.oldtouchx
				word.y = TOUCHy - word.oldtouchy

				local half_w = math.floor(w / 2)

				if word.now == 1 then
					if word.x < -half_w then word.x = -half_w end
					if word.x > 320 - half_w then word.x = 320 - half_w end
					if word.y < 5 then word.y = 5 end
					if word.y > 60 then word.y = 60 end
				else
					if word.x < -half_w then word.x = -half_w end
					if word.x > 320 - half_w then word.x = 320 - half_w end
					if word.y < -40 then word.y = -40 end
					if word.y > 220 then word.y = 220 end
				end
			end
		end

		if (TOUCHx == 0 and TOUCHy == 0) and TOUCH == key then
			word.oldtouchx = nil
			word.oldtouchy = nil
			PLAY_SFX("paper_dragstop")
		end

		if TOUCH ~= key and (word.oldtouchx ~= nil or word.oldtouchy ~= nil) then
			word.oldtouchx = nil
			word.oldtouchy = nil
		end

		if TOUCH ~= key and word.now == 1 then
			word.velocity = word.velocity or 0
			word.gravity = word.gravity or 0

			if word.y <= 23 then
				word.gravity = 0
				word.velocity = 0
			else
				word.gravity = 0.1
			end

			if word.y > 24 then
				word.velocity = word.velocity + word.gravity
				word.y = word.y - word.velocity
				if word.y <= 23 then
					word.y = 23
					word.velocity = 0
					word.gravity = 0
				end
			end
		end

		return
	end
	if key=="RULEBOOK" then
		word.x = word.x or 5
		word.y = word.y or 23
	elseif key=="TRANSCRIPT" then
		word.x = word.x or 16
		word.y = word.y or -27
	elseif key=="BULLETIN" then
		word.x = word.x or 34
		word.y = word.y or 23
	else
		word.x = word.x or 145
		word.y = word.y or -200
	end
	word.now = word.now or 1
	word.velocity=word.velocity or 0
	word.gravity=word.gravity or 0
	if TOUCHx>0 and TOUCHy>0 then
		if word.now==1 then
			if	TOUCH=="ACTIVE" and TOUCHx >= word.x and TOUCHx <= word.x+Graphics.getImageWidth(word.tex2) and TOUCHy>=word.y and TOUCHy <= word.y+Graphics.getImageHeight(word.tex2) then 
				TOUCH = key
				word.velocity=0
				PLAY_SFX("paper_dragstart")
			end
			if TOUCH == key then
				word.oldtouchx = word.oldtouchx or TOUCHx-word.x
				word.oldtouchy = word.oldtouchy or TOUCHy-word.y
				if TOUCHx-word.oldtouchx>35 and TOUCHx-word.oldtouchx+Graphics.getImageWidth(word.tex2)<285 and key~="RULEBOOK" and key~="TRANSCRIPT" and key~="BULLETIN" then
					word.x=TOUCHx-word.oldtouchx
				elseif TOUCHx-word.oldtouchx<35 and key~="RULEBOOK" and key~="TRANSCRIPT" and key~="BULLETIN" then
					word.x=35
				elseif word.y<22 and key=="TRANSCRIPT" then
					word.x=16
				elseif TOUCHx-word.oldtouchx>285-math.floor(Graphics.getImageWidth(word.tex2)) then
					word.x=285-math.floor(Graphics.getImageWidth(word.tex2))
				elseif TOUCHx-word.oldtouchx>5 and TOUCHx-word.oldtouchx+Graphics.getImageWidth(word.tex2)<285 and (key=="RULEBOOK" or key=="TRANSCRIPT" or key=="BULLETIN") then
					word.x=TOUCHx-word.oldtouchx
				elseif TOUCHx-word.oldtouchx<5 and (key=="RULEBOOK" or key=="TRANSCRIPT" or key=="BULLETIN") then
					word.x=5
				end
				if TOUCHy-word.oldtouchy+Graphics.getImageHeight(word.tex2)<340 and TOUCHy-word.oldtouchy>22 and (stamp==nil or key=="RULEBOOK" or key=="TRANSCRIPT" or key=="BULLETIN") then
					word.y=TOUCHy-word.oldtouchy
				elseif TOUCHy-word.oldtouchy+Graphics.getImageHeight(word.tex2)<340 and stamp~=nil and key~="RULEBOOK" and key~="TRANSCRIPT" and key~="BULLETIN" then
					word.y=TOUCHy-word.oldtouchy
				elseif TOUCHy-word.oldtouchy+Graphics.getImageHeight(word.tex2)<340 and key=="TRANSCRIPT" and word.x<36 then
					word.y=TOUCHy-word.oldtouchy
				end
			end
			elseif word.now==0 then
			if	TOUCHy>67 and TOUCH=="ACTIVE" and TOUCHx >= word.x and TOUCHx <= word.x+Graphics.getImageWidth(word.tex) and TOUCHy>=word.y and TOUCHy <= word.y+Graphics.getImageHeight(word.tex) then 
				TOUCH = key
				word.velocity=0
				PLAY_SFX("paper_dragstart")
			end
			if TOUCH == key then
				word.oldtouchx = word.oldtouchx or TOUCHx-word.x
				word.oldtouchy = word.oldtouchy or TOUCHy-word.y
				if TOUCHx-word.oldtouchx>-math.floor(Graphics.getImageWidth(word.tex)/2) and TOUCHx-word.oldtouchx+Graphics.getImageWidth(word.tex)<385 then
					word.x=TOUCHx-word.oldtouchx
				end
				if TOUCHy-word.oldtouchy+Graphics.getImageHeight(word.tex)<340 and TOUCHy-word.oldtouchy>-Graphics.getImageHeight(word.tex) then
					word.y=TOUCHy-word.oldtouchy
				end
				if TOUCHx>=word.x+218 and TOUCHx<=word.x+238 and TOUCHy>=word.y+144 and TOUCHy<word.y+158 and key=="RULEBOOK" and RULEBOOK.state<8 then
					RULEBOOK.state=RULEBOOK.state+1
					TOUCH="SHEET"
					PLAY_SFX("paper_turnpage")
				elseif TOUCHx>=word.x and TOUCHx<=word.x+16 and TOUCHy>=word.y+144 and TOUCHy<word.y+158 and key=="RULEBOOK" and RULEBOOK.state>2 then
					RULEBOOK.state=RULEBOOK.state-1
					TOUCH="SHEET"
					PLAY_SFX("paper_turnpage")
				end
			end
		end
		
		if TOUCHy>67 and TOUCH==key and word.now==1 then
			word.now=0
			word.velocity=0
			word.gravity=0
			word.x=TOUCHx-math.floor(Graphics.getImageWidth(word.tex)/2)
			word.y=TOUCHy-math.floor(Graphics.getImageHeight(word.tex)/2)
			word.oldtouchx = nil
			word.oldtouchy = nil
		end
		if TOUCHy<=67 and TOUCH==key and word.now==0 then
			word.now=1
			word.velocity=0
			word.gravity=0
			word.x=TOUCHx-math.floor(Graphics.getImageWidth(word.tex2)/2)
			word.y=TOUCHy-math.floor(Graphics.getImageHeight(word.tex2)/2)
			word.oldtouchx = nil
			word.oldtouchy = nil
		end
	end	
	if TOUCH~=key and word.now==1 and key~="RULEBOOK" and key~="TRANSCRIPT" and key~="BULLETIN" then
		word.velocity = word.velocity or 0
		word.gravity = word.gravity or 0

		if word.y < 23 then
			word.gravity = 0
			word.velocity = 0
			word.y = word.y + 3
			if word.y >= 23 then
				word.y = 23
			end
		elseif word.y > 24 then
			word.gravity = 0.1
			word.velocity = word.velocity + word.gravity
			word.y = word.y - word.velocity
			if word.y <= 23 then
				word.y = 23
				word.velocity = 0
				word.gravity = 0
			end
		else
			word.gravity = 0
			word.velocity = 0
		end
	end
	if TOUCH~=key and word.now==1 and key=="RULEBOOK" then
		word.velocity = word.velocity or 0
		if word.x > 5 then
			word.gravity = 0.5
			word.velocity = word.velocity + word.gravity
			if word.velocity > 12 then word.velocity = 12 end
			word.x = word.x - word.velocity
			if word.x <= 5 then
				word.x = 5
				word.velocity = 0
				word.gravity = 0
			end
		elseif word.x < 5 then
			word.x = 5
			word.velocity = 0
			word.gravity = 0
		else
			word.velocity = 0
			word.gravity = 0
		end
		if word.y > 23 then
			word.y = word.y - 1
			if word.y <= 23 then word.y = 23 end
		elseif word.y < 23 then
			word.y = 23
		end
	end
	if TOUCH~=key and word.now==1 and key=="BULLETIN" then
		word.velocity = word.velocity or 0
		if word.x > 34 then
			word.gravity = 0.5
			word.velocity = word.velocity + word.gravity
			if word.velocity > 12 then word.velocity = 12 end
			word.x = word.x - word.velocity
			if word.x <= 34 then
				word.x = 34
				word.velocity = 0
				word.gravity = 0
			end
		elseif word.x < 34 then
			word.x = 34
			word.velocity = 0
			word.gravity = 0
		else
			word.velocity = 0
			word.gravity = 0
		end
		if word.y > 23 then
			word.y = word.y - 1
			if word.y <= 23 then word.y = 23 end
		elseif word.y < 23 then
			word.y = 23
		end
	end
	if TOUCH~=key and (word.oldtouchx~=nil or word.oldtouchy~=nil) then
		word.oldtouchx=nil
		word.oldtouchy=nil
		PLAY_SFX("paper_dragstop")
	end
	if TOUCH~=key and word.now==1 and key=="TRANSCRIPT" then
		word.velocity = word.velocity or 0
		if word.x > 16 then
			word.gravity = 0.5
			word.velocity = word.velocity + word.gravity
			if word.velocity > 12 then word.velocity = 12 end
			word.x = word.x - word.velocity
			if word.x <= 16 then
				word.x = 16
				word.velocity = 0
				word.gravity = 0
			end
		elseif word.x < 16 then
			word.x = 16
			word.velocity = 0
			word.gravity = 0
		else
			word.velocity = 0
			word.gravity = 0
		end
		if word.x == 16 then
			if word.y > -27 then
				word.y = word.y - 3
				if word.y <= -27 then word.y = -27 end
			elseif word.y < -27 then
				word.y = -27
			end
		end
	end
end

--------------------------------------------------------------------------------
-- BULLETIN DYNAMIC LAYOUT ENGINE (DESK RENDERING)
--------------------------------------------------------------------------------

function GET_BULLETIN_LAYOUT(cur_cfg)
	local rules = (cur_cfg and cur_cfg.bulletin_rules) or { "ARSTOTZKAN CITIZENS ONLY", "DENY ALL FOREIGNERS" }
	local rule_info = {}
	for idx = 1, #rules do
		local r_text = rules[idx]
		if r_text then
			local is_wrapped = false
			local l1, l2 = r_text, nil
			if string.len(r_text) > 22 then
				local split_pos = string.find(string.sub(r_text, 1, 22), "%s[^%s]*$") or 20
				l1 = string.sub(r_text, 1, split_pos - 1)
				l2 = string.sub(r_text, split_pos + 1)
				is_wrapped = true
			end

			table.insert(rule_info, {
				idx = idx,
				text = r_text,
				line1 = l1,
				line2 = l2,
				wrapped = is_wrapped,
				h = is_wrapped and 15 or 7
			})
		end
	end

	local n = #rule_info
	if n == 0 then
		return { rules = {}, sep_y = 131, notice_y1 = 146, notice_y2 = 158, glory_y = 178 }
	end

	local gap = 1
	local start_y = 70
	if n <= 2 then
		gap = 8
		start_y = 74
	elseif n == 3 then
		gap = 5
		start_y = 72
	elseif n == 4 then
		gap = 3
		start_y = 71
	elseif n == 5 then
		gap = 1
		start_y = 70
	else
		gap = 1
		start_y = 69
	end

	local cur_y = start_y
	local layout_rules = {}
	for _, ri in ipairs(rule_info) do
		local ry = cur_y
		table.insert(layout_rules, {
			idx = ri.idx,
			text = ri.text,
			line1 = ri.line1,
			line2 = ri.line2,
			wrapped = ri.wrapped,
			ry = ry
		})
		cur_y = ry + ri.h + gap
	end

	local last_rule_bottom = (cur_y - gap)
	local sep_y = last_rule_bottom + 3
	if n <= 3 then
		sep_y = math.max(sep_y, 131)
	elseif n == 4 then
		sep_y = math.max(sep_y, 136)
	end

	local notice_y1 = sep_y + 4
	local notice_y2 = notice_y1 + 9
	local glory_y = math.min(189, math.max(notice_y2 + 11, 186))

	return {
		rules = layout_rules,
		sep_y = sep_y,
		notice_y1 = notice_y1,
		notice_y2 = notice_y2,
		glory_y = glory_y
	}
end

--------------------------------------------------------------------------------
-- INSPECTION MODE: ACTIVE HOTSPOTS RESOLUTION & TOUCH HIT-TESTING
--------------------------------------------------------------------------------

function GET_ACTIVE_HOTSPOTS()
	local hotspots = {}
	if not INSPECTION_HOTSPOTS then return hotspots end
	for i = 1, #DESKTOP do
		local key = DESKTOP[i]
		local doc = ITEM_BY_KEY and ITEM_BY_KEY[key]
		if doc and doc.now == 0 then
			local templates = nil
			if key == "PASSPORT" and INSPECTION_HOTSPOTS_PASSPORT and PERSON and PERSON.passport then
				templates = INSPECTION_HOTSPOTS_PASSPORT[PERSON.passport]
			elseif key == "RULEBOOK" then
				if INSPECTION_HOTSPOTS_RULEBOOK and doc.state then
					templates = INSPECTION_HOTSPOTS_RULEBOOK[doc.state]
				end
			elseif key == "BULLETIN" then
				-- Bulletin is an authentic desk reference document; inspection hotspots are disabled
				templates = nil
			end
			if not templates then
				templates = INSPECTION_HOTSPOTS[key]
			end
			if templates then
				for _, t in ipairs(templates) do
					local xo = t.xo
					local yo = t.yo
					if key == "ENTRYPERMIT" and t.cat == "SEAL_MOA" and PERSON and PERSON.permitx and PERSON.permity then
						xo = PERSON.permitx
						yo = PERSON.permity
					elseif key == "WORKPASS" and t.cat == "SEAL_MOL" and PERSON and PERSON.WORKPASSx and PERSON.WORKPASSy then
						xo = PERSON.WORKPASSx
						yo = PERSON.WORKPASSy
					end
					table.insert(hotspots, {
						id = t.id,
						cat = t.cat,
						xo = xo,
						yo = yo,
						x = doc.x + xo,
						y = doc.y + yo,
						w = t.w,
						h = t.h,
						doc = key
					})
				end
			end
		end
	end

	-- Add anchors (always selectable during inspection, on upper shelf)
	if INSPECTION_ANCHORS then
		for _, a in ipairs(INSPECTION_ANCHORS) do
			table.insert(hotspots, {
				id = a.id,
				cat = a.cat,
				x = a.x,
				y = a.y,
				w = a.w,
				h = a.h,
				label = a.label,
				doc = "ANCHOR"
			})
		end
	end

	return hotspots
end

function GET_DOC_DESK_BOUNDS(doc, key)
	if not doc then return 0, 0, 0, 0 end
	local x = doc.x or 0
	local y = doc.y or 0
	local w, h = 150, 200
	if key == "PASSPORT" then
		w, h = 130, 162
	elseif key == "RULEBOOK" then
		w, h = 238, 158
	elseif doc.is_cit then
		w, h = 183, 80
	elseif key == "IDCARD" then
		w, h = 126, 71
	elseif key == "WORKPASS" then
		w, h = 147, 135
	elseif key == "ENTRYPERMIT" then
		w, h = 150, 201
	elseif key == "FINGERPRINTSLIP" or doc.is_fingerprint_slip then
		w, h = 170, 60
	elseif key == "IDENTITYRECORD" or doc.is_identity_record then
		w, h = 183, 98
	elseif doc.tex then
		w = Graphics.getImageWidth(doc.tex)
		h = Graphics.getImageHeight(doc.tex)
	end
	return x, y, w, h
end

local function IS_POINT_IN_DESK_DOC(tx, ty, doc, key)
	if not doc or doc.now ~= 0 then return false end
	if ty < 68 then return false end
	local dx, dy, dw, dh = GET_DOC_DESK_BOUNDS(doc, key)
	return tx >= dx and tx <= dx + dw and ty >= dy and ty <= dy + dh
end

function INSPECTION_TOUCH(tx, ty)
	-- 1. Counter Shelf tap (y <= 67): Anchors & Folded Documents
	if ty <= 67 then
		if INSPECTION_ANCHORS then
			for _, a in ipairs(INSPECTION_ANCHORS) do
				if tx >= a.x and tx <= a.x + a.w and ty >= a.y and ty <= a.y + a.h then
					local hs = {
						id = a.id,
						cat = a.cat,
						x = a.x,
						y = a.y,
						w = a.w,
						h = a.h,
						label = a.label,
						doc = "ANCHOR"
					}
					for j, sel in ipairs(INSPECTION.selected) do
						if sel.id == hs.id then
							table.remove(INSPECTION.selected, j)
							PLAY_SFX("inspect_unhighlight")
							INSPECTION.match_found = false
							INSPECTION.match_reason = nil
							return true
						end
					end
					if #INSPECTION.selected >= 2 then
						table.remove(INSPECTION.selected, 1)
						INSPECTION.match_found = false
						INSPECTION.match_reason = nil
					end
					table.insert(INSPECTION.selected, hs)
					PLAY_SFX("inspect_highlight")
					if #INSPECTION.selected == 2 and CHECK_DISCREPANCY then
						CHECK_DISCREPANCY(INSPECTION.selected[1], INSPECTION.selected[2])
					end
					return true
				end
			end
		end

		for i = 1, #DESKTOP do
			local k = DESKTOP[i]
			local d = ITEM_BY_KEY and ITEM_BY_KEY[k]
			if d and d.now == 1 and d.y >= 0 then
				local w2 = (d.tex2 and Graphics.getImageWidth(d.tex2)) or 68
				local h2 = (d.tex2 and Graphics.getImageHeight(d.tex2)) or 27
				if tx >= d.x and tx <= d.x + w2 and ty >= d.y and ty <= d.y + h2 then
					d.now = 0
					d.y = 80
					d.x = math.min(180, math.max(10, tx - 60))
					PLAY_SFX("paper_dragstop")
					return true
				end
			end
		end
		return false
	end

	-- 2. Desk tap (y > 67): Find top-most document in DESKTOP (Z-order)
	local top_key = nil
	local top_doc = nil
	for i = 1, #DESKTOP do
		local k = DESKTOP[i]
		local d = ITEM_BY_KEY and ITEM_BY_KEY[k]
		if d and IS_POINT_IN_DESK_DOC(tx, ty, d, k) then
			top_key = k
			top_doc = d
			break
		end
	end

	-- If tap was on empty desk table, return false
	if not top_key or not top_doc then
		return false
	end

	-- 3. Top document is RULEBOOK: Check page flip dog-ears first
	if top_key == "RULEBOOK" then
		if tx >= top_doc.x + 215 and tx <= top_doc.x + 238 and ty >= top_doc.y + 138 and ty <= top_doc.y + 158 and top_doc.state < 8 then
			top_doc.state = top_doc.state + 1
			INSPECTION.selected = {}
			INSPECTION.match_found = false
			PLAY_SFX("paper_turnpage")
			return true
		elseif tx >= top_doc.x and tx <= top_doc.x + 22 and ty >= top_doc.y + 138 and ty <= top_doc.y + 158 and top_doc.state > 2 then
			top_doc.state = top_doc.state - 1
			INSPECTION.selected = {}
			INSPECTION.match_found = false
			PLAY_SFX("paper_turnpage")
			return true
		end
	end

	-- 4. Get active hotspots for ONLY the top-most document
	local hotspots = GET_ACTIVE_HOTSPOTS()
	local top_hotspots = {}
	for _, hs in ipairs(hotspots) do
		if hs.doc == top_key then
			table.insert(top_hotspots, hs)
		end
	end

	local best_hs = nil
	local best_dist = 999999

	-- Phase 1: Exact hit strictly inside hotspot bounds
	for _, hs in ipairs(top_hotspots) do
		if tx >= hs.x and tx <= hs.x + hs.w and ty >= hs.y and ty <= hs.y + hs.h then
			best_hs = hs
			best_dist = 0
			break
		end
	end

	-- Phase 2: Closest hit within tolerance margin (pad_x = 4, pad_y = 2)
	if not best_hs then
		local pad_x = 4
		local pad_y = 2
		for _, hs in ipairs(top_hotspots) do
			if tx >= hs.x - pad_x and tx <= hs.x + hs.w + pad_x and ty >= hs.y - pad_y and ty <= hs.y + hs.h + pad_y then
				local cx = hs.x + hs.w / 2
				local cy = hs.y + hs.h / 2
				local dist = (tx - cx) * (tx - cx) + (ty - cy) * (ty - cy)
				if dist < best_dist then
					best_dist = dist
					best_hs = hs
				end
			end
		end
	end

	if best_hs then
		local hs = best_hs
		-- Check if already selected -> deselect
		for j, sel in ipairs(INSPECTION.selected) do
			if sel.id == hs.id then
				table.remove(INSPECTION.selected, j)
				PLAY_SFX("inspect_unhighlight")
				INSPECTION.match_found = false
				INSPECTION.match_reason = nil
				return true
			end
		end
		-- If 2 already selected, remove oldest (FIFO queue of 2)
		if #INSPECTION.selected >= 2 then
			table.remove(INSPECTION.selected, 1)
			INSPECTION.match_found = false
			INSPECTION.match_reason = nil
		end
		-- Add new selection
		table.insert(INSPECTION.selected, hs)
		PLAY_SFX("inspect_highlight")

		-- If 2 selected, run discrepancy check
		if #INSPECTION.selected == 2 then
			if CHECK_DISCREPANCY then
				CHECK_DISCREPANCY(INSPECTION.selected[1], INSPECTION.selected[2])
			end
		end
		return true
	end

	-- 5. Blank area of top document was tapped -> Absorb touch (prevent click-through)
	return true
end

--------------------------------------------------------------------------------
-- INSPECTION MODE: DISCREPANCY CHECK ENGINE
--------------------------------------------------------------------------------

local function PARSE_DATE_NUM(str)
	if not str or type(str) ~= "string" or #str < 10 then return nil end
	local d = tonumber(string.sub(str, 1, 2))
	local m = tonumber(string.sub(str, 4, 5))
	local y = tonumber(string.sub(str, 7, 10))
	if d and m and y then
		return y * 10000 + m * 100 + d
	end
	return nil
end

function CHECK_DISCREPANCY(h1, h2)
	if not h1 or not h2 or not PERSON then return false end
	if h1.id == h2.id then return false end

	local c1, c2 = h1.cat, h2.cat
	if c1 > c2 then
		c1, c2 = c2, c1
		h1, h2 = h2, h1
	end

	local match = false
	local wrong_id = nil
	local special_key = nil

	local day_cfg = IS_STORY_MODE and GET_DAY_CONFIG(CURRENT_DAY)

	-- 1. Expired date vs Today's date
	if c1 == "EXP_DATE" and c2 == "TODAY_DATE" then
		local cur_d, cur_m, cur_y = GET_CURRENT_GAME_DATE()
		local today_num = cur_y * 10000 + cur_m * 100 + cur_d
		local exp_str = nil
		local is_permit = false

		if h1.doc == "PASSPORT" or h2.doc == "PASSPORT" then
			exp_str = PERSON.passEXP
		elseif h1.doc == "ENTRYPERMIT" or h2.doc == "ENTRYPERMIT" then
			exp_str = PERSON.permitenterby
			is_permit = true
		elseif h1.doc == "WORKPASS" or h2.doc == "WORKPASS" then
			exp_str = PERSON.WORKPASSuntil
		elseif h1.doc == "ENTRYTICKET" or h2.doc == "ENTRYTICKET" then
			exp_str = PERSON.ticketEXP
		end

		local exp_num = PARSE_DATE_NUM(exp_str)
		if exp_num and exp_num < today_num then
			match = true
			wrong_id = is_permit and 15 or 14
		end

	-- 2. Name mismatch across documents
	elseif c1 == "NAME" and c2 == "NAME" and h1.doc ~= h2.doc then
		local function get_doc_name(doc)
			if doc == "PASSPORT" then return PERSON.name
			elseif doc == "ENTRYPERMIT" then return PERSON.permitname
			elseif doc == "IDCARD" then
				return tostring((PERSON.idcardfirstname or "") .. " " .. (PERSON.idcardlastname or ""))
			elseif doc == "WORKPASS" then return PERSON.WORKPASSholder
			end
			return nil
		end
		local n1 = get_doc_name(h1.doc)
		local n2 = get_doc_name(h2.doc)
		if n1 and n2 and n1 ~= n2 then
			match = true
			wrong_id = 7
		end

	-- 3. ID Number mismatch across documents
	elseif c1 == "ID_NUM" and c2 == "ID_NUM" and h1.doc ~= h2.doc then
		local function get_doc_id(doc)
			if doc == "PASSPORT" then return tostring(PERSON.ID or "")
			elseif doc == "ENTRYPERMIT" then return tostring(PERSON.permitid or "")
			end
			return nil
		end
		local id1 = get_doc_id(h1.doc)
		local id2 = get_doc_id(h2.doc)
		if id1 and id2 and id1 ~= id2 then
			match = true
			wrong_id = 9
		end

	-- 4. DOB mismatch across documents (Passport vs ID Card)
	elseif c1 == "DOB" and c2 == "DOB" and h1.doc ~= h2.doc then
		if PERSON.DOB and PERSON.idcardDOB and PERSON.DOB ~= PERSON.idcardDOB then
			match = true
			wrong_id = 4
		end

	-- 5. Non-matching Photo (Entrant Face vs Passport/ID Photo)
	elseif (c1 == "FACE" and c2 == "PHOTO") or (c1 == "PHOTO" and c2 == "FACE") then
		if PERSON.face and PERSON.realface and PERSON.face ~= PERSON.realface then
			match = true
			wrong_id = 12
		end

	-- 6. Sex / Gender mismatch (Entrant Face appearance vs Document Gender)
	elseif (c1 == "FACE" and c2 == "GENDER") or (c1 == "GENDER" and c2 == "FACE") then
		local real_face = PERSON.realface or PERSON.face or 1
		local appearance_gender = ((real_face >= 1 and real_face <= 4) or (real_face >= 29 and real_face <= 44)) and "F" or "M"
		if PERSON.GNDR and PERSON.GNDR ~= appearance_gender then
			match = true
			wrong_id = 8
		end

	-- 7. Height mismatch (Entrant vs ID Card)
	elseif (c1 == "FACE" and c2 == "HEIGHT") or (c1 == "HEIGHT" and c2 == "FACE") or (c1 == "HEIGHT" and c2 == "HEIGHT" and h1.id ~= h2.id) then
		if PERSON.idcardheight and PERSON.height and PERSON.idcardheight ~= PERSON.height then
			match = true
			wrong_id = 10
		end

	-- 8. Weight mismatch (Entrant vs ID Card)
	elseif (c1 == "FACE" and c2 == "WEIGHT") or (c1 == "WEIGHT" and c2 == "FACE") or (c1 == "WEIGHT" and c2 == "WEIGHT" and h1.id ~= h2.id) then
		if PERSON.idcardweight and PERSON.weight and PERSON.idcardweight ~= PERSON.weight then
			match = true
			wrong_id = 11
		end

	-- 9. Invalid Issuing City (City on Passport vs Nation/City)
	elseif (c1 == "CITY" and (c2 == "NATION" or c2 == "CITY")) or (c2 == "CITY" and (c1 == "NATION" or c1 == "CITY" and h1.id ~= h2.id)) then
		local valid_cities = FORDOCUMENT and PERSON.passport and FORDOCUMENT[PERSON.passport]
		local is_fake = true
		if valid_cities then
			for _, vc in ipairs(valid_cities) do
				if vc == PERSON.COL then
					is_fake = false
					break
				end
			end
		end
		if is_fake then
			match = true
			wrong_id = 5
		end

	-- 10. Forged / Invalid District (ID Card district vs Nation/District)
	elseif c1 == "DISTRICT" or c2 == "DISTRICT" then
		local is_valid = false
		if DISTRICTS and PERSON.idcarddistrict then
			for _, dist in ipairs(DISTRICTS) do
				if dist == PERSON.idcarddistrict then
					is_valid = true
					break
				end
			end
		end
		if not is_valid then
			match = true
			wrong_id = 6
		end

	-- 11. Forged MOA Seal (Entry Permit vs Rulebook Page 8 or Rule)
	elseif (c1 == "SEAL_MOA" and c2 == "SEAL_MOA" and h1.id ~= h2.id) or (c1 == "RULE_SEAL" and c2 == "SEAL_MOA") or (c1 == "SEAL_MOA" and c2 == "RULE_SEAL") then
		if PERSON.permitMOA and PERSON.permitMOA > 2 then
			match = true
			wrong_id = 17
		end

	-- 12. Forged MOL Seal (Work Pass vs Rulebook Page 8 or Rule)
	elseif (c1 == "SEAL_MOL" and c2 == "SEAL_MOL" and h1.id ~= h2.id) or (c1 == "RULE_SEAL" and c2 == "SEAL_MOL") or (c1 == "SEAL_MOL" and c2 == "RULE_SEAL") then
		if PERSON.WORKPASSMOL and PERSON.WORKPASSMOL > 4 then
			match = true
			wrong_id = 16
		end

	-- 12b. Foreigner Restriction (Passport Nation vs Rulebook Day 1 Rule)
	elseif (c1 == "NATION" and c2 == "RULE_FOREIGNERS") or (c2 == "NATION" and c1 == "RULE_FOREIGNERS") then
		if day_cfg and not day_cfg.allow_foreigners and PERSON and PERSON.passport ~= 2 then
			match = true
			special_key = "foreigners"
		end

	-- 13. Duration Mismatch (Entry Permit duration vs Stated duration in transcript)
	elseif c1 == "DURATION" or c2 == "DURATION" then
		if PERSON.transcript_mismatch then
			match = true
			wrong_id = 18
		end

	-- 14. Diplomatic Sanctions / Embargo Violation
	elseif (c1 == "NATION" or c2 == "NATION") and day_cfg and day_cfg.embargo_nation then
		if GET_NATION_NAME(PERSON.passport) == day_cfg.embargo_nation then
			match = true
			special_key = "embargo"
		end

	-- 15. Wanted Fugitive match
	elseif (c1 == "NAME" or c2 == "NAME" or c1 == "PHOTO" or c2 == "PHOTO" or c1 == "FACE" or c2 == "FACE") and day_cfg and day_cfg.wanted_name then
		if PERSON.is_wanted or PERSON.name == day_cfg.wanted_name then
			match = true
			special_key = "wanted"
		end

	-- 16. Foreigners not allowed (Story Mode Day 1)
	elseif (c1 == "NATION" or c2 == "NATION") and day_cfg and not day_cfg.allow_foreigners then
		if PERSON.passport ~= 2 then
			match = true
			special_key = "foreigners"
		end

	-- 17. Fingerprint Slip vs Identity Record: Biometric comparison
	elseif c1 == "BIOMETRIC" and c2 == "BIOMETRIC" and h1.id ~= h2.id then
		local prints_match = true
		if PERSON.record_fingerprints and PERSON.fingerprints then
			for i = 1, 5 do
				if PERSON.record_fingerprints[i] ~= PERSON.fingerprints[i] then
					prints_match = false
					break
				end
			end
		elseif PERSON.fingerprint_id and PERSON.record_fingerprint_id and PERSON.fingerprint_id ~= PERSON.record_fingerprint_id then
			prints_match = false
		end

		if prints_match then
			match = true
			if PERSON.has_alias then
				PERSON.name_cleared = true
				special_key = "alias_cleared"
			elseif PERSON.photo_verified then
				PERSON.photo_cleared = true
				special_key = "photo_cleared"
			else
				special_key = "biometric_cleared"
			end
		else
			match = true
			wrong_id = 12
			special_key = "biometric_mismatch"
		end

	-- 18. Fingerprint Slip / Identity Record: Name / Alias cross-referencing
	elseif (c1 == "NAME" and c2 == "SLIP_RESULT") or (c1 == "BIOMETRIC" and c2 == "NAME") then
		if PERSON.has_alias and PERSON.alias then
			match = true
			PERSON.name_cleared = true
			special_key = "alias_cleared"
		elseif (PERSON.record_fingerprint_id and PERSON.fingerprint_id and PERSON.record_fingerprint_id ~= PERSON.fingerprint_id) or (not PERSON.has_alias and WRONGCONST == WRONGTABLE[7]) then
			match = true
			wrong_id = 7
			special_key = "biometric_mismatch"
		elseif PERSON.is_wanted then
			match = true
			special_key = "wanted"
		end

	-- 19. Fingerprint Slip: Photo / Appearance cross-referencing
	elseif ((c1 == "PHOTO" or c1 == "FACE") and c2 == "SLIP_RESULT") or (c1 == "BIOMETRIC" and (c2 == "PHOTO" or c2 == "FACE")) then
		if PERSON.photo_verified then
			match = true
			PERSON.photo_cleared = true
			special_key = "photo_cleared"
		elseif PERSON.record_fingerprint_id and PERSON.fingerprint_id and PERSON.record_fingerprint_id ~= PERSON.fingerprint_id then
			match = true
			wrong_id = 12
			special_key = "biometric_mismatch"
		elseif PERSON.is_wanted then
			match = true
			special_key = "wanted"
		end
	end

	-- Result processing
	if match then
		INSPECTION.match_found = true
		INSPECTION.match_reason = special_key or wrong_id
		INSPECTION.interrogated = false
		INSPECTION.can_detain = false
		INSPECTION.flash_timer = 20
		PLAY_SFX("inspect_interrogateon")

		if special_key == "alias_cleared" or special_key == "photo_cleared" or special_key == "biometric_cleared" then
			INSPECTION.interrogated = true
			INSPECTION.can_detain = false
			INSPECTION.is_grave = false
			PLAY_SFX("inspect_highlight")
		elseif wrong_id == 5 or wrong_id == 6 or wrong_id == 12 or wrong_id == 16 or wrong_id == 17 or special_key == "embargo" or special_key == "wanted" or special_key == "biometric_mismatch" then
			INSPECTION.is_grave = true
			if special_key == "biometric_mismatch" or special_key == "wanted" then
				INSPECTION.can_detain = true
				INSPECTION.interrogated = true
			end
		else
			INSPECTION.is_grave = false
		end
		return true
	else
		-- Negative match (no discrepancy between the two items)
		INSPECTION.match_found = false
		INSPECTION.match_reason = nil
		INSPECTION.is_grave = false
		INSPECTION.flash_timer = 15
		PLAY_SFX("inspect_unhighlight")
		INSPECTION.selected = {}
		return false
	end
end

--------------------------------------------------------------------------------
-- INSPECTION MODE: INTERROGATION & DETAIN MECHANICS
--------------------------------------------------------------------------------

function START_INTERROGATION()
	if not INSPECTION.match_found or INSPECTION.interrogated or INSPECTION.interrogating then
		return false
	end

	local reason = INSPECTION.match_reason
	local accusation = nil
	if INSPECTOR_ACCUSATIONS then
		accusation = INSPECTOR_ACCUSATIONS[reason] or INSPECTOR_ACCUSATIONS.default
	end
	if not accusation then
		accusation = "There is a discrepancy in your documents."
	end

	local pool = nil
	if ENTRANT_RESPONSES then
		pool = ENTRANT_RESPONSES[reason] or ENTRANT_RESPONSES.default
	end
	if not pool or #pool == 0 then
		pool = { "I do not understand.", "There must be some mistake." }
	end
	local response = pool[math.random(1, #pool)]

	table.insert(CHAT, accusation)
	table.insert(CHATplace, 1)
	local idx = #CHAT
	CHATtime[idx] = Timer.getTime(CBtime)
	CHATy[idx] = 103
	local text_w = GPU_MeasureText(accusation, 7)
	local bw = math.max(80, text_w + 6)
	CHATw[idx] = bw
	CHATx[idx] = 112
	CHATframe[idx] = 0
	PLAY_SFX("speech_inspector")

	INSPECTION.interrogating = true
	INSPECTION.interrogation_queue = {
		response = response,
		delay = 60 -- 1 second at 60 fps
	}
	return true
end

function UPDATE_INSPECTION()
	if INSPECTION.flash_timer and INSPECTION.flash_timer > 0 then
		INSPECTION.flash_timer = INSPECTION.flash_timer - 1
	end
	if INSPECTION.line_timer then
		INSPECTION.line_timer = (INSPECTION.line_timer + 1) % 60
	end

	if INSPECTION.interrogation_queue then
		INSPECTION.interrogation_queue.delay = INSPECTION.interrogation_queue.delay - 1
		if INSPECTION.interrogation_queue.delay <= 0 then
			local resp = INSPECTION.interrogation_queue.response
			table.insert(CHAT, resp)
			table.insert(CHATplace, 2)
			local idx = #CHAT
			CHATtime[idx] = Timer.getTime(CBtime)
			CHATy[idx] = 115
			local text_w = GPU_MeasureText(resp, 7)
			local bw = math.max(80, text_w + 6)
			CHATw[idx] = bw
			CHATx[idx] = 290 - bw
			CHATframe[idx] = 0
			PLAY_SFX("speech_entrant")

			INSPECTION.interrogation_queue = nil
			INSPECTION.interrogating = false
			INSPECTION.interrogated = true
			if INSPECTION.is_grave then
				INSPECTION.can_detain = true
			end
			local r = INSPECTION.match_reason
			if (r == 7 or r == 12 or r == "wanted" or r == "biometric_mismatch") and SCANNER and not SCANNER.scanned then
				if not IS_STORY_MODE or (CURRENT_DAY and CURRENT_DAY >= 5) then
					SCANNER.active = true
				end
			end
		end
	end
end

function EXECUTE_DETAIN()
	local day_cfg = IS_STORY_MODE and GET_DAY_CONFIG(CURRENT_DAY)
	local has_embargo_violation = (day_cfg and day_cfg.embargo_nation and GET_NATION_NAME(PERSON.passport) == day_cfg.embargo_nation)
	local has_wanted_violation = (day_cfg and day_cfg.wanted_name and (PERSON.is_wanted or PERSON.name == day_cfg.wanted_name))
	local is_biometric_fraud = (PERSON and PERSON.record_fingerprint_id and PERSON.fingerprint_id and PERSON.record_fingerprint_id ~= PERSON.fingerprint_id) or (
		PERSON and PERSON.record_fingerprints and PERSON.fingerprints and (
			PERSON.record_fingerprints[1] ~= PERSON.fingerprints[1] or
			PERSON.record_fingerprints[2] ~= PERSON.fingerprints[2] or
			PERSON.record_fingerprints[3] ~= PERSON.fingerprints[3] or
			PERSON.record_fingerprints[4] ~= PERSON.fingerprints[4] or
			PERSON.record_fingerprints[5] ~= PERSON.fingerprints[5]
		)
	)
	local is_valid_detain = INSPECTION.is_grave and (
		(WRONGCONST ~= "Nothing" and (WRONGCONST == WRONGTABLE[5] or WRONGCONST == WRONGTABLE[6] or WRONGCONST == WRONGTABLE[7] or WRONGCONST == WRONGTABLE[12] or WRONGCONST == WRONGTABLE[16] or WRONGCONST == WRONGTABLE[17]))
		or has_embargo_violation
		or has_wanted_violation
		or is_biometric_fraud
	)

	if not INSPECTION.can_detain or not INSPECTION.interrogated or not is_valid_detain then
		-- Unlawful detention penalty
		WRONGMANn = (WRONGMANn or 0) + 1
		if IS_STORY_MODE then
			DAY_MISTAKES_COUNT = (DAY_MISTAKES_COUNT or 0) + 1
			DAY_INSPECTED_COUNT = (DAY_INSPECTED_COUNT or 0) + 1
		end
		local mistake_count = IS_STORY_MODE and DAY_MISTAKES_COUNT or WRONGMANn
		local max_warnings = (CURRENT_DAY and CURRENT_DAY >= 3) and 1 or 2
		if day_cfg and day_cfg.allowed_warnings ~= nil then
			max_warnings = day_cfg.allowed_warnings
		end

		local penalty_text = "WARNING - NO PENALTY"
		local penalty_pts = 0
		local penalty_time = 0
		if IS_STORY_MODE then
			if mistake_count == max_warnings + 1 then
				penalty_text = "PENALTY: 5 CREDITS"
				penalty_pts = 5
			elseif mistake_count > max_warnings + 1 then
				penalty_text = "PENALTY: 10 CREDITS"
				penalty_pts = 10
			end
		elseif MODEselect == 1 then
			-- Timed mode: -20 seconds from 3rd error onward
			if mistake_count <= 2 then
				penalty_text = "WARNING - NO PENALTY"
				penalty_time = 0
			else
				penalty_text = "PENALTY: -20 SECONDS"
				penalty_time = 20000
			end
		elseif MODEselect == 2 then
			-- Perfection mode: any unlawful detention is fatal
			penalty_text = "FATAL INFRACTION - DISMISSED"
			penalty_pts = 0
		elseif MODEselect == 3 then
			-- Endurance mode: 2 free warnings then credit deductions
			if mistake_count <= 2 then
				penalty_text = "WARNING - NO PENALTY"
				penalty_pts = 0
			elseif mistake_count == 3 then
				penalty_text = "PENALTY: -5 CREDITS"
				penalty_pts = 5
			else
				penalty_text = "PENALTY: -10 CREDITS"
				penalty_pts = 10
			end
		end

		SPAWN_CITATION("UNLAWFUL DETENTION", penalty_text, MODEselect, penalty_pts, penalty_time)
		if MODEselect == 2 then
			PERFECT_GAMEOVER_ACTIVE = true
			PERFECT_GAMEOVER_READY = false
			if PERFECT_TIMER == nil then PERFECT_TIMER = Timer.new() end
			Timer.reset(PERFECT_TIMER)
			Timer.pause(PERFECT_TIMER)
		end
	else
		-- Lawful detention reward
		table.insert(PENDING_REWARDS, {
			delay = 600,
			points = IS_STORY_MODE and 5 or plusPOINTS,
			is_story = IS_STORY_MODE
		})
		if IS_STORY_MODE then
			DAY_INSPECTED_COUNT = (DAY_INSPECTED_COUNT or 0) + 1
		end
	end

	-- Authentic detain sequence
	INSPECTION.detained = true
	table.insert(CHAT, "Detain this person.")
	table.insert(CHATplace, 1)
	local idx = #CHAT
	CHATtime[idx] = Timer.getTime(CBtime)
	CHATy[idx] = 103
	local text_w = GPU_MeasureText("Detain this person.", 7)
	local bw = math.max(80, text_w + 6)
	CHATw[idx] = bw
	CHATx[idx] = 112
	CHATframe[idx] = 0
	PLAY_SFX("speech_inspector")
	PLAY_SFX("border_callguards")

	-- Confiscate / clear all traveler documents from desk
	local i = 1
	while i <= #DESKTOP do
		local k = DESKTOP[i]
		if TRAVELER_DOCS[k] then
			local d = ITEM_BY_KEY and ITEM_BY_KEY[k]
			if d then
				d.now = 1
				d.y = -200
				d.velocity = 0
				d.gravity = 0
			end
			table.remove(DESKTOP, i)
		else
			i = i + 1
		end
	end

	stamp = "DETAIN"
	CheckPoint = 2

	-- Reset inspection mode
	RESET_INSPECTION()
end

--------------------------------------------------------------------------------
-- INSPECTION MODE: VISUAL RENDERING PIPELINE
--------------------------------------------------------------------------------

local INSPECT_AMBER_BORDER = Color.new(255, 200, 60, 220)
local INSPECT_AMBER_FILL   = Color.new(255, 200, 60, 45)
local INSPECT_RED_BORDER   = Color.new(220, 50, 50, 240)
local INSPECT_RED_FILL     = Color.new(220, 50, 50, 60)
local INSPECT_DIM_DESK     = Color.new(0, 0, 0, 45)
local INSPECT_ANCHOR_BG    = Color.new(35, 40, 35, 230)
local INSPECT_ANCHOR_BD    = Color.new(110, 130, 110, 220)
local INSPECT_ANCHOR_TXT   = Color.new(170, 190, 170)
local INSPECT_BTN_BG       = Color.new(25, 28, 25, 240)
local INSPECT_BTN_BORDER   = Color.new(220, 220, 210, 240)
local INSPECT_DETAIN_BG    = Color.new(150, 25, 25, 240)
local INSPECT_DETAIN_BD    = Color.new(240, 90, 90, 250)

local function DRAW_HOTSPOT_HIGHLIGHT(sel)
	local fill_col = INSPECTION.match_found and INSPECT_RED_FILL or INSPECT_AMBER_FILL
	local border_col = INSPECTION.match_found and INSPECT_RED_BORDER or INSPECT_AMBER_BORDER
	local doc = sel.doc and ITEM_BY_KEY and ITEM_BY_KEY[sel.doc]
	local sx = (doc and sel.xo) and (doc.x + sel.xo) or sel.x
	local sy = (doc and sel.yo) and (doc.y + sel.yo) or sel.y
	-- Semitransparent highlight fill inside hotspot
	Graphics.fillRect(sx, sx + sel.w, sy, sy + sel.h, fill_col)

	-- Pixel-perfect authentic 4-corner brackets framing the hotspot
	local corner_col = INSPECTION.match_found and Color.new(225, 45, 45, 255) or Color.new(38, 30, 26, 255)
	local pad = 1
	local thick = 2
	local arm = math.min(6, math.max(4, math.floor(sel.h / 2)))
	local x0 = sx - pad
	local y0 = sy - pad
	local x1 = sx + sel.w + pad
	local y1 = sy + sel.h + pad

	-- Top-Left Corner Bracket
	Graphics.fillRect(x0, x0 + arm, y0, y0 + thick, corner_col)
	Graphics.fillRect(x0, x0 + thick, y0 + thick, y0 + arm, corner_col)

	-- Top-Right Corner Bracket
	Graphics.fillRect(x1 - arm, x1, y0, y0 + thick, corner_col)
	Graphics.fillRect(x1 - thick, x1, y0 + thick, y0 + arm, corner_col)

	-- Bottom-Left Corner Bracket
	Graphics.fillRect(x0, x0 + arm, y1 - thick, y1, corner_col)
	Graphics.fillRect(x0, x0 + thick, y1 - arm, y1 - thick, corner_col)

	-- Bottom-Right Corner Bracket
	Graphics.fillRect(x1 - arm, x1, y1 - thick, y1, corner_col)
	Graphics.fillRect(x1 - thick, x1, y1 - arm, y1 - thick, corner_col)
end

function DRAW_DOC_INSPECTION_HIGHLIGHT(doc_key)
	if not INSPECTION or not INSPECTION.active then return end
	if not INSPECTION.selected then return end
	for _, sel in ipairs(INSPECTION.selected) do
		if sel.doc == doc_key then
			DRAW_HOTSPOT_HIGHLIGHT(sel)
		end
	end
end

function DRAW_INSPECTION_OVERLAY()
	-- 1. Inspection Toggle Button (bottom-right: x = 288, y = 216, w = 32, h = 24)
	if INSPECTION.active then
		if INSPECT_BTN_CLOSE then
			Graphics.drawImage(288, 216, INSPECT_BTN_CLOSE)
		else
			Graphics.fillRect(286, 310, 206, 230, Color.new(45, 38, 20, 220))
			Graphics.fillEmptyRect(286, 310, 206, 230, INSPECT_AMBER_BORDER)
		end
	else
		if INSPECT_BTN_OPEN then
			Graphics.drawImage(288, 216, INSPECT_BTN_OPEN)
		else
			Graphics.fillRect(286, 310, 206, 230, Color.new(20, 20, 20, 160))
			Graphics.fillEmptyRect(286, 310, 206, 230, Color.new(100, 100, 95, 180))
		end
		-- If inspection is inactive, do not draw active overlay elements
		return
	end

-- 2. Desk dimming moved to desk render pass

	-- 3. Top-screen data anchors on upper counter shelf
	if INSPECTION_ANCHORS then
		for _, a in ipairs(INSPECTION_ANCHORS) do
			Graphics.fillRect(a.x, a.x + a.w, a.y, a.y + a.h, INSPECT_ANCHOR_BG)
			Graphics.fillEmptyRect(a.x, a.x + a.w, a.y, a.y + a.h, INSPECT_ANCHOR_BD)
			GPU_DrawText(math.floor(a.x + a.w / 2), a.y + 4, a.label or "ANCHOR", INSPECT_ANCHOR_TXT, "c", 320, SMALL_FONT, 7)
		end
	end

	-- 4. Connecting Line between selected points
	if #INSPECTION.selected == 2 then
		local s1 = INSPECTION.selected[1]
		local s2 = INSPECTION.selected[2]
		local d1 = s1.doc and ITEM_BY_KEY and ITEM_BY_KEY[s1.doc]
		local d2 = s2.doc and ITEM_BY_KEY and ITEM_BY_KEY[s2.doc]
		local sx1 = (d1 and s1.xo) and (d1.x + s1.xo) or s1.x
		local sy1 = (d1 and s1.yo) and (d1.y + s1.yo) or s1.y
		local sx2 = (d2 and s2.xo) and (d2.x + s2.xo) or s2.x
		local sy2 = (d2 and s2.yo) and (d2.y + s2.yo) or s2.y
		local cx1 = math.floor(sx1 + s1.w / 2)
		local cy1 = math.floor(sy1 + s1.h / 2)
		local cx2 = math.floor(sx2 + s2.w / 2)
		local cy2 = math.floor(sy2 + s2.h / 2)

		local line_col = INSPECTION.match_found and INSPECT_RED_BORDER or INSPECT_AMBER_BORDER
		local dx = cx2 - cx1
		local dy = cy2 - cy1
		local dist = math.sqrt(dx * dx + dy * dy)
		local steps = math.floor(dist / 5)
		if steps > 0 then
			for s = 0, steps do
				local phase = (s + math.floor((INSPECTION.line_timer or 0) / 4)) % 2
				if phase == 0 or INSPECTION.match_found then
					local t = s / steps
					local px = math.floor(cx1 + dx * t)
					local py = math.floor(cy1 + dy * t)
					if INSPECT_LINE_TEX then
						Graphics.drawImage(px, py, INSPECT_LINE_TEX)
					else
						Graphics.fillRect(px, px + 2, py, py + 2, line_col)
					end
				end
			end
		end
	end

	-- 5. Anchor highlights (if an anchor was selected)
	if INSPECTION.selected then
		for _, sel in ipairs(INSPECTION.selected) do
			if sel.doc == "ANCHOR" or not sel.doc then
				DRAW_HOTSPOT_HIGHLIGHT(sel)
			end
		end
	end

	-- 6. Negative Match Flash Animation
	if INSPECTION.flash_timer and INSPECTION.flash_timer > 0 and not INSPECTION.match_found then
		local flash_alpha = math.min(100, INSPECTION.flash_timer * 7)
		Graphics.fillRect(0, 320, 67, 240, Color.new(220, 40, 40, flash_alpha))
	end

	-- 7. Action Buttons (INTERROGATE and DETAIN)
	-- INTERROGATE button
	if INSPECTION.match_found and not INSPECTION.interrogated and not INSPECTION.interrogating then
		Graphics.fillRect(95, 192, 175, 205, INSPECT_BTN_BG)
		Graphics.fillEmptyRect(95, 192, 175, 205, INSPECT_BTN_BORDER)
		Graphics.fillEmptyRect(97, 190, 177, 203, INSPECT_BTN_BORDER)
		GPU_DrawText(143, 186, "INTERROGATE (X)", Color.new(240, 240, 230), "c", 320, SMALL_FONT, 7)
	end

	-- DETAIN button (authentic 3-state sprite: 71x30 per slice)
	-- State 0 (sy=0): Active / Ready (Red light)
	-- State 1 (sy=30): Inactive / Locked (Grey light)
	-- State 2 (sy=60): Pressed / Activated (Bright glowing amber light)
	if INSPECTION.can_detain and DETAIN_BTN_TEX then
		local sy = 0 -- State 0: Active / Ready
		if INSPECTION.detained or TOUCH == "DETAIN_BTN" then
			sy = 60 -- State 2: Pressed / Activated
		end
		Graphics.drawPartialImage(247, 0, 0, sy, 71, 30, DETAIN_BTN_TEX)
	end
end

function LOAD_IMAGE(word,key)
	-- [PERF] Conservative off-screen cull: skip draw entirely if the document
	-- is fully outside the 320x240 touch screen. Max document size is 238x162
	-- (Rulebook open), so we use that as the worst-case bounding box.
	-- This only fires when the doc is COMPLETELY off-screen (no false positives).
	if word.now == 0 then
		if word.y > 240 or word.y + 162 < 0 or word.x > 320 or word.x + 238 < 0 then
			return
		end
	end
	if word.is_cit then
		if word.status == "DELAY" then
			return
		end
		if word.now == 1 then
			local rot = word.rot or 0.15
			local w2 = (word.tex2 and Graphics.getImageWidth(word.tex2)) or 68
			local h2 = (word.tex2 and Graphics.getImageHeight(word.tex2)) or 27
			local cx = math.floor(word.x + w2 / 2)
			local cy = math.floor(word.y + h2 / 2)
			if Options["Shadow"] == 1 then
				Graphics.drawRotateImage(cx + 2, cy + 2, word.tex2, rot, SHADOW)
			end
			Graphics.drawRotateImage(cx, cy, word.tex2, rot)
		elseif word.now == 0 then
			if TOUCH == key and Options["Shadow"] == 1 then
				Graphics.drawImage(math.floor(word.x + 3), math.floor(word.y + 3), word.tex, SHADOW)
			end
			Graphics.drawImage(math.floor(word.x), math.floor(word.y), word.tex)
			LOAD_TEXT(key)
		end
	elseif word.is_fingerprint_slip or key == "FINGERPRINTSLIP" then
		if word.now == 1 then
			local rot = word.rot or -0.10
			local w2 = (word.tex2 and Graphics.getImageWidth(word.tex2)) or 87
			local h2 = (word.tex2 and Graphics.getImageHeight(word.tex2)) or 30
			local cx = math.floor(word.x + w2 / 2)
			local cy = math.floor(word.y + h2 / 2)
			if Options["Shadow"] == 1 then
				Graphics.drawRotateImage(cx + 2, cy + 2, word.tex2, rot, SHADOW)
			end
			Graphics.drawRotateImage(cx, cy, word.tex2, rot)
		elseif word.now == 0 then
			if TOUCH == key and Options["Shadow"] == 1 then
				Graphics.drawImage(math.floor(word.x + 3), math.floor(word.y + 3), word.tex, SHADOW)
			end
			Graphics.drawImage(math.floor(word.x), math.floor(word.y), word.tex)
			if FINGERPRINTSHEET and PERSON and PERSON.fingerprints then
				for i = 1, 5 do
					local fp = PERSON.fingerprints[i] or 0
					local col = fp % 3
					local row = math.floor(fp / 3)
					Graphics.drawPartialImage(math.floor(word.x + 4 + (i - 1) * 32), math.floor(word.y + 13), col * 32, row * 32, 32, 32, FINGERPRINTSHEET)
				end
			end
		end
	elseif word.is_identity_record or key == "IDENTITYRECORD" then
		if word.now == 1 then
			local rot = word.rot or 0.10
			local w2 = (word.tex2 and Graphics.getImageWidth(word.tex2)) or 93
			local h2 = (word.tex2 and Graphics.getImageHeight(word.tex2)) or 44
			local cx = math.floor(word.x + w2 / 2)
			local cy = math.floor(word.y + h2 / 2)
			if Options["Shadow"] == 1 then
				Graphics.drawRotateImage(cx + 2, cy + 2, word.tex2, rot, SHADOW)
			end
			Graphics.drawRotateImage(cx, cy, word.tex2, rot)
		elseif word.now == 0 then
			if TOUCH == key and Options["Shadow"] == 1 then
				Graphics.drawImage(math.floor(word.x + 3), math.floor(word.y + 3), word.tex, SHADOW)
			end
			Graphics.drawImage(math.floor(word.x), math.floor(word.y), word.tex)
			if FINGERPRINTSHEET and PERSON and PERSON.record_fingerprints then
				for i = 1, 5 do
					local fp = PERSON.record_fingerprints[i] or 0
					local col = fp % 3
					local row = math.floor(fp / 3)
					Graphics.drawPartialImage(math.floor(word.x + 11 + (i - 1) * 32), math.floor(word.y + 38), col * 32, row * 32, 32, 32, FINGERPRINTSHEET)
				end
			end
			LOAD_TEXT(key)
		end
	elseif key=="PASSPORT" then 
		if word.now==1 then
			if Options["Shadow"]==1 then
				Graphics.drawRotateImage(word.x+16, word.y+23, PASSPORT.tex2,PASSPORT.rot,SHADOW)
			end
			Graphics.drawImageExtended(word.x+15, word.y+20, 30*(PERSON.passport - (4*(math.ceil((PERSON.passport-0.1)/4)-1)+1)), 40*(math.ceil((PERSON.passport-0.1)/4)-1), 30, 40, PASSPORT.rot, 1, 1, NOTPASSPORT_SHEET)
			if word.y<22 and TOUCH==key and stamp~=nil and SWITCHER==0 and TRAVELER_DOCS[key] then
				Graphics.drawImage(word.x-13, word.y+14, GIVE)
			end
			elseif word.now==0 then
			if TOUCH == key then
				if Options["Shadow"]==1 then
					Graphics.drawImage(word.x+5, word.y+5, PASSPORT.tex,SHADOW)
				end
			end
			Graphics.drawPartialImage(word.x,word.y,130*(PERSON.passport - (4*(math.ceil((PERSON.passport-0.1)/4)-1)+1)),162*(math.ceil((PERSON.passport-0.1)/4)-1),130,162, PASSPORT_SHEET)
			LOAD_TEXT(key,PERSON.face)
			
		end
		elseif key=="RULEBOOK" then
		if word.now==1 then
			if Options["Shadow"]==1 then
				Graphics.drawImage(word.x+1, word.y+3, word.tex2,SHADOW)
			end
			Graphics.drawImage(word.x, word.y, word.tex2)
			elseif word.now==0 then
			if TOUCH == key then
				if Options["Shadow"]==1 then
					Graphics.drawPartialImage(word.x+5,word.y+5,238*(RULEBOOK.state - (2*(math.ceil((RULEBOOK.state-0.1)/2)-1)+1)),158*(math.ceil((RULEBOOK.state-0.1)/2)-1),238,158, RULEBOOKSHEETS,SHADOW)
				end
			end
			Graphics.drawPartialImage(word.x,word.y,238*(RULEBOOK.state - (2*(math.ceil((RULEBOOK.state-0.1)/2)-1)+1)),158*(math.ceil((RULEBOOK.state-0.1)/2)-1),238,158, RULEBOOKSHEETS)
		end
		elseif key=="TRANSCRIPT" then
		if word.now==1 then
			if Options["Shadow"]==1 then
				Graphics.drawImage(word.x+1, word.y+3, word.tex2,SHADOW)
			end
			Graphics.drawImage(word.x, word.y, word.tex2)
			elseif word.now==0 then
			Graphics.drawImage(word.x, word.y, word.tex)
			LOAD_TEXT(key)
		end
		elseif key=="BULLETIN" then
			if word.now==1 then
				if Options["Shadow"]==1 then
					Graphics.drawImage(word.x+1, word.y+3, word.tex2, SHADOW)
				end
				Graphics.drawImage(word.x, word.y, word.tex2)
			elseif word.now==0 then
				if TOUCH == key then
					if Options["Shadow"]==1 then
						Graphics.drawImage(math.floor(word.x + 5), math.floor(word.y + 5), word.tex, SHADOW)
					end
				end
				Graphics.drawImage(math.floor(word.x), math.floor(word.y), word.tex)
				LOAD_TEXT(key)
			end
		else
		if word.now==0 then
			if TOUCH == key then
				if Options["Shadow"]==1 then
					Graphics.drawImage(word.x+5, word.y+5, word.tex,SHADOW)
				end
			end
			Graphics.drawImage(word.x, word.y, word.tex)
			LOAD_TEXT(key)
			
			elseif word.now==1 then
			if Options["Shadow"]==1 then
				Graphics.drawRotateImage(word.x+1+math.floor(Graphics.getImageWidth(word.tex2)/2), word.y+3+math.floor(Graphics.getImageHeight(word.tex2)/2), word.tex2, word.rot, SHADOW)
			end
			Graphics.drawRotateImage(word.x+math.floor(Graphics.getImageWidth(word.tex2)/2), word.y+math.floor(Graphics.getImageHeight(word.tex2)/2), word.tex2,word.rot)
			if word.y<22 and TOUCH==key and stamp~=nil and TRAVELER_DOCS[key] and SWITCHER==0 then
				Graphics.drawImage(word.x+math.floor(Graphics.getImageWidth(word.tex2)/2)-28, word.y+math.floor(Graphics.getImageHeight(word.tex2)/2)-6, GIVE)
			end
			
		end
	end
	if TRAVELER_DOCS[key] then
		if word.y<22 and stamp~=nil and SWITCHER==0 and word.now==1 and TOUCH~=key then
			for d_idx = 1, #DESKTOP do
				if DESKTOP[d_idx] == key then
					table.remove(DESKTOP, d_idx)
					break
				end
			end
			word.y = -200
		end
	end
end
DOC_TEXT_CACHE = {}
CHAT_U = {}
CHAT_W = {}

local function add_doc_field(tbl, x_off, y_off, text, color, align, font, size)
	if text == nil then return end
	local s = tostring(text)
	if size == 8 then s = string.upper(s) end
	local w = GPU_MeasureText(s, size)
	table.insert(tbl, {
		x_off = x_off,
		y_off = y_off,
		text = s,
		color = color,
		align = align,
		font = font,
		size = size,
		w = w
	})
end

function BUILD_DOC_TEXT_CACHE()
	DOC_TEXT_CACHE = {
		PASSPORT = { fields = {}, photo = nil },
		ENTRYTICKET = { fields = {} },
		ENTRYPERMIT = { fields_align1 = {}, fields_align0 = {} },
		IDCARD = { fields = {}, photo = nil },
		WORKPASS = { fields_align1 = {}, fields_align0 = {} }
	}

	-- 1. PASSPORT
	local p_fields = DOC_TEXT_CACHE.PASSPORT.fields
	local p_type = PERSON.passport
	local p_name = PERSON.name
	local p_dob = PERSON.DOB
	local p_gndr = PERSON.GNDR
	local p_col = PERSON.COL
	local p_exp = PERSON.passEXP
	local p_id = PERSON.ID

	if p_type == 1 then
		add_doc_field(p_fields, 8, 138, p_name, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 22, 101, p_dob, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 22, 110, p_gndr, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 22, 119, p_col, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 22, 128, p_exp, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 55, 148, p_id, BROWN, "l", SMALL_FONT, 7)
		DOC_TEXT_CACHE.PASSPORT.photo = { x_off = 83, y_off = 88 }
	elseif p_type == 2 then
		add_doc_field(p_fields, 8, 86, p_name, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 68, 98, p_dob, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 68, 106, p_gndr, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 68, 114, p_col, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 68, 122, p_exp, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 8, 148, p_id, BROWN, "l", SMALL_FONT, 7)
		DOC_TEXT_CACHE.PASSPORT.photo = { x_off = 8, y_off = 98 }
	elseif p_type == 3 then
		add_doc_field(p_fields, 8, 85, p_name, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 69, 96, p_dob, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 69, 104, p_gndr, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 69, 112, p_col, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 69, 120, p_exp, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 60, 144, p_id, BROWN, "l", SMALL_FONT, 7)
		DOC_TEXT_CACHE.PASSPORT.photo = { x_off = 9, y_off = 96 }
	elseif p_type == 4 then
		add_doc_field(p_fields, 8, 97, p_name, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 68, 107, p_dob, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 68, 115, p_gndr, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 68, 123, p_col, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 68, 131, p_exp, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 55, 148, p_id, BROWN, "l", SMALL_FONT, 7)
		DOC_TEXT_CACHE.PASSPORT.photo = { x_off = 8, y_off = 107 }
	elseif p_type == 5 then
		add_doc_field(p_fields, 8, 86, p_name, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 26, 98, p_dob, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 26, 106, p_gndr, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 26, 114, p_col, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 26, 122, p_exp, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 55, 148, p_id, BROWN, "l", SMALL_FONT, 7)
		DOC_TEXT_CACHE.PASSPORT.photo = { x_off = 85, y_off = 96 }
	elseif p_type == 6 then
		add_doc_field(p_fields, 8, 97, p_name, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 68, 107, p_dob, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 68, 115, p_gndr, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 68, 123, p_col, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 68, 131, p_exp, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 55, 147, p_id, BROWN, "l", SMALL_FONT, 7)
		DOC_TEXT_CACHE.PASSPORT.photo = { x_off = 8, y_off = 106 }
	elseif p_type == 8 then
		add_doc_field(p_fields, 8, 97, p_name, BROWN, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 25, 111, p_dob, DOCUMENTS_WHITE, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 25, 119, p_gndr, DOCUMENTS_WHITE, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 25, 127, p_col, DOCUMENTS_WHITE, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 25, 135, p_exp, DOCUMENTS_WHITE, "l", SMALL_FONT, 7)
		add_doc_field(p_fields, 10, 145, p_id, DOCUMENTS_WHITE, "l", SMALL_FONT, 7)
		DOC_TEXT_CACHE.PASSPORT.photo = { x_off = 84, y_off = 107 }
	end

	-- 2. ENTRYTICKET
	if PERSON.ticketEXP then
		add_doc_field(DOC_TEXT_CACHE.ENTRYTICKET.fields, 72, 30, PERSON.ticketEXP, ENTRYTICKET_BROWN, "l", NORMAL_FONT, 8)
	end

	-- 3. ENTRYPERMIT
	if PERSON.permitname then
		local ep1 = DOC_TEXT_CACHE.ENTRYPERMIT.fields_align1
		add_doc_field(ep1, 75, 89, PERSON.permitname, ENTRYTICKET_BROWN, "c", NORMAL_FONT, 8)
		add_doc_field(ep1, 75, 120, PERSON.permitid, ENTRYTICKET_BROWN, "c", NORMAL_FONT, 8)
		add_doc_field(ep1, 90, 137, PERSON.permitpurpose, ENTRYTICKET_BROWN, "c", NORMAL_FONT, 8)
		add_doc_field(ep1, 90, 153, PERSON.permitduration, ENTRYTICKET_BROWN, "c", NORMAL_FONT, 8)
		add_doc_field(ep1, 90, 169, PERSON.permitenterby, ENTRYTICKET_BROWN, "c", NORMAL_FONT, 8)

		local ep0 = DOC_TEXT_CACHE.ENTRYPERMIT.fields_align0
		add_doc_field(ep0, 25, 89, PERSON.permitname, ENTRYTICKET_BROWN, "l", NORMAL_FONT, 8)
		add_doc_field(ep0, 25, 120, PERSON.permitid, ENTRYTICKET_BROWN, "l", NORMAL_FONT, 8)
		add_doc_field(ep0, 60, 137, PERSON.permitpurpose, ENTRYTICKET_BROWN, "l", NORMAL_FONT, 8)
		add_doc_field(ep0, 60, 153, PERSON.permitduration, ENTRYTICKET_BROWN, "l", NORMAL_FONT, 8)
		add_doc_field(ep0, 60, 169, PERSON.permitenterby, ENTRYTICKET_BROWN, "l", NORMAL_FONT, 8)
	end

	-- 4. IDCARD
	if PERSON.idcarddistrict then
		local idc = DOC_TEXT_CACHE.IDCARD.fields
		add_doc_field(idc, 8, 11, PERSON.idcarddistrict .. " DISTRICT", IDCARD_WCOLOR, "l", NORMAL_FONT, 8)
		add_doc_field(idc, 49, 19, (PERSON.idcardlastname or "") .. ",", IDCARD_BCOLOR, "l", NORMAL_FONT, 8)
		add_doc_field(idc, 49, 29, PERSON.idcardfirstname, IDCARD_BCOLOR, "l", NORMAL_FONT, 8)
		add_doc_field(idc, 65, 39, PERSON.idcardDOB, IDCARD_BCOLOR, "l", NORMAL_FONT, 8)
		add_doc_field(idc, 65, 49, PERSON.idcardheight, IDCARD_BCOLOR, "l", NORMAL_FONT, 8)
		add_doc_field(idc, 65, 59, PERSON.idcardweight, IDCARD_BCOLOR, "l", NORMAL_FONT, 8)
		DOC_TEXT_CACHE.IDCARD.photo = { x_off = 4, y_off = 17 }
	end

	-- 5. WORKPASS
	if PERSON.WORKPASSholder then
		local wp1 = DOC_TEXT_CACHE.WORKPASS.fields_align1
		add_doc_field(wp1, 85, 63, PERSON.WORKPASSholder, WORKPASS_COLOR, "c", NORMAL_FONT, 8)
		add_doc_field(wp1, 85, 79, PERSON.WORKPASSfield, WORKPASS_COLOR, "c", NORMAL_FONT, 8)
		add_doc_field(wp1, 85, 95, PERSON.WORKPASSuntil, WORKPASS_COLOR, "c", NORMAL_FONT, 8)

		local wp0 = DOC_TEXT_CACHE.WORKPASS.fields_align0
		add_doc_field(wp0, 40, 63, PERSON.WORKPASSholder, WORKPASS_COLOR, "l", NORMAL_FONT, 8)
		add_doc_field(wp0, 36, 79, PERSON.WORKPASSfield, WORKPASS_COLOR, "l", NORMAL_FONT, 8)
		add_doc_field(wp0, 36, 95, PERSON.WORKPASSuntil, WORKPASS_COLOR, "l", NORMAL_FONT, 8)
	end
end

function LOAD_TEXT(key, face)
	if not DOC_TEXT_CACHE or not DOC_TEXT_CACHE.PASSPORT then
		BUILD_DOC_TEXT_CACHE()
	end

	if CITATIONS and CITATIONS[key] then
		local cit = CITATIONS[key]
		local cx = math.floor(cit.x)
		local cy = math.floor(cit.y)
		if not cit.title_w then
			cit.title_w = GPU_MeasureText("MINISTRY OF ADMISSION", 7)
			cit.sub_w = GPU_MeasureText("OFFICIAL CITATION", 7)
			cit.reason_u = string.upper(cit.reason or "")
			cit.reason_w = GPU_MeasureText(cit.reason_u, 7)
			cit.penalty_u = string.upper(cit.penalty or "")
			cit.penalty_w = GPU_MeasureText(cit.penalty_u, 7)
		end
		if cy + 22 >= 65 and cy + 22 <= 240 then
			GPU_DrawText(cx + 91, cy + 22, "MINISTRY OF ADMISSION", CITATION_COLOR, "c", 320, SMALL_FONT, 7, cit.title_w)
		end
		if cy + 33 >= 65 and cy + 33 <= 240 then
			GPU_DrawText(cx + 91, cy + 33, "OFFICIAL CITATION", CITATION_COLOR, "c", 320, SMALL_FONT, 7, cit.sub_w)
		end
		if cy + 44 >= 65 and cy + 44 <= 240 then
			GPU_DrawText(cx + 91, cy + 44, cit.reason_u, CITATION_COLOR, "c", 320, SMALL_FONT, 7, cit.reason_w)
		end
		if cy + 56 >= 65 and cy + 56 <= 240 then
			GPU_DrawText(cx + 91, cy + 56, cit.penalty_u, CITATION_COLOR, "c", 320, SMALL_FONT, 7, cit.penalty_w)
		end
		return
	end

	if (key == "IDENTITYRECORD" or (IDENTITYRECORD and IDENTITYRECORD.key == key)) and IDENTITYRECORD then
		local sx = math.floor(IDENTITYRECORD.x)
		local sy = math.floor(IDENTITYRECORD.y)
		if sy + 14 >= 65 and sy + 14 <= 240 then
			GPU_DrawText(sx + 45, sy + 14, string.upper(PERSON.name or ""), BLACK, "l", 320, SMALL_FONT, 7)
		end
		if sy + 24 >= 65 and sy + 24 <= 240 then
			local alias_str = (PERSON.has_alias and PERSON.alias and string.upper(PERSON.alias)) or "NONE"
			local alias_col = (PERSON.has_alias and Color.new(20, 80, 25)) or Color.new(45, 45, 45)
			GPU_DrawText(sx + 45, sy + 24, alias_str, alias_col, "l", 320, SMALL_FONT, 7)
		end
		return
	end

	if key == "PASSPORT" then
		local p_data = DOC_TEXT_CACHE.PASSPORT
		if p_data then
			local px = PASSPORT.x
			local py = PASSPORT.y
			local fields = p_data.fields
			for i = 1, #fields do
				local f = fields[i]
				local ay = py + f.y_off
				if ay >= 65 and ay <= 240 then
					GPU_DrawText(px + f.x_off, ay, f.text, f.color, f.align, 320, f.font, f.size, f.w)
				end
			end
			if p_data.photo then
				local ay = py + p_data.photo.y_off
				if ay >= 65 and ay <= 240 then
					Graphics.drawPartialImage(px + p_data.photo.x_off, ay, 40*(face - (11*(math.ceil((face-0.1)/11)-1)+1)), 48*(math.ceil((face-0.1)/11)-1), 40, 48, FACE[5])
				end
			end
		end
		if stamp == "NO" then
			Graphics.drawPartialImage(PASSPORT.x + state2x, PASSPORT.y + state2y, statesp1, statesp2, statesp3, statesp4, NOSTAMP)
		elseif stamp == "YES" then
			Graphics.drawPartialImage(PASSPORT.x + state2x, PASSPORT.y + state2y, statesp1, statesp2, statesp3, statesp4, YESSTAMP)
		end
	elseif key == "ENTRYTICKET" then
		local et_data = DOC_TEXT_CACHE.ENTRYTICKET
		if et_data then
			local ex = ENTRYTICKET.x
			local ey = ENTRYTICKET.y
			local fields = et_data.fields
			for i = 1, #fields do
				local f = fields[i]
				local ay = ey + f.y_off
				if ay >= 65 and ay <= 240 then
					GPU_DrawText(ex + f.x_off, ay, f.text, f.color, f.align, 320, f.font, f.size, f.w)
				end
			end
		end
	elseif key == "ENTRYPERMIT" then
		local ep_data = DOC_TEXT_CACHE.ENTRYPERMIT
		if ep_data then
			local ex = ENTRYPERMIT.x
			local ey = ENTRYPERMIT.y
			local moa_y = ey + PERSON.permity
			if moa_y >= 65 and moa_y <= 240 then
				Graphics.drawPartialImage(ex + PERSON.permitx, moa_y, 35*(PERSON.permitMOA - (4*(math.ceil((PERSON.permitMOA-0.1)/4)-1)+1)), 35*(math.ceil((PERSON.permitMOA-0.1)/4)-1), 35, 35, EMOA, Color.new(240,0,0,150))
			end
			local fields = (Options["TextAlign"] == 1) and ep_data.fields_align1 or ep_data.fields_align0
			for i = 1, #fields do
				local f = fields[i]
				local ay = ey + f.y_off
				if ay >= 65 and ay <= 240 then
					GPU_DrawText(ex + f.x_off, ay, f.text, f.color, f.align, 320, f.font, f.size, f.w)
				end
			end
		end
	elseif key == "IDCARD" then
		local idc_data = DOC_TEXT_CACHE.IDCARD
		if idc_data then
			local ix = IDCARD.x
			local iy = IDCARD.y
			local fields = idc_data.fields
			for i = 1, #fields do
				local f = fields[i]
				local ay = iy + f.y_off
				if ay >= 65 and ay <= 240 then
					GPU_DrawText(ix + f.x_off, ay, f.text, f.color, f.align, 320, f.font, f.size, f.w)
				end
			end
			if idc_data.photo then
				local ay = iy + idc_data.photo.y_off
				if ay >= 65 and ay <= 240 then
					Graphics.drawPartialImage(ix + idc_data.photo.x_off, ay, 40*(PERSON.idcardface - (11*(math.ceil((PERSON.idcardface-0.1)/11)-1)+1)), 48*(math.ceil((PERSON.idcardface-0.1)/11)-1), 40, 48, FACE[5])
				end
			end
		end
	elseif key == "WORKPASS" then
		local wp_data = DOC_TEXT_CACHE.WORKPASS
		if wp_data then
			local wx = WORKPASS.x
			local wy = WORKPASS.y
			local mol_y = wy + PERSON.WORKPASSy
			if mol_y >= 65 and mol_y <= 240 then
				Graphics.drawPartialImage(wx + PERSON.WORKPASSx, mol_y, 35*(PERSON.WORKPASSMOL - (4*(math.ceil((PERSON.WORKPASSMOL-0.1)/4)-1)+1)), 35*(math.ceil((PERSON.WORKPASSMOL-0.1)/4)-1), 35, 35, EMOL, Color.new(88,0,240,150))
			end
			local fields = (Options["TextAlign"] == 1) and wp_data.fields_align1 or wp_data.fields_align0
			for i = 1, #fields do
				local f = fields[i]
				local ay = wy + f.y_off
				if ay >= 65 and ay <= 240 then
					GPU_DrawText(wx + f.x_off, ay, f.text, f.color, f.align, 320, f.font, f.size, f.w)
				end
			end
		end
	elseif key == "TRANSCRIPT" then
		if Options["Dialog"] == 1 then
			local tx = TRANSCRIPT.x
			local ty = TRANSCRIPT.y
			for i = 1, #CHAT do
				local ly = ty + 13 + 9 * (i - 1)
				if ly >= 65 and ly <= 240 then
					if not CHAT_U[i] then
						local u = string.upper(tostring(CHAT[i] or ""))
						CHAT_U[i] = u
						CHAT_W[i] = GPU_MeasureText(u, 8)
					end
					if CHATplace[i] == 1 then
						Graphics.drawImage(tx + 11, ty + 12 + 9 * (i - 1), TRANSCRIPT.tex3)
						GPU_DrawText(tx + 12, ly, CHAT_U[i], TRANSCRIPTBLUE, "l", tx + 138, NORMAL_FONT, 8, CHAT_W[i])
					elseif CHATplace[i] == 2 then
						local rx = tx + 137
						local w = CHAT_W[i] or 0
						if w > 125 then
							rx = tx + 12 + w
						end
						GPU_DrawText(rx, ly, CHAT_U[i], TRANSCRIPTBROWN, "r", tx + 138, NORMAL_FONT, 8, w)
					end
				end
			end
		end
	elseif key == "BULLETIN" then
		local bx = BULLETIN.x
		local by = BULLETIN.y
		-- In Story Mode use the current day config; in Arcade modes use the full checkpoint config.
		local cur_cfg = IS_STORY_MODE
			and ((GET_DAY_CONFIG and GET_DAY_CONFIG(CURRENT_DAY)) or (DAYS_CONFIG and DAYS_CONFIG[CURRENT_DAY or 1]))
			or ARCADE_DAY_CONFIG
		local day_num = IS_STORY_MODE and (CURRENT_DAY or 1) or "A"
		local day_date = (cur_cfg and cur_cfg.date) or "26.11.1982"

		-- [ZONE 1: MINISTRY HEADER (y = 0..67, height 68 px, above authentic dotted line at 68)]
		GPU_DrawText(bx + 75, by + 8, "MINISTRY OF ADMISSION", Color.new(75, 55, 45), "c", 320, NORMAL_FONT, 8)
		GPU_DrawText(bx + 75, by + 21, "OFFICIAL BULLETIN", Color.new(125, 45, 45), "c", 320, SMALL_FONT, 7)
		GPU_DrawText(bx + 75, by + 33, "DAY " .. tostring(day_num) .. " - " .. day_date, Color.new(90, 80, 75), "c", 320, SMALL_FONT, 7)
		GPU_DrawText(bx + 14, by + 52, "DAILY DIRECTIVES:", Color.new(55, 42, 38), "l", 320, SMALL_FONT, 7)

		-- [ZONE 2: DIRECTIVES & RULES]
		local blayout = GET_BULLETIN_LAYOUT(cur_cfg)
		for _, r in ipairs(blayout.rules) do
			local ry = by + r.ry
			-- Square red bullet marker (centered vertically with first line of rule)
			Graphics.fillRect(bx + 14, bx + 17, ry + 2, ry + 5, Color.new(140, 45, 40))
			if r.wrapped then
				GPU_DrawText(bx + 20, ry, r.line1, Color.new(45, 38, 34), "l", 320, SMALL_FONT, 7)
				GPU_DrawText(bx + 20, ry + 8, r.line2, Color.new(45, 38, 34), "l", 320, SMALL_FONT, 7)
			else
				GPU_DrawText(bx + 20, ry, r.line1, Color.new(45, 38, 34), "l", 320, SMALL_FONT, 7)
			end
		end

		-- Dynamic dotted separator between Zone 2 and Zone 3
		local sep_y = by + blayout.sep_y
		for dx = 0, 148, 2 do
			Graphics.fillRect(bx + dx, bx + dx + 1, sep_y, sep_y + 1, Color.new(163, 163, 163))
		end

		-- [ZONE 3: NOTICE & PROTOCOL FOOTER]
		local n1_y = by + blayout.notice_y1
		local n2_y = by + blayout.notice_y2
		if cur_cfg and cur_cfg.wanted_name then
			GPU_DrawText(bx + 75, n1_y, "SPECIAL NOTICE", Color.new(135, 45, 45), "c", 320, SMALL_FONT, 7)
			GPU_DrawText(bx + 75, n2_y, "FUGITIVE: " .. string.upper(cur_cfg.wanted_name), Color.new(55, 45, 40), "c", 320, SMALL_FONT, 7)
		elseif cur_cfg and cur_cfg.embargo_nation then
			GPU_DrawText(bx + 75, n1_y, "SPECIAL NOTICE", Color.new(135, 45, 45), "c", 320, SMALL_FONT, 7)
			GPU_DrawText(bx + 75, n2_y, "EMBARGO: " .. string.upper(cur_cfg.embargo_nation), Color.new(55, 45, 40), "c", 320, SMALL_FONT, 7)
		else
			GPU_DrawText(bx + 75, n1_y, "INSPECTION PROTOCOL ACTIVE", Color.new(110, 100, 95), "c", 320, SMALL_FONT, 7)
			GPU_DrawText(bx + 75, n2_y, "REPORT ALL DISCREPANCIES", Color.new(110, 100, 95), "c", 320, SMALL_FONT, 7)
		end
		GPU_DrawText(bx + 75, by + blayout.glory_y, "GLORY TO ARSTOTZKA", Color.new(100, 80, 75), "c", 320, SMALL_FONT, 7)
	end
end
function STAMP_CODE()
	if TOUCHx>=STAMP.x and TOUCHx<=STAMP.x+10 and TOUCHy>=47 and TOUCHy<=104 and STAMP.state=="CLOSED" and TOUCH=="ACTIVE" then
		STAMP.state="OPENED"
		STAMP.velocity=23
		TOUCH="STAMP"
		STAMP.gravity = 0
		PLAY_SFX("stampbar_open")
	end
	if TOUCHx>=STAMP.x and TOUCHx<=STAMP.x+10 and TOUCHy>=47 and TOUCHy<=104 and STAMP.state=="OPENED" and TOUCH=="ACTIVE" then 
		STAMP.state="CLOSED"
		STAMP.velocity=0
		TOUCH="STAMP"
		STAMP.gravity = 0
		PLAY_SFX("stampbar_close")
	end
	if STAMP.x > 40 and STAMP.state=="OPENED" then
		STAMP.gravity = 1
		elseif STAMP.state=="OPENED" then
		STAMP.gravity = 0 
	end
	if STAMP.x < 310 and STAMP.state=="CLOSED" then
		STAMP.gravity = 1
		elseif STAMP.state=="CLOSED" then
		STAMP.gravity = 0 
	end
	if STAMP.state=="OPENED" and STAMP.x > 40 and STAMP.velocity > 0 and Timer.getTime(STAMP_TIMER) >= 10 then
		Timer.reset(STAMP_TIMER)
		Timer.resume(STAMP_TIMER)
		STAMP.velocity = STAMP.velocity - STAMP.gravity
		STAMP.x = STAMP.x - STAMP.velocity
	end
	if STAMP.state=="CLOSED" and STAMP.x < 310 and Timer.getTime(STAMP_TIMER) >= 10 then
		Timer.reset(STAMP_TIMER)
		Timer.resume(STAMP_TIMER)
		STAMP.velocity = STAMP.velocity + STAMP.gravity
		STAMP.x = STAMP.x + STAMP.velocity
	end
	if STAMP.x<40 and STAMP.state=="OPENED" then STAMP.x=40 end
	if STAMP.x>310 and STAMP.state=="CLOSED" then STAMP.x=310 end
	if STAMP.state=="OPENED" and TOUCHx>=40+40 and TOUCHy>=22 and TOUCHx<=40+115 and TOUCHy<=22+87 and STAMP.velocity==0 then
		TOUCH="ACTIVE3"
		if STAMP.red<38 then
			STAMP.red=STAMP.red+4
			if STAMP.red>=38 then
				if not STAMP.red_down then
					PLAY_SFX("stamp_down")
					STAMP.red_down = true
				end
				if PASSPORT.x ~= nil then
					if PASSPORT.x+130>STAMP.x+40 and PASSPORT.x<STAMP.x+40+75 and PASSPORT.y<38+87 and PASSPORT.y+162>38+57 and PASSPORT.now==0 then
						statex=STAMP.x+42-PASSPORT.x
						statey=STAMP.red+57-PASSPORT.y
						if statex>=0 and statex<=130 then 
							state2x=statex
							statesp1=0
							elseif statex<0 then
							state2x=0
							statesp1=-statex
							else
							statesp1=nil
						end
						if statey>=0 and statey<=162 then
							state2y=statey
							statesp2=0
							elseif statey<0 then
							state2y=0
							statesp2=-statey
							else
							statesp2=nil
						end
						if statey+30<=162 and statey>0 then
							statesp4=30
							elseif statey<=0 and statey>-30 then
							statesp4=30+statey
							elseif statey+30>162 then
							statesp4=162-statey
							else
							statesp4=nil
						end
						if statex+70<=130 and statex>0 then
							statesp3=70
							elseif statex<=0 and statex>-70 then
							statesp3=70+statex
							elseif statex+70>130 then
							statesp3=130-statex
							else
							statesp3=nil
						end
						if statesp1~=nil and statesp2~=nil and statesp3~=nil and statesp4~= nil then 
							stamp="NO" 
							else 
							stamp=nil 
						end
						
					end
				end
			end
		end
		else
		if STAMP.red_down then
			PLAY_SFX("stamp_up")
			STAMP.red_down = false
		end
		if STAMP.red>22 then
			STAMP.red=STAMP.red-4
		end
	end
	if STAMP.state=="OPENED" and TOUCHx>=40+160 and TOUCHy>=22 and TOUCHx<=40+235 and TOUCHy<=22+87 and STAMP.velocity==0 then
		TOUCH="ACTIVE3"
		if STAMP.green<38 then
			STAMP.green=STAMP.green+4
		end
		if STAMP.green>=38 then
			if not STAMP.green_down then
				PLAY_SFX("stamp_down")
				STAMP.green_down = true
			end
			if PASSPORT.x ~= nil then
				if PASSPORT.x+130>STAMP.x+160 and PASSPORT.x<STAMP.x+160+75 and PASSPORT.y<38+87 and PASSPORT.y+162>38+57 and PASSPORT.now==0 then
					statex=STAMP.x+162-PASSPORT.x
					statey=STAMP.green+57-PASSPORT.y
					if statex>=0 and statex<=130 then 
						state2x=statex
						statesp1=0
						elseif statex<0 then
						state2x=0
						statesp1=-statex
						else
						statesp1=nil
					end
					if statey>=0 and statey<=162 then
						state2y=statey
						statesp2=0
						elseif statey<0 then
						state2y=0
						statesp2=-statey
						else
						statesp2=nil
					end
					if statey+30<=162 and statey>0 then
						statesp4=30
						elseif statey<=0 and statey>-30 then
						statesp4=30+statey
						elseif statey+30>162 then
						statesp4=162-statey
						else
						statesp4=nil
					end
					if statex+70<=130 and statex>0 then
						statesp3=70
						elseif statex<=0 and statex>-70 then
						statesp3=70+statex
						elseif statex+70>130 then
						statesp3=130-statex
						else
						statesp3=nil
					end
					if statesp1~=nil and statesp2~=nil and statesp3~=nil and statesp4~= nil then 
						stamp="YES"  
						else 
						stamp=nil 
					end
					
				end
			end
		end
		else
		if STAMP.green_down then
			PLAY_SFX("stamp_up")
			STAMP.green_down = false
		end
		if STAMP.green>22 then
			STAMP.green=STAMP.green-4
		end
	end
end
function GENDERGENERATOR()
	local a=0
	if (PERSON.face>=1 and PERSON.face<=4) or (PERSON.face>=29 and PERSON.face<=44) then a = "F" else a="M" end
	return a
end
function NAMEGENERATOR()
	if PERSON.GNDR=="M" then 
		return tostring(MNAMES.FN[math.random(1,#MNAMES.FN)]),tostring(MNAMES.LN[math.random(1,#MNAMES.LN)]) 
		else	
		return tostring(FNAMES.FN[math.random(1,#FNAMES.FN)]),tostring(FNAMES.LN[math.random(1,#FNAMES.LN)]) 
	end
end
function PURPOSEGENERATOR()
	local a
	a = math.random(1,4)
	local phrase = "Transit"
	if a==1 then
		a="TRANSIT" 
		local r = math.random(1,3)
		if r==1 then phrase="Transit"
		elseif r==2 then phrase="Transit only"
		else phrase="Passing through" end
	elseif a==2 then 
		a="VISIT" 
		local r = math.random(1,4)
		if r==1 then phrase="Visiting"
		elseif r==2 then phrase="Visiting family"
		elseif r==3 then phrase="Pleasure"
		else phrase="Here on holiday" end
	elseif a==3 then 
		a="IMMIGRATE" 
		local r = math.random(1,3)
		if r==1 then phrase="Immigrating"
		elseif r==2 then phrase="To live here"
		else phrase="Seeking residence" end
	elseif a==4 then 
		a="WORK" 
		local r = math.random(1,4)
		if r==1 then phrase="Working"
		elseif r==2 then phrase="Here for employment"
		elseif r==3 then phrase="Labor and business"
		else phrase="Job placement" end
	end
	table.insert(CHAT,#CHAT+1,phrase)
	table.insert(CHATplace,#CHATplace+1,2)
	return a
end
function DURATIONGENERATOR()
	local a
	local b
	if PERSON.permitpurpose=="TRANSIT" then 
		a=math.random(1,2)
		if a==1 then
			a="2 DAYS" 
			local r = math.random(1,4)
			if r==1 then b="Just 2 days"
			elseif r==2 then b="Couple a days"
			elseif r==3 then b="Visiting for 2 days"
			else b="Transit for 2 days" end
			table.insert(CHAT,#CHAT+1,b)
			table.insert(CHATplace,#CHATplace+1,2)
		else 
			a="14 DAYS" 
			local r = math.random(1,4)
			if r==1 then b="Couple weeks"
			elseif r==2 then b="Just 14 days"
			elseif r==3 then b="Only two weeks"
			else b="Stay for 14 days" end
			table.insert(CHAT,#CHAT+1,b)
			table.insert(CHATplace,#CHATplace+1,2)
		end
	elseif PERSON.permitpurpose=="VISIT" then
		a=math.random(1,4)
		if a==1 then 
			a="14 DAYS" 
			local r = math.random(1,4)
			if r==1 then b="Couple weeks"
			elseif r==2 then b="Just 14 days"
			elseif r==3 then b="Only two weeks"
			else b="Stay for 14 days" end
			table.insert(CHAT,#CHAT+1,b)
			table.insert(CHATplace,#CHATplace+1,2)
		elseif a==2 then
			a="1 MONTH" 
			local r = math.random(1,4)
			if r==1 then b="30 days"
			elseif r==2 then b="A few weeks"
			elseif r==3 then b="One month"
			else b="Visiting for 1 month" end
			table.insert(CHAT,#CHAT+1,b)
			table.insert(CHATplace,#CHATplace+1,2)
		elseif a==3 then
			a="2 MONTHS" 
			local r = math.random(1,4)
			if r==1 then b="60 days"
			elseif r==2 then b="8 weeks"
			elseif r==3 then b="Couple months"
			else b="Two months" end
			table.insert(CHAT,#CHAT+1,b)
			table.insert(CHATplace,#CHATplace+1,2)
		elseif a==4 then
			a="3 MONTHS" 
			local r = math.random(1,4)
			if r==1 then b="90 days"
			elseif r==2 then b="12 weeks"
			elseif r==3 then b="Three months"
			else b="A few months" end
			table.insert(CHAT,#CHAT+1,b)
			table.insert(CHATplace,#CHATplace+1,2)
		end
	elseif PERSON.permitpurpose=="IMMIGRATE" then
		a="FOREVER"
		local r = math.random(1,3)
		if r==1 then b="Forever"
		elseif r==2 then b="Until i die"
		else b="Permanent stay" end
		table.insert(CHAT,#CHAT+1,b)
		table.insert(CHATplace,#CHATplace+1,2)
	elseif PERSON.permitpurpose=="WORK" then
		a=math.random(1,5)
		if a==1 then 
			a="1 MONTH" 
			local r = math.random(1,4)
			if r==1 then b="30 days"
			elseif r==2 then b="A few weeks"
			elseif r==3 then b="One month"
			else b="Work for 1 month" end
			table.insert(CHAT,#CHAT+1,b)
			table.insert(CHATplace,#CHATplace+1,2)
		elseif a==2 then 
			a="2 MONTHS" 
			local r = math.random(1,4)
			if r==1 then b="60 days"
			elseif r==2 then b="8 weeks"
			elseif r==3 then b="Couple months"
			else b="Two months" end
			table.insert(CHAT,#CHAT+1,b)
			table.insert(CHATplace,#CHATplace+1,2)
		elseif a==3 then 
			a="3 MONTHS" 
			local r = math.random(1,4)
			if r==1 then b="90 days"
			elseif r==2 then b="12 weeks"
			elseif r==3 then b="Three months"
			else b="A few months" end
			table.insert(CHAT,#CHAT+1,b)
			table.insert(CHATplace,#CHATplace+1,2)
		elseif a==4 then 
			a="6 MONTHS" 
			local r = math.random(1,3)
			if r==1 then b="Six months"
			elseif r==2 then b="Half a year"
			else b="24 weeks" end
			table.insert(CHAT,#CHAT+1,b)
			table.insert(CHATplace,#CHATplace+1,2)
		elseif a==5 then 
			a="1 Year" 
			local r = math.random(1,4)
			if r==1 then b="One year"
			elseif r==2 then b="Full year"
			elseif r==3 then b="A year"
			else b="12 months" end
			table.insert(CHAT,#CHAT+1,b)
			table.insert(CHATplace,#CHATplace+1,2)
		end
	end
	return a
end
function FORMAT_DATE(day, month, year)
	local d_str = (day < 10 and "0" .. day or tostring(day))
	local m_str = (month < 10 and "0" .. month or tostring(month))
	return d_str .. "." .. m_str .. "." .. tostring(year)
end

function GET_CURRENT_GAME_DATE()
	if IS_STORY_MODE then
		local day_cfg = GET_DAY_CONFIG(CURRENT_DAY)
		if day_cfg and day_cfg.date then
			local d_str = day_cfg.date
			local d = tonumber(string.sub(d_str, 1, 2)) or 23
			local m = tonumber(string.sub(d_str, 4, 5)) or 11
			local y = tonumber(string.sub(d_str, 7, 10)) or 1982
			return d, m, y, d_str
		end
	else
		local d = today.day or 20
		local m = today.month or 10
		local y = 1982
		local str = FORMAT_DATE(d, m, y)
		return d, m, y, str
	end
end

function DOBGENERATOR()
	local _, _, gy = GET_CURRENT_GAME_DATE()
	local age = math.random(18, 65)
	local y = gy - age
	local m = math.random(1, 12)
	local d = math.random(1, 28)
	return FORMAT_DATE(d, m, y)
end

function DATEGENERATOR(validornat)
	local gd, gm, gy = GET_CURRENT_GAME_DATE()
	local d = gy*10000 + gm*100 + gd
	local a, b, c
	local e = 0
	if validornat=="y" then
		e = 0
		while d > e do
			a = math.random(gy, gy + 3)
			b = math.random(1, 12)
			c = math.random(1, 28)
			e = a*10000 + b*100 + c
		end
	elseif validornat=="n" then
		e = 100000000
		while d <= e do
			a = math.random(gy - 3, gy)
			b = math.random(1, 12)
			c = math.random(1, 28)
			e = a*10000 + b*100 + c
		end
	end
	return FORMAT_DATE(c, b, a)
end
function RANDOMIZE()
	local wrong = 0
	if RESET_INSPECTION then RESET_INSPECTION() end
	for i=1,#DESKTOP do table.remove(DESKTOP,1) end
	for i=1,#ALLITEMS do table.remove(ALLITEMS,1) end
	CLEAR_CHAT()
	if CBtime then
		Timer.reset(CBtime)
		Timer.resume(CBtime)
	end
	table.insert(DESKTOP,1,"TRANSCRIPT")
	table.insert(ALLITEMS,1,TRANSCRIPT)
	IDCARD.x=145
	IDCARD.y=-200
	IDCARD.now=1
	PASSPORT.x=145
	PASSPORT.y=-200
	PASSPORT.now=1
	ENTRYPERMIT.x=145 
	ENTRYPERMIT.y=-200
	ENTRYPERMIT.now=1
	WORKPASS.x=145 
	WORKPASS.y=-200
	WORKPASS.now=1
	ENTRYTICKET.rot = math.random(-4,4)/10
	ENTRYPERMIT.rot =  math.random(-4,4)/10
	IDCARD.rot =  math.random(-4,4)/10
	PASSPORT.rot =  math.random(-4,4)/10
	WORKPASS.rot =  math.random(-4,4)/10
	table.insert(DESKTOP,1,"RULEBOOK")
	table.insert(DESKTOP,1,"PASSPORT")
	table.insert(DESKTOP,1,"BULLETIN")
	table.insert(ALLITEMS,1,RULEBOOK)
	table.insert(ALLITEMS,1,PASSPORT)
	table.insert(ALLITEMS,1,BULLETIN)
	RULEBOOK.x = 5
	RULEBOOK.y = 23
	RULEBOOK.now = 1
	BULLETIN.x = 34
	BULLETIN.y = 23
	BULLETIN.now = 1
	table.insert(CHAT,#CHAT+1,"Papers Please")
	table.insert(CHATplace,#CHATplace+1,1)
	local faces = PERSON.face
	while faces == PERSON.face do
		PERSON.face = math.random(1,44)
	end
	PERSON.realface = PERSON.face
	PERSON.passport = math.random(1,8)
	while PERSON.passport==7 do
		PERSON.passport = 2
	end

	local day_cfg = nil
	if IS_STORY_MODE then
		day_cfg = GET_DAY_CONFIG(CURRENT_DAY)
	end

	-- Embargo check & spawn (25% chance to spawn citizen of embargoed nation)
	if IS_STORY_MODE and day_cfg and day_cfg.embargo_nation then
		if math.random(1, 4) == 1 then
			for id, nat in pairs(NATION_NAMES) do
				if nat == day_cfg.embargo_nation then
					PERSON.passport = id
					break
				end
			end
		end
	end

	PERSON.GNDR = GENDERGENERATOR()
	PERSON.idcardfirstname,PERSON.idcardlastname=NAMEGENERATOR()
	PERSON.name = tostring(PERSON.idcardfirstname.." "..PERSON.idcardlastname)

	-- Wanted fugitive check & spawn (20% chance to spawn wanted fugitive)
	PERSON.is_wanted = false
	if IS_STORY_MODE and day_cfg and day_cfg.wanted_name then
		if math.random(1, 5) == 1 then
			PERSON.is_wanted = true
			PERSON.name = day_cfg.wanted_name
			local s_idx = string.find(day_cfg.wanted_name, " ")
			if s_idx then
				PERSON.idcardfirstname = string.sub(day_cfg.wanted_name, 1, s_idx - 1)
				PERSON.idcardlastname = string.sub(day_cfg.wanted_name, s_idx + 1)
			else
				PERSON.idcardfirstname = day_cfg.wanted_name
				PERSON.idcardlastname = ""
			end
		end
	end

	PERSON.transcript_mismatch = false
	PERSON.is_embargoed = false
	PERSON.fingerprints = {
		math.random(0, 29),
		math.random(0, 29),
		math.random(0, 29),
		math.random(0, 29),
		math.random(0, 29)
	}
	PERSON.record_fingerprints = {
		PERSON.fingerprints[1],
		PERSON.fingerprints[2],
		PERSON.fingerprints[3],
		PERSON.fingerprints[4],
		PERSON.fingerprints[5]
	}
	PERSON.fingerprint_id = PERSON.fingerprints[1]
	PERSON.record_fingerprint_id = PERSON.fingerprints[1]
	PERSON.has_alias = false
	PERSON.alias = nil
	PERSON.photo_verified = false
	PERSON.name_cleared = false
	PERSON.photo_cleared = false
	PERSON.DOB = DOBGENERATOR()
	PERSON.COL = FORDOCUMENT[PERSON.passport][math.random(1,3)]
	PERSON.passEXP=DATEGENERATOR("y")
	PERSON.ID=makeString(5).."-"..makeString(5)
	local give_permit = true
	local give_workpass = true
	if IS_STORY_MODE and day_cfg then
		give_permit = day_cfg.require_permit
		give_workpass = day_cfg.require_workpass
	end

	if PERSON.passport==2 then
		table.insert(DESKTOP,1,"IDCARD")
		table.insert(ALLITEMS,1,IDCARD)
		PERSON.idcarddistrict=DISTRICTS[math.random(1,#DISTRICTS)]
		PERSON.idcardDOB=tostring(PERSON.DOB)
		PERSON.idcardheight = HEIGHTGENERATOR()
		PERSON.idcardweight = math.random(40,90)
		PERSON.idcardface=PERSON.face
		PERSON.height=PERSON.idcardheight
		PERSON.weight=PERSON.idcardweight
	else
		if give_permit then
			table.insert(DESKTOP,1,"ENTRYPERMIT")
			table.insert(ALLITEMS,1,ENTRYPERMIT)
		end
		local AskPurpose=math.random(1,3)
		if AskPurpose==1 then AskPurpose="What's Purpose?"
			elseif AskPurpose==2 then AskPurpose="What's Reason?"
			elseif AskPurpose==3 then AskPurpose="Purpose of the trip?"
		end
		table.insert(CHAT,#CHAT+1,AskPurpose)
		table.insert(CHATplace,#CHATplace+1,1)
		PERSON.permitname=PERSON.name
		PERSON.permitid=tostring(PERSON.ID)
		PERSON.permitpurpose=tostring(PURPOSEGENERATOR())
		PERSON.permitx = math.random(10,105)
		PERSON.permity = math.random(11,23)
		PERSON.permitMOA = math.random(1,2)
		local AskDuration=math.random(1,3)
		if AskDuration==1 then AskDuration="What's Duration?"
			elseif AskDuration==2 then AskDuration="How long?"
			elseif AskDuration==3 then AskDuration="Duration of the trip?"
		end
		table.insert(CHAT,#CHAT+1,AskDuration)
		table.insert(CHATplace,#CHATplace+1,1)
		PERSON.permitduration=tostring(DURATIONGENERATOR())
		PERSON.permitenterby=DATEGENERATOR("y")
		PERSON.height=HEIGHTGENERATOR()
		PERSON.weight=math.random(40,90)
	end
	if give_workpass and PERSON.permitpurpose=="WORK" and PERSON.passport~=2 then
		table.insert(DESKTOP,1,"WORKPASS")
		table.insert(ALLITEMS,1,WORKPASS)
		PERSON.WORKPASSholder=PERSON.name
		PERSON.WORKPASSfield=FIELDS[math.random(1,#FIELDS)]
		PERSON.WORKPASSuntil=DATEGENERATOR("y")
		PERSON.WORKPASSx = math.random(6,105)
		PERSON.WORKPASSy = math.random(7,29)
		PERSON.WORKPASSMOL = math.random(1,4)
	end
	
	wrong = math.random(1,#WRONGTABLE)
	if IS_STORY_MODE and day_cfg then
		if not give_permit and (wrong==7 or wrong==9 or wrong==15 or wrong==17 or wrong==18) then
			wrong = 1
		end
		if not give_workpass and wrong==16 then
			wrong = 1
		end
		if (CURRENT_DAY < 5 or not give_permit or PERSON.passport == 2) and wrong == 18 then
			wrong = 1
		end
	elseif not IS_STORY_MODE and wrong == 18 then
		wrong = 1
	end
	if wrong==4 then
		if PERSON.passport==2 then
			local dob_tries = 0
			while PERSON.idcardDOB == PERSON.DOB and dob_tries < 10 do
				PERSON.idcardDOB = DOBGENERATOR()
				dob_tries = dob_tries + 1
			end
			if PERSON.idcardDOB == PERSON.DOB then
				wrong=1 
			end
			else 
			wrong=1
		end
		elseif wrong==5 then
		PERSON.COL = FORDOCUMENTFAKE[PERSON.passport][math.random(1,3)]
		elseif wrong==6 then
		if PERSON.passport==2 then
			PERSON.idcarddistrict=FAKEDISTRICTS[math.random(1,#FAKEDISTRICTS)]
			else 
			wrong=1
		end
		elseif wrong==7 then
		while PERSON.name == tostring(PERSON.idcardfirstname.." "..PERSON.idcardlastname) do
			PERSON.idcardfirstname,PERSON.idcardlastname=NAMEGENERATOR()
		end
		while PERSON.permitname==PERSON.name do
			PERSON.idcardfirstname,PERSON.idcardlastname=NAMEGENERATOR()
			PERSON.permitname = tostring(PERSON.idcardfirstname.." "..PERSON.idcardlastname)
		end
		if (not IS_STORY_MODE or (CURRENT_DAY and CURRENT_DAY >= 5)) and math.random(1, 2) == 1 then
			PERSON.has_alias = true
			PERSON.alias = PERSON.permitname or tostring(PERSON.idcardfirstname.." "..PERSON.idcardlastname)
			PERSON.record_fingerprints = {
				PERSON.fingerprints[1],
				PERSON.fingerprints[2],
				PERSON.fingerprints[3],
				PERSON.fingerprints[4],
				PERSON.fingerprints[5]
			}
			PERSON.record_fingerprint_id = PERSON.fingerprint_id
		else
			PERSON.has_alias = false
			PERSON.alias = nil
			PERSON.record_fingerprints = {
				PERSON.fingerprints[1],
				(PERSON.fingerprints[2] + math.random(1, 10)) % 30,
				PERSON.fingerprints[3],
				(PERSON.fingerprints[4] + math.random(1, 10)) % 30,
				PERSON.fingerprints[5]
			}
			PERSON.record_fingerprint_id = PERSON.record_fingerprints[2]
		end
		elseif wrong==8 then
		if PERSON.GNDR=="M" then 
			PERSON.GNDR="F"
			else	
			PERSON.GNDR="M"
		end
		elseif wrong==9 then
		if PERSON.passport~=2 then
			while PERSON.permitid==tostring(PERSON.ID) do
				PERSON.permitid=tostring(makeString(5).."-"..makeString(5))
			end
			else 
			wrong=1
		end
		elseif wrong==10 then
		if PERSON.passport==2 then
			if math.random(1, 2) == 1 then
				PERSON.idcardheight = PERSON.idcardheight - math.random(8, 12)
			else
				PERSON.idcardheight = PERSON.idcardheight + math.random(8, 12)
			end
			else 
			wrong=1
		end
		elseif wrong==11 then
		if PERSON.passport==2 then
			if math.random(1, 2) == 1 then
				PERSON.idcardweight = PERSON.weight - math.random(4, 8)
			else
				PERSON.idcardweight = PERSON.weight + math.random(4, 8)
			end
			else 
			wrong=1
		end
		elseif wrong==12 then
		PERSON.idcardface = math.random(1,44)
		PERSON.face = PERSON.idcardface
		if PERSON.idcardface==PERSON.realface then
			wrong=1
		end
		if (not IS_STORY_MODE or (CURRENT_DAY and CURRENT_DAY >= 5)) and math.random(1, 2) == 1 then
			PERSON.photo_verified = true
			PERSON.record_fingerprints = {
				PERSON.fingerprints[1],
				PERSON.fingerprints[2],
				PERSON.fingerprints[3],
				PERSON.fingerprints[4],
				PERSON.fingerprints[5]
			}
			PERSON.record_fingerprint_id = PERSON.fingerprint_id
		else
			PERSON.photo_verified = false
			PERSON.record_fingerprints = {
				(PERSON.fingerprints[1] + math.random(1, 10)) % 30,
				PERSON.fingerprints[2],
				(PERSON.fingerprints[3] + math.random(1, 10)) % 30,
				PERSON.fingerprints[4],
				PERSON.fingerprints[5]
			}
			PERSON.record_fingerprint_id = PERSON.record_fingerprints[1]
		end
		elseif wrong==14 then
		PERSON.passEXP=DATEGENERATOR("n")
		elseif wrong==15 then
		PERSON.permitenterby=DATEGENERATOR("n")
		elseif wrong==16 then
		if PERSON.permitpurpose=="WORK" and PERSON.passport~=2 then
			PERSON.WORKPASSMOL = math.random(5,10)
			else
			wrong=1
		end
		elseif wrong==17 then
		if PERSON.passport~=2 then
			PERSON.permitMOA = math.random(3,10)
			else
			wrong=1
		end
		elseif wrong==18 then
		if PERSON.passport~=2 and give_permit then
			PERSON.transcript_mismatch = true
			if PERSON.permitduration == "2 DAYS" then
				PERSON.permitduration = "1 MONTH"
			elseif PERSON.permitduration == "14 DAYS" then
				PERSON.permitduration = "2 DAYS"
			elseif PERSON.permitduration == "1 MONTH" then
				PERSON.permitduration = "2 DAYS"
			elseif PERSON.permitduration == "2 MONTHS" or PERSON.permitduration == "3 MONTHS" then
				PERSON.permitduration = "14 DAYS"
			elseif PERSON.permitduration == "FOREVER" then
				PERSON.permitduration = "3 MONTHS"
			elseif PERSON.permitduration == "6 MONTHS" or PERSON.permitduration == "1 Year" then
				PERSON.permitduration = "14 DAYS"
			else
				PERSON.permitduration = "2 DAYS"
			end
		else
			wrong = 1
		end
	end
	LASTWRONGCONST = WRONGCONST
	WRONGCONST=WRONGTABLE[wrong]
	if IS_STORY_MODE and day_cfg then
		if not day_cfg.allow_foreigners and PERSON.passport~=2 then
			WRONGCONST = "Foreigners not allowed"
		elseif day_cfg.embargo_nation and GET_NATION_NAME(PERSON.passport) == day_cfg.embargo_nation then
			PERSON.is_embargoed = true
			WRONGCONST = "Violation of diplomatic sanctions"
		elseif PERSON.is_wanted then
			WRONGCONST = "Wanted fugitive admitted"
		elseif PERSON.transcript_mismatch then
			WRONGCONST = "Entry permit duration mismatch"
		end
	end
	if CITATION_COUNT > 0 then
		for i = 1, CITATION_COUNT do
			local id_str = "CITATION_" .. i
			local cit = CITATIONS[id_str]
			if cit then
				table.insert(DESKTOP, 1, cit.key)
				table.insert(ALLITEMS, 1, cit)
				ITEM_BY_KEY[cit.key] = cit
			end
		end
	end
	stamp=nil
	BUILD_DOC_TEXT_CACHE()
end
function TECHMENU()
	TECHMENUenable = 0
	if Controls.check(pad,KEY_SELECT) then
		TECHMENUenable = 1
	end
	if TECHMENUenable==1 then
		Graphics.fillRect(0,400,0,103,BLACK)
		if stamp==nil then
			GPU_DrawText(0,0,"Stamp - not found",WHITE,"l",400,NORMAL_FONT,8)
			elseif stamp=="YES" then
			GPU_DrawText(0,0,"Stamp - "..stamp,GREEN,"l",400,NORMAL_FONT,8)
			elseif stamp=="NO" then
			GPU_DrawText(0,0,"Stamp - "..stamp,RED,"l",400,NORMAL_FONT,8)
		end
		GPU_DrawText(0,8,"FaceId - "..PERSON.face,WHITE,"l",400,NORMAL_FONT,8)
		GPU_DrawText(0,16,"StateOfCage - "..SWITCHER ,WHITE,"l",400,NORMAL_FONT,8)
		GPU_DrawText(0,24,"TouchX-TouchY: "..TOUCHx.." - "..TOUCHy ,WHITE,"l",400,NORMAL_FONT,8)
		if TOUCH~=nil then
			GPU_DrawText(0,32,"ActiveItem - "..TOUCH ,WHITE,"l",400,NORMAL_FONT,8)
			else
			GPU_DrawText(0,32,"ActiveItem - NOTHING" ,WHITE,"l",400,NORMAL_FONT,8)
		end
		if TOUCH=="PASSPORT" then
			GPU_DrawText(0,40, PERSON.passport,WHITE,"l",400,NORMAL_FONT,8)
		end
		GPU_DrawText(0,48,"Last Wrong - "..LASTWRONGCONST,WHITE,"l",400,NORMAL_FONT,8)
		GPU_DrawText(0,64,"Now Wrong - "..WRONGCONST  ,WHITE,"l",400,NORMAL_FONT,8)
		
		if stamp==nil then
			GPU_DrawText(0,72,"STAMP the PASSPORT and Check this line",GREEN,"l",400,NORMAL_FONT,8)
			elseif stamp=="YES" and WRONGCONST=="Nothing" then
			GPU_DrawText(0,72,"YOU ARE CORRECT",GREEN,"l",400,NORMAL_FONT,8)
			elseif stamp=="NO" and WRONGCONST~="Nothing" then
			GPU_DrawText(0,72,"YOU ARE CORRECT",GREEN,"l",400,NORMAL_FONT,8)
			else
			GPU_DrawText(0,72,"YOU ARE NOT CORRECT",RED,"l",400,NORMAL_FONT,8)
		end
	end
end
function HEIGHTGENERATOR()
	local a = 0
	if PERSON.face==1 then a=math.random(166,169)
		elseif PERSON.face==2 then a=math.random(167,169)
		elseif PERSON.face==3 then a=math.random(165,168)
		elseif PERSON.face==4 then a=math.random(173,176)
		elseif PERSON.face==5 then a=math.random(182,185)
		elseif PERSON.face==6 then a=math.random(165,168)
		elseif PERSON.face==7 then a=math.random(178,181)
		elseif PERSON.face==8 then a=math.random(177,180)
		elseif PERSON.face==9 then a=math.random(180,182)
		elseif PERSON.face==10 then a=math.random(171,173)
		elseif PERSON.face==11 then a=math.random(178,181)
		elseif PERSON.face==12 then a=math.random(173,176)
		elseif PERSON.face==13 then a=math.random(176,178)
		elseif PERSON.face==14 then a=math.random(173,176)
		elseif PERSON.face==15 then a=math.random(179,181)
		elseif PERSON.face==16 then a=math.random(181,184)
		elseif PERSON.face==17 then a=math.random(173,176)
		elseif PERSON.face==18 then a=math.random(178,181)
		elseif PERSON.face==19 then a=math.random(166,169)
		elseif PERSON.face==20 then a=math.random(171,173)
		elseif PERSON.face==21 then a=math.random(163,166)
		elseif PERSON.face==22 then a=math.random(178,181)
		elseif PERSON.face==23 then a=math.random(168,170)
		elseif PERSON.face==24 then a=math.random(179,181)
		elseif PERSON.face==25 then a=math.random(181,183)
		elseif PERSON.face==26 then a=math.random(178,181)
		elseif PERSON.face==27 then a=math.random(181,184)
		elseif PERSON.face==28 then a=math.random(181,184)
		elseif PERSON.face==29 then a=math.random(175,177)
		elseif PERSON.face==30 then a=math.random(161,164)
		elseif PERSON.face==31 then a=math.random(171,173)
		elseif PERSON.face==32 then a=math.random(178,181)
		elseif PERSON.face==33 then a=math.random(172,174)
		elseif PERSON.face==34 then a=math.random(178,181)
		elseif PERSON.face==35 then a=math.random(171,173)
		elseif PERSON.face==36 then a=math.random(169,171)
		elseif PERSON.face==37 then a=math.random(172,175)
		elseif PERSON.face==38 then a=math.random(173,176)
		elseif PERSON.face==39 then a=math.random(173,176)
		elseif PERSON.face==40 then a=math.random(177,180)
		elseif PERSON.face==41 then a=math.random(166,169)
		elseif PERSON.face==42 then a=math.random(171,173)
		elseif PERSON.face==43 then a=math.random(171,173)
		elseif PERSON.face==44 then a=math.random(172,174)
	end
	return a
end
function DRAW_SPEECH_BUBBLE(x, y, w)
	if w <= 80 and x >= 0 then
		Graphics.drawImage(x, y, SB)
	else
		local x_start = math.max(0, x)
		local x_end = math.min(400, x + w - 1)
		if x_end > x_start then
			local r0_s = math.max(0, x + 2)
			local r0_e = math.min(400, x + w - 3)
			if r0_e > r0_s then Graphics.fillRect(r0_s, r0_e, y, y + 10, DOCUMENTS_WHITE) end

			local r1_s = math.max(0, x + 1)
			local r1_e = math.min(400, x + w - 2)
			if r1_e > r1_s then Graphics.fillRect(r1_s, r1_e, y + 1, y + 9, DOCUMENTS_WHITE) end

			Graphics.fillRect(x_start, x_end, y + 2, y + 8, DOCUMENTS_WHITE)
		end
	end
end

function DIALOG_SYSTEM()
	if FACE.x < 126 and stamp == nil then
		if CBtime then
			Timer.reset(CBtime)
			Timer.resume(CBtime)
		end
		return
	end

	if FACE.x ~= 126 then
		return
	end

	if SWITCHER == 1 then
		if CBtime then
			Timer.pause(CBtime)
		end
		return
	end

	if CBtime then
		Timer.resume(CBtime)
	end
	local current_t = Timer.getTime(CBtime)
	for i = 1, #CHAT do
		if CHATtime[i] == nil then
			CHATtime[i] = 1000 * (i - 1)
		end
		local should_start = (current_t >= CHATtime[i]) or (i > 1 and CHATframe and CHATframe[i - 1] and CHATframe[i - 1] >= 60) or (i == 1)
		if should_start then
			if CHATframe then
				CHATframe[i] = (CHATframe[i] or 0) + 1
			end
			local elapsed = current_t - CHATtime[i]
			local y = CHATy[i] or (103 + (i - 1) * 12)
			local place = CHATplace[i] or 1

			local bw = CHATw[i]
			if bw == nil then
				local text_w = GPU_MeasureText(CHAT[i], 7)
				bw = math.max(80, text_w + 6)
				CHATw[i] = bw
			end

			local is_timed_out = (elapsed >= 3000) or (CHATframe and CHATframe[i] and CHATframe[i] >= 180)

			if place == 2 then
				if CHATx[i] == nil then
					CHATx[i] = 290 - bw
					PLAY_SFX("speech_entrant")
				end
				if CHATx[i] < 290 then
					DRAW_SPEECH_BUBBLE(CHATx[i], y, bw)
					GPU_DrawText(CHATx[i] + 2, y + 3, CHAT[i], BROWN2, "l", 400, SMALL_FONT, 7)
					if is_timed_out then
						CHATx[i] = CHATx[i] + 5
					end
				end
			else
				if CHATx[i] == nil then
					CHATx[i] = 112
					PLAY_SFX("speech_inspector")
				end
				if CHATx[i] + bw > 112 then
					DRAW_SPEECH_BUBBLE(CHATx[i], y, bw)
					GPU_DrawText(CHATx[i] + 2, y + 3, CHAT[i], BROWN2, "l", 400, SMALL_FONT, 7)
					if is_timed_out then
						CHATx[i] = CHATx[i] - 5
					end
				end
			end
		end
	end
end
function CHECK_EMPTYTABLE()
	if not HAS_TRAVELER_DOCS() and stamp ~= nil then
		local has_embargo_violation = false
		local has_wanted_violation = false
		local has_transcript_violation = false

		local day_cfg = nil
		if IS_STORY_MODE then
			day_cfg = GET_DAY_CONFIG(CURRENT_DAY)
			if day_cfg then
				if day_cfg.embargo_nation and GET_NATION_NAME(PERSON.passport) == day_cfg.embargo_nation then
					has_embargo_violation = true
				end
				if day_cfg.wanted_name and PERSON.name == day_cfg.wanted_name then
					has_wanted_violation = true
				end
				if PERSON.transcript_mismatch then
					has_transcript_violation = true
				end
			end
		end

		local is_name_cleared = (PERSON and PERSON.name_cleared and (WRONGCONST == WRONGTABLE[7] or string.find(string.lower(WRONGCONST or ""), "name") ~= nil))
		local is_photo_cleared = (PERSON and PERSON.photo_cleared and (WRONGCONST == WRONGTABLE[12] or string.find(string.lower(WRONGCONST or ""), "photo") ~= nil))
		local is_cleared_infraction = is_name_cleared or is_photo_cleared

		local is_invalid_entrant = ((WRONGCONST ~= "Nothing" and not is_cleared_infraction)) or has_embargo_violation or has_wanted_violation or has_transcript_violation

		if stamp == "YES" and not is_invalid_entrant and CheckPoint==0 then
			table.insert(PENDING_REWARDS, {
				delay = 600,
				points = IS_STORY_MODE and 5 or plusPOINTS,
				is_story = IS_STORY_MODE
			})
			if IS_STORY_MODE then
				DAY_INSPECTED_COUNT = DAY_INSPECTED_COUNT + 1
			end
		elseif stamp == "YES" and is_invalid_entrant and CheckPoint==0 then
			WRONGMANn = WRONGMANn+1
			if IS_STORY_MODE then
				DAY_MISTAKES_COUNT = DAY_MISTAKES_COUNT + 1
				DAY_INSPECTED_COUNT = DAY_INSPECTED_COUNT + 1
			end
			local reason_text = "INVALID ADMISSION"
			if has_embargo_violation then
				reason_text = "VIOLATION OF DIPLOMATIC SANCTIONS"
			elseif has_wanted_violation then
				reason_text = "WANTED FUGITIVE ADMITTED"
			elseif has_transcript_violation then
				reason_text = "ENTRY PERMIT DURATION MISMATCH"
			elseif WRONGCONST ~= "Nothing" then
				reason_text = string.upper(WRONGCONST)
			end
			local penalty_text = ""
			local penalty_pts = 0
			local penalty_time = 0
			local mistake_count = IS_STORY_MODE and DAY_MISTAKES_COUNT or WRONGMANn
			if IS_STORY_MODE then
				local max_warnings = (CURRENT_DAY and CURRENT_DAY >= 3) and 1 or 2
				if day_cfg and day_cfg.allowed_warnings ~= nil then
					max_warnings = day_cfg.allowed_warnings
				end
				if mistake_count <= max_warnings then
					penalty_text = "WARNING - NO PENALTY"
					penalty_pts = 0
				elseif mistake_count == max_warnings + 1 then
					penalty_text = "PENALTY: 5 CREDITS"
					penalty_pts = 5
				else
					penalty_text = "PENALTY: 10 CREDITS"
					penalty_pts = 10
				end
			elseif MODEselect == 1 then
				if mistake_count <= 2 then
					penalty_text = "WARNING - NO PENALTY"
					penalty_time = 0
				else
					penalty_text = "PENALTY: -20 SECONDS"
					penalty_time = 20000
				end
			elseif MODEselect == 2 then
				penalty_text = "FATAL INFRACTION - DISMISSED"
				penalty_pts = 0
			elseif MODEselect == 3 then
				if mistake_count <= 2 then
					penalty_text = "WARNING - NO PENALTY"
					penalty_pts = 0
				elseif mistake_count == 3 then
					penalty_text = "PENALTY: -5 CREDITS"
					penalty_pts = 5
				else
					penalty_text = "PENALTY: -10 CREDITS"
					penalty_pts = 10
				end
			else
				penalty_text = "WARNING - NO PENALTY"
				penalty_pts = 0
			end
			SPAWN_CITATION(reason_text, penalty_text, MODEselect, penalty_pts, penalty_time)
			if MODEselect == 2 then
				PERFECT_GAMEOVER_ACTIVE = true
				PERFECT_GAMEOVER_READY = false
				if PERFECT_TIMER == nil then
					PERFECT_TIMER = Timer.new()
				end
				Timer.reset(PERFECT_TIMER)
				Timer.pause(PERFECT_TIMER)
			end
		elseif stamp == "NO" and is_invalid_entrant and CheckPoint==0 then
			table.insert(PENDING_REWARDS, {
				delay = 600,
				points = IS_STORY_MODE and 5 or plusPOINTS,
				is_story = IS_STORY_MODE
			})
			if IS_STORY_MODE then
				DAY_INSPECTED_COUNT = DAY_INSPECTED_COUNT + 1
			end
		elseif stamp == "NO" and not is_invalid_entrant and CheckPoint==0 then
			WRONGMANn = WRONGMANn+1
			if IS_STORY_MODE then
				DAY_MISTAKES_COUNT = DAY_MISTAKES_COUNT + 1
				DAY_INSPECTED_COUNT = DAY_INSPECTED_COUNT + 1
			end
			local reason_text = "DENIAL REASON INVALID"
			local penalty_text = ""
			local penalty_pts = 0
			local penalty_time = 0
			local mistake_count = IS_STORY_MODE and DAY_MISTAKES_COUNT or WRONGMANn
			if IS_STORY_MODE then
				local max_warnings = (CURRENT_DAY and CURRENT_DAY >= 3) and 1 or 2
				if day_cfg and day_cfg.allowed_warnings ~= nil then
					max_warnings = day_cfg.allowed_warnings
				end
				if mistake_count <= max_warnings then
					penalty_text = "WARNING - NO PENALTY"
					penalty_pts = 0
				elseif mistake_count == max_warnings + 1 then
					penalty_text = "PENALTY: 5 CREDITS"
					penalty_pts = 5
				else
					penalty_text = "PENALTY: 10 CREDITS"
					penalty_pts = 10
				end
			elseif MODEselect == 1 then
				if mistake_count <= 2 then
					penalty_text = "WARNING - NO PENALTY"
					penalty_time = 0
				else
					penalty_text = "PENALTY: -20 SECONDS"
					penalty_time = 20000
				end
			elseif MODEselect == 2 then
				penalty_text = "FATAL INFRACTION - DISMISSED"
				penalty_pts = 0
			elseif MODEselect == 3 then
				if mistake_count <= 2 then
					penalty_text = "WARNING - NO PENALTY"
					penalty_pts = 0
				elseif mistake_count == 3 then
					penalty_text = "PENALTY: -5 CREDITS"
					penalty_pts = 5
				else
					penalty_text = "PENALTY: -10 CREDITS"
					penalty_pts = 10
				end
			else
				penalty_text = "WARNING - NO PENALTY"
				penalty_pts = 0
			end
			SPAWN_CITATION(reason_text, penalty_text, MODEselect, penalty_pts, penalty_time)
			if MODEselect == 2 then
				PERFECT_GAMEOVER_ACTIVE = true
				PERFECT_GAMEOVER_READY = false
				if PERFECT_TIMER == nil then
					PERFECT_TIMER = Timer.new()
				end
				Timer.reset(PERFECT_TIMER)
				Timer.pause(PERFECT_TIMER)
			end
		end
		if CheckPoint==0 then
			CheckPoint=2
			PLAY_SFX("traveler_walkout")
		end
		if stamp == "YES" and CheckPoint==2 then
			FACE.x=FACE.x + 2.5
			FACE.y=-(5*math.cos(15*(FACE.x-126)))+109
		elseif stamp == "NO" and CheckPoint==2 then
			FACE.x=FACE.x - 2.5
			FACE.y=-(5*math.cos(15*(FACE.x-126)))+109
		elseif stamp == "DETAIN" and CheckPoint==2 then
			FACE.x=FACE.x - 4.0
			FACE.y=-(5*math.cos(15*(FACE.x-126)))+109
		end
	end
end
function LOAD_CLOCK()
	local gd, gm, gy, g_date_str = GET_CURRENT_GAME_DATE()
	local d_short = string.sub(g_date_str, 1, 6) .. string.sub(g_date_str, -2)
	GPU_DrawText(358, 228, d_short, BROWN2, "l", 400, DIGITS, 5)
	if IS_STORY_MODE then
		local day_cfg = GET_DAY_CONFIG(CURRENT_DAY)
		local total_day_ms = (day_cfg and day_cfg.duration_sec or 180) * 1000
		local elapsed = Timer.getTime(GameTIME) + (DAY_TIME_OFFSET or 0)
		local frac = math.min(1, math.max(0, elapsed / total_day_ms))
		local hour_angle = (3*pi/2) + frac * (3*pi/2)
		local min_angle = frac * 9 * 2 * pi
		Graphics.drawRotateImage(322,224, clockHOUR,hour_angle,Color.new(86,62,37))
		Graphics.drawRotateImage(322,224, clockMINUTE,min_angle,Color.new(86,62,37))
		Graphics.drawRotateImage(323,225, clockHOUR,hour_angle,Color.new(66,42,28))
		Graphics.drawRotateImage(323,225, clockMINUTE,min_angle,Color.new(66,42,28))
	else
		if Timer.getTime(Clock)>1000 then
			clockInt=clockInt+pi/30
			Timer.reset(Clock)
		end
		Graphics.drawRotateImage(322,224, clockHOUR,clockInt/10,Color.new(86,62,37))
		Graphics.drawRotateImage(322,224, clockMINUTE,clockInt,Color.new(86,62,37))
		Graphics.drawRotateImage(323,225, clockHOUR,clockInt/10,Color.new(66,42,28))
		Graphics.drawRotateImage(323,225, clockMINUTE,clockInt,Color.new(66,42,28))
	end
	if CLOCK_PIN_TEX then
		Graphics.drawImage(321, 223, CLOCK_PIN_TEX)
	end
end

PREV_SHELL_OPEN = true
if Controls and Controls.shellStatus then
	PREV_SHELL_OPEN = Controls.shellStatus()
end

while true do
	-- Check if 3DS OS has requested applet termination (e.g. Home Menu exit, Power button)
	if System and System.checkStatus and System.checkStatus() == 3 then
		break
	end

	-- [CLAMSHELL SLEEP & POWER MANAGEMENT]
	-- Detect physical 3DS lid open/close transitions via PTM service
	local shell_open = true
	if Controls and Controls.shellStatus then
		shell_open = Controls.shellStatus()
	end

	if not shell_open then
		if PREV_SHELL_OPEN then
			PREV_SHELL_OPEN = false
			-- When closing the 3DS clamshell during an active shift, auto-pause
			-- so the shift clock (180s) does not advance while the console is asleep
			if menu == 2 then
				if GameTIME then Timer.pause(GameTIME) end
				if CBtime then Timer.pause(CBtime) end
				PAUSE_AUDIO()
				menu = "Pause"
			else
				PAUSE_AUDIO()
			end
		end

		-- Clamshell is closed: DO NOT poll inputs, clear screens, render, or flip framebuffers.
		-- Service APT events (sleep / wake transitions) via waitVblankStart().
		-- In code.bin, waitVblankStart() detects shell == closed and skips gspWaitForVBlank()
		-- to prevent deadlock while the display hardware is off.
		Screen.waitVblankStart()
	else
		if not PREV_SHELL_OPEN then
			PREV_SHELL_OPEN = true
			-- Guarantee hardware LCD display backlights are fully powered on upon lid reopening
			if Controls and Controls.enableScreen then
				pcall(Controls.enableScreen, 0)
				pcall(Controls.enableScreen, 1)
			end
			-- Resume audio unless left on the Pause screen
			if menu ~= "Pause" then
				RESUME_AUDIO()
			end
		end

		Screen.refresh()
		Screen.clear(TOP_SCREEN)
		Screen.clear(BOTTOM_SCREEN)
		TOUCHx,TOUCHy = Controls.readTouch()
		STICK.x,STICK.y = Controls.readCirclePad()
		pad = Controls.read()

		--OptionsOP()
		if menu==2 then
		Graphics.initBlend(BOTTOM_SCREEN)
		-- Process delayed correct inspection rewards (10s suspense delay)
		local r_idx = 1
		while r_idx <= #PENDING_REWARDS do
			local rew = PENDING_REWARDS[r_idx]
			rew.delay = rew.delay - 1
			if rew.delay <= 0 then
				SCORE = SCORE + rew.points
				LAST_PLUS_POINTS = rew.points
				PLUSy = 80
				if rew.is_story then
					DAY_CORRECT_COUNT = DAY_CORRECT_COUNT + 1
				end
				table.remove(PENDING_REWARDS, r_idx)
			else
				r_idx = r_idx + 1
			end
		end

		for k, cit in pairs(CITATIONS) do
			if cit.status == "DELAY" then
				cit.delay_frames = cit.delay_frames + 1
				if cit.delay_frames >= cit.delay_max then
					cit.status = "PRINTING"
					cit.step_feed = 8
					cit.step_pause = 0
					PLAY_SFX("printer_line")
					-- Apply mistake penalty at the exact moment citation emerges
					if cit.penalty_pts and cit.penalty_pts > 0 then
						SCORE = SCORE - cit.penalty_pts
						LAST_MINUS_POINTS = cit.penalty_pts
						MINUSy = 80
					end
					if cit.penalty_time and cit.penalty_time > 0 then
						TIMEMINUS = TIMEMINUS + cit.penalty_time
						TIMEy = 80
					end
				end
			elseif cit.status == "PRINTING" then
				if cit.step_feed > 0 then
					local move = math.min(2, cit.step_feed)
					cit.y = cit.y - move
					cit.step_feed = cit.step_feed - move
					if cit.y <= cit.target_y then
						cit.y = cit.target_y
						cit.status = "IDLE"
						if cit.is_fatal and not PERFECT_GAMEOVER_READY then
							PERFECT_GAMEOVER_READY = true
							if PERFECT_TIMER == nil then PERFECT_TIMER = Timer.new() end
							Timer.reset(PERFECT_TIMER)
							Timer.resume(PERFECT_TIMER)
						end
					end
					if cit.step_feed <= 0 and cit.status == "PRINTING" then
						cit.step_pause = 16
					end
				elseif cit.step_pause > 0 then
					cit.step_pause = cit.step_pause - 1
					if cit.step_pause <= 0 then
						if cit.y > cit.target_y then
							cit.step_feed = math.min(8, cit.y - cit.target_y)
							PLAY_SFX("printer_line")
						else
							cit.y = cit.target_y
							cit.status = "IDLE"
							if cit.is_fatal and not PERFECT_GAMEOVER_READY then
								PERFECT_GAMEOVER_READY = true
								if PERFECT_TIMER == nil then PERFECT_TIMER = Timer.new() end
								Timer.reset(PERFECT_TIMER)
								Timer.resume(PERFECT_TIMER)
							end
						end
					end
				end
			end
		end
		-- Update Identity Record mechanical print feed
		if IDENTITYRECORD and IDENTITYRECORD.status == "PRINTING" then
			if IDENTITYRECORD.y < IDENTITYRECORD.target_y then
				IDENTITYRECORD.y = IDENTITYRECORD.y + 2
			else
				IDENTITYRECORD.y = IDENTITYRECORD.target_y
				IDENTITYRECORD.status = "IDLE"
				PLAY_SFX("printer_line")
			end
		end
		if INSPECTION.active then
			if TOUCH == "ACTIVE" and TOUCHx > 0 and TOUCHy > 0 then
				-- Check inspection toggle button (x=288, y=216, w=32, h=24)
				if TOUCHx >= 284 and TOUCHx <= 320 and TOUCHy >= 212 and TOUCHy <= 240 then
					INSPECTION.active = false
					INSPECTION.selected = {}
					INSPECTION.match_found = false
					INSPECTION.match_reason = nil
					PLAY_SFX("inspect_close")
					TOUCH = "INSPECT_TOGGLE"
				-- Check interrogate button (x=95..192, y=175..205)
				elseif INSPECTION.match_found and not INSPECTION.interrogated and not INSPECTION.interrogating and TOUCHx >= 95 and TOUCHx <= 195 and TOUCHy >= 173 and TOUCHy <= 207 then
					START_INTERROGATION()
					TOUCH = "INTERROGATE_BTN"
				-- Check detain button (x=247..318, y=0..30)
				elseif INSPECTION.can_detain and TOUCHx >= 245 and TOUCHx <= 320 and TOUCHy >= 0 and TOUCHy <= 30 then
					EXECUTE_DETAIN()
					TOUCH = "DETAIN_BTN"
				-- Check scanner pad (x=75..107, y=38..62)
				elseif SCANNER and SCANNER.active and TOUCHx >= SCANNER.x and TOUCHx <= SCANNER.x + SCANNER.w and TOUCHy >= SCANNER.y and TOUCHy <= SCANNER.y + SCANNER.h then
					PLAY_SFX("button_down")
					SCANNER.active = false
					SCANNER.scanned = true
					SPAWN_FINGERPRINT_SLIP()
					TOUCH = "SCANNER_PAD"
				else
					-- Route to hotspot selection
					if INSPECTION_TOUCH(TOUCHx, TOUCHy) then
						TOUCH = "INSPECT_HOTSPOT"
					end
				end
			end
		else
			-- Normal inspection inactive: check toggle button (x=288, y=216, w=32, h=24)
			if TOUCH == "ACTIVE" and TOUCHx >= 284 and TOUCHx <= 320 and TOUCHy >= 212 and TOUCHy <= 240 then
				INSPECTION.active = true
				if STAMP.state == "OPENED" then
					STAMP.state = "CLOSED"
					STAMP.velocity = 0
				end
				PLAY_SFX("inspect_open")
				TOUCH = "INSPECT_TOGGLE"
			else
				-- Check scanner pad (x=75..107, y=38..62)
				if SCANNER and SCANNER.active and TOUCH == "ACTIVE" and TOUCHx >= SCANNER.x and TOUCHx <= SCANNER.x + SCANNER.w and TOUCHy >= SCANNER.y and TOUCHy <= SCANNER.y + SCANNER.h then
					PLAY_SFX("button_down")
					SCANNER.active = false
					SCANNER.scanned = true
					SPAWN_FINGERPRINT_SLIP()
					TOUCH = "SCANNER_PAD"
				else
					for i=1, #DESKTOP do
						if TOUCH == DESKTOP[i] then 
							table.remove(DESKTOP,i) 
							table.insert(DESKTOP,1,TOUCH)
						end
					end
					STAMP_CODE()
					for i = 1, #DESKTOP do
						local itm = ITEM_BY_KEY[DESKTOP[i]]
						if itm then TOUCH_CHECK(itm, itm.key) end
					end
				end
			end
		end
		if TOUCH~="ACTIVE" and TOUCHx==0 and TOUCHy==0 then
			TOUCH="ACTIVE"
		end
		if TOUCH=="ACTIVE" and TOUCHx>0 and TOUCHy>0 then
			TOUCH="NOTHING"
		end
		Graphics.drawPartialImage(0, 67, 0, 77, 320, 173, BKG_BTMS)
		if INSPECTION and INSPECTION.active then
			Graphics.fillRect(0, 320, 67, 240, INSPECT_DIM_DESK)
		end
		for i = #DESKTOP, 1, -1 do
			local itm = ITEM_BY_KEY[DESKTOP[i]]
			if itm and itm.now == 0 then
				LOAD_IMAGE(itm, itm.key)
				if INSPECTION and INSPECTION.active then
					DRAW_DOC_INSPECTION_HIGHLIGHT(itm.key)
				end
			end
		end
		Graphics.drawPartialImage(0, 0, 0, 0, 320, 77, BKG_BTMS)
		if SCANNER_PAD_TEX then
			if SCANNER and SCANNER.active then
				Graphics.drawPartialImage(SCANNER.x, SCANNER.y, 0, 24, SCANNER.w, SCANNER.h, SCANNER_PAD_TEX)
			else
				Graphics.drawPartialImage(SCANNER.x, SCANNER.y, 0, 0, SCANNER.w, SCANNER.h, SCANNER_PAD_TEX)
			end
		end
		for i = #DESKTOP, 1, -1 do
			local itm = ITEM_BY_KEY[DESKTOP[i]]
			if itm and itm.now == 1 then LOAD_IMAGE(itm, itm.key) end
		end
		if stamp==nil then
			Graphics.drawPartialImage(117, 0, 117, 0, 87, 8, BKG_BTMS)
		end
		Graphics.drawPartialImage(STAMP.x,STAMP.y, 0, 0, 280, 47, STMP_SPRITE)
		if STAMP.x<300 then
			Graphics.drawPartialImage(STAMP.x+40,STAMP.red, 0, 82, 75, 87, STMP_SPRITE)
			Graphics.drawPartialImage(STAMP.x+160,STAMP.green, 75, 82, 75, 87, STMP_SPRITE)
		end
		Graphics.drawPartialImage(STAMP.x,STAMP.y+47, 0, 46, 280, 36, STMP_SPRITE)
		DRAW_INSPECTION_OVERLAY()
		if FADE_ALPHA > 0 then
			Graphics.fillRect(0, 320, 0, 240, Color.new(0, 0, 0, math.floor(math.min(255, math.max(0, FADE_ALPHA)))))
		end
		screenshotmake()
		Graphics.termBlend()
		Graphics.initBlend(TOP_SCREEN)
		if IS_STORY_MODE then
			local day_cfg = GET_DAY_CONFIG(CURRENT_DAY)
			local total_day_ms = (day_cfg and day_cfg.duration_sec or 180) * 1000
			local elapsed = Timer.getTime(GameTIME) + (DAY_TIME_OFFSET or 0)
			TIME = total_day_ms - elapsed
			if TIME <= 0 then
				TIME = 0
				DAY_OVER = true
			end
			plusPOINTS = 5
		elseif MODEselect==1 then
			-- [TIMED MODE] 10 minutes countdown (600s). Each error deducts -20s via TIMEMINUS.
			TIME = 600000 - Timer.getTime(GameTIME) - TIMEMINUS
			plusPOINTS = 5
			elseif MODEselect==2 then
			-- [PERFECTION MODE] Stopwatch — time elapsed shown on HUD, game ends on first error.
			TIME = Timer.getTime(GameTIME)
			plusPOINTS = 5
			elseif MODEselect==3 then
			-- [ENDURANCE MODE] Stopwatch — starts at 30 credits, ends when SCORE < 0.
			TIME = Timer.getTime(GameTIME)
			plusPOINTS = 5
		end
		TIMEsec = TIME/1000
		TIMEmin = math.floor(TIMEsec/60)
		TIMEsec = math.floor(TIMEsec - TIMEmin*60)
		Graphics.drawImage(112,104, WALL_TXR)
		BKG_SHDW()
		LOAD_FACE(PERSON.realface)
		if CheckPoint == 1 and Controls.check(pad,KEY_A) and not Controls.check(oldpad,KEY_A) then
			if not (IS_STORY_MODE and DAY_OVER) and not PERFECT_GAMEOVER_ACTIVE and not (MODEselect == 3 and SCORE < 0) then
				PEOPLESCORE = PEOPLESCORE + 1
				PLAY_SFX("speech_announce")
				PLAY_SFX("traveler_walkin")
				RANDOMIZE()
				CheckPoint=0
			end
		end
		if (FACE.x>276 or FACE.x<-24) and stamp~=nil and CheckPoint==2 then
			CheckPoint = 1
			FACE.x = -24
			FACE.y=-(5*math.cos(15*(FACE.x-126)))+109
		end
		if FACE.x<126 and stamp==nil then
			FACE.x = FACE.x+2.5
			if FACE.x > 126 then FACE.x = 126 end
			FACE.y=-(5*math.cos(15*(FACE.x-126)))+109
			if FACE.x>120 and SWITCHER==1 then
				SWITCHER=0
			end
		end
		CHECK_EMPTYTABLE()
		UPDATE_INSPECTION()
		CAGE_MOVE()
		MAP_MOVE()
		if Options["Dialog"]==1 then
			DIALOG_SYSTEM()
		end
		Graphics.drawImage(BKG_TPSX, 0, BKG_TPS)
		if CheckPoint==1 then
			Graphics.drawPartialImage(BKG_TPSX+146,65,0,0,56,38, CHSheet)
			Graphics.drawImage(BKG_TPSX+135, 43, SB)
			GPU_DrawText(BKG_TPSX+137,46,"Press A to Call next" ,BROWN2,"l",400,SMALL_FONT,7)
			else
			Graphics.drawPartialImage(BKG_TPSX+146,65,0,38,56,38, CHSheet)
		end
		if Options["Car"]==1 then
			CARs()
			if BKG_TPSX<-120 then
				Graphics.drawImage(BKG_TPSX+525,CAR.y,CARIMAGE)
			end
		end
		
		Graphics.drawPartialImage(0, 113, 0, 0, 400, 103, BKG_MONITORS)
		Graphics.drawPartialImage(0, 103, 0, 103, 400, 137, BKG_MONITORS)
		if TRANSCRIPT.x~=nil then
			if TRANSCRIPT.now==1 then
				Graphics.drawImage(TRANSCRIPT.x+40,TRANSCRIPT.y+255, TRANSCRIPT.tex2)
			end
		end
		Graphics.drawPartialImage(52, 200, 52, 200, 46, 34, BKG_MONITORS)
		if FACE.x==126 then
			if Options["TextAlign"]==1 then
				GPU_DrawText(22,220,PERSON.weight ,BROWN2,"c",400,DIGITS,5)
				elseif Options["TextAlign"]==0 then
				GPU_DrawText(15,220,PERSON.weight ,BROWN2,"l",400,DIGITS,5)
			end
		end
		if Options["TextAlign"]==1 then
			GPU_DrawText(53,110,SCORE ,BROWN2,"c",400,SMALL_FONT,7)
			elseif Options["TextAlign"]==0 then
			GPU_DrawText(44,110,SCORE ,BROWN2,"l",400,SMALL_FONT,7)
		end
		GPU_DrawText(70,110,"+"..plusPOINTS,HUD_GREEN_TEXT,"l",400,SMALL_FONT,7)
		if Options["TextAlign"]==1 then
			if string.len(PEOPLESCORE)==1 then
				GPU_DrawText(65,215,"0"..PEOPLESCORE,BROWN3,"r",400,DIGITS,5)
				else
				GPU_DrawText(65,215,PEOPLESCORE,BROWN3,"r",400,DIGITS,5)
			end
			elseif Options["TextAlign"]==0 then
			if string.len(PEOPLESCORE)==1 then
				GPU_DrawText(83,215,"0"..PEOPLESCORE,BROWN3,"l",400,DIGITS,5)
				else
				GPU_DrawText(83,215,PEOPLESCORE,BROWN3,"l",400,DIGITS,5)
			end
		end
		if MINUSy<110 then
			MINUSy=MINUSy+0.3
			Graphics.fillRect(40,67,MINUSy-2,MINUSy+8,HUD_RED_BG)
			Graphics.fillEmptyRect(40,67,MINUSy-2,MINUSy+8,HUD_RED_BORDER)
			local m_text = "-" .. (LAST_MINUS_POINTS or 5)
			if Options["TextAlign"]==1 then
				GPU_DrawText(53,MINUSy,m_text ,HUD_RED_TEXT,"c",400,SMALL_FONT,7)
				elseif Options["TextAlign"]==0 then
				GPU_DrawText(44,MINUSy,m_text ,HUD_RED_TEXT,"l",400,SMALL_FONT,7)
			end
		end
		if PLUSy<110 then
			PLUSy=PLUSy+0.3
			Graphics.fillRect(40,67,PLUSy-2,PLUSy+8,HUD_GREEN_BG)
			Graphics.fillEmptyRect(40,67,PLUSy-2,PLUSy+8,HUD_GREEN_BORDER)
			local p_text = "+" .. (LAST_PLUS_POINTS or plusPOINTS)
			if Options["TextAlign"]==1 then
				GPU_DrawText(53,PLUSy,p_text ,HUD_GREEN_TEXT,"c",400,SMALL_FONT,7)
				elseif Options["TextAlign"]==0 then
				GPU_DrawText(44,PLUSy,p_text ,HUD_GREEN_TEXT,"l",400,SMALL_FONT,7)
			end
		end
		
		LOAD_CLOCK()
		if Options["TextAlign"]==1 then
			if string.len(TIMEmin)==1 and string.len(TIMEsec)==1 then
				GPU_DrawText(347,110,"0"..TIMEmin..":0"..TIMEsec ,BROWN2,"c",400,SMALL_FONT,7)
				elseif string.len(TIMEmin)==1 and string.len(TIMEsec)==2 then
				GPU_DrawText(347,110,"0"..TIMEmin..":"..TIMEsec ,BROWN2,"c",400,SMALL_FONT,7)
				elseif string.len(TIMEmin)>1 and string.len(TIMEsec)==2 then
				GPU_DrawText(347,110,TIMEmin..":"..TIMEsec ,BROWN2,"c",400,SMALL_FONT,7)
				elseif string.len(TIMEmin)>1 and string.len(TIMEsec)==1 then
				GPU_DrawText(347,110,TIMEmin..":0"..TIMEsec ,BROWN2,"c",400,SMALL_FONT,7)
			end
			else
			if string.len(TIMEmin)==1 and string.len(TIMEsec)==1 then
				GPU_DrawText(330,110,"0"..TIMEmin..":0"..TIMEsec ,BROWN2,"l",400,SMALL_FONT,7)
				elseif string.len(TIMEmin)==1 and string.len(TIMEsec)==2 then
				GPU_DrawText(330,110,"0"..TIMEmin..":"..TIMEsec ,BROWN2,"l",400,SMALL_FONT,7)
				elseif string.len(TIMEmin)>1 and string.len(TIMEsec)==2 then
				GPU_DrawText(330,110,TIMEmin..":"..TIMEsec ,BROWN2,"l",400,SMALL_FONT,7)
				elseif string.len(TIMEmin)>1 and string.len(TIMEsec)==1 then
				GPU_DrawText(330,110,TIMEmin..":0"..TIMEsec ,BROWN2,"l",400,SMALL_FONT,7)
			end
		end
		if TIMEy<110 then
			TIMEy=TIMEy+0.3
			Graphics.fillRect(327,369,TIMEy-2,TIMEy+8,HUD_RED_BG)
			Graphics.fillEmptyRect(327,369,TIMEy-2,TIMEy+8,HUD_RED_BORDER)
			if Options["TextAlign"]==1 then
				GPU_DrawText(347,TIMEy,"-00:20" ,HUD_RED_TEXT,"c",400,SMALL_FONT,7)
				elseif Options["TextAlign"]==0 then
				GPU_DrawText(330,TIMEy,"-00:20" ,HUD_RED_TEXT,"l",400,SMALL_FONT,7)
			end
		end
		
		--TECHMENU()
		if FADE_ALPHA > 0 then
			Graphics.fillRect(0, 400, 0, 240, Color.new(0, 0, 0, math.floor(math.min(255, math.max(0, FADE_ALPHA)))))
		end
		screenshotmake()
		Graphics.termBlend()
		if IS_STORY_MODE then
			if DAY_OVER and CheckPoint == 1 and FADE_STATE == "NONE" and not IS_CITATION_PRINTING() then
				Timer.pause(GameTIME)
				SWITCHER = 1
				FADE_STATE = "OUT_TO_SUMMARY"
				FADE_ALPHA = 0
			end
			if FADE_STATE == "OUT_TO_SUMMARY" then
				FADE_ALPHA = FADE_ALPHA + 8
				if FADE_ALPHA >= 255 then
					FADE_ALPHA = 255
					FADE_STATE = "IN_TO_SUMMARY"
					local day_cfg = GET_DAY_CONFIG(CURRENT_DAY)
					local expenses = (day_cfg and day_cfg.daily_expenses) or 20
					if DAY_EXPENSES_DEDUCTED_DAY ~= CURRENT_DAY then
						SCORE = SCORE - expenses
						DAY_SUMMARY_EXPENSES = expenses
						DAY_EXPENSES_DEDUCTED_DAY = CURRENT_DAY
					end
					menu = "DaySummary"
				end
			end
		elseif MODEselect==1 then
			if TIME < 0 then
				menu="GameOver"
				Timer.pause(GameTIME)
				TIMEmin="00"
				TIMEsec="00"
			end
			elseif MODEselect==2 then
			if WRONGMANn>0 then
				if PERFECT_GAMEOVER_ACTIVE then
					if PERFECT_GAMEOVER_READY and PERFECT_TIMER and Timer.getTime(PERFECT_TIMER) >= 2500 then
						menu="GameOver"
						Timer.pause(GameTIME)
						PERFECT_GAMEOVER_ACTIVE = false
						PERFECT_GAMEOVER_READY = false
					end
				else
					menu="GameOver"
					Timer.pause(GameTIME)
				end
			end
			elseif MODEselect==3 then
			if SCORE<0 and not IS_CITATION_PRINTING() then
				menu="GameOver"
				Timer.pause(GameTIME)
			end
		end
		if Controls.check(pad, KEY_Y) and not Controls.check(oldpad, KEY_Y) and FADE_STATE == "NONE" then
			if INSPECTION.active then
				INSPECTION.active = false
				INSPECTION.selected = {}
				INSPECTION.match_found = false
				INSPECTION.match_reason = nil
				PLAY_SFX("inspect_close")
			else
				INSPECTION.active = true
				if STAMP.state == "OPENED" then
					STAMP.state = "CLOSED"
					STAMP.velocity = 0
				end
				PLAY_SFX("inspect_open")
			end
		end

		if Controls.check(pad, KEY_X) and not Controls.check(oldpad, KEY_X) and FADE_STATE == "NONE" then
			if INSPECTION.active and (INSPECTION.can_detain or (INSPECTION.match_found and not INSPECTION.interrogated and not INSPECTION.interrogating)) then
				if INSPECTION.can_detain then
					EXECUTE_DETAIN()
				elseif INSPECTION.match_found and not INSPECTION.interrogated and not INSPECTION.interrogating then
					START_INTERROGATION()
				end
			else
				if INSPECTION.active then
					INSPECTION.active = false
					INSPECTION.selected = {}
					INSPECTION.match_found = false
					INSPECTION.match_reason = nil
					PLAY_SFX("inspect_close")
				end
				if STAMP.state == "CLOSED" then
					STAMP.state = "OPENED"
					STAMP.velocity = 23
					STAMP.gravity = 0
					PLAY_SFX("stampbar_open")
				elseif STAMP.state == "OPENED" then
					STAMP.state = "CLOSED"
					STAMP.velocity = 0
					STAMP.gravity = 0
					PLAY_SFX("stampbar_close")
				end
			end
		end

		if Controls.check(pad,KEY_START) and not Controls.check(oldpad,KEY_START) and FADE_STATE=="NONE" then
			Timer.pause(GameTIME)
			if CBtime then Timer.pause(CBtime) end
			PAUSE_AUDIO()
			menu="Pause"
		end
		elseif menu==0 then
		if NIGHTREPORT_TEX then Graphics.freeImage(NIGHTREPORT_TEX); NIGHTREPORT_TEX = nil end
		if APARTMENT_CLASS_TEX then Graphics.freeImage(APARTMENT_CLASS_TEX); APARTMENT_CLASS_TEX = nil end
		if BUDGET_CHECK_TEX then Graphics.freeImage(BUDGET_CHECK_TEX); BUDGET_CHECK_TEX = nil end
		GAMEOVER_ANIM_SCORE = nil
		Graphics.initBlend(TOP_SCREEN)
		Graphics.drawImage(0,TITLEy+265,Title)
		screenshotmake()
		Graphics.termBlend()
		Graphics.initBlend(BOTTOM_SCREEN)
		if TITLEy<-128 then
			ScreenButton(96,102,STORYMODEbutton,"DayIntro",STORYMODE)
			ScreenButton(96,135,DEMObutton,"Selection",DEMO)
			else
			ScreenButton(96,TITLEy+207,STORYMODEbutton,"DayIntro",STORYMODE)
			ScreenButton(96,TITLEy+240,DEMObutton,"Selection",DEMO)
		end
		if TITLEy<-240 then
			ScreenButton(303,0,EXITbutton,"Exit",EXIT)
			else
			ScreenButton(303,TITLEy+240,EXITbutton,"Exit",EXIT)
		end
		Graphics.drawImage(-40,TITLEy,Title)
		if TITLEy<-128 and CURRENT_SAVE then
			if CURRENT_SAVE.in_progress == 1 then
				GPU_DrawText(160, 168, "SAVED GAME AVAILABLE", Color.new(220, 200, 130), "c", 320, SMALL_FONT, 7)
				GPU_DrawText(160, 180, "DAY "..CURRENT_SAVE.day.." - IN PROGRESS", Color.new(200, 180, 110), "c", 320, SMALL_FONT, 7)
			else
				GPU_DrawText(160, 172, "STORY MODE: DAY "..CURRENT_SAVE.day, Color.new(180, 180, 180), "c", 320, SMALL_FONT, 7)
			end
			if (CURRENT_SAVE.day and CURRENT_SAVE.day > 1) or CURRENT_SAVE.in_progress == 1 then
				GPU_DrawText(160, 204, "[X] RESTART FROM DAY 1", Color.new(150, 110, 110), "c", 320, SMALL_FONT, 7)
			end
		end
		if TITLEy < -128 then
			GPU_DrawText(4, 228, "v" .. GAME_VERSION, Color.new(110, 110, 110), "l", 100, SMALL_FONT, 7)
			GPU_DrawText(316, 228, "by " .. GAME_AUTHOR, Color.new(110, 110, 110), "r", 320, SMALL_FONT, 7)
		end
		screenshotmake()
		Graphics.termBlend()
		if (TITLEy==-280 or TOUCHx>0 or TOUCHy>0) and TITLEi==0 then
			TITLEy=-280
			TITLEx=TITLEy+20
			TITLEi=1
		end
		if Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A) and TITLEy < -128 then
			STOP_BGM()
			START_STORY_MODE()
		end
		if Controls.check(pad, KEY_X) and not Controls.check(oldpad, KEY_X) and TITLEy < -128 then
			SAVE_GAME({ day = 1, in_progress = 0 })
			CURRENT_SAVE = LOAD_GAME()
			CURRENT_DAY = 1
		end
		TITLE_MOVE()
		elseif menu=="Exit" then
		TERM_AUDIO()
		if IS_STORY_MODE then
			SAVE_STORY_PROGRESS()
		end
		GarbageCollection()
		System.exit()
		elseif menu=="Selection" then
		Graphics.initBlend(TOP_SCREEN)
		Graphics.drawImage(0,TITLEy+265,Title)
		screenshotmake()
		Graphics.termBlend()
		Graphics.initBlend(BOTTOM_SCREEN)
		if TOUCHy>0 and TOUCHy<210 and TOUCHx>0 and TOUCHx<130 then
			MODEselect = math.floor((TOUCHy+70)/70)
			Graphics.fillRect(0,130,math.floor(TOUCHy/70)*70,math.floor((TOUCHy+70)/70)*70,GREEN_menu)
		end
		if TOUCHy>0 and TOUCHy<70 and TOUCHx>190 and TOUCHx<320 then
			COURSEselect = math.floor((TOUCHy+70)/70)
			Graphics.fillRect(190,320,math.floor(TOUCHy/70)*70,math.floor((TOUCHy+70)/70)*70,GREEN_menu)
		end
		if MODEselect>0 then
			Graphics.drawImage(130,35+(MODEselect-1)*70,LINEhor)
		end
		if COURSEselect>0 then
			Graphics.drawImage(160,35+(COURSEselect-1)*70,LINEhor)
		end
		if COURSEselect~=MODEselect and COURSEselect~=0 and MODEselect~=0 then
			if COURSEselect>MODEselect then
				for i=1,(COURSEselect-MODEselect) do
					Graphics.drawImage(160,35+(MODEselect-1)*70+(i-1)*70,LINEver)
				end
				elseif COURSEselect<MODEselect then
				for i=1,(MODEselect-COURSEselect) do
					Graphics.drawImage(160,35+(COURSEselect-1)*70+(i-1)*70,LINEver)
				end
			end
		end
		Graphics.drawImage(0,0,MODES)
		Graphics.drawImage(217,0,MODE1)
		GPU_DrawText(0,0,MODEselect.."."..COURSEselect,WHITE,"l",320,DIGITS,5)
		ScreenButton(0,222,BACKbutton,0,BACK)
		if MODEselect>0 and COURSEselect==1 then
			ScreenButton(191,222,STARTbutton,2,START)
		end
		screenshotmake()
		Graphics.termBlend()
		TITLE_MOVE()
		elseif menu=="Pause" then
		Graphics.initBlend(TOP_SCREEN)
		Graphics.drawImage(0,TITLEy+265,Title)
		screenshotmake()
		Graphics.termBlend()
		Graphics.initBlend(BOTTOM_SCREEN)
		GPU_DrawText(120,14,"TextAlign.....",WHITE,"l",320,SMALL_FONT,7)
		GPU_DrawText(120,29,"Shadow........",WHITE,"l",320,SMALL_FONT,7)
		GPU_DrawText(120,44,"Dialog............",WHITE,"l",320,SMALL_FONT,7)
		GPU_DrawText(120,59,"Car..................",WHITE,"l",320,SMALL_FONT,7)
		GPU_DrawText(120,74,"Sound..............",WHITE,"l",320,SMALL_FONT,7)
		CHECKBOX(180,10,"TextAlign")
		CHECKBOX(180,25,"Shadow")
		CHECKBOX(180,40,"Dialog")
		CHECKBOX(180,55,"Car")
		CHECKBOX(180,70,"Sound")
		ScreenButton(96,102,RESUMEbutton,2,RESUME)
		ScreenButton(96,132,MAINMENUbutton,0,MAINMENU)
		ScreenButton(96,162,QUITbutton,"Exit",QUIT)
		if IS_STORY_MODE then
			GPU_DrawText(160, 192, "STORY MODE: PROGRESS SAVED ON EXIT", Color.new(200, 190, 150), "c", 320, SMALL_FONT, 7)
			GPU_DrawText(160, 206, "DAY "..CURRENT_DAY.." - "..DAY_INSPECTED_COUNT.." INSPECTIONS COMPLETED", Color.new(160, 150, 120), "c", 320, SMALL_FONT, 7)
		end
		if Controls.check(pad, KEY_START) and not Controls.check(oldpad, KEY_START) then
			Timer.resume(GameTIME)
			if CBtime then Timer.resume(CBtime) end
			RESUME_AUDIO()
			menu = 2
		end
		screenshotmake()
		Graphics.termBlend()
		TITLE_MOVE()
		elseif menu=="GameOver" then
		STOP_AMBIENT()
		if NIGHTREPORT_TEX == nil then
			NIGHTREPORT_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/NightReport.png")
		end
		if MAINMENUbutton == nil then
			MAINMENUbutton = Graphics.loadImage(System.currentDirectory().."ASSETS/MAINMENUbutton.png")
		end
		if APARTMENT_CLASS_TEX == nil then
			APARTMENT_CLASS_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/ApartmentClass.png")
		end
		if BUDGET_CHECK_TEX == nil then
			BUDGET_CHECK_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/BudgetLineCheck.png")
		end

		-- [TOP SCREEN: NIGHTREPORT BANNER & TERMINATION STATUS]
		Graphics.initBlend(TOP_SCREEN)
		Graphics.fillRect(0, 400, 0, 240, Color.new(0, 0, 0))

		-- Draw authentic NightReport banner (374x29 centered at x=13, y=20)
		if NIGHTREPORT_TEX then
			Graphics.drawImage(13, 20, NIGHTREPORT_TEX)
		end

		-- Header label above plate
		GPU_DrawText(200, 18, "END OF", Color.new(140, 160, 140), "c", 400, SMALL_FONT, 7)

		-- Day number inside hexagonal plate (plate spans y=30 to y=48, centered at y=35)
		local plate_text = "DAY " .. tostring(CURRENT_DAY or 1)
		GPU_DrawText(200, 35, plate_text, Color.new(15, 25, 15), "c", 400, NORMAL_FONT, 8)

		-- Status narrative in red
		local gameover_sub = "Your account has fallen into a negative balance."
		if MODEselect == 1 then
			gameover_sub = "Shift time expired. Account in negative balance."
		elseif MODEselect == 2 then
			if WRONGCONST and WRONGCONST ~= "Nothing" then
				gameover_sub = "Fatal infraction: " .. tostring(WRONGCONST)
			else
				gameover_sub = "Fatal infraction committed. Dismissal fine assessed."
			end
		end
		GPU_DrawText(200, 68, gameover_sub, Color.new(220, 70, 70), "c", 400, SMALL_FONT, 7)

		-- Subtle atmospheric watermark (East Grestin Housing)
		if APARTMENT_CLASS_TEX then
			Graphics.drawPartialImage(188, 110, 0, 0, 24, 30, APARTMENT_CLASS_TEX)
		end
		GPU_DrawText(200, 145, "MINISTRY OF ADMISSION - CLASS-8 HOUSING", Color.new(65, 80, 65), "c", 400, SMALL_FONT, 7)
		GPU_DrawText(200, 160, "EAST GRESTIN DISTRICT", Color.new(50, 65, 50), "c", 400, SMALL_FONT, 7)

		screenshotmake()
		Graphics.termBlend()

		-- [BOTTOM SCREEN: AUTHENTIC TYPEWRITER FINANCIAL LEDGER - NEGATIVE SCORE]
		Graphics.initBlend(BOTTOM_SCREEN)
		Graphics.fillRect(0, 320, 0, 240, Color.new(0, 0, 0))

		local prev_savings = DAY_START_SCORE or 0
		local earned_salary = (DAY_CORRECT_COUNT or 0) * 5
		local exp_total = DAY_SUMMARY_EXPENSES or 20
		local rent_val = math.max(10, exp_total - 10)
		local food_val = 5
		local heat_val = 5

		-- Calculate citations / penalties ensuring the balance is strictly negative
		local final_target_score = SCORE
		local total_citations_fine = 0
		if final_target_score < 0 then
			total_citations_fine = (prev_savings + earned_salary) - (final_target_score + exp_total)
			if total_citations_fine < 0 then total_citations_fine = 0 end
		else
			total_citations_fine = (prev_savings + earned_salary) - exp_total + 15
			if total_citations_fine < 20 then total_citations_fine = 20 end
			final_target_score = (prev_savings + earned_salary) - exp_total - total_citations_fine
		end

		-- Animate score count-down into negative
		if GAMEOVER_ANIM_SCORE == nil then
			GAMEOVER_ANIM_SCORE = prev_savings + earned_salary
		end
		if GAMEOVER_ANIM_SCORE > final_target_score then
			local diff = GAMEOVER_ANIM_SCORE - final_target_score
			local step = math.max(1, math.ceil(diff / 8))
			GAMEOVER_ANIM_SCORE = GAMEOVER_ANIM_SCORE - step
		end

		local ledger_y = 32
		local row_h = 17
		local WHITE_LEDGER = Color.new(225, 225, 225)
		local RED_LEDGER = Color.new(210, 60, 60)

		-- Row 1: SAVINGS
		GPU_DrawText(35, ledger_y, "SAVINGS", WHITE_LEDGER, "l", 320, NORMAL_FONT, 8)
		GPU_DrawText(285, ledger_y, tostring(prev_savings), WHITE_LEDGER, "r", 320, NORMAL_FONT, 8)
		ledger_y = ledger_y + row_h

		-- Row 2: SALARY
		GPU_DrawText(35, ledger_y, "SALARY - " .. tostring(DAY_CORRECT_COUNT or 0), WHITE_LEDGER, "l", 320, NORMAL_FONT, 8)
		GPU_DrawText(285, ledger_y, tostring(earned_salary), WHITE_LEDGER, "r", 320, NORMAL_FONT, 8)
		ledger_y = ledger_y + row_h

		-- Row 3: CITATIONS / PENALTIES (in red)
		if total_citations_fine > 0 then
			local cit_label = (DAY_MISTAKES_COUNT and DAY_MISTAKES_COUNT > 0) and ("CITATIONS - " .. tostring(DAY_MISTAKES_COUNT)) or "PENALTIES"
			GPU_DrawText(35, ledger_y, cit_label, RED_LEDGER, "l", 320, NORMAL_FONT, 8)
			GPU_DrawText(285, ledger_y, "-" .. tostring(total_citations_fine), RED_LEDGER, "r", 320, NORMAL_FONT, 8)
			ledger_y = ledger_y + row_h
		end

		-- Row 4: RENT
		GPU_DrawText(35, ledger_y, "RENT", RED_LEDGER, "l", 320, NORMAL_FONT, 8)
		GPU_DrawText(285, ledger_y, "-" .. tostring(rent_val), RED_LEDGER, "r", 320, NORMAL_FONT, 8)
		ledger_y = ledger_y + row_h

		-- Row 5: FOOD
		GPU_DrawText(35, ledger_y, "FOOD", RED_LEDGER, "l", 320, NORMAL_FONT, 8)
		GPU_DrawText(268, ledger_y, "-" .. tostring(food_val), RED_LEDGER, "r", 320, NORMAL_FONT, 8)
		if BUDGET_CHECK_TEX then
			Graphics.drawPartialImage(274, ledger_y - 2, 0, 0, 12, 12, BUDGET_CHECK_TEX)
		else
			Graphics.fillEmptyRect(276, 284, ledger_y, ledger_y + 8, RED_LEDGER)
			Graphics.fillRect(279, 281, ledger_y + 3, ledger_y + 5, RED_LEDGER)
		end
		ledger_y = ledger_y + row_h

		-- Row 6: HEAT
		GPU_DrawText(35, ledger_y, "HEAT", RED_LEDGER, "l", 320, NORMAL_FONT, 8)
		GPU_DrawText(268, ledger_y, "-" .. tostring(heat_val), RED_LEDGER, "r", 320, NORMAL_FONT, 8)
		if BUDGET_CHECK_TEX then
			Graphics.drawPartialImage(274, ledger_y - 2, 0, 0, 12, 12, BUDGET_CHECK_TEX)
		else
			Graphics.fillEmptyRect(276, 284, ledger_y, ledger_y + 8, RED_LEDGER)
			Graphics.fillRect(279, 281, ledger_y + 3, ledger_y + 5, RED_LEDGER)
		end
		ledger_y = ledger_y + 13

		-- Dotted divider line
		for lx = 35, 285, 4 do
			Graphics.fillRect(lx, lx + 2, ledger_y, ledger_y + 1, Color.new(100, 100, 100))
		end
		ledger_y = ledger_y + 7

		-- Total / Balance: Animated into negative
		local total_color = (GAMEOVER_ANIM_SCORE < 0) and RED_LEDGER or WHITE_LEDGER
		local total_str = tostring(GAMEOVER_ANIM_SCORE) .. " CREDITS"
		if GAMEOVER_ANIM_SCORE < 0 then
			total_str = "-" .. tostring(math.abs(GAMEOVER_ANIM_SCORE)) .. " CREDITS"
		end
		GPU_DrawText(285, ledger_y, total_str, total_color, "r", 320, NORMAL_FONT, 8)

		-- ONLY MAIN MENU BUTTON on bottom right (129x19 at 176, 206)
		GAMEOVER_MENU_BTN = GAMEOVER_MENU_BTN or {touched = false}
		if TOUCHx > 0 and TOUCHy > 0 then
			if FADE_STATE == "NONE" and TOUCHx >= 176 and TOUCHx <= 305 and TOUCHy >= 200 and TOUCHy <= 235 then
				GAMEOVER_MENU_BTN.touched = true
			else
				GAMEOVER_MENU_BTN.touched = false
			end
		end
		if GAMEOVER_MENU_BTN.touched and TOUCHx > 0 and TOUCHy > 0 then
			Graphics.drawPartialImage(176, 206, 0, 19, 129, 19, MAINMENUbutton)
		else
			Graphics.drawPartialImage(176, 206, 0, 0, 129, 19, MAINMENUbutton)
		end

		-- Trigger return to main menu
		if FADE_STATE == "NONE" and ((TOUCHx == 0 and TOUCHy == 0 and GAMEOVER_MENU_BTN.touched) or (Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A)) or (Controls.check(pad, KEY_B) and not Controls.check(oldpad, KEY_B))) then
			GAMEOVER_MENU_BTN.touched = false
			GAMEOVER_ANIM_SCORE = nil
			if NIGHTREPORT_TEX then Graphics.freeImage(NIGHTREPORT_TEX); NIGHTREPORT_TEX = nil end
			if APARTMENT_CLASS_TEX then Graphics.freeImage(APARTMENT_CLASS_TEX); APARTMENT_CLASS_TEX = nil end
			if BUDGET_CHECK_TEX then Graphics.freeImage(BUDGET_CHECK_TEX); BUDGET_CHECK_TEX = nil end
			CLEAR_CITATIONS()
			STOP_BGM()
			menu = 0
		end

		screenshotmake()
		Graphics.termBlend()
		elseif menu=="DayIntro" then
		local day_cfg = GET_DAY_CONFIG(CURRENT_DAY)

		-- [LAZY-LOAD AUTHENTIC BULLETIN & NEWSPAPER TEXTURES]
		if BULLETIN_BTM_TEX == nil then
			BULLETIN_BTM_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/BKG_BULLETIN_BTM.png")
		end
		if NEWS_TEX == nil then
			NEWS_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/News.png")
			if NEWS_TEX == nil then
				NEWS_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/BKG_BULLETIN_TOP.png")
			end
		end
		if NEWS_EZIC_TEX == nil and (CURRENT_DAY or 1) >= 4 then
			NEWS_EZIC_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/NewsEzicStamp.png")
		end

		-- [TOP SCREEN: AUTHENTIC NEWSPAPER - THE TRUTH OF ARSTOTZKA]
		Graphics.initBlend(TOP_SCREEN)
		-- Vintage dark desk border around newspaper
		Graphics.fillRect(0, 400, 0, 240, Color.new(24, 22, 21))
		
		local news_x = 17
		local news_y = 10
		
		-- Shadow behind newspaper
		Graphics.fillRect(news_x + 3, 365, news_y + 3, 220, Color.new(14, 12, 11))
		
		if NEWS_TEX then
			Graphics.drawImage(news_x, news_y, NEWS_TEX)
		else
			Graphics.fillRect(news_x, 365, news_y, 220, Color.new(203, 202, 187))
			Graphics.fillEmptyRect(news_x, 365, news_y, 220, Color.new(96, 95, 88))
		end
		if NEWS_EZIC_TEX and (CURRENT_DAY or 1) >= 4 then
			Graphics.drawImage(news_x + 300, news_y + 155, NEWS_EZIC_TEX)
		end
		screenshotmake()
		Graphics.termBlend()

		-- [BOTTOM SCREEN: MINISTRY OF ADMISSION OFFICIAL BULLETIN]
		Graphics.initBlend(BOTTOM_SCREEN)
		if BULLETIN_BTM_TEX then
			Graphics.drawImage(0, 0, BULLETIN_BTM_TEX)
		else
			Graphics.fillRect(0, 320, 0, 240, Color.new(24, 22, 21))
			-- Paper document background with double border matching News.png palette
			Graphics.fillRect(8, 304, 6, 226, Color.new(203, 202, 187))
			Graphics.fillEmptyRect(8, 304, 6, 226, Color.new(96, 95, 88))
			-- Crimson header banner
			Graphics.fillRect(20, 298, 17, 46, Color.new(82, 34, 34))
		end
		
		GPU_DrawText(160, 20, "MINISTRY OF ADMISSION", Color.new(239, 237, 220), "c", 320, NORMAL_FONT, 8)
		GPU_DrawText(160, 34, "OFFICIAL DIRECTIVE - DAY "..CURRENT_DAY.." - "..day_cfg.date, Color.new(239, 237, 220), "c", 320, SMALL_FONT, 7)
		
		-- Subheader
		GPU_DrawText(24, 48, "ARSTOTZKA BORDER CONTROL - GRESTIN CHECKPOINT", Color.new(96, 95, 88), "l", 320, SMALL_FONT, 7)
		if BULLETIN_BTM_TEX == nil then
			Graphics.fillRect(24, 296, 56, 58, Color.new(167, 165, 154))
		end
		
		-- Directives / Rules (as present in day_cfg.bulletin_rules)
		local rule_y = 65
		local num_brules = (day_cfg and day_cfg.bulletin_rules and #day_cfg.bulletin_rules) or 0
		local rule_step = (num_brules >= 5) and 14 or 18
		for idx, rule in ipairs(day_cfg.bulletin_rules) do
			if BULLETIN_BTM_TEX == nil then
				Graphics.fillRect(22, 25, rule_y + 1, rule_y + 5, Color.new(82, 34, 34))
			end
			local rule_col = Color.new(96, 95, 88)
			if string.find(rule, "DENY ALL") or string.find(rule, "WANTED") then
				rule_col = Color.new(140, 35, 35)
			end
			GPU_DrawText(28, rule_y, rule, rule_col, "l", 320, SMALL_FONT, 7)
			rule_y = rule_y + rule_step
		end
		
		-- Shift info line
		if BULLETIN_BTM_TEX == nil then
			Graphics.fillRect(24, 296, 150, 152, Color.new(167, 165, 154))
		end
		GPU_DrawText(160, 150, "SHIFT: 09:00 - 18:00  |  PENALTIES FOR CITATIONS", Color.new(115, 110, 102), "c", 320, SMALL_FONT, 7)
		
		-- Custom Checkpoint Button (ASSETS/CHECKPOINTbutton.png)
		if OPENCHECKPOINT_TEX == nil and not OPENCHECKPOINT_TRIED then
			OPENCHECKPOINT_TRIED = true
			local btn_path = System.currentDirectory().."ASSETS/CHECKPOINTbutton.png"
			local exists = false
			if System and System.doesFileExist then
				exists = System.doesFileExist(btn_path)
			end
			if not exists then
				btn_path = System.currentDirectory().."ASSETS/OPENCHECKPOINTbutton.png"
				if System and System.doesFileExist then
					exists = System.doesFileExist(btn_path)
				end
			end
			if exists then
				pcall(function()
					OPENCHECKPOINT_TEX = Graphics.loadImage(btn_path)
				end)
			end
		end

		local btn_w = 129
		local btn_h = 19
		local btn_x = 95
		local btn_y = 175

		if OPENCHECKPOINT_TEX then
			btn_w = Graphics.getImageWidth(OPENCHECKPOINT_TEX)
			btn_h = math.floor(Graphics.getImageHeight(OPENCHECKPOINT_TEX) / 2)
			btn_x = math.floor((320 - btn_w) / 2)
		end

		DAY_INTRO_BTN = DAY_INTRO_BTN or {touched = false}
		if TOUCHx>0 and TOUCHy>0 then
			if TOUCHx>=btn_x and TOUCHx<=btn_x+btn_w and TOUCHy>=btn_y and TOUCHy<=btn_y+btn_h then
				DAY_INTRO_BTN.touched = true
			else
				DAY_INTRO_BTN.touched = false
			end
		end

		if OPENCHECKPOINT_TEX then
			if DAY_INTRO_BTN.touched and TOUCHx>0 and TOUCHy>0 then
				Graphics.drawPartialImage(btn_x, btn_y, 0, btn_h, btn_w, btn_h, OPENCHECKPOINT_TEX)
			else
				Graphics.drawPartialImage(btn_x, btn_y, 0, 0, btn_w, btn_h, OPENCHECKPOINT_TEX)
			end
			GPU_DrawText(160, 198, "PRESS (A) OR TAP TO OPEN", Color.new(115, 110, 102), "c", 320, SMALL_FONT, 7)
		else
			local btn_text_col = Color.new(96, 95, 88)
			if DAY_INTRO_BTN.touched and TOUCHx>0 and TOUCHy>0 then
				btn_text_col = Color.new(140, 35, 35)
			end
			GPU_DrawText(160, 182, "[ OPEN CHECKPOINT (A) ]", btn_text_col, "c", 320, NORMAL_FONT, 8)
		end
		
		GPU_DrawText(160, 218, "PRESS (B) FOR MENU", Color.new(115, 110, 102), "c", 320, SMALL_FONT, 7)
		
		if (TOUCHx==0 and TOUCHy==0 and DAY_INTRO_BTN.touched) or (Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A)) then
			DAY_INTRO_BTN.touched = false
			if NEWS_TEX then
				Graphics.freeImage(NEWS_TEX)
				NEWS_TEX = nil
				NEWS_TEX_DAY = nil
			end
			if NEWS_EZIC_TEX then
				Graphics.freeImage(NEWS_EZIC_TEX)
				NEWS_EZIC_TEX = nil
			end
			if BULLETIN_BTM_TEX then
				Graphics.freeImage(BULLETIN_BTM_TEX)
				BULLETIN_BTM_TEX = nil
			end
			if OPENCHECKPOINT_TEX then
				Graphics.freeImage(OPENCHECKPOINT_TEX)
				OPENCHECKPOINT_TEX = nil
			end
			OPENCHECKPOINT_TRIED = nil
			if BKG_BTMS==nil then
				loadtex()
			end
			Timer.reset(GameTIME)
			Timer.resume(GameTIME)
			Timer.reset(Clock)
			if CBtime then
				Timer.reset(CBtime)
				Timer.resume(CBtime)
			end
			clockInt = 0
			DAY_OVER = false
			CLEAR_CITATIONS()
			DAY_INSPECTED_COUNT = 0
			DAY_CORRECT_COUNT = 0
			DAY_MISTAKES_COUNT = 0
			DAY_TIME_OFFSET = 0
			DAY_START_SCORE = DAY_START_SCORE or SCORE
			FADE_STATE = "NONE"
			FADE_ALPHA = 0
			PEOPLESCORE = 0
			CheckPoint = 1
			stamp = "YES"
			if FACE then
				FACE.x = -24
				FACE.y = 104
			end
			SWITCHER = 1
			for i=1,#DESKTOP do table.remove(DESKTOP,1) end
			for i=1,#ALLITEMS do table.remove(ALLITEMS,1) end
			CLEAR_CHAT()
			table.insert(DESKTOP,1,"TRANSCRIPT")
			table.insert(ALLITEMS,1,TRANSCRIPT)
			table.insert(DESKTOP,1,"RULEBOOK")
			table.insert(ALLITEMS,1,RULEBOOK)
			table.insert(DESKTOP,1,"BULLETIN")
			table.insert(ALLITEMS,1,BULLETIN)
			RULEBOOK.x = 5
			RULEBOOK.y = 23
			RULEBOOK.now = 1
			BULLETIN.x = 34
			BULLETIN.y = 23
			BULLETIN.now = 1
			STOP_BGM()
			STOP_AMBIENT()
			PLAY_SFX("booth_intro")
			menu = 2
		end
		if Controls.check(pad, KEY_B) and not Controls.check(oldpad, KEY_B) then
			if NEWS_TEX then
				Graphics.freeImage(NEWS_TEX)
				NEWS_TEX = nil
				NEWS_TEX_DAY = nil
			end
			if NEWS_EZIC_TEX then
				Graphics.freeImage(NEWS_EZIC_TEX)
				NEWS_EZIC_TEX = nil
			end
			if BULLETIN_BTM_TEX then
				Graphics.freeImage(BULLETIN_BTM_TEX)
				BULLETIN_BTM_TEX = nil
			end
			if OPENCHECKPOINT_TEX then
				Graphics.freeImage(OPENCHECKPOINT_TEX)
				OPENCHECKPOINT_TEX = nil
			end
			OPENCHECKPOINT_TRIED = nil
			CLEAR_CITATIONS()
			IS_STORY_MODE = false
			STOP_AMBIENT()
			STOP_BGM()
			menu = 0
		end
		screenshotmake()
		Graphics.termBlend()
		elseif menu=="DaySummary" then
		STOP_AMBIENT()
		-- Lazy load authentic NightReport & Button assets
		if NIGHTREPORT_TEX == nil then
			NIGHTREPORT_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/NightReport.png")
		end
		if MAINMENUbutton == nil then
			MAINMENUbutton = Graphics.loadImage(System.currentDirectory().."ASSETS/MAINMENUbutton.png")
		end
		if SCORE >= 0 and SLEEPbutton == nil then
			SLEEPbutton = Graphics.loadImage(System.currentDirectory().."ASSETS/SLEEPbutton.png")
		end
		if APARTMENT_CLASS_TEX == nil then
			APARTMENT_CLASS_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/ApartmentClass.png")
		end
		if BUDGET_CHECK_TEX == nil then
			BUDGET_CHECK_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/BudgetLineCheck.png")
		end
		if DAYSUMMARY_BKG_TEX then Graphics.freeImage(DAYSUMMARY_BKG_TEX); DAYSUMMARY_BKG_TEX = nil end
		if DAYSUMMARY_TOP_TEX then Graphics.freeImage(DAYSUMMARY_TOP_TEX); DAYSUMMARY_TOP_TEX = nil end

		-- [TOP SCREEN: AUTHENTIC PAPERS, PLEASE NIGHTREPORT HEADER & APARTMENT NARRATIVE]
		Graphics.initBlend(TOP_SCREEN)
		Graphics.fillRect(0, 400, 0, 240, Color.new(0, 0, 0))
		
		-- Draw authentic NightReport banner (374x29 centered at x=13, y=20)
		if NIGHTREPORT_TEX then
			Graphics.drawImage(13, 20, NIGHTREPORT_TEX)
		end
		
		-- Header label above plate
		GPU_DrawText(200, 18, "END OF", Color.new(140, 160, 140), "c", 400, SMALL_FONT, 7)
		
		-- Day number inside hexagonal plate (plate spans y=30 to y=48, centered at y=35)
		GPU_DrawText(200, 35, "DAY " .. tostring(CURRENT_DAY or 1), Color.new(15, 25, 15), "c", 400, NORMAL_FONT, 8)
		
		-- Status narrative line at y=68
		if SCORE < 0 then
			-- Debt game over narrative in red
			GPU_DrawText(200, 68, "Your account has fallen into a negative balance.", Color.new(220, 70, 70), "c", 400, SMALL_FONT, 7)
		else
			-- Narrative family status
			local family_status_msg = "Your family is in good health."
			if CURRENT_DAY == 1 then
				family_status_msg = "The class-8 apartment in East Grestin is sparse."
			elseif CURRENT_DAY == 2 then
				family_status_msg = "Your family is in good health."
			elseif CURRENT_DAY == 3 then
				family_status_msg = "The temperature is dropping. Heating is required."
			elseif CURRENT_DAY == 4 then
				family_status_msg = "Your son is resting. The family is quiet."
			else
				local family_msgs = {
					"Your family is in good health.",
					"Your wife thanks you for the food.",
					"Your son asks about the border checkpoint.",
					"The neighborhood in East Grestin remains quiet.",
					"Your uncle complains about the cold weather."
				}
				local msg_idx = ((CURRENT_DAY * 3 + 7) % #family_msgs) + 1
				family_status_msg = family_msgs[msg_idx]
			end
			GPU_DrawText(200, 68, family_status_msg, Color.new(220, 220, 220), "c", 400, SMALL_FONT, 7)
		end
		
		-- Subtle atmospheric watermark (East Grestin Housing)
		if APARTMENT_CLASS_TEX then
			Graphics.drawPartialImage(188, 110, 0, 0, 24, 30, APARTMENT_CLASS_TEX)
		end
		GPU_DrawText(200, 145, "MINISTRY OF ADMISSION - CLASS-8 HOUSING", Color.new(65, 80, 65), "c", 400, SMALL_FONT, 7)
		GPU_DrawText(200, 160, "EAST GRESTIN DISTRICT", Color.new(50, 65, 50), "c", 400, SMALL_FONT, 7)
		
		if FADE_ALPHA > 0 then
			Graphics.fillRect(0, 400, 0, 240, Color.new(0, 0, 0, math.floor(math.min(255, math.max(0, FADE_ALPHA)))))
		end
		screenshotmake()
		Graphics.termBlend()
		
		-- [BOTTOM SCREEN: AUTHENTIC TYPEWRITER FINANCIAL LEDGER]
		Graphics.initBlend(BOTTOM_SCREEN)
		Graphics.fillRect(0, 320, 0, 240, Color.new(0, 0, 0))
		
		local exp_total = DAY_SUMMARY_EXPENSES or 20
		local rent_val = math.max(10, exp_total - 10)
		local food_val = 5
		local heat_val = 5
		
		local prev_savings = DAY_START_SCORE or 0
		local earned_salary = (DAY_CORRECT_COUNT or 0) * 5
		local total_citations_fine = (prev_savings + earned_salary) - (SCORE + exp_total)
		if total_citations_fine < 0 then total_citations_fine = 0 end
		
		-- Animate score count-down into negative if in debt
		if SCORE < 0 then
			if DAYSUMMARY_ANIM_SCORE == nil then
				DAYSUMMARY_ANIM_SCORE = prev_savings + earned_salary
			end
			if DAYSUMMARY_ANIM_SCORE > SCORE then
				local diff = DAYSUMMARY_ANIM_SCORE - SCORE
				local step = math.max(1, math.ceil(diff / 8))
				DAYSUMMARY_ANIM_SCORE = DAYSUMMARY_ANIM_SCORE - step
			end
		else
			DAYSUMMARY_ANIM_SCORE = nil
		end
		
		local ledger_y = 32
		local row_h = 17
		local RED_LEDGER = Color.new(210, 60, 60)
		local WHITE_LEDGER = Color.new(225, 225, 225)
		
		-- Row 1: SAVINGS
		GPU_DrawText(35, ledger_y, "SAVINGS", WHITE_LEDGER, "l", 320, NORMAL_FONT, 8)
		GPU_DrawText(285, ledger_y, tostring(prev_savings), WHITE_LEDGER, "r", 320, NORMAL_FONT, 8)
		ledger_y = ledger_y + row_h
		
		-- Row 2: SALARY
		GPU_DrawText(35, ledger_y, "SALARY - " .. tostring(DAY_CORRECT_COUNT or 0), WHITE_LEDGER, "l", 320, NORMAL_FONT, 8)
		GPU_DrawText(285, ledger_y, tostring(earned_salary), WHITE_LEDGER, "r", 320, NORMAL_FONT, 8)
		ledger_y = ledger_y + row_h
		
		-- Row 3: CITATIONS (if any infractions committed)
		if (DAY_MISTAKES_COUNT or 0) > 0 and total_citations_fine > 0 then
			GPU_DrawText(35, ledger_y, "CITATIONS - " .. tostring(DAY_MISTAKES_COUNT), RED_LEDGER, "l", 320, NORMAL_FONT, 8)
			GPU_DrawText(285, ledger_y, "-" .. tostring(total_citations_fine), RED_LEDGER, "r", 320, NORMAL_FONT, 8)
			ledger_y = ledger_y + row_h
		end
		
		-- Row 4: RENT
		GPU_DrawText(35, ledger_y, "RENT", RED_LEDGER, "l", 320, NORMAL_FONT, 8)
		GPU_DrawText(285, ledger_y, "-" .. tostring(rent_val), RED_LEDGER, "r", 320, NORMAL_FONT, 8)
		ledger_y = ledger_y + row_h
		
		-- Row 5: FOOD
		GPU_DrawText(35, ledger_y, "FOOD", RED_LEDGER, "l", 320, NORMAL_FONT, 8)
		GPU_DrawText(268, ledger_y, "-" .. tostring(food_val), RED_LEDGER, "r", 320, NORMAL_FONT, 8)
		if BUDGET_CHECK_TEX then
			Graphics.drawPartialImage(274, ledger_y - 2, 0, 0, 12, 12, BUDGET_CHECK_TEX)
		else
			Graphics.fillEmptyRect(276, 284, ledger_y, ledger_y + 8, RED_LEDGER)
			Graphics.fillRect(279, 281, ledger_y + 3, ledger_y + 5, RED_LEDGER)
		end
		ledger_y = ledger_y + row_h
		
		-- Row 6: HEAT
		GPU_DrawText(35, ledger_y, "HEAT", RED_LEDGER, "l", 320, NORMAL_FONT, 8)
		GPU_DrawText(268, ledger_y, "-" .. tostring(heat_val), RED_LEDGER, "r", 320, NORMAL_FONT, 8)
		if BUDGET_CHECK_TEX then
			Graphics.drawPartialImage(274, ledger_y - 2, 0, 0, 12, 12, BUDGET_CHECK_TEX)
		else
			Graphics.fillEmptyRect(276, 284, ledger_y, ledger_y + 8, RED_LEDGER)
			Graphics.fillRect(279, 281, ledger_y + 3, ledger_y + 5, RED_LEDGER)
		end
		ledger_y = ledger_y + 13
		
		-- Dotted divider line
		for lx = 35, 285, 4 do
			Graphics.fillRect(lx, lx + 2, ledger_y, ledger_y + 1, Color.new(100, 100, 100))
		end
		ledger_y = ledger_y + 7
		
		-- Total / Balance
		local disp_score = (SCORE < 0 and DAYSUMMARY_ANIM_SCORE) and DAYSUMMARY_ANIM_SCORE or SCORE
		local total_color = (disp_score < 0) and RED_LEDGER or WHITE_LEDGER
		local total_str = tostring(disp_score) .. " CREDITS"
		if disp_score < 0 then
			total_str = "-" .. tostring(math.abs(disp_score)) .. " CREDITS"
		end
		GPU_DrawText(285, ledger_y, total_str, total_color, "r", 320, NORMAL_FONT, 8)
		
		DAY_MENU_BTN = DAY_MENU_BTN or {touched = false}
		DAY_SLEEP_BTN = DAY_SLEEP_BTN or {touched = false}
		
		if SCORE < 0 then
			-- [DEBT GAME OVER]: ONLY MAIN MENU BUTTON on bottom-right (176, 206)
			if TOUCHx > 0 and TOUCHy > 0 then
				if FADE_STATE == "NONE" and TOUCHx >= 176 and TOUCHx <= 305 and TOUCHy >= 200 and TOUCHy <= 235 then
					DAY_MENU_BTN.touched = true
				else
					DAY_MENU_BTN.touched = false
				end
			end
			if DAY_MENU_BTN.touched and TOUCHx > 0 and TOUCHy > 0 then
				Graphics.drawPartialImage(176, 206, 0, 19, 129, 19, MAINMENUbutton)
			else
				Graphics.drawPartialImage(176, 206, 0, 0, 129, 19, MAINMENUbutton)
			end
			
			-- Trigger return to main menu / reset save state (Debt Game Over)
			if FADE_STATE == "NONE" and ((TOUCHx == 0 and TOUCHy == 0 and DAY_MENU_BTN.touched) or (Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A)) or (Controls.check(pad, KEY_B) and not Controls.check(oldpad, KEY_B))) then
				DAY_MENU_BTN.touched = false
				DAYSUMMARY_ANIM_SCORE = nil
				if NIGHTREPORT_TEX then Graphics.freeImage(NIGHTREPORT_TEX); NIGHTREPORT_TEX = nil end
				if APARTMENT_CLASS_TEX then Graphics.freeImage(APARTMENT_CLASS_TEX); APARTMENT_CLASS_TEX = nil end
				if BUDGET_CHECK_TEX then Graphics.freeImage(BUDGET_CHECK_TEX); BUDGET_CHECK_TEX = nil end
				CLEAR_CITATIONS()
				DAY_EXPENSES_DEDUCTED_DAY = nil
				DAY_SUMMARY_EXPENSES = nil
				-- Reset Nintendo save memory / progress upon insolvency dismissal
				SAVE_GAME({
					day = 1,
					in_progress = 0,
					elapsed = 0,
					inspected = 0,
					correct = 0,
					mistakes = 0,
					score = 0,
					wrongmann = 0,
					peoplescore = 0
				})
				CURRENT_SAVE = LOAD_GAME()
				CURRENT_DAY = 1
				DAY_START_SCORE = 0
				SCORE = 0
				DAY_INSPECTED_COUNT = 0
				DAY_CORRECT_COUNT = 0
				DAY_MISTAKES_COUNT = 0
				DAY_TIME_OFFSET = 0
				WRONGMANn = 0
				PEOPLESCORE = 0
				IS_STORY_MODE = false
				FADE_STATE = "NONE"
				FADE_ALPHA = 0
				STOP_BGM()
				menu = 0
			end
		else
			-- [NORMAL SUMMARY]: MAIN MENU on bottom-left (15, 206) & SLEEP on bottom-right (176, 206)
			if TOUCHx > 0 and TOUCHy > 0 then
				if FADE_STATE == "NONE" and TOUCHx >= 15 and TOUCHx <= 144 and TOUCHy >= 200 and TOUCHy <= 235 then
					DAY_MENU_BTN.touched = true
				else
					DAY_MENU_BTN.touched = false
				end
			end
			if DAY_MENU_BTN.touched and TOUCHx > 0 and TOUCHy > 0 then
				Graphics.drawPartialImage(15, 206, 0, 19, 129, 19, MAINMENUbutton)
			else
				Graphics.drawPartialImage(15, 206, 0, 0, 129, 19, MAINMENUbutton)
			end

			if TOUCHx > 0 and TOUCHy > 0 then
				if FADE_STATE == "NONE" and TOUCHx >= 176 and TOUCHx <= 305 and TOUCHy >= 200 and TOUCHy <= 235 then
					DAY_SLEEP_BTN.touched = true
				else
					DAY_SLEEP_BTN.touched = false
				end
			end
			if DAY_SLEEP_BTN.touched and TOUCHx > 0 and TOUCHy > 0 then
				Graphics.drawPartialImage(176, 206, 0, 19, 129, 19, SLEEPbutton)
			else
				Graphics.drawPartialImage(176, 206, 0, 0, 129, 19, SLEEPbutton)
			end
			
			-- Trigger SLEEP -> Next Day
			if FADE_STATE == "NONE" and ((TOUCHx == 0 and TOUCHy == 0 and DAY_SLEEP_BTN.touched) or (Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A))) then
				DAY_SLEEP_BTN.touched = false
				DAYSUMMARY_ANIM_SCORE = nil
				if NIGHTREPORT_TEX then Graphics.freeImage(NIGHTREPORT_TEX); NIGHTREPORT_TEX = nil end
				if APARTMENT_CLASS_TEX then Graphics.freeImage(APARTMENT_CLASS_TEX); APARTMENT_CLASS_TEX = nil end
				if BUDGET_CHECK_TEX then Graphics.freeImage(BUDGET_CHECK_TEX); BUDGET_CHECK_TEX = nil end
				CLEAR_CITATIONS()
				CURRENT_DAY = CURRENT_DAY + 1
				DAY_START_SCORE = SCORE
				DAY_EXPENSES_DEDUCTED_DAY = nil
				DAY_SUMMARY_EXPENSES = nil
				DAY_INSPECTED_COUNT = 0
				DAY_CORRECT_COUNT = 0
				DAY_MISTAKES_COUNT = 0
				DAY_TIME_OFFSET = 0
				WRONGMANn = 0
				PEOPLESCORE = 0
				SAVE_GAME({
					day = CURRENT_DAY,
					in_progress = 0,
					score = SCORE
				})
				FADE_STATE = "NONE"
				FADE_ALPHA = 0
				menu = "DayIntro"
			end
			
			-- Trigger MENU -> Save and Quit to Title
			if FADE_STATE == "NONE" and ((TOUCHx == 0 and TOUCHy == 0 and DAY_MENU_BTN.touched) or (Controls.check(pad, KEY_B) and not Controls.check(oldpad, KEY_B))) then
				DAY_MENU_BTN.touched = false
				DAYSUMMARY_ANIM_SCORE = nil
				if NIGHTREPORT_TEX then Graphics.freeImage(NIGHTREPORT_TEX); NIGHTREPORT_TEX = nil end
				if APARTMENT_CLASS_TEX then Graphics.freeImage(APARTMENT_CLASS_TEX); APARTMENT_CLASS_TEX = nil end
				if BUDGET_CHECK_TEX then Graphics.freeImage(BUDGET_CHECK_TEX); BUDGET_CHECK_TEX = nil end
				local next_day = CURRENT_DAY + 1
				DAY_START_SCORE = SCORE
				DAY_EXPENSES_DEDUCTED_DAY = nil
				DAY_SUMMARY_EXPENSES = nil
				SAVE_GAME({
					day = next_day,
					in_progress = 0,
					score = SCORE
				})
				CURRENT_DAY = next_day
				DAY_TIME_OFFSET = 0
				CLEAR_CITATIONS()
				IS_STORY_MODE = false
				FADE_STATE = "NONE"
				FADE_ALPHA = 0
				STOP_BGM()
				menu = 0
			end
		end
		
		if FADE_ALPHA > 0 then
			Graphics.fillRect(0, 320, 0, 240, Color.new(0, 0, 0, math.floor(math.min(255, math.max(0, FADE_ALPHA)))))
		end
		if FADE_STATE == "IN_TO_SUMMARY" then
			FADE_ALPHA = FADE_ALPHA - 8
			if FADE_ALPHA <= 0 then
				FADE_ALPHA = 0
				FADE_STATE = "NONE"
			end
		end
		screenshotmake()
		Graphics.termBlend()
	end
	if Controls.check(pad,KEY_L) and activatescreenshot==0 and not Controls.check(oldpad,KEY_L)  then
		Th,Tm,Ts = System.getTime()
		System.takeScreenshot("/PapersPlease-"..Th.."-"..Tm.."-"..Ts..".bmp",false)
		activatescreenshot=255
	end
		Screen.flip()
		Screen.waitVblankStart()
		oldpad = pad
	end
end
