# ExaminationScreen.gd
# Feature 4.1: Book Examination Phase - panel-compatible
# Shows book cover with zoom tool, optional UV light reveal
extends Control

# Panel mode flag
var panel_mode: bool = false

# Panel content area dimensions (set by DiegeticScreenManager)
var content_width: int = 480
var content_height: int = 590

# UI References (created programmatically for panel mode)
var book_cover_panel: PanelContainer
var book_title_label: Label
var book_pattern_label: Label
var uv_overlay_label: Label
var zoom_panel: PanelContainer
var zoom_view_rect: ColorRect
var zoom_content_label: Label
var crosshair_h: ColorRect
var crosshair_v: ColorRect
var begin_button: Button
var uv_button: Button
var customer_header: Label

# State
var current_book_data: Dictionary = {}
var current_text_id: int = 0
var is_uv_active: bool = false
var is_mouse_over_book: bool = false

# Signals
signal begin_translation

func _ready():
	"""Initialize examination screen"""
	if panel_mode:
		setup_panel_layout()

	await get_tree().process_frame
	await get_tree().process_frame
	initialize()

func set_panel_content_size(width: int, height: int):
	"""Set content dimensions from panel (called by DiegeticScreenManager)"""
	content_width = width
	content_height = height

func setup_panel_layout():
	"""Create panel-compatible layout using dynamic dimensions"""
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(content_width, content_height)

	# Main container
	var margin = MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_top", 35)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# Customer header
	customer_header = Label.new()
	customer_header.text = "Examining book..."
	customer_header.add_theme_font_size_override("font_size", 14)
	customer_header.add_theme_color_override("font_color", Color(0.3, 0.25, 0.2))
	customer_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(customer_header)

	# Book cover panel (scale to fit content area)
	book_cover_panel = PanelContainer.new()
	var book_width = content_width - 30  # Leave margins
	var book_height = int(content_height * 0.5)  # Use ~50% of height for book
	book_cover_panel.custom_minimum_size = Vector2(book_width, book_height)
	book_cover_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	book_cover_panel.mouse_filter = Control.MOUSE_FILTER_PASS

	var book_style = StyleBoxFlat.new()
	book_style.bg_color = Color(0.956, 0.909, 0.847)  # Default cream
	book_style.border_width_left = 3
	book_style.border_width_top = 3
	book_style.border_width_right = 3
	book_style.border_width_bottom = 3
	book_style.border_color = Color(0.545, 0.266, 0.137)
	book_style.corner_radius_top_left = 4
	book_style.corner_radius_top_right = 4
	book_style.corner_radius_bottom_right = 4
	book_style.corner_radius_bottom_left = 4
	book_cover_panel.add_theme_stylebox_override("panel", book_style)
	vbox.add_child(book_cover_panel)

	# Book content container
	var book_content = Control.new()
	book_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	book_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	book_cover_panel.add_child(book_content)

	# Book title (top) - scale with book width
	book_title_label = Label.new()
	book_title_label.text = "Ancient Tome"
	book_title_label.add_theme_font_size_override("font_size", 18)
	book_title_label.add_theme_color_override("font_color", Color(0.4, 0.35, 0.3))
	book_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	book_title_label.position = Vector2(15, 15)
	book_title_label.size = Vector2(book_width - 30, 30)
	book_content.add_child(book_title_label)

	# Symbol pattern (center) - scale with book dimensions
	book_pattern_label = Label.new()
	book_pattern_label.text = "∆ ◊≈ ⊕⊗◈"
	var pattern_font_size = int(book_height * 0.15)  # Scale font with book height
	book_pattern_label.add_theme_font_size_override("font_size", max(24, pattern_font_size))
	book_pattern_label.add_theme_color_override("font_color", Color(0.5, 0.4, 0.35, 0.3))
	book_pattern_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	book_pattern_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	book_pattern_label.position = Vector2(15, int(book_height * 0.25))
	book_pattern_label.size = Vector2(book_width - 30, int(book_height * 0.5))
	book_content.add_child(book_pattern_label)

	# UV overlay (hidden by default) - scale with book dimensions
	uv_overlay_label = Label.new()
	uv_overlay_label.text = ""
	uv_overlay_label.add_theme_font_size_override("font_size", 16)
	uv_overlay_label.add_theme_color_override("font_color", Color(0.8, 0.4, 1.0))
	uv_overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	uv_overlay_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	uv_overlay_label.position = Vector2(15, 50)
	uv_overlay_label.size = Vector2(book_width - 30, book_height - 80)
	uv_overlay_label.visible = false
	book_content.add_child(uv_overlay_label)

	# Crosshairs (hidden by default) - scale to book size
	crosshair_h = ColorRect.new()
	crosshair_h.color = Color(1.0, 0.843, 0.0, 0.5)  # Gold
	crosshair_h.size = Vector2(book_width, 2)
	crosshair_h.position = Vector2(0, book_height / 2)
	crosshair_h.visible = false
	book_content.add_child(crosshair_h)

	crosshair_v = ColorRect.new()
	crosshair_v.color = Color(1.0, 0.843, 0.0, 0.5)  # Gold
	crosshair_v.size = Vector2(2, book_height)
	crosshair_v.position = Vector2(book_width / 2, 0)
	crosshair_v.visible = false
	book_content.add_child(crosshair_v)

	# Zoom panel (inset) - position at bottom-right of book cover
	zoom_panel = PanelContainer.new()
	var zoom_size = min(150, int(book_width * 0.33))  # 1/3 of book width, max 150px
	zoom_panel.custom_minimum_size = Vector2(zoom_size, zoom_size)
	zoom_panel.position = Vector2(book_width - zoom_size - 10, book_height - zoom_size - 10)  # Bottom right corner

	var zoom_style = StyleBoxFlat.new()
	zoom_style.bg_color = Color(0, 0, 0)
	zoom_style.border_width_left = 3
	zoom_style.border_width_top = 3
	zoom_style.border_width_right = 3
	zoom_style.border_width_bottom = 3
	zoom_style.border_color = Color(1.0, 0.843, 0.0)  # Gold border
	zoom_panel.add_theme_stylebox_override("panel", zoom_style)
	book_content.add_child(zoom_panel)

	# Zoom view
	zoom_view_rect = ColorRect.new()
	zoom_view_rect.color = Color(0.956, 0.909, 0.847)
	zoom_view_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	zoom_view_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	zoom_panel.add_child(zoom_view_rect)

	zoom_content_label = Label.new()
	zoom_content_label.text = "∆"
	zoom_content_label.add_theme_font_size_override("font_size", 80)
	zoom_content_label.add_theme_color_override("font_color", Color(0.5, 0.4, 0.35, 0.6))
	zoom_content_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zoom_content_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	zoom_content_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	zoom_content_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	zoom_view_rect.add_child(zoom_content_label)

	# Hint label
	var hint_label = Label.new()
	hint_label.text = "Hover over the book to examine symbols closely"
	hint_label.add_theme_font_size_override("font_size", 10)
	hint_label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4))
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint_label)

	# Button row
	var button_row = HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 8)
	vbox.add_child(button_row)

	# UV button (optional upgrade)
	uv_button = Button.new()
	uv_button.text = "💡 UV LIGHT"
	uv_button.custom_minimum_size = Vector2(0, 32)
	uv_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	uv_button.add_theme_font_size_override("font_size", 12)
	uv_button.visible = false  # Only show if owned
	uv_button.pressed.connect(_on_uv_button_pressed)
	button_row.add_child(uv_button)

	# Begin translation button
	begin_button = Button.new()
	begin_button.text = "Begin Translation"
	begin_button.custom_minimum_size = Vector2(0, 32)
	begin_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	begin_button.add_theme_font_size_override("font_size", 12)
	begin_button.pressed.connect(_on_begin_translation_pressed)
	button_row.add_child(begin_button)

