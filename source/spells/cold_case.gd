extends TileModifierSpell

func set_status_tooltips():
	status_tooltips = [TileStatus.MYSTERY, TileStatus.FROZEN]

func get_tooltip_context():
	return {}

const FIXED_OPTIONS_CAP := 4

const POOF_COLOR := Color("#009aff")

var start_end_parity := 0

func get_save_data():
	var save = super.get_save_data()
	save["start_end_parity"] = start_end_parity
	return save


func load_save_data(save):
	super.load_save_data(save)
	start_end_parity = save.start_end_parity

const SHORT_WORD_BIGRAMS := {
	OVERALL={
	"eu": 0.106, "rv": 0.106, "sk": 0.110, "ba": 0.110, "oy": 0.114,
	"ci": 0.114, "fi": 0.114, "wn": 0.114, "iz": 0.114, "ft": 0.114, "vo": 0.119,
	"xi": 0.123, "su": 0.123, "cr": 0.123, "go": 0.123, "ct": 0.127, "gu": 0.127,
	"rb": 0.131, "nu": 0.136, "sa": 0.140, "ib": 0.140, "of": 0.144, "cu": 0.148,
	"xe": 0.148, "oe": 0.152, "rc": 0.152, "ze": 0.152, "ga": 0.157, "up": 0.157,
	"da": 0.157, "hr": 0.161, "qu": 0.161, "ik": 0.161, "eb": 0.165, "tc": 0.165,
	"ns": 0.169, "hu": 0.174, "af": 0.174, "tl": 0.174, "rl": 0.174, "uf": 0.178,
	"pl": 0.178, "gi": 0.182, "io": 0.186, "do": 0.186, "rs": 0.191, "bo": 0.191,
	"gl": 0.191, "ye": 0.195, "rk": 0.195, "ef": 0.199, "fe": 0.199, "gh": 0.199,
	"dg": 0.199, "eg": 0.203, "ld": 0.203, "bi": 0.207, "tu": 0.207, "ev": 0.207,
	"ua": 0.212, "rn": 0.216, "ki": 0.216, "si": 0.216, "ew": 0.220, "mm": 0.224,
	"ei": 0.224, "sh": 0.229, "wi": 0.229, "az": 0.229, "pa": 0.233, "lt": 0.233,
	"dl": 0.233, "rd": 0.233, "po": 0.237, "ue": 0.237, "ff": 0.241, "mo": 0.241,
	"rg": 0.246, "aw": 0.250, "ub": 0.250, "if": 0.250, "og": 0.254, "rm": 0.254,
	"vi": 0.254, "ug": 0.258, "au": 0.258, "ud": 0.267, "ca": 0.271, "ov": 0.271,
	"co": 0.271, "ch": 0.271, "ia": 0.271, "bb": 0.271, "dd": 0.275, "wa": 0.275,
	"be": 0.275, "th": 0.279, "mb": 0.279, "ui": 0.292, "gg": 0.292, "bl": 0.296,
	"ep": 0.301, "na": 0.305, "iv": 0.309, "ob": 0.313, "em": 0.318, "no": 0.322,
	"ay": 0.322, "mi": 0.326, "oi": 0.330, "ss": 0.335, "ok": 0.335, "tr": 0.339,
	"rr": 0.339, "ab": 0.343, "pi": 0.343, "pp": 0.343, "nn": 0.356, "ma": 0.356,
	"di": 0.356, "rt": 0.368, "nk": 0.368, "uc": 0.377, "ip": 0.381, "oc": 0.381,
	"ed": 0.385, "we": 0.407, "lu": 0.407, "nc": 0.411, "ec": 0.419, "oa": 0.423,
	"im": 0.432, "mp": 0.432, "av": 0.432, "od": 0.436, "op": 0.436, "ru": 0.445,
	"to": 0.449, "ni": 0.453, "hi": 0.453, "tt": 0.453, "ti": 0.457, "om": 0.466,
	"ce": 0.470, "ak": 0.478, "ag": 0.478, "ig": 0.483, "ap": 0.483, "ul": 0.483,
	"ta": 0.495, "ho": 0.500, "et": 0.508, "id": 0.508, "os": 0.521, "ha": 0.534,
	"ut": 0.542, "nt": 0.550, "um": 0.563, "ow": 0.576, "me": 0.580, "ad": 0.584,
	"ng": 0.589, "es": 0.606, "nd": 0.606, "ie": 0.627, "ot": 0.631, "ir": 0.631,
	"st": 0.644, "ge": 0.644, "he": 0.656, "us": 0.673, "ic": 0.711, "am": 0.724,
	"ol": 0.749, "ck": 0.758, "se": 0.771, "li": 0.775, "ai": 0.779, "ve": 0.783,
	"ac": 0.783, "pe": 0.792, "de": 0.817, "it": 0.821, "ou": 0.826, "is": 0.830,
	"lo": 0.843, "un": 0.851, "ll": 0.851, "ne": 0.860, "ur": 0.893, "la": 0.919,
	"el": 0.932, "ee": 0.978, "as": 0.987, "ro": 1.004, "il": 1.020, "ke": 1.025,
	"on": 1.037, "al": 1.059, "at": 1.080, "en": 1.097, "oo": 1.228, "le": 1.253,
	"ri": 1.258, "re": 1.270, "ra": 1.300, "er": 1.313, "te": 1.317, "or": 1.359,
	"ea": 1.419, "an": 1.601, "ar": 1.939, "in": 2.486,
	},
	START={
	"yu": 0.106, "on": 0.106, "ed": 0.106,
	"us": 0.106, "ic": 0.115, "ko": 0.115, "ow": 0.115, "hy": 0.115, "od": 0.115,
	"ty": 0.124, "av": 0.124, "zi": 0.124, "ze": 0.132, "af": 0.132, "id": 0.132,
	"ev": 0.132, "at": 0.141, "im": 0.141, "au": 0.150, "sq": 0.150, "ag": 0.159,
	"op": 0.177, "ap": 0.185, "ph": 0.185, "aw": 0.194, "wr": 0.194, "ji": 0.203,
	"ce": 0.203, "kn": 0.203, "ya": 0.212, "ou": 0.212, "ai": 0.221, "up": 0.221,
	"yo": 0.221, "ka": 0.221, "el": 0.221, "je": 0.229, "nu": 0.238, "em": 0.238,
	"ci": 0.238, "ye": 0.238, "or": 0.247, "er": 0.247, "tw": 0.265, "ea": 0.265,
	"ab": 0.274, "ke": 0.274, "as": 0.282, "vo": 0.282, "ad": 0.282, "sm": 0.309,
	"ju": 0.327, "ac": 0.335, "sk": 0.335, "am": 0.344, "jo": 0.353, "en": 0.353,
	"gi": 0.362, "ex": 0.362, "ni": 0.380, "fu": 0.380, "ja": 0.397, "gl": 0.406,
	"va": 0.406, "ge": 0.424, "lu": 0.424, "an": 0.459, "ne": 0.468, "ve": 0.477,
	"wo": 0.485, "na": 0.494, "vi": 0.503, "qu": 0.503, "hi": 0.512, "we": 0.512,
	"pl": 0.512, "ki": 0.512, "wh": 0.521, "gu": 0.521, "sn": 0.521, "ar": 0.538,
	"tu": 0.556, "mu": 0.565, "no": 0.565, "sw": 0.565, "ru": 0.574, "in": 0.591,
	"fe": 0.591, "fr": 0.591, "un": 0.600, "th": 0.618, "al": 0.627, "du": 0.635,
	"hu": 0.644, "dr": 0.644, "bi": 0.662, "cu": 0.680, "te": 0.697, "bl": 0.733,
	"sc": 0.733, "su": 0.733, "ri": 0.733, "da": 0.741, "go": 0.750, "fo": 0.768,
	"pu": 0.777, "ti": 0.777, "si": 0.786, "le": 0.803, "pr": 0.821, "fi": 0.821,
	"wi": 0.830, "sl": 0.830, "he": 0.883, "ga": 0.891, "cl": 0.900, "fa": 0.900,
	"me": 0.918, "pi": 0.953, "li": 0.962, "so": 0.962, "fl": 0.962, "mi": 0.971,
	"ro": 0.971, "di": 0.971, "tr": 0.980, "br": 0.997, "pe": 1.006, "wa": 1.015,
	"to": 1.015, "se": 1.033, "do": 1.068, "gr": 1.086, "cr": 1.086, "lo": 1.121,
	"sa": 1.121, "po": 1.121, "ha": 1.165, "bu": 1.174, "sp": 1.183, "la": 1.183,
	"be": 1.200, "ta": 1.244, "ch": 1.262, "ho": 1.306, "ra": 1.333, "sh": 1.333,
	"de": 1.342, "mo": 1.386, "pa": 1.509, "bo": 1.536, "ba": 1.536, "ma": 1.633,
	"ca": 1.668, "st": 1.677, "re": 1.809, "co": 1.889,
},
END = {
	"ca": 0.106, "ph": 0.106,
	"oe": 0.106, "pa": 0.106, "tz": 0.106, "lf": 0.115, "ka": 0.115, "wl": 0.124,
	"ek": 0.124, "ud": 0.124, "mo": 0.124, "bo": 0.124, "ba": 0.124, "co": 0.124,
	"ea": 0.133, "ga": 0.133, "va": 0.133, "ax": 0.133, "ho": 0.133, "vy": 0.133,
	"ok": 0.133, "da": 0.142, "un": 0.151, "he": 0.151, "be": 0.151, "cy": 0.151,
	"gh": 0.151, "ub": 0.151, "ob": 0.151, "ig": 0.159, "sk": 0.168, "rm": 0.168,
	"ul": 0.168, "ug": 0.177, "ol": 0.177, "em": 0.177, "ex": 0.177, "im": 0.177,
	"go": 0.186, "og": 0.186, "ht": 0.186, "fy": 0.186, "zy": 0.186, "ep": 0.186,
	"ha": 0.186, "pt": 0.186, "ak": 0.186, "aw": 0.195, "ld": 0.204, "ab": 0.204,
	"lo": 0.213, "la": 0.221, "oy": 0.221, "fs": 0.230, "no": 0.230, "od": 0.230,
	"ia": 0.230, "ze": 0.239, "wn": 0.239, "ew": 0.239, "ft": 0.239, "oo": 0.239,
	"ah": 0.248, "ip": 0.248, "ct": 0.248, "ag": 0.248, "ir": 0.248, "cs": 0.257,
	"gy": 0.257, "ro": 0.275, "do": 0.275, "hy": 0.283, "to": 0.283, "hs": 0.283,
	"rk": 0.283, "om": 0.292, "by": 0.301, "my": 0.310, "ap": 0.319, "rn": 0.319,
	"pe": 0.328, "ta": 0.328, "ur": 0.337, "rd": 0.345, "lt": 0.354, "op": 0.354,
	"ma": 0.381, "ut": 0.390, "ff": 0.390, "na": 0.399, "ra": 0.399, "ue": 0.399,
	"um": 0.399, "ws": 0.399, "ad": 0.399, "mp": 0.407, "ee": 0.416, "ys": 0.416,
	"up": 0.434, "me": 0.434, "py": 0.434, "ow": 0.443, "am": 0.443, "is": 0.443,
	"il": 0.461, "sy": 0.469, "ss": 0.469, "nd": 0.478, "ke": 0.478, "ny": 0.505,
	"th": 0.505, "bs": 0.514, "rt": 0.523, "ay": 0.523, "ot": 0.523, "at": 0.531,
	"as": 0.540, "nk": 0.549, "dy": 0.558, "de": 0.585, "ve": 0.585, "ll": 0.585,
	"id": 0.593, "os": 0.629, "us": 0.629, "ky": 0.638, "ic": 0.647, "it": 0.673,
	"gs": 0.691, "sh": 0.700, "ar": 0.700, "ms": 0.700, "ce": 0.709, "ie": 0.753,
	"ck": 0.762, "or": 0.771, "ey": 0.779, "an": 0.797, "ge": 0.815, "el": 0.850,
	"se": 0.850, "ne": 0.850, "nt": 0.877, "in": 0.903, "ry": 0.957, "te": 0.974,
	"ty": 1.001, "re": 1.019, "st": 1.045, "ch": 1.054, "et": 1.063, "en": 1.134,
	"ps": 1.187, "al": 1.231, "on": 1.258, "ds": 1.408, "ls": 1.417, "ns": 1.452,
	"ks": 1.479, "ly": 1.550, "rs": 1.630, "le": 2.090, "ng": 2.179, "ts": 2.639,
	"es": 5.128, "er": 5.606, "ed": 6.722,
}

}

