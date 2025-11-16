# CapacityLabel.gd
# Updates to show current capacity usage
extends Label

var previous_capacity: int = 0

func _process(_delta):
	text = "%d/%d Customers Served" % [GameState.capacity_used, GameState.max_capacity]

	# Update color based on capacity (Feature 3.3)
	modulate = GameState.get_capacity_color()

	# Animate on capacity change
	if GameState.capacity_used != previous_capacity:
		animate_capacity_change()
		previous_capacity = GameState.capacity_used

func animate_capacity_change():
	"""Scale animation when capacity changes"""
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
