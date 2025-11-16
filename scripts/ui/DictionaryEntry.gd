# DictionaryEntry.gd
# Feature 2.4: Dictionary Auto-Fill System
# Individual dictionary entry showing symbol → word mapping
extends PanelContainer

@onready var symbol_label = $HBoxContainer/SymbolBackground/SymbolLabel
@onready var word_label = $HBoxContainer/WordLabel
@onready var checkmark = $HBoxContainer/Checkmark

var is_learned: bool = false
var current_symbol: String = ""

func set_symbol(symbol: String):
	"""Set the symbol to display"""
	current_symbol = symbol
	symbol_label.text = symbol

func set_word(word):
	"""Set the English word (null = unknown)"""
	if word == null:
		word_label.text = "???"
		word_label.add_theme_color_override("font_color", Color("#999999"))
		checkmark.visible = false
	else:
		word_label.text = word
		word_label.add_theme_color_override("font_color", Color("#2ECC71"))
		checkmark.visible = true

func set_learned(learned: bool):
	"""Update visual state for learned symbols"""
	if learned == is_learned:
		return  # No change

	is_learned = learned

	if learned:
		# Green tint background
		var style = StyleBoxFlat.new()
		style.bg_color = Color("#1A3009")
		style.border_width_bottom = 1
		style.border_color = Color("#3A2518")
		add_theme_stylebox_override("panel", style)

		# Fade in animation
		modulate.a = 0
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.5)
	else:
		# Transparent background
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0)
		style.border_width_bottom = 1
		style.border_color = Color("#3A2518")
		add_theme_stylebox_override("panel", style)
		modulate.a = 1.0

func _on_mouse_entered():
	"""Hover highlight"""
	if not is_learned:
		# Lighten background slightly
		var style = get_theme_stylebox("panel").duplicate()
		style.bg_color = Color("#3A2A1F")
		add_theme_stylebox_override("panel", style)

func _on_mouse_exited():
	"""Remove hover highlight"""
	if not is_learned:
		# Return to transparent
		var style = get_theme_stylebox("panel").duplicate()
		style.bg_color = Color(0, 0, 0, 0)
		add_theme_stylebox_override("panel", style)