func initialize():
	"""Called when panel opens - load current book from GameState"""
	if GameState.current_book.is_empty():
		show_no_book_message()
		return

	load_book(GameState.current_book)

func show_no_book_message():
	"""Display message when no book is on desk"""
	if customer_header:
		customer_header.text = "No book on desk - Accept a customer first"
	if begin_button:
		begin_button.disabled = true

func load_book(book_data: Dictionary):
	"""Load book examination data"""
	current_book_data = book_data
	current_text_id = book_data.get("text_id", 1)
	is_uv_active = false

	# Get text data for symbols
	var text_data = SymbolData.get_text(current_text_id)

	# Update customer header
	var customer_name = book_data.get("name", "Unknown")
	customer_header.text = "Examining %s's book" % customer_name

	# Update book appearance
	var book_color = book_data.get("book_cover_color", Color("#F4E8D8"))
	var style = book_cover_panel.get_theme_stylebox("panel").duplicate()
	style.bg_color = book_color
	book_cover_panel.add_theme_stylebox_override("panel", style)
	zoom_view_rect.color = book_color

	# Update book title
	var book_title = book_data.get("book_title", "Ancient Tome")
	book_title_label.text = book_title

	# Update symbol pattern
	if not text_data.is_empty():
		book_pattern_label.text = text_data.symbols

	# UV hidden text
	var uv_text = book_data.get("uv_hidden_text", "")
	uv_overlay_label.text = uv_text
	uv_overlay_label.visible = false

	# Show UV button if upgrade owned
	uv_button.visible = GameState.has_uv_light

	# Enable begin button
	begin_button.disabled = false

