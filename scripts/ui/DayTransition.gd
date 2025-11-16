# DayTransition.gd
# Feature 4.5: Multi-Day Progression System
# Handles fade-to-black day transitions with title card
extends CanvasLayer

@onready var overlay = $Overlay
@onready var title_card = $TitleCard
@onready var day_label = $TitleCard/DayLabel
@onready var utilities_label = $TitleCard/UtilitiesLabel

func _ready():
	# Start with transition hidden
	overlay.color.a = 0.0
	title_card.visible = false

func start_day_transition():
	"""Execute full day transition sequence"""
	# Lock UI during transition
	set_process_input(false)

	# Sequence:
	# 1. Fade to black (0.2s)
	# 2. Show title card (hold 1.0s)
	# 3. Fade back in (0.3s)

	await fade_to_black()
	await show_title_card()
	await fade_from_black()

	# Unlock UI
	set_process_input(true)

func fade_to_black() -> void:
	"""Fade overlay to black"""
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 0.2)
	await tween.finished

func fade_from_black() -> void:
	"""Fade overlay back to transparent"""
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 0.0, 0.3)
	await tween.finished

func show_title_card() -> void:
	"""Show day title card, advance day, refresh queue"""
	# Advance the day
	GameState.advance_day()

	# Update title card text
	day_label.text = "Day %d - %s" % [GameState.current_day, GameState.day_name]
	utilities_label.text = "Utilities: -$%d" % GameState.DAILY_UTILITIES

	# Show title card
	title_card.visible = true

	# Hold for 1 second
	await get_tree().create_timer(1.0).timeout

	# Refresh customer queue
	var queue_panel = get_node("/root/Main/LeftPanel")
	if queue_panel:
		queue_panel.refresh_queue()

	# Hide title card
	title_card.visible = false
