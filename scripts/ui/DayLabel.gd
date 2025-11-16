# DayLabel.gd
# Updates to show current day number and name
extends Label

func _process(_delta):
	text = "Day %d - %s" % [GameState.current_day, GameState.day_name]
