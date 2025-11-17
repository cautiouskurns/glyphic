# MagnifyingGlassButton.gd
# Feature 3A.1: Interactive Desk Objects
# Triggers book examination panel instead of navigating away from shop
extends Button

@onready var tooltip = $Tooltip
@onready var lens = $Lens
@onready var lens_rim = $LensRim

var glow_overlay: Panel  # Created programmatically
var is_panel_open: bool = false
var panel_color: Color = Color("#3498DB")  # Blue for examination
var original_lens_color: Color
var hover_tween: Tween
var tooltip_timer: float = 0.0
var is_hovering: bool = false

# Signal for DiegeticScreenManager
signal object_clicked(screen_type: String)

func _ready():
	original_lens_color = lens.color

	# Remove old SceneManager navigation - now handled via signal
	# pressed.connect(SceneManager.goto_examination_screen)  # REMOVED

	# Connect new panel trigger
	pressed.connect(_on_clicked)
	mouse_entered.connect(_on_hover_start)
	mouse_exited.connect(_on_hover_end)

	# Initialize glow overlay (hidden by default)
	setup_glow_overlay()

	# Hide tooltip initially
	if tooltip:
		tooltip.visible = false

func _on_clicked():
	"""Emit signal to open/toggle panel"""
	object_clicked.emit("examination")
	# Hide tooltip when clicked
	if tooltip:
		tooltip.visible = false

func _on_hover_start():
	"""Brighten object and enhance lens on hover"""
	is_hovering = true
	tooltip_timer = 0.0

	if not is_panel_open:
		# Brighten button modulate
		if hover_tween:
			hover_tween.kill()
		hover_tween = create_tween()
		hover_tween.set_parallel(true)
		hover_tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.15), 0.1)

		# Make lens more visible on hover (keep original behavior)
		hover_tween.tween_property(lens, "color", Color(0.7, 0.85, 1, 0.6), 0.2)

func _on_hover_end():
	"""Return to normal on unhover"""
	is_hovering = false

	if not is_panel_open:
		if hover_tween:
			hover_tween.kill()
		hover_tween = create_tween()
		hover_tween.set_parallel(true)
		hover_tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)

		# Return lens to original transparency
		hover_tween.tween_property(lens, "color", original_lens_color, 0.2)

	# Hide tooltip
	if tooltip:
		tooltip.visible = false

func _process(delta):
	"""Handle tooltip delay"""
	if is_hovering and not is_panel_open:
		tooltip_timer += delta
		if tooltip_timer >= 0.3 and tooltip:
			show_tooltip()
	else:
		tooltip_timer = 0.0

func setup_glow_overlay():
	"""Create glow effect overlay"""
	glow_overlay = Panel.new()
	add_child(glow_overlay)
	move_child(glow_overlay, 0)  # Behind button content

	# Match button size
	glow_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow_overlay.visible = false

	# Create glow style
	var glow_style = StyleBoxFlat.new()
	glow_style.bg_color = Color(0, 0, 0, 0)  # Transparent center
	glow_style.border_width_left = 4
	glow_style.border_width_top = 4
	glow_style.border_width_right = 4
	glow_style.border_width_bottom = 4
	glow_style.border_color = Color(panel_color.r, panel_color.g, panel_color.b, 0.8)
	glow_style.shadow_size = 8
	glow_style.shadow_color = Color(panel_color.r, panel_color.g, panel_color.b, 0.4)
	glow_style.corner_radius_top_left = 6
	glow_style.corner_radius_top_right = 6
	glow_style.corner_radius_bottom_right = 6
	glow_style.corner_radius_bottom_left = 6

	glow_overlay.add_theme_stylebox_override("panel", glow_style)

func show_tooltip():
	"""Display tooltip above object"""
	if tooltip and not tooltip.visible:
		tooltip.visible = true
		tooltip.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(tooltip, "modulate:a", 1.0, 0.15)

# Public API (called by DiegeticScreenManager)

func set_panel_open(open: bool):
	"""Called when panel opens/closes"""
	is_panel_open = open

	if open:
		# Show glow
		glow_overlay.visible = true
		glow_overlay.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(glow_overlay, "modulate:a", 1.0, 0.2)
	else:
		# Hide glow
		var tween = create_tween()
		tween.tween_property(glow_overlay, "modulate:a", 0.0, 0.2)
		await tween.finished
		glow_overlay.visible = false
		modulate = Color(1, 1, 1)  # Reset brightness

		# Reset lens color
		lens.color = original_lens_color

func dim_inactive():
	"""Dim object when different panel is active"""
	if not is_panel_open:
		modulate = Color(0.8, 0.8, 0.8)

func restore_inactive():
	"""Restore brightness when other panel closes"""
	if not is_panel_open:
		modulate = Color(1, 1, 1)
