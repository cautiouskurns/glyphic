# DiegeticPanel.gd
# Feature 3A.3: Screen Panel Sliding
# Individual panel that slides onto desk workspace
extends Control

# Panel configuration
var panel_type: String  # "queue", "translation", "dictionary", "examination", "work"
var panel_title: String
var panel_color: Color
var layout_config: PanelLayoutConfig  # Layout configuration (loaded from LayoutManager)
var target_position: Vector2  # Final position on desk (set by ShopScene)
var is_active: bool = false

# Convenience accessors (delegate to layout_config)
var panel_width: int:
	get: return layout_config.panel_width if layout_config else 600
var panel_height: int:
	get: return layout_config.panel_height if layout_config else 700

# Animation
var slide_tween: Tween
const SLIDE_DURATION = 0.4
const OFF_SCREEN_X = 2100

# UI References
var background_panel: Panel  # Background panel for styling
var header_bar: Panel
var tab_label: Label
var close_button: Button
var content_container: ScrollContainer
var content_area: VBoxContainer

# Signals
signal panel_closed(panel_type: String)
signal panel_focused(panel_type: String)

func _ready():
	"""Initialize panel appearance and UI"""
	setup_panel_style()
	setup_header()
	setup_content_area()
	setup_close_button()  # Add button LAST so it's on top

func load_content(panel_type: String):
	"""Load screen content via DiegeticScreenManager"""
	DiegeticScreenManager.load_screen_into_panel(panel_type, self)

func setup_panel_style():
	"""Style panel as desk object (paper/folder)"""
	# Control sizing and positioning
	custom_minimum_size = Vector2(panel_width, panel_height)
	size = Vector2(panel_width, panel_height)
	position = Vector2(OFF_SCREEN_X, target_position.y)  # Start off-screen, at target Y position
	mouse_filter = Control.MOUSE_FILTER_STOP  # Catch clicks for focus handling

	# CRITICAL: Disable automatic child layout
	clip_contents = false

	# Skip background panel for screens that provide their own (e.g., queue, examination, translation, dictionary)
	# These screens have their background styled in their .tscn file
	var screens_with_own_background = ["queue", "examination", "translation", "dictionary"]
	if panel_type in screens_with_own_background:
		return  # Don't create background panel

	# Create background panel for styling
	background_panel = Panel.new()
	background_panel.position = Vector2(0, 0)
	background_panel.size = Vector2(panel_width, panel_height)
	background_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Critical: don't block clicks
	background_panel.z_index = -10  # Behind everything

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.95, 0.92, 0.88)  # Cream paper
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.3, 0.25, 0.2)  # Dark brown edge
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.shadow_size = 12
	panel_style.shadow_offset = Vector2(6, 6)
	panel_style.shadow_color = Color(0, 0, 0, 0.5)

	background_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(background_panel)

func update_layout():
	"""Update panel layout when dimensions change (called after layout_config is set)"""
	# Update control size
	custom_minimum_size = Vector2(panel_width, panel_height)
	size = Vector2(panel_width, panel_height)

	# Update background panel size
	if background_panel:
		background_panel.size = Vector2(panel_width, panel_height)

	# Update header size
	if header_bar:
		var header_height = layout_config.header_height if layout_config else 35
		header_bar.size = Vector2(panel_width, header_height)

	# Update title label size
	if tab_label:
		tab_label.size = Vector2(panel_width - 60, 20)

	# Update close button position (top right)
	if close_button:
		if layout_config:
			close_button.position = layout_config.get_close_button_position()
			var btn_size = layout_config.close_button_size
			close_button.size = Vector2(btn_size, btn_size)
		else:
			close_button.position = Vector2(panel_width - 38, 4)
			close_button.size = Vector2(28, 28)

	# Update content area size
	if content_container:
		var content_width: int
		var content_height: int
		var content_pos: Vector2

		if layout_config:
			content_width = layout_config.get_content_width()
			content_height = layout_config.get_content_height()
			content_pos = layout_config.get_content_position()
		else:
			content_width = panel_width - 40
			content_height = panel_height - 75
			content_pos = Vector2(20, 55)

		content_container.custom_minimum_size = Vector2(content_width, content_height)
		content_container.size = Vector2(content_width, content_height)
		content_container.position = content_pos

