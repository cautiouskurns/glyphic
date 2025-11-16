# CustomerPopup.gd
# Feature 3.2: Customer Selection Popup
# Modal popup showing full customer details with ACCEPT/REFUSE choice
extends ColorRect

signal customer_accepted(customer_data)
signal customer_refused(customer_data)

@onready var popup_panel = $CustomerPopup
@onready var name_label = $CustomerPopup/MarginContainer/VBoxContainer/HeaderRow/NameLabel
@onready var payment_label = $CustomerPopup/MarginContainer/VBoxContainer/HeaderRow/PaymentLabel
@onready var difficulty_badge = $CustomerPopup/MarginContainer/VBoxContainer/HeaderRow/DifficultyBadge/DifficultyLabel
@onready var dialogue_label = $CustomerPopup/MarginContainer/VBoxContainer/DialogueLabel
@onready var translation_label = $CustomerPopup/MarginContainer/VBoxContainer/TranslationLabel
@onready var difficulty_info_label = $CustomerPopup/MarginContainer/VBoxContainer/DifficultyInfoLabel
@onready var checkmark1 = $CustomerPopup/MarginContainer/VBoxContainer/PrioritiesList/Priority1/Checkmark1
@onready var priority_text1 = $CustomerPopup/MarginContainer/VBoxContainer/PrioritiesList/Priority1/PriorityText1
@onready var checkmark2 = $CustomerPopup/MarginContainer/VBoxContainer/PrioritiesList/Priority2/Checkmark2
@onready var priority_text2 = $CustomerPopup/MarginContainer/VBoxContainer/PrioritiesList/Priority2/PriorityText2
@onready var checkmark3 = $CustomerPopup/MarginContainer/VBoxContainer/PrioritiesList/Priority3/Checkmark3
@onready var priority_text3 = $CustomerPopup/MarginContainer/VBoxContainer/PrioritiesList/Priority3/PriorityText3
@onready var accept_button = $CustomerPopup/MarginContainer/VBoxContainer/ButtonRow/AcceptButton
@onready var refuse_button = $CustomerPopup/MarginContainer/VBoxContainer/ButtonRow/RefuseButton

var current_customer: Dictionary = {}
var is_animating: bool = false

# Colors
const COLOR_GREEN = Color("#2D5016")
const COLOR_GREEN_HOVER = Color("#3FB023")
const COLOR_RED = Color("#8B0000")
const COLOR_RED_HOVER = Color("#B30000")
const COLOR_GRAY = Color("#888888")
const COLOR_WHITE = Color("#FFFFFF")
const COLOR_CHECKMARK_YES = Color("#2D5016")
const COLOR_CHECKMARK_NO = Color("#8B0000")

# Priority descriptions
const PRIORITY_DESCRIPTIONS = {
	"Fast": "Rush job required",
	"Cheap": "Budget-conscious customer",
	"Accurate": "Perfection expected"
}

# All possible priorities (in display order)
const ALL_PRIORITIES = ["Fast", "Cheap", "Accurate"]

func _ready():
	# Set up button styles
	setup_button_styles()
	# Hide initially
	visible = false

