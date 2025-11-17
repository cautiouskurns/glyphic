# PapersButton.gd
# Interactive papers button for navigating to translation workspace
extends Button

@onready var tooltip = $Tooltip
@onready var papers = [
	$Paper1,
	$Paper2,
	$Paper3,
	$Paper4
]

var hover_tween: Tween

func _ready():
	# Connect hover signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	# Show tooltip
	tooltip.visible = true

	# Slightly lift papers on hover
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	for i in range(papers.size()):
		hover_tween.tween_property(papers[i], "position:y", papers[i].position.y - 3, 0.2)

func _on_mouse_exited():
	# Hide tooltip
	tooltip.visible = false

	# Return papers to original position
	if hover_tween:
		hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	for i in range(papers.size()):
		hover_tween.tween_property(papers[i], "position:y", papers[i].position.y + 3, 0.2)
