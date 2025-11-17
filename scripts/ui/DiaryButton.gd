# DiaryButton.gd
# Interactive diary button for navigating to customer queue
extends Button

@onready var tooltip = $Tooltip
@onready var diary_cover = $DiaryCover

var original_color: Color
var hover_tween: Tween

func _ready():
	original_color = diary_cover.color

	# Connect hover signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	# Show tooltip
	tooltip.visible = true

	# Brighten cover on hover
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(diary_cover, "color", original_color.lightened(0.2), 0.2)

func _on_mouse_exited():
	# Hide tooltip
	tooltip.visible = false

	# Return to original color
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(diary_cover, "color", original_color, 0.2)
