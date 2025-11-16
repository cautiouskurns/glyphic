# CashLabel.gd
# Feature 2.5: Money Tracking System
# Updates to show current cash with animated count-up and dynamic color
extends Label

var target_cash: int = 100
var displayed_cash: int = 100
var animation_speed: float = 100.0  # Dollars per second

func _ready():
	target_cash = GameState.player_cash
	displayed_cash = GameState.player_cash
	text = "$%d" % displayed_cash
	modulate = get_cash_color_for_amount(displayed_cash)

func _process(delta):
	# Check if GameState cash changed
	if GameState.player_cash != target_cash:
		target_cash = GameState.player_cash

	# Animate towards target
	if displayed_cash != target_cash:
		var diff = target_cash - displayed_cash
		var step = sign(diff) * min(abs(diff), animation_speed * delta)

		# Ensure at least 1 dollar increment per frame (prevent stuck at 0)
		if abs(step) < 1.0:
			step = sign(diff)

		displayed_cash += int(step)

		# Clamp to target (prevent overshoot)
		if sign(diff) > 0 and displayed_cash > target_cash:
			displayed_cash = target_cash
		elif sign(diff) < 0 and displayed_cash < target_cash:
			displayed_cash = target_cash

	# Update display
	text = "$%d" % displayed_cash
	modulate = get_cash_color_for_amount(displayed_cash)

func get_cash_color_for_amount(amount: int) -> Color:
	"""Get color for specific cash amount (for smooth transition during animation)"""
	if amount >= 200:
		return Color("#2D5016")  # Green - comfortable
	elif amount >= 100:
		return Color("#CC6600")  # Orange - cautious
	else:
		return Color("#8B0000")  # Red - danger
