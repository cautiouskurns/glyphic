# QueueScreen.gd
# Feature 3A.4: Customer Queue Screen - panel-compatible
# Adapted from CustomerQueuePanel.gd
extends Control

# Panel mode flag (kept for compatibility, but layout is now in .tscn)
var panel_mode: bool = false

# UI References (now from scene tree)
@onready var background_panel = $BackgroundPanel
@onready var capacity_label = $MarginContainer/MainVBox/CapacityLabel
@onready var card_container = $MarginContainer/MainVBox/ScrollContainer/CardContainer
@onready var scroll_container = $MarginContainer/MainVBox/ScrollContainer
@onready var placeholder_card = $MarginContainer/MainVBox/ScrollContainer/CardContainer/PlaceholderCard

# Card scene
var card_scene = preload("res://scenes/ui/CustomerCard.tscn")
var current_queue: Array = []

# Signals
signal customer_selected(customer_data: Dictionary)
signal accept_customer(customer_data: Dictionary)

func _ready():
	"""Initialize queue screen"""
	# Hide placeholder card (used for editor visualization only)
	if placeholder_card:
		placeholder_card.visible = false

	# Connect to capacity changes
	GameState.capacity_changed.connect(_on_capacity_changed)

	# Connect to day changes to refresh queue
	GameState.day_advanced.connect(_on_day_advanced)

	# Wait for layout to be calculated before populating
	await get_tree().process_frame
	await get_tree().process_frame  # Wait two frames to ensure layout is done
	initialize()

func initialize():
	"""Called when panel opens - load current game state"""
	populate_queue()
	update_capacity_label()

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
		# Single column - cards are now 200×150, use at full scale
		var card_wrapper = CenterContainer.new()
		card_wrapper.custom_minimum_size = Vector2(310, 150)
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
	update_capacity_label()

func update_capacity_label():
	"""Update capacity display"""
	if not capacity_label:
		return

	var used = GameState.capacity_used
	var max_cap = GameState.max_capacity
	var remaining = max_cap - used

	capacity_label.text = "Capacity: %d/%d" % [used, max_cap]

	# Color code based on usage
	if used >= max_cap:
		capacity_label.add_theme_color_override("font_color", Color("#2D5016"))  # Green - full
	elif remaining <= 1:
		capacity_label.add_theme_color_override("font_color", Color("#FF8C00"))  # Orange - almost full
	else:
		capacity_label.add_theme_color_override("font_color", Color("#888888"))  # Gray - plenty of room

func _on_capacity_changed():
	"""Handle capacity change"""
	update_capacity_label()

func _on_day_advanced():
	"""Refresh queue when day advances"""
	refresh()
