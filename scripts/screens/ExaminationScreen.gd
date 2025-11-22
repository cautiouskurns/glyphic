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

# New UI elements for enhanced examination
@onready var spine_text_label = $MarginContainer/MainVBox/BookCoverPanel/BookContent/SpineTextLabel
@onready var embossing_label = $MarginContainer/MainVBox/BookCoverPanel/BookContent/EmbossingLabel
@onready var wear_overlay = $MarginContainer/MainVBox/BookCoverPanel/BookContent/WearOverlay
@onready var torn_corner_tl = $MarginContainer/MainVBox/BookCoverPanel/BookContent/WearOverlay/TornCornerTL
@onready var torn_corner_tr = $MarginContainer/MainVBox/BookCoverPanel/BookContent/WearOverlay/TornCornerTR
@onready var cracked_spine = $MarginContainer/MainVBox/BookCoverPanel/BookContent/WearOverlay/CrackedSpine
@onready var damage_overlay = $MarginContainer/MainVBox/BookCoverPanel/BookContent/DamageOverlay
@onready var water_stain = $MarginContainer/MainVBox/BookCoverPanel/BookContent/DamageOverlay/WaterStain
@onready var coffee_stain = $MarginContainer/MainVBox/BookCoverPanel/BookContent/DamageOverlay/CoffeeStain
@onready var bookmark_ribbon = $MarginContainer/MainVBox/BookCoverPanel/BookContent/BookmarkRibbon
@onready var flavor_text_label = $MarginContainer/MainVBox/ExaminationInfoPanel/FlavorTextLabel
@onready var physical_props_label = $MarginContainer/MainVBox/ExaminationInfoPanel/PhysicalPropsLabel
@onready var provenance_label = $MarginContainer/MainVBox/ExaminationInfoPanel/ProvenanceLabel
@onready var secrets_header_button = $MarginContainer/MainVBox/SecretsPanel/SecretsHeaderButton
@onready var secrets_list_vbox = $MarginContainer/MainVBox/SecretsPanel/SecretsListVBox

# State
var current_book_data: Dictionary = {}
var current_text_id: int = 0
var is_uv_active: bool = false
var is_mouse_over_book: bool = false
var secrets_expanded: bool = false
var current_secrets: Array[String] = []

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
	secrets_header_button.pressed.connect(_on_secrets_header_pressed)

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

	# Load BookResource if available (new system)
	var book_resource: BookResource = book_data.get("book_resource", null)

	# Update book appearance
	var book_color = book_data.get("book_cover_color", Color("#F4E8D8"))
	var border_color = book_color.darkened(0.3)

	# Apply visual style based on book properties
	var style = StyleBoxFlat.new()
	style.bg_color = book_color
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = border_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4

	# If book resource exists, apply enhanced visuals
	if book_resource:
		# Adjust border based on wear level
		if book_resource.wear_level > 70:
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
		elif book_resource.wear_level < 20:
			style.border_width_left = 4
			style.border_width_top = 4
			style.border_width_right = 4
			style.border_width_bottom = 4

	book_cover_panel.add_theme_stylebox_override("panel", style)
	zoom_view_rect.color = book_color

	# Update book title
	var book_title = book_data.get("book_title", "Ancient Tome")
	if book_resource:
		book_title = book_resource.title
	book_title_label.text = book_title

	# Update symbol pattern or cover pattern
	if book_resource and book_resource.cover_pattern != "":
		# Show decorative cover pattern
		book_pattern_label.text = book_resource.cover_pattern
	elif not text_data.is_empty():
		book_pattern_label.text = text_data.symbols

	# UV hidden text
	var uv_text = book_data.get("uv_hidden_text", "")
	if book_resource:
		uv_text = book_resource.uv_hidden_text
	uv_overlay_label.text = uv_text
	uv_overlay_label.visible = false

	# Show UV button if upgrade owned
	uv_button.visible = GameState.has_uv_light

	# Enable begin button
	begin_button.disabled = false

	# Populate new examination UI elements from book_resource
	if book_resource:
		populate_examination_details(book_resource)
	else:
		# Fallback for books without resources
		clear_examination_details()

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

