# PanelLayoutConfig.gd
# Resource defining layout parameters for diegetic panels
extends Resource
class_name PanelLayoutConfig

# Panel dimensions
@export_group("Panel Size")
@export var panel_width: int = 520
@export var panel_height: int = 750

# Header dimensions
@export_group("Header")
@export var header_height: int = 35
@export var title_padding_left: int = 12
@export var close_button_offset_right: int = 38
@export var close_button_size: int = 28

# Content area
@export_group("Content Area")
@export var content_padding_horizontal: int = 20  # Left/right margins
@export var content_padding_vertical: int = 20     # Top/bottom margins
@export var content_top_offset: int = 55           # Distance from top (below header)

# Calculated properties (auto-computed from exported values)
func get_content_width() -> int:
	return panel_width - (content_padding_horizontal * 2)

func get_content_height() -> int:
	return panel_height - content_top_offset - content_padding_vertical

func get_close_button_position() -> Vector2:
	return Vector2(panel_width - close_button_offset_right, 4)

func get_content_position() -> Vector2:
	return Vector2(content_padding_horizontal, content_top_offset)
