# GameState.gd
# Autoload singleton managing core game state
extends Node

# Signals (Feature 4.5)
signal capacity_changed
signal day_advanced

# Core state variables
var current_day: int = 1
var day_name: String = "Monday"
var player_cash: int = 100
var capacity_used: int = 0
var max_capacity: int = 5

# Upgrades (Feature 3.4, 4.1)
var has_coffee_machine: bool = false  # Increases max_capacity to 6
var has_uv_light: bool = false  # Reveals hidden text on book covers (Feature 4.1)

# Customer tracking (Feature 3.3)
var accepted_customers: Array = []  # Array of customer data dictionaries
var refused_customers: Array = []  # Array of customer names (for relationship tracking)
var customer_queue: Array = []  # Feature 3A.4: Waiting customers

# Current customer being served
var current_customer: Dictionary = {}
# Current book on desk for examination/translation
var current_book: Dictionary = {}

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
	has_coffee_machine = false
	has_uv_light = false
	accepted_customers = []
	refused_customers = []
	customer_queue = []
	current_customer = {}
	current_book = {}

	# Feature 3A.4: Add some test customers to queue
	add_test_customers()

func advance_day():
	"""Advance to next day, deduct utilities, reset capacity"""
	player_cash -= DAILY_UTILITIES
	current_day += 1
	if current_day <= 7:
		day_name = DAY_NAMES[current_day - 1]
	capacity_used = 0
	accepted_customers = []  # Reset for new day

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
	capacity_changed.emit()

func can_accept_customer() -> bool:
	"""Check if player can accept another customer today"""
	return capacity_used < max_capacity

func is_capacity_full() -> bool:
	"""Check if capacity is at maximum (Feature 3.4)"""
	return capacity_used >= max_capacity

func get_cash_color() -> Color:
	"""Return color based on cash amount thresholds"""
	if player_cash >= 200:
		return Color("#2D5016")  # Green - comfortable
	elif player_cash >= 100:
		return Color("#CC6600")  # Orange - cautious
	else:
		return Color("#8B0000")  # Red - danger

# Feature 3.3: Accept/Refuse Logic
func accept_customer(customer_data: Dictionary):
	"""Add customer to accepted list, place book on desk, and increment capacity"""
	# Safety check: prevent accepting beyond capacity (Feature 3.4)
	if is_capacity_full():
		push_warning("Cannot accept customer - capacity full (%d/%d)" % [capacity_used, max_capacity])
		return

	accepted_customers.append(customer_data)

	# Place the customer's book on desk for examination/translation
	current_book = customer_data.duplicate()

	# Assign text ID based on difficulty
	var difficulty = customer_data.get("difficulty", "easy")
	current_book["text_id"] = get_text_id_for_difficulty(difficulty)

	# Add book appearance data if not present
	if not current_book.has("book_cover_color"):
		current_book["book_cover_color"] = Color("#F4E8D8")  # Default cream
	if not current_book.has("uv_hidden_text"):
		current_book["uv_hidden_text"] = ""

	increment_capacity()

func refuse_customer(customer_data: Dictionary):
	"""Add customer to refused list and damage relationship if recurring"""
	var customer_name = customer_data.get("name", "")
	refused_customers.append(customer_name)

	# If recurring customer, damage relationship
	if customer_data.get("is_recurring", false):
		CustomerData.damage_relationship(customer_name)

func get_capacity_color() -> Color:
	"""Return color based on capacity usage"""
	if capacity_used >= 5:
		return Color("#2D5016")  # Green - capacity met
	elif capacity_used >= 4:
		return Color("#FF8C00")  # Orange - almost full
	else:
		return Color("#888888")  # Gray - can take more

func get_text_id_for_difficulty(difficulty: String) -> int:
	"""Map customer difficulty to appropriate translation text ID"""
	match difficulty.to_lower():
		"easy":
			return 1  # Text 1: "the old way"
		"medium":
			return randi_range(2, 3)  # Text 2 or 3 (randomize)
		"hard":
			return randi_range(4, 5)  # Text 4 or 5 (randomize)
		_:
			return 1  # Default to easy

func get_day_name(day: int) -> String:
	"""Get the name of the day (e.g., Monday, Tuesday)"""
	if day >= 1 and day <= DAY_NAMES.size():
		return DAY_NAMES[day - 1]
	else:
		return "Day %d" % day  # For days beyond the week

func add_test_customers():
	"""Feature 3A.4: Add test customers to queue for development/testing"""
	customer_queue = [
		{
			"name": "Madame Leclair",
			"book_title": "Ancient Glyphs Vol 3",
			"difficulty": "easy",
			"payment": 50,
			"time": "2:00 PM",
			"description": "Sweet elderly woman. Always brings cookies.",
			"signature": "",
			"is_recurring": true,
			"is_priority": false
		},
		{
			"name": "Professor Thornwood",
			"book_title": "Tome of Mysteries",
			"difficulty": "medium",
			"payment": 75,
			"time": "2:00 PM",
			"description": "Grumpy academic. Very particular about translations.",
			"signature": "",
			"is_recurring": false,
			"is_priority": false
		},
		{
			"name": "Dr. Nakamura",
			"book_title": "Celestial Scripts",
			"difficulty": "hard",
			"payment": 100,
			"time": "2:00 PM",
			"description": "Mysterious scholar. Pays well for difficult work.",
			"signature": "",
			"is_recurring": true,
			"is_priority": true
		}
	]

func end_day():
	"""End the current day"""
	advance_day()
