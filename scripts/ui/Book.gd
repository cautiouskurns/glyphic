# Book.gd
# Individual book with proper styling, outlines, and shadows
extends PanelContainer

@onready var book_spine = $BookSpine
@onready var spine_text = $SpineText

# Possible text/symbols for book spines
var spine_symbols = ["∆", "◊", "○", "□", "▽", "◈", "⬡", "※", "✦", "★", "◉", "◎"]
var spine_letters = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "A", "B", "C", "D"]

# Store book appearance data
var book_color: Color
var book_spine_text: String = ""
var skip_randomization: bool = false

func _ready():
	"""Apply book styling with outline and shadow"""
	if not skip_randomization:
		randomize_appearance()

func randomize_appearance():
	"""Set random book appearance with warm brown tones"""
	# Varied book dimensions
	var book_width = randf_range(25, 55)
	var book_height = randf_range(80, 130)
	custom_minimum_size = Vector2(book_width, book_height)

	# Generate warm brown color
	var hue_base = 0.08 + randf_range(-0.02, 0.02)  # Around brown/orange
	var saturation = randf_range(0.4, 0.7)
	var value = randf_range(0.2, 0.45)
	book_color = Color.from_hsv(hue_base, saturation, value)

	# Create book style with outline and shadow
	var book_style = StyleBoxFlat.new()
	book_style.bg_color = book_color

	# Outline (border)
	book_style.border_width_left = 1
	book_style.border_width_top = 1
	book_style.border_width_right = 1
	book_style.border_width_bottom = 1
	# Darker border for contrast
	book_style.border_color = Color(book_color.r * 0.5, book_color.g * 0.5, book_color.b * 0.5, 1)

	# Shadow
	book_style.shadow_size = 3
	book_style.shadow_offset = Vector2(1, 2)
	book_style.shadow_color = Color(0, 0, 0, 0.4)

	# Small corner radius for slight roundedness
	book_style.corner_radius_top_left = 1
	book_style.corner_radius_top_right = 1
	book_style.corner_radius_bottom_right = 1
	book_style.corner_radius_bottom_left = 1

	add_theme_stylebox_override("panel", book_style)

	# Set spine color (slightly darker variant)
	book_spine.color = Color(book_color.r * 0.8, book_color.g * 0.8, book_color.b * 0.8, 1)

	# Add text/symbols to some books (30% chance)
	if randf() < 0.3:
		if randf() < 0.5:
			# Symbol
			book_spine_text = spine_symbols[randi() % spine_symbols.size()]
		else:
			# Letter/number
			book_spine_text = spine_letters[randi() % spine_letters.size()]

		spine_text.text = book_spine_text

		# Make text color slightly lighter than book for subtle contrast
		spine_text.add_theme_color_override("font_color", Color(
			book_color.r * 1.4,
			book_color.g * 1.4,
			book_color.b * 1.4,
			0.6
		))
	else:
		book_spine_text = ""
		spine_text.text = ""

	# Slight random tilt
	rotation = randf_range(-0.03, 0.03)

func set_color_override(color: Color):
	"""Manually set book color instead of random"""
	book_color = color

	var book_style = StyleBoxFlat.new()
	book_style.bg_color = color

	book_style.border_width_left = 1
	book_style.border_width_top = 1
	book_style.border_width_right = 1
	book_style.border_width_bottom = 1
	book_style.border_color = Color(color.r * 0.5, color.g * 0.5, color.b * 0.5, 1)

	book_style.shadow_size = 3
	book_style.shadow_offset = Vector2(1, 2)
	book_style.shadow_color = Color(0, 0, 0, 0.4)

	book_style.corner_radius_top_left = 1
	book_style.corner_radius_top_right = 1
	book_style.corner_radius_bottom_right = 1
	book_style.corner_radius_bottom_left = 1

	add_theme_stylebox_override("panel", book_style)
	book_spine.color = Color(color.r * 0.8, color.g * 0.8, color.b * 0.8, 1)

func get_book_data() -> Dictionary:
	"""Get all book appearance data for saving"""
	return {
		"color": book_color,
		"spine_text": book_spine_text,
		"size": custom_minimum_size,
		"rotation": rotation
	}

func restore_appearance(data: Dictionary):
	"""Restore book appearance from saved data"""
	skip_randomization = true

	# Set size first
	if data.has("size"):
		custom_minimum_size = data.size

	# Restore color
	if data.has("color"):
		set_color_override(data.color)

	# Restore spine text
	if data.has("spine_text"):
		book_spine_text = data.spine_text
		spine_text.text = book_spine_text

		# Set text color if there's text
		if book_spine_text != "":
			spine_text.add_theme_color_override("font_color", Color(
				book_color.r * 1.4,
				book_color.g * 1.4,
				book_color.b * 1.4,
				0.6
			))

	# Restore rotation
	if data.has("rotation"):
		rotation = data.rotation
