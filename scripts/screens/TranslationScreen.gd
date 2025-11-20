# TranslationScreen.gd
# Feature 3A.4: Translation Workspace - panel-compatible
extends Control

# Panel mode flag
var panel_mode: bool = false
var is_notebook_mode: bool = false  # Horizontal notebook layout (wide + short)

# UI References (will be reassigned if notebook mode)
@onready var subtitle_label = $MarginContainer/VBoxContainer/SubtitleLabel
@onready var glyph_paper = $MarginContainer/VBoxContainer/GlyphPaper
@onready var glyph_container = $MarginContainer/VBoxContainer/GlyphPaper/GlyphContainer
@onready var translation_paper = $MarginContainer/VBoxContainer/TranslationPaper
@onready var input_field = $MarginContainer/VBoxContainer/TranslationPaper/TranslationContent/InputField
@onready var hint_button = $MarginContainer/VBoxContainer/ButtonRow/HintButton
@onready var submit_button = $MarginContainer/VBoxContainer/ButtonRow/SubmitButton
@onready var pagination_container = $MarginContainer/VBoxContainer/Footer/Pagination
@onready var difficulty_badge = $MarginContainer/VBoxContainer/Footer/DifficultyBadge

# Additional UI for notebook mode
var scratch_notes: TextEdit  # Right side notes area

# Translation state
var current_text_id: int = 0
var current_text_data: Dictionary = {}
var is_validating: bool = false
var hint_shown: bool = false

# Signals
signal translation_completed(success: bool, payment: int)

func _ready():
	"""Initialize translation screen"""
	# Detect notebook mode (wide horizontal layout)
	await get_tree().process_frame
	var panel_width = size.x if size.x > 0 else custom_minimum_size.x
	var panel_height = size.y if size.y > 0 else custom_minimum_size.y
	is_notebook_mode = panel_width > 1000 and panel_height < 300

	if is_notebook_mode:
		setup_notebook_layout()
	elif panel_mode:
		setup_panel_layout()

	# Style the paper panels
	style_paper_panels()

	# Wait for layout before initializing
	await get_tree().process_frame
	await get_tree().process_frame
	initialize()

func setup_panel_layout():
	"""Configure for panel display (500px panel = 460px content area)"""
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(460, 590)

func setup_notebook_layout():
	"""Configure horizontal notebook layout (1300×180 - wide and short)"""
	# Get the existing VBoxContainer
	var margin_container = $MarginContainer
	var vbox = $MarginContainer/VBoxContainer

	# Create new HBoxContainer for horizontal layout
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Left side (60%) - translation work area
	var left_side = VBoxContainer.new()
	left_side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_side.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_side.size_flags_stretch_ratio = 0.6

	# Right side (40%) - scratch notes
	var right_side = VBoxContainer.new()
	right_side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_side.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_side.size_flags_stretch_ratio = 0.4

	# Move existing content to left side (compact vertical layout)
	# Create compact top row: subtitle + difficulty badge
	var top_row = HBoxContainer.new()
	subtitle_label.reparent(top_row)
	subtitle_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	difficulty_badge.reparent(top_row)
	left_side.add_child(top_row)

	# Glyphs (make horizontal and compact)
	glyph_paper.reparent(left_side)
	glyph_container.custom_minimum_size = Vector2(0, 60)  # Compact height

	# Translation input area
	translation_paper.reparent(left_side)

	# Button row stays with left side
	var button_row = $MarginContainer/VBoxContainer/ButtonRow
	button_row.reparent(left_side)

	# Create scratch notes area for right side
	var notes_label = Label.new()
	notes_label.text = "Scratch Notes"
	notes_label.add_theme_font_size_override("font_size", 12)
	notes_label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4))
	right_side.add_child(notes_label)

	scratch_notes = TextEdit.new()
	scratch_notes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scratch_notes.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scratch_notes.placeholder_text = "Use this space for notes, partial translations, patterns..."
	scratch_notes.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY

	# Style scratch notes
	var notes_style = StyleBoxFlat.new()
	notes_style.bg_color = Color(0.98, 0.96, 0.94)  # Slightly different paper color
	notes_style.border_width_left = 2
	notes_style.border_width_top = 2
	notes_style.border_width_right = 2
	notes_style.border_width_bottom = 2
	notes_style.border_color = Color(0.3, 0.25, 0.2)
	notes_style.content_margin_left = 10
	notes_style.content_margin_top = 10
	notes_style.content_margin_right = 10
	notes_style.content_margin_bottom = 10
	scratch_notes.add_theme_stylebox_override("normal", notes_style)
	scratch_notes.add_theme_stylebox_override("focus", notes_style)

	right_side.add_child(scratch_notes)

	# Assemble horizontal layout
	hbox.add_child(left_side)
	hbox.add_child(right_side)

	# Replace VBoxContainer with HBoxContainer
	vbox.queue_free()
	margin_container.add_child(hbox)

