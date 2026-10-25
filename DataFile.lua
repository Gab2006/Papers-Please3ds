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
		daily_expenses   = 20,
		duration_sec     = 180 -- 3 minuti reali (09:00 - 18:00)
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
		duration_sec     = 180
	}
end
