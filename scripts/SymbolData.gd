# SymbolData.gd
# Autoload singleton managing symbol alphabet, translation texts, and dictionary state
extends Node

# 20-symbol alphabet from design doc
const SYMBOLS: Array = [
	"∆", "◊", "≈", "⊕", "⊗", "⬡", "∞", "◈",
	"⊟", "⊞", "⊠", "⊡", "⊢", "⊣", "⊤", "⊥",
	"⊦", "⊧", "⊨", "⊩"
]

# 5 translation texts with increasing difficulty
var texts: Array = [
	{
		"id": 1,
		"name": "Text 1 - Family History",
		"symbols": "∆ ◊≈ ⊕⊗◈",
		"solution": "the old way",
		"mappings": {
			"∆": "the",
			"◊≈": "old",
			"⊕⊗◈": "way"
		},
		"difficulty": "Easy",
		"payment_base": 50,
		"hint": "Simple word substitution. Each symbol group = one English word."
	},
	{
		"id": 2,
		"name": "Text 2 - Forgotten Ways",
		"symbols": "∆ ◊≈ ⊕⊗◈ ⊕⊗⬡ ⬡∞◊⊩⊩≈⊩",
		"solution": "the old way was forgotten",
		"mappings": {
			"∆": "the",
			"◊≈": "old",
			"⊕⊗◈": "way",
			"⊕⊗⬡": "was",
			"⬡∞◊⊩⊩≈⊩": "forgotten"
		},
		"difficulty": "Medium",
		"payment_base": 100,
		"hint": "Builds on previous text. Look for familiar symbols."
	},
	{
		"id": 3,
		"name": "Text 3 - Sleeping God",
		"symbols": "∆ ◊≈ ⊞⊟≈ ⬡≈≈⊢⬡",
		"solution": "the old god sleeps",
		"mappings": {
			"∆": "the",
			"◊≈": "old",
			"⊞⊟≈": "god",
			"⬡≈≈⊢⬡": "sleeps"
		},
		"difficulty": "Medium",
		"payment_base": 100,
		"hint": "Half the symbols are known. New vocabulary: divine entities."
	},
	{
		"id": 4,
		"name": "Text 4 - Lost Magic",
		"symbols": "⊗◈⊞∞◈ ⊕⊗⬡ ◊⊩◈≈ ⊟⊩◊⊕⊩",
		"solution": "magic was once known",
		"mappings": {
			"⊗◈⊞∞◈": "magic",
			"⊕⊗⬡": "was",
			"◊⊩◈≈": "once",
			"⊟⊩◊⊕⊩": "known"
		},
		"difficulty": "Hard",
		"payment_base": 150,
		"hint": "Only one familiar symbol. Deduce from context."
	},
	{
		"id": 5,
		"name": "Text 5 - The Return",
		"symbols": "∆≈◊ ⊗◈≈ ◈≈∆◊◈⊩∞⊩⊞ ⬡◊◊⊩",
		"solution": "they are returning soon",
		"mappings": {
			"∆≈◊": "they",
			"⊗◈≈": "are",
			"◈≈∆◊◈⊩∞⊩⊞": "returning",
			"⬡◊◊⊩": "soon"
		},
		"difficulty": "Hard",
		"payment_base": 200,
		"hint": "Finale text. Ominous warning. Synthesis of all previous knowledge."
	}
]

# Dictionary state (symbol → word, confidence level)
var dictionary: Dictionary = {}

# Symbol metadata (category, aliases, thematic tags)
var symbol_metadata: Dictionary = {
	"∆": {"category": "structural", "aliases": ["Gateway", "Passage", "Threshold"]},
	"◊≈": {"category": "temporal", "aliases": ["Old", "Primordial", "Before"]},
	"⊕⊗◈": {"category": "structural", "aliases": ["Path", "Road", "Direction"]},
	"⊕⊗⬡": {"category": "temporal", "aliases": ["Existed", "Occurred"]},
	"⬡∞◊⊩⊩≈⊩": {"category": "mystical", "aliases": ["Lost", "Erased", "Hidden"]},
	"⊞⊟≈": {"category": "mystical", "aliases": ["Deity", "Divine", "Sacred"]},
	"⬡≈≈⊢⬡": {"category": "temporal", "aliases": ["Rests", "Dormant", "Waiting"]},
	"⊗◈⊞∞◈": {"category": "mystical", "aliases": ["Power", "Arcane", "Sorcery"]},
	"◊⊩◈≈": {"category": "temporal", "aliases": ["Previously", "Formerly"]},
	"⊟⊩◊⊕⊩": {"category": "elemental", "aliases": ["Understood", "Familiar"]},
	"∆≈◊": {"category": "structural", "aliases": ["Those", "Them", "Others"]},
	"⊗◈≈": {"category": "elemental", "aliases": ["Exist", "Being"]},
	"◈≈∆◊◈⊩∞⊩⊞": {"category": "temporal", "aliases": ["Coming Back", "Revival"]},
	"⬡◊◊⊩": {"category": "temporal", "aliases": ["Shortly", "Imminent", "Near"]},
}

