# ShopScene.gd
# Main diegetic shop interface - atmospheric library/study aesthetic
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

func _ready():
	"""Initialize shop scene (only runs once now that scene persists)"""
	add_top_bar()
	setup_lighting()
	setup_wood_paneling()
	setup_bookshelves()
	add_shelf_dividers(left_bookshelf)
	add_shelf_dividers(left_bookshelf2)
	add_shelf_dividers(right_bookshelf)
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

	# Bottom hint label
	var hint_label = Label.new()
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
	# Connect pressed signals to navigation
	diary_button.pressed.connect(SceneManager.goto_queue_screen)
	dictionary_button.pressed.connect(SceneManager.goto_dictionary_screen)
	papers_button.pressed.connect(SceneManager.goto_translation_screen)
	magnifying_glass_button.pressed.connect(SceneManager.goto_examination_screen)
	bell_button.pressed.connect(SceneManager.goto_work_screen)

func _input(event):
	"""Handle input"""
	pass

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
