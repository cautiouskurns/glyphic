# MagnifyingGlassButton.gd
# Interactive magnifying glass button for navigating to book examination
extends Button

@onready var tooltip = $Tooltip
@onready var lens = $Lens
@onready var lens_rim = $LensRim

var original_lens_color: Color
var hover_tween: Tween

func _ready():
	original_lens_color = lens.color

	# Connect hover signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	# Show tooltip
	tooltip.visible = true

	# Make lens more visible on hover
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(lens, "color", Color(0.7, 0.85, 1, 0.6), 0.2)

func _on_mouse_exited():
	# Hide tooltip
	tooltip.visible = false

	# Return lens to original transparency
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(lens, "color", original_lens_color, 0.2)
