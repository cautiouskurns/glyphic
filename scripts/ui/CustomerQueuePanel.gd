# CustomerQueuePanel.gd
# Feature 3.1: Customer Queue Display
# Manages the customer queue in the left panel
extends Panel

@onready var card_container = $ScrollContainer/VBoxContainer

var card_scene = preload("res://scenes/ui/CustomerCard.tscn")
var current_queue: Array = []

func _ready():
	populate_queue()

func populate_queue():
	"""Generate and display 7-10 customer cards"""
	# Clear existing cards
	for child in card_container.get_children():
		child.queue_free()

	# Generate daily queue from CustomerData
	current_queue = CustomerData.generate_daily_queue(GameState.current_day)

	# Create card for each customer
	for customer in current_queue:
		var card = card_scene.instantiate()
		card_container.add_child(card)

		# Populate card data
		card.set_customer_data(customer)

		# Connect click signal
		card.card_clicked.connect(_on_customer_card_clicked)

func _on_customer_card_clicked(customer_data: Dictionary):
	"""Handle customer card click - open popup"""
	var popup = get_node("/root/Main/CustomerPopup")
	popup.show_popup(customer_data)

func refresh_queue():
	"""Refresh the queue (called when day advances)"""
	populate_queue()
