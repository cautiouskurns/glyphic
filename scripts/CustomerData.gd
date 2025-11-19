# CustomerData.gd
# Autoload singleton managing customer types, queue generation, and relationship tracking
extends Node

# 3 recurring customer types from design doc
var recurring_customers: Dictionary = {
	"Mrs. Kowalski": {
		"type": "recurring",
		"book_title": "Family History",
		"appears_days": [1, 2, 3],  # Monday, Tuesday, Wednesday
		"payment": 50,
		"difficulty": "Easy",
		"priorities": ["Cheap", "Accurate"],
		"refusal_tolerance": 2,  # Stops appearing after 2 refusals
		"current_relationship": 2,  # Starts at max, decreases on refusal
		"dialogue": {
			"greeting": "Hello dear, I found this old family book.",
			"negotiation": "Take your time, dear. I just want it done right.",
			"success": "Oh wonderful! Thank you so much!",
			"failure": "Are you sure, dear? It doesn't seem quite right...",
			"story_beat": "My grandmother was in a secret society, you know."
		},
		"story_role": "Tutorial/Heart",
		"personality": "Patient, sweet, gentle introduction",
		"book_cover_color": Color("#F4E8D8"),  # Cream/aged parchment (Feature 4.1)
		"uv_hidden_text": "Previous owner:\nMargaret K.\n1924"  # Feature 4.1 - UV Light reveal
	},

	"Dr. Chen": {
		"type": "recurring",
		"book_title": "Research Journal",
		"appears_days": [2, 3, 4, 5, 6, 7],  # Tuesday through Sunday
		"payment": 100,
		"difficulty": "Medium",
		"priorities": ["Fast", "Accurate"],
		"refusal_tolerance": 2,
		"current_relationship": 2,
		"dialogue": {
			"greeting": "I need this translated for my research. It's critical.",
			"negotiation": "Accuracy is everything. Money isn't an issue.",
			"success": "Excellent work. This confirms my hypothesis.",
			"failure": "This can't be right. My research depends on accuracy.",
			"story_beat": "Something is waking up beneath the city... we're running out of time."
		},
		"story_role": "Scholar/Plot",
		"personality": "Curious, intense, driven",
		"book_cover_color": Color("#8B4513"),  # Dark scholarly brown (Feature 4.1)
		"uv_hidden_text": "⚠ FORBIDDEN SEAL\nDo not open after dark"  # Feature 4.1 - UV Light reveal
	},

	"The Stranger": {
		"type": "recurring",
		"book_title": "Ancient Tome",
		"appears_days": [5, 6, 7],  # Friday, Saturday, Sunday
		"payment": 200,
		"difficulty": "Hard",
		"priorities": ["Fast", "Accurate"],
		"refusal_tolerance": 1,  # Very sensitive - one refusal and gone
		"current_relationship": 1,
		"dialogue": {
			"greeting": "Translate this. Now.",
			"negotiation": "Fast and accurate. Money is no object.",
			"success": "You've done well. Keep this between us.",
			"failure": "Unacceptable. I expected better.",
			"story_beat": "They are returning soon. You need to know the truth."
		},
		"story_role": "Mystery/Finale",
		"personality": "Mysterious, terse, ominous",
		"book_cover_color": Color("#1A1A1A"),  # Black/mysterious (Feature 4.1)
		"uv_hidden_text": "PROPERTY OF\nTHE ORDER\n⊗"  # Feature 4.1 - UV Light reveal
	}
}