func style_paper_panels():
	"""Style glyph and translation paper panels"""
	# Glyph paper (cream/beige)
	var glyph_style = StyleBoxFlat.new()
	glyph_style.bg_color = Color(0.956, 0.909, 0.847)  # #F4E8D8
	glyph_style.border_width_left = 2
	glyph_style.border_width_top = 2
	glyph_style.border_width_right = 2
	glyph_style.border_width_bottom = 2
	glyph_style.border_color = Color(0.3, 0.25, 0.2)
	glyph_style.corner_radius_top_left = 4
	glyph_style.corner_radius_top_right = 4
	glyph_style.corner_radius_bottom_right = 4
	glyph_style.corner_radius_bottom_left = 4
	glyph_style.content_margin_left = 15
	glyph_style.content_margin_top = 15
	glyph_style.content_margin_right = 15
	glyph_style.content_margin_bottom = 15
	glyph_paper.add_theme_stylebox_override("panel", glyph_style)

	# Translation paper (same style)
	var trans_style = glyph_style.duplicate()
	translation_paper.add_theme_stylebox_override("panel", trans_style)

func initialize():
	"""Called when panel opens - load translation from current book on desk"""
	# Check if there's a book on desk to translate
	if GameState.current_book.is_empty():
		show_no_customer_message()
		return

	# Get the current book being worked on
	var customer = GameState.current_book
	var difficulty = customer.get("difficulty", "easy")
	var customer_name = customer.get("name", "Unknown")

	# Get text ID (already assigned when book was accepted)
	current_text_id = customer.get("text_id", GameState.get_text_id_for_difficulty(difficulty))
	current_text_data = SymbolData.get_text(current_text_id)

	if current_text_data.is_empty():
		push_error("Failed to load text ID: %d" % current_text_id)
		return

	# Update UI
	subtitle_label.text = "Translating for %s" % customer_name
	difficulty_badge.text = "%s DIFFICULTY" % difficulty.to_upper()

	# Display glyphs
	display_glyphs()

	# Setup pagination
	setup_pagination()

	# Enable input
	input_field.editable = true
	input_field.grab_focus()

func show_no_customer_message():
	"""Display message when no customer is active"""
	subtitle_label.text = "No active customer"
	input_field.placeholder_text = "Accept a customer first..."
	input_field.editable = false
	submit_button.disabled = true
	hint_button.disabled = true

func display_glyphs():
	"""Create glyph boxes for each symbol in the text"""
	# Clear existing glyphs
	for child in glyph_container.get_children():
		child.queue_free()

	# Split symbols by spaces to get individual symbol groups
	var symbol_groups = current_text_data.symbols.split(" ", false)

	for i in range(symbol_groups.size()):
		var symbol = symbol_groups[i]
		create_glyph_box(symbol, i + 1)

func create_glyph_box(symbol: String, number: int):
	"""Create an individual glyph display box"""
	var box = VBoxContainer.new()
	box.custom_minimum_size = Vector2(50, 70)

	# Glyph box background
	var panel = PanelContainer.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(1, 1, 1)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.3, 0.25, 0.2)
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.content_margin_left = 8
	panel_style.content_margin_top = 8
	panel_style.content_margin_right = 8
	panel_style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", panel_style)
	panel.custom_minimum_size = Vector2(50, 50)

	# Symbol label
	var symbol_label = Label.new()
	symbol_label.text = symbol
	symbol_label.add_theme_font_size_override("font_size", 24)
	symbol_label.add_theme_color_override("font_color", Color(0.164706, 0.121569, 0.101961))
	symbol_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	symbol_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	symbol_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	symbol_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(symbol_label)

	box.add_child(panel)

	# Number label below box
	var number_label = Label.new()
	number_label.text = str(number)
	number_label.add_theme_font_size_override("font_size", 10)
	number_label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4))
	number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(number_label)

	glyph_container.add_child(box)

