# Feature 3A.3: Screen Panel Sliding (Diegetic Workspace Panels)

**Priority:** CRITICAL - Creates actual panel UI for diegetic workspace

**Tests Critical Question:** Q3 (Engaging texture) - Do sliding panels that "lay on the desk" feel more integrated and immersive than modal popups?

**Estimated Time:** 120 minutes

**Dependencies:**
- Feature 3A.1: Interactive Desk Objects (signals and glows)
- Feature 3A.2: Shop Workspace Zones (camera focus and panel zone)

---

## Overview

When a desk object is clicked, a panel slides in from the right edge and "lays down" on the desk surface in the defined panel zone. Panels appear as physical objects on the desk (like papers or folders) rather than floating UI. Multiple panels can be open simultaneously (max 3) with browser-style tabs at the top. Each panel type displays different content (queue, translation, dictionary, etc.).

**Critical Design Constraint:** Panels must feel like physical desk objects - they slide in smoothly, cast subtle shadows, and integrate with the desk aesthetic. They are not floating windows but rather work materials laid on the desk.

---

## What Player Sees

### **Panel Appearance:**

```
Panel Container (laying on desk):
  ┌─────────────────────────────────────┐
  │ [Tab: Queue] [X]                    │  ← Header bar (40px height)
  ├─────────────────────────────────────┤
  │                                     │
  │     Panel Content Area              │  ← Content (810px height)
  │     (Queue, Translation, etc.)      │
  │                                     │
  │     Specific to panel type          │
  │                                     │
  │                                     │
  └─────────────────────────────────────┘

Size: 1100px wide × 850px tall
Position: (800, 115) in focused view
Appears on brown desk surface
```

**Visual Styling:**

**Panel Background:**
- Color: `Color(0.95, 0.92, 0.88)` - Cream/aged paper
- Border: 2px solid `Color(0.3, 0.25, 0.2)` - Dark brown edge
- Corner radius: 4px
- Shadow: 12px blur, 6px offset, `Color(0, 0, 0, 0.5)` - Strong desk shadow

**Header Bar (40px tall):**
- Background: Panel color matching desk object
  - Queue: Brown `#A0826D`
  - Translation: Cream `#F4E8D8`
  - Dictionary: Green `#2D5016`
  - Examination: Blue `#3498DB`
  - Work: Gold `#FFD700`
- Tab Label: Panel name in white, 16pt font
- Close Button: [X] on far right, 30×30px, hover to red

**Content Area (810px tall):**
- Background: Same cream color as panel
- Padding: 20px all sides
- Scrollable if content overflows
- For now: Placeholder text "Panel content will go here"

### **Multiple Panels (Browser-Style Tabs):**

When 2+ panels open:
```
  ┌──────────┬──────────┬──────────┐
  │ Queue    │ Dict    ✓│ Trans   │  ← Active tab highlighted
  ├──────────┴──────────┴──────────┤
  │                                 │
  │  Dictionary content visible     │
  │  (other panels hidden behind)   │
  │                                 │
  └─────────────────────────────────┘

Tab Styling:
- Active tab: Full header color, white text
- Inactive tab: 70% opacity header color, grey text
- Click inactive tab → brings panel to front
- Max 3 tabs visible, horizontal scroll if more
```

---

## What Player Does

### **Opening First Panel:**

**Player action:** Click Diary desk object
**Visual response (0.4s total):**
1. **0.0s:** Camera shifts to focus mode (Feature 3A.2)
2. **0.1s:** Panel spawns at x=2100 (off-screen right)
3. **0.1-0.5s:** Panel slides left from 2100 → 800 (0.4s ease-out)
4. **0.5s:** Panel settles on desk, shadow fades in
5. **0.5s:** Diary button glows brown (Feature 3A.1)

**Result:** Queue panel visible in panel zone, desk objects still clickable

### **Opening Second Panel:**

**Player action:** Click Dictionary (while Queue panel open)
**Visual response:**
1. Queue panel shrinks slightly, tab appears at top
2. Dictionary panel slides in from right
3. Dictionary tab becomes active, Queue tab inactive
4. Dictionary button glows green
5. Both tabs visible at top

**Result:** Dictionary panel front, Queue panel behind, both tabs visible

### **Switching Between Panels:**

**Player action:** Click Queue tab
**Visual response (0.2s):**
1. Dictionary panel fades to 95% opacity
2. Queue panel fades to 100% opacity, moves to front (z-index)
3. Queue tab highlighted, Dictionary tab dimmed
4. Desk object glows update (Queue bright, Dictionary dim)

