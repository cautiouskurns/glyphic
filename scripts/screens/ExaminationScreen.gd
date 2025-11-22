# ExaminationScreen.gd
# Feature 4.1: Book Examination Phase - panel-compatible
# Shows book cover with zoom tool, optional UV light reveal
extends Control

# Panel mode flag (kept for compatibility, but layout is now in .tscn)
var panel_mode: bool = false

# View References
@onready var cover_view = $CoverView
@onready var examination_view = $ExaminationView

# CoverView UI References
@onready var book_cover_display = $CoverView/CenterContainer/ContentVBox/BookCoverDisplay
@onready var cover_title_label = $CoverView/CenterContainer/ContentVBox/BookCoverDisplay/CoverContent/BookContentVBox/CoverTitleLabel
@onready var cover_author_label = $CoverView/CenterContainer/ContentVBox/BookCoverDisplay/CoverContent/BookContentVBox/CoverAuthorLabel
@onready var cover_pattern_label = $CoverView/CenterContainer/ContentVBox/BookCoverDisplay/CoverContent/BookContentVBox/CoverPatternLabel
@onready var open_book_button = $CoverView/CenterContainer/ContentVBox/BookCoverDisplay/CoverContent/OpenBookButton
@onready var cover_wear_overlay = $CoverView/CenterContainer/ContentVBox/BookCoverDisplay/CoverContent/CoverWearOverlay
@onready var cover_damage_overlay = $CoverView/CenterContainer/ContentVBox/BookCoverDisplay/CoverContent/CoverDamageOverlay

# ExaminationView UI References (updated paths)
@onready var background_panel = $BackgroundPanel
@onready var customer_header = $ExaminationView/MainVBox/CustomerHeader
@onready var book_cover_panel = $ExaminationView/MainVBox/BookCoverPanel
@onready var book_title_label = $ExaminationView/MainVBox/BookCoverPanel/BookContent/BookTitleLabel
@onready var book_pattern_label = $ExaminationView/MainVBox/BookCoverPanel/BookContent/BookPatternLabel
@onready var uv_overlay_label = $ExaminationView/MainVBox/BookCoverPanel/BookContent/UVOverlayLabel
@onready var crosshair_h = $ExaminationView/MainVBox/BookCoverPanel/BookContent/CrosshairH
@onready var crosshair_v = $ExaminationView/MainVBox/BookCoverPanel/BookContent/CrosshairV
@onready var zoom_panel = $ExaminationView/MainVBox/BookCoverPanel/BookContent/ZoomPanel
@onready var zoom_view_rect = $ExaminationView/MainVBox/BookCoverPanel/BookContent/ZoomPanel/ZoomViewRect
@onready var zoom_content_label = $ExaminationView/MainVBox/BookCoverPanel/BookContent/ZoomPanel/ZoomViewRect/ZoomContentLabel
@onready var uv_button = $ExaminationView/MainVBox/ButtonRow/UVButton
@onready var begin_button = $ExaminationView/MainVBox/ButtonRow/BeginButton

# New UI elements for enhanced examination (updated paths)
@onready var spine_text_label = $ExaminationView/MainVBox/BookCoverPanel/BookContent/SpineTextLabel
@onready var embossing_label = $ExaminationView/MainVBox/BookCoverPanel/BookContent/EmbossingLabel
@onready var wear_overlay = $ExaminationView/MainVBox/BookCoverPanel/BookContent/WearOverlay
@onready var torn_corner_tl = $ExaminationView/MainVBox/BookCoverPanel/BookContent/WearOverlay/TornCornerTL
@onready var torn_corner_tr = $ExaminationView/MainVBox/BookCoverPanel/BookContent/WearOverlay/TornCornerTR
@onready var cracked_spine = $ExaminationView/MainVBox/BookCoverPanel/BookContent/WearOverlay/CrackedSpine
@onready var damage_overlay = $ExaminationView/MainVBox/BookCoverPanel/BookContent/DamageOverlay
@onready var water_stain = $ExaminationView/MainVBox/BookCoverPanel/BookContent/DamageOverlay/WaterStain
@onready var coffee_stain = $ExaminationView/MainVBox/BookCoverPanel/BookContent/DamageOverlay/CoffeeStain
@onready var bookmark_ribbon = $ExaminationView/MainVBox/BookCoverPanel/BookContent/BookmarkRibbon
@onready var flavor_text_label = $ExaminationView/MainVBox/ExaminationInfoPanel/FlavorTextLabel
@onready var physical_props_label = $ExaminationView/MainVBox/ExaminationInfoPanel/PhysicalPropsLabel
@onready var provenance_label = $ExaminationView/MainVBox/ExaminationInfoPanel/ProvenanceLabel
@onready var secrets_header_button = $ExaminationView/MainVBox/SecretsPanel/SecretsHeaderButton
@onready var secrets_list_vbox = $ExaminationView/MainVBox/SecretsPanel/SecretsListVBox