func setup_header():
	"""Create header bar with tab and close button"""
	# Header bar with absolute positioning
	header_bar = Panel.new()
	header_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE  # IGNORE so it doesn't block button

	# Header color matches panel type (desk object color)
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = panel_color
	header_style.corner_radius_top_left = 4
	header_style.corner_radius_top_right = 4
	header_bar.add_theme_stylebox_override("panel", header_style)

	add_child(header_bar)

	# Set position AFTER adding to tree
	var header_height = layout_config.header_height if layout_config else 35
	header_bar.position = Vector2(0, 0)
	header_bar.size = Vector2(panel_width, header_height)

	# Tab label (panel name) - left aligned in header
	tab_label = Label.new()
	tab_label.text = panel_title
	tab_label.add_theme_color_override("font_color", Color(1, 1, 1))
	tab_label.add_theme_font_size_override("font_size", 13)
	tab_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tab_label.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block clicks
	header_bar.add_child(tab_label)

	# Set position AFTER adding to tree
	var title_padding = layout_config.title_padding_left if layout_config else 12
	tab_label.position = Vector2(title_padding, 8)
	tab_label.size = Vector2(panel_width - 60, 20)  # Leave space for close button

func setup_close_button():
	"""Setup close button - called LAST so it's drawn on top"""
	close_button = Button.new()
	close_button.text = "X"

	# Prevent button from expanding to fill parent
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	close_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	# Set fixed size
	var btn_size = layout_config.close_button_size if layout_config else 28
	close_button.custom_minimum_size = Vector2(btn_size, btn_size)
	close_button.size = Vector2(btn_size, btn_size)

	# Position will be set by update_layout() - just add it for now
	close_button.position = Vector2(0, 4)

	close_button.pressed.connect(_on_close_pressed)
	add_child(close_button)

	# Force position update on next frame
	call_deferred("_update_close_button_position")

func _update_close_button_position():
	"""Update close button position after layout is finalized"""
	if close_button and is_instance_valid(close_button):
		if layout_config:
			close_button.position = layout_config.get_close_button_position()
		else:
			# Fallback calculation: top-right corner with offset
			close_button.position = Vector2(panel_width - 38, 4)

func setup_content_area():
	"""Create scrollable content area"""
	content_container = ScrollContainer.new()

	# Use layout config if available, otherwise fall back to hardcoded values
	var content_width: int
	var content_height: int
	var content_pos: Vector2

	if layout_config:
		content_width = layout_config.get_content_width()
		content_height = layout_config.get_content_height()
		content_pos = layout_config.get_content_position()
	else:
		# Fallback calculations
		content_width = panel_width - 40  # 20px padding on each side
		content_height = panel_height - 75  # 55px for header + 20px bottom
		content_pos = Vector2(20, 55)

	content_container.custom_minimum_size = Vector2(content_width, content_height)
	content_container.size = Vector2(content_width, content_height)
	content_container.position = content_pos
	content_container.mouse_filter = Control.MOUSE_FILTER_PASS  # Pass clicks to children

	# Remove default ScrollContainer background styling
	var transparent_style = StyleBoxEmpty.new()
	content_container.add_theme_stylebox_override("panel", transparent_style)

	add_child(content_container)

	content_area = VBoxContainer.new()
	content_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.add_child(content_area)

	# Placeholder content (will be replaced by actual panel content)
	var placeholder = Label.new()
	placeholder.text = "Panel content will go here\n(Feature 3A.4 will populate this)"
	placeholder.add_theme_font_size_override("font_size", 18)
	content_area.add_child(placeholder)

func slide_in():
	"""Animate panel sliding in from right"""
	if slide_tween:
		slide_tween.kill()

	slide_tween = create_tween()
	slide_tween.set_ease(Tween.EASE_OUT)
	slide_tween.set_trans(Tween.TRANS_CUBIC)

	slide_tween.tween_property(self, "position:x", target_position.x, SLIDE_DURATION)

func slide_out():
	"""Animate panel sliding out to right"""
	# Clean up screen content first (Feature 3A.4)
	DiegeticScreenManager.unload_screen(panel_type)

	if slide_tween:
		slide_tween.kill()

	slide_tween = create_tween()
	slide_tween.set_parallel(true)
	slide_tween.set_ease(Tween.EASE_IN)
	slide_tween.set_trans(Tween.TRANS_CUBIC)

	slide_tween.tween_property(self, "position:x", OFF_SCREEN_X, 0.3)
	slide_tween.tween_property(self, "modulate:a", 0.0, 0.3)

	await slide_tween.finished
	queue_free()

func set_active(active: bool):
	"""Set panel as active (front) or inactive (background)"""
	is_active = active

	if active:
		z_index = 10
		modulate.a = 1.0
		header_bar.modulate.a = 1.0
	else:
		z_index = 5
		modulate.a = 0.95
		header_bar.modulate.a = 0.7

func _on_close_pressed():
	"""Handle close button click"""
	panel_closed.emit(panel_type)

func _gui_input(event):
	"""Handle panel click to bring to front"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Bring panel to front if not active
		if not is_active:
			panel_focused.emit(panel_type)
