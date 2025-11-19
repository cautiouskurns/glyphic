# CustomerCard.gd
# Feature 3.1: Customer Queue Display
# Individual customer card with cork board aesthetic and pin
extends PanelContainer

signal card_clicked(customer_data)

# Cork board card elements
@onready var pin = $Pin
@onready var pin_center = $Pin/PinCenter
@onready var name_label = $MarginContainer/VBoxContainer/NameLabel
@onready var difficulty_label = $MarginContainer/VBoxContainer/DifficultyRow/DifficultyBadge/HBox/DifficultyLabel
@onready var stars_label = $MarginContainer/VBoxContainer/DifficultyRow/DifficultyBadge/HBox/StarsLabel
@onready var time_label = $MarginContainer/VBoxContainer/MetaRow/TimeContainer/TimeLabel
@onready var payment_label = $MarginContainer/VBoxContainer/MetaRow/PaymentContainer/PaymentLabel
@onready var description_label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var signature_label = $MarginContainer/VBoxContainer/SignatureLabel
@onready var status_label = $MarginContainer/VBoxContainer/StatusLabel
@onready var status_badge = $StatusBadge
@onready var heart_icon = $HeartIcon
@onready var warning_triangle = $WarningTriangle
@onready var broken_banner = $BrokenBanner
@onready var priority_stamp = $PriorityStamp

var customer_data: Dictionary = {}
var is_hovered: bool = false
var is_accepted: bool = false
var is_refused: bool = false
var is_capacity_full: bool = false  # Feature 3.4: Track capacity full state

# Pin colors by difficulty
const PIN_COLORS = {
	"easy": Color(0.4, 0.7, 0.4, 1),      # Green
	"medium": Color(0.9, 0.7, 0.2, 1),    # Yellow
	"hard": Color(0.85, 0.3, 0.2, 1),     # Red
	"expert": Color(0.6, 0.3, 0.7, 1)     # Purple
}

# Default cream background
const COLOR_DEFAULT = Color("#F4E8D8")
# Gold tint for hover
const COLOR_HOVER = Color("#FFE4B3")
# Gold tint for hover (dimmed at capacity - Feature 3.4)
const COLOR_HOVER_DIMMED = Color("#FFE4B3")  # Will use with 30% opacity
# Brighter gold for click flash
const COLOR_CLICK = Color("#FFD700")

func _ready():
	"""Apply random rotation for organic cork board feel"""
	# CRITICAL FIX: Force Pin to use layout_mode 0 (absolute positioning) instead of 2 (fill)
	# This prevents the pin from filling the entire card when colored

	# Reset all anchors to 0 to force layout_mode 0
	pin.anchor_left = 0.0
	pin.anchor_top = 0.0
	pin.anchor_right = 0.0
	pin.anchor_bottom = 0.0

	# Set explicit position and size
	pin.position = Vector2(248, -8)
	pin.size = Vector2(24, 24)
	pin.custom_minimum_size = Vector2(24, 24)

	# Disable container size flags
	pin.size_flags_horizontal = 0
	pin.size_flags_vertical = 0

	# Also fix PinCenter - reset anchors
	pin_center.anchor_left = 0.0
	pin_center.anchor_top = 0.0
	pin_center.anchor_right = 0.0
	pin_center.anchor_bottom = 0.0
	pin_center.position = Vector2(6, 6)
	pin_center.size = Vector2(12, 12)
	pin_center.custom_minimum_size = Vector2(12, 12)

	# CRITICAL: Force white modulate to prevent color tinting
	modulate = Color.WHITE
	self_modulate = Color.WHITE

	# Force card background to cream - CRITICAL: prevents colored cards
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_DEFAULT
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 8
	style.shadow_offset = Vector2(3, 3)
	add_theme_stylebox_override("panel", style)

	# Ensure priority stamp, heart icon, and pin are hidden by default
	priority_stamp.visible = false
	heart_icon.visible = false
	pin.visible = false
	pin_center.visible = false

	# Apply rotation after layout (deferred to next frame)
	_apply_rotation.call_deferred()

func _apply_rotation():
	"""Apply random rotation after layout is calculated"""
	# Random rotation between -12 and +12 degrees for very visible tilt
	var rand_rotation = randf_range(-4.0, 4.0)

	# Set pivot to center for natural rotation
	pivot_offset = size / 2.0

	rotation_degrees = rand_rotation

func set_customer_data(data: Dictionary):
	"""Populate card with customer information"""
	customer_data = data

	# Set name with book title
	if data.has("name") and data.has("book_title"):
		name_label.text = "📖 %s - \"%s\"" % [data["name"], data["book_title"]]
	elif data.has("name"):
		name_label.text = data["name"]

	# Set payment
	if data.has("payment"):
		payment_label.text = "%d" % data["payment"]

	# Set difficulty (text + dots + pin color)
	if data.has("difficulty"):
		var difficulty_str = str(data["difficulty"]).to_lower()

		# Set difficulty label
		difficulty_label.text = difficulty_str.to_upper()

		# Set difficulty dots
		stars_label.text = get_difficulty_dots(difficulty_str)

		# Set pin color based on difficulty
		set_pin_color(difficulty_str)

	# Set time
	if data.has("time"):
		time_label.text = data["time"]
	else:
		time_label.text = "2:00 PM"  # Default

	# Set description
	if data.has("description"):
		description_label.text = data["description"]

	# Set signature (customer's handwritten note/signature)
	if data.has("signature"):
		signature_label.text = data["signature"]
	else:
		signature_label.text = ""

	# Show heart icon for recurring customers
	if data.has("is_recurring") and data["is_recurring"]:
		heart_icon.visible = true

	# Show priority stamp for priority customers
	if data.has("is_priority") and data["is_priority"]:
		priority_stamp.visible = true

	# CRITICAL: Force cream background AFTER all other setup to prevent any color bleeding
	modulate = Color.WHITE
	self_modulate = Color.WHITE
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_DEFAULT
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 8
	style.shadow_offset = Vector2(3, 3)
	add_theme_stylebox_override("panel", style)