const SHORT_WORD_TRIGRAMS := {
	END={
	"rky": 0.103, "oof": 0.103, "try": 0.103, "ign": 0.103,
	"ret": 0.103, "mbs": 0.103, "fty": 0.103, "ind": 0.103, "iny": 0.103, "bit": 0.103,
	"llo": 0.103, "oom": 0.103, "ium": 0.103, "oat": 0.103, "ere": 0.103, "uch": 0.103,
	"uds": 0.103, "awn": 0.103, "oys": 0.103, "thy": 0.103, "een": 0.103, "ily": 0.103,
	"oth": 0.103, "ual": 0.103, "ama": 0.103, "eck": 0.103, "nto": 0.103, "air": 0.103,
	"nal": 0.103, "osh": 0.103, "ase": 0.103, "mon": 0.103, "tar": 0.103, "und": 0.103,
	"ogs": 0.103, "ike": 0.103, "all": 0.103, "sks": 0.103, "rty": 0.103, "fed": 0.103,
	"xes": 0.115, "ffy": 0.115, "ney": 0.115, "mpy": 0.115, "xed": 0.115, "ree": 0.115,
	"lin": 0.115, "rth": 0.115, "chy": 0.115, "och": 0.115, "uce": 0.115, "aws": 0.115,
	"ful": 0.115, "way": 0.115, "ift": 0.115, "imp": 0.115, "shy": 0.115, "ipe": 0.115,
	"oms": 0.115, "ime": 0.115, "ews": 0.115, "che": 0.115, "ape": 0.115, "ugs": 0.115,
	"ugh": 0.115, "ngo": 0.115, "aid": 0.115, "ana": 0.115, "oks": 0.115, "ull": 0.115,
	"nty": 0.115, "lot": 0.115, "lon": 0.115, "old": 0.115, "rer": 0.126, "rch": 0.126,
	"eek": 0.126, "oss": 0.126, "nna": 0.126, "ong": 0.126, "sel": 0.126, "ory": 0.126,
	"obs": 0.126, "die": 0.126, "ear": 0.126, "kup": 0.126, "lar": 0.126, "ole": 0.126,
	"ubs": 0.126, "ras": 0.126, "mit": 0.126, "que": 0.126, "ace": 0.126, "set": 0.126,
	"ote": 0.126, "gie": 0.126, "ndy": 0.126, "ord": 0.126, "ead": 0.126, "ope": 0.126,
	"gue": 0.126, "fts": 0.126, "oll": 0.126, "ina": 0.126, "rse": 0.126, "and": 0.137,
	"amp": 0.137, "abs": 0.137, "ark": 0.137, "oes": 0.137, "son": 0.137, "ell": 0.137,
	"vel": 0.137, "ode": 0.137, "ums": 0.137, "tly": 0.137, "rge": 0.137, "urs": 0.137,
	"ect": 0.137, "ilt": 0.137, "ues": 0.137, "ath": 0.137, "ino": 0.137, "lds": 0.149,
	"iff": 0.149, "kle": 0.149, "eep": 0.149, "aze": 0.149, "eps": 0.149, "orn": 0.149,
	"men": 0.149, "ags": 0.149, "ony": 0.149, "irs": 0.149, "art": 0.149, "ffs": 0.149,
	"ook": 0.149, "low": 0.149, "row": 0.160, "ray": 0.160, "nic": 0.160, "ora": 0.160,
	"oot": 0.160, "eat": 0.160, "eer": 0.160, "ods": 0.160, "ast": 0.160, "ame": 0.160,
	"eak": 0.160, "ach": 0.160, "bes": 0.160, "den": 0.160, "wns": 0.160, "bed": 0.160,
	"ven": 0.160, "eed": 0.172, "ral": 0.172, "rns": 0.172, "tal": 0.172, "ees": 0.172,
	"key": 0.172, "lts": 0.172, "ert": 0.172, "ier": 0.172, "ggy": 0.172, "ddy": 0.172,
	"uck": 0.172, "yer": 0.172, "ust": 0.172, "unt": 0.172, "rly": 0.172, "ove": 0.172,
	"oon": 0.172, "oop": 0.172, "zed": 0.172, "ute": 0.172, "rms": 0.172, "aks": 0.172,
	"ten": 0.172, "oke": 0.183, "ose": 0.183, "wer": 0.183, "ple": 0.183, "ive": 0.183,
	"yed": 0.183, "ush": 0.183, "ics": 0.183, "own": 0.183, "tic": 0.183, "cer": 0.183,
	"ley": 0.183, "cky": 0.183, "uts": 0.195, "ion": 0.195, "ung": 0.195, "ery": 0.195,
	"rks": 0.195, "end": 0.195, "ess": 0.195, "hed": 0.195, "ial": 0.195, "ken": 0.195,
	"ock": 0.195, "ort": 0.195, "ity": 0.195, "ump": 0.195, "ade": 0.206, "eal": 0.206,
	"ssy": 0.206, "ton": 0.206, "ang": 0.206, "ile": 0.206, "are": 0.206, "ick": 0.206,
	"unk": 0.206, "uff": 0.206, "eds": 0.206, "nge": 0.206, "ket": 0.206, "ane": 0.218,
	"ths": 0.218, "tle": 0.218, "hes": 0.218, "sty": 0.218, "ave": 0.218, "ise": 0.218,
	"ink": 0.218, "rds": 0.218, "mmy": 0.218, "ary": 0.218, "ure": 0.218, "ght": 0.218,
	"dly": 0.218, "fer": 0.218, "ide": 0.218, "ber": 0.218, "ams": 0.218, "ish": 0.229,
	"ids": 0.229, "ant": 0.229, "ank": 0.229, "pes": 0.229, "ake": 0.229, "ard": 0.229,
	"nky": 0.240, "ops": 0.240, "dge": 0.240, "int": 0.240, "ite": 0.252, "one": 0.252,
	"ved": 0.252, "ail": 0.252, "nny": 0.252, "bby": 0.252, "ser": 0.252, "ire": 0.252,
	"ied": 0.252, "tty": 0.263, "her": 0.263, "aps": 0.263, "out": 0.263, "ced": 0.263,
	"ain": 0.263, "ale": 0.263, "ens": 0.263, "tor": 0.263, "ges": 0.263, "man": 0.263,
	"mes": 0.263, "mer": 0.275, "ore": 0.275, "ice": 0.275, "ppy": 0.275, "our": 0.275,
	"ill": 0.275, "ads": 0.275, "ips": 0.275, "rts": 0.275, "ors": 0.275, "nce": 0.286,
	"ash": 0.286, "ils": 0.286, "ows": 0.286, "ays": 0.286, "gle": 0.286, "rry": 0.298,
	"use": 0.298, "ist": 0.298, "ely": 0.309, "ots": 0.309, "let": 0.309, "age": 0.309,
	"ack": 0.309, "des": 0.321, "nch": 0.321, "ces": 0.332, "els": 0.344, "tch": 0.344,
	"mps": 0.344, "dle": 0.355, "ets": 0.355, "ngs": 0.355, "wed": 0.355, "ver": 0.366,
	"ons": 0.366, "ans": 0.366, "als": 0.366, "nes": 0.389, "tes": 0.401, "ins": 0.401,
	"nts": 0.401, "ler": 0.401, "ine": 0.412, "nks": 0.412, "med": 0.412, "its": 0.424,
	"sts": 0.424, "kes": 0.435, "nds": 0.447, "ner": 0.447, "ars": 0.458, "ats": 0.458,
	"ent": 0.458, "ate": 0.470, "sed": 0.481, "lly": 0.492, "ded": 0.492, "est": 0.492,
	"ger": 0.515, "ble": 0.515, "ies": 0.527, "ves": 0.538, "red": 0.538, "ged": 0.550,
	"lls": 0.550, "per": 0.561, "ned": 0.561, "res": 0.573, "les": 0.607, "ped": 0.641,
	"ker": 0.653, "ses": 0.664, "cks": 0.733, "led": 0.744, "der": 0.802, "ked": 0.882,
	"ted": 0.996, "ers": 1.065, "ter": 1.111, "ing": 2.279,
},
	START={
	"sig": 0.102, "leg": 0.102,
	"bol": 0.102, "int": 0.102, "doo": 0.102, "bit": 0.102, "ris": 0.102, "lun": 0.102,
	"nic": 0.102, "red": 0.102, "son": 0.102, "rav": 0.102, "ple": 0.102, "bag": 0.102,
	"ass": 0.102, "act": 0.102, "smi": 0.102, "twe": 0.102, "wai": 0.102, "tim": 0.102,
	"hot": 0.102, "hur": 0.102, "inf": 0.102, "gui": 0.102, "gau": 0.102, "thu": 0.102,
	"fac": 0.102, "bog": 0.102, "spu": 0.102, "fel": 0.102, "duc": 0.102, "liv": 0.102,
	"soa": 0.102, "sni": 0.102, "kno": 0.102, "fol": 0.102, "deb": 0.102, "pie": 0.102,
	"bab": 0.102, "pul": 0.102, "who": 0.102, "exp": 0.102, "tit": 0.102, "til": 0.102,
	"rin": 0.102, "rig": 0.102, "tam": 0.102, "tap": 0.102, "tip": 0.102, "rub": 0.102,
	"hin": 0.102, "wag": 0.102, "was": 0.102, "ala": 0.102, "tow": 0.102, "cos": 0.102,
	"top": 0.102, "dol": 0.102, "dor": 0.102, "god": 0.102, "goa": 0.102, "gul": 0.113,
	"bor": 0.113, "pai": 0.113, "pet": 0.113, "bru": 0.113, "mut": 0.113, "bul": 0.113,
	"mal": 0.113, "vis": 0.113, "gam": 0.113, "fun": 0.113, "dam": 0.113, "bum": 0.113,
	"pop": 0.113, "ami": 0.113, "rus": 0.113, "dep": 0.113, "arm": 0.113, "smo": 0.113,
	"reb": 0.113, "reg": 0.113, "tac": 0.113, "rum": 0.113, "tom": 0.113, "ven": 0.113,
	"rid": 0.113, "sou": 0.113, "sir": 0.113, "sub": 0.113, "kid": 0.113, "but": 0.113,
	"bos": 0.113, "lap": 0.113, "mag": 0.113, "fat": 0.113, "mel": 0.113, "plo": 0.113,
	"pen": 0.124, "beg": 0.124, "cab": 0.124, "run": 0.124, "dev": 0.124, "lam": 0.124,
	"men": 0.124, "rap": 0.124, "que": 0.124, "gal": 0.124, "rou": 0.124, "imp": 0.124,
	"ram": 0.124, "fir": 0.124, "tas": 0.124, "lac": 0.124, "div": 0.124, "cle": 0.124,
	"san": 0.124, "whe": 0.124, "lar": 0.124, "dan": 0.124, "sil": 0.124, "ang": 0.124,
	"pic": 0.124, "ali": 0.124, "dre": 0.124, "ear": 0.124, "ren": 0.124, "sun": 0.124,
	"gla": 0.124, "rag": 0.124, "dar": 0.124, "gre": 0.124, "gru": 0.124, "val": 0.124,
	"bou": 0.124, "hat": 0.124, "may": 0.124, "thi": 0.124, "lou": 0.124, "mad": 0.124,
	"yea": 0.124, "uni": 0.124, "fai": 0.124, "dum": 0.124, "mot": 0.136, "dee": 0.136,
	"ber": 0.136, "roa": 0.136, "hom": 0.136, "roo": 0.136, "lan": 0.136, "pra": 0.136,
	"rai": 0.136, "pho": 0.136, "wha": 0.136, "fre": 0.136, "cap": 0.136, "kin": 0.136,
	"pun": 0.136, "gar": 0.136, "wan": 0.136, "rot": 0.136, "mai": 0.136, "cop": 0.136,
	"rob": 0.136, "all": 0.136, "sur": 0.136, "awa": 0.136, "tun": 0.136, "mod": 0.136,
	"sle": 0.147, "cou": 0.147, "ref": 0.147, "don": 0.147, "ver": 0.147, "rep": 0.147,
	"blu": 0.147, "rem": 0.147, "hal": 0.147, "hel": 0.147, "met": 0.147, "hor": 0.147,
	"wee": 0.147, "far": 0.147, "woo": 0.147, "def": 0.147, "loa": 0.147, "ben": 0.147,
	"cam": 0.147, "mea": 0.147, "sav": 0.147, "plu": 0.147, "por": 0.147, "las": 0.147,
	"pil": 0.147, "spr": 0.147, "bli": 0.147, "ble": 0.147, "clu": 0.147, "del": 0.147,
	"tur": 0.158, "ton": 0.158, "sin": 0.158, "ser": 0.158, "med": 0.158, "mas": 0.158,
	"res": 0.158, "ree": 0.158, "cut": 0.158, "rat": 0.158, "cal": 0.158, "lim": 0.158,
	"mus": 0.158, "hol": 0.158, "pac": 0.158, "hun": 0.158, "rac": 0.158, "rel": 0.158,
	"dro": 0.158, "pos": 0.158, "wal": 0.158, "slu": 0.158, "the": 0.158, "rev": 0.158,
	"tor": 0.158, "tre": 0.170, "bow": 0.170, "han": 0.170, "pas": 0.170, "bun": 0.170,
	"tal": 0.170, "tro": 0.170, "lat": 0.170, "moo": 0.170, "bee": 0.170, "dri": 0.170,
	"wea": 0.170, "mon": 0.170, "shr": 0.170, "twi": 0.170, "den": 0.170, "swe": 0.170,
	"sea": 0.170, "dec": 0.170, "tin": 0.170, "dea": 0.170, "wil": 0.181, "hon": 0.181,
	"flu": 0.181, "sor": 0.181, "cru": 0.181, "goo": 0.181, "out": 0.181, "fri": 0.181,
	"scr": 0.181, "fra": 0.181, "pal": 0.181, "loc": 0.181, "bat": 0.181, "poo": 0.181,
	"mol": 0.181, "see": 0.181, "pre": 0.181, "fle": 0.181, "mis": 0.181, "sen": 0.181,
	"sol": 0.181, "tar": 0.181, "mat": 0.181, "mou": 0.181, "fin": 0.181, "squ": 0.192,
	"bal": 0.192, "pea": 0.192, "pat": 0.192, "ten": 0.192, "col": 0.192, "fro": 0.192,
	"hum": 0.192, "fli": 0.192, "glo": 0.192, "swi": 0.192, "tea": 0.192, "bus": 0.192,
	"tru": 0.192, "rec": 0.204, "mer": 0.204, "fil": 0.204, "slo": 0.204, "dis": 0.204,
	"tan": 0.204, "pol": 0.204, "rea": 0.204, "ran": 0.204, "pur": 0.204, "bre": 0.204,
	"bel": 0.204, "chu": 0.215, "coo": 0.215, "per": 0.215, "flo": 0.215, "sna": 0.215,
	"gen": 0.215, "mil": 0.215, "spe": 0.215, "qui": 0.215, "pee": 0.226, "win": 0.226,
	"wor": 0.226, "cas": 0.226, "cli": 0.226, "cri": 0.226, "bla": 0.226, "thr": 0.226,
	"qua": 0.226, "sti": 0.226, "cro": 0.238, "bas": 0.238, "sno": 0.238, "loo": 0.238,
	"dra": 0.249, "she": 0.249, "shi": 0.249, "bro": 0.249, "swa": 0.249, "stu": 0.249,
	"din": 0.249, "her": 0.249, "pla": 0.249, "ski": 0.249, "sli": 0.249, "bon": 0.249,
	"hea": 0.260, "pan": 0.260, "lin": 0.260, "ste": 0.260, "sal": 0.260, "spo": 0.271,
	"har": 0.271, "blo": 0.271, "pin": 0.283, "ban": 0.283, "par": 0.283, "gri": 0.283,
	"mor": 0.283, "whi": 0.283, "min": 0.283, "sca": 0.283, "sco": 0.283, "spa": 0.294,
	"war": 0.294, "com": 0.294, "cho": 0.294, "cor": 0.294, "bri": 0.294, "sla": 0.294,
	"cre": 0.294, "cur": 0.294, "bea": 0.305, "clo": 0.305, "con": 0.305, "pro": 0.305,
	"che": 0.317, "hoo": 0.317, "bur": 0.317, "gro": 0.317, "man": 0.328, "lea": 0.339,
	"tri": 0.339, "mar": 0.339, "sho": 0.339, "tra": 0.351, "spi": 0.351, "cla": 0.351,
	"can": 0.362, "for": 0.362, "pri": 0.373, "chi": 0.385, "sto": 0.385, "str": 0.385,
	"bar": 0.396, "boo": 0.396, "cha": 0.396, "bra": 0.407, "fla": 0.419, "cra": 0.430,
	"car": 0.441, "gra": 0.543, "sha": 0.577, "sta": 0.600,
	},
	OVERALL={
	"hil": 0.104, "ckl": 0.104, "owl": 0.104,
	"ule": 0.104, "rid": 0.104, "ede": 0.104, "ouc": 0.104, "edi": 0.104, "roa": 0.104,
	"ift": 0.104, "ilt": 0.104, "ega": 0.104, "imb": 0.104, "ugg": 0.104, "url": 0.104,
	"has": 0.104, "loa": 0.104, "oar": 0.104, "imp": 0.104, "eta": 0.104, "ece": 0.104,
	"ask": 0.104, "wel": 0.104, "ait": 0.104, "ini": 0.104, "nti": 0.104, "ten": 0.104,
	"tat": 0.104, "uil": 0.104, "uin": 0.104, "uit": 0.104, "han": 0.104, "een": 0.104,
	"ith": 0.104, "nor": 0.104, "ivi": 0.104, "par": 0.104, "cen": 0.104, "wer": 0.104,
	"amb": 0.104, "rad": 0.104, "alk": 0.104, "ugh": 0.104, "erv": 0.104, "abi": 0.104,
	"eme": 0.104, "aki": 0.104, "aci": 0.104, "stl": 0.104, "tal": 0.104, "arb": 0.104,
	"ray": 0.104, "ndi": 0.114, "udd": 0.114, "ene": 0.114, "oma": 0.114, "esi": 0.114,
	"ish": 0.114, "ais": 0.114, "eca": 0.114, "ixe": 0.114, "ors": 0.114, "unn": 0.114,
	"edg": 0.114, "ett": 0.114, "rve": 0.114, "ven": 0.114, "her": 0.114, "tai": 0.114,
	"eel": 0.114, "hal": 0.114, "gin": 0.114, "hoo": 0.114, "alm": 0.114, "sin": 0.114,
	"hea": 0.114, "cor": 0.114, "lay": 0.114, "rif": 0.114, "por": 0.114, "per": 0.114,
	"itc": 0.114, "ete": 0.114, "ama": 0.114, "eig": 0.114, "ein": 0.125, "omi": 0.125,
	"mbl": 0.125, "adi": 0.125, "rum": 0.125, "own": 0.125, "opi": 0.125, "tar": 0.125,
	"ntr": 0.125, "lve": 0.125, "ner": 0.125, "orm": 0.125, "che": 0.125, "rip": 0.125,
	"odi": 0.125, "aun": 0.125, "urn": 0.125, "oom": 0.125, "din": 0.125, "rus": 0.125,
	"lum": 0.125, "mbe": 0.125, "emo": 0.125, "bbe": 0.125, "mpl": 0.125, "udg": 0.125,
	"ala": 0.125, "irt": 0.125, "rme": 0.125, "qui": 0.125, "ele": 0.125, "inn": 0.125,
	"alo": 0.135, "oni": 0.135, "nse": 0.135, "ogg": 0.135, "lou": 0.135, "arg": 0.135,
	"hir": 0.135, "ork": 0.135, "onn": 0.135, "inc": 0.135, "ane": 0.135, "oli": 0.135,
	"add": 0.135, "rte": 0.135, "asi": 0.135, "oos": 0.135, "lar": 0.135, "raw": 0.135,
	"lac": 0.135, "eac": 0.135, "tri": 0.135, "err": 0.135, "ram": 0.135, "out": 0.135,
	"nit": 0.135, "eam": 0.146, "ens": 0.146, "ras": 0.146, "ath": 0.146, "loo": 0.146,
	"oss": 0.146, "ord": 0.146, "eek": 0.146, "urs": 0.146, "oti": 0.146, "ipe": 0.146,
	"ght": 0.146, "org": 0.146, "war": 0.146, "rke": 0.146, "oil": 0.146, "enn": 0.146,
	"las": 0.146, "rim": 0.146, "lat": 0.146, "igg": 0.146, "uri": 0.146, "ool": 0.146,
	"alt": 0.156, "nce": 0.156, "rde": 0.156, "ute": 0.156, "nin": 0.156, "app": 0.156,
	"avi": 0.156, "lee": 0.156, "omb": 0.156, "vin": 0.156, "ean": 0.156, "hor": 0.156,
	"orr": 0.156, "res": 0.156, "rse": 0.156, "rre": 0.156, "ble": 0.156, "iss": 0.156,
	"tor": 0.156, "orn": 0.156, "ren": 0.156, "eri": 0.156, "ria": 0.156, "urr": 0.156,
	"und": 0.156, "the": 0.156, "ora": 0.156, "rav": 0.156, "epe": 0.156, "idd": 0.166,
	"ung": 0.166, "ush": 0.166, "bbl": 0.166, "rap": 0.166, "eli": 0.166, "har": 0.166,
	"ffe": 0.166, "hee": 0.166, "min": 0.166, "ubb": 0.166, "aze": 0.166, "eck": 0.166,
	"amm": 0.166, "ani": 0.166, "tra": 0.177, "utt": 0.177, "ril": 0.177, "obb": 0.177,
	"ode": 0.177, "oop": 0.177, "our": 0.177, "ric": 0.177, "rou": 0.177, "ike": 0.177,
	"arl": 0.177, "agg": 0.177, "lam": 0.177, "ure": 0.177, "arn": 0.177, "lea": 0.177,
	"abb": 0.177, "ati": 0.177, "ddl": 0.177, "ere": 0.177, "unc": 0.177, "old": 0.177,
	"lte": 0.187, "umm": 0.187, "opp": 0.187, "run": 0.187, "rat": 0.187, "eni": 0.187,
	"ass": 0.187, "ime": 0.187, "ist": 0.187, "rit": 0.187, "air": 0.187, "abl": 0.187,
	"lon": 0.187, "mme": 0.187, "int": 0.187, "ome": 0.187, "enc": 0.187, "llo": 0.187,
	"ead": 0.187, "lie": 0.187, "pin": 0.187, "ond": 0.198, "umb": 0.198, "yin": 0.198,
	"ire": 0.198, "rac": 0.198, "ash": 0.198, "ous": 0.198, "ngl": 0.198, "ise": 0.198,
	"kin": 0.198, "ost": 0.198, "oot": 0.198, "ard": 0.198, "oug": 0.198, "low": 0.198,
	"unt": 0.198, "win": 0.208, "ark": 0.208, "eve": 0.208, "dge": 0.208, "ong": 0.208,
	"nke": 0.208, "mpe": 0.208, "aye": 0.208, "rro": 0.208, "dde": 0.208, "ewe": 0.208,
	"itt": 0.208, "rge": 0.208, "lic": 0.208, "eed": 0.208, "ote": 0.208, "lde": 0.208,
	"ott": 0.218, "ter": 0.218, "ole": 0.218, "use": 0.218, "nte": 0.218, "ann": 0.218,
	"rne": 0.218, "eak": 0.218, "eal": 0.218, "hin": 0.229, "arm": 0.229, "lan": 0.229,
	"unk": 0.229, "arr": 0.229, "age": 0.229, "eep": 0.239, "ind": 0.239, "ose": 0.239,
	"row": 0.239, "ron": 0.239, "ari": 0.239, "rai": 0.239, "ort": 0.239, "oun": 0.239,
	"roo": 0.239, "uff": 0.239, "ris": 0.239, "ape": 0.239, "tin": 0.250, "ale": 0.250,
	"oin": 0.250, "ice": 0.250, "ink": 0.260, "ood": 0.260, "ull": 0.260, "end": 0.260,
	"ope": 0.260, "ite": 0.260, "ent": 0.260, "eas": 0.260, "amp": 0.270, "anc": 0.270,
	"est": 0.270, "ain": 0.270, "ace": 0.281, "ook": 0.281, "ver": 0.281, "ust": 0.281,
	"ipp": 0.281, "ade": 0.281, "att": 0.281, "ump": 0.291, "ail": 0.291, "ore": 0.291,
	"ank": 0.291, "oll": 0.291, "ree": 0.301, "ide": 0.301, "eat": 0.301, "ame": 0.301,
	"ant": 0.301, "rie": 0.301, "ase": 0.301, "gge": 0.322, "uck": 0.322, "nge": 0.333,
	"she": 0.343, "ang": 0.343, "nne": 0.343, "igh": 0.353, "ran": 0.364, "art": 0.364,
	"sse": 0.364, "ive": 0.374, "lin": 0.374, "ppe": 0.374, "one": 0.374, "ock": 0.385,
	"ile": 0.385, "owe": 0.385, "ove": 0.395, "rin": 0.395, "and": 0.416, "nde": 0.426,
	"oke": 0.426, "rea": 0.437, "are": 0.437, "ell": 0.447, "all": 0.457, "ast": 0.468,
	"ave": 0.468, "ack": 0.468, "ste": 0.478, "ine": 0.489, "ill": 0.489, "tte": 0.499,
	"ick": 0.509, "ake": 0.520, "ear": 0.530, "ing": 0.541, "lle": 0.551, "ate": 0.593,
	"cke": 0.707,
	}
}


