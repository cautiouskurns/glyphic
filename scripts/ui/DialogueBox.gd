# DialogueBox.gd
# Feature 3.3: Accept/Refuse Logic
# Manages dialogue box updates for customer interactions
extends Panel

@onready var dialogue_label = $DialogueLabel

# Generic dialogue messages
const GENERIC_ACCEPT = "\"Wonderful! I'll wait patiently while you work on this.\""
const GENERIC_REFUSE = "\"No problem, I'll try another shop. Good luck!\""
const CAPACITY_FULL = "*You've reached capacity for today. Remaining customers turn away.*"

func update_dialogue(message: String, color: Color):
	"""Update dialogue text and color"""
	dialogue_label.text = message
	dialogue_label.add_theme_color_override("font_color", color)

func show_accept_dialogue(customer_data: Dictionary):
	"""Show acceptance dialogue"""
	var dialogue_data = customer_data.get("dialogue", {})
	var message = dialogue_data.get("negotiation", GENERIC_ACCEPT)

	# Format message
	var formatted = "\"%s\"\n  — %s" % [message, customer_data.get("name", "Customer")]

	update_dialogue(formatted, Color("#2ECC71"))  # Green

func show_refuse_dialogue(customer_data: Dictionary):
	"""Show refusal dialogue"""
	var dialogue_data = customer_data.get("dialogue", {})
	var customer_name = customer_data.get("name", "Customer")

	# Check if recurring customer and get appropriate message
	if customer_data.get("is_recurring", false):
		var message = dialogue_data.get("failure", GENERIC_REFUSE)

		# Check if relationship broken (different message for final refusal)
		if customer_name in CustomerData.recurring_customers:
			var relationship = CustomerData.recurring_customers[customer_name].current_relationship
			if relationship == 0:
				# Relationship broken - use sadder message
				if customer_name == "Mrs. Kowalski":
					message = "I see. I'll find someone else to help."
				elif customer_name == "Dr. Chen":
					message = "I'm disappointed. I thought I could count on you."
				elif customer_name == "The Stranger":
					message = "*He nods silently and leaves, never to return.*"

		var formatted = "\"%s\"\n  — %s" % [message, customer_name]
		update_dialogue(formatted, Color("#E74C3C"))  # Red
	else:
		# Random customer - generic refusal
		var formatted = "%s\n  — %s" % [GENERIC_REFUSE, customer_name]
		update_dialogue(formatted, Color("#E74C3C"))  # Red

func show_capacity_full_message():
	"""Show capacity full message"""
	update_dialogue(CAPACITY_FULL, Color("#FF8C00"))  # Orange

func clear_dialogue():
	"""Reset to placeholder"""
	dialogue_label.text = "*Customer dialogue appears here...*"
	dialogue_label.add_theme_color_override("font_color", Color("#999999"))
