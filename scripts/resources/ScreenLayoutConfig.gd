# ScreenLayoutConfig.gd
# Resource defining layout parameters for individual screen content
extends Resource
class_name ScreenLayoutConfig

# Translation Screen Layout
@export_group("Translation Screen")
@export var text_display_height: int = 150
@export var text_display_margin_bottom: int = 20
@export var input_field_height: int = 40
@export var button_row_height: int = 50
@export var element_spacing: int = 10

# Examination Screen Layout
@export_group("Examination Screen")
@export var book_display_width: int = 400
@export var book_display_height: int = 500
@export var tool_button_size: int = 60
@export var tool_button_spacing: int = 15
@export var examination_padding: int = 20

# Dictionary Screen Layout
@export_group("Dictionary Screen")
@export var entry_height: int = 60
@export var entry_spacing: int = 5
@export var search_bar_height: int = 40
@export var dictionary_padding: int = 10

# Queue Screen Layout
@export_group("Queue Screen")
@export var customer_card_height: int = 120
@export var customer_card_spacing: int = 10
@export var queue_padding: int = 15

# Calculated helpers for Translation Screen
func get_total_translation_height() -> int:
	return text_display_height + text_display_margin_bottom + input_field_height + button_row_height + (element_spacing * 3)

# Calculated helpers for Examination Screen
func get_book_display_size() -> Vector2:
	return Vector2(book_display_width, book_display_height)

func get_tool_button_size() -> Vector2:
	return Vector2(tool_button_size, tool_button_size)
