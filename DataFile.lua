WRONGTABLE = {
	[1]="Nothing",
	[2]="Nothing",
	[3]="Nothing",
	[4]="Date of birth is inconsistent",
	[5]="Invalid issuing city",
	[6]="District name",
	[7]="Name is inconsistent",
	[8]="Invalid Sex",
	[9]="ID number is inconsistent",
	[10]="Invalid Height",
	[11]="Invalid Weight",
	[12]="Non-matching photo",
	[13]="Nothing",
	[14]="Invalid expiration date",
	[15]="Invalid expiration date",
	[16]="Forged or missing seal",
	[17]="Forged or missing seal",
	[18]="Entry permit duration mismatch"
}

NATION_NAMES = {
	[1] = "ANTEGRIA",
	[2] = "ARSTOTZKA",
	[3] = "IMPOR",
	[4] = "KOLECHIA",
	[5] = "REPUBLIA",
	[6] = "UNITED FEDERATION",
	[7] = "ARSTOTZKA",
	[8] = "OBRISTAN"
}

function GET_NATION_NAME(passport_id)
	return NATION_NAMES[passport_id] or "UNKNOWN"
end
CITY={
	ANTEGRIA={
		"St. Marmero",
		"Glorian",
		"Outer Grouse"
	},
	ARSTOTZKA={
		"Orvech Vonor",
		"East Grestin",
		"Paradizna"
	},
	IMPOR={
		"Enkyo",
		"Haihan",
		"Tsunkeido"
	},
	KOLECHIA={
		"Yurko City",
		"Vedor",
		"West Grestin"
	},
	REPUBLIA={
		"True Glorian",
		"Lesrenadi",
		"Bostan"
	},
	UF={
		"Great Rapid",
		"Shingleton",
		"Korista City"
	},
	FAKE={
		"NOTHING",
		"NOTHING",
		"NOTHING"
	},
	OBRISTAN={
		"Skal",
		"Lorndaz",
		"Mergerous"
	}
}
FAKECITY={
	ANTEGRIA={
		"St. Maramere",
		"Orvech Vonor",
		"Outer Grooose"
	},
	ARSTOTZKA={
		"Orvech Valter",
		"West Grestin",
		"Tsunkeido"
	},
	IMPOR={
		"Inkyu",
		"Yurko City",
		"True Glorian"
	},
	KOLECHIA={
		"True Glorian",
		"Vedro",
		"True Glorian"
	},
	REPUBLIA={
		"False Glorian",
		"Great Rapid",
		"Boostland"
	},
	UF={
		"Great Rapeed",
		"Skal",
		"Coristah City"
	},
	FAKE={
		"NOTHING",
		"NOTHING",
		"NOTHING"
	},
	OBRISTAN={
		"Schal",
		"Lorpdeez",
		"Nerkerous"
	}
}
FORDOCUMENT={
	[1]=CITY.ANTEGRIA,
	[2]=CITY.ARSTOTZKA,
	[3]=CITY.IMPOR,
	[4]=CITY.KOLECHIA,
	[5]=CITY.REPUBLIA,
	[6]=CITY.UF,
	[7]=CITY.FAKE,
	[8]=CITY.OBRISTAN
}
FORDOCUMENTFAKE={
	[1]=FAKECITY.ANTEGRIA,
	[2]=FAKECITY.ARSTOTZKA,
	[3]=FAKECITY.IMPOR,
	[4]=FAKECITY.KOLECHIA,
	[5]=FAKECITY.REPUBLIA,
	[6]=FAKECITY.UF,
	[7]=FAKECITY.FAKE,
	[8]=FAKECITY.OBRISTAN
}
MNAMES={
	FN={
		"Aaron",
		"Abbas",
		"Adam",
		"Aleksandar",
		"Ali",
		"Artur",
		"Ben",
		"Brandon",
		"Dmitry",
		"Mark",
		"Michael",
		"Nazar",
		"Narek",
		"Nikolay",
		"Oliver",
		"Noah",
		"Oscar",
		"Philip",
		"Raphael",
		"Riccardo",
		"Richard",
		"Roman",
		"Victor",
		"Zak",
		"Robert"
	},
	LN={
		"Suleymanov",
		"Ismayilov",
		"Ibrahimov",
		"Dimitrov",
		"Petrov",
		"Kastrati",
		"Bauer",
		"Pichler",
		"Leitner",
		"Schmidt",
		"Wolf",
		"Mammadov",
		"Rasulov",
		"Kozlov",
		"Simon"
	}
}
FNAMES={
	FN={
		"Abbey",
		"Alice",
		"Alexa",
		"Alexandra",
		"Alina",
		"Amy",
		"Boglarka",
		"Brianna",
		"Brooklyn",
		"Chloe",
		"Ema",
		"Emily",
		"Fiona",
		"Gabriela",
		"Isobella",
		"Johanna",
		"Karin",
		"Katie",
		"Katerina",
		"Lana",
		"Lisa",
		"Nadia",
		"Mia",
		"Olivia",
		"Polina",
		"Rin",
		"Sahra",
		"Sakura",
		"Viktoria",
		"Zoe"
	},
	LN={
		"Suleymanova",
		"Ismayilova",
		"Ibrahimova",
		"Dimitrova",
		"Petrova",
		"Kastrati",
		"Bauer",
		"Pichler",
		"Leitner",
		"Schmidt",
		"Wolf",
		"Mammadova",
		"Rasulova",
		"Kozlova",
		"Simon"
	}
}
DISTRICTS={
	"Altan",
	"Vescillo",
	"Burnton",
	"Octovalis",
	"Gennistora",
	"Lendiforma",
	"Wozenfield",
	"Fardesto"
}
FAKEDISTRICTS={
	"Altona",
	"Vesciyo",
	"Fireton",
	"Septemvalis",
	"Genesistora",
	"Landandform",
	"Wozenfelt",
	"Fordestroy"
}
FIELDS={
	"Accounting",
	"Agriculture",
	"Architecture",
	"Aviation",
	"Construction",
	"Dentistry",
	"Drafting",
	"Engineering",
	"Fine arts",
	"Fishing",
	"Food service",
	"General labor",
	"Healthcare",
	"Manufacturing",
	"Research",
	"Sports",
	"Statistics",
	"Surveying"
}

