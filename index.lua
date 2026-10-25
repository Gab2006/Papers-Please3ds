-- [GAME METADATA & VERSION]
GAME_AUTHOR = "Gab2006"
GAME_VERSION_MAJOR = 0
GAME_VERSION_MINOR = 1
GAME_VERSION_MICRO = 0
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
	booth_intro = "booth-intro.wav"
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
		-- Only pause channels that were previously played (valid CSND channel allocated)
		if AUDIO.sfx_played[id] and Sound and Sound.pause then
			pcall(Sound.pause, s)
		end
		-- In LPP-3DS CSND: loop argument must be literal boolean false for SOUND_ONE_SHOT
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
	if Sound and Sound.pause then
		if AUDIO.current_ambient then pcall(Sound.pause, AUDIO.current_ambient) end
		if AUDIO.current_bgm then pcall(Sound.pause, AUDIO.current_bgm) end
		if AUDIO.sfx then
			for id, h in pairs(AUDIO.sfx) do
				if AUDIO.sfx_played[id] and h then pcall(Sound.pause, h) end
			end
		end
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
	if AUDIO.sfx then
		for id, h in pairs(AUDIO.sfx) do
			if AUDIO.sfx_played[id] and Sound and Sound.pause and h then
				pcall(Sound.pause, h)
			end
		end
	end
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
end
function LOAD_ITEMS()
	PASSPORT={key="PASSPORT"} --Load Data for PASSPORT
	ENTRYTICKET={key="ENTRYTICKET"} --Load Data for ENTRYTICKET
	ENTRYPERMIT={key="ENTRYPERMIT"}	--Load Data for ENTRYPERMIT
	IDCARD={key="IDCARD"} --Load Data for IDCARD
	WORKPASS={key="WORKPASS"} --Load Data for WORKPASS
	TRANSCRIPT={key="TRANSCRIPT",now=1,x=16,y=-27} --Load Data for TRANSCRIPT
	RULEBOOK={state=2,key="RULEBOOK",now=1,x=5,y=23} --Load Data for RULEBOOK
	DESKTOP={"RULEBOOK","TRANSCRIPT"} --NAMES OF THE ITEMS THAT ON TABLE
	ALLITEMS={RULEBOOK,TRANSCRIPT} --TABLES OF ITEMS THAT IN DESKTOP table
