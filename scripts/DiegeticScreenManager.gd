# DiegeticScreenManager.gd
# Feature 3A.4: Manages screen content within diegetic panels
extends Node

# Screen scene paths
const SCREEN_SCENES = {
	"queue": "res://scenes/screens/QueueScreen.tscn",
	"translation": "res://scenes/screens/TranslationScreen.tscn",
	"dictionary": "res://scenes/screens/DictionaryScreen.tscn",
	"examination": "res://scenes/screens/ExaminationScreen.tscn",
	"work": "res://scenes/screens/WorkScreen.tscn"
}

# Track active screen instances
var active_screens: Dictionary = {}  # {panel_type: screen_instance}

# Signals for cross-screen communication
signal customer_accepted(customer_data: Dictionary)
signal translation_started(book_data: Dictionary)
signal translation_completed(book_data: Dictionary)
signal day_ended()

func load_screen_into_panel(panel_type: String, panel: Control):
	"""Load appropriate screen content into a panel"""
	if not SCREEN_SCENES.has(panel_type):
		push_error("Unknown panel type: %s" % panel_type)
		return

	# Play page turn sound when opening panel
	AudioManager.play_panel_open()

	# Load screen scene
	var screen_scene = load(SCREEN_SCENES[panel_type])
	var screen_instance = screen_scene.instantiate()

	# Configure for panel display
	screen_instance.panel_mode = true  # Tell screen it's in a panel
	screen_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	screen_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Pass panel layout config to screen (screens can use it for layout calculations)
	if panel.layout_config and screen_instance.has_method("set_panel_layout_config"):
		screen_instance.set_panel_layout_config(panel.layout_config)

	# Pass screen layout config to screen (for screen-specific layout parameters)
	var screen_layout = LayoutManager.get_screen_layout(panel_type)
	if screen_instance.has_method("set_screen_layout_config"):
		screen_instance.set_screen_layout_config(screen_layout)

	# Pass panel content area dimensions to screen (legacy compatibility)
	var content_width = panel.layout_config.get_content_width() if panel.layout_config else panel.panel_width - 40
	var content_height = panel.layout_config.get_content_height() if panel.layout_config else panel.panel_height - 75
	if screen_instance.has_method("set_panel_content_size"):
		screen_instance.set_panel_content_size(content_width, content_height)

	# Add to panel's content area
	var content_area = panel.content_area
	# Clear placeholder content
	for child in content_area.get_children():
		child.queue_free()

	content_area.add_child(screen_instance)

	# Connect screen signals
	connect_screen_signals(panel_type, screen_instance)

	# Track active screen
	active_screens[panel_type] = screen_instance

	# Note: Screen will self-initialize in _ready() via call_deferred

func unload_screen(panel_type: String):
	"""Clean up screen instance when panel closes"""
	if active_screens.has(panel_type):
		# Play page turn sound when closing panel
		AudioManager.play_panel_close()

		var screen = active_screens[panel_type]
		disconnect_screen_signals(panel_type, screen)
		screen.queue_free()
		active_screens.erase(panel_type)

func connect_screen_signals(panel_type: String, screen: Control):
	"""Connect screen-specific signals to manager handlers"""
	match panel_type:
		"queue":
			if screen.has_signal("customer_selected"):
				screen.customer_selected.connect(_on_customer_selected)

		"examination":
			if screen.has_signal("begin_translation"):
				screen.begin_translation.connect(_on_begin_translation)

		"translation":
			if screen.has_signal("translation_submitted"):
				screen.translation_submitted.connect(_on_translation_submitted)
			if screen.has_signal("dictionary_requested"):
				screen.dictionary_requested.connect(_on_dictionary_requested)

		"dictionary":
			if screen.has_signal("glyph_selected"):
				screen.glyph_selected.connect(_on_glyph_selected)

		"work":
			if screen.has_signal("end_day_requested"):
				screen.end_day_requested.connect(_on_end_day_requested)

func disconnect_screen_signals(panel_type: String, screen: Control):
	"""Disconnect all signals when screen is unloaded"""
	match panel_type:
		"queue":
			if screen.has_signal("customer_selected"):
				screen.customer_selected.disconnect(_on_customer_selected)

		"examination":
			if screen.has_signal("begin_translation"):
				screen.begin_translation.disconnect(_on_begin_translation)

		"translation":
			if screen.has_signal("translation_submitted"):
				screen.translation_submitted.disconnect(_on_translation_submitted)
			if screen.has_signal("dictionary_requested"):
				screen.dictionary_requested.disconnect(_on_dictionary_requested)

		"dictionary":
			if screen.has_signal("glyph_selected"):
				screen.glyph_selected.disconnect(_on_glyph_selected)

		"work":
			if screen.has_signal("end_day_requested"):
				screen.end_day_requested.disconnect(_on_end_day_requested)

# Signal handlers for screen interactions

func _on_customer_selected(customer_data: Dictionary):
	"""Handle customer selection in queue screen"""
	print("Customer selected: %s" % customer_data.get("name", "Unknown"))
	# Show customer popup via ShopScene
	var shop_scene = get_tree().get_first_node_in_group("shop_scene")
	if shop_scene and shop_scene.has_method("show_customer_popup"):
		shop_scene.show_customer_popup(customer_data)

func _on_begin_translation():
	"""Handle 'Begin Translation' from examination screen - open translation panel"""
	print("Beginning translation for: %s" % GameState.current_book.get("name", "Unknown"))
	# Open translation panel via ShopScene
	var shop_scene = get_tree().get_first_node_in_group("shop_scene")
	if shop_scene:
		shop_scene._on_desk_object_clicked("translation")

func _on_translation_submitted(translation: String, correct: bool):
	"""Handle translation submission"""
	if correct:
		GameState.player_cash += 50
		print("Translation correct! +$50")
	else:
		print("Translation incorrect")

func _on_dictionary_requested():
	"""Open dictionary panel when requested from translation screen"""
	# Signal ShopScene to open dictionary panel
	var shop_scene = get_tree().get_first_node_in_group("shop_scene")
	if shop_scene:
		shop_scene._on_desk_object_clicked("dictionary")

func _on_glyph_selected(glyph_data: Dictionary):
	"""Handle glyph selection in dictionary"""
	print("Glyph selected: %s" % glyph_data.symbol)

func _on_end_day_requested():
	"""Handle end of day"""
	GameState.end_day()
	day_ended.emit()
	print("Day ended")

# Public API

func get_active_screen(panel_type: String) -> Control:
	"""Get currently active screen instance for a panel type"""
	return active_screens.get(panel_type, null)

func refresh_screen(panel_type: String):
	"""Refresh screen content (e.g., after game state change)"""
	if active_screens.has(panel_type):
		var screen = active_screens[panel_type]
		if screen.has_method("refresh"):
			screen.refresh()
