# CapacityLabel.gd
# Updates to show current capacity usage
extends Label

func _process(_delta):
	text = "%d/%d Customers Served" % [GameState.capacity_used, GameState.max_capacity]