func populate_examination_details(book: BookResource):
	"""Fill all examination UI elements with book resource data"""
	# Flavor text
	if book.examination_flavor_text != "":
		flavor_text_label.text = book.examination_flavor_text
	else:
		flavor_text_label.text = book.get_visual_description()

	# Physical properties
	var condition_text = "Pristine"
	if book.wear_level > 70:
		condition_text = "Heavily worn"
	elif book.wear_level > 40:
		condition_text = "Well-worn"
	elif book.wear_level > 20:
		condition_text = "Good"

	physical_props_label.text = "Material: %s • Size: %s • Condition: %s" % [
		book.cover_material,
		book.size,
		condition_text
	]

	# Provenance
	var provenance_parts: Array[String] = []
	if book.previous_owner != "":
		provenance_parts.append("Previous owner: " + book.previous_owner)
	if book.publication_year > 0:
		provenance_parts.append("Published: %d" % book.publication_year)
	if book.acquisition_note != "":
		provenance_parts.append(book.acquisition_note)

	if provenance_parts.size() > 0:
		provenance_label.text = " • ".join(provenance_parts)
	else:
		provenance_label.text = "Provenance unknown"

	# Spine text
	if book.spine_text != "" and book.spine_text != "[Unreadable ancient script]":
		spine_text_label.text = book.spine_text
		spine_text_label.visible = true
	else:
		spine_text_label.visible = false

	# Embossing
	if book.has_embossing:
		embossing_label.text = book.embossing_symbol
		embossing_label.visible = true
	else:
		embossing_label.visible = false

	# Wear overlays
	if book.wear_level > 60:
		wear_overlay.visible = true
		torn_corner_tl.visible = book.wear_level > 75
		torn_corner_tr.visible = book.wear_level > 80
		cracked_spine.visible = book.wear_level > 70
	else:
		wear_overlay.visible = false

	# Damage overlays
	damage_overlay.visible = book.water_damage or book.coffee_stain
	water_stain.visible = book.water_damage
	coffee_stain.visible = book.coffee_stain

	# Bookmark
	if book.bookmark_page > 0:
		bookmark_ribbon.visible = true
		# Vary bookmark color based on page number (just for variety)
		var hue = (book.bookmark_page % 360) / 360.0
		bookmark_ribbon.color = Color.from_hsv(hue, 0.7, 0.8)
	else:
		bookmark_ribbon.visible = false

	# Populate secrets
	current_secrets = book.get_all_secrets()
	update_secrets_display()

	# Print to console for testing
	print("=== BOOK EXAMINATION ===")
	print(book.get_visual_description())
	if book.examination_flavor_text != "":
		print("\n" + book.examination_flavor_text)

func clear_examination_details():
	"""Clear examination details for books without resources"""
	flavor_text_label.text = "No additional details available."
	physical_props_label.text = ""
	provenance_label.text = ""
	spine_text_label.visible = false
	embossing_label.visible = false
	wear_overlay.visible = false
	damage_overlay.visible = false
	bookmark_ribbon.visible = false
	current_secrets = []
	update_secrets_display()

func update_secrets_display():
	"""Update the secrets panel with current secrets"""
	# Clear existing secret labels
	for child in secrets_list_vbox.get_children():
		child.queue_free()

	# Update header count
	var unlocked_count = 0
	for secret in current_secrets:
		if not secret.contains("[UV Light]") and not secret.contains("[Better Lamp]"):
			unlocked_count += 1

	secrets_header_button.text = "%s Discoverable Secrets (%d/%d)" % [
		"▼" if secrets_expanded else "▶",
		unlocked_count,
		current_secrets.size()
	]

	# If expanded, show secrets
	if secrets_expanded and current_secrets.size() > 0:
		secrets_list_vbox.visible = true
		for secret in current_secrets:
			var secret_label = Label.new()
			secret_label.theme_override_font_sizes["font_size"] = 10

			# Check if secret is locked
			var is_locked = secret.contains("[UV Light]") or secret.contains("[Better Lamp]")
			if is_locked:
				secret_label.text = "🔒 " + secret
				secret_label.theme_override_colors["font_color"] = Color(0.5, 0.45, 0.4, 0.6)
			else:
				secret_label.text = "• " + secret
				secret_label.theme_override_colors["font_color"] = Color(0.4, 0.35, 0.3, 1)

			secrets_list_vbox.add_child(secret_label)
	else:
		secrets_list_vbox.visible = false

func _on_secrets_header_pressed():
	"""Toggle secrets panel expansion"""
	secrets_expanded = not secrets_expanded
	update_secrets_display()

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