func setup_pagination():
	"""Create pagination dots (1-5) showing current text"""
	# Clear existing dots
	for child in pagination_container.get_children():
		child.queue_free()

	# Create dots for texts 1-5
	for i in range(1, 6):
		var dot = Label.new()
		dot.text = str(i)
		dot.add_theme_font_size_override("font_size", 12)
		dot.custom_minimum_size = Vector2(24, 24)
		dot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		# Highlight current text
		if i == current_text_id:
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.7, 0.65, 0.6)
			style.corner_radius_top_left = 12
			style.corner_radius_top_right = 12
			style.corner_radius_bottom_right = 12
			style.corner_radius_bottom_left = 12
			dot.add_theme_stylebox_override("normal", style)
			dot.add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			dot.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4))

		pagination_container.add_child(dot)

func _on_input_submitted(text: String):
	"""Handle Enter key press"""
	_on_submit_pressed()

func _on_submit_pressed():
	"""Handle Submit button click"""
	if is_validating or current_text_id == 0:
		return

	var player_input = input_field.text.strip_edges()

	if player_input.is_empty():
		flash_input_field(Color(0.8, 0.2, 0.2))  # Red flash
		return

	# Disable input during validation
	is_validating = true
	input_field.editable = false
	submit_button.disabled = true
	hint_button.disabled = true

	# Validate translation
	var is_correct = SymbolData.validate_translation(current_text_id, player_input)

	if is_correct:
		handle_success()
	else:
		handle_failure()

func handle_success():
	"""Success feedback and rewards"""
	flash_input_field(Color(0.176, 0.501, 0.086))  # Green flash

	var payment = current_text_data.payment_base

	# Update game state
	GameState.add_cash(payment)
	SymbolData.update_dictionary(current_text_id)

	# Remove book from desk and customer from accepted queue
	var customer_name = GameState.current_book.get("name", "")
	GameState.current_book = {}  # Clear book from desk

	# Remove from accepted customers list
	for i in range(GameState.accepted_customers.size()):
		if GameState.accepted_customers[i].get("name", "") == customer_name:
			GameState.accepted_customers.remove_at(i)
			break

	# Emit success signal
	translation_completed.emit(true, payment)

	# Show success message briefly
	input_field.text = "✓ Correct! +$%d" % payment
	input_field.add_theme_color_override("font_color", Color(0.176, 0.501, 0.086))

	# Wait then reset or load next customer
	await get_tree().create_timer(2.0).timeout
	reset_for_next_translation()

func handle_failure():
	"""Failure feedback"""
	flash_input_field(Color(0.8, 0.2, 0.2))  # Red flash

	# Clear input after brief delay
	await get_tree().create_timer(0.5).timeout
	input_field.text = ""
	input_field.editable = true
	submit_button.disabled = false
	hint_button.disabled = false
	is_validating = false
	input_field.grab_focus()

func _on_hint_pressed():
	"""Show hint from text data"""
	if hint_shown:
		return

	hint_shown = true
	hint_button.text = current_text_data.hint
	hint_button.disabled = true

func flash_input_field(color: Color):
	"""Flash input field border"""
	var original_color = input_field.get_theme_color("font_color", "LineEdit")

	# Flash style
	var flash_style = StyleBoxFlat.new()
	flash_style.bg_color = Color(1, 1, 1)
	flash_style.border_width_left = 3
	flash_style.border_width_top = 3
	flash_style.border_width_right = 3
	flash_style.border_width_bottom = 3
	flash_style.border_color = color
	flash_style.corner_radius_top_left = 4
	flash_style.corner_radius_top_right = 4
	flash_style.corner_radius_bottom_right = 4
	flash_style.corner_radius_bottom_left = 4

	input_field.add_theme_stylebox_override("normal", flash_style)
	input_field.add_theme_stylebox_override("focus", flash_style)

	await get_tree().create_timer(0.3).timeout
	input_field.remove_theme_stylebox_override("normal")
	input_field.remove_theme_stylebox_override("focus")

func reset_for_next_translation():
	"""Reset for next customer or show completion"""
	is_validating = false
	hint_shown = false

	input_field.text = ""
	input_field.remove_theme_color_override("font_color")

	# Check if there's another book on desk to translate
	if not GameState.current_book.is_empty():
		initialize()  # Load next book
	else:
		show_no_customer_message()

func refresh():
	"""Update display when panel is refreshed"""
	initialize()