**Result:** Queue panel front, quick tab switch (no slide animation)

### **Closing Panel:**

**Player action:** Click [X] on active panel
**Visual response (0.3s):**
1. Panel slides right from 800 → 2100 (0.3s ease-in)
2. Panel fades out (0.3s)
3. Desk object glow clears
4. If last panel: Exit focus mode (Feature 3A.2)
5. If other panels open: Next panel becomes active

**Result:** Panel removed, workspace cleared or next panel shown

---

## Underlying Behavior

### **GDScript Structure (DiegeticPanel.gd - New Script):**

```gdscript
# DiegeticPanel.gd
# Feature 3A.3: Screen Panel Sliding
# Individual panel that slides onto desk workspace
extends PanelContainer

# Panel configuration
var panel_type: String  # "queue", "translation", "dictionary", "examination", "work"
var panel_title: String
var panel_color: Color
var is_active: bool = false

# Animation
var slide_tween: Tween
const SLIDE_DURATION = 0.4
const OFF_SCREEN_X = 2100
const ON_SCREEN_X = 800

# UI References
var header_bar: Panel
var tab_label: Label
var close_button: Button
var content_container: ScrollContainer
var content_area: VBoxContainer

# Signals
signal panel_closed(panel_type: String)
signal panel_focused(panel_type: String)

func _ready():
	"""Initialize panel appearance and UI"""
	setup_panel_style()
	setup_header()
	setup_content_area()

func setup_panel_style():
	"""Style panel as desk object (paper/folder)"""
	# Panel container styling
	size = Vector2(1100, 850)
	position = Vector2(OFF_SCREEN_X, 115)  # Start off-screen

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.95, 0.92, 0.88)  # Cream paper
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.3, 0.25, 0.2)  # Dark brown edge
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.shadow_size = 12
	panel_style.shadow_offset = Vector2(6, 6)
	panel_style.shadow_color = Color(0, 0, 0, 0.5)

	add_theme_stylebox_override("panel", panel_style)

func setup_header():
	"""Create header bar with tab and close button"""
	header_bar = Panel.new()
	header_bar.size = Vector2(1100, 40)
	header_bar.position = Vector2(0, 0)

	# Header color matches panel type (desk object color)
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = panel_color
	header_style.corner_radius_top_left = 4
	header_style.corner_radius_top_right = 4
	header_bar.add_theme_stylebox_override("panel", header_style)

	add_child(header_bar)

	# Tab label (panel name)
	tab_label = Label.new()
	tab_label.text = panel_title
	tab_label.position = Vector2(15, 10)
	tab_label.add_theme_color_override("font_color", Color(1, 1, 1))
	tab_label.add_theme_font_size_override("font_size", 16)
	header_bar.add_child(tab_label)

	# Close button [X]
	close_button = Button.new()
	close_button.text = "X"
	close_button.size = Vector2(30, 30)
	close_button.position = Vector2(1055, 5)
	close_button.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
	close_button.add_theme_font_size_override("font_size", 18)
	close_button.pressed.connect(_on_close_pressed)
	close_button.mouse_entered.connect(_on_close_hover)
	close_button.mouse_exited.connect(_on_close_unhover)
	header_bar.add_child(close_button)

func setup_content_area():
	"""Create scrollable content area"""
	content_container = ScrollContainer.new()
	content_container.size = Vector2(1060, 770)
	content_container.position = Vector2(20, 60)
	add_child(content_container)

	content_area = VBoxContainer.new()
	content_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.add_child(content_area)

	# Placeholder content (will be replaced by actual panel content)
	var placeholder = Label.new()
	placeholder.text = "Panel content will go here\n(Feature 3A.4 will populate this)"
	placeholder.add_theme_font_size_override("font_size", 18)
	content_area.add_child(placeholder)

func slide_in():
	"""Animate panel sliding in from right"""
	if slide_tween:
		slide_tween.kill()

	slide_tween = create_tween()
	slide_tween.set_ease(Tween.EASE_OUT)
	slide_tween.set_trans(Tween.TRANS_CUBIC)

	slide_tween.tween_property(self, "position:x", ON_SCREEN_X, SLIDE_DURATION)

func slide_out():
	"""Animate panel sliding out to right"""
	if slide_tween:
		slide_tween.kill()

	slide_tween = create_tween()
	slide_tween.set_parallel(true)
	slide_tween.set_ease(Tween.EASE_IN)
	slide_tween.set_trans(Tween.TRANS_CUBIC)

	slide_tween.tween_property(self, "position:x", OFF_SCREEN_X, 0.3)
	slide_tween.tween_property(self, "modulate:a", 0.0, 0.3)

	await slide_tween.finished
	queue_free()

func set_active(active: bool):
	"""Set panel as active (front) or inactive (background)"""
	is_active = active

	if active:
		z_index = 10
		modulate.a = 1.0
		header_bar.modulate.a = 1.0
	else:
		z_index = 5
		modulate.a = 0.95
		header_bar.modulate.a = 0.7

func _on_close_pressed():
	"""Handle close button click"""
	panel_closed.emit(panel_type)

func _on_close_hover():
	"""Red highlight on close button hover"""
	close_button.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))

func _on_close_unhover():
	"""Remove hover highlight"""
	close_button.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))

func _gui_input(event):
	"""Handle panel click to bring to front"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_active:
			panel_focused.emit(panel_type)
```