# Random customer templates (one-time only)
var random_customer_templates: Array = [
	{
		"name_prefix": "Scholar",
		"book_title": "Ancient Text",
		"difficulty": "Medium",
		"payment_range": [80, 120],
		"priorities": [["Fast", "Cheap"], ["Cheap", "Accurate"]],
		"dialogue": {
			"greeting": "I need this academic text translated.",
			"success": "Thank you, this will help my thesis.",
			"failure": "Hmm, I'll need to double-check this."
		}
	},
	{
		"name_prefix": "Collector",
		"book_title": "Estate Find",
		"difficulty": "Hard",
		"payment_range": [150, 180],
		"priorities": [["Fast", "Accurate"]],
		"dialogue": {
			"greeting": "Rare find. Need it authenticated.",
			"success": "Fascinating. Worth every penny.",
			"failure": "Are you certain? This is valuable."
		}
	},
	{
		"name_prefix": "Student",
		"book_title": "Homework Help",
		"difficulty": "Easy",
		"payment_range": [40, 60],
		"priorities": [["Fast", "Cheap"]],
		"dialogue": {
			"greeting": "I need help with my homework...",
			"success": "Thanks! You're a lifesaver!",
			"failure": "Oh no... I really needed this."
		}
	},
	{
		"name_prefix": "Merchant",
		"book_title": "Mystery Book",
		"difficulty": "Easy",
		"payment_range": [50, 80],
		"priorities": [["Fast", "Cheap"], ["Cheap", "Accurate"]],
		"dialogue": {
			"greeting": "Got this at an estate sale. What's it say?",
			"success": "Neat! Thanks for the translation.",
			"failure": "Eh, not worth much anyway."
		}
	}
]

# Generate daily customer queue (7-10 customers total)
func generate_daily_queue(day_number: int) -> Array:
	var queue: Array = []

	# Add recurring customers if they should appear today
	for customer_name in recurring_customers.keys():
		var customer = recurring_customers[customer_name]

		# Check if day is in appearance window
		if day_number in customer.appears_days:
			# Check if relationship is intact (not refused too many times)
			if customer.current_relationship > 0:
				queue.append(create_customer_instance(customer_name, customer))

	# Fill remaining slots with random one-time customers (target 7-10 total)
	var num_random = randi_range(4, 7)  # Fill to reach 7-10 total
	for i in range(num_random):
		queue.append(generate_random_customer())

	# Shuffle queue so recurring customers aren't always first
	queue.shuffle()

	return queue

func create_customer_instance(name: String, data: Dictionary) -> Dictionary:
	"""Create a customer instance from recurring customer data"""
	return {
		"name": name,
		"book_title": data.book_title,
		"type": data.type,
		"payment": data.payment,
		"difficulty": data.difficulty,
		"priorities": data.priorities,
		"dialogue": data.dialogue,
		"story_role": data.story_role,
		"is_recurring": true,
		"book_cover_color": data.get("book_cover_color", Color("#F4E8D8")),  # Feature 4.1 - Default cream if missing
		"uv_hidden_text": data.get("uv_hidden_text", "")  # Feature 4.1 - Empty if no UV text
	}

func generate_random_customer() -> Dictionary:
	"""Generate a one-time random customer from templates"""
	var template = random_customer_templates[randi() % random_customer_templates.size()]
	var random_number = randi_range(100, 999)

	# Random book cover colors for variety (Feature 4.1)
	var random_colors = [
		Color("#F4E8D8"),  # Cream
		Color("#D2B48C"),  # Tan
		Color("#8B4513"),  # Brown
		Color("#A0826D"),  # Light brown
		Color("#6B4423")   # Dark brown
	]

	return {
		"name": "%s #%d" % [template.name_prefix, random_number],
		"book_title": template.book_title,
		"type": "one-time",
		"payment": randi_range(template.payment_range[0], template.payment_range[1]),
		"difficulty": template.difficulty,
		"priorities": template.priorities[randi() % template.priorities.size()],
		"dialogue": template.dialogue,
		"story_role": "None",
		"is_recurring": false,
		"book_cover_color": random_colors[randi() % random_colors.size()],  # Feature 4.1
		"uv_hidden_text": ""  # No UV text for random customers (Feature 4.1)
	}

func damage_relationship(customer_name: String):
	"""Decrease relationship value when player refuses a recurring customer"""
	if customer_name in recurring_customers:
		recurring_customers[customer_name].current_relationship -= 1

func get_relationship_status(customer_name: String) -> int:
	"""Get current relationship value for a recurring customer"""
	if customer_name in recurring_customers:
		return recurring_customers[customer_name].current_relationship
	return -1  # Not a recurring customer

func reset_relationships():
	"""Reset all relationships to starting values (for new game)"""
	for customer_name in recurring_customers.keys():
		recurring_customers[customer_name].current_relationship = recurring_customers[customer_name].refusal_tolerance
