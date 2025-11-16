# EndDayButton.gd
# Feature 4.5: Multi-Day Progression System
# Shows "End Day" button when capacity full or queue exhausted
extends Button

# Hover colors
const COLOR_NORMAL = Color("#2D5016")
const COLOR_HOVER = Color("#3D6826")
const COLOR_DISABLED = Color("#555555")

var is_enabled: bool = false

func _ready():
	# Start hidden
	visible = false
	disabled = true

	# Connect to GameState capacity changes
	GameState.capacity_changed.connect(_on_capacity_changed)

	# Also check when customers are accepted/refused
	var popup = get_node("/root/Main/CustomerPopup")
	if popup:
		popup.customer_accepted.connect(_check_queue_exhausted)
		popup.customer_refused.connect(_check_queue_exhausted)

func _input(event):
	# E key shortcut to end day
	if event is InputEventKey and event.pressed and event.keycode == KEY_E and is_enabled and visible:
		_on_pressed()
		get_viewport().set_input_as_handled()

func _on_capacity_changed():
	"""Show button when capacity is full"""
	if GameState.capacity_used >= GameState.max_capacity:
		show_button()
	else:
		hide_button()

func _check_queue_exhausted(_customer_data = null):
	"""Check if all customers in queue have been processed (accepted or refused)"""
	# Get queue panel
	var queue_panel = get_node("/root/Main/LeftPanel")
	if not queue_panel:
		return

	# Check all cards - if all are accepted or refused, queue is exhausted
	var all_processed = true
	for card in queue_panel.card_container.get_children():
		if not card.is_accepted and not card.is_refused:
			all_processed = false
			break

	# Show button if queue exhausted OR capacity full
	if all_processed or GameState.is_capacity_full():
		show_button()
	else:
		hide_button()

func show_button():
	"""Enable and show the End Day button"""
	is_enabled = true
	disabled = false
	visible = true

	# Update button style
	var style = get_theme_stylebox("normal").duplicate()
	style.bg_color = COLOR_NORMAL
	add_theme_stylebox_override("normal", style)

func hide_button():
	"""Hide the End Day button"""
	is_enabled = false
	disabled = true
	visible = false

func _on_pressed():
	"""Handle End Day button click - trigger day transition"""
	if not is_enabled:
		return

	# Get transition overlay
	var main = get_node("/root/Main")
	if main.has_node("DayTransition"):
		var transition = main.get_node("DayTransition")
		transition.start_day_transition()

	# Hide button immediately
	hide_button()

# Hover effects
func _on_mouse_entered():
	if not is_enabled:
		return

	var style = get_theme_stylebox("normal").duplicate()
	style.bg_color = COLOR_HOVER
	style.border_color = Color("#FFD700")  # Gold glow
	add_theme_stylebox_override("normal", style)

func _on_mouse_exited():
	if not is_enabled:
		return

	var style = get_theme_stylebox("normal").duplicate()
	style.bg_color = COLOR_NORMAL
	style.border_color = Color("#1A3009")
	add_theme_stylebox_override("normal", style)
