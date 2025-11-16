# Main.gd
# Main game controller with tab system for expanded screen views
extends Control

@onready var tab_bar = $TabBar
@onready var left_panel = $LeftPanel
@onready var workspace = $Workspace
@onready var right_panel = $RightPanel
@onready var examination_screen = $Workspace/ExaminationScreen
@onready var translation_display = $Workspace/TranslationDisplay

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

func _ready():
	# Connect tab bar signal
	tab_bar.tab_selected.connect(_on_tab_selected)

	# Set initial tab
	current_tab = Tab.WORK
	apply_tab_layout(Tab.WORK)

func _input(event):
	"""Handle keyboard shortcuts for tab switching"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
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
	"""Full-screen customer queue"""
	# Hide workspace and right panel
	set_panel_visible_animated(workspace, false)
	set_panel_visible_animated(right_panel, false)

	# Expand left panel to full width
	set_panel_visible_animated(left_panel, true)
	tween_panel_rect(left_panel, {"left": 0, "top": 130, "right": 1920, "bottom": 780})

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
