# DictionaryButton.gd
# Interactive dictionary button for navigating to glyph dictionary
extends Button

@onready var tooltip = $Tooltip
@onready var left_page = $LeftPage
@onready var right_page = $RightPage

var original_left_color: Color
var original_right_color: Color
var hover_tween: Tween

func _ready():
	original_left_color = left_page.color
	original_right_color = right_page.color

	# Connect hover signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	# Show tooltip
	tooltip.visible = true

	# Brighten pages on hover
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	hover_tween.tween_property(left_page, "color", Color(1, 1, 1, 1), 0.2)
	hover_tween.tween_property(right_page, "color", Color(1, 1, 1, 1), 0.2)

func _on_mouse_exited():
	# Hide tooltip
	tooltip.visible = false

	# Return to original color
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	hover_tween.tween_property(left_page, "color", original_left_color, 0.2)
	hover_tween.tween_property(right_page, "color", original_right_color, 0.2)