-- [ARCADE MODE DAY CONFIG]
-- Static full-checkpoint ruleset used by all three arcade modes (Timed, Perfection, Endurance).
-- Mirrors the advanced checkpoint rules (Days 4+) so the desk bulletin is accurate and consistent.
ARCADE_DAY_CONFIG = {
	date             = "26.11.1982",
	headline         = "CHECKPOINT ACTIVE",
	subline          = "Standard border inspection rules apply.",
	bulletin_rules   = {
		"ARSTOTZKA: VALID PASSPORT + ID CARD",
		"FOREIGNERS: ENTRY PERMIT REQUIRED",
		"WORKERS: VALID WORK PASS REQUIRED",
		"CHECK ALL SEALS AND EXPIRATION DATES"
	},
	allow_foreigners = true,
	require_permit   = true,
	require_workpass = true,
	allowed_warnings = 2,
	daily_expenses   = 0,
	duration_sec     = 600 -- 10 minutes (Timed mode timer ceiling)
}

DAYS_CONFIG = {
	[1] = {
		date = "23.11.1982",
		headline = "GRESTIN BORDER REOPENS",
		subline = "Six-year war with Kolechia is over.",
		bulletin_rules = {
			"ARSTOTZKAN CITIZENS ONLY",
			"DENY ALL FOREIGNERS",
			"CHECK EXPIRATION AND VALIDITY"
		},
		allow_foreigners = false,
		require_permit   = false,
		require_workpass = false,
		allowed_warnings = 2,
		daily_expenses   = 20,
		duration_sec     = 180 -- 3 real minutes (09:00 - 18:00)
	},
	[2] = {
		date = "24.11.1982",
		headline = "FOREIGNERS NOW ALLOWED",
		subline = "Ministry permits entry for non-citizens.",
		bulletin_rules = {
			"FOREIGNERS REQUIRE VALID PASSPORT",
			"CHECK EXPIRATION DATE AND ISSUING CITY",
			"DENY FORGED OR EXPIRED PASSPORTS"
		},
		allow_foreigners = true,
		require_permit   = false,
		require_workpass = false,
		allowed_warnings = 2,
		daily_expenses   = 20,
		duration_sec     = 180
	},
	[3] = {
		date = "25.11.1982",
		headline = "SECURITY MEASURES TIGHTENED",
		subline = "New entry permit required for foreigners.",
		bulletin_rules = {
			"FOREIGNERS REQUIRE ENTRY PERMIT",
			"VERIFY MATCHING NAME AND ID NUMBER",
			"CHECK MINISTRY OF ADMISSION (MOA) SEAL"
		},
		allow_foreigners = true,
		require_permit   = true,
		require_workpass = false,
		allowed_warnings = 1,
		daily_expenses   = 20,
		duration_sec     = 180
	},
	[4] = {
		date = "26.11.1982",
		headline = "LABOR RESTRICTIONS IN EFFECT",
		subline = "Workers require valid Arstotzkan work pass.",
		bulletin_rules = {
			"WORKERS REQUIRE VALID WORK PASS",
			"CHECK EXPIRATION AND LABOR SEAL (MOL)",
			"ALL DOCUMENTS MUST MATCH"
		},
		allow_foreigners = true,
		require_permit   = true,
		require_workpass = true,
		allowed_warnings = 1,
		daily_expenses   = 20,
		duration_sec     = 180
	}
}

