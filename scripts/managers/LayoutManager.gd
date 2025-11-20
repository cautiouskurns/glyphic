# LayoutManager.gd
# Autoload singleton providing centralized access to layout configurations
extends Node

# Panel layout configs (one per panel type)
var panel_layouts: Dictionary = {}

# Screen layout configs (one per screen type)
var screen_layouts: Dictionary = {}

func _ready():
	"""Load all layout configuration resources"""
	load_panel_layouts()
	load_screen_layouts()

func load_panel_layouts():
	"""Create panel layout configs directly in code"""
	print("LayoutManager: Creating panel layouts...")

	# Queue panel - compact list (left edge/archive area)
	var queue_config = PanelLayoutConfig.new()
	queue_config.panel_width = 400
	queue_config.panel_height = 300
	queue_config.header_height = 35
	queue_config.title_padding_left = 12
	queue_config.close_button_offset_right = 38
	queue_config.close_button_size = 28
	queue_config.content_padding_horizontal = 20
	queue_config.content_padding_vertical = 20
	queue_config.content_top_offset = 55
	panel_layouts["queue"] = queue_config
	print("  Queue: %dx%d" % [queue_config.panel_width, queue_config.panel_height])

	# Translation panel - horizontal notebook (bottom)
	var translation_config = PanelLayoutConfig.new()
	translation_config.panel_width = 1300
	translation_config.panel_height = 180
	translation_config.header_height = 35
	translation_config.title_padding_left = 12
	translation_config.close_button_offset_right = 38
	translation_config.close_button_size = 28
	translation_config.content_padding_horizontal = 20
	translation_config.content_padding_vertical = 20
	translation_config.content_top_offset = 55
	panel_layouts["translation"] = translation_config
	print("  Translation: %dx%d" % [translation_config.panel_width, translation_config.panel_height])

	# Dictionary panel - reference area (right)
	var dictionary_config = PanelLayoutConfig.new()
	dictionary_config.panel_width = 650
	dictionary_config.panel_height = 600
	dictionary_config.header_height = 35
	dictionary_config.title_padding_left = 12
	dictionary_config.close_button_offset_right = 38
	dictionary_config.close_button_size = 28
	dictionary_config.content_padding_horizontal = 20
	dictionary_config.content_padding_vertical = 20
	dictionary_config.content_top_offset = 55
	panel_layouts["dictionary"] = dictionary_config
	print("  Dictionary: %dx%d" % [dictionary_config.panel_width, dictionary_config.panel_height])

	# Examination panel - work area (left)
	var examination_config = PanelLayoutConfig.new()
	examination_config.panel_width = 700
	examination_config.panel_height = 600
	examination_config.header_height = 35
	examination_config.title_padding_left = 12
	examination_config.close_button_offset_right = 38
	examination_config.close_button_size = 28
	examination_config.content_padding_horizontal = 20
	examination_config.content_padding_vertical = 20
	examination_config.content_top_offset = 55
	panel_layouts["examination"] = examination_config
	print("  Examination: %dx%d" % [examination_config.panel_width, examination_config.panel_height])

	print("LayoutManager: Created %d panel layouts" % panel_layouts.size())

func load_screen_layouts():
	"""Create screen layout configs directly in code"""
	print("LayoutManager: Creating screen layouts...")

	# Translation screen layout
	var translation_screen = ScreenLayoutConfig.new()
	translation_screen.text_display_height = 150
	translation_screen.text_display_margin_bottom = 20
	translation_screen.input_field_height = 40
	translation_screen.button_row_height = 50
	translation_screen.element_spacing = 10
	screen_layouts["translation"] = translation_screen

	# Examination screen layout
	var examination_screen = ScreenLayoutConfig.new()
	examination_screen.book_display_width = 400
	examination_screen.book_display_height = 500
	examination_screen.tool_button_size = 60
	examination_screen.tool_button_spacing = 15
	examination_screen.examination_padding = 20
	screen_layouts["examination"] = examination_screen

	# Dictionary screen layout
	var dictionary_screen = ScreenLayoutConfig.new()
	dictionary_screen.entry_height = 60
	dictionary_screen.entry_spacing = 5
	dictionary_screen.search_bar_height = 40
	dictionary_screen.dictionary_padding = 10
	screen_layouts["dictionary"] = dictionary_screen

	# Queue screen layout
	var queue_screen = ScreenLayoutConfig.new()
	queue_screen.customer_card_height = 120
	queue_screen.customer_card_spacing = 10
	queue_screen.queue_padding = 15
	screen_layouts["queue"] = queue_screen

	print("LayoutManager: Created %d screen layouts" % screen_layouts.size())

func get_panel_layout(panel_type: String) -> PanelLayoutConfig:
	"""Get panel layout config for a specific panel type"""
	if panel_type not in panel_layouts:
		push_warning("LayoutManager: Panel layout not found for type: %s. Using default." % panel_type)
		return PanelLayoutConfig.new()  # Return default config

	return panel_layouts[panel_type]

func get_screen_layout(screen_type: String) -> ScreenLayoutConfig:
	"""Get screen layout config for a specific screen type"""
	if screen_type not in screen_layouts:
		push_warning("Screen layout not found for type: %s. Using default." % screen_type)
		return ScreenLayoutConfig.new()  # Return default config

	return screen_layouts[screen_type]
