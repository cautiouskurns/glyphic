# DictionaryEntry.gd
# Enhanced dictionary entry with lined paper aesthetic
# Shows symbol with rich metadata: certainty, category, source, aliases
extends PanelContainer

@onready var symbol_label = $VBoxContainer/HeaderRow/SymbolIconPanel/SymbolLabel
@onready var title_label = $VBoxContainer/HeaderRow/InfoContainer/TitleLabel
@onready var certainty_badge = $VBoxContainer/HeaderRow/InfoContainer/BadgesRow/CertaintyBadge
@onready var certainty_label = $VBoxContainer/HeaderRow/InfoContainer/BadgesRow/CertaintyBadge/CertaintyLabel
@onready var category_tag = $VBoxContainer/HeaderRow/InfoContainer/BadgesRow/CategoryTag
@onready var category_label = $VBoxContainer/HeaderRow/InfoContainer/BadgesRow/CategoryTag/CategoryLabel
@onready var source_label = $VBoxContainer/MetadataRow/SourceLabel
@onready var date_label = $VBoxContainer/MetadataRow/DateLabel
@onready var aliases_container = $VBoxContainer/AliasesRow/AliasesContainer
@onready var metadata_row = $VBoxContainer/MetadataRow
@onready var aliases_row = $VBoxContainer/AliasesRow

var current_symbol: String = ""
var is_learned: bool = false

# StyleBox for alias badges
var alias_badge_style: StyleBoxFlat

func _ready():
	# Create alias badge style
	alias_badge_style = StyleBoxFlat.new()
	alias_badge_style.bg_color = Color(0.9, 0.85, 0.8, 1)
	alias_badge_style.corner_radius_top_left = 12
	alias_badge_style.corner_radius_top_right = 12
	alias_badge_style.corner_radius_bottom_right = 12
	alias_badge_style.corner_radius_bottom_left = 12
	alias_badge_style.content_margin_left = 10.0
	alias_badge_style.content_margin_top = 5.0
	alias_badge_style.content_margin_right = 10.0
	alias_badge_style.content_margin_bottom = 5.0

func set_symbol_data(symbol: String, entry_data: Dictionary):
	"""Set all dictionary entry data from SymbolData"""
	current_symbol = symbol
	symbol_label.text = symbol

	# Check if learned
	is_learned = entry_data.word != null

	if is_learned:
		# Show learned state
		title_label.text = entry_data.word.capitalize()

		# Set certainty badge
		certainty_badge.visible = true
		var certainty_text = SymbolData.get_certainty_level(entry_data.confidence)
		var certainty_color = SymbolData.get_certainty_color(entry_data.confidence)
		certainty_label.text = certainty_text
		var badge_style = certainty_badge.get_theme_stylebox("panel").duplicate()
		badge_style.bg_color = certainty_color
		certainty_badge.add_theme_stylebox_override("panel", badge_style)

		# Set category tag
		category_tag.visible = true
		category_label.text = entry_data.category
		var category_color = SymbolData.get_category_color(entry_data.category)
		category_label.add_theme_color_override("font_color", category_color)
		var tag_style = category_tag.get_theme_stylebox("panel").duplicate()
		tag_style.border_color = category_color
		category_tag.add_theme_stylebox_override("panel", tag_style)

		# Set source and date
		if entry_data.source != "":
			source_label.text = "Source: %s" % entry_data.source
		else:
			source_label.text = "Source: Unknown"

		if entry_data.day_added > 0:
			date_label.text = "Added Day %d" % entry_data.day_added
		else:
			date_label.text = "Added Day 1"

		# Create individual alias badges
		clear_aliases()
		if entry_data.aliases.size() > 0:
			for alias in entry_data.aliases:
				create_alias_badge(alias)
		else:
			# Show placeholder if no aliases
			var placeholder = Label.new()
			placeholder.text = "No aliases"
			placeholder.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4, 1))
			placeholder.add_theme_font_size_override("font_size", 13)
			aliases_container.add_child(placeholder)

		# Show all metadata
		metadata_row.visible = true
		aliases_row.visible = true

	else:
		# Show unknown state
		title_label.text = "???"
		title_label.add_theme_color_override("font_color", Color("#666666"))

		# Hide certainty and category
		certainty_badge.visible = false
		category_tag.visible = false

		# Hide metadata rows
		metadata_row.visible = false
		aliases_row.visible = false

		# Cream background for unknown (same as learned)
		var unknown_style = StyleBoxFlat.new()
		unknown_style.bg_color = Color(0.956863, 0.909804, 0.847059, 1)  # Cream color
		unknown_style.corner_radius_top_left = 8
		unknown_style.corner_radius_top_right = 8
		unknown_style.corner_radius_bottom_right = 8
		unknown_style.corner_radius_bottom_left = 8
		unknown_style.content_margin_left = 80.0
		unknown_style.content_margin_top = 20.0
		unknown_style.content_margin_right = 24.0
		unknown_style.content_margin_bottom = 20.0
		unknown_style.shadow_size = 4
		unknown_style.shadow_offset = Vector2(0, 2)
		unknown_style.shadow_color = Color(0, 0, 0, 0.15)
		add_theme_stylebox_override("panel", unknown_style)

