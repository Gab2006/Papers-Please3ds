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
	[17]="Forged or missing seal"
}
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
			"SOLO CITTADINI DI ARSTOTZKA AMMESSI",
			"RESPINGERE TUTTI GLI STRANIERI",
			"CONTROLLA SCADENZA E VALIDITA' DOCUMENTI"
		},
		allow_foreigners = false,
		require_permit   = false,
		require_workpass = false,
		duration_sec     = 180 -- 3 minuti reali (09:00 - 18:00)
	},
	[2] = {
		date = "24.11.1982",
		headline = "FOREIGNERS NOW ALLOWED",
		subline = "Ministry permits entry for non-citizens.",
		bulletin_rules = {
			"STRANIERI AMMESSI CON PASSAPORTO VALIDO",
			"CONTROLLA DATA DI SCADENZA E CITTA'",
			"RESPINGI PASSAPORTI CONTRAFFATTI O SCADUTI"
		},
		allow_foreigners = true,
		require_permit   = false,
		require_workpass = false,
		duration_sec     = 180
	},
	[3] = {
		date = "25.11.1982",
		headline = "SECURITY MEASURES TIGHTENED",
		subline = "New entry permit required for foreigners.",
		bulletin_rules = {
			"STRANIERI DEVONO PRESENTARE ENTRY PERMIT",
			"CONFRONTA NOME E NUMERO ID TRA DOCUMENTI",
			"VERIFICA SIGILLO MINISTERO AMMISSIONE (MOA)"
		},
		allow_foreigners = true,
		require_permit   = true,
		require_workpass = false,
		duration_sec     = 180
	},
	[4] = {
		date = "26.11.1982",
		headline = "LABOR RESTRICTIONS IN EFFECT",
		subline = "Workers require valid Arstotzkan work pass.",
		bulletin_rules = {
			"SCOPO LAVORO RICHIEDE WORK PASS VALIDO",
			"VERIFICA SCADENZA E SIGILLO LAVORO (MOL)",
			"TUTTI I DOCUMENTI DEVONO COINCIDERE"
		},
		allow_foreigners = true,
		require_permit   = true,
		require_workpass = true,
		duration_sec     = 180
	}
}