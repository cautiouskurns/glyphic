# DictionaryPanel.gd
# Feature 2.4: Dictionary Auto-Fill System
# Manages all dictionary entries, updates from SymbolData
extends Panel

@onready var dictionary_list = $ScrollContainer/VBoxContainer

# Template scene for dictionary entries
var entry_scene = preload("res://scenes/ui/DictionaryEntry.tscn")

# Track symbol order for consistent display
var symbol_order: Array = []

func _ready():
	populate_dictionary()

func populate_dictionary():
	"""Create all dictionary entries from SymbolData"""
	# Get all symbol groups from SymbolData.dictionary
	symbol_order = SymbolData.dictionary.keys()

	# Create entry for each symbol
	for symbol in symbol_order:
		var entry = entry_scene.instantiate()
		dictionary_list.add_child(entry)  # Add to tree FIRST so @onready vars initialize

		# Now set properties (after _ready() has been called)
		entry.set_symbol(symbol)
		entry.set_word(null)  # Unknown initially
		entry.set_learned(false)

func update_dictionary():
	"""Refresh all entries from SymbolData"""
	var entries = dictionary_list.get_children()

	for i in range(entries.size()):
		var symbol = symbol_order[i]
		var dict_entry = SymbolData.get_dictionary_entry(symbol)

		if dict_entry.word != null:
			# Symbol is learned
			entries[i].set_word(dict_entry.word)
			entries[i].set_learned(true)
		else:
			# Symbol still unknown
			entries[i].set_word(null)
			entries[i].set_learned(false)

func _process(_delta):
	"""Poll for dictionary updates (Phase 2 simplification)"""
	# In Phase 3+, use signals instead of polling
	update_dictionary()