func _process(_delta):
	"""Track mouse position for zoom effect"""
	if not is_mouse_over_book and book_cover_panel:
		# Check if mouse is over book panel
		var book_rect = book_cover_panel.get_global_rect()
		var mouse_pos = get_global_mouse_position()

		if book_rect.has_point(mouse_pos):
			is_mouse_over_book = true
			Input.set_default_cursor_shape(Input.CURSOR_CROSS)
			crosshair_h.visible = true
			crosshair_v.visible = true

	if is_mouse_over_book and book_cover_panel:
		var book_rect = book_cover_panel.get_global_rect()
		var mouse_pos = get_global_mouse_position()

		if not book_rect.has_point(mouse_pos):
			is_mouse_over_book = false
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
			crosshair_h.visible = false
			crosshair_v.visible = false
		else:
			# Update zoom
			var local_mouse = mouse_pos - book_rect.position
			update_zoom(local_mouse, book_rect.size)

func update_zoom(local_mouse: Vector2, book_size: Vector2):
	"""Update 2× zoom view based on mouse position"""
	# Calculate relative position (0.0 to 1.0)
	var rel_x = local_mouse.x / book_size.x
	var rel_y = local_mouse.y / book_size.y

	# Update crosshair positions
	crosshair_h.position.y = local_mouse.y - 1
	crosshair_v.position.x = local_mouse.x - 1

	# Get text data for zoom content
	var text_data = SymbolData.get_text(current_text_id)
	if text_data.is_empty():
		return

	# Split symbols into groups
	var symbol_groups = text_data.symbols.split(" ", false)

	# Determine which symbol to zoom based on position
	# Top third: Title area
	if rel_y < 0.30:
		zoom_content_label.text = "~"
		zoom_content_label.add_theme_font_size_override("font_size", 100)
	# Middle third: Symbol pattern area
	elif rel_y >= 0.30 and rel_y < 0.80:
		# Map X position to symbol index
		var index = int(rel_x * symbol_groups.size())
		if index >= symbol_groups.size():
			index = symbol_groups.size() - 1
		if index >= 0:
			zoom_content_label.text = symbol_groups[index]
			zoom_content_label.add_theme_font_size_override("font_size", 80)
	# Bottom third: Edge area
	else:
		zoom_content_label.text = "~"
		zoom_content_label.add_theme_font_size_override("font_size", 100)

func _on_uv_button_pressed():
	"""Toggle UV light mode"""
	is_uv_active = not is_uv_active

	if is_uv_active:
		# Activate UV mode
		uv_button.text = "💡 UV LIGHT (ON)"

		# Purple tint on book
		var base_color = current_book_data.get("book_cover_color", Color("#F4E8D8"))
		var uv_color = Color(
			base_color.r * 0.7 + 0.4 * 0.3,
			base_color.g * 0.7 + 0.0 * 0.3,
			base_color.b * 0.7 + 0.8 * 0.3
		)
		var style = book_cover_panel.get_theme_stylebox("panel").duplicate()
		style.bg_color = uv_color
		book_cover_panel.add_theme_stylebox_override("panel", style)

		# Show UV hidden text
		uv_overlay_label.visible = true
		uv_overlay_label.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(uv_overlay_label, "modulate:a", 1.0, 0.5)
	else:
		# Deactivate UV mode
		uv_button.text = "💡 UV LIGHT"

		# Restore original book color
		var base_color = current_book_data.get("book_cover_color", Color("#F4E8D8"))
		var style = book_cover_panel.get_theme_stylebox("panel").duplicate()
		style.bg_color = base_color
		book_cover_panel.add_theme_stylebox_override("panel", style)

		# Hide UV text
		var tween = create_tween()
		tween.tween_property(uv_overlay_label, "modulate:a", 0.0, 0.3)
		await tween.finished
		uv_overlay_label.visible = false

func _on_begin_translation_pressed():
	"""Proceed to translation phase"""
	# Reset cursor
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	# Emit signal to open translation screen
	begin_translation.emit()

func refresh():
	"""Update display when panel is refreshed"""
	initialize()
