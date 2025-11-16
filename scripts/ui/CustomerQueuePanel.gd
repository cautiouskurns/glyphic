# CustomerQueuePanel.gd
# Feature 3.1: Customer Queue Display
# Manages the customer queue in the left panel
extends Panel

@onready var card_container = $ScrollContainer/VBoxContainer

var card_scene = preload("res://scenes/ui/CustomerCard.tscn")
var current_queue: Array = []

func _ready():
	populate_queue()

	# Connect popup signals (Feature 3.3)
	var popup = get_node("/root/Main/CustomerPopup")
	popup.customer_accepted.connect(_on_customer_accepted)
	popup.customer_refused.connect(_on_customer_refused)

	# Connect examination screen signals (Feature 4.1)
	var examination_screen = get_node("/root/Main/Workspace/ExaminationScreen")
	if examination_screen:
		examination_screen.examination_skipped.connect(_on_examination_skipped)

func populate_queue():
	"""Generate and display 7-10 customer cards"""
	# Clear existing cards
	for child in card_container.get_children():
		child.queue_free()

	# Generate daily queue from CustomerData
	current_queue = CustomerData.generate_daily_queue(GameState.current_day)

	# Create card for each customer
	var card_index = 0
	for customer in current_queue:
		var card = card_scene.instantiate()
		card_container.add_child(card)

		# Populate card data
		card.set_customer_data(customer)

		# Connect click signal
		card.card_clicked.connect(_on_customer_card_clicked)

		# Feature 3.5: Check relationship status for recurring customers
		if customer.get("is_recurring", false):
			var customer_name = customer.get("name", "")
			var relationship_status = CustomerData.get_relationship_status(customer_name)

			# Check if relationship is damaged
			var max_relationship = CustomerData.recurring_customers[customer_name].refusal_tolerance
			if relationship_status < max_relationship and relationship_status > 0:
				# Warning state (damaged but not broken)
				card.set_warning_state()
			elif relationship_status == 0:
				# Broken relationship (shouldn't appear, but handle edge case)
				card.set_relationship_broken_state()

		# Feature 3.6: Fade-in cascade animation
		card.modulate.a = 0.0  # Start invisible
		var tween = create_tween()
		tween.tween_property(card, "modulate:a", 1.0, 0.3).set_delay(card_index * 0.1)

		card_index += 1

func _on_customer_card_clicked(customer_data: Dictionary):
	"""Handle customer card click - open popup"""
	var popup = get_node("/root/Main/CustomerPopup")
	popup.show_popup(customer_data)

func refresh_queue():
	"""Refresh the queue (called when day advances)"""
	populate_queue()

# Feature 3.3: Accept/Refuse Logic
func _on_customer_accepted(customer_data: Dictionary):
	"""Handle customer acceptance"""
	# Add to game state
	GameState.accept_customer(customer_data)

	# Update card visual
	var card = find_card_by_name(customer_data.get("name", ""))
	if card:
		card.set_accepted()

	# Get appropriate text ID for difficulty
	var difficulty = customer_data.get("difficulty", "Easy")
	var text_id = GameState.get_text_id_for_difficulty(difficulty)

	# Feature 4.1: Show examination screen before translation
	var examination_screen = get_node("/root/Main/Workspace/ExaminationScreen")
	var translation_display = get_node("/root/Main/Workspace/TranslationDisplay")

	if examination_screen:
		# Hide translation, show examination
		translation_display.visible = false
		examination_screen.load_book(customer_data, text_id)
	else:
		# Fallback if examination screen not available
		translation_display.load_text_for_customer(text_id, customer_data.get("name", ""))

	# Update dialogue box
	var dialogue_box = get_node("/root/Main/DialogueBox")
	if dialogue_box.has_method("show_accept_dialogue"):
		dialogue_box.show_accept_dialogue(customer_data)

	# Feature 3.4: Check if capacity full → update cards, then auto-refuse remaining
	if GameState.capacity_used >= GameState.max_capacity:
		update_cards_for_capacity_full()
		auto_refuse_remaining()

func _on_customer_refused(customer_data: Dictionary):
	"""Handle customer refusal"""
	# Add to game state
	GameState.refuse_customer(customer_data)

	# Update card visual
	var card = find_card_by_name(customer_data.get("name", ""))
	if card:
		card.set_refused()

	# Feature 3.5: Check relationship damage for recurring customers
	if customer_data.get("is_recurring", false):
		var customer_name = customer_data.get("name", "")
		var relationship_status = CustomerData.get_relationship_status(customer_name)

		if relationship_status == 1:
			# Warning state: one more refusal breaks relationship
			card.set_warning_state()
		elif relationship_status == 0:
			# Broken relationship
			card.set_relationship_broken_state()

	# Update dialogue box
	var dialogue_box = get_node("/root/Main/DialogueBox")
	if dialogue_box.has_method("show_refuse_dialogue"):
		dialogue_box.show_refuse_dialogue(customer_data)

func find_card_by_name(customer_name: String):
	"""Find card instance by customer name"""
	for card in card_container.get_children():
		if card.customer_data.get("name", "") == customer_name:
			return card
	return null

func auto_refuse_remaining():
	"""Auto-refuse all remaining non-accepted customers when capacity full"""
	# Wait a moment before starting cascade
	await get_tree().create_timer(0.3).timeout

	# Find all cards that aren't accepted or refused
	var remaining_cards = []
	for card in card_container.get_children():
		if not card.is_accepted and not card.is_refused:
			remaining_cards.append(card)

	# Pulse red border on all remaining cards
	for card in remaining_cards:
		pulse_red_border(card)

	# Wait for pulse to finish
	await get_tree().create_timer(0.5).timeout

	# Cascade refuse with delay
	for card in remaining_cards:
		card.set_refused()
		GameState.refuse_customer(card.customer_data)
		await get_tree().create_timer(0.2).timeout

	# Show capacity full message
	var dialogue_box = get_node("/root/Main/DialogueBox")
	if dialogue_box.has_method("show_capacity_full_message"):
		dialogue_box.show_capacity_full_message()

func pulse_red_border(card):
	"""Pulse red border animation on card"""
	var original_style = card.get_theme_stylebox("panel")
	var pulse_style = original_style.duplicate()
	pulse_style.border_color = Color("#FF0000")
	pulse_style.border_width_left = 4
	pulse_style.border_width_top = 4
	pulse_style.border_width_right = 4
	pulse_style.border_width_bottom = 4

	# Flash to red
	card.add_theme_stylebox_override("panel", pulse_style)
	await get_tree().create_timer(0.25).timeout

	# Flash back
	card.add_theme_stylebox_override("panel", original_style)
	await get_tree().create_timer(0.25).timeout

# Feature 3.4: Update cards when capacity becomes full
func update_cards_for_capacity_full():
	"""Apply capacity full visual state to all remaining cards"""
	for card in card_container.get_children():
		if not card.is_accepted and not card.is_refused:
			card.set_capacity_full_state()

# Feature 4.1: Examination Screen Completion
func _on_examination_skipped(text_id: int, customer_name: String):
	"""Handle examination completion - proceed to translation"""
	var examination_screen = get_node("/root/Main/Workspace/ExaminationScreen")
	var translation_display = get_node("/root/Main/Workspace/TranslationDisplay")

	# Show translation workspace
	translation_display.load_text_for_customer(text_id, customer_name)
	translation_display.visible = true

	# Fade in translation
	translation_display.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(translation_display, "modulate:a", 1.0, 0.3)