function GET_DAY_CONFIG(day)
	day = tonumber(day) or 1
	if day < 1 then day = 1 end

	if day <= 4 and DAYS_CONFIG and DAYS_CONFIG[day] then
		local cfg = DAYS_CONFIG[day]
		if not cfg.daily_expenses then
			cfg.daily_expenses = 20
		end
		if not cfg.allowed_warnings then
			cfg.allowed_warnings = (day >= 3) and 1 or 2
		end
		return cfg
	end

	-- Procedural Deterministic Generator for Days 5+
	local tier = 1
	local daily_expenses = 20
	if day >= 16 then
		tier = 3
		daily_expenses = 30
	elseif day >= 9 then
		tier = 2
		daily_expenses = 25
	end

	-- Calendar Date calculation (base: 27.11.1982 for Day 5)
	local offset = day - 5
	local d = 27 + offset
	local m = 11
	local y = 1982
	while d > 30 do
		d = d - 30
		m = m + 1
		if m > 12 then
			m = 1
			y = y + 1
		end
	end
	local d_str = (d < 10 and "0" .. d or tostring(d)) .. "." .. (m < 10 and "0" .. m or tostring(m)) .. "." .. tostring(y)

	-- Deterministic PRNG from day seed (31-bit LCG)
	local prng = (day * 1103515245 + 12345) % 2147483648
	local embargo_nation = nil
	local wanted_name = nil
	local bulletin_rules = {
		"ALL FOREIGNERS REQUIRE ENTRY PERMIT",
		"WORKERS REQUIRE VALID WORK PASS"
	}

	local FOREIGN_NATIONS = { "ANTEGRIA", "IMPOR", "KOLECHIA", "REPUBLIA", "UNITED FEDERATION", "OBRISTAN" }

	if tier >= 1 and (prng % 3 == 0) then
		local nat_idx = (math.floor(prng / 7) % #FOREIGN_NATIONS) + 1
		embargo_nation = FOREIGN_NATIONS[nat_idx]
		table.insert(bulletin_rules, "DENY ALL CITIZENS OF " .. embargo_nation)
	end

	if tier >= 2 and (prng % 2 == 0) then
		local w_first = MNAMES.FN[(math.floor(prng / 13) % #MNAMES.FN) + 1]
		local w_last = MNAMES.LN[(math.floor(prng / 17) % #MNAMES.LN) + 1]
		wanted_name = w_first .. " " .. w_last
		table.insert(bulletin_rules, "WANTED CRIMINAL: " .. wanted_name)
	end

	table.insert(bulletin_rules, "VERIFY PURPOSE AND DURATION IN TRANSCRIPT")

	local headline = "BORDER SECURITY TIGHTENED"
	local subline = "Ministry of Admission issues high alert directives."
	if embargo_nation then
		headline = "RESTRICTIONS ON " .. embargo_nation
		subline = "Suspension of all diplomatic entry privileges."
	elseif wanted_name then
		headline = "FUGITIVE AT LARGE: " .. string.upper(wanted_name)
		subline = "State Police notify border checkpoints for apprehension."
	end

	return {
		date             = d_str,
		headline         = headline,
		subline          = subline,
		bulletin_rules   = bulletin_rules,
		allow_foreigners = true,
		require_permit   = true,
		require_workpass = true,
		embargo_nation   = embargo_nation,
		wanted_name      = wanted_name,
		daily_expenses   = daily_expenses,
		allowed_warnings = 1,
		duration_sec     = 180
	}
end

--------------------------------------------------------------------------------
-- INSPECTION MODE DATA: HOTSPOTS, ANCHORS & INTERROGATION DIALOGUES
--------------------------------------------------------------------------------

INSPECTION_HOTSPOTS_PASSPORT = {
	[1] = {
		{ id = "PASSPORT.NATION",   cat = "NATION",   xo = 8,  yo = 88,  w = 72,  h = 10 },
		{ id = "PASSPORT.DOB",      cat = "DOB",      xo = 7,  yo = 100, w = 72,  h = 8 },
		{ id = "PASSPORT.GENDER",   cat = "GENDER",   xo = 7,  yo = 109, w = 72,  h = 8 },
		{ id = "PASSPORT.CITY",     cat = "CITY",     xo = 7,  yo = 118, w = 72,  h = 8 },
		{ id = "PASSPORT.EXP_DATE", cat = "EXP_DATE", xo = 7,  yo = 127, w = 72,  h = 8 },
		{ id = "PASSPORT.NAME",     cat = "NAME",     xo = 7,  yo = 137, w = 116, h = 9 },
		{ id = "PASSPORT.ID_NUM",   cat = "ID_NUM",   xo = 50, yo = 147, w = 72,  h = 10 },
		{ id = "PASSPORT.PHOTO",    cat = "PHOTO",    xo = 83, yo = 88,  w = 40,  h = 48 }
	},
	[2] = {
		{ id = "PASSPORT.NAME",     cat = "NAME",     xo = 8,  yo = 85,  w = 115, h = 9 },
		{ id = "PASSPORT.DOB",      cat = "DOB",      xo = 47, yo = 97,  w = 76,  h = 8 },
		{ id = "PASSPORT.GENDER",   cat = "GENDER",   xo = 47, yo = 105, w = 76,  h = 8 },
		{ id = "PASSPORT.CITY",     cat = "CITY",     xo = 47, yo = 113, w = 76,  h = 8 },
		{ id = "PASSPORT.EXP_DATE", cat = "EXP_DATE", xo = 47, yo = 121, w = 76,  h = 8 },
		{ id = "PASSPORT.NATION",   cat = "NATION",   xo = 72, yo = 131, w = 52,  h = 12 },
		{ id = "PASSPORT.ID_NUM",   cat = "ID_NUM",   xo = 8,  yo = 146, w = 80,  h = 10 },
		{ id = "PASSPORT.PHOTO",    cat = "PHOTO",    xo = 8,  yo = 98,  w = 40,  h = 48 }
	},
	[3] = {
		{ id = "PASSPORT.NAME",     cat = "NAME",     xo = 8,  yo = 84,  w = 115, h = 9 },
		{ id = "PASSPORT.DOB",      cat = "DOB",      xo = 47, yo = 95,  w = 76,  h = 8 },
		{ id = "PASSPORT.GENDER",   cat = "GENDER",   xo = 47, yo = 103, w = 76,  h = 8 },
		{ id = "PASSPORT.CITY",     cat = "CITY",     xo = 47, yo = 111, w = 76,  h = 8 },
		{ id = "PASSPORT.EXP_DATE", cat = "EXP_DATE", xo = 47, yo = 119, w = 76,  h = 8 },
		{ id = "PASSPORT.NATION",   cat = "NATION",   xo = 7,  yo = 145, w = 40,  h = 12 },
		{ id = "PASSPORT.ID_NUM",   cat = "ID_NUM",   xo = 58, yo = 143, w = 65,  h = 10 },
		{ id = "PASSPORT.PHOTO",    cat = "PHOTO",    xo = 9,  yo = 96,  w = 40,  h = 48 }
	},
	[4] = {
		{ id = "PASSPORT.NATION",   cat = "NATION",   xo = 60, yo = 86,  w = 64,  h = 9 },
		{ id = "PASSPORT.NAME",     cat = "NAME",     xo = 8,  yo = 96,  w = 115, h = 9 },
		{ id = "PASSPORT.DOB",      cat = "DOB",      xo = 47, yo = 106, w = 76,  h = 8 },
		{ id = "PASSPORT.GENDER",   cat = "GENDER",   xo = 47, yo = 114, w = 76,  h = 8 },
		{ id = "PASSPORT.CITY",     cat = "CITY",     xo = 47, yo = 122, w = 76,  h = 8 },
		{ id = "PASSPORT.EXP_DATE", cat = "EXP_DATE", xo = 47, yo = 130, w = 76,  h = 8 },
		{ id = "PASSPORT.ID_NUM",   cat = "ID_NUM",   xo = 52, yo = 146, w = 70,  h = 10 },
		{ id = "PASSPORT.PHOTO",    cat = "PHOTO",    xo = 8,  yo = 107, w = 40,  h = 48 }
	},
	[5] = {
		{ id = "PASSPORT.NAME",     cat = "NAME",     xo = 8,  yo = 85,  w = 115, h = 9 },
		{ id = "PASSPORT.DOB",      cat = "DOB",      xo = 6,  yo = 97,  w = 76,  h = 8 },
		{ id = "PASSPORT.GENDER",   cat = "GENDER",   xo = 6,  yo = 105, w = 76,  h = 8 },
		{ id = "PASSPORT.CITY",     cat = "CITY",     xo = 6,  yo = 113, w = 76,  h = 8 },
		{ id = "PASSPORT.EXP_DATE", cat = "EXP_DATE", xo = 6,  yo = 121, w = 76,  h = 8 },
		{ id = "PASSPORT.NATION",   cat = "NATION",   xo = 7,  yo = 134, w = 70,  h = 12 },
		{ id = "PASSPORT.ID_NUM",   cat = "ID_NUM",   xo = 52, yo = 146, w = 70,  h = 10 },
		{ id = "PASSPORT.PHOTO",    cat = "PHOTO",    xo = 85, yo = 96,  w = 40,  h = 48 }
	},
	[6] = {
		{ id = "PASSPORT.NATION",   cat = "NATION",   xo = 24, yo = 86,  w = 84,  h = 9 },
		{ id = "PASSPORT.NAME",     cat = "NAME",     xo = 8,  yo = 96,  w = 115, h = 9 },
		{ id = "PASSPORT.DOB",      cat = "DOB",      xo = 47, yo = 106, w = 76,  h = 8 },
		{ id = "PASSPORT.GENDER",   cat = "GENDER",   xo = 47, yo = 114, w = 76,  h = 8 },
		{ id = "PASSPORT.CITY",     cat = "CITY",     xo = 47, yo = 122, w = 76,  h = 8 },
		{ id = "PASSPORT.EXP_DATE", cat = "EXP_DATE", xo = 47, yo = 130, w = 76,  h = 8 },
		{ id = "PASSPORT.ID_NUM",   cat = "ID_NUM",   xo = 52, yo = 146, w = 70,  h = 10 },
		{ id = "PASSPORT.PHOTO",    cat = "PHOTO",    xo = 8,  yo = 106, w = 40,  h = 48 }
	},
	[8] = {
		{ id = "PASSPORT.NATION",   cat = "NATION",   xo = 36, yo = 86,  w = 58,  h = 9 },
		{ id = "PASSPORT.NAME",     cat = "NAME",     xo = 8,  yo = 96,  w = 115, h = 9 },
		{ id = "PASSPORT.DOB",      cat = "DOB",      xo = 6,  yo = 110, w = 76,  h = 8 },
		{ id = "PASSPORT.GENDER",   cat = "GENDER",   xo = 6,  yo = 118, w = 76,  h = 8 },
		{ id = "PASSPORT.CITY",     cat = "CITY",     xo = 6,  yo = 126, w = 76,  h = 8 },
		{ id = "PASSPORT.EXP_DATE", cat = "EXP_DATE", xo = 6,  yo = 134, w = 76,  h = 8 },
		{ id = "PASSPORT.ID_NUM",   cat = "ID_NUM",   xo = 8,  yo = 144, w = 70,  h = 10 },
		{ id = "PASSPORT.PHOTO",    cat = "PHOTO",    xo = 84, yo = 107, w = 40,  h = 48 }
	}
}
INSPECTION_HOTSPOTS_PASSPORT[7] = INSPECTION_HOTSPOTS_PASSPORT[2]

INSPECTION_HOTSPOTS = {
	PASSPORT = INSPECTION_HOTSPOTS_PASSPORT[1],
	ENTRYPERMIT = {
		{ id = "PERMIT.NAME",     cat = "NAME",     xo = 15, yo = 84,  w = 120, h = 14 },
		{ id = "PERMIT.ID_NUM",   cat = "ID_NUM",   xo = 15, yo = 115, w = 120, h = 14 },
		{ id = "PERMIT.PURPOSE",  cat = "PURPOSE",  xo = 15, yo = 132, w = 120, h = 14 },
		{ id = "PERMIT.DURATION", cat = "DURATION", xo = 15, yo = 148, w = 120, h = 14 },
		{ id = "PERMIT.EXP_DATE", cat = "EXP_DATE", xo = 15, yo = 164, w = 120, h = 14 },
		{ id = "PERMIT.SEAL",     cat = "SEAL_MOA", xo = 10, yo = 11,  w = 45,  h = 35 }
	},
	IDCARD = {
		{ id = "IDCARD.DISTRICT", cat = "DISTRICT", xo = 6,  yo = 8,   w = 114, h = 9 },
		{ id = "IDCARD.NAME",     cat = "NAME",     xo = 45, yo = 18,  w = 77,  h = 19 },
		{ id = "IDCARD.DOB",      cat = "DOB",      xo = 45, yo = 38,  w = 77,  h = 9 },
		{ id = "IDCARD.HEIGHT",   cat = "HEIGHT",   xo = 45, yo = 48,  w = 77,  h = 9 },
		{ id = "IDCARD.WEIGHT",   cat = "WEIGHT",   xo = 45, yo = 58,  w = 77,  h = 9 },
		{ id = "IDCARD.PHOTO",    cat = "PHOTO",    xo = 4,  yo = 17,  w = 40,  h = 48 }
	},
	WORKPASS = {
		{ id = "WORKPASS.NAME",     cat = "NAME",     xo = 8,  yo = 59,  w = 125, h = 14 },
		{ id = "WORKPASS.FIELD",    cat = "FIELD",    xo = 8,  yo = 75,  w = 125, h = 14 },
		{ id = "WORKPASS.EXP_DATE", cat = "EXP_DATE", xo = 8,  yo = 91,  w = 125, h = 14 },
		{ id = "WORKPASS.SEAL",     cat = "SEAL_MOL", xo = 6,  yo = 7,   w = 45,  h = 35 }
	},
	ENTRYTICKET = {
		{ id = "TICKET.EXP_DATE", cat = "EXP_DATE", xo = 65, yo = 26,  w = 60,  h = 14 }
	}
}

INSPECTION_HOTSPOTS_RULEBOOK = {
	[2] = {
		{ id = "RULEBOOK.RULE_FOR",  cat = "RULE_FOREIGNERS", xo = 120, yo = 40, w = 110, h = 18 },
		{ id = "RULEBOOK.RULE_DATE", cat = "TODAY_DATE",      xo = 120, yo = 60, w = 110, h = 18 },
		{ id = "RULEBOOK.RULE_SEAL", cat = "RULE_SEAL",       xo = 120, yo = 80, w = 110, h = 25 }
	},
	[4] = {
		-- Antegria Issuing Cities
		{ id = "RULEBOOK.CITY_ANTEGRIA_1", cat = "CITY", xo = 38, yo = 45, w = 68, h = 9 },
		{ id = "RULEBOOK.CITY_ANTEGRIA_2", cat = "CITY", xo = 38, yo = 55, w = 68, h = 9 },
		{ id = "RULEBOOK.CITY_ANTEGRIA_3", cat = "CITY", xo = 38, yo = 65, w = 68, h = 9 },
		-- Impor Issuing Cities
		{ id = "RULEBOOK.CITY_IMPOR_1", cat = "CITY", xo = 168, yo = 45, w = 48, h = 9 },
		{ id = "RULEBOOK.CITY_IMPOR_2", cat = "CITY", xo = 168, yo = 55, w = 48, h = 9 },
		{ id = "RULEBOOK.CITY_IMPOR_3", cat = "CITY", xo = 168, yo = 65, w = 48, h = 9 }
	},
	[5] = {
		-- Arstotzka Districts
		{ id = "RULEBOOK.DISTRICT_1", cat = "DISTRICT", xo = 25, yo = 50,  w = 60, h = 8 },
		{ id = "RULEBOOK.DISTRICT_2", cat = "DISTRICT", xo = 25, yo = 60,  w = 60, h = 8 },
		{ id = "RULEBOOK.DISTRICT_3", cat = "DISTRICT", xo = 25, yo = 70,  w = 60, h = 8 },
		{ id = "RULEBOOK.DISTRICT_4", cat = "DISTRICT", xo = 25, yo = 80,  w = 60, h = 8 },
		{ id = "RULEBOOK.DISTRICT_5", cat = "DISTRICT", xo = 25, yo = 90,  w = 60, h = 8 },
		{ id = "RULEBOOK.DISTRICT_6", cat = "DISTRICT", xo = 25, yo = 100, w = 60, h = 8 },
		{ id = "RULEBOOK.DISTRICT_7", cat = "DISTRICT", xo = 25, yo = 110, w = 60, h = 8 },
		{ id = "RULEBOOK.DISTRICT_8", cat = "DISTRICT", xo = 25, yo = 120, w = 60, h = 8 },
		-- Arstotzka Issuing Cities
		{ id = "RULEBOOK.CITY_ARSTOTZKA_1", cat = "CITY", xo = 138, yo = 91,  w = 60, h = 8 },
		{ id = "RULEBOOK.CITY_ARSTOTZKA_2", cat = "CITY", xo = 138, yo = 101, w = 60, h = 8 },
		{ id = "RULEBOOK.CITY_ARSTOTZKA_3", cat = "CITY", xo = 138, yo = 111, w = 60, h = 8 }
	},
	[6] = {
		-- Kolechia Issuing Cities
		{ id = "RULEBOOK.CITY_KOLECHIA_1", cat = "CITY", xo = 38, yo = 45, w = 68, h = 9 },
		{ id = "RULEBOOK.CITY_KOLECHIA_2", cat = "CITY", xo = 38, yo = 55, w = 68, h = 9 },
		{ id = "RULEBOOK.CITY_KOLECHIA_3", cat = "CITY", xo = 38, yo = 65, w = 68, h = 9 },
		-- Obristan Issuing Cities
		{ id = "RULEBOOK.CITY_OBRISTAN_1", cat = "CITY", xo = 168, yo = 45, w = 48, h = 9 },
		{ id = "RULEBOOK.CITY_OBRISTAN_2", cat = "CITY", xo = 168, yo = 55, w = 48, h = 9 },
		{ id = "RULEBOOK.CITY_OBRISTAN_3", cat = "CITY", xo = 168, yo = 65, w = 48, h = 9 }
	},
	[7] = {
		-- Republia Issuing Cities
		{ id = "RULEBOOK.CITY_REPUBLIA_1", cat = "CITY", xo = 38, yo = 45, w = 68, h = 9 },
		{ id = "RULEBOOK.CITY_REPUBLIA_2", cat = "CITY", xo = 38, yo = 55, w = 68, h = 9 },
		{ id = "RULEBOOK.CITY_REPUBLIA_3", cat = "CITY", xo = 38, yo = 65, w = 68, h = 9 },
		-- United Federation Issuing Cities
		{ id = "RULEBOOK.CITY_UF_1", cat = "CITY", xo = 164, yo = 45, w = 58, h = 9 },
		{ id = "RULEBOOK.CITY_UF_2", cat = "CITY", xo = 164, yo = 55, w = 58, h = 9 },
		{ id = "RULEBOOK.CITY_UF_3", cat = "CITY", xo = 164, yo = 65, w = 58, h = 9 }
	},
	[8] = {
		{ id = "RULEBOOK.SEAL_MOA", cat = "SEAL_MOA", xo = 15,  yo = 100, w = 86, h = 42 },
		{ id = "RULEBOOK.TEXT_MOA", cat = "SEAL_MOA", xo = 15,  yo = 25,  w = 86, h = 70 },
		{ id = "RULEBOOK.SEAL_MOL", cat = "SEAL_MOL", xo = 133, yo = 22,  w = 92, h = 78 },
		{ id = "RULEBOOK.TEXT_MOL", cat = "SEAL_MOL", xo = 133, yo = 104, w = 92, h = 42 }
	}
}

INSPECTION_ANCHORS = {
	{ id = "ANCHOR.FACE", cat = "FACE",       x = 135, y = 4, w = 56, h = 20, label = "ENTRANT" },
	{ id = "ANCHOR.DATE", cat = "TODAY_DATE",  x = 200, y = 4, w = 55, h = 20, label = "TODAY" }
}

INSPECTOR_ACCUSATIONS = {
	[4]  = "The date of birth does not match.",
	[5]  = "This issuing city is not valid.",
	[6]  = "This district does not exist.",
	[7]  = "The name does not match your documents.",
	[8]  = "Your appearance does not match the listed sex.",
	[9]  = "The ID number does not match.",
	[10] = "Your height does not match your ID card.",
	[11] = "Your weight does not match your ID card.",
	[12] = "You do not look like your photo.",
	[14] = "Your passport has expired.",
	[15] = "Your entry permit has expired.",
	[16] = "The labor seal appears forged.",
	[17] = "The admission seal appears forged.",
	[18] = "Your stated duration does not match the permit.",
	embargo    = "Your nation is currently under embargo.",
	wanted     = "You match the description of a wanted criminal.",
	foreigners = "Entry is restricted to Arstotzkan citizens.",
	default    = "There is a discrepancy in your documents."
}

ENTRANT_RESPONSES = {
	[4]        = { "I am not sure why it is different.", "There must be a mistake." },
	[5]        = { "That is where I was born!", "I do not understand the problem." },
	[6]        = { "I have always lived there!", "Check your records again." },
	[7]        = { "I recently changed my name.", "It is a family name." },
	[8]        = { "I assure you, these are my documents.", "Please, there is no issue." },
	[9]        = { "The numbers should match!", "Let me look at that again..." },
	[10]       = { "I must have grown since then.", "The card is old." },
	[11]       = { "I have lost weight recently.", "The measurement was wrong." },
	[12]       = { "The photo is old. It is still me.", "I have changed since then." },
	[14]       = { "I had no time to renew it!", "Please, I did not realize!" },
	[15]       = { "I thought it was still valid!", "Can you make an exception?" },
	[16]       = { "I got this from the Ministry!", "It should be authentic!" },
	[17]       = { "The seal was applied at the office!", "This is legitimate!" },
	[18]       = { "That is what I was told!", "The permit should be correct." },
	embargo    = { "I have done nothing wrong!", "Please, I am not a threat!" },
	wanted     = { "You have the wrong person!", "I am innocent, I swear!" },
	foreigners = { "I only wanted to visit!", "Please let me through!" },
	default    = { "I do not understand.", "There must be some mistake." }
}