end
LOAD_ITEMS()
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
	
	local cit = {
		key              = id_str,
		is_cit           = true,
		reason           = reason_text,
		penalty          = penalty_text,
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
		for i=1,#CHAT do table.remove(CHAT,1) end
		for i=1,#CHATplace do table.remove(CHATplace,1) end
		table.insert(DESKTOP,1,"TRANSCRIPT")
		table.insert(ALLITEMS,1,TRANSCRIPT)
		table.insert(DESKTOP,1,"RULEBOOK")
		table.insert(ALLITEMS,1,RULEBOOK)
		RULEBOOK.x = 5
		RULEBOOK.y = 23
		RULEBOOK.now = 1
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
			end
			if BKG_BTMS==nil then
				loadtex()
			end
			Timer.resume(GameTIME)
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
			for i=1,#CHAT do table.remove(CHAT,1) end
			for i=1,#CHATplace do table.remove(CHATplace,1) end
			table.insert(DESKTOP,1,"TRANSCRIPT")
			table.insert(ALLITEMS,1,TRANSCRIPT)
			table.insert(DESKTOP,1,"RULEBOOK")
			table.insert(ALLITEMS,1,RULEBOOK)
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

			-- Se sporge dal bordo inferiore del bancone: slide verso quota ripiano y = 23 (come passaporto e carta d'identita')
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
		else
		word.x = word.x or 145
		word.y = word.y or -200
	end
	word.now = word.now or 1
	word.velocity=word.velocity or 0
	word.gravity=gravity or 0
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
				if TOUCHx-word.oldtouchx>35 and TOUCHx-word.oldtouchx+Graphics.getImageWidth(word.tex2)<285 and key~="RULEBOOK" and key~="TRANSCRIPT" then
					word.x=TOUCHx-word.oldtouchx
					elseif TOUCHx-word.oldtouchx<35 and key~="RULEBOOK" and key~="TRANSCRIPT" then
					word.x=35
					elseif word.y<22 and key=="TRANSCRIPT" then
					word.x=16
					elseif TOUCHx-word.oldtouchx>285-math.floor(Graphics.getImageWidth(word.tex2)) then
					word.x=285-math.floor(Graphics.getImageWidth(word.tex2))
					elseif TOUCHx-word.oldtouchx>5 and TOUCHx-word.oldtouchx+Graphics.getImageWidth(word.tex2)<285 and (key=="RULEBOOK" or key=="TRANSCRIPT") then
					word.x=TOUCHx-word.oldtouchx
					elseif TOUCHx-word.oldtouchx<5 and (key=="RULEBOOK" or key=="TRANSCRIPT") then
					word.x=5
				end
				if TOUCHy-word.oldtouchy+Graphics.getImageHeight(word.tex2)<340 and TOUCHy-word.oldtouchy>22 and (stamp==nil or key=="RULEBOOK" or key=="TRANSCRIPT") then
					word.y=TOUCHy-word.oldtouchy
					elseif TOUCHy-word.oldtouchy+Graphics.getImageHeight(word.tex2)<340 and stamp~=nil and key~="RULEBOOK" and key~="TRANSCRIPT" then
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
			word.x=TOUCHx-math.floor(Graphics.getImageWidth(word.tex)/2)
			word.y=TOUCHy-math.floor(Graphics.getImageHeight(word.tex)/2)
			word.oldtouchx = nil
			word.oldtouchy = nil
		end
		if TOUCHy<=67 and TOUCH==key and word.now==0 then
			word.now=1
			word.x=TOUCHx-math.floor(Graphics.getImageWidth(word.tex2)/2)
			word.y=TOUCHy-math.floor(Graphics.getImageHeight(word.tex2)/2)
			word.oldtouchx = nil
			word.oldtouchy = nil
		end
	end	
	if TOUCH~=key and word.now==1 and key~="RULEBOOK" and key~="TRANSCRIPT" then
		if word.y <= 23 then
			word.gravity = 0
			word.velocity = 0
			else 
			word.gravity = 0.1 
		end
		time = Timer.getTime(timer)
		if time>=10 and word.y>24 then
			Timer.reset(timer)
			Timer.resume(timer)
			word.velocity = word.velocity + word.gravity
			word.y=word.y - word.velocity
			elseif word.y<23 then
			word.y=word.y+3
		end
	end
	if TOUCH~=key and word.now==1 and key=="RULEBOOK" then
		if word.x <= 5 then
			word.gravity = 0
			else 
			word.gravity = 0.5 
		end
		time = Timer.getTime(timer)
		if time>=10 then
			Timer.reset(timer)
			Timer.resume(timer)
			word.velocity = word.velocity + word.gravity
			word.x=word.x - word.velocity
		end
		if word.x<5 then word.x=5 end
		if word.y>23 then word.y=word.y-1 end
		if word.y<23 then word.y=23 end
	end
	if TOUCH~=key and word.oldtouchx~=nil and word.oldtouchy~=nil then
		word.oldtouchx=nil
		word.oldtouchy=nil
		PLAY_SFX("paper_dragstop")
	end
	if TOUCH~=key and word.now==1 and key=="TRANSCRIPT" then
		if word.x <= 16 then
			word.gravity = 0
			else 
			word.gravity = 0.5 
		end
		time = Timer.getTime(timer)
		if time>=10 then
			Timer.reset(timer)
			Timer.resume(timer)
			word.velocity = word.velocity + word.gravity
			word.x=word.x - word.velocity
		end
		if word.x<16 then word.x=16 end
		if word.x==16 and word.y>-27 then
			word.y=word.y-3
		end
		if word.x==16 and word.y<-27 then
			word.y=-27
		end
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
function LOAD_TEXT(key,face)
	if CITATIONS and CITATIONS[key] then
		local cit = CITATIONS[key]
		local cx = math.floor(cit.x)
		local cy = math.floor(cit.y)
		GPU_DrawText(cx + 91, cy + 22, "MINISTRY OF ADMISSION", CITATION_COLOR, "c", 320, SMALL_FONT, 7)
		GPU_DrawText(cx + 91, cy + 33, "OFFICIAL CITATION", CITATION_COLOR, "c", 320, SMALL_FONT, 7)
		GPU_DrawText(cx + 91, cy + 44, string.upper(cit.reason or ""), CITATION_COLOR, "c", 320, SMALL_FONT, 7)
		GPU_DrawText(cx + 91, cy + 56, string.upper(cit.penalty or ""), CITATION_COLOR, "c", 320, SMALL_FONT, 7)
		return
	end
	if key=="PASSPORT" then
		if PERSON.passport==1 then
			GPU_DrawText(PASSPORT.x+8,PASSPORT.y+138, PERSON.name, BROWN,"l",320,SMALL_FONT,7) -- firstname and lastname
			GPU_DrawText(PASSPORT.x+22,PASSPORT.y+101, PERSON.DOB, BROWN,"l",320,SMALL_FONT,7) -- date of birth
			GPU_DrawText(PASSPORT.x+22,PASSPORT.y+110, PERSON.GNDR, BROWN,"l",320,SMALL_FONT,7) -- gender
			GPU_DrawText(PASSPORT.x+22,PASSPORT.y+119, PERSON.COL, BROWN,"l",320,SMALL_FONT,7) --  city of living
			GPU_DrawText(PASSPORT.x+22,PASSPORT.y+128, PERSON.passEXP, BROWN,"l",320,SMALL_FONT,7) -- PERSON.passEXP
			GPU_DrawText(PASSPORT.x+55,PASSPORT.y+148, PERSON.ID, BROWN,"l",320,SMALL_FONT,7) --id code XXXXX-XXXXX
			Graphics.drawPartialImage(PASSPORT.x+83,PASSPORT.y+88,40*(face - (11*(math.ceil((face-0.1)/11)-1)+1)),48*(math.ceil((face-0.1)/11)-1),40,48, FACE[5])
		end
		if PERSON.passport==2 then
			GPU_DrawText(PASSPORT.x+8,PASSPORT.y+86, PERSON.name, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+68,PASSPORT.y+98, PERSON.DOB, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+68,PASSPORT.y+106,  PERSON.GNDR, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+68,PASSPORT.y+114,  PERSON.COL, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+68,PASSPORT.y+122,  PERSON.passEXP, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+8,PASSPORT.y+148,  PERSON.ID, BROWN,"l",320,SMALL_FONT,7)
			Graphics.drawPartialImage(PASSPORT.x+8,PASSPORT.y+98,40*(face - (11*(math.ceil((face-0.1)/11)-1)+1)),48*(math.ceil((face-0.1)/11)-1),40,48, FACE[5])
		end
		if PERSON.passport==3 then
			GPU_DrawText(PASSPORT.x+8,PASSPORT.y+85, PERSON.name, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+69,PASSPORT.y+96, PERSON.DOB, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+69,PASSPORT.y+104,  PERSON.GNDR, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+69,PASSPORT.y+112,  PERSON.COL, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+69,PASSPORT.y+120,  PERSON.passEXP, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+60,PASSPORT.y+144,  PERSON.ID, BROWN,"l",320,SMALL_FONT,7)
			Graphics.drawPartialImage(PASSPORT.x+9,PASSPORT.y+96,40*(face - (11*(math.ceil((face-0.1)/11)-1)+1)),48*(math.ceil((face-0.1)/11)-1),40,48, FACE[5])
		end
		if PERSON.passport==4 then
			GPU_DrawText(PASSPORT.x+8,PASSPORT.y+97, PERSON.name, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+68,PASSPORT.y+107, PERSON.DOB, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+68,PASSPORT.y+115,  PERSON.GNDR, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+68,PASSPORT.y+123,  PERSON.COL, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+68,PASSPORT.y+131,  PERSON.passEXP, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+55,PASSPORT.y+148,  PERSON.ID, BROWN,"l",320,SMALL_FONT,7)
			Graphics.drawPartialImage(PASSPORT.x+8,PASSPORT.y+107,40*(face - (11*(math.ceil((face-0.1)/11)-1)+1)),48*(math.ceil((face-0.1)/11)-1),40,48, FACE[5])
		end
		if PERSON.passport==5 then
			GPU_DrawText(PASSPORT.x+8,PASSPORT.y+86, PERSON.name, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+26,PASSPORT.y+98, PERSON.DOB, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+26,PASSPORT.y+106,  PERSON.GNDR, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+26,PASSPORT.y+114,  PERSON.COL, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+26,PASSPORT.y+122,  PERSON.passEXP, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+55,PASSPORT.y+148,  PERSON.ID, BROWN,"l",320,SMALL_FONT,7)
			Graphics.drawPartialImage(PASSPORT.x+85,PASSPORT.y+96,40*(face - (11*(math.ceil((face-0.1)/11)-1)+1)),48*(math.ceil((face-0.1)/11)-1),40,48, FACE[5])
		end
		if PERSON.passport==6 then
			GPU_DrawText(PASSPORT.x+8,PASSPORT.y+97, PERSON.name, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+68,PASSPORT.y+107, PERSON.DOB, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+68,PASSPORT.y+115,  PERSON.GNDR, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+68,PASSPORT.y+123,  PERSON.COL, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+68,PASSPORT.y+131,  PERSON.passEXP, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+55,PASSPORT.y+147,  PERSON.ID, BROWN,"l",320,SMALL_FONT,7)
			Graphics.drawPartialImage(PASSPORT.x+8,PASSPORT.y+106,40*(face - (11*(math.ceil((face-0.1)/11)-1)+1)),48*(math.ceil((face-0.1)/11)-1),40,48, FACE[5])
		end
		if PERSON.passport==7 then
		end
		if PERSON.passport==8 then
			GPU_DrawText(PASSPORT.x+8,PASSPORT.y+97, PERSON.name, BROWN,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+25,PASSPORT.y+111, PERSON.DOB, DOCUMENTS_WHITE,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+25,PASSPORT.y+119,  PERSON.GNDR, DOCUMENTS_WHITE,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+25,PASSPORT.y+127,  PERSON.COL, DOCUMENTS_WHITE,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+25,PASSPORT.y+135,  PERSON.passEXP, DOCUMENTS_WHITE,"l",320,SMALL_FONT,7)
			GPU_DrawText(PASSPORT.x+10,PASSPORT.y+145,  PERSON.ID, DOCUMENTS_WHITE,"l",320,SMALL_FONT,7)
			Graphics.drawPartialImage(PASSPORT.x+84,PASSPORT.y+107,40*(face - (11*(math.ceil((face-0.1)/11)-1)+1)),48*(math.ceil((face-0.1)/11)-1),40,48, FACE[5])
		end
		if stamp=="NO" then
			Graphics.drawPartialImage(PASSPORT.x+state2x,PASSPORT.y+state2y,statesp1,statesp2,statesp3,statesp4, NOSTAMP)
			elseif stamp=="YES" then
			Graphics.drawPartialImage(PASSPORT.x+state2x,PASSPORT.y+state2y,statesp1,statesp2,statesp3,statesp4, YESSTAMP)
		end
		elseif key=="ENTRYTICKET" then
		GPU_DrawText(ENTRYTICKET.x+72,ENTRYTICKET.y+30, PERSON.ticketEXP, ENTRYTICKET_BROWN,320,NORMAL_FONT,8)
		elseif key=="ENTRYPERMIT" then
		Graphics.drawPartialImage(ENTRYPERMIT.x+PERSON.permitx,ENTRYPERMIT.y+PERSON.permity,35*(PERSON.permitMOA - (4*(math.ceil((PERSON.permitMOA-0.1)/4)-1)+1)),35*(math.ceil((PERSON.permitMOA-0.1)/4)-1),35,35, EMOA, Color.new(240,0,0,150))
		if Options["TextAlign"]==1 then
			GPU_DrawText(ENTRYPERMIT.x+75,ENTRYPERMIT.y+89, string.upper(PERSON.permitname), ENTRYTICKET_BROWN,"c",320,NORMAL_FONT,8)
			GPU_DrawText(ENTRYPERMIT.x+75,ENTRYPERMIT.y+120, string.upper(PERSON.permitid), ENTRYTICKET_BROWN,"c",320,NORMAL_FONT,8)
			GPU_DrawText(ENTRYPERMIT.x+90,ENTRYPERMIT.y+137, string.upper(PERSON.permitpurpose), ENTRYTICKET_BROWN,"c",320,NORMAL_FONT,8)
			GPU_DrawText(ENTRYPERMIT.x+90,ENTRYPERMIT.y+153, string.upper(PERSON.permitduration), ENTRYTICKET_BROWN,"c",320,NORMAL_FONT,8)
			GPU_DrawText(ENTRYPERMIT.x+90,ENTRYPERMIT.y+169, string.upper(PERSON.permitenterby), ENTRYTICKET_BROWN,"c",320,NORMAL_FONT,8)
			elseif Options["TextAlign"]==0 then
			GPU_DrawText(ENTRYPERMIT.x+25,ENTRYPERMIT.y+89, string.upper(PERSON.permitname), ENTRYTICKET_BROWN,"l",320,NORMAL_FONT,8)
			GPU_DrawText(ENTRYPERMIT.x+25,ENTRYPERMIT.y+120, string.upper(PERSON.permitid), ENTRYTICKET_BROWN,"l",320,NORMAL_FONT,8)
			GPU_DrawText(ENTRYPERMIT.x+60,ENTRYPERMIT.y+137, string.upper(PERSON.permitpurpose), ENTRYTICKET_BROWN,"l",320,NORMAL_FONT,8)
			GPU_DrawText(ENTRYPERMIT.x+60,ENTRYPERMIT.y+153, string.upper(PERSON.permitduration), ENTRYTICKET_BROWN,"l",320,NORMAL_FONT,8)
			GPU_DrawText(ENTRYPERMIT.x+60,ENTRYPERMIT.y+169, string.upper(PERSON.permitenterby), ENTRYTICKET_BROWN,"l",320,NORMAL_FONT,8)
		end
		elseif key=="IDCARD" then
		GPU_DrawText(IDCARD.x+8,IDCARD.y+11, string.upper(PERSON.idcarddistrict).." DISTRICT", IDCARD_WCOLOR,"l",320,NORMAL_FONT,8)
		GPU_DrawText(IDCARD.x+49,IDCARD.y+19, string.upper(PERSON.idcardlastname)..",", IDCARD_BCOLOR,"l",320,NORMAL_FONT,8)
		GPU_DrawText(IDCARD.x+49,IDCARD.y+29, string.upper(PERSON.idcardfirstname), IDCARD_BCOLOR,"l",320,NORMAL_FONT,8)
		GPU_DrawText(IDCARD.x+65,IDCARD.y+39, string.upper(PERSON.idcardDOB), IDCARD_BCOLOR,"l",320,NORMAL_FONT,8)
		GPU_DrawText(IDCARD.x+65,IDCARD.y+49, string.upper(PERSON.idcardheight), IDCARD_BCOLOR,"l",320,NORMAL_FONT,8)
		GPU_DrawText(IDCARD.x+65,IDCARD.y+59, string.upper(PERSON.idcardweight), IDCARD_BCOLOR,"l",320,NORMAL_FONT,8)
		Graphics.drawPartialImage(IDCARD.x+4,IDCARD.y+17,40*(PERSON.idcardface - (11*(math.ceil((PERSON.idcardface-0.1)/11)-1)+1)),48*(math.ceil((PERSON.idcardface-0.1)/11)-1),40,48, FACE[5])
		elseif key=="WORKPASS" then
		Graphics.drawPartialImage(WORKPASS.x+PERSON.WORKPASSx,WORKPASS.y+PERSON.WORKPASSy,35*(PERSON.WORKPASSMOL - (4*(math.ceil((PERSON.WORKPASSMOL-0.1)/4)-1)+1)),35*(math.ceil((PERSON.WORKPASSMOL-0.1)/4)-1),35,35, EMOL, Color.new(88,0,240,150))
		if Options["TextAlign"]==1 then
			GPU_DrawText(WORKPASS.x+85,WORKPASS.y+63, string.upper(PERSON.WORKPASSholder), WORKPASS_COLOR,"c",320,NORMAL_FONT,8)
			GPU_DrawText(WORKPASS.x+85,WORKPASS.y+79, string.upper(PERSON.WORKPASSfield), WORKPASS_COLOR,"c",320,NORMAL_FONT,8)
			GPU_DrawText(WORKPASS.x+85,WORKPASS.y+95, string.upper(PERSON.WORKPASSuntil), WORKPASS_COLOR,"c",320,NORMAL_FONT,8)
			elseif Options["TextAlign"]==0 then
			GPU_DrawText(WORKPASS.x+40,WORKPASS.y+63, string.upper(PERSON.WORKPASSholder), WORKPASS_COLOR,"l",320,NORMAL_FONT,8)
			GPU_DrawText(WORKPASS.x+36,WORKPASS.y+79, string.upper(PERSON.WORKPASSfield), WORKPASS_COLOR,"l",320,NORMAL_FONT,8)
			GPU_DrawText(WORKPASS.x+36,WORKPASS.y+95, string.upper(PERSON.WORKPASSuntil), WORKPASS_COLOR,"l",320,NORMAL_FONT,8)
		end
		elseif key=="TRANSCRIPT" then
		if Options["Dialog"]==1 then
			for i=1, #CHAT do 
				if CHATplace[i]==1 then
					Graphics.drawImage(TRANSCRIPT.x+11,TRANSCRIPT.y+12+9*(i-1),TRANSCRIPT.tex3)
					GPU_DrawText(TRANSCRIPT.x+12,TRANSCRIPT.y+13+9*(i-1), string.upper(CHAT[i]), TRANSCRIPTBLUE,"l",320,NORMAL_FONT,8)
					elseif CHATplace[i]==2 then
					GPU_DrawText(TRANSCRIPT.x+137,TRANSCRIPT.y+13+9*(i-1), string.upper(CHAT[i]), TRANSCRIPTBROWN,"r",320,NORMAL_FONT,8)
				end
			end
		end
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
	if STAMP.state=="OPENED" and STAMP.x > 40 and STAMP.velocity > 0 and Timer.getTime(timer) >= 10 then
		Timer.reset(timer)
		Timer.resume(timer)
		STAMP.velocity = STAMP.velocity - STAMP.gravity
		STAMP.x = STAMP.x - STAMP.velocity
	end
	if STAMP.state=="CLOSED" and STAMP.x < 310 and Timer.getTime(timer) >= 10 then
		Timer.reset(timer)
		Timer.resume(timer)
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
	for i=1,#DESKTOP do table.remove(DESKTOP,1) end
	for i=1,#ALLITEMS do table.remove(ALLITEMS,1) end
	for i=1,#CHAT do table.remove(CHAT,1) end
	for i=1,#CHATplace do table.remove(CHATplace,1) end
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
	table.insert(ALLITEMS,1,RULEBOOK)
	table.insert(ALLITEMS,1,PASSPORT)
	RULEBOOK.x = 5
	RULEBOOK.y = 23
	RULEBOOK.now = 1
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
			PERSON.idcardheight = PERSON.idcardheight - math.random(7,10)
			else 
			wrong=1
		end
		elseif wrong==11 then
		if PERSON.passport==2 then
			PERSON.idcardweight = PERSON.weight - math.random(2,5)
			else 
			wrong=1
		end
		elseif wrong==12 then
		PERSON.idcardface = math.random(1,44)
		PERSON.face = PERSON.idcardface
		if PERSON.idcardface==PERSON.realface then
			wrong=1
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
			end
		end
	end
	stamp=nil
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
	if PERSON.face==1 then a=math.random(165,171)
		elseif PERSON.face==2 then a=math.random(165,171)
		elseif PERSON.face==3 then a=math.random(164,170)
		elseif PERSON.face==4 then a=math.random(161,164)
		elseif PERSON.face==5 then a=math.random(181,184)
		elseif PERSON.face==6 then a=math.random(164,170)
		elseif PERSON.face==7 then a=math.random(178,182)
		elseif PERSON.face==8 then a=math.random(175,181)
		elseif PERSON.face==9 then a=math.random(179,183)
		elseif PERSON.face==10 then a=math.random(170,173)
		elseif PERSON.face==11 then a=math.random(178,182)
		elseif PERSON.face==12 then a=math.random(173,179)
		elseif PERSON.face==13 then a=math.random(177,181)
		elseif PERSON.face==14 then a=math.random(173,179)
		elseif PERSON.face==15 then a=math.random(179,183)
		elseif PERSON.face==16 then a=math.random(179,183)
		elseif PERSON.face==17 then a=math.random(169,173)
		elseif PERSON.face==18 then a=math.random(178,182)
		elseif PERSON.face==19 then a=math.random(165,171)
		elseif PERSON.face==20 then a=math.random(169,174)
		elseif PERSON.face==21 then a=math.random(164,169)
		elseif PERSON.face==22 then a=math.random(164,170)
		elseif PERSON.face==23 then a=math.random(165,171)
		elseif PERSON.face==24 then a=math.random(179,183)
		elseif PERSON.face==25 then a=math.random(180,183)
		elseif PERSON.face==26 then a=math.random(178,182)
		elseif PERSON.face==27 then a=math.random(181,184)
		elseif PERSON.face==28 then a=math.random(180,183)
		elseif PERSON.face==29 then a=math.random(173,179)
		elseif PERSON.face==30 then a=math.random(161,164)
		elseif PERSON.face==31 then a=math.random(169,173)
		elseif PERSON.face==32 then a=math.random(175,181)
		elseif PERSON.face==33 then a=math.random(171,174)
		elseif PERSON.face==34 then a=math.random(178,182)
		elseif PERSON.face==35 then a=math.random(169,174)
		elseif PERSON.face==36 then a=math.random(168,172)
		elseif PERSON.face==37 then a=math.random(171,174)
		elseif PERSON.face==38 then a=math.random(173,179)
		elseif PERSON.face==39 then a=math.random(173,179)
		elseif PERSON.face==40 then a=math.random(175,181)
		elseif PERSON.face==41 then a=math.random(165,171)
		elseif PERSON.face==42 then a=math.random(171,174)
		elseif PERSON.face==43 then a=math.random(169,174)
		elseif PERSON.face==44 then a=math.random(161,164)
	end
	return a
end
function DIALOG_SYSTEM()
	for i=1, #CHAT do
		if FACE.x==126 and SWITCHER==0 then
			if  Timer.getTime(CBtime)>1000*(i-1) then
				if CHATplace[i]==2 then
					if CHATx[i] == nil then
						PLAY_SFX("speech_entrant")
					end
					CHATx[i] = CHATx[i] or 210
					if CHATx[i] < 290 then
						Graphics.drawImage(CHATx[i], 103+(i-1)*12, SB)
						GPU_DrawText(CHATx[i]+2,106+(i-1)*12,CHAT[i] ,BROWN2,"l",400,SMALL_FONT,7)
						if Timer.getTime(CBtime)>3000+1000*(i-1) then
							CHATx[i] = CHATx[i] + 5
						end
					end
					else
					if CHATx[i] == nil then
						PLAY_SFX("speech_inspector")
					end
					CHATx[i] = CHATx[i] or 112
					if CHATx[i] > 32 then
						Graphics.drawImage(CHATx[i], 103+(i-1)*12, SB)
						GPU_DrawText(CHATx[i]+2,106+(i-1)*12,CHAT[i] ,BROWN2,"l",400,SMALL_FONT,7)
						if Timer.getTime(CBtime)>3000+1000*(i-1) then
							CHATx[i] = CHATx[i] - 5
						end
					end
				end
			end
			else
			if SWITCHER==1 then
				else
				Timer.reset(CBtime)
				CHATx[i] = nil
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

		local is_invalid_entrant = (WRONGCONST ~= "Nothing") or has_embargo_violation or has_wanted_violation or has_transcript_violation

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
					penalty_text = "PENALTY: -30 SECONDS"
					penalty_time = 30000
				end
			elseif MODEselect == 2 then
				penalty_text = "FATAL INFRACTION - DISMISSED"
				penalty_pts = 0
			elseif MODEselect == 3 then
				if mistake_count <= 2 then
					penalty_text = "WARNING - NO PENALTY"
					penalty_pts = 0
				elseif mistake_count == 3 then
					penalty_text = "PENALTY: -5 POINTS"
					penalty_pts = 5
				else
					penalty_text = "PENALTY: -10 POINTS"
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
					penalty_text = "PENALTY: -30 SECONDS"
					penalty_time = 30000
				end
			elseif MODEselect == 2 then
				penalty_text = "FATAL INFRACTION - DISMISSED"
				penalty_pts = 0
			elseif MODEselect == 3 then
				if mistake_count <= 2 then
					penalty_text = "WARNING - NO PENALTY"
					penalty_pts = 0
				elseif mistake_count == 3 then
					penalty_text = "PENALTY: -5 POINTS"
					penalty_pts = 5
				else
					penalty_text = "PENALTY: -10 POINTS"
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
end
while true do
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
		for i=1, #DESKTOP do
			if TOUCH == DESKTOP[i] then 
				table.remove(DESKTOP,i) 
				table.insert(DESKTOP,1,TOUCH)
			end
		end
		STAMP_CODE()
		for i = 1 ,#DESKTOP do
			for k = 1,#ALLITEMS do
				if DESKTOP[i]==ALLITEMS[k].key then TOUCH_CHECK(ALLITEMS[k],ALLITEMS[k].key) end
			end
		end
		if TOUCH~="ACTIVE" and TOUCHx==0 and TOUCHy==0 then
			TOUCH="ACTIVE"
		end
		if TOUCH=="ACTIVE" and TOUCHx>0 and TOUCHy>0 then
			TOUCH="NOTHING"
		end
		Graphics.drawPartialImage(0, 67, 0, 77, 320, 173, BKG_BTMS)
		for i = 1,#DESKTOP do
			for k=1,#ALLITEMS do
				if DESKTOP[#DESKTOP-i+1]==ALLITEMS[k].key and ALLITEMS[k].now==0 then LOAD_IMAGE(ALLITEMS[k],ALLITEMS[k].key) end
			end
		end
		Graphics.drawPartialImage(0, 0, 0, 0, 320, 77, BKG_BTMS)
		for i = 1,#DESKTOP do
			for k=1,#ALLITEMS do
				if DESKTOP[#DESKTOP-i+1]==ALLITEMS[k].key and ALLITEMS[k].now==1 then LOAD_IMAGE(ALLITEMS[k],ALLITEMS[k].key) end
			end
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
			TIME = 600000 - Timer.getTime(GameTIME) - TIMEMINUS
			plusPOINTS = 1
			elseif MODEselect==2 then
			TIME = Timer.getTime(GameTIME)
			if 10 - TIMEmin  >= 1 then
				plusPOINTS = 10 - TIMEmin
				else
				plusPOINTS = 1
			end
			elseif MODEselect==3 then
			TIME = Timer.getTime(GameTIME)
			plusPOINTS = 1
		end
		TIMEsec = TIME/1000
		TIMEmin = math.floor(TIMEsec/60)
		TIMEsec = math.floor(TIMEsec - TIMEmin*60)
		Graphics.drawImage(112,104, WALL_TXR)
		BKG_SHDW()
		LOAD_FACE(PERSON.realface)
		if CheckPoint == 1 and Controls.check(pad,KEY_A) and not Controls.check(oldpad,KEY_A) then
			if not (IS_STORY_MODE and DAY_OVER) and not PERFECT_GAMEOVER_ACTIVE then
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
			FACE.y=-(5*math.cos(15*(FACE.x-126)))+109
			if FACE.x>120 and SWITCHER==1 then
				SWITCHER=0
			end
		end
		CHECK_EMPTYTABLE()
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
				GPU_DrawText(347,TIMEy,"-00:30" ,HUD_RED_TEXT,"c",400,SMALL_FONT,7)
				elseif Options["TextAlign"]==0 then
				GPU_DrawText(330,TIMEy,"-00:30" ,HUD_RED_TEXT,"l",400,SMALL_FONT,7)
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
			if SCORE<0 then
				menu="GameOver"
				Timer.pause(GameTIME)
			end
		end
		if Controls.check(pad,KEY_START) and not Controls.check(oldpad,KEY_START) and FADE_STATE=="NONE" then
			Timer.pause(GameTIME)
			PAUSE_AUDIO()
			menu="Pause"
		end
		elseif menu==0 then
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
			RESUME_AUDIO()
			menu = 2
		end
		screenshotmake()
		Graphics.termBlend()
		TITLE_MOVE()
		elseif menu=="GameOver" then
		Graphics.initBlend(TOP_SCREEN)
		Graphics.drawImage(0,TITLEy+265,Title)
		screenshotmake()
		Graphics.termBlend()
		Graphics.initBlend(BOTTOM_SCREEN)
		GPU_DrawText(120,45,"Time........"..TIMEmin..":"..TIMEsec,WHITE,"l",320,SMALL_FONT,7)
		GPU_DrawText(120,60,"Score......."..SCORE,WHITE,"l",320,SMALL_FONT,7)
		GPU_DrawText(120,75,"Peoples....."..PEOPLESCORE,WHITE,"l",320,SMALL_FONT,7)
		GPU_DrawText(120,90,"LASTreason.."..WRONGCONST,WHITE,"l",320,SMALL_FONT,7)
		GPU_DrawText(120,105,"Mistakes..."..WRONGMANn,WHITE,"l",320,SMALL_FONT,7)
		ScreenButton(96,132,MAINMENUbutton,0,MAINMENU)
		ScreenButton(96,162,QUITbutton,"Exit",QUIT)
		screenshotmake()
		Graphics.termBlend()
		TITLE_MOVE()
		elseif menu=="DayIntro" then
		local day_cfg = GET_DAY_CONFIG(CURRENT_DAY)

		-- [LAZY-LOAD AUTHENTIC BULLETIN & NEWSPAPER TEXTURES]
		if BULLETIN_BTM_TEX == nil then
			BULLETIN_BTM_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/BKG_BULLETIN_BTM.png")
		end
		if CURRENT_DAY <= 4 then
			if NEWS_TEX == nil or NEWS_TEX_DAY ~= CURRENT_DAY then
				if NEWS_TEX then Graphics.freeImage(NEWS_TEX) end
				local news_path = System.currentDirectory().."ASSETS/NEWS_DAY"..CURRENT_DAY..".png"
				NEWS_TEX = Graphics.loadImage(news_path)
				if NEWS_TEX == nil then
					NEWS_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/BKG_BULLETIN_TOP.png")
				end
				NEWS_TEX_DAY = CURRENT_DAY
			end
		else
			if NEWS_TEX then
				Graphics.freeImage(NEWS_TEX)
				NEWS_TEX = nil
				NEWS_TEX_DAY = nil
			end
		end

		-- [TOP SCREEN: AUTHENTIC NEWSPAPER - THE TRUTH OF ARSTOTZKA / ARSTOTZKAN TRIBUNE]
		Graphics.initBlend(TOP_SCREEN)
		if CURRENT_DAY <= 4 and NEWS_TEX then
			Graphics.drawImage(0, 0, NEWS_TEX)
		else
			-- Procedural Newspaper: "THE ARSTOTZKAN TRIBUNE"
			Graphics.fillRect(0, 400, 0, 240, Color.new(22, 19, 18))
			-- Newspaper sheet background
			Graphics.fillRect(12, 388, 10, 230, Color.new(228, 220, 206))
			Graphics.fillEmptyRect(12, 388, 10, 230, Color.new(65, 55, 45))
			Graphics.fillEmptyRect(14, 386, 12, 228, Color.new(140, 130, 115))

			-- Newspaper Header Banner
			Graphics.fillRect(16, 384, 14, 46, Color.new(45, 40, 38))
			GPU_DrawText(200, 18, "THE ARSTOTZKAN TRIBUNE", Color.new(245, 240, 230), "c", 400, NORMAL_FONT, 8)
			GPU_DrawText(200, 34, "THE VOICE OF THE MINISTRY  |  ISSUE #" .. CURRENT_DAY .. "  |  " .. day_cfg.date, Color.new(200, 190, 175), "c", 400, SMALL_FONT, 7)

			-- Headline divider line
			Graphics.fillRect(20, 380, 52, 54, Color.new(50, 40, 35))

			-- Main Headline Box
			GPU_DrawText(200, 62, day_cfg.headline, Color.new(20, 15, 15), "c", 400, NORMAL_FONT, 8)
			GPU_DrawText(200, 80, day_cfg.subline, Color.new(70, 55, 50), "c", 400, SMALL_FONT, 7)

			-- Separator
			Graphics.fillRect(40, 360, 94, 95, Color.new(120, 110, 100))

			-- Additional newspaper articles / flavor
			if day_cfg.embargo_nation then
				GPU_DrawText(25, 104, "DIPLOMATIC SANCTIONS IN EFFECT", Color.new(140, 30, 30), "l", 400, NORMAL_FONT, 8)
				GPU_DrawText(25, 122, "Ministry of Foreign Affairs has suspended all entry privileges", Color.new(50, 40, 40), "l", 400, SMALL_FONT, 7)
				GPU_DrawText(25, 136, "for citizens originating from " .. day_cfg.embargo_nation .. ".", Color.new(50, 40, 40), "l", 400, SMALL_FONT, 7)
				GPU_DrawText(25, 150, "Inspectors must deny entry immediately under penalty of law.", Color.new(80, 50, 50), "l", 400, SMALL_FONT, 7)
			else
				GPU_DrawText(25, 104, "SECURITY PROTOCOLS UPDATED", Color.new(35, 30, 30), "l", 400, NORMAL_FONT, 8)
				GPU_DrawText(25, 122, "State security agencies have increased checkpoint surveillance.", Color.new(50, 40, 40), "l", 400, SMALL_FONT, 7)
				GPU_DrawText(25, 136, "Inspectors are reminded to verify all paperwork rigorously.", Color.new(50, 40, 40), "l", 400, SMALL_FONT, 7)
				GPU_DrawText(25, 150, "Discrepancies in applicant statements will not be tolerated.", Color.new(80, 50, 50), "l", 400, SMALL_FONT, 7)
			end

			if day_cfg.wanted_name then
				Graphics.fillRect(25, 375, 168, 196, Color.new(60, 20, 20))
				Graphics.fillEmptyRect(25, 375, 168, 196, Color.new(120, 40, 40))
				GPU_DrawText(200, 172, "WANTED BY STATE POLICE: " .. day_cfg.wanted_name, Color.new(255, 220, 220), "c", 400, SMALL_FONT, 7)
				GPU_DrawText(200, 184, "DENY ENTRY IMMEDIATELY UPON PRESENTATION OF PAPERS", Color.new(240, 180, 180), "c", 400, SMALL_FONT, 7)
			end

			GPU_DrawText(200, 210, "GLORY TO ARSTOTZKA.", Color.new(140, 25, 25), "c", 400, NORMAL_FONT, 8)
		end
		screenshotmake()
		Graphics.termBlend()

		-- [BOTTOM SCREEN: MINISTRY OF ADMISSION OFFICIAL BULLETIN]
		Graphics.initBlend(BOTTOM_SCREEN)
		if BULLETIN_BTM_TEX then
			Graphics.drawImage(0, 0, BULLETIN_BTM_TEX)
		else
			Graphics.fillRect(0, 320, 0, 240, Color.new(28, 24, 24))
			-- Paper document background with double border
			Graphics.fillRect(10, 310, 8, 232, Color.new(236, 230, 218))
			Graphics.fillEmptyRect(10, 310, 8, 232, Color.new(110, 90, 70))
			Graphics.fillEmptyRect(12, 308, 10, 230, Color.new(170, 150, 130))
			-- Crimson header banner
			Graphics.fillRect(12, 308, 10, 42, Color.new(82, 34, 34))
		end
		
		GPU_DrawText(160, 14, "MINISTRY OF ADMISSION", WHITE, "c", 320, NORMAL_FONT, 8)
		GPU_DrawText(160, 28, "OFFICIAL DIRECTIVE - DAY "..CURRENT_DAY.." - "..day_cfg.date, Color.new(230, 210, 210), "c", 320, SMALL_FONT, 7)
		
		-- Subheader
		GPU_DrawText(20, 48, "ARSTOTZKA BORDER CONTROL - GRESTIN CHECKPOINT", Color.new(70, 60, 50), "l", 320, SMALL_FONT, 7)
		if BULLETIN_BTM_TEX == nil then
			Graphics.fillRect(20, 300, 58, 60, Color.new(120, 100, 80))
		end
		
		-- Directives / Rules
		local rule_y = 64
		for idx, rule in ipairs(day_cfg.bulletin_rules) do
			if BULLETIN_BTM_TEX == nil then
				Graphics.fillRect(20, 24, rule_y + 3, rule_y + 7, Color.new(82, 34, 34))
			end
			local rule_col = Color.new(20, 20, 20)
			if string.find(rule, "DENY ALL") or string.find(rule, "WANTED") then
				rule_col = Color.new(140, 25, 25)
			end
			GPU_DrawText(28, rule_y, rule, rule_col, "l", 320, SMALL_FONT, 7)
			rule_y = rule_y + 16
		end
		
		-- Shift info line
		if BULLETIN_BTM_TEX == nil then
			Graphics.fillRect(20, 300, 148, 150, Color.new(180, 160, 140))
		end
		GPU_DrawText(160, 149, "SHIFT: 09:00 - 18:00  |  PENALTIES FOR CITATIONS", Color.new(80, 70, 60), "c", 320, SMALL_FONT, 7)
		
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
			GPU_DrawText(160, 198, "PRESS (A) OR TAP TO OPEN", Color.new(110, 100, 90), "c", 320, SMALL_FONT, 7)
		else
			local btn_text_col = Color.new(35, 30, 30)
			if DAY_INTRO_BTN.touched and TOUCHx>0 and TOUCHy>0 then
				btn_text_col = Color.new(90, 36, 36)
			end
			GPU_DrawText(160, 182, "[ OPEN CHECKPOINT (A) ]", btn_text_col, "c", 320, NORMAL_FONT, 8)
		end
		
		GPU_DrawText(160, 218, "PRESS (B) FOR MENU", Color.new(100, 90, 80), "c", 320, SMALL_FONT, 7)
		
		if (TOUCHx==0 and TOUCHy==0 and DAY_INTRO_BTN.touched) or (Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A)) then
			DAY_INTRO_BTN.touched = false
			if NEWS_TEX then
				Graphics.freeImage(NEWS_TEX)
				NEWS_TEX = nil
				NEWS_TEX_DAY = nil
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
			for i=1,#CHAT do table.remove(CHAT,1) end
			for i=1,#CHATplace do table.remove(CHATplace,1) end
			table.insert(DESKTOP,1,"TRANSCRIPT")
			table.insert(ALLITEMS,1,TRANSCRIPT)
			table.insert(DESKTOP,1,"RULEBOOK")
			table.insert(ALLITEMS,1,RULEBOOK)
			RULEBOOK.x = 5
			RULEBOOK.y = 23
			RULEBOOK.now = 1
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
		if SCORE < 0 then
			-- ==============================================================
			-- [DEBT GAME OVER: SOMBER / DARK ARREST SCREEN (PAPERS, PLEASE)]
			-- ==============================================================
			-- [TOP SCREEN: BLEAK ARREST NOTICE & SUMMARY]
			Graphics.initBlend(TOP_SCREEN)
			Graphics.fillRect(0, 400, 0, 240, Color.new(12, 10, 14))
			Graphics.fillRect(0, 400, 0, 3, Color.new(160, 30, 30))
			Graphics.fillRect(0, 400, 237, 240, Color.new(160, 30, 30))
			
			GPU_DrawText(200, 16, "MINISTRY OF ADMISSION", Color.new(210, 50, 50), "c", 400, NORMAL_FONT, 8)
			GPU_DrawText(200, 32, "NOTICE OF INDEBTEDNESS & TERMINATION", Color.new(180, 170, 160), "c", 400, SMALL_FONT, 7)
			GPU_DrawText(200, 46, "GRESTIN BORDER DISTRICT - END OF SHIFT", Color.new(130, 120, 110), "c", 400, SMALL_FONT, 7)
			
			-- Dark central dossier container
			Graphics.fillRect(30, 370, 58, 176, Color.new(20, 16, 20))
			Graphics.fillEmptyRect(30, 370, 58, 176, Color.new(90, 30, 30))
			Graphics.fillEmptyRect(32, 368, 60, 174, Color.new(45, 18, 20))
			
			GPU_DrawText(45, 68, "EMPLOYEE: INSPECTOR 221-A", Color.new(170, 160, 150), "l", 400, SMALL_FONT, 7)
			GPU_DrawText(45, 84, "STATUS: DISMISSED & DETAINED", Color.new(220, 50, 50), "l", 400, SMALL_FONT, 7)
			GPU_DrawText(45, 102, "ENTRANTS PROCESSED:", Color.new(150, 140, 130), "l", 400, SMALL_FONT, 7)
			GPU_DrawText(355, 102, tostring(DAY_INSPECTED_COUNT), Color.new(200, 190, 180), "r", 400, NORMAL_FONT, 8)
			GPU_DrawText(45, 120, "CITATIONS ACCUMULATED:", Color.new(180, 60, 60), "l", 400, SMALL_FONT, 7)
			GPU_DrawText(355, 120, tostring(DAY_MISTAKES_COUNT), Color.new(220, 50, 50), "r", 400, NORMAL_FONT, 8)
			
			Graphics.fillRect(45, 355, 136, 137, Color.new(80, 30, 30))
			
			GPU_DrawText(45, 146, "FINAL ACCOUNT BALANCE:", Color.new(220, 180, 180), "l", 400, NORMAL_FONT, 8)
			GPU_DrawText(355, 146, tostring(SCORE) .. " CREDITS", Color.new(240, 40, 40), "r", 400, NORMAL_FONT, 8)
			
			GPU_DrawText(200, 192, "AN INDEBTED OFFICER IS A NATIONAL SECURITY RISK.", Color.new(140, 40, 40), "c", 400, SMALL_FONT, 7)
			GPU_DrawText(200, 212, "GLORY TO ARSTOTZKA.", Color.new(190, 40, 40), "c", 400, NORMAL_FONT, 8)
			
			if FADE_ALPHA > 0 then
				Graphics.fillRect(0, 400, 0, 240, Color.new(0, 0, 0, math.floor(math.min(255, math.max(0, FADE_ALPHA)))))
			end
			screenshotmake()
			Graphics.termBlend()

			-- [BOTTOM SCREEN: DARK ARREST WARRANT DECREE]
			Graphics.initBlend(BOTTOM_SCREEN)
			Graphics.fillRect(0, 320, 0, 240, Color.new(16, 13, 17))
			
			-- Document sheet background (dark charcoal)
			Graphics.fillRect(15, 305, 10, 230, Color.new(24, 20, 24))
			Graphics.fillEmptyRect(15, 305, 10, 230, Color.new(85, 30, 30))
			Graphics.fillEmptyRect(17, 303, 12, 228, Color.new(45, 18, 20))
			
			-- Red header banner
			Graphics.fillRect(25, 295, 18, 36, Color.new(80, 22, 22))
			Graphics.fillEmptyRect(25, 295, 18, 36, Color.new(120, 35, 35))
			GPU_DrawText(160, 23, "OFFICIAL NOTICE OF ARREST", Color.new(240, 210, 210), "c", 320, NORMAL_FONT, 8)
			
			-- Typewriter narrative lines
			GPU_DrawText(28, 44, "Your account has fallen into a negative balance.", Color.new(210, 200, 190), "l", 320, SMALL_FONT, 7)
			GPU_DrawText(28, 58, "You cannot pay the penalties assessed against you.", Color.new(210, 200, 190), "l", 320, SMALL_FONT, 7)
			GPU_DrawText(28, 72, "The Ministry of Admission does not tolerate debt.", Color.new(210, 200, 190), "l", 320, SMALL_FONT, 7)
			GPU_DrawText(28, 88, "You are under arrest for non-payment.", Color.new(230, 60, 60), "l", 320, SMALL_FONT, 7)
			GPU_DrawText(28, 102, "Your family will be questioned and returned to Nirsk.", Color.new(170, 160, 150), "l", 320, SMALL_FONT, 7)
			GPU_DrawText(28, 116, "A replacement inspector has been assigned.", Color.new(170, 160, 150), "l", 320, SMALL_FONT, 7)
			
			Graphics.fillRect(28, 292, 130, 131, Color.new(70, 25, 25))
			GPU_DrawText(160, 138, "CAUSE OF DISMISSAL: INSOLVENCY", Color.new(200, 50, 50), "c", 320, NORMAL_FONT, 8)
			
			-- Button 1: RETRY DAY (A)
			DAY_RETRY_BTN = DAY_RETRY_BTN or {touched = false}
			if FADE_STATE == "NONE" and TOUCHx>=35 and TOUCHx<=285 and TOUCHy>=154 and TOUCHy<=182 then
				Graphics.fillRect(35,285,154,182,Color.new(120,35,35))
				DAY_RETRY_BTN.touched = true
			else
				Graphics.fillRect(35,285,154,182,Color.new(75,20,20))
			end
			Graphics.fillEmptyRect(35,285,154,182,Color.new(140,40,40))
			GPU_DrawText(160, 166, "RETRY DAY (A)", Color.new(250, 230, 230), "c", 320, NORMAL_FONT, 8)
			
			-- Button 2: MAIN MENU (B)
			DAY_MENU_BTN = DAY_MENU_BTN or {touched = false}
			if FADE_STATE == "NONE" and TOUCHx>=35 and TOUCHx<=285 and TOUCHy>=192 and TOUCHy<=220 then
				Graphics.fillRect(35,285,192,220,Color.new(65,60,65))
				DAY_MENU_BTN.touched = true
			else
				Graphics.fillRect(35,285,192,220,Color.new(40,36,40))
			end
			Graphics.fillEmptyRect(35,285,192,220,Color.new(80,75,80))
			GPU_DrawText(160, 204, "MAIN MENU (B)", Color.new(200, 200, 200), "c", 320, NORMAL_FONT, 8)
			
			if FADE_STATE == "NONE" and ((TOUCHx==0 and TOUCHy==0 and DAY_RETRY_BTN.touched) or (Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A))) then
				DAY_RETRY_BTN.touched = false
				if DAYSUMMARY_BKG_TEX then Graphics.freeImage(DAYSUMMARY_BKG_TEX); DAYSUMMARY_BKG_TEX = nil end
				if DAYSUMMARY_TOP_TEX then Graphics.freeImage(DAYSUMMARY_TOP_TEX); DAYSUMMARY_TOP_TEX = nil end
				CLEAR_CITATIONS()
				DAY_INSPECTED_COUNT = 0
				DAY_CORRECT_COUNT = 0
				DAY_MISTAKES_COUNT = 0
				DAY_TIME_OFFSET = 0
				WRONGMANn = 0
				PEOPLESCORE = 0
				DAY_EXPENSES_DEDUCTED_DAY = nil
				DAY_SUMMARY_EXPENSES = nil
				SCORE = DAY_START_SCORE or 0
				SAVE_GAME({
					day = CURRENT_DAY,
					in_progress = 0,
					score = SCORE
				})
				FADE_STATE = "NONE"
				FADE_ALPHA = 0
				menu = "DayIntro"
			end
			
			if FADE_STATE == "NONE" and ((TOUCHx==0 and TOUCHy==0 and DAY_MENU_BTN.touched) or (Controls.check(pad, KEY_B) and not Controls.check(oldpad, KEY_B))) then
				DAY_MENU_BTN.touched = false
				if DAYSUMMARY_BKG_TEX then Graphics.freeImage(DAYSUMMARY_BKG_TEX); DAYSUMMARY_BKG_TEX = nil end
				if DAYSUMMARY_TOP_TEX then Graphics.freeImage(DAYSUMMARY_TOP_TEX); DAYSUMMARY_TOP_TEX = nil end
				CLEAR_CITATIONS()
				DAY_EXPENSES_DEDUCTED_DAY = nil
				DAY_SUMMARY_EXPENSES = nil
				SAVE_GAME({
					day = CURRENT_DAY,
					in_progress = 0,
					score = DAY_START_SCORE or 0
				})
				DAY_TIME_OFFSET = 0
				IS_STORY_MODE = false
				FADE_STATE = "NONE"
				FADE_ALPHA = 0
				STOP_BGM()
				menu = 0
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
		else
			-- ==============================================================
			-- [NORMAL DAY SUMMARY: SUCCESSFUL DAY (SCORE >= 0)]
			-- ==============================================================
			if DAYSUMMARY_BKG_TEX == nil then
				DAYSUMMARY_BKG_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/BKG_DAYSUMMARY.png")
			end
			if DAYSUMMARY_TOP_TEX == nil then
				DAYSUMMARY_TOP_TEX = Graphics.loadImage(System.currentDirectory().."ASSETS/BKG_DAYSUMMARY_TOP.png")
			end

			-- [TOP SCREEN: DUSK / SHIFT SUMMARY HEADER]
			Graphics.initBlend(TOP_SCREEN)
			if DAYSUMMARY_TOP_TEX then
				Graphics.drawImage(0, 0, DAYSUMMARY_TOP_TEX)
			else
				Graphics.fillRect(0, 400, 0, 240, Color.new(15, 12, 18))
				GPU_DrawText(200, 24, "MINISTRY OF ADMISSION", Color.new(225, 215, 200), "c", 400, NORMAL_FONT, 8)
				GPU_DrawText(200, 42, "GRESTIN BORDER CHECKPOINT", Color.new(180, 170, 160), "c", 400, SMALL_FONT, 7)
			end
			GPU_DrawText(200, 70, "CHECKPOINT CLOSED - 18:00", Color.new(180, 50, 50), "c", 400, NORMAL_FONT, 8)
			GPU_DrawText(200, 98, "END OF SHIFT - DAY "..CURRENT_DAY, WHITE, "c", 400, NORMAL_FONT, 8)
			if FADE_ALPHA > 0 then
				Graphics.fillRect(0, 400, 0, 240, Color.new(0, 0, 0, math.floor(math.min(255, math.max(0, FADE_ALPHA)))))
			end
			screenshotmake()
			Graphics.termBlend()
			
			-- [BOTTOM SCREEN: SUMMARY REPORT SHEET]
			Graphics.initBlend(BOTTOM_SCREEN)
			if DAYSUMMARY_BKG_TEX then
				Graphics.drawImage(0, 0, DAYSUMMARY_BKG_TEX)
			else
				Graphics.fillRect(0, 320, 0, 240, Color.new(25, 20, 20))
				Graphics.fillRect(15, 305, 12, 228, Color.new(230, 222, 205))
				Graphics.fillEmptyRect(15, 305, 12, 228, Color.new(100, 80, 60))
			end
			
			GPU_DrawText(160, 52, "DAILY INSPECTION REPORT", Color.new(82, 34, 34), "c", 320, NORMAL_FONT, 8)
			Graphics.fillRect(35, 285, 61, 63, Color.new(82, 34, 34))
			
			GPU_DrawText(35, 68, "SALARY ("..DAY_CORRECT_COUNT.." APPROVED):", Color.new(40, 40, 40), "l", 320, SMALL_FONT, 7)
			GPU_DrawText(280, 68, "+" .. tostring(DAY_CORRECT_COUNT * 5) .. " CREDITS", Color.new(20, 95, 20), "r", 320, NORMAL_FONT, 8)
			
			GPU_DrawText(35, 86, "CITATIONS / PENALTIES:", Color.new(180, 50, 50), "l", 320, SMALL_FONT, 7)
			GPU_DrawText(280, 86, tostring(DAY_MISTAKES_COUNT), Color.new(180, 50, 50), "r", 320, NORMAL_FONT, 8)
			
			GPU_DrawText(35, 104, "RENT & FOOD EXPENSES:", Color.new(140, 50, 50), "l", 320, SMALL_FONT, 7)
			GPU_DrawText(280, 104, "-" .. tostring(DAY_SUMMARY_EXPENSES or 20) .. " CREDITS", Color.new(160, 40, 40), "r", 320, NORMAL_FONT, 8)
			
			GPU_DrawText(35, 124, "SAVINGS BALANCE:", Color.new(30, 30, 30), "l", 320, SMALL_FONT, 7)
			GPU_DrawText(280, 124, tostring(SCORE) .. " CREDITS", Color.new(20, 95, 20), "r", 320, NORMAL_FONT, 8)
			
			DAY_NEXT_BTN = DAY_NEXT_BTN or {touched = false}
			GPU_DrawText(160, 142, "DAY "..CURRENT_DAY.." COMPLETE!", Color.new(25, 100, 25), "c", 320, NORMAL_FONT, 8)
			
			if FADE_STATE == "NONE" and TOUCHx>=45 and TOUCHx<=275 and TOUCHy>=156 and TOUCHy<=184 then
				Graphics.fillRect(45,275,156,184,Color.new(80,160,80))
				DAY_NEXT_BTN.touched = true
			else
				Graphics.fillRect(45,275,156,184,Color.new(45,120,45))
			end
			Graphics.fillEmptyRect(45,275,156,184,Color.new(20,60,20))
			GPU_DrawText(160, 168, "NEXT DAY (A)", WHITE, "c", 320, NORMAL_FONT, 8)
			
			if FADE_STATE == "NONE" and ((TOUCHx==0 and TOUCHy==0 and DAY_NEXT_BTN.touched) or (Controls.check(pad, KEY_A) and not Controls.check(oldpad, KEY_A))) then
				DAY_NEXT_BTN.touched = false
				if DAYSUMMARY_BKG_TEX then Graphics.freeImage(DAYSUMMARY_BKG_TEX); DAYSUMMARY_BKG_TEX = nil end
				if DAYSUMMARY_TOP_TEX then Graphics.freeImage(DAYSUMMARY_TOP_TEX); DAYSUMMARY_TOP_TEX = nil end
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
			
			DAY_MENU_BTN = DAY_MENU_BTN or {touched = false}
			if FADE_STATE == "NONE" and TOUCHx>=55 and TOUCHx<=265 and TOUCHy>=192 and TOUCHy<=220 then
				Graphics.fillRect(55,265,192,220,Color.new(100,100,100))
				DAY_MENU_BTN.touched = true
			else
				Graphics.fillRect(55,265,192,220,Color.new(70,70,70))
			end
			Graphics.fillEmptyRect(55,265,192,220,Color.new(30,30,30))
			GPU_DrawText(160, 204, "MAIN MENU (B)", WHITE, "c", 320, NORMAL_FONT, 8)
			
			if FADE_STATE == "NONE" and ((TOUCHx==0 and TOUCHy==0 and DAY_MENU_BTN.touched) or (Controls.check(pad, KEY_B) and not Controls.check(oldpad, KEY_B))) then
				DAY_MENU_BTN.touched = false
				if DAYSUMMARY_BKG_TEX then Graphics.freeImage(DAYSUMMARY_BKG_TEX); DAYSUMMARY_BKG_TEX = nil end
				if DAYSUMMARY_TOP_TEX then Graphics.freeImage(DAYSUMMARY_TOP_TEX); DAYSUMMARY_TOP_TEX = nil end
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