# ShopScene.gd
# Main diegetic shop interface - atmospheric library/study aesthetic
@tool
extends Control

@onready var left_bookshelf = $LeftBookshelf
@onready var left_bookshelf2 = $LeftBookshelf2
@onready var right_bookshelf = $RightBookshelf
@onready var left_books_container = $LeftBookshelf/BooksContainer
@onready var left_books_container2 = $LeftBookshelf2/BooksContainer
@onready var right_books_container = $RightBookshelf/BooksContainer
@onready var papers = $Desk/Papers
@onready var open_book = $Desk/OpenBook
@onready var doorway = $Doorway

# Interactive navigation buttons (now scene instances with built-in visuals and tooltips)
@onready var diary_button = $Desk/DiaryButton
@onready var dictionary_button = $Desk/DictionaryButton
@onready var papers_button = $Desk/PapersButton
@onready var magnifying_glass_button = $Desk/MagnifyingGlassButton
@onready var bell_button = $Desk/BellButton

# Preload book scene
var book_scene = preload("res://scenes/ui/Book.tscn")

# Store references to top bar labels for updating
var day_label: Label
var cash_label: Label
var hint_label: Label  # Bottom hint text

# Feature 3A.2: Shop Workspace Zones - Camera and focus mode
var camera: Camera2D  # Created programmatically
var background_dim: ColorRect  # Overlay for dimming bookshelves

# Workspace zone state
var is_focused_mode: bool = false
var focus_tween: Tween

# Feature 3A.3: Panel management
var active_panels: Dictionary = {}  # {panel_type: DiegeticPanel}
var panel_stack: Array[String] = []  # Stack of panel types (for z-order)
const MAX_PANELS = 4

# Feature 3A.4: Customer popup
var customer_popup: Control

# Camera positions and zoom levels
var default_camera_position: Vector2 = Vector2(960, 540)  # Center of 1920×1080
var focused_camera_position: Vector2 = Vector2(960, 970)  # Shifted down to desk focus
var default_zoom: Vector2 = Vector2(1.0, 1.0)
var focused_zoom: Vector2 = Vector2(1.0, 1.0)  # Keep same zoom, just shift perspective

# Panel zone configuration (Feature 3A.3)
# Different zones for different panel types - spatial mapping to desk objects
#
# HOW TO EDIT PANEL POSITIONS:
# 1. Open ShopScene.tscn in the editor
# 2. Expand PanelZones node in the scene tree
# 3. Select a zone (e.g., QueueZone, TranslationZone)
# 4. Use the 2D transform tools to drag/resize the zone
# 5. The semi-transparent colored rectangles show where panels will appear
# 6. When happy with layout, run game and open debugger console
# 7. Call: get_node("/root/ShopScene").sync_panel_zones_from_scene()
# 8. Copy the output from console and paste it below
#
# const PANEL_ZONES = {
# 	"queue": Vector2(75, 700),           # Left zone - near diary
# 	"translation": Vector2(500, 720),     # Center-left - near papers
# 	"dictionary": Vector2(1300, 720),     # Right zone - near dictionary/book (larger, more visible)
# 	"examination": Vector2(850, 740),     # Center - near magnifying glass
# 	"work": Vector2(1050, 700)            # Center-right - near bell
# }

const PANEL_ZONES = {
	"queue": Vector2(20, 750),          # Left edge - archive area (on desk)
	"translation": Vector2(310, 1300),  # Bottom - horizontal notebook (lower on desk)
	"dictionary": Vector2(1200, 700),   # Right - reference area (on desk)
	"examination": Vector2(100, 700),   # Left - work area (on desk)
	"work": Vector2(1050, 700),         # Keep existing for now
}


# const PANEL_WIDTH = 350
# const PANEL_HEIGHT = 650
# # Dictionary panel gets special larger size
# const DICTIONARY_PANEL_WIDTH = 520
# const DICTIONARY_PANEL_HEIGHT = 750
# # Translation panel gets special width
# const TRANSLATION_PANEL_WIDTH = 500
# const TRANSLATION_PANEL_HEIGHT = 650
# # Examination panel gets special larger size
# const EXAMINATION_PANEL_WIDTH = 520
# const EXAMINATION_PANEL_HEIGHT = 650

const PANEL_WIDTH = 309
const PANEL_HEIGHT = 483

const TRANSLATION_PANEL_WIDTH = 451
const TRANSLATION_PANEL_HEIGHT = 596

const DICTIONARY_PANEL_WIDTH = 426
const DICTIONARY_PANEL_HEIGHT = 750

const EXAMINATION_PANEL_WIDTH = 520
const EXAMINATION_PANEL_HEIGHT = 650


# Panel type to color/title mapping (Feature 3A.3)
const PANEL_COLORS = {
	"queue": Color("#A0826D"),       # Brown
	"translation": Color("#F4E8D8"),  # Cream
	"dictionary": Color("#A0826D"),   # Brown (matches queue)
	"examination": Color("#A0826D"),  # Brown (matches queue/dictionary)
	"work": Color("#FFD700")          # Gold
}

const PANEL_TITLES = {
	"queue": "Customer Queue",
	"translation": "Translation Workspace",
	"dictionary": "Glyph Dictionary",
	"examination": "Book Examination",
	"work": "Current Work"
}

func _ready():
	"""Initialize shop scene (only runs once now that scene persists)"""
	# Skip initialization in editor
	if Engine.is_editor_hint():
		return

	# Feature 3A.4: Add to group so DiegeticScreenManager can find this scene
	add_to_group("shop_scene")

	add_top_bar()
	setup_lighting()
	setup_wood_paneling()
	setup_bookshelves()
	add_shelf_dividers(left_bookshelf)
	add_shelf_dividers(left_bookshelf2)
	add_shelf_dividers(right_bookshelf)
	setup_interactive_bookshelf_spines()
	setup_doorway_scene()

	# Generate books (only happens once since scene persists)
	generate_books(left_books_container, 70)
	generate_books(left_books_container2, 70)
	generate_books(right_books_container, 65)

	setup_papers_styling()
	setup_book_styling()
	add_desk_texture()
	add_paper_details()
	add_book_details()
	add_shadows()
	add_dust_particles()
	setup_interactive_buttons()
	setup_archive_access_button()

	# Feature 3A.2: Setup workspace zones and camera
	setup_camera()
	setup_background_dim()
	connect_desk_objects()

	# Feature 3A.4: Setup customer popup
	setup_customer_popup()

	# Hide panel zone markers at runtime
	hide_panel_zone_markers()

func add_top_bar():
	"""Add top bar with day and money information"""
	# Top bar background
	var top_bar = Panel.new()
	top_bar.size = Vector2(1920, 90)
	top_bar.position = Vector2(0, 0)
	top_bar.z_index = 100  # Ensure it's on top

	var top_bar_style = StyleBoxFlat.new()
	top_bar_style.bg_color = Color(0.164706, 0.121569, 0.101961, 1)
	top_bar.add_theme_stylebox_override("panel", top_bar_style)
	add_child(top_bar)

	# Day label - store reference for updates
	day_label = Label.new()
	day_label.position = Vector2(30, 30)
	day_label.size = Vector2(345, 38)
	day_label.text = "Day %d - %s" % [GameState.current_day, get_day_name(GameState.current_day)]
	day_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	day_label.add_theme_font_size_override("font_size", 27)
	top_bar.add_child(day_label)

	# Cash label - store reference for updates
	cash_label = Label.new()
	cash_label.position = Vector2(1550, 22)
	cash_label.size = Vector2(340, 46)
	cash_label.text = "$%d" % GameState.player_cash
	cash_label.add_theme_color_override("font_color", Color(0.37577152, 0.63815117, 0.20049343, 1))
	cash_label.add_theme_font_size_override("font_size", 36)
	cash_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_bar.add_child(cash_label)

	# Bottom hint label - store reference for focus mode
	hint_label = Label.new()
	hint_label.position = Vector2(0, 1040)
	hint_label.size = Vector2(1920, 40)
	hint_label.text = "Click on objects to navigate • Press ESC or click 🏠 Return to Shop button to come back"
	hint_label.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6, 0.8))
	hint_label.add_theme_font_size_override("font_size", 16)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.z_index = 100
	add_child(hint_label)

func get_day_name(day: int) -> String:
	"""Get day of week name"""
	var days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
	return days[(day - 1) % 7]

func setup_bookshelves():
	"""Style all three bookshelves with dark wood tones"""
	# Create shared shelf style
	var shelf_style = StyleBoxFlat.new()
	shelf_style.bg_color = Color(0.239216, 0.156863, 0.0784314, 1)  # #3D2814
	shelf_style.border_width_left = 4
	shelf_style.border_width_top = 4
	shelf_style.border_width_right = 4
	shelf_style.border_width_bottom = 4
	shelf_style.border_color = Color(0.2, 0.13, 0.07, 1)
	shelf_style.shadow_size = 8
	shelf_style.shadow_offset = Vector2(2, 3)
	shelf_style.shadow_color = Color(0, 0, 0, 0.4)

	# Apply to all bookshelves
	left_bookshelf.get_node("ShelfPanel").add_theme_stylebox_override("panel", shelf_style)
	left_bookshelf2.get_node("ShelfPanel").add_theme_stylebox_override("panel", shelf_style)
	right_bookshelf.get_node("ShelfPanel").add_theme_stylebox_override("panel", shelf_style)

func setup_interactive_bookshelf_spines():
	"""Add clickable reference book spines to right bookshelf"""
	# Reference books data: {name, color, position_y, book_type}
	var reference_books = [
		{"name": "Grimoire", "color": Color(0.6, 0.1, 0.1), "y": 120, "type": "grimoire"},
		{"name": "Grammar Guide", "color": Color(0.1, 0.5, 0.2), "y": 240, "type": "grammar"},
		{"name": "Encyclopedia", "color": Color(0.8, 0.4, 0.1), "y": 360, "type": "encyclopedia"},
		{"name": "Atlas", "color": Color(0.4, 0.3, 0.2), "y": 480, "type": "atlas"}
	]

	var shelf_panel = right_bookshelf.get_node("ShelfPanel")

	for book_data in reference_books:
		# Create book spine button
		var book_button = Button.new()
		book_button.custom_minimum_size = Vector2(35, 120)
		book_button.size = Vector2(35, 120)
		book_button.position = Vector2(15, book_data.y)  # Left edge of shelf
		book_button.flat = false
		book_button.tooltip_text = "Open %s" % book_data.name

		# Style as book spine
		var spine_style = StyleBoxFlat.new()
		spine_style.bg_color = book_data.color
		spine_style.border_width_left = 1
		spine_style.border_width_top = 2
		spine_style.border_width_right = 1
		spine_style.border_width_bottom = 2
		spine_style.border_color = book_data.color.darkened(0.3)
		spine_style.corner_radius_top_left = 2
		spine_style.corner_radius_bottom_left = 2
		spine_style.shadow_size = 4
		spine_style.shadow_offset = Vector2(2, 2)
		spine_style.shadow_color = Color(0, 0, 0, 0.3)
		book_button.add_theme_stylebox_override("normal", spine_style)
		book_button.add_theme_stylebox_override("hover", spine_style.duplicate())
		book_button.add_theme_stylebox_override("pressed", spine_style.duplicate())

		# Add vertical text label (book title)
		var title_label = Label.new()
		title_label.text = book_data.name
		title_label.rotation_degrees = -90
		title_label.position = Vector2(17, 60)  # Centered on spine
		title_label.add_theme_font_size_override("font_size", 10)
		title_label.add_theme_color_override("font_color", Color(1, 1, 1))
		title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		book_button.add_child(title_label)

		# Connect click to open dictionary with book context
		book_button.pressed.connect(_on_reference_book_clicked.bind(book_data.type))

		shelf_panel.add_child(book_button)

func _on_reference_book_clicked(book_type: String):
	"""Handle reference book spine click - open dictionary panel"""
	print("Reference book clicked: %s" % book_type)

	if not is_focused_mode:
		enter_focus_mode()

	# Check if dictionary panel already open
	if active_panels.has("dictionary"):
		bring_panel_to_front("dictionary")
	else:
		open_panel("dictionary")

	# TODO: Load book-specific content into dictionary
	# This will be implemented when dictionary screen supports different book types

func setup_wood_paneling():
	"""Add wood paneling behind bookshelves"""
	# Create wood panel strips for background texture
	var panel_width = 80
	var panel_count = 25  # Cover full width

	for i in range(panel_count):
		var panel = ColorRect.new()
		panel.size = Vector2(panel_width, 1080)
		panel.position = Vector2(i * panel_width, 0)

		# Alternating wood tones for panel effect
		if i % 2 == 0:
			panel.color = Color(0.18, 0.12, 0.08, 1)
		else:
			panel.color = Color(0.16, 0.11, 0.07, 1)

		# Add to background (insert after background ColorRect)
		add_child(panel)
		move_child(panel, 1)  # Put behind bookshelves but above background

func setup_doorway_scene():
	"""Add dark dusk sky with moon and black silhouetted skyline"""
	var door_light = doorway.get_node("DoorLight")

	# Clear the existing solid color and replace with dark gradient sky
	door_light.color = Color(1, 1, 1, 0)  # Make transparent

	# Create dark dusk sky gradient using layered ColorRects
	# Top layer (deep dark blue-purple)
	var sky_top = ColorRect.new()
	sky_top.size = Vector2(door_light.size.x, door_light.size.y * 0.5)
	sky_top.position = Vector2(0, 0)
	sky_top.color = Color(0.08, 0.1, 0.18, 1)  # Deep twilight blue
	door_light.add_child(sky_top)
	door_light.move_child(sky_top, 0)

	# Mid layer (dark purple-orange)
	var sky_mid = ColorRect.new()
	sky_mid.size = Vector2(door_light.size.x, door_light.size.y * 0.3)
	sky_mid.position = Vector2(0, door_light.size.y * 0.45)
	sky_mid.color = Color(0.15, 0.12, 0.15, 1)  # Dark purple-grey
	door_light.add_child(sky_mid)
	door_light.move_child(sky_mid, 0)

	# Bottom layer (darker orange at horizon)
	var sky_bottom = ColorRect.new()
	sky_bottom.size = Vector2(door_light.size.x, door_light.size.y * 0.25)
	sky_bottom.position = Vector2(0, door_light.size.y * 0.75)
	sky_bottom.color = Color(0.18, 0.14, 0.12, 1)  # Dark warm brown
	door_light.add_child(sky_bottom)
	door_light.move_child(sky_bottom, 0)

	# Add moon (large, pale)
	var moon = Polygon2D.new()
	moon.polygon = create_circle_points(Vector2(220, 80), 35)
	moon.color = Color(0.95, 0.93, 0.85, 1)  # Pale moon
	door_light.add_child(moon)

	# Moon glow (subtle)
	var moon_glow = Polygon2D.new()
	moon_glow.polygon = create_circle_points(Vector2(220, 80), 45)
	moon_glow.color = Color(0.9, 0.88, 0.8, 0.2)  # Faint glow
	door_light.add_child(moon_glow)
	door_light.move_child(moon_glow, moon.get_index())  # Behind moon

	# Create black silhouetted skyline
	var skyline_container = Control.new()
	skyline_container.size = Vector2(300, 200)
	skyline_container.position = Vector2(0, door_light.size.y - 200)
	door_light.add_child(skyline_container)

	# Building silhouettes (varied heights, pure black)
	var building_data = [
		{"x": 0, "width": 35, "height": 80},
		{"x": 35, "width": 40, "height": 120},
		{"x": 75, "width": 25, "height": 65},
		{"x": 100, "width": 50, "height": 140},
		{"x": 150, "width": 30, "height": 90},
		{"x": 180, "width": 45, "height": 110},
		{"x": 225, "width": 35, "height": 85},
		{"x": 260, "width": 40, "height": 130}
	]

	for building in building_data:
		var building_rect = ColorRect.new()
		building_rect.size = Vector2(building.width, building.height)
		building_rect.position = Vector2(building.x, 200 - building.height)
		building_rect.color = Color(0, 0, 0, 1)  # Pure black silhouette
		skyline_container.add_child(building_rect)

		# Add subtle building details (antenna, spires) to some buildings
		if randf() < 0.4:
			var antenna = ColorRect.new()
			antenna.size = Vector2(2, randf_range(10, 25))
			antenna.position = Vector2(building.width / 2 - 1, -antenna.size.y)
			antenna.color = Color(0, 0, 0, 1)
			building_rect.add_child(antenna)

func add_shelf_dividers(bookshelf: Control):
	"""Add horizontal shelf dividers to show individual shelves"""
	var shelf_panel = bookshelf.get_node("ShelfPanel")
	var shelf_height = shelf_panel.size.y
	var shelves = 6
	var shelf_spacing = shelf_height / shelves

	for i in range(1, shelves):  # Don't add divider at top (0) or bottom (shelves)
		# Create thicker shelf with panel styling
		var shelf = PanelContainer.new()
		shelf.size = Vector2(shelf_panel.size.x, 12)
		shelf.position = Vector2(0, i * shelf_spacing - 6)  # Center on divider line

		var shelf_style = StyleBoxFlat.new()
		shelf_style.bg_color = Color(0.2, 0.13, 0.07, 1)
		shelf_style.border_width_top = 1
		shelf_style.border_width_bottom = 2
		shelf_style.border_color = Color(0.15, 0.1, 0.05, 1)
		shelf_style.shadow_size = 3
		shelf_style.shadow_offset = Vector2(0, 2)
		shelf_style.shadow_color = Color(0, 0, 0, 0.3)
		shelf.add_theme_stylebox_override("panel", shelf_style)

		shelf_panel.add_child(shelf)

func generate_books(container: Control, book_count: int):
	"""Generate varied books for a shelf using Book scene instances"""
	var shelf_width = container.size.x
	var shelf_height = container.size.y

	# Calculate shelves (assume 6 shelves)
	var shelves = 6
	var shelf_spacing = shelf_height / shelves
	var books_per_shelf = book_count / shelves

	for shelf_index in range(shelves):
		var shelf_y = shelf_index * shelf_spacing
		var current_x = 0.0

		# Generate books for this shelf
		var books_on_shelf = books_per_shelf + randi_range(-3, 3)

		for book_index in range(books_on_shelf):
			# Instantiate Book scene
			var book = book_scene.instantiate()
			container.add_child(book)

			# Book appearance is randomized in its _ready() function
			# Wait for next frame to get actual size after styling
			await get_tree().process_frame

			var book_width = book.size.x
			var book_height = book.size.y

			# Check if book fits on shelf, if not remove and move to next shelf
			if current_x + book_width > shelf_width:
				book.queue_free()
				break

			# Position book on shelf - align bottom edge with shelf bottom
			book.position = Vector2(current_x, shelf_y + shelf_spacing - book_height)

			current_x += book_width + randf_range(1, 4)  # Small gaps between books

func setup_papers_styling():
	"""Style the loose papers on the desk with aged paper appearance"""
	for paper in papers.get_children():
		var paper_style = StyleBoxFlat.new()
		paper_style.bg_color = Color(0.909804, 0.862745, 0.721569, 1)  # #E8DCC8
		paper_style.shadow_size = 10
		paper_style.shadow_offset = Vector2(4, 4)
		paper_style.shadow_color = Color(0, 0, 0, 0.35)
		paper_style.corner_radius_top_left = 2
		paper_style.corner_radius_top_right = 2
		paper_style.corner_radius_bottom_right = 2
		paper_style.corner_radius_bottom_left = 2
		paper.add_theme_stylebox_override("panel", paper_style)

func setup_book_styling():
	"""Style the open book with dark cover and aged pages"""
	var book_style = StyleBoxFlat.new()
	book_style.bg_color = Color(0.2, 0.15, 0.1, 1)  # Dark brown book cover
	book_style.shadow_size = 15
	book_style.shadow_offset = Vector2(5, 6)
	book_style.shadow_color = Color(0, 0, 0, 0.5)
	book_style.corner_radius_top_left = 4
	book_style.corner_radius_top_right = 4
	book_style.corner_radius_bottom_right = 4
	book_style.corner_radius_bottom_left = 4
	open_book.add_theme_stylebox_override("panel", book_style)

func setup_lighting():
	"""Add atmospheric lighting with desk lamp"""
	# Overall ambient darkness (lighter than before)
	var ambient = CanvasModulate.new()
	ambient.color = Color(0.55, 0.5, 0.45)  # Warmer, brighter ambient
	add_child(ambient)

	# Create physical desk lamp object (in desk-local coordinates)
	var lamp_local_position = Vector2(200, 50)  # Local to desk
	create_desk_lamp(lamp_local_position)

	# Create radial gradient texture for lamp light
	var gradient = Gradient.new()
	gradient.colors = [Color(1, 1, 1, 1), Color(1, 1, 1, 0)]
	gradient.offsets = [0.0, 1.0]

	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill = GradientTexture2D.FILL_RADIAL
	gradient_texture.fill_from = Vector2(0.5, 0.5)
	gradient_texture.fill_to = Vector2(1.0, 0.5)
	gradient_texture.width = 512
	gradient_texture.height = 512

	# Point light (warm spotlight) - in global coordinates
	var lamp_light = PointLight2D.new()
	lamp_light.position = Vector2(200 - 10, 650 + 50 - 130)  # Global position: desk top (650) + local (50) - bulb offset (130), adjusted for stem x offset
	lamp_light.texture = gradient_texture
	lamp_light.texture_scale = 6.0
	lamp_light.color = Color(1.0, 0.88, 0.65)  # Warm yellow
	lamp_light.energy = 1.5
	lamp_light.blend_mode = Light2D.BLEND_MODE_ADD
	lamp_light.z_index = 10  # Ensure light is on top
	add_child(lamp_light)

	# Subtle lamp flicker animation
	var tween = create_tween().set_loops()
	tween.tween_property(lamp_light, "energy", 1.3, 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(lamp_light, "energy", 1.7, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func create_desk_lamp(position: Vector2):
	"""Create a visible desk lamp at the specified position"""
	var lamp_container = Node2D.new()
	lamp_container.position = position
	lamp_container.z_index = 5  # Ensure lamp is visible above desk surface
	$Desk.add_child(lamp_container)

	# Lamp base (round, dark metal) - BIGGER
	var base = Polygon2D.new()
	base.polygon = create_circle_points(Vector2(0, 0), 35)
	base.color = Color(0.25, 0.2, 0.15, 1)  # Lighter so it's visible
	lamp_container.add_child(base)

	# Base shadow
	var base_shadow = Polygon2D.new()
	base_shadow.polygon = create_ellipse_points(Vector2(3, 5), 40, 12)
	base_shadow.color = Color(0, 0, 0, 0.4)
	base_shadow.z_index = -1
	lamp_container.add_child(base_shadow)

	# Lamp stem (curved arm) - BIGGER AND BRIGHTER
	var stem = Line2D.new()
	stem.add_point(Vector2(0, 0))
	stem.add_point(Vector2(-10, -50))
	stem.add_point(Vector2(-15, -100))
	stem.add_point(Vector2(-10, -130))
	stem.default_color = Color(0.35, 0.28, 0.22, 1)  # Lighter bronze
	stem.width = 10
	stem.joint_mode = Line2D.LINE_JOINT_ROUND
	stem.begin_cap_mode = Line2D.LINE_CAP_ROUND
	stem.end_cap_mode = Line2D.LINE_CAP_ROUND
	lamp_container.add_child(stem)

	# Lamp shade (cone/bell shape) - BIGGER
	var shade = Polygon2D.new()
	shade.polygon = PackedVector2Array([
		Vector2(-50, -150),  # Left top edge
		Vector2(30, -150),   # Right top edge
		Vector2(25, -120),   # Right bottom
		Vector2(-45, -120)   # Left bottom
	])
	shade.color = Color(0.4, 0.35, 0.25, 1)  # Brass/bronze shade exterior
	lamp_container.add_child(shade)

	# Shade interior (glowing, warm) - BIGGER
	var shade_interior = Polygon2D.new()
	shade_interior.polygon = PackedVector2Array([
		Vector2(-48, -148),
		Vector2(28, -148),
		Vector2(23, -122),
		Vector2(-43, -122)
	])
	shade_interior.color = Color(1.0, 0.9, 0.7, 1)  # Bright warm glowing interior
	lamp_container.add_child(shade_interior)

	# Light bulb glow (visible bright spot) - BIGGER AND BRIGHTER
	var bulb_glow = Polygon2D.new()
	bulb_glow.polygon = create_circle_points(Vector2(-10, -130), 15)
	bulb_glow.color = Color(1.0, 0.95, 0.8, 1)  # Very bright warm glow
	lamp_container.add_child(bulb_glow)

func create_circle_points(center: Vector2, radius: float) -> PackedVector2Array:
	"""Helper to create circle points for polygons"""
	var points = PackedVector2Array()
	for i in range(20):
		var angle = (i / 20.0) * TAU
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points

func create_ellipse_points(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	"""Helper to create ellipse points for shadows"""
	var points = PackedVector2Array()
	for i in range(20):
		var angle = (i / 20.0) * TAU
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points

func add_shadows():
	"""Add drop shadows under all desk elements for depth"""
	# Shadow under open book
	var book_shadow = ColorRect.new()
	book_shadow.color = Color(0, 0, 0, 0.5)
	book_shadow.size = open_book.size
	book_shadow.position = open_book.position + Vector2(8, 8)
	book_shadow.z_index = open_book.z_index - 1
	$Desk.add_child(book_shadow)
	$Desk.move_child(book_shadow, 0)

	# Shadows under papers
	for paper in papers.get_children():
		var shadow = ColorRect.new()
		shadow.color = Color(0, 0, 0, 0.35)
		shadow.size = paper.size
		shadow.position = paper.position + Vector2(5, 5)
		shadow.rotation = paper.rotation
		shadow.z_index = paper.z_index - 1
		papers.add_child(shadow)
		papers.move_child(shadow, 0)

func add_desk_texture():
	"""Add wood grain texture to desk surface"""
	var desk_surface = $Desk/DeskSurface

	# Create subtle wood grain lines
	for i in range(25):
		var line = Line2D.new()
		var y = randf_range(0, desk_surface.size.y)
		line.add_point(Vector2(0, y))
		line.add_point(Vector2(desk_surface.size.x, y))
		line.default_color = Color(0, 0, 0, 0.08)
		line.width = randf_range(1, 2)
		desk_surface.add_child(line)

func add_paper_details():
	"""Add lived-in details to papers - scribbles, stains, rotation"""
	var paper_array = papers.get_children()

	# Add slight rotation to all papers (already has some, enhance it)
	for paper in paper_array:
		# Already rotated in scene, add scribbles
		var scribbles = Node2D.new()
		paper.add_child(scribbles)

		# Add 3-4 handwritten lines
		for i in range(randi_range(3, 4)):
			var line = Line2D.new()
			var start = Vector2(20, 30 + i * 20)
			var end = Vector2(paper.size.x - 20, 30 + i * 20)
			line.add_point(start)
			line.add_point(end)
			line.default_color = Color(0.2, 0.2, 0.2, 0.3)  # Faded ink
			line.width = 1
			scribbles.add_child(line)

	# Add coffee stain to first paper
	if paper_array.size() > 0:
		var stain = create_circle_polygon(Vector2(140, 180), 18)
		stain.color = Color(0.35, 0.25, 0.18, 0.25)  # Brown stain
		paper_array[0].add_child(stain)

func add_book_details():
	"""Add page edge detail and corner curl to open book"""
	# Left page edge (shows stacked pages)
	var pages_edge = ColorRect.new()
	pages_edge.color = Color(0.88, 0.83, 0.73, 1)  # Slightly darker than page
	pages_edge.size = Vector2(8, open_book.size.y - 30)
	pages_edge.position = Vector2(-8, 15)
	open_book.add_child(pages_edge)

	# Draw individual page lines on edge
	for i in range(20):
		var page_line = ColorRect.new()
		var y = 5 + i * (pages_edge.size.y / 20)
		page_line.size = Vector2(8, 1)
		page_line.position = Vector2(0, y)
		page_line.color = Color(0, 0, 0, 0.15)
		pages_edge.add_child(page_line)

	# Page curl at top-right corner (subtle)
	var curl = Polygon2D.new()
	var left_page = open_book.get_node("LeftPage")
	curl.polygon = PackedVector2Array([
		Vector2(left_page.size.x - 25, 0),
		Vector2(left_page.size.x, 0),
		Vector2(left_page.size.x, 25)
	])
	curl.color = Color(0.82, 0.77, 0.67, 1)  # Darker (shadow side of curl)
	left_page.add_child(curl)

func add_dust_particles():
	"""Add subtle dust motes floating in lamp light"""
	var dust = CPUParticles2D.new()
	dust.position = Vector2(400, 400)  # Near lamp area
	dust.amount = 25
	dust.lifetime = 5.0
	dust.preprocess = 3.0  # Start with some already floating
	dust.emitting = true

	# Emission area
	dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	dust.emission_sphere_radius = 300.0

	# Movement (slow float upward)
	dust.direction = Vector2(0, -1)
	dust.spread = 40
	dust.gravity = Vector2(0, -5)
	dust.initial_velocity_min = 5
	dust.initial_velocity_max = 15

	# Appearance (more visible)
	dust.color = Color(1, 1, 1, 0.25)
	dust.scale_amount_min = 2.0
	dust.scale_amount_max = 4.0

	add_child(dust)

func create_circle_polygon(center: Vector2, radius: float) -> Polygon2D:
	"""Helper to create circular polygon for stains"""
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()
	for i in range(16):
		var angle = (i / 16.0) * TAU
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	polygon.polygon = points
	return polygon

func setup_interactive_buttons():
	"""Connect navigation signals for interactive buttons (visual/hover logic is now in each button scene)"""
	# Feature 3A.1/3A.2: Old SceneManager navigation removed
	# Desk objects now emit object_clicked signals instead
	# Navigation will be handled by DiegeticScreenManager in Feature 3A.4

	# Old navigation (REMOVED):
	# diary_button.pressed.connect(SceneManager.goto_queue_screen)
	# dictionary_button.pressed.connect(SceneManager.goto_dictionary_screen)
	# papers_button.pressed.connect(SceneManager.goto_translation_screen)
	# magnifying_glass_button.pressed.connect(SceneManager.goto_examination_screen)
	# bell_button.pressed.connect(SceneManager.goto_work_screen)

func setup_archive_access_button():
	"""Add archive access button to open queue panel"""
	var archive_button = Button.new()
	archive_button.text = "📁 Archive"
	archive_button.custom_minimum_size = Vector2(100, 40)
	archive_button.size = Vector2(100, 40)
	archive_button.position = Vector2(20, 400)
	archive_button.tooltip_text = "Open Customer Archive"

	# Style the button
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.4, 0.35, 0.3)  # Dark brown
	button_style.border_width_left = 2
	button_style.border_width_top = 2
	button_style.border_width_right = 2
	button_style.border_width_bottom = 2
	button_style.border_color = Color(0.3, 0.25, 0.2)
	button_style.corner_radius_top_left = 4
	button_style.corner_radius_top_right = 4
	button_style.corner_radius_bottom_right = 4
	button_style.corner_radius_bottom_left = 4
	button_style.content_margin_left = 10
	button_style.content_margin_right = 10
	archive_button.add_theme_stylebox_override("normal", button_style)

	var hover_style = button_style.duplicate()
	hover_style.bg_color = Color(0.5, 0.45, 0.4)  # Lighter brown on hover
	archive_button.add_theme_stylebox_override("hover", hover_style)

	# Set text color
	archive_button.add_theme_color_override("font_color", Color(0.9, 0.85, 0.8))

	# Connect to open queue panel
	archive_button.pressed.connect(_on_archive_button_pressed)

	# Add to desk area
	$Desk.add_child(archive_button)
	archive_button.z_index = 10  # Above desk surface

func _on_archive_button_pressed():
	"""Handle archive button click - open queue panel"""
	print("Archive button pressed")

	if not is_focused_mode:
		enter_focus_mode()

	# Check if queue panel already open
	if active_panels.has("queue"):
		bring_panel_to_front("queue")
	else:
		open_panel("queue")

func _input(event):
	"""Handle ESC key for focus mode - Feature 3A.2"""
	if event is InputEventKey and event.pressed and not event.echo:
		# Feature 3A.2: ESC to exit focus mode
		if event.keycode == KEY_ESCAPE:
			if is_focused_mode:
				exit_focus_mode()
				get_viewport().set_input_as_handled()  # Don't propagate ESC
				return

func hide_shop():
	"""Hide shop UI when navigating to game screens"""
	visible = false

func show_shop():
	"""Show shop UI when returning from game screens"""
	visible = true
	update_top_bar()

func update_top_bar():
	"""Update day and money displays on the top bar"""
	if day_label:
		day_label.text = "Day %d - %s" % [GameState.current_day, get_day_name(GameState.current_day)]
	if cash_label:
		cash_label.text = "$%d" % GameState.player_cash

# Feature 3A.2: Shop Workspace Zones Implementation

func setup_camera():
	"""Initialize camera for perspective shifts"""
	camera = Camera2D.new()
	add_child(camera)

	camera.position = default_camera_position
	camera.zoom = default_zoom
	camera.enabled = true

func setup_background_dim():
	"""Create dimming overlay for bookshelves during focus mode"""
	background_dim = ColorRect.new()
	background_dim.size = Vector2(1920, 650)  # Cover bookshelf area
	background_dim.position = Vector2(0, 0)
	background_dim.color = Color(0, 0, 0, 0)  # Transparent initially
	background_dim.mouse_filter = Control.MOUSE_FILTER_STOP  # Blocks clicks when active
	background_dim.visible = false
	background_dim.z_index = 50  # Above bookshelves, below panels
	add_child(background_dim)

	# Connect click to exit focus mode
	background_dim.gui_input.connect(_on_background_clicked)

func connect_desk_objects():
	"""Connect desk object signals to focus mode - Feature 3A.1 integration"""
	diary_button.object_clicked.connect(_on_desk_object_clicked)
	papers_button.object_clicked.connect(_on_desk_object_clicked)
	dictionary_button.object_clicked.connect(_on_desk_object_clicked)
	magnifying_glass_button.object_clicked.connect(_on_desk_object_clicked)
	bell_button.object_clicked.connect(_on_desk_object_clicked)

func _on_desk_object_clicked(screen_type: String):
	"""Handle desk object click - open or focus panel (Feature 3A.3)"""
	if not is_focused_mode:
		enter_focus_mode()

	# Check if panel already open
	if active_panels.has(screen_type):
		bring_panel_to_front(screen_type)
	else:
		open_panel(screen_type)

func enter_focus_mode():
	"""Shift perspective to focus on desk workspace"""
	if is_focused_mode:
		return  # Already in focus mode

	is_focused_mode = true

	# Kill existing tween if any
	if focus_tween:
		focus_tween.kill()

	focus_tween = create_tween()
	focus_tween.set_parallel(true)
	focus_tween.set_ease(Tween.EASE_OUT)
	focus_tween.set_trans(Tween.TRANS_CUBIC)

	# Camera shift and zoom
	focus_tween.tween_property(camera, "position", focused_camera_position, 0.4)
	focus_tween.tween_property(camera, "zoom", focused_zoom, 0.4)

	# Dim and blur bookshelves
	background_dim.visible = true
	focus_tween.tween_property(background_dim, "color:a", 0.4, 0.4)  # 40% dark overlay

	# Dim bookshelf modulate (separate from overlay for blur effect)
	focus_tween.tween_property(left_bookshelf, "modulate:a", 0.6, 0.4)
	focus_tween.tween_property(left_bookshelf2, "modulate:a", 0.6, 0.4)
	focus_tween.tween_property(right_bookshelf, "modulate:a", 0.6, 0.4)
	focus_tween.tween_property(doorway, "modulate:a", 0.5, 0.4)

	# Brighten desk surface slightly
	var desk_surface = $Desk/DeskSurface
	focus_tween.tween_property(desk_surface, "modulate", Color(1.1, 1.1, 1.1), 0.4)

	# Dim hint label at bottom
	if hint_label:
		focus_tween.tween_property(hint_label, "modulate:a", 0.0, 0.4)

func exit_focus_mode():
	"""Return perspective to default shop view"""
	if not is_focused_mode:
		return  # Already in default mode

	is_focused_mode = false

	# Feature 3A.3: Close all panels when exiting focus mode
	close_all_panels()

	# Kill existing tween if any
	if focus_tween:
		focus_tween.kill()

	focus_tween = create_tween()
	focus_tween.set_parallel(true)
	focus_tween.set_ease(Tween.EASE_IN)
	focus_tween.set_trans(Tween.TRANS_CUBIC)

	# Camera return to default
	focus_tween.tween_property(camera, "position", default_camera_position, 0.4)
	focus_tween.tween_property(camera, "zoom", default_zoom, 0.4)

	# Remove dim overlay
	focus_tween.tween_property(background_dim, "color:a", 0.0, 0.4)

	# Restore bookshelf brightness
	focus_tween.tween_property(left_bookshelf, "modulate:a", 1.0, 0.4)
	focus_tween.tween_property(left_bookshelf2, "modulate:a", 1.0, 0.4)
	focus_tween.tween_property(right_bookshelf, "modulate:a", 1.0, 0.4)
	focus_tween.tween_property(doorway, "modulate:a", 1.0, 0.4)

	# Return desk to normal brightness
	var desk_surface = $Desk/DeskSurface
	focus_tween.tween_property(desk_surface, "modulate", Color(1, 1, 1), 0.4)

	# Restore hint label at bottom
	if hint_label:
		focus_tween.tween_property(hint_label, "modulate:a", 1.0, 0.4)

	# Hide background dim after animation
	await focus_tween.finished
	background_dim.visible = false

	# Clear all object glows (Feature 3A.1 integration)
	diary_button.set_panel_open(false)
	papers_button.set_panel_open(false)
	dictionary_button.set_panel_open(false)
	magnifying_glass_button.set_panel_open(false)
	bell_button.set_panel_open(false)

func _on_background_clicked(event: InputEvent):
	"""Handle click on dimmed background - exit focus mode"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		exit_focus_mode()

# Feature 3A.3: Panel Management Functions

func open_panel(panel_type: String):
	"""Create and slide in new panel"""
	if active_panels.size() >= MAX_PANELS:
		print("Maximum panels open (%d)" % MAX_PANELS)
		return

	# Create panel instance
	var panel_scene = load("res://scenes/ui/DiegeticPanel.tscn")
	var panel = panel_scene.instantiate()

	panel.panel_type = panel_type
	panel.panel_title = PANEL_TITLES[panel_type]
	panel.panel_color = PANEL_COLORS[panel_type]

	# Load layout config from LayoutManager
	panel.layout_config = LayoutManager.get_panel_layout(panel_type)
	panel.target_position = PANEL_ZONES[panel_type]

	# Update layout with config
	panel.update_layout()

	# Connect signals
	panel.panel_closed.connect(_on_panel_closed)
	panel.panel_focused.connect(bring_panel_to_front)

	# Add to scene
	add_child(panel)
	active_panels[panel_type] = panel
	panel_stack.append(panel_type)

	# Load screen content (Feature 3A.4)
	panel.load_content(panel_type)

	# Slide in animation
	panel.slide_in()
	panel.set_active(true)

	# Update desk object glows
	update_desk_object_glows()

func bring_panel_to_front(panel_type: String):
	"""Bring existing panel to front"""
	if not active_panels.has(panel_type):
		return

	# Remove from stack and re-add to top
	panel_stack.erase(panel_type)
	panel_stack.append(panel_type)

	# Update z-index for all panels
	for i in range(panel_stack.size()):
		var type = panel_stack[i]
		var panel = active_panels[type]
		panel.set_active(i == panel_stack.size() - 1)  # Last is active

	# Update desk object glows
	update_desk_object_glows()

func _on_panel_closed(panel_type: String):
	"""Handle panel close"""
	if not active_panels.has(panel_type):
		return

	var panel = active_panels[panel_type]

	# Slide out animation
	panel.slide_out()

	# Remove from tracking
	active_panels.erase(panel_type)
	panel_stack.erase(panel_type)

	# If no panels left, exit focus mode
	if active_panels.size() == 0:
		exit_focus_mode()
	else:
		# Bring next panel to front
		var next_type = panel_stack[panel_stack.size() - 1]
		bring_panel_to_front(next_type)

	# Update desk object glows
	update_desk_object_glows()

func update_desk_object_glows():
	"""Update desk object glows based on open panels"""
	# Clear all glows first
	diary_button.set_panel_open(false)
	papers_button.set_panel_open(false)
	dictionary_button.set_panel_open(false)
	magnifying_glass_button.set_panel_open(false)
	bell_button.set_panel_open(false)

	# Set glows for open panels
	for panel_type in active_panels.keys():
		match panel_type:
			"queue":
				diary_button.set_panel_open(true)
			"translation":
				papers_button.set_panel_open(true)
			"dictionary":
				dictionary_button.set_panel_open(true)
			"examination":
				magnifying_glass_button.set_panel_open(true)
			"work":
				bell_button.set_panel_open(true)

func close_all_panels():
	"""Close all open panels (called when exiting focus mode)"""
	# Create a copy of active panel types to avoid modification during iteration
	var panel_types_to_close = active_panels.keys().duplicate()

	for panel_type in panel_types_to_close:
		if active_panels.has(panel_type):
			var panel = active_panels[panel_type]
			panel.queue_free()  # Immediate cleanup without animation

	# Clear tracking
	active_panels.clear()
	panel_stack.clear()

	# Clear all glows
	update_desk_object_glows()

# Feature 3A.4: Customer Popup

func setup_customer_popup():
	"""Create and configure customer popup"""
	var popup_scene = load("res://scenes/ui/CustomerPopup.tscn")
	customer_popup = popup_scene.instantiate()
	add_child(customer_popup)
	customer_popup.z_index = 200  # Above everything

	# Connect popup signals
	customer_popup.customer_accepted.connect(_on_customer_accepted)
	customer_popup.customer_refused.connect(_on_customer_refused)

func show_customer_popup(customer_data: Dictionary):
	"""Show popup with customer details"""
	if customer_popup:
		customer_popup.show_popup(customer_data)

func _on_customer_accepted(customer_data: Dictionary):
	"""Handle customer acceptance from popup"""
	print("Customer accepted: %s" % customer_data.get("name", "Unknown"))
	GameState.accept_customer(customer_data)
	# Refresh the queue screen
	if active_panels.has("queue"):
		var queue_panel = active_panels["queue"]
		DiegeticScreenManager.refresh_screen("queue")

func _on_customer_refused(customer_data: Dictionary):
	"""Handle customer refusal from popup"""
	print("Customer refused: %s" % customer_data.get("name", "Unknown"))
	GameState.refuse_customer(customer_data)
	# Refresh the queue screen
	if active_panels.has("queue"):
		var queue_panel = active_panels["queue"]
		DiegeticScreenManager.refresh_screen("queue")

# Public API for DiegeticScreenManager (Feature 3A.4)

func get_panel_zone_rect(panel_type: String) -> Rect2:
	"""Returns the panel display zone for a specific panel type in global coordinates"""
	var pos = PANEL_ZONES[panel_type]
	return Rect2(pos.x, pos.y, PANEL_WIDTH, PANEL_HEIGHT)

func is_in_focus_mode() -> bool:
	"""Check if shop is currently in focused desk mode"""
	return is_focused_mode

func hide_panel_zone_markers():
	"""Hide panel zone markers at runtime (they're only for editor visualization)"""
	if has_node("PanelZones"):
		$PanelZones.visible = false

func sync_panel_zones_from_scene():
	"""Development helper: Print panel positions AND sizes from scene nodes
	   Call this from debugger or add a button in editor to sync positions"""
	if not has_node("PanelZones"):
		print("No PanelZones node found in scene")
		return

	print("\n=== SYNCED PANEL POSITIONS ===")
	print("Copy this into ShopScene.gd PANEL_ZONES constant:")
	print("const PANEL_ZONES = {")

	var zones_node = $PanelZones
	var zone_data = {
		"QueueZone": "queue",
		"TranslationZone": "translation",
		"DictionaryZone": "dictionary",
		"ExaminationZone": "examination",
		"WorkZone": "work"
	}

	# Track sizes for later output
	var zone_sizes = {}

	for zone_node_name in zone_data.keys():
		if zones_node.has_node(zone_node_name):
			var zone = zones_node.get_node(zone_node_name)
			var pos = zone.position
			var panel_type = zone_data[zone_node_name]
			print("\t\"%s\": Vector2(%d, %d)," % [panel_type, pos.x, pos.y])

			# Store size for this zone
			if zone is ColorRect:
				zone_sizes[panel_type] = zone.size

	print("}\n")

	# Print panel sizes
	print("=== SYNCED PANEL SIZES ===")
	print("If you resized zones, update these constants:")
	print("NOTE: Screen content will automatically resize to fit the new panel dimensions.\n")

	for panel_type in ["queue", "translation", "dictionary", "examination", "work"]:
		if zone_sizes.has(panel_type):
			var size = zone_sizes[panel_type]
			var width = int(size.x)
			var height = int(size.y)

			# Generate appropriate constant name
			match panel_type:
				"queue":
					print("const PANEL_WIDTH = %d" % width)
					print("const PANEL_HEIGHT = %d" % height)
				"translation":
					print("const TRANSLATION_PANEL_WIDTH = %d" % width)
					print("const TRANSLATION_PANEL_HEIGHT = %d" % height)
				"dictionary":
					print("const DICTIONARY_PANEL_WIDTH = %d" % width)
					print("const DICTIONARY_PANEL_HEIGHT = %d" % height)
				"examination":
					print("const EXAMINATION_PANEL_WIDTH = %d" % width)
					print("const EXAMINATION_PANEL_HEIGHT = %d" % height)
				"work":
					# Work uses default PANEL_WIDTH/HEIGHT, so skip
					pass
			print("")

	print("Positions and sizes synced from scene nodes!")
