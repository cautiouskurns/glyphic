# ExaminationScreen.gd
# Feature 4.1: Book Examination Phase
# Shows book cover with zoom tool, optional UV light reveal
extends Control

signal examination_skipped(text_id, customer_name)

@onready var customer_header = $CustomerHeader/HeaderLabel
@onready var book_cover_rect = $BookCoverRect
@onready var book_title_label = $BookCoverRect/BookTitleLabel
@onready var book_pattern_label = $BookCoverRect/BookPatternLabel
@onready var uv_overlay_label = $BookCoverRect/UVOverlayLabel
@onready var zoom_inset_panel = $ZoomInsetPanel
@onready var zoom_view_rect = $ZoomInsetPanel/ZoomViewRect
@onready var zoom_content_label = $ZoomInsetPanel/ZoomViewRect/ZoomContentLabel
@onready var crosshair_h = $BookCoverRect/CrosshairH
@onready var crosshair_v = $BookCoverRect/CrosshairV
@onready var skip_button = $Toolbar/SkipButton
@onready var uv_button = $Toolbar/UVButton

var current_customer_data: Dictionary = {}
var current_text_id: int = 0
var is_uv_active: bool = false
var is_mouse_over_book: bool = false

func _ready():
	# Start hidden
	visible = false

func load_book(customer_data: Dictionary, text_id: int):
	"""Load book examination screen for accepted customer"""
	current_customer_data = customer_data
	current_text_id = text_id
	is_uv_active = false

	# Set customer name in header
	var customer_name = customer_data.get("name", "Unknown Customer")
	customer_header.text = "Examining book for: %s" % customer_name

	# Set book cover color
	var book_color = customer_data.get("book_cover_color", Color("#F4E8D8"))
	var style = book_cover_rect.get_theme_stylebox("panel").duplicate()
	style.bg_color = book_color
	book_cover_rect.add_theme_stylebox_override("panel", style)

	# Also set zoom view to match
	zoom_view_rect.color = book_color

	# Set UV hidden text (will be shown if UV toggled)
	var uv_text = customer_data.get("uv_hidden_text", "")
	uv_overlay_label.text = uv_text
	uv_overlay_label.visible = false

	# Show/hide UV button based on upgrade
	uv_button.visible = GameState.has_uv_light
	if GameState.has_uv_light:
		# Reset UV button state
		uv_button.text = "UV LIGHT"
		var uv_style = StyleBoxFlat.new()
		uv_style.bg_color = Color("#4B0082")  # Purple
		uv_style.border_width_left = 2
		uv_style.border_width_top = 2
		uv_style.border_width_right = 2
		uv_style.border_width_bottom = 2
		uv_style.border_color = Color("#9370DB")
		uv_style.corner_radius_top_left = 6
		uv_style.corner_radius_top_right = 6
		uv_style.corner_radius_bottom_right = 6
		uv_style.corner_radius_bottom_left = 6
		uv_button.add_theme_stylebox_override("normal", uv_style)

	# Show the screen with fade-in
	visible = true
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func _process(_delta):
	"""Track mouse position for zoom effect"""
	if not visible:
		return

	# Get mouse position relative to the book cover
	var local_mouse = book_cover_rect.get_local_mouse_position()
	var book_size = book_cover_rect.size

	# Check if mouse is over book area (using local coordinates)
	if (local_mouse.x >= 0 and local_mouse.x <= book_size.x and
		local_mouse.y >= 0 and local_mouse.y <= book_size.y):
		if not is_mouse_over_book:
			is_mouse_over_book = true
			Input.set_default_cursor_shape(Input.CURSOR_CROSS)
			# Show crosshairs
			crosshair_h.visible = true
			crosshair_v.visible = true
		update_zoom(local_mouse, book_size)
	else:
		if is_mouse_over_book:
			is_mouse_over_book = false
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
			# Hide crosshairs
			crosshair_h.visible = false
			crosshair_v.visible = false

