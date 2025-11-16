# CapacityLabel.gd
# Updates to show current capacity usage
extends Label

@onready var lock_icon = $LockIcon
@onready var coffee_icon = $CoffeeIcon

var previous_capacity: int = 0
var previous_coffee_state: bool = false
var previous_full_state: bool = false

func _process(_delta):
	text = "%d/%d Customers Served" % [GameState.capacity_used, GameState.max_capacity]

	# Update color based on capacity (Feature 3.3)
	modulate = GameState.get_capacity_color()

	# Animate on capacity change
	if GameState.capacity_used != previous_capacity:
		animate_capacity_change()
		previous_capacity = GameState.capacity_used

	# Feature 3.4: Show/hide lock icon when capacity full
	var is_full = GameState.is_capacity_full()
	if is_full != previous_full_state:
		update_lock_icon(is_full)
		previous_full_state = is_full

	# Feature 3.4: Show/hide coffee icon when upgrade active
	var has_coffee = GameState.has_coffee_machine
	if has_coffee != previous_coffee_state:
		update_coffee_icon(has_coffee)
		previous_coffee_state = has_coffee

func animate_capacity_change():
	"""Scale animation when capacity changes"""
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func update_lock_icon(show: bool):
	"""Show or hide lock icon with fade animation (Feature 3.4)"""
	if show:
		lock_icon.modulate.a = 0.0
		lock_icon.visible = true
		var tween = create_tween()
		tween.tween_property(lock_icon, "modulate:a", 1.0, 0.2)
	else:
		lock_icon.visible = false

func update_coffee_icon(show: bool):
	"""Show or hide coffee cup icon with fade animation (Feature 3.4)"""
	if show:
		coffee_icon.modulate.a = 0.0
		coffee_icon.visible = true
		var tween = create_tween()
		tween.tween_property(coffee_icon, "modulate:a", 1.0, 0.2)
	else:
		coffee_icon.visible = false
