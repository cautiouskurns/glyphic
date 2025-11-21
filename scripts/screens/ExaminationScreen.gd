# ExaminationScreen.gd
# Feature 4.1: Book Examination Phase - panel-compatible
# Shows book cover with zoom tool, optional UV light reveal
extends Control

# Panel mode flag (kept for compatibility, but layout is now in .tscn)
var panel_mode: bool = false

# UI References (now from scene tree)
@onready var background_panel = $BackgroundPanel
@onready var customer_header = $MarginContainer/MainVBox/CustomerHeader
@onready var book_cover_panel = $MarginContainer/MainVBox/BookCoverPanel
@onready var book_title_label = $MarginContainer/MainVBox/BookCoverPanel/BookContent/BookTitleLabel
@onready var book_pattern_label = $MarginContainer/MainVBox/BookCoverPanel/BookContent/BookPatternLabel
@onready var uv_overlay_label = $MarginContainer/MainVBox/BookCoverPanel/BookContent/UVOverlayLabel
@onready var crosshair_h = $MarginContainer/MainVBox/BookCoverPanel/BookContent/CrosshairH
@onready var crosshair_v = $MarginContainer/MainVBox/BookCoverPanel/BookContent/CrosshairV
@onready var zoom_panel = $MarginContainer/MainVBox/BookCoverPanel/BookContent/ZoomPanel
@onready var zoom_view_rect = $MarginContainer/MainVBox/BookCoverPanel/BookContent/ZoomPanel/ZoomViewRect
@onready var zoom_content_label = $MarginContainer/MainVBox/BookCoverPanel/BookContent/ZoomPanel/ZoomViewRect/ZoomContentLabel
@onready var uv_button = $MarginContainer/MainVBox/ButtonRow/UVButton
@onready var begin_button = $MarginContainer/MainVBox/ButtonRow/BeginButton

# State
var current_book_data: Dictionary = {}
var current_text_id: int = 0
var is_uv_active: bool = false
var is_mouse_over_book: bool = false

# Slide animation
var target_position: Vector2  # Final position on screen
var slide_tween: Tween
const SLIDE_DURATION = 0.4
const OFF_SCREEN_X = -700  # Off-screen to the left

# Signals
signal begin_translation

func _ready():
	"""Initialize examination screen"""
	# Store target position and start off-screen
	target_position = position
	position.x = OFF_SCREEN_X

	# Connect button signals
	uv_button.pressed.connect(_on_uv_button_pressed)
	begin_button.pressed.connect(_on_begin_translation_pressed)

	await get_tree().process_frame
	await get_tree().process_frame
	initialize()

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
	var style = book_cover_panel.get_theme_stylebox("panel")
	if style == null:
		# Create default style if none exists
		style = StyleBoxFlat.new()
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		style.border_color = Color(0.545, 0.266, 0.137)
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_right = 4
		style.corner_radius_bottom_left = 4
	else:
		style = style.duplicate()
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

func slide_in():
	"""Animate screen sliding in from left"""
	if slide_tween:
		slide_tween.kill()

	visible = true
	slide_tween = create_tween()
	slide_tween.set_ease(Tween.EASE_OUT)
	slide_tween.set_trans(Tween.TRANS_CUBIC)

	slide_tween.tween_property(self, "position:x", target_position.x, SLIDE_DURATION)

func slide_out():
	"""Animate screen sliding out to left"""
	if slide_tween:
		slide_tween.kill()

	slide_tween = create_tween()
	slide_tween.set_ease(Tween.EASE_IN)
	slide_tween.set_trans(Tween.TRANS_CUBIC)

	slide_tween.tween_property(self, "position:x", OFF_SCREEN_X, SLIDE_DURATION * 0.75)

	await slide_tween.finished
	visible = false
