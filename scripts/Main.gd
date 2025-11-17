# Main.gd
# Main game controller with tab system for expanded screen views
extends Control

@onready var tab_bar = $TabBar
@onready var left_panel = $LeftPanel
@onready var workspace = $Workspace
@onready var right_panel = $RightPanel
@onready var examination_screen = $Workspace/ExaminationScreen
@onready var translation_display = $Workspace/TranslationDisplay
@onready var queue_title = $LeftPanel/TitleLabel
@onready var capacity_info = $LeftPanel/CapacityInfo
@onready var difficulty_legend = $LeftPanel/DifficultyLegend

# Get reference to cork board style from scene
var corkboard_style: StyleBoxFlat
var default_panel_style: StyleBoxFlat

enum Tab {
	WORK = 0,
	TRANSLATION = 1,
	EXAMINATION = 2,
	DICTIONARY = 3,
	QUEUE = 4
}

var current_tab: Tab = Tab.WORK

# Store original panel dimensions for Work tab
var work_layout = {
	"left_panel": {"left": 0, "top": 130, "right": 420, "bottom": 780},
	"workspace": {"left": 420, "top": 130, "right": 1500, "bottom": 780},
	"right_panel": {"left": 1500, "top": 130, "right": 1920, "bottom": 780}
}

var return_button_added: bool = false

func _ready():
	# Connect tab bar signal
	tab_bar.tab_selected.connect(_on_tab_selected)

	# Store panel styles
	default_panel_style = left_panel.get_theme_stylebox("panel")

	# Create cork board style
	corkboard_style = StyleBoxFlat.new()
	corkboard_style.bg_color = Color(0.76, 0.6, 0.42, 1)
	corkboard_style.corner_radius_top_left = 8
	corkboard_style.corner_radius_top_right = 8
	corkboard_style.corner_radius_bottom_right = 8
	corkboard_style.corner_radius_bottom_left = 8
	corkboard_style.shadow_color = Color(0, 0, 0, 0.2)
	corkboard_style.shadow_size = 6
	corkboard_style.shadow_offset = Vector2(0, 3)

	# Add return to shop button (only once)
	if not return_button_added:
		add_return_to_shop_button()
		return_button_added = true

	# Apply initial layout
	apply_initial_tab()

func apply_initial_tab():
	"""Apply the appropriate tab when scene becomes visible"""
	# Make sure the scene is ready before accessing onready variables
	if not tab_bar:
		return

	# Check if we came from shop with a target tab
	if SceneManager.target_tab >= 0:
		current_tab = SceneManager.target_tab
		tab_bar.current_tab = SceneManager.target_tab
		apply_tab_layout(SceneManager.target_tab)
	else:
		# Set initial tab
		current_tab = Tab.WORK
		apply_tab_layout(Tab.WORK)

func _notification(what):
	"""Handle visibility changes"""
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible and is_node_ready():
			# Scene just became visible and is ready, apply the target tab
			apply_initial_tab()

func _input(event):
	"""Handle keyboard shortcuts for tab switching"""
	if event is InputEventKey and event.pressed and visible:
		match event.keycode:
			KEY_ESCAPE:
				# Return to shop
				SceneManager.return_to_shop()
			KEY_1:
				tab_bar.current_tab = Tab.WORK
				_on_tab_selected(Tab.WORK)
			KEY_2:
				tab_bar.current_tab = Tab.TRANSLATION
				_on_tab_selected(Tab.TRANSLATION)
			KEY_3:
				tab_bar.current_tab = Tab.EXAMINATION
				_on_tab_selected(Tab.EXAMINATION)
			KEY_4:
				tab_bar.current_tab = Tab.DICTIONARY
				_on_tab_selected(Tab.DICTIONARY)
			KEY_5:
				tab_bar.current_tab = Tab.QUEUE
				_on_tab_selected(Tab.QUEUE)
			KEY_0:
				# DEBUG: Access shop scene directly
				SceneManager.return_to_shop()

func _on_tab_selected(tab: int):
	"""Handle tab change"""
	current_tab = tab
	apply_tab_layout(tab)

func apply_tab_layout(tab: Tab):
	"""Apply layout for selected tab with smooth transitions"""
	match tab:
		Tab.WORK:
			apply_work_layout()
		Tab.TRANSLATION:
			apply_translation_layout()
		Tab.EXAMINATION:
			apply_examination_layout()
		Tab.DICTIONARY:
			apply_dictionary_layout()
		Tab.QUEUE:
			apply_queue_layout()

func apply_work_layout():
	"""Default 3-panel layout"""
	# Show all panels
	set_panel_visible_animated(left_panel, true)
	set_panel_visible_animated(workspace, true)
	set_panel_visible_animated(right_panel, true)

	# Set positions
	tween_panel_rect(left_panel, work_layout.left_panel)
	tween_panel_rect(workspace, work_layout.workspace)
	tween_panel_rect(right_panel, work_layout.right_panel)

	# Restore default dark panel background
	left_panel.add_theme_stylebox_override("panel", default_panel_style)

	# Restore default title color (cream/beige)
	queue_title.add_theme_color_override("font_color", Color(0.956863, 0.909804, 0.847059, 1))

	# Hide capacity info and legend
	capacity_info.visible = false
	difficulty_legend.visible = false

	# Set grid to 1 column for narrow left panel
	if left_panel.has_method("set_grid_columns"):
		left_panel.set_grid_columns(1)