### **Scene Structure (DiegeticPanel.tscn):**

```
DiegeticPanel (PanelContainer) - Script: DiegeticPanel.gd
├── HeaderBar (Panel) - Colored header with panel type color
│   ├── TabLabel (Label) - Panel name
│   └── CloseButton (Button) - [X] button
└── ContentContainer (ScrollContainer) - Scrollable content
    └── ContentArea (VBoxContainer) - Actual panel content
```

### **Panel Manager Integration (ShopScene.gd additions):**

```gdscript
# ShopScene.gd
# Feature 3A.3: Panel management

var active_panels: Dictionary = {}  # {panel_type: DiegeticPanel}
var panel_stack: Array[String] = []  # Stack of panel types (for z-order)
const MAX_PANELS = 3

# Panel type to color mapping
const PANEL_COLORS = {
	"queue": Color("#A0826D"),       # Brown
	"translation": Color("#F4E8D8"),  # Cream
	"dictionary": Color("#2D5016"),   # Green
	"examination": Color("#3498DB"),  # Blue
	"work": Color("#FFD700")          # Gold
}

const PANEL_TITLES = {
	"queue": "Customer Queue",
	"translation": "Translation Workspace",
	"dictionary": "Glyph Dictionary",
	"examination": "Book Examination",
	"work": "Current Work"
}

func _on_desk_object_clicked(screen_type: String):
	"""Handle desk object click - open or focus panel"""
	if not is_focused_mode:
		enter_focus_mode()

	# Check if panel already open
	if active_panels.has(screen_type):
		bring_panel_to_front(screen_type)
	else:
		open_panel(screen_type)

func open_panel(panel_type: String):
	"""Create and slide in new panel"""
	if active_panels.size() >= MAX_PANELS:
		print("Maximum panels open (%d)" % MAX_PANELS)
		return

	# Create panel instance
	var panel = preload("res://scenes/ui/DiegeticPanel.tscn").instantiate()
	panel.panel_type = panel_type
	panel.panel_title = PANEL_TITLES[panel_type]
	panel.panel_color = PANEL_COLORS[panel_type]

	# Connect signals
	panel.panel_closed.connect(_on_panel_closed)
	panel.panel_focused.connect(bring_panel_to_front)

	# Add to scene
	add_child(panel)
	active_panels[panel_type] = panel
	panel_stack.append(panel_type)

	# Slide in animation
	panel.slide_in()
	panel.set_active(true)

	# Update desk object glows
	update_desk_object_glows()

func bring_panel_to_front(panel_type: String):
	"""Bring existing panel to front"""
	if not active_panels.has(panel_type):
		return

	# Remove from stack and re-add to top
	panel_stack.erase(panel_type)
	panel_stack.append(panel_type)

	# Update z-index for all panels
	for i in range(panel_stack.size()):
		var type = panel_stack[i]
		var panel = active_panels[type]
		panel.set_active(i == panel_stack.size() - 1)  # Last is active

	# Update desk object glows
	update_desk_object_glows()

func _on_panel_closed(panel_type: String):
	"""Handle panel close"""
	if not active_panels.has(panel_type):
		return

	var panel = active_panels[panel_type]

	# Slide out animation
	panel.slide_out()

	# Remove from tracking
	active_panels.erase(panel_type)
	panel_stack.erase(panel_type)

	# If no panels left, exit focus mode
	if active_panels.size() == 0:
		exit_focus_mode()
	else:
		# Bring next panel to front
		var next_type = panel_stack[panel_stack.size() - 1]
		bring_panel_to_front(next_type)

	# Update desk object glows
	update_desk_object_glows()

func update_desk_object_glows():
	"""Update desk object glows based on open panels"""
	# Clear all glows first
	diary_button.set_panel_open(false)
	papers_button.set_panel_open(false)
	dictionary_button.set_panel_open(false)
	magnifying_glass_button.set_panel_open(false)
	bell_button.set_panel_open(false)

	# Set glows for open panels
	for panel_type in active_panels.keys():
		match panel_type:
			"queue":
				diary_button.set_panel_open(true)
			"translation":
				papers_button.set_panel_open(true)
			"dictionary":
				dictionary_button.set_panel_open(true)
			"examination":
				magnifying_glass_button.set_panel_open(true)
			"work":
				bell_button.set_panel_open(true)
```

