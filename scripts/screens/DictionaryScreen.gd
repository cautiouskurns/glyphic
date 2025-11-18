# DictionaryScreen.gd
# Feature 3A.4: Glyph Dictionary - panel-compatible
# Adapted from DictionaryPanel.gd for diegetic panel system
extends Control

# Panel mode flag
var panel_mode: bool = false

# UI References
@onready var subtitle_label = $VBoxContainer/Header/SubtitleLabel
@onready var search_box = $VBoxContainer/Header/SearchBox
@onready var dictionary_list = $VBoxContainer/ScrollContainer/VBoxContainer
@onready var all_button = $VBoxContainer/Header/FilterButtons/AllButton
@onready var elemental_button = $VBoxContainer/Header/FilterButtons/ElementalButton
@onready var structural_button = $VBoxContainer/Header/FilterButtons/StructuralButton
@onready var temporal_button = $VBoxContainer/Header/FilterButtons/TemporalButton
@onready var mystical_button = $VBoxContainer/Header/FilterButtons/MysticalButton

# Template scene for dictionary entries
var entry_scene = preload("res://scenes/ui/DictionaryEntry.tscn")

# Track symbol order for consistent display
var symbol_order: Array = []
var all_entries: Array = []  # Store all entry nodes

var current_search: String = ""
var active_filters: Array = ["all"]  # Default: show all categories

func _ready():
	"""Initialize dictionary screen"""
	print("DictionaryScreen: _ready() called, panel_mode =", panel_mode)

	if panel_mode:
		setup_panel_layout()

	# Wait for layout before initializing
	await get_tree().process_frame
	await get_tree().process_frame
	print("DictionaryScreen: About to call initialize()")
	initialize()

func setup_panel_layout():
	"""Configure for panel display"""
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

func initialize():
	"""Called when panel opens - load dictionary"""
	print("DictionaryScreen: initialize() called")

	# Connect search box
	search_box.text_changed.connect(_on_search_changed)

	# Connect filter buttons
	all_button.pressed.connect(func(): _on_filter_pressed("all"))
	elemental_button.pressed.connect(func(): _on_filter_pressed("elemental"))
	structural_button.pressed.connect(func(): _on_filter_pressed("structural"))
	temporal_button.pressed.connect(func(): _on_filter_pressed("temporal"))
	mystical_button.pressed.connect(func(): _on_filter_pressed("mystical"))

	print("DictionaryScreen: About to populate_dictionary()")
	populate_dictionary()

func populate_dictionary():
	"""Create all dictionary entries from SymbolData"""
	print("DictionaryScreen: populate_dictionary() called")

	# Clear existing entries
	for child in dictionary_list.get_children():
		child.queue_free()

	all_entries.clear()

	# Get all symbol groups from SymbolData.dictionary
	symbol_order = SymbolData.dictionary.keys()
	print("DictionaryScreen: Found %d symbols in SymbolData" % symbol_order.size())

	# Create entry for each symbol
	for symbol in symbol_order:
		var entry = entry_scene.instantiate()
		dictionary_list.add_child(entry)  # Add to tree FIRST

		# Ensure entry is above other UI elements
		entry.z_index = 1

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

	print("DictionaryScreen: Created %d dictionary entries" % all_entries.size())

	# Wait a frame and check visibility
	await get_tree().process_frame
	await get_tree().process_frame

	print("DictionaryScreen: dictionary_list size:", dictionary_list.size)
	print("DictionaryScreen: dictionary_list children count:", dictionary_list.get_child_count())
	for i in range(min(3, dictionary_list.get_child_count())):
		var child = dictionary_list.get_child(i)
		print("  Entry %d: visible=%s, size=%s, modulate=%s" % [i, child.visible, child.size, child.modulate])

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

func refresh():
	"""Public API: Refresh the dictionary display"""
	update_dictionary()