# State
var view_mode: String = "cover"  # "cover" or "examination"
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
	open_book_button.pressed.connect(_on_open_book_pressed)
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
	"""Load book examination data - shows cover view first"""
	current_book_data = book_data
	current_text_id = book_data.get("text_id", 1)
	is_uv_active = false
	view_mode = "cover"

	# Show cover view, hide examination view
	cover_view.visible = true
	examination_view.visible = false

	# Load BookResource if available
	var book_resource: BookResource = book_data.get("book_resource", null)

	# Populate cover view
	if book_resource:
		populate_cover_view(book_resource)

	# Also prepare examination view in background
	# Get text data for symbols
	var text_data = SymbolData.get_text(current_text_id)

	# Update customer header
	var customer_name = book_data.get("name", "Unknown")
	customer_header.text = "Examining %s's book" % customer_name

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

func populate_cover_view(book: BookResource):
	"""Populate the cover view with book data"""
	# Set title and author
	cover_title_label.text = book.title
	if book.author != "":
		cover_author_label.text = book.author
	else:
		cover_author_label.text = "[Author Unknown]"

	# Set cover pattern/decoration
	if book.has_embossing:
		cover_pattern_label.text = book.embossing_symbol
	elif book.cover_pattern != "":
		cover_pattern_label.text = book.cover_pattern
	else:
		cover_pattern_label.text = "~"

	# Set book size based on size property
	var size_multiplier = book.get_size_multiplier()
	var base_width = 320.0
	var base_height = 450.0
	book_cover_display.custom_minimum_size = Vector2(
		base_width * size_multiplier,
		base_height * size_multiplier
	)

	# Apply cover color and material-based border
	var cover_style = StyleBoxFlat.new()
	cover_style.bg_color = book.cover_color

	# Border thickness based on material
	var border_width = 3
	match book.cover_material:
		"Leather":
			border_width = 4  # Thick borders for leather
		"Cloth":
			border_width = 3  # Medium borders for cloth
		"Paper":
			border_width = 2  # Thin borders for paper
		"Wood":
			border_width = 5  # Very thick borders for wood

	cover_style.border_width_left = border_width
	cover_style.border_width_top = border_width
	cover_style.border_width_right = border_width
	cover_style.border_width_bottom = border_width
	cover_style.border_color = book.cover_color.darkened(0.4)

	# Rounded corners based on material
	var corner_radius = 4
	if book.cover_material == "Wood":
		corner_radius = 2  # Less rounded for wood
	elif book.cover_material == "Paper":
		corner_radius = 6  # More rounded for paper

	cover_style.corner_radius_top_left = corner_radius
	cover_style.corner_radius_top_right = corner_radius
	cover_style.corner_radius_bottom_right = corner_radius
	cover_style.corner_radius_bottom_left = corner_radius

	# Apply shadow for depth
	cover_style.shadow_color = Color(0, 0, 0, 0.3)
	cover_style.shadow_size = 8
	cover_style.shadow_offset = Vector2(4, 4)

	book_cover_display.add_theme_stylebox_override("panel", cover_style)

	# TODO: Add wear/damage overlays to cover if needed
	# For now, we'll skip cover overlays as they're complex to position dynamically

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

func _on_open_book_pressed():
	"""Transition from cover view to examination view"""
	view_mode = "examination"

	# Fade out cover view
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(cover_view, "modulate:a", 0.0, 0.3)
	await fade_out_tween.finished

	# Hide cover, show examination
	cover_view.visible = false
	cover_view.modulate.a = 1.0  # Reset for next time
	examination_view.visible = true
	examination_view.modulate.a = 0.0

	# Fade in examination view
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(examination_view, "modulate:a", 1.0, 0.3)

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