---

## Acceptance Criteria

### **Visual Checks:**
- [ ] Panel spawns off-screen at x=2100
- [ ] Panel slides in smoothly over 0.4s (ease-out)
- [ ] Panel settles at position (800, 115)
- [ ] Panel appears on brown desk surface (looks like laying on desk)
- [ ] Panel has cream paper background color
- [ ] Panel has 2px dark brown border
- [ ] Panel casts shadow (12px blur, 6px offset)
- [ ] Header bar matches desk object color
- [ ] Close button [X] visible on far right of header
- [ ] Content area scrollable if content overflows

### **Interaction Checks (Single Panel):**
- [ ] Click desk object → Panel slides in from right
- [ ] Click [X] → Panel slides out to right and fades
- [ ] Click [X] on last panel → Exit focus mode
- [ ] Hover [X] → Button turns red
- [ ] Panel slide animation smooth (no jitter)
- [ ] Desk object glows while panel open

### **Multiple Panel Checks:**
- [ ] Open 2 panels → Both tabs visible at top
- [ ] Active panel has full-color header
- [ ] Inactive panels have 70% opacity headers
- [ ] Click inactive tab → Panel comes to front (0.2s)
- [ ] Click inactive tab → z-index updates correctly
- [ ] Max 3 panels enforced (4th click ignored or shows message)
- [ ] Close active panel → Next panel becomes active
- [ ] Close all panels → Exit focus mode

### **Integration Checks (Feature 3A.1/3A.2):**
- [ ] Panel opens only after focus mode enters
- [ ] Desk objects remain clickable while panel open
- [ ] Desk object glows update correctly
- [ ] Multiple desk objects can glow simultaneously
- [ ] ESC closes all panels and exits focus mode
- [ ] Click dimmed bookshelf → Closes all panels

### **Panel Content Checks:**
- [ ] Queue panel: Shows placeholder content
- [ ] Translation panel: Shows placeholder content
- [ ] Dictionary panel: Shows placeholder content
- [ ] Examination panel: Shows placeholder content
- [ ] Work panel: Shows placeholder content
- [ ] Content area properly sized (1060×770)
- [ ] Content scrollable if needed

### **Edge Case Checks:**
- [ ] Opening same panel twice → Brings to front, doesn't duplicate
- [ ] Rapid panel switching → No animation glitches
- [ ] Close panel during slide-in → Completes gracefully
- [ ] Click desk object during panel slide → Queues correctly
- [ ] Window resize doesn't break panel positioning
- [ ] Panel z-index never conflicts

---

## Manual Test Script

### **1. Test single panel open:**
```
- Click Diary desk object
- Observe: Camera shifts to focus mode (Feature 3A.2)
- Observe: Queue panel slides in from right over 0.4s
- Observe: Panel settles at position (800, 115)
- Verify: Panel has brown header bar
- Verify: Panel shows placeholder content
- Verify: Diary button glows brown
- Screenshot: "3A3_single_panel.png"
```

### **2. Test panel close:**
```
- With Queue panel open, click [X] button
- Observe: Panel slides right and fades over 0.3s
- Observe: Diary glow clears
- Observe: Focus mode exits (camera returns)
- Verify: Clean panel removal, no errors
```

### **3. Test multiple panels:**
```
- Click Diary (Queue panel opens)
- Click Dictionary (Dictionary panel opens)
- Verify: Both tabs visible at top of panel
- Verify: Dictionary tab active (full color)
- Verify: Queue tab inactive (70% opacity)
- Verify: Dictionary button glows green
- Verify: Diary button still glows brown
- Screenshot: "3A3_two_panels.png"
```

### **4. Test tab switching:**
```
- With Queue and Dictionary panels open
- Click Queue tab
- Observe: Panels switch over 0.2s
- Verify: Queue panel now front
- Verify: Queue tab active, Dictionary tab inactive
- Verify: No slide animation (just z-index change)
```

