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

# Preload book scene
var book_scene = preload("res://scenes/ui/Book.tscn")

func _ready():
	"""Initialize shop scene"""
	setup_wood_paneling()
	setup_bookshelves()
	add_shelf_dividers(left_bookshelf)
	add_shelf_dividers(left_bookshelf2)
	add_shelf_dividers(right_bookshelf)
	generate_books(left_books_container, 70)
	generate_books(left_books_container2, 70)
	generate_books(right_books_container, 65)
	setup_papers_styling()
	setup_book_styling()

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

func add_shelf_dividers(bookshelf: Control):
	"""Add horizontal shelf dividers to show individual shelves"""
	var shelf_panel = bookshelf.get_node("ShelfPanel")
	var shelf_height = shelf_panel.size.y
	var shelves = 6
	var shelf_spacing = shelf_height / shelves

	for i in range(1, shelves):  # Don't add divider at top (0) or bottom (shelves)
		var divider = ColorRect.new()
		divider.size = Vector2(shelf_panel.size.x, 3)
		divider.position = Vector2(0, i * shelf_spacing)
		divider.color = Color(0.2, 0.13, 0.07, 1)  # Slightly darker than shelf
		shelf_panel.add_child(divider)

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

func _input(event):
	"""Handle input - press ESC to return to main scene"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/Main.tscn")
