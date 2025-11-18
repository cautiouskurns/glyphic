# QueueScreen.gd
# Feature 3A.4: Customer Queue Screen - panel-compatible
# Adapted from CustomerQueuePanel.gd
extends Control

# Panel mode flag
var panel_mode: bool = false

# UI References
var card_container: GridContainer
var scroll_container: ScrollContainer

# Card scene
var card_scene = preload("res://scenes/ui/CustomerCard.tscn")
var current_queue: Array = []

# Signals
signal customer_selected(customer_data: Dictionary)
signal accept_customer(customer_data: Dictionary)

func _ready():
	"""Initialize queue screen"""
	if panel_mode:
		setup_panel_layout()
	else:
		setup_fullscreen_layout()

	# Wait for layout to be calculated before populating
	await get_tree().process_frame
	await get_tree().process_frame  # Wait two frames to ensure layout is done
	initialize()

func setup_panel_layout():
	"""Create compact layout for panel display (450×650px panel)"""
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	# CRITICAL: Set explicit minimum size to match panel content area
	custom_minimum_size = Vector2(420, 590)

	# Margin container for top spacing
	var margin = MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_top", 35)
	add_child(margin)

	# Scroll container for customer cards
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.custom_minimum_size = Vector2(420, 575)
	margin.add_child(scroll_container)

	# Grid container for cards (1 column in panel mode)
	card_container = GridContainer.new()
	card_container.columns = 1
	card_container.add_theme_constant_override("h_separation", 6)
	card_container.add_theme_constant_override("v_separation", 15)
	card_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(card_container)

func setup_fullscreen_layout():
	"""Create full-screen layout (if needed)"""
	# Use same layout as panel mode
	setup_panel_layout()

func initialize():
	"""Called when panel opens - load current game state"""
	populate_queue()

func populate_queue():
	"""Generate and display customer cards from GameState"""
	# Clear existing cards
	for child in card_container.get_children():
		child.queue_free()

	# Get queue from GameState (use test customers for now)
	current_queue = GameState.customer_queue.duplicate()

	if current_queue.is_empty():
		# Show empty message
		var empty_label = Label.new()
		empty_label.text = "No customers waiting"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 18)
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		card_container.add_child(empty_label)
		return

	# Create card for each customer
	var card_index = 0
	for customer in current_queue:
		# Single column - cards are now 300×150, use at full scale
		var card_wrapper = CenterContainer.new()
		card_wrapper.custom_minimum_size = Vector2(420, 150)
		card_wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_container.add_child(card_wrapper)

		var card = card_scene.instantiate()
		if card == null:
			push_error("Failed to instantiate card scene!")
			continue

		card_wrapper.add_child(card)

		# Use full scale since cards are already sized appropriately
		card.scale = Vector2(1.0, 1.0)

		# Populate card data
		card.set_customer_data(customer)

		# Connect click signal
		card.card_clicked.connect(_on_customer_card_clicked)

		# Make visible immediately
		card_wrapper.modulate.a = 1.0

		card_index += 1

func _on_customer_card_clicked(customer_data: Dictionary):
	"""Handle customer card click"""
	print("QueueScreen: Customer clicked: %s" % customer_data.get("name", "Unknown"))
	customer_selected.emit(customer_data)
	# For now, just emit - popup handling will be added later

func refresh():
	"""Refresh the queue display"""
	populate_queue()