func get_difficulty_dots(difficulty: String) -> String:
	"""Convert difficulty to dot display (●○)"""
	var dot_count = 0

	match difficulty.to_lower():
		"easy":
			dot_count = 2
		"medium":
			dot_count = 3
		"hard":
			dot_count = 4
		"expert":
			dot_count = 5
		_:
			dot_count = 3  # Default to medium

	# Generate dot display (filled ● and empty ○)
	var dots = ""
	for i in range(5):
		if i < dot_count:
			dots += "●"
		else:
			dots += "○"
	return dots

func set_pin_color(difficulty: String):
	"""Set pin color based on difficulty level"""
	var color = PIN_COLORS.get(difficulty.to_lower(), PIN_COLORS["medium"])

	# Create NEW pin style with color (don't duplicate the transparent default)
	var pin_style = StyleBoxFlat.new()
	pin_style.bg_color = color
	pin_style.corner_radius_top_left = 12
	pin_style.corner_radius_top_right = 12
	pin_style.corner_radius_bottom_right = 12
	pin_style.corner_radius_bottom_left = 12
	pin_style.shadow_color = Color(0, 0, 0, 0.4)
	pin_style.shadow_size = 3
	pin_style.shadow_offset = Vector2(1, 2)
	pin.add_theme_stylebox_override("panel", pin_style)

	# Create pin center style (slightly darker for depth)
	var center_style = StyleBoxFlat.new()
	center_style.bg_color = color.darkened(0.15)
	center_style.corner_radius_top_left = 12
	center_style.corner_radius_top_right = 12
	center_style.corner_radius_bottom_right = 12
	center_style.corner_radius_bottom_left = 12
	pin_center.add_theme_stylebox_override("panel", center_style)

	# Show the pin now that it has color
	pin.visible = true
	pin_center.visible = true

func get_difficulty_stars(difficulty) -> String:
	"""Legacy function - convert difficulty to star display (deprecated, use get_difficulty_dots)"""
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
	"""Show hover effect (subtle shadow increase)"""
	# Skip hover if accepted or refused
	if is_accepted or is_refused:
		return

	is_hovered = true
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_DEFAULT
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 12
	style.shadow_offset = Vector2(4, 4)

	# Feature 3.4: Red outline at capacity
	if is_capacity_full:
		style.border_color = Color("#8B0000")
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2

	add_theme_stylebox_override("panel", style)

func _on_mouse_exited():
	"""Remove hover effect"""
	# Skip if accepted or refused
	if is_accepted or is_refused:
		return

	is_hovered = false
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_DEFAULT
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 8
	style.shadow_offset = Vector2(3, 3)

	# Feature 3.4: Restore red outline if at capacity
	if is_capacity_full:
		style.border_color = Color("#8B0000")
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2

	add_theme_stylebox_override("panel", style)

func _on_gui_input(event):
	"""Handle click (subtle flash → emit signal)"""
	# Skip click if accepted or refused
	if is_accepted or is_refused:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Subtle scale pulse instead of color change
		var original_scale = scale
		var tween = create_tween()
		tween.tween_property(self, "scale", original_scale * 0.98, 0.05)
		tween.tween_property(self, "scale", original_scale, 0.1)

		# Emit signal for popup
		card_clicked.emit(customer_data)

# Feature 3.3: Accept/Refuse Visual States
func set_accepted():
	"""Update card to show accepted state"""
	is_accepted = true
	is_hovered = false

	# Keep cream background, just add checkmark
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_DEFAULT
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 8
	style.shadow_offset = Vector2(3, 3)
	add_theme_stylebox_override("panel", style)

	# Show status checkmark only
	status_badge.text = "✓"
	status_badge.add_theme_color_override("font_color", Color("#2D5016"))
	status_badge.visible = true

func set_refused():
	"""Update card to show refused state"""
	is_refused = true
	is_hovered = false

	# Keep cream background, just fade the card
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_DEFAULT
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 8
	style.shadow_offset = Vector2(3, 3)
	add_theme_stylebox_override("panel", style)

	# Fade to 50% opacity
	modulate.a = 0.5

	# Show X mark only
	status_badge.text = "✗"
	status_badge.add_theme_color_override("font_color", Color("#8B0000"))
	status_badge.visible = true

# Feature 3.4: Capacity Full Visual State
func set_capacity_full_state():
	"""Apply red outline when capacity is full"""
	is_capacity_full = true

	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_DEFAULT
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 8
	style.shadow_offset = Vector2(3, 3)
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

	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_DEFAULT
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 8
	style.shadow_offset = Vector2(3, 3)
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
