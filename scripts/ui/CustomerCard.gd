# CustomerCard.gd
# Feature 3.1: Customer Queue Display
# Individual customer card with hover effects and click handling
extends PanelContainer

signal card_clicked(customer_data)

@onready var name_label = $MarginContainer/VBoxContainer/TopRow/NameLabel
@onready var payment_label = $MarginContainer/VBoxContainer/TopRow/PaymentLabel
@onready var difficulty_badge = $MarginContainer/VBoxContainer/DifficultyRow/DifficultyBadge
@onready var description_label = $MarginContainer/VBoxContainer/DescriptionLabel

var customer_data: Dictionary = {}
var is_hovered: bool = false

# Default cream background
const COLOR_DEFAULT = Color("#F4E8D8")
# Gold tint for hover
const COLOR_HOVER = Color("#FFE4B3")
# Brighter gold for click flash
const COLOR_CLICK = Color("#FFD700")

func set_customer_data(data: Dictionary):
	"""Populate card with customer information"""
	customer_data = data

	# Set name
	if data.has("name"):
		name_label.text = data["name"]

	# Set payment
	if data.has("payment"):
		payment_label.text = "$%d" % data["payment"]

	# Set difficulty badge (convert number to stars)
	if data.has("difficulty"):
		difficulty_badge.text = get_difficulty_stars(data["difficulty"])

	# Set description
	if data.has("description"):
		description_label.text = data["description"]

func get_difficulty_stars(difficulty) -> String:
	"""Convert difficulty to star display (accepts string or int)"""
	var star_count = 0

	# Handle both string and int difficulty
	if difficulty is String:
		match difficulty.to_lower():
			"easy":
				star_count = 2
			"medium":
				star_count = 3
			"hard":
				star_count = 4
			_:
				star_count = 3  # Default to medium
	else:
		star_count = int(difficulty)

	# Generate star display
	var stars = ""
	for i in range(5):
		if i < star_count:
			stars += "★"
		else:
			stars += "☆"
	return stars

func _on_mouse_entered():
	"""Show hover effect (gold tint)"""
	is_hovered = true
	var style = get_theme_stylebox("panel").duplicate()
	style.bg_color = COLOR_HOVER
	add_theme_stylebox_override("panel", style)

func _on_mouse_exited():
	"""Remove hover effect"""
	is_hovered = false
	var style = get_theme_stylebox("panel").duplicate()
	style.bg_color = COLOR_DEFAULT
	add_theme_stylebox_override("panel", style)

func _on_gui_input(event):
	"""Handle click (gold flash → emit signal)"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Flash gold
		var style = get_theme_stylebox("panel").duplicate()
		style.bg_color = COLOR_CLICK
		add_theme_stylebox_override("panel", style)

		# Emit signal for popup
		card_clicked.emit(customer_data)

		# Return to hover/default after brief delay
		await get_tree().create_timer(0.15).timeout
		if is_hovered:
			style.bg_color = COLOR_HOVER
		else:
			style.bg_color = COLOR_DEFAULT
		add_theme_stylebox_override("panel", style)