const SOUNDS = {
	GHOSTSOUND_1 = preload("res://mods/proverbpalace/sounds/ghostsound1.wav"),
	GHOSTSOUND_2 = preload("res://mods/proverbpalace/sounds/ghostsound2.wav"),
	GHOSTSOUND_3 = preload("res://mods/proverbpalace/sounds/ghostsound3.wav"),
	
	SUITCASE_1 = preload("res://mods/proverbpalace/sounds/suitcase1.wav"),
	SUITCASE_2 = preload("res://mods/proverbpalace/sounds/suitcase2.wav"),
}


const MIN_NGRAM_WEIGHT := 0.1
const COLD_CASE_EFFECT = preload("res://mods/proverbpalace/source/spells/cold_case/cold_case_effect_instance.tscn")

func is_ngram_valid(ngram: String, letter_pool: Array[String]) -> bool:
	var remaining_letter_pool = letter_pool.duplicate()
	for i in len(ngram):
		if ngram[i] in remaining_letter_pool:
			remaining_letter_pool.erase(ngram[i])
		else:
			return false
	
	
	return true

func get_ngram_pool(letter_pool: Array[String]) -> Dictionary[String,float]:
	var pool_for_value : Dictionary[String, float] = {}
	for ngram_length in range(3,0,-1):
		for val in range(8,0,-1):
			pool_for_value = get_ngram_pool_for_value(letter_pool,val,ngram_length)
			#print_debug(pool_for_value)
			if len(pool_for_value) >= 3:
				return pool_for_value
	
	return {}