### **5. Test close non-active panel:**
```
- Have Queue (active) and Dictionary (background) open
- Click [X] on Dictionary tab
- Verify: Dictionary panel closes
- Verify: Queue panel remains active
- Verify: Dictionary button glow clears
- Verify: Diary button still glows
```

### **6. Test max panels:**
```
- Open Diary, Dictionary, Papers panels (3 total)
- Try to click Magnifying Glass (4th panel)
- Verify: No new panel opens (or shows warning)
- Verify: Existing panels unaffected
```

### **7. Test ESC with panels:**
```
- Have 2 panels open
- Press ESC
- Verify: All panels close
- Verify: All glows clear
- Verify: Focus mode exits
- Verify: Clean return to default shop view
```

### **8. Test rapid interactions:**
```
- Quickly click Diary → Dictionary → Papers → Queue
- Verify: Panels queue correctly
- Verify: Final state: Queue panel active
- Verify: All clicked objects glow
- Verify: No animation glitches
```

### **9. Pass criteria:**
Panels slide smoothly, tabs work correctly, desk objects glow appropriately, max 3 panels enforced, ESC closes all panels.

---

## Known Simplifications

**Phase 3A shortcuts:**
- No panel minimize/maximize (just close)
- No panel drag-to-reorder tabs
- No panel resize (fixed 1100×850)
- Simple tab overflow (no scroll if >3)
- Placeholder content only (real content in Feature 3A.4)

**Technical debt:**
- Panel positions hardcoded (should adapt to panel zone)
  - **Impact:** Breaks if panel zone changes
- Panel colors hardcoded in ShopScene (duplicates Feature 3A.1)
  - **Impact:** Color changes need updates in 2 places
- Max panels fixed at 3 (should be configurable)
  - **Impact:** Can't easily increase/decrease limit
- Tab width fixed (doesn't shrink for many tabs)
  - **Impact:** 4+ tabs would overflow

**Future enhancements:**
- Smooth tab reordering (drag tabs)
- Panel stacking with slight offset (3D depth)
- Panel content fade-in animation
- Notification badges on inactive tabs
- Sound effects (paper rustle on slide)

---

## Integration Points

### **Connects to Feature 3A.1 (Interactive Desk Objects):**
- Desk object signals trigger panel opening
- `set_panel_open()` called based on active panels
- Glow colors match panel header colors

### **Connects to Feature 3A.2 (Shop Workspace Zones):**
- Panels appear in defined panel zone (800, 115)
- Panels only open when focus mode active
- ESC closes panels and exits focus mode
- Panels positioned using `get_panel_zone_rect()`

### **Connects to Feature 3A.4 (Diegetic Screen Manager):**
- Panel content areas populated by manager
- Panel types route to correct content screens
- Manager handles panel lifecycle (create/destroy)
- Manager implements panel-specific logic (queue, translation, etc.)

---

## Visual Reference

### **Panel Animation Sequence:**

```
SLIDE IN (0.4s):
  Frame 0.0s: x=2100 (off-screen right)
              └───────────┐
                          │ Panel │
                          └───────┘

  Frame 0.2s: x=1450 (halfway)
          ┌───────────┐
          │ Panel     │
          └───────────┘

  Frame 0.4s: x=800 (on-screen, settled)
  ┌───────────┐
  │ Panel     │
  │ Content   │
  └───────────┘

SLIDE OUT (0.3s):
  Frame 0.0s: x=800, alpha=1.0
  Frame 0.15s: x=1450, alpha=0.5
  Frame 0.3s: x=2100, alpha=0.0, queue_free()
```

### **Color Reference:**

```gdscript
# Panel styling
PANEL_BG = Color(0.95, 0.92, 0.88)  # Cream paper
PANEL_BORDER = Color(0.3, 0.25, 0.2)  # Dark brown
PANEL_SHADOW = Color(0, 0, 0, 0.5)  # Strong shadow

# Header colors (match desk objects from Feature 3A.1)
QUEUE_HEADER = Color("#A0826D")       # Brown
TRANSLATION_HEADER = Color("#F4E8D8")  # Cream
DICTIONARY_HEADER = Color("#2D5016")   # Green
EXAMINATION_HEADER = Color("#3498DB")  # Blue
WORK_HEADER = Color("#FFD700")         # Gold
```

---

## Next Step

After Feature 3A.3 is complete, proceed to **Feature 3A.4: Diegetic Screen Manager** to populate panel content areas with actual game screens (queue, translation, dictionary, etc.).