func update_zoom(local_mouse: Vector2, book_size: Vector2):
	"""Update 2× zoom view based on mouse position"""
	# Calculate relative position on book (0.0 to 1.0)
	var rel_x = local_mouse.x / book_size.x
	var rel_y = local_mouse.y / book_size.y

	# Update crosshair positions to follow mouse (already in local coordinates)
	crosshair_h.position.y = local_mouse.y - 1
	crosshair_v.position.x = local_mouse.x - 1

	# Update zoom panel background color
	var base_color = current_customer_data.get("book_cover_color", Color("#F4E8D8"))
	zoom_view_rect.color = base_color

	# Determine which part of the book is being viewed
	# Match the actual book layout for more accurate zoom

	# Top third: Title area
	if rel_y < 0.30:
		zoom_content_label.text = "Ancient"
		zoom_content_label.add_theme_font_size_override("font_size", 120)

	# Middle third: Symbol pattern area (matches BookPatternLabel layout)
	elif rel_y >= 0.30 and rel_y < 0.70:
		# First row of symbols (line 1 of pattern)
		if rel_y < 0.50:
			var symbols_row1 = ["∆", "◊", "≈", "⊕", "⊗", "◈"]
			var index = int(rel_x * symbols_row1.size())
			if index >= symbols_row1.size():
				index = symbols_row1.size() - 1
			zoom_content_label.text = symbols_row1[index]
		# Second row of symbols (line 2 of pattern)
		else:
			var symbols_row2 = ["⊞", "⊟", "≈", "⬡", "≈", "≈", "⊢", "⬡"]
			var index = int(rel_x * symbols_row2.size())
			if index >= symbols_row2.size():
				index = symbols_row2.size() - 1
			zoom_content_label.text = symbols_row2[index]
		zoom_content_label.add_theme_font_size_override("font_size", 160)

	# Bottom third: Border/edge area
	else:
		zoom_content_label.text = "~"
		zoom_content_label.add_theme_font_size_override("font_size", 200)

func _on_skip_button_pressed():
	"""Skip examination and proceed to translation"""
	# Reset cursor
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished

	# Hide self
	visible = false

	# Emit signal to proceed to translation
	examination_skipped.emit(current_text_id, current_customer_data.get("name", ""))

func _on_uv_button_pressed():
	"""Toggle UV light mode"""
	is_uv_active = not is_uv_active

	if is_uv_active:
		# Activate UV mode
		uv_button.text = "UV LIGHT (ON)"

		# Purple tint on book
		var style = book_cover_rect.get_theme_stylebox("panel").duplicate()
		var base_color = current_customer_data.get("book_cover_color", Color("#F4E8D8"))
		# Blend with purple
		var uv_color = Color(
			base_color.r * 0.7 + 0.4 * 0.3,
			base_color.g * 0.7 + 0.0 * 0.3,
			base_color.b * 0.7 + 0.8 * 0.3
		)
		style.bg_color = uv_color
		book_cover_rect.add_theme_stylebox_override("panel", style)

		# Show UV hidden text
		uv_overlay_label.visible = true

		# Tween transition
		uv_overlay_label.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(uv_overlay_label, "modulate:a", 1.0, 0.5)

	else:
		# Deactivate UV mode
		uv_button.text = "UV LIGHT"

		# Restore original book color
		var style = book_cover_rect.get_theme_stylebox("panel").duplicate()
		style.bg_color = current_customer_data.get("book_cover_color", Color("#F4E8D8"))
		book_cover_rect.add_theme_stylebox_override("panel", style)

		# Hide UV text
		var tween = create_tween()
		tween.tween_property(uv_overlay_label, "modulate:a", 0.0, 0.3)
		await tween.finished
		uv_overlay_label.visible = false

func _input(event):
	"""Handle keyboard shortcuts"""
	if not visible:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ESCAPE:
			# Skip with spacebar or escape
			_on_skip_button_pressed()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_U and GameState.has_uv_light:
			# Toggle UV with U key
			_on_uv_button_pressed()
			get_viewport().set_input_as_handled()
