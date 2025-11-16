# DictionaryPanel.gd
# Enhanced dictionary panel with search and category filtering
extends Panel

@onready var subtitle_label = $Header/SubtitleLabel
@onready var search_box = $Header/SearchBox
@onready var dictionary_list = $ScrollContainer/VBoxContainer
@onready var all_button = $Header/FilterButtons/AllButton
@onready var elemental_button = $Header/FilterButtons/ElementalButton
@onready var structural_button = $Header/FilterButtons/StructuralButton
@onready var temporal_button = $Header/FilterButtons/TemporalButton
@onready var mystical_button = $Header/FilterButtons/MysticalButton

# Template scene for dictionary entries
var entry_scene = preload("res://scenes/ui/DictionaryEntry.tscn")

# Track symbol order for consistent display
var symbol_order: Array = []
var all_entries: Array = []  # Store all entry nodes

var current_search: String = ""
var active_filters: Array = ["all"]  # Default: show all categories

func _ready():
	populate_dictionary()

	# Connect search box
	search_box.text_changed.connect(_on_search_changed)

	# Connect filter buttons
	all_button.pressed.connect(func(): _on_filter_pressed("all"))
	elemental_button.pressed.connect(func(): _on_filter_pressed("elemental"))
	structural_button.pressed.connect(func(): _on_filter_pressed("structural"))
	temporal_button.pressed.connect(func(): _on_filter_pressed("temporal"))
	mystical_button.pressed.connect(func(): _on_filter_pressed("mystical"))

func populate_dictionary():
	"""Create all dictionary entries from SymbolData"""
	# Clear existing entries
	for child in dictionary_list.get_children():
		child.queue_free()

	all_entries.clear()

	# Get all symbol groups from SymbolData.dictionary
	symbol_order = SymbolData.dictionary.keys()

	# Create entry for each symbol
	for symbol in symbol_order:
		var entry = entry_scene.instantiate()
		dictionary_list.add_child(entry)  # Add to tree FIRST

		# Get full entry data
		var entry_data = SymbolData.get_dictionary_entry(symbol)

		# Set all data using enhanced method
		entry.set_symbol_data(symbol, entry_data)

		# Store reference
		all_entries.append({
			"node": entry,
			"symbol": symbol,
			"data": entry_data
		})

	# Update subtitle
	update_subtitle()

func update_dictionary():
	"""Refresh all entries from SymbolData"""
	for entry_ref in all_entries:
		var symbol = entry_ref.symbol
		var entry_node = entry_ref.node
		var entry_data = SymbolData.get_dictionary_entry(symbol)

		# Update with latest data
		entry_node.set_symbol_data(symbol, entry_data)
		entry_ref.data = entry_data

	# Update subtitle
	update_subtitle()

	# Reapply filters
	apply_filters()

func update_subtitle():
	"""Update the subtitle with current stats"""
	var day_name = GameState.get_day_name(GameState.current_day)
	var documented_count = SymbolData.get_documented_count()
	var total_count = symbol_order.size()

	subtitle_label.text = "Personal Catalog • %s • %d/%d Symbols Documented" % [
		day_name,
		documented_count,
		total_count
	]

func _on_search_changed(new_text: String):
	"""Handle search box text change"""
	current_search = new_text.to_lower().strip_edges()
	apply_filters()

func _on_filter_pressed(category: String):
	"""Handle filter button press"""
	if category == "all":
		# All button: deactivate other filters
		active_filters = ["all"]
		all_button.button_pressed = true
		elemental_button.button_pressed = false
		structural_button.button_pressed = false
		temporal_button.button_pressed = false
		mystical_button.button_pressed = false
	else:
		# Category button: toggle and remove "all"
		if active_filters.has("all"):
			active_filters.clear()
			all_button.button_pressed = false

		if active_filters.has(category):
			active_filters.erase(category)
		else:
			active_filters.append(category)

		# If no filters active, revert to "all"
		if active_filters.is_empty():
			active_filters = ["all"]
			all_button.button_pressed = true

	apply_filters()

func apply_filters():
	"""Apply current search and category filters"""
	for entry_ref in all_entries:
		var entry_node = entry_ref.node
		var entry_data = entry_ref.data
		var symbol = entry_ref.symbol

		var visible = true

		# Category filter
		if not active_filters.has("all"):
			if not active_filters.has(entry_data.category):
				visible = false

		# Search filter (only for learned symbols)
		if visible and current_search != "":
			if entry_data.word != null:
				var word = entry_data.word.to_lower()
				var category = entry_data.category.to_lower()

				# Search in word, category, or aliases
				var found_in_word = word.contains(current_search)
				var found_in_category = category.contains(current_search)
				var found_in_aliases = false

				for alias in entry_data.aliases:
					if alias.to_lower().contains(current_search):
						found_in_aliases = true
						break

				if not (found_in_word or found_in_category or found_in_aliases):
					visible = false

		entry_node.visible = visible

func _process(_delta):
	"""Poll for dictionary updates"""
	update_dictionary()
