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

func _ready():
	initialize_dictionary()

func initialize_dictionary():
	"""Initialize all 20 symbols as unknown"""
	for symbol in SYMBOLS:
		dictionary[symbol] = {
			"word": null,  # null = unknown, shows "???"
			"confidence": 0,  # 0 = unknown, 1-2 = tentative, 3+ = confirmed
			"learned_from": []  # Track which texts taught this symbol
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
		if not dictionary[symbol].learned_from.has(text.name):
			dictionary[symbol].learned_from.append(text.name)

func get_dictionary_entry(symbol: String) -> Dictionary:
	"""Get current state of a symbol in the dictionary"""
	if symbol in dictionary:
		return dictionary[symbol]
	return {"word": null, "confidence": 0, "learned_from": []}
