# TranslationDisplay.gd
# Feature 2.1: Translation Display System
# Shows symbol text, accepts player input, validates translations
extends Control

@onready var symbol_text_label = $SymbolTextDisplay/SymbolLabel
@onready var input_field = $InputField
@onready var submit_button = $SubmitButton

var current_text_id: int = 0  # 0 = no active text, 1-5 = Text ID
var is_validating: bool = false  # Prevents multiple submit clicks

func _ready():
	set_default_state()

func load_text(text_id: int):
	"""Load a translation text from SymbolData"""
	current_text_id = text_id
	var text_data = SymbolData.get_text(text_id)

	if text_data.is_empty():
		push_error("Invalid text_id: %d" % text_id)
		return

	# Display symbols
	symbol_text_label.text = text_data.symbols
	symbol_text_label.add_theme_color_override("font_color", Color("#2A1F1A"))

	# Enable input
	input_field.editable = true
	input_field.placeholder_text = "Type your translation here..."
	input_field.text = ""  # Clear previous input

	# Enable submit button
	submit_button.disabled = false

	# Fade in animation
	symbol_text_label.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(symbol_text_label, "modulate:a", 1.0, 0.3)

func set_default_state():
	"""Reset to 'no active text' state"""
	current_text_id = 0
	symbol_text_label.text = "*Select a customer to begin...*"
	symbol_text_label.add_theme_color_override("font_color", Color("#999999"))
	input_field.editable = false
	input_field.text = ""
	submit_button.disabled = true

func _on_submit_pressed():
	"""Handle Submit button click"""
	if is_validating or current_text_id == 0:
		return  # Prevent multiple clicks or submit with no text

	var player_input = input_field.text.strip_edges()

	if player_input.is_empty():
		# Flash red if trying to submit empty answer
		flash_input_field(Color("#CC0000"))
		return

	# Disable input during validation
	is_validating = true
	input_field.editable = false
	submit_button.disabled = true

	# Trigger validation (Feature 2.2)
	validate_translation(current_text_id, player_input)

func _on_text_submitted(text: String):
	"""Handle Enter key press in input field"""
	_on_submit_pressed()

func validate_translation(text_id: int, player_input: String):
	"""Call validation engine and handle result"""
	var is_correct = SymbolData.validate_translation(text_id, player_input)

	if is_correct:
		handle_success(text_id)
	else:
		handle_failure()

func handle_success(text_id: int):
	"""Success feedback - Feature 2.3 handles visual effects"""
	flash_input_field(Color("#2ECC71"))  # Green flash

	# Get payment amount
	var text_data = SymbolData.get_text(text_id)
	var payment = text_data.payment_base

	# Update game state
	GameState.add_cash(payment)
	SymbolData.update_dictionary(text_id)

	# Show success message (Feature 2.3)
	show_success_feedback(payment)

	# Re-enable input after 1 second
	await get_tree().create_timer(1.0).timeout
	reset_for_next_translation()

func handle_failure():
	"""Failure feedback - Feature 2.3 handles visual effects"""
	flash_input_field(Color("#E74C3C"))  # Red flash

	# Show failure message (Feature 2.3)
	show_failure_feedback()

	# Clear input and re-enable after 0.5 seconds
	await get_tree().create_timer(0.5).timeout
	input_field.text = ""
	input_field.editable = true
	submit_button.disabled = false
	is_validating = false
	input_field.grab_focus()  # Re-focus for next attempt

func reset_for_next_translation():
	"""Prepare for next translation"""
	is_validating = false
	set_default_state()

func flash_input_field(color: Color):
	"""Flash input field border with given color"""
	# Get current style
	var original_style = input_field.get_theme_stylebox("normal")

	# Create flash style
	var flash_style = StyleBoxFlat.new()
	flash_style.bg_color = Color(1, 1, 1, 1)  # White background
	flash_style.border_width_left = 4
	flash_style.border_width_top = 4
	flash_style.border_width_right = 4
	flash_style.border_width_bottom = 4
	flash_style.border_color = color
	flash_style.corner_radius_top_left = 6
	flash_style.corner_radius_top_right = 6
	flash_style.corner_radius_bottom_right = 6
	flash_style.corner_radius_bottom_left = 6
	flash_style.shadow_color = Color(color.r, color.g, color.b, 0.6)
	flash_style.shadow_size = 12

	# Apply flash style
	input_field.add_theme_stylebox_override("normal", flash_style)
	input_field.add_theme_stylebox_override("focus", flash_style)

	# Revert after 0.3 seconds
	await get_tree().create_timer(0.3).timeout
	input_field.remove_theme_stylebox_override("normal")
	input_field.remove_theme_stylebox_override("focus")

# Placeholder stubs for Feature 2.3
func show_success_feedback(payment: int):
	"""Show success message in dialogue box (Feature 2.3)"""
	# Placeholder: Just print for now
	print("SUCCESS! +$%d" % payment)

func show_failure_feedback():
	"""Show failure message in dialogue box (Feature 2.3)"""
	# Placeholder: Just print for now
	print("FAILURE! Try again.")