func _ready():
	initialize_dictionary()

func initialize_dictionary():
	"""Initialize all symbol groups from texts as unknown"""
	dictionary.clear()

	# Collect all unique symbol groups across all texts
	for text in texts:
		for symbol_group in text.mappings.keys():
			if not symbol_group in dictionary:
				var metadata = symbol_metadata.get(symbol_group, {"category": "elemental", "aliases": []})
				dictionary[symbol_group] = {
					"word": null,  # null = unknown, shows "???"
					"confidence": 0,  # 0 = unknown, 1-2 = tentative, 3+ = confirmed
					"learned_from": [],  # Track which texts taught this symbol
					"category": metadata.category,  # elemental, structural, temporal, mystical
					"aliases": metadata.aliases,  # Related words/meanings
					"source": "",  # Where it was learned from
					"day_added": 0  # Game day when discovered
				}

func get_text(text_id: int) -> Dictionary:
	"""Retrieve text data by ID (1-5)"""
	for text in texts:
		if text.id == text_id:
			return text
	return {}

func validate_translation(text_id: int, player_input: String) -> bool:
	"""Check if player's translation matches the solution"""
	var text = get_text(text_id)
	if text.is_empty():
		return false

	# Normalize input: lowercase, strip whitespace
	var normalized_input = player_input.strip_edges().to_lower()
	var normalized_solution = text.solution.to_lower()

	return normalized_input == normalized_solution

func update_dictionary(text_id: int):
	"""Update dictionary with learned symbols from successful translation"""
	var text = get_text(text_id)
	if text.is_empty():
		return

	for symbol in text.mappings.keys():
		var word = text.mappings[symbol]

		# For Phase 1: Immediate confirmation (skip 3-use rule)
		dictionary[symbol].word = word
		dictionary[symbol].confidence = 3  # Confirmed

		# Set source and day added (only on first discovery)
		if dictionary[symbol].learned_from.is_empty():
			dictionary[symbol].source = text.name
			dictionary[symbol].day_added = GameState.current_day

		if not dictionary[symbol].learned_from.has(text.name):
			dictionary[symbol].learned_from.append(text.name)

func get_dictionary_entry(symbol: String) -> Dictionary:
	"""Get current state of a symbol in the dictionary"""
	if symbol in dictionary:
		return dictionary[symbol]
	return {
		"word": null,
		"confidence": 0,
		"learned_from": [],
		"category": "elemental",
		"aliases": [],
		"source": "",
		"day_added": 0
	}

func get_certainty_level(confidence: int) -> String:
	"""Convert confidence score to certainty level text"""
	if confidence >= 3:
		return "HIGH CERTAINTY"
	elif confidence >= 1:
		return "MEDIUM CERTAINTY"
	else:
		return "LOW CERTAINTY"

func get_certainty_color(confidence: int) -> Color:
	"""Get color for certainty badge"""
	if confidence >= 3:
		return Color("#2E7D32")  # Green
	elif confidence >= 1:
		return Color("#F57C00")  # Orange
	else:
		return Color("#616161")  # Gray

func get_category_color(category: String) -> Color:
	"""Get color for category tag"""
	match category:
		"elemental":
			return Color("#795548")  # Brown
		"structural":
			return Color("#455A64")  # Blue-gray
		"temporal":
			return Color("#5E35B1")  # Purple
		"mystical":
			return Color("#6A1B9A")  # Deep purple
		_:
			return Color("#616161")  # Gray

func get_documented_count() -> int:
	"""Count how many symbols have been documented"""
	var count = 0
	for entry in dictionary.values():
		if entry.word != null:
			count += 1
	return count