func setup_button_styles():
	"""Configure button visual styles"""
	# Accept button (green)
	var accept_normal = StyleBoxFlat.new()
	accept_normal.bg_color = COLOR_GREEN
	accept_normal.border_width_left = 2
	accept_normal.border_width_top = 2
	accept_normal.border_width_right = 2
	accept_normal.border_width_bottom = 2
	accept_normal.border_color = Color("#1A3009")
	accept_normal.corner_radius_top_left = 6
	accept_normal.corner_radius_top_right = 6
	accept_normal.corner_radius_bottom_right = 6
	accept_normal.corner_radius_bottom_left = 6

	var accept_hover = accept_normal.duplicate()
	accept_hover.bg_color = COLOR_GREEN_HOVER

	var accept_pressed = accept_normal.duplicate()
	accept_pressed.bg_color = COLOR_GREEN.darkened(0.2)

	var accept_disabled = accept_normal.duplicate()
	accept_disabled.bg_color = COLOR_GRAY

	accept_button.add_theme_stylebox_override("normal", accept_normal)
	accept_button.add_theme_stylebox_override("hover", accept_hover)
	accept_button.add_theme_stylebox_override("pressed", accept_pressed)
	accept_button.add_theme_stylebox_override("disabled", accept_disabled)

	# Refuse button (red)
	var refuse_normal = StyleBoxFlat.new()
	refuse_normal.bg_color = COLOR_RED
	refuse_normal.border_width_left = 2
	refuse_normal.border_width_top = 2
	refuse_normal.border_width_right = 2
	refuse_normal.border_width_bottom = 2
	refuse_normal.border_color = Color("#5A0000")
	refuse_normal.corner_radius_top_left = 6
	refuse_normal.corner_radius_top_right = 6
	refuse_normal.corner_radius_bottom_right = 6
	refuse_normal.corner_radius_bottom_left = 6

	var refuse_hover = refuse_normal.duplicate()
	refuse_hover.bg_color = COLOR_RED_HOVER

	var refuse_pressed = refuse_normal.duplicate()
	refuse_pressed.bg_color = COLOR_RED.darkened(0.2)

	refuse_button.add_theme_stylebox_override("normal", refuse_normal)
	refuse_button.add_theme_stylebox_override("hover", refuse_hover)
	refuse_button.add_theme_stylebox_override("pressed", refuse_pressed)

func show_popup(customer_data: Dictionary):
	"""Display popup with customer information"""
	if is_animating:
		return

	current_customer = customer_data
	populate_customer_info()
	check_capacity()

	# Show and animate in
	visible = true
	animate_open()

func hide_popup():
	"""Close popup with animation"""
	if is_animating:
		return

	animate_close()

func populate_customer_info():
	"""Fill in all customer details"""
	# Header
	name_label.text = current_customer.get("name", "Unknown Customer")
	payment_label.text = "$%d" % current_customer.get("payment", 0)

	# Difficulty badge
	var difficulty = current_customer.get("difficulty", "Medium")
	difficulty_badge.text = get_difficulty_stars(difficulty)

	# Dialogue quote
	var dialogue = current_customer.get("dialogue", {})
	var greeting = dialogue.get("greeting", "...")
	dialogue_label.text = "\"%s\"" % greeting

	# Translation info
	translation_label.text = "Translation: %s" % get_translation_text_name(difficulty)
	difficulty_info_label.text = "Difficulty: %s" % get_difficulty_info(difficulty)

	# Priorities
	update_priorities_display()

func update_priorities_display():
	"""Show checkmarks for customer priorities"""
	var customer_priorities = current_customer.get("priorities", [])

	# Priority 1: Fast
	var has_fast = "Fast" in customer_priorities
	checkmark1.text = "✓" if has_fast else "✗"
	checkmark1.add_theme_color_override("font_color", COLOR_CHECKMARK_YES if has_fast else COLOR_CHECKMARK_NO)
	priority_text1.text = "Fast (%s)" % PRIORITY_DESCRIPTIONS["Fast"]

	# Priority 2: Cheap
	var has_cheap = "Cheap" in customer_priorities
	checkmark2.text = "✓" if has_cheap else "✗"
	checkmark2.add_theme_color_override("font_color", COLOR_CHECKMARK_YES if has_cheap else COLOR_CHECKMARK_NO)
	priority_text2.text = "Cheap (%s)" % PRIORITY_DESCRIPTIONS["Cheap"]

	# Priority 3: Accurate
	var has_accurate = "Accurate" in customer_priorities
	checkmark3.text = "✓" if has_accurate else "✗"
	checkmark3.add_theme_color_override("font_color", COLOR_CHECKMARK_YES if has_accurate else COLOR_CHECKMARK_NO)
	priority_text3.text = "Accurate (%s)" % PRIORITY_DESCRIPTIONS["Accurate"]