func get_ngram_pool_for_value(letter_pool: Array[String], value: int, ngram_length: int) -> Dictionary[String,float]:
	var ngram_pool: Dictionary[String,float] = {}
	var parity_key: String = ["START","END","OVERALL"][start_end_parity]
	var bigrams = SHORT_WORD_BIGRAMS[parity_key]
	var trigrams = SHORT_WORD_TRIGRAMS[parity_key]
	match ngram_length:
		3:
			for trigram in trigrams.keys():
				if Letters.get_string_value(trigram) == value and is_ngram_valid(trigram,letter_pool) and trigrams[trigram] > MIN_NGRAM_WEIGHT:
					ngram_pool[trigram] = trigrams[trigram]
		2:
			for bigram in bigrams.keys():
				if Letters.get_string_value(bigram) == value and is_ngram_valid(bigram,letter_pool) and bigrams[bigram] > MIN_NGRAM_WEIGHT:
					ngram_pool[bigram] = bigrams[bigram]
		1:
			for letter in Letters.LETTERS.keys():
				if Letters.get_string_value(letter) == value and is_ngram_valid(letter,letter_pool):
					ngram_pool[letter] = Letters.LETTERS[letter]
	
	return ngram_pool


func apply_to_tile(tile: Tile, _real_tile, is_preview, _is_preview_update):
	if is_preview:
		tile.add_status(TileStatus.MYSTERY)
		tile.add_status(TileStatus.FROZEN)
	
	tile.remove_status(TileStatus.CAPITAL)
	tile.remove_status(TileStatus.PERIOD)
	if not is_preview:
		var valid_tiles := tile_board.get_tiles({
			sorted=false, 
			custom_tile_check = func(tile: Tile, _parameters: Dictionary):
				if (len(tile.face) == 1):
					return tile.has_face() and !tile.has_status(TileStatus.MYSTERY)
				return false,
			exclude_tiles = [tile]
		})
		
		var letter_pool: Array[String] = []
		for t in valid_tiles:
			letter_pool.append(t.face)
			
		var ngram_pool := get_ngram_pool(letter_pool)
		
		AudioManager.play_sound(SOUNDS["SUITCASE_%d"%(randi_range(1,2))],.8,1.)
		#tile.add_poofcloud(POOF_COLOR,Globals.TILE_POOF_COLOR.frozen[1])
		
		if len(ngram_pool.keys()) < 1:
			tile.randomize_face([], rng.spell, false)
			tile.add_status(TileStatus.MYSTERY, rng.spell.randi())
			tile.add_status(TileStatus.FROZEN)
			#tile.add_poofcloud(tile.get_color())
			start_end_parity = (start_end_parity + 1)%3
			
			# TODO UNIFY THIS WITH NORMAL VFX
			return
		
		var ngram_choice = rng.spell.weighted_random(ngram_pool)
		
		var option_count: int = FIXED_OPTIONS_CAP
		
		var remaining_ngram_options = ngram_pool.duplicate()
		remaining_ngram_options.erase(ngram_choice)
		var chosen_ngram_options : Array[String] = [ngram_choice]
		for i in range(option_count - 1):
			if len(remaining_ngram_options) == 0:
				break
			var decoy_ngram = rng.spell.weighted_random(remaining_ngram_options)
			chosen_ngram_options.append(decoy_ngram)
			remaining_ngram_options.erase(decoy_ngram)
		
		(chosen_ngram_options.shuffle())
		var sseed = rng.spell.randi()
		
		var effect: GenericTileEffect = null
		var spelling_interval := 0.14
		
		effect = COLD_CASE_EFFECT.instantiate() as GenericTileEffect
		effect.do_play_sound = func():
			AudioManager.play_sound(
				SOUNDS["GHOSTSOUND_%d"%(start_end_parity+1)],
				randf_range(.3,.4),
				.65
			)
			for i in len(ngram_choice):
				tile.set_face(ngram_choice.substr(0,i+1))
				#AudioManager.play_sound(Sounds.UI.TEXT_TYPING,1.)
				AudioManager.play_sound(Sounds.TILE.FROZEN,1.,.75)
				tile.add_status(TileStatus.MYSTERY,sseed, chosen_ngram_options)
				await Game.timeout(spelling_interval)
			tile.add_status(TileStatus.FROZEN)
		
		var do_freeze := !tile.has_status(TileStatus.FROZEN)
		effect.frame_coords = tile.tile_sprite.base_sprite.frame_coords
		tile.tile_sprite.add_child(effect)
		effect.atlas = tile.tile_sprite.base_sprite.texture
		effect.dont_change = !do_freeze
		effect.bounce.connect(
			func():
				tile.animation.play("shake")
				)
		
		
		await effect.effect_finished
		start_end_parity = (start_end_parity + 1)%3
		
		frame_updated.emit()
	else:
		tile.set_face("aaa", true, false)

func get_hv_frames() -> Vector2i:
	return Vector2i(3, 1)


func get_frame() -> int:
	return start_end_parity


func is_tile_selectable(tile: Tile) -> bool:
	return (
		tile.is_face_modifiable()
		and not (
			tile.has_status(TileEffect.SHIMMERING)
		) and not (
			tile.has_harmful_status()
		) and not (
			tile.has_status(TileStatus.FROZEN) and len(tile.face) == 3
		)
	)
