# GameState.gd
# Autoload singleton managing core game state
extends Node

# Core state variables
var current_day: int = 1
var day_name: String = "Monday"
var player_cash: int = 100
var capacity_used: int = 0
var max_capacity: int = 5

# Constants
const DAILY_UTILITIES: int = 30
const WEEKLY_RENT: int = 200
const RENT_DUE_DAY: int = 5  # Friday
const STARTING_CASH: int = 100
const DAY_NAMES: Array = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

func _ready():
	reset_game_state()

func reset_game_state():
	"""Reset all game state to initial values"""
	current_day = 1
	day_name = DAY_NAMES[0]
	player_cash = STARTING_CASH
	capacity_used = 0
	max_capacity = 5

func advance_day():
	"""Advance to next day, deduct utilities, reset capacity"""
	player_cash -= DAILY_UTILITIES
	current_day += 1
	if current_day <= 7:
		day_name = DAY_NAMES[current_day - 1]
	capacity_used = 0

	# Check if rent is due (Friday = day 5)
	if current_day == RENT_DUE_DAY:
		check_rent_payment()

func check_rent_payment():
	"""Check if player can pay rent, deduct if possible"""
	if player_cash >= WEEKLY_RENT:
		player_cash -= WEEKLY_RENT
	else:
		# Game over logic will be added in Phase 4
		pass

func add_cash(amount: int):
	"""Add cash to player's balance"""
	player_cash += amount

func increment_capacity():
	"""Increment capacity used (when accepting a customer)"""
	capacity_used += 1

func can_accept_customer() -> bool:
	"""Check if player can accept another customer today"""
	return capacity_used < max_capacity

func get_cash_color() -> Color:
	"""Return color based on cash amount thresholds"""
	if player_cash >= 200:
		return Color("#2D5016")  # Green - comfortable
	elif player_cash >= 100:
		return Color("#CC6600")  # Orange - cautious
	else:
		return Color("#8B0000")  # Red - danger