func apply_translation_layout():
	"""Full-screen translation workspace"""
	# Hide side panels
	set_panel_visible_animated(left_panel, false)
	set_panel_visible_animated(right_panel, false)

	# Expand workspace to full width
	set_panel_visible_animated(workspace, true)
	tween_panel_rect(workspace, {"left": 0, "top": 130, "right": 1920, "bottom": 780})

	# Ensure translation display is visible
	translation_display.visible = true
	examination_screen.visible = false

func apply_examination_layout():
	"""Full-screen book examination"""
	# Hide side panels
	set_panel_visible_animated(left_panel, false)
	set_panel_visible_animated(right_panel, false)

	# Expand workspace to full width
	set_panel_visible_animated(workspace, true)
	tween_panel_rect(workspace, {"left": 0, "top": 130, "right": 1920, "bottom": 780})

	# Show examination screen
	examination_screen.visible = true
	translation_display.visible = false

	# If no book loaded, load a test book (Scholar #749 from debug)
	if examination_screen.current_text_id == 0:
		var test_customer = {
			"name": "Scholar #749",
			"book_cover_color": Color("#F4E8D8"),
			"uv_hidden_text": "Ancient text\nrevealed by UV"
		}
		examination_screen.load_book(test_customer, 1)

func apply_dictionary_layout():
	"""Full-screen dictionary with wider cards"""
	# Hide left panel and workspace
	set_panel_visible_animated(left_panel, false)
	set_panel_visible_animated(workspace, false)

	# Expand right panel to full width with padding for nice wide cards
	set_panel_visible_animated(right_panel, true)
	tween_panel_rect(right_panel, {"left": 100, "top": 130, "right": 1820, "bottom": 780})

func apply_queue_layout():
	"""Full-screen customer queue with cork board grid"""
	# Hide workspace and right panel
	set_panel_visible_animated(workspace, false)
	set_panel_visible_animated(right_panel, false)

	# Expand left panel to full width with padding for cork board aesthetic
	set_panel_visible_animated(left_panel, true)
	tween_panel_rect(left_panel, {"left": 100, "top": 130, "right": 1820, "bottom": 780})

	# Apply cork board background
	left_panel.add_theme_stylebox_override("panel", corkboard_style)

	# Update title color for cork board (darker brown for contrast)
	queue_title.add_theme_color_override("font_color", Color(0.25, 0.18, 0.13, 1))

	# Show capacity info and difficulty legend
	capacity_info.visible = true
	difficulty_legend.visible = true

	# Update capacity info text
	var remaining = GameState.max_capacity - GameState.capacity_used
	if remaining > 0:
		capacity_info.text = "%d slot%s remaining today" % [remaining, "s" if remaining != 1 else ""]
	else:
		capacity_info.text = "No slots remaining today"

	# Set grid to 3 columns for wide cork board view
	if left_panel.has_method("set_grid_columns"):
		left_panel.set_grid_columns(3)

func set_panel_visible_animated(panel: Control, is_visible: bool):
	"""Fade in/out panel visibility"""
	if is_visible:
		panel.visible = true
		panel.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	else:
		var tween = create_tween()
		tween.tween_property(panel, "modulate:a", 0.0, 0.2)
		tween.tween_callback(func(): panel.visible = false)

func tween_panel_rect(panel: Control, rect: Dictionary):
	"""Smoothly animate panel position and size"""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "offset_left", rect.left, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "offset_top", rect.top, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "offset_right", rect.right, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "offset_bottom", rect.bottom, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func add_return_to_shop_button():
	"""Add a button to return to the shop scene"""
	var button = Button.new()
	button.text = "🏠 Return to Shop"
	button.position = Vector2(1650, 25)
	button.size = Vector2(240, 40)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color(0.956863, 0.909804, 0.847059, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))

	# Style button
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.25, 0.18, 0.13, 1)
	button_style.corner_radius_top_left = 4
	button_style.corner_radius_top_right = 4
	button_style.corner_radius_bottom_right = 4
	button_style.corner_radius_bottom_left = 4
	button.add_theme_stylebox_override("normal", button_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.35, 0.28, 0.23, 1)
	hover_style.corner_radius_top_left = 4
	hover_style.corner_radius_top_right = 4
	hover_style.corner_radius_bottom_right = 4
	hover_style.corner_radius_bottom_left = 4
	button.add_theme_stylebox_override("hover", hover_style)

	button.pressed.connect(func(): SceneManager.return_to_shop())

	# Add to top bar
	$TopBar.add_child(button)
