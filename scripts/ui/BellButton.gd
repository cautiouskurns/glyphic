# BellButton.gd
# Interactive bell button for starting work
extends Button

@onready var tooltip = $Tooltip
@onready var bell_dome = $BellDome
@onready var bell_top = $BellTop
@onready var highlight = $Highlight

var original_dome_color: Color
var hover_tween: Tween
var press_tween: Tween

func _ready():
	original_dome_color = bell_dome.color

	# Connect signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_mouse_entered():
	# Show tooltip
	tooltip.visible = true

	# Brighten bell on hover
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(bell_dome, "color", original_dome_color.lightened(0.15), 0.2)

func _on_mouse_exited():
	# Hide tooltip
	tooltip.visible = false

	# Return to original color
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(bell_dome, "color", original_dome_color, 0.2)

func _on_button_down():
	# Press bell top down
	if press_tween:
		press_tween.kill()
	press_tween = create_tween()
	press_tween.tween_property(bell_top, "position:y", bell_top.position.y + 3, 0.1)

func _on_button_up():
	# Release bell top
	if press_tween:
		press_tween.kill()
	press_tween = create_tween()
	press_tween.tween_property(bell_top, "position:y", bell_top.position.y - 3, 0.1)
