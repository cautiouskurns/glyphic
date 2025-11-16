# CashLabel.gd
# Updates to show current cash with dynamic color
extends Label

func _process(_delta):
	text = "$%d" % GameState.player_cash
	modulate = GameState.get_cash_color()