func check_capacity():
	"""Enable/disable ACCEPT button based on shop capacity"""
	var capacity_full = GameState.capacity_used >= GameState.max_capacity
	accept_button.disabled = capacity_full

	if capacity_full:
		accept_button.tooltip_text = "Shop is full (%d/%d)" % [GameState.capacity_used, GameState.max_capacity]
	else:
		accept_button.tooltip_text = ""

func get_difficulty_stars(difficulty: String) -> String:
	"""Convert difficulty to star display"""
	var star_count = 0
	match difficulty.to_lower():
		"easy":
			star_count = 2
		"medium":
			star_count = 3
		"hard":
			star_count = 4
		_:
			star_count = 3

	var stars = ""
	for i in range(5):
		if i < star_count:
			stars += "★"
		else:
			stars += "☆"
	return stars

func get_difficulty_info(difficulty: String) -> String:
	"""Get difficulty description"""
	match difficulty.to_lower():
		"easy":
			return "Simple translation (~15 words)"
		"medium":
			return "Moderate translation (~25 words)"
		"hard":
			return "Complex translation (~50 words)"
		_:
			return "Moderate translation"

func get_translation_text_name(difficulty: String) -> String:
	"""Get translation text name based on difficulty"""
	match difficulty.to_lower():
		"easy":
			return "Text 1 - The Old Way"
		"medium":
			return "Text 2-3 - Ancient Mysteries"
		"hard":
			return "Text 4-5 - Deep Knowledge"
		_:
			return "Unknown Text"

func animate_open():
	"""Scale-in animation for popup open"""
	is_animating = true

	# Start states
	modulate.a = 0.0
	popup_panel.scale = Vector2(0.8, 0.8)

	# Animate overlay fade-in
	var overlay_tween = create_tween()
	overlay_tween.tween_property(self, "modulate:a", 1.0, 0.2)

	# Animate popup scale-in
	var popup_tween = create_tween()
	popup_tween.set_trans(Tween.TRANS_BACK)
	popup_tween.set_ease(Tween.EASE_OUT)
	popup_tween.tween_property(popup_panel, "scale", Vector2(1.0, 1.0), 0.2)

	await popup_tween.finished
	is_animating = false

func animate_close():
	"""Scale-out animation for popup close"""
	is_animating = true

	# Animate popup scale-out
	var popup_tween = create_tween()
	popup_tween.set_trans(Tween.TRANS_BACK)
	popup_tween.set_ease(Tween.EASE_IN)
	popup_tween.tween_property(popup_panel, "scale", Vector2(0.8, 0.8), 0.15)

	# Animate overlay fade-out
	var overlay_tween = create_tween()
	overlay_tween.tween_property(self, "modulate:a", 0.0, 0.15)

	await popup_tween.finished
	visible = false
	is_animating = false

func flash_button(button: Button):
	"""Flash button white briefly"""
	var original_color = button.modulate

	# Flash to white
	var flash_in = create_tween()
	flash_in.tween_property(button, "modulate", COLOR_WHITE, 0.1)
	await flash_in.finished

	# Flash back
	var flash_out = create_tween()
	flash_out.tween_property(button, "modulate", original_color, 0.1)
	await flash_out.finished

func _input(event):
	"""Handle keyboard shortcuts"""
	if not visible or is_animating:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER and not accept_button.disabled:
			_on_accept_pressed()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE:
			hide_popup()
			get_viewport().set_input_as_handled()

func _on_accept_pressed():
	"""Handle ACCEPT button click"""
	flash_button(accept_button)
	await flash_button

	customer_accepted.emit(current_customer)
	hide_popup()

func _on_refuse_pressed():
	"""Handle REFUSE button click"""
	flash_button(refuse_button)
	await flash_button

	customer_refused.emit(current_customer)
	hide_popup()

func _on_overlay_gui_input(event):
	"""Close popup if overlay clicked"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_popup()
