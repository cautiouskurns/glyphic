# CustomerCard.gd
# Feature 3.1: Customer Queue Display
# Individual customer card with hover effects and click handling
extends PanelContainer

signal card_clicked(customer_data)

@onready var name_label = $MarginContainer/VBoxContainer/TopRow/NameLabel
@onready var payment_label = $MarginContainer/VBoxContainer/TopRow/PaymentLabel
@onready var difficulty_badge = $MarginContainer/VBoxContainer/DifficultyRow/DifficultyBadge
@onready var description_label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var status_label = $MarginContainer/VBoxContainer/StatusLabel
@onready var status_badge = $StatusBadge
@onready var warning_triangle = $WarningTriangle
@onready var broken_banner = $BrokenBanner

var customer_data: Dictionary = {}
var is_hovered: bool = false
var is_accepted: bool = false
var is_refused: bool = false
var is_capacity_full: bool = false  # Feature 3.4: Track capacity full state

# Default cream background
const COLOR_DEFAULT = Color("#F4E8D8")
# Gold tint for hover
const COLOR_HOVER = Color("#FFE4B3")
# Gold tint for hover (dimmed at capacity - Feature 3.4)
const COLOR_HOVER_DIMMED = Color("#FFE4B3")  # Will use with 30% opacity
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
	# Skip hover if accepted or refused
	if is_accepted or is_refused:
		return

	is_hovered = true
	var style = get_theme_stylebox("panel").duplicate()

	# Feature 3.4: Dimmed hover at capacity (30% opacity blend)
	if is_capacity_full:
		# Blend 30% gold with 70% default cream
		style.bg_color = COLOR_DEFAULT.lerp(COLOR_HOVER, 0.3)
		# Maintain red outline
		style.border_color = Color("#8B0000")
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
	else:
		style.bg_color = COLOR_HOVER

	add_theme_stylebox_override("panel", style)

func _on_mouse_exited():
	"""Remove hover effect"""
	# Skip if accepted or refused
	if is_accepted or is_refused:
		return

	is_hovered = false
	var style = get_theme_stylebox("panel").duplicate()
	style.bg_color = COLOR_DEFAULT

	# Feature 3.4: Restore red outline if at capacity
	if is_capacity_full:
		style.border_color = Color("#8B0000")
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2

	add_theme_stylebox_override("panel", style)

func _on_gui_input(event):
	"""Handle click (gold flash → emit signal)"""
	# Skip click if accepted or refused
	if is_accepted or is_refused:
		return

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

# Feature 3.3: Accept/Refuse Visual States
func set_accepted():
	"""Update card to show accepted state"""
	is_accepted = true
	is_hovered = false

	# Green background tint
	var style = get_theme_stylebox("panel").duplicate()
	style.bg_color = Color("#E8F5E0")  # Light green
	style.border_color = Color("#2D5016")  # Green border
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	add_theme_stylebox_override("panel", style)

	# Show status elements
	status_badge.text = "✓"
	status_badge.add_theme_color_override("font_color", Color("#FFFFFF"))
	status_badge.visible = true

	status_label.text = "ACCEPTED"
	status_label.add_theme_color_override("font_color", Color("#2D5016"))
	status_label.visible = true

func set_refused():
	"""Update card to show refused state"""
	is_refused = true
	is_hovered = false

	# Gray background
	var style = get_theme_stylebox("panel").duplicate()
	style.bg_color = Color("#CCCCCC")  # Gray
	add_theme_stylebox_override("panel", style)

	# Fade to 50% opacity
	modulate.a = 0.5

	# Show status elements
	status_badge.text = "✗"
	status_badge.add_theme_color_override("font_color", Color("#FFFFFF"))
	status_badge.visible = true

	status_label.text = "REFUSED"
	status_label.add_theme_color_override("font_color", Color("#8B0000"))
	status_label.visible = true

# Feature 3.4: Capacity Full Visual State
func set_capacity_full_state():
	"""Apply red outline when capacity is full"""
	is_capacity_full = true

	var style = get_theme_stylebox("panel").duplicate()
	style.bg_color = COLOR_DEFAULT
	style.border_color = Color("#8B0000")  # Red
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	add_theme_stylebox_override("panel", style)

	# Set 50% opacity on border
	modulate.a = 1.0  # Keep card at full opacity, just border is red

func clear_capacity_full_state():
	"""Remove red outline when capacity not full"""
	is_capacity_full = false

	var style = get_theme_stylebox("panel").duplicate()
	style.bg_color = COLOR_DEFAULT
	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 0
	add_theme_stylebox_override("panel", style)

# Feature 3.5: Relationship Warning States
func set_warning_state():
	"""Show warning triangle (relationship at 1, one more refusal breaks it)"""
	warning_triangle.visible = true

func set_relationship_broken_state():
	"""Show diagonal red banner (relationship at 0, customer won't return)"""
	broken_banner.visible = true
	# Optionally dim the card slightly
	modulate.a = 0.9