func clear_aliases():
	"""Remove all alias badges"""
	for child in aliases_container.get_children():
		child.queue_free()

func create_alias_badge(alias_text: String):
	"""Create a pill-shaped badge for an alias"""
	var badge = PanelContainer.new()
	badge.add_theme_stylebox_override("panel", alias_badge_style)

	var label = Label.new()
	label.text = alias_text
	label.add_theme_color_override("font_color", Color(0.3, 0.25, 0.2, 1))
	label.add_theme_font_size_override("font_size", 13)

	badge.add_child(label)
	aliases_container.add_child(badge)

func _on_mouse_entered():
	"""Hover highlight"""
	if is_learned:
		# Lighten background on hover
		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = Color(0.98, 0.95, 0.9, 1)
		hover_style.corner_radius_top_left = 8
		hover_style.corner_radius_top_right = 8
		hover_style.corner_radius_bottom_right = 8
		hover_style.corner_radius_bottom_left = 8
		hover_style.content_margin_left = 80.0
		hover_style.content_margin_top = 20.0
		hover_style.content_margin_right = 24.0
		hover_style.content_margin_bottom = 20.0
		hover_style.shadow_size = 6
		hover_style.shadow_offset = Vector2(0, 3)
		hover_style.shadow_color = Color(0, 0, 0, 0.25)
		add_theme_stylebox_override("panel", hover_style)

func _on_mouse_exited():
	"""Remove hover highlight"""
	if is_learned:
		# Return to normal
		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color = Color(0.956863, 0.909804, 0.847059, 1)
		normal_style.corner_radius_top_left = 8
		normal_style.corner_radius_top_right = 8
		normal_style.corner_radius_bottom_right = 8
		normal_style.corner_radius_bottom_left = 8
		normal_style.content_margin_left = 80.0
		normal_style.content_margin_top = 20.0
		normal_style.content_margin_right = 24.0
		normal_style.content_margin_bottom = 20.0
		normal_style.shadow_size = 4
		normal_style.shadow_offset = Vector2(0, 2)
		normal_style.shadow_color = Color(0, 0, 0, 0.15)
		add_theme_stylebox_override("panel", normal_style)

# Legacy methods for compatibility with old system
func set_symbol(symbol: String):
	"""Legacy method - use set_symbol_data instead"""
	current_symbol = symbol
	symbol_label.text = symbol

func set_word(word):
	"""Legacy method - use set_symbol_data instead"""
	if word != null:
		title_label.text = word.capitalize()
	else:
		title_label.text = "???"

func set_learned(learned: bool):
	"""Legacy method - use set_symbol_data instead"""
	is_learned = learned
