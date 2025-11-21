# BookPile.gd
# Visual backlog of accepted books on the left side of the desk
# Books are added when customer accepted, removed when translation completed
extends Control

signal book_clicked(customer_data)

@onready var book_container = $VBoxContainer

var books: Array[Dictionary] = []

# Colors
const COLOR_BOOK_BG = Color("#F4E8D8")  # Cream parchment
const COLOR_BOOK_BORDER = Color("#3A2518")  # Dark brown
const COLOR_BOOK_HOVER = Color("#FFD700")  # Gold highlight
const COLOR_TEXT = Color("#3A2518")  # Dark brown text

func _ready():
	# Start invisible - will show when first book added
	visible = false

func add_book(customer_data: Dictionary):
	"""Add a book to the pile"""
	if customer_data.is_empty():
		push_warning("BookPile: Cannot add empty customer data")
		return

	# Add to internal array
	books.append(customer_data)

	# Create visual book card
	create_book_card(customer_data)

	# Show pile if this is first book
	if not visible:
		visible = true
		# Fade in animation
		modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.3)

func remove_book(customer_data: Dictionary):
	"""Remove a book from the pile"""
	# Find and remove from array
	var index = -1
	for i in range(books.size()):
		if books[i].get("name") == customer_data.get("name"):
			index = i
			break

	if index >= 0:
		books.remove_at(index)

		# Remove visual card
		if index < book_container.get_child_count():
			var card = book_container.get_child(index)
			card.queue_free()

	# Hide pile if empty
	if books.is_empty() and visible:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		await tween.finished
		visible = false

func create_book_card(customer_data: Dictionary):
	"""Create a clickable book card"""
	var card = PanelContainer.new()

	# Style the card
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = customer_data.get("book_cover_color", COLOR_BOOK_BG)
	style_normal.border_width_left = 2
	style_normal.border_width_top = 2
	style_normal.border_width_right = 2
	style_normal.border_width_bottom = 2
	style_normal.border_color = COLOR_BOOK_BORDER
	style_normal.corner_radius_top_left = 4
	style_normal.corner_radius_top_right = 4
	style_normal.corner_radius_bottom_right = 4
	style_normal.corner_radius_bottom_left = 4

	card.add_theme_stylebox_override("panel", style_normal)
	card.custom_minimum_size = Vector2(180, 60)

	# Create button inside card
	var button = Button.new()
	button.text = customer_data.get("name", "Unknown Customer")
	button.flat = true
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_font_size_override("font_size", 14)

	# Connect click
	button.pressed.connect(_on_book_card_clicked.bind(customer_data))

	# Add hover effect
	button.mouse_entered.connect(func():
		var hover_style = style_normal.duplicate()
		hover_style.border_color = COLOR_BOOK_HOVER
		hover_style.border_width_left = 3
		hover_style.border_width_top = 3
		hover_style.border_width_right = 3
		hover_style.border_width_bottom = 3
		card.add_theme_stylebox_override("panel", hover_style)
	)

	button.mouse_exited.connect(func():
		card.add_theme_stylebox_override("panel", style_normal)
	)

	card.add_child(button)
	book_container.add_child(card)

func _on_book_card_clicked(customer_data: Dictionary):
	"""Handle book card click"""
	print("BookPile: Book clicked - %s" % customer_data.get("name", "Unknown"))
	book_clicked.emit(customer_data)

func get_book_count() -> int:
	"""Return number of books in pile"""
	return books.size()
