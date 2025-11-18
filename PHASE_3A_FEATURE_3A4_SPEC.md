# Feature 3A.4: Diegetic Screen Manager
**Phase 3A - Diegetic UI System**

## Executive Summary
The Diegetic Screen Manager populates panels with actual game screens, transforming empty panel containers into functional workspaces. Each panel type displays its corresponding screen content (queue cards, translation interface, dictionary entries, etc.) within the diegetic panel framework.

This feature bridges the old scene-based navigation system with the new diegetic panel system, allowing game screens to exist as content within desk panels rather than as separate scenes.

---

## Visual Requirements

### Panel Content Types

#### 1. **Queue Panel** (Customer Queue Screen)
```
╔════════════════════════════════════════╗
║ Customer Queue                      [X]║
╠════════════════════════════════════════╣
║                                        ║
║  ┌──────────────────────────────┐     ║
║  │ Customer #1                  │     ║
║  │ Book: "Ancient Glyphs Vol 3" │     ║
║  │ Status: Waiting              │     ║
║  │              [View Request]  │     ║
║  └──────────────────────────────┘     ║
║                                        ║
║  ┌──────────────────────────────┐     ║
║  │ Customer #2                  │     ║
║  │ Book: "Tome of Mysteries"    │     ║
║  │ Status: In Progress          │     ║
║  │              [View Request]  │     ║
║  └──────────────────────────────┘     ║
║                                        ║
║  [Accept Next Customer]                ║
║                                        ║
╚════════════════════════════════════════╝
```

#### 2. **Translation Panel** (Translation Workspace)
```
╔════════════════════════════════════════╗
║ Translation Workspace               [X]║
╠════════════════════════════════════════╣
║                                        ║
║  Current Book: "Ancient Glyphs"        ║
║  Page 3/50                             ║
║                                        ║
║  Source Text:                          ║
║  ┌────────────────────────────────┐   ║
║  │ ⚡︎ ☽ ◈ ✦ ⚔                   │   ║
║  └────────────────────────────────┘   ║
║                                        ║
║  Translation:                          ║
║  ┌────────────────────────────────┐   ║
║  │ [Type translation here]        │   ║
║  └────────────────────────────────┘   ║
║                                        ║
║  [Submit] [Skip] [Use Dictionary]      ║
║                                        ║
╚════════════════════════════════════════╝
```

#### 3. **Dictionary Panel** (Glyph Dictionary)
```
╔════════════════════════════════════════╗
║ Glyph Dictionary                    [X]║
╠════════════════════════════════════════╣
║                                        ║
║  Search: [____________] 🔍             ║
║                                        ║
║  Known Glyphs:                         ║
║  ┌────────────────────────────────┐   ║
║  │ ⚡︎  Lightning  (Common)         │   ║
║  │ ☽  Moon       (Common)         │   ║
║  │ ◈  Star       (Rare)           │   ║
║  │ ✦  Sparkle    (Rare)           │   ║
║  │ ⚔  Sword      (Uncommon)       │   ║
║  └────────────────────────────────┘   ║
║                                        ║
║  Unknown Glyphs: 45 remaining          ║
║                                        ║
╚════════════════════════════════════════╝
```

#### 4. **Examination Panel** (Book Examination)
```
╔════════════════════════════════════════╗
║ Book Examination                    [X]║
╠════════════════════════════════════════╣
║                                        ║
║  No book selected                      ║
║                                        ║
║  Click bell to ring for next customer  ║
║                                        ║
║                                        ║
╚════════════════════════════════════════╝
```

#### 5. **Work Panel** (Current Work Status)
```
╔════════════════════════════════════════╗
║ Current Work                        [X]║
╠════════════════════════════════════════╣
║                                        ║
║  Today's Progress:                     ║
║  - Customers Served: 3                 ║
║  - Books Translated: 2                 ║
║  - Earnings: $150                      ║
║                                        ║
║  Current Task:                         ║
║  "Ancient Glyphs Vol 3" - Page 3/50    ║
║                                        ║
║  [Resume Work] [End Day]               ║
║                                        ║
╚════════════════════════════════════════╝
```

---

## Interaction Flow

### Screen Loading Sequence

```
User clicks desk object (e.g., Diary)
         ↓
ShopScene receives object_clicked("queue")
         ↓
ShopScene calls open_panel("queue")
         ↓
DiegeticPanel created and configured
         ↓
DiegeticScreenManager.load_screen_into_panel("queue", panel)
         ↓
Screen content instantiated and added to panel.content_area
         ↓
Screen's _ready() initializes with current game state
         ↓
Panel slides in, showing populated content
```

### Screen Lifecycle

```
PANEL OPENS
  ↓
DiegeticScreenManager loads appropriate screen scene
  ↓
Screen instance added to panel's content_area
  ↓
Screen connects to GameState and updates display
  ↓
USER INTERACTS WITH SCREEN
  ↓
Screen emits signals (e.g., customer_selected, translation_submitted)
  ↓
DiegeticScreenManager handles signals, updates GameState
  ↓
PANEL CLOSES
  ↓
Screen instance cleaned up (queue_free)
  ↓
Panel slides out
```

---

## Technical Implementation

### Core Architecture

#### DiegeticScreenManager (New Singleton)
**Purpose:** Central manager for loading game screens into diegetic panels

**Responsibilities:**
- Load appropriate screen scene for each panel type
- Manage screen lifecycle (instantiation, cleanup)
- Handle screen-to-screen navigation
- Bridge screen signals to game state updates
- Coordinate multi-panel interactions

#### Screen Integration Pattern
Each existing game screen (QueueScreen, TranslationScreen, etc.) is converted to a **panel-compatible format**:
- Remove full-screen layout
- Adapt to smaller panel dimensions (600×620px content area)
- Emit signals instead of direct scene changes
- Work within content_area VBoxContainer

---

## Code Structure

### File: `scripts/DiegeticScreenManager.gd` (New Autoload)

```gdscript
# DiegeticScreenManager.gd
# Feature 3A.4: Manages screen content within diegetic panels
extends Node

# Screen scene paths
const SCREEN_SCENES = {
	"queue": "res://scenes/screens/QueueScreen.tscn",
	"translation": "res://scenes/screens/TranslationScreen.tscn",
	"dictionary": "res://scenes/screens/DictionaryScreen.tscn",
	"examination": "res://scenes/screens/ExaminationScreen.tscn",
	"work": "res://scenes/screens/WorkScreen.tscn"
}

# Track active screen instances
var active_screens: Dictionary = {}  # {panel_type: screen_instance}

# Signals for cross-screen communication
signal customer_accepted(customer_data: Dictionary)
signal translation_started(book_data: Dictionary)
signal translation_completed(book_data: Dictionary)
signal day_ended()

func load_screen_into_panel(panel_type: String, panel: Control):
	"""Load appropriate screen content into a panel"""
	if not SCREEN_SCENES.has(panel_type):
		push_error("Unknown panel type: %s" % panel_type)
		return

	# Load screen scene
	var screen_scene = load(SCREEN_SCENES[panel_type])
	var screen_instance = screen_scene.instantiate()

	# Configure for panel display
	screen_instance.panel_mode = true  # Tell screen it's in a panel
	screen_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	screen_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Add to panel's content area
	var content_area = panel.content_area
	# Clear placeholder content
	for child in content_area.get_children():
		child.queue_free()

	content_area.add_child(screen_instance)

	# Connect screen signals
	connect_screen_signals(panel_type, screen_instance)

	# Track active screen
	active_screens[panel_type] = screen_instance

	# Initialize screen with current game state
	if screen_instance.has_method("initialize"):
		screen_instance.initialize()

func unload_screen(panel_type: String):
	"""Clean up screen instance when panel closes"""
	if active_screens.has(panel_type):
		var screen = active_screens[panel_type]
		disconnect_screen_signals(panel_type, screen)
		screen.queue_free()
		active_screens.erase(panel_type)

func connect_screen_signals(panel_type: String, screen: Control):
	"""Connect screen-specific signals to manager handlers"""
	match panel_type:
		"queue":
			if screen.has_signal("customer_selected"):
				screen.customer_selected.connect(_on_customer_selected)
			if screen.has_signal("accept_customer"):
				screen.accept_customer.connect(_on_accept_customer)

		"translation":
			if screen.has_signal("translation_submitted"):
				screen.translation_submitted.connect(_on_translation_submitted)
			if screen.has_signal("dictionary_requested"):
				screen.dictionary_requested.connect(_on_dictionary_requested)

		"dictionary":
			if screen.has_signal("glyph_selected"):
				screen.glyph_selected.connect(_on_glyph_selected)

		"work":
			if screen.has_signal("end_day_requested"):
				screen.end_day_requested.connect(_on_end_day_requested)

func disconnect_screen_signals(panel_type: String, screen: Control):
	"""Disconnect all signals when screen is unloaded"""
	match panel_type:
		"queue":
			if screen.has_signal("customer_selected"):
				screen.customer_selected.disconnect(_on_customer_selected)
			if screen.has_signal("accept_customer"):
				screen.accept_customer.disconnect(_on_accept_customer)

		"translation":
			if screen.has_signal("translation_submitted"):
				screen.translation_submitted.disconnect(_on_translation_submitted)
			if screen.has_signal("dictionary_requested"):
				screen.dictionary_requested.disconnect(_on_dictionary_requested)

		"dictionary":
			if screen.has_signal("glyph_selected"):
				screen.glyph_selected.disconnect(_on_glyph_selected)

		"work":
			if screen.has_signal("end_day_requested"):
				screen.end_day_requested.disconnect(_on_end_day_requested)

# Signal handlers for screen interactions

func _on_customer_selected(customer_data: Dictionary):
	"""Handle customer selection in queue screen"""
	print("Customer selected: %s" % customer_data.name)
	# Could trigger examination panel to open

func _on_accept_customer(customer_data: Dictionary):
	"""Handle accepting next customer"""
	GameState.current_customer = customer_data
	customer_accepted.emit(customer_data)
	print("Accepted customer: %s" % customer_data.name)

func _on_translation_submitted(translation: String, correct: bool):
	"""Handle translation submission"""
	if correct:
		GameState.player_cash += 50
		print("Translation correct! +$50")
	else:
		print("Translation incorrect")

func _on_dictionary_requested():
	"""Open dictionary panel when requested from translation screen"""
	# Signal ShopScene to open dictionary panel
	var shop_scene = get_tree().get_first_node_in_group("shop_scene")
	if shop_scene:
		shop_scene._on_desk_object_clicked("dictionary")

func _on_glyph_selected(glyph_data: Dictionary):
	"""Handle glyph selection in dictionary"""
	print("Glyph selected: %s" % glyph_data.symbol)

func _on_end_day_requested():
	"""Handle end of day"""
	GameState.end_day()
	day_ended.emit()
	print("Day ended")

# Public API

func get_active_screen(panel_type: String) -> Control:
	"""Get currently active screen instance for a panel type"""
	return active_screens.get(panel_type, null)

func refresh_screen(panel_type: String):
	"""Refresh screen content (e.g., after game state change)"""
	if active_screens.has(panel_type):
		var screen = active_screens[panel_type]
		if screen.has_method("refresh"):
			screen.refresh()
```

### File: `scripts/ui/DiegeticPanel.gd` (Update)

```gdscript
# Add to DiegeticPanel.gd after _ready()

func load_content(panel_type: String):
	"""Load screen content via DiegeticScreenManager"""
	DiegeticScreenManager.load_screen_into_panel(panel_type, self)

# Update slide_out() to clean up screen content

func slide_out():
	"""Animate panel sliding out to right"""
	# Clean up screen content first
	DiegeticScreenManager.unload_screen(panel_type)

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
```

### File: `scripts/ShopScene.gd` (Update)

```gdscript
# Update open_panel() to load content

func open_panel(panel_type: String):
	"""Create and slide in new panel"""
	if active_panels.size() >= MAX_PANELS:
		print("Maximum panels open (%d)" % MAX_PANELS)
		return

	# Create panel instance
	var panel_scene = load("res://scenes/ui/DiegeticPanel.tscn")
	var panel = panel_scene.instantiate()
	panel.panel_type = panel_type
	panel.panel_title = PANEL_TITLES[panel_type]
	panel.panel_color = PANEL_COLORS[panel_type]

	# Set panel size and position zone
	panel.panel_width = PANEL_WIDTH
	panel.panel_height = PANEL_HEIGHT
	panel.target_position = PANEL_ZONES[panel_type]

	# Connect signals
	panel.panel_closed.connect(_on_panel_closed)
	panel.panel_focused.connect(bring_panel_to_front)

	# Add to scene
	add_child(panel)
	active_panels[panel_type] = panel
	panel_stack.append(panel_type)

	# Load screen content (NEW)
	panel.load_content(panel_type)

	# Slide in animation
	panel.slide_in()
	panel.set_active(true)

	# Update desk object glows
	update_desk_object_glows()
```

---

## Screen Adaptation Guidelines

### Converting Existing Screens to Panel Format

Each screen needs these modifications:

#### 1. **Add Panel Mode Variable**
```gdscript
var panel_mode: bool = false  # True when displayed in panel
```

#### 2. **Adjust Layout for Panel Size**
```gdscript
func _ready():
	if panel_mode:
		# Use compact layout (600×620px content area)
		setup_panel_layout()
	else:
		# Use full-screen layout (if screen still needs standalone mode)
		setup_fullscreen_layout()
```

#### 3. **Replace Navigation Calls with Signals**
```gdscript
# OLD:
func _on_accept_button_pressed():
	SceneManager.goto_translation_screen()

# NEW:
signal accept_customer(customer_data: Dictionary)

func _on_accept_button_pressed():
	accept_customer.emit(current_customer_data)
```

#### 4. **Add Initialize/Refresh Methods**
```gdscript
func initialize():
	"""Called when panel opens - load current game state"""
	refresh()

func refresh():
	"""Update display with current game state"""
	# Update UI elements from GameState
	update_customer_list()
	update_progress_display()
```

---

## Acceptance Criteria

### Must Have
- ✅ DiegeticScreenManager autoload singleton created
- ✅ All 5 screen types load into panels correctly
- ✅ Queue screen displays customer list and accepts customers
- ✅ Translation screen allows glyph translation with dictionary link
- ✅ Dictionary screen shows known glyphs with search
- ✅ Examination screen shows book details when book selected
- ✅ Work screen shows daily progress and allows day end
- ✅ Screen content cleans up properly when panels close
- ✅ Signals properly connect/disconnect on load/unload
- ✅ GameState updates persist across panel close/reopen

### Should Have
- ✅ Screens adapt gracefully to panel dimensions
- ✅ Cross-panel interactions work (e.g., dictionary opens from translation)
- ✅ Screen state persists when panel goes to background
- ✅ Multiple panels update independently

### Could Have
- ⚪ Screen transition animations within panels
- ⚪ Panel-to-panel content drag & drop
- ⚪ Split-screen mode for related panels

---

## Testing

### Test Script 1: Queue Screen Integration
```gdscript
# Test queue screen loads and functions in panel

1. Click Diary button
2. Verify Customer Queue panel slides in at left position (200, 700)
3. Verify panel contains customer list from GameState
4. Click "Accept Customer" button
5. Verify GameState.current_customer updates
6. Verify panel shows updated queue
7. Close panel
8. Reopen panel
9. Verify queue state persisted
```

### Test Script 2: Translation Screen Integration
```gdscript
# Test translation screen with dictionary linking

1. Click Papers button
2. Verify Translation Workspace panel opens center-left (500, 720)
3. Verify current book displays from GameState
4. Click "Use Dictionary" button
5. Verify Dictionary panel opens at right (1400, 680)
6. Select glyph in dictionary
7. Verify glyph info appears
8. Submit translation
9. Verify GameState.player_cash updates if correct
```

### Test Script 3: Multi-Panel State Management
```gdscript
# Test multiple panels maintain independent state

1. Open Queue panel
2. Select Customer #2
3. Open Translation panel
4. Start translating page 5
5. Open Dictionary panel
6. Search for glyph "☽"
7. Click Queue panel tab to bring to front
8. Verify Customer #2 still selected
9. Click Translation panel tab
10. Verify still on page 5
11. Close all panels
12. Reopen Translation panel
13. Verify continues from page 5 (state persisted in GameState)
```

---

## Implementation Steps

### Phase 1: Manager Setup
1. Create `scripts/DiegeticScreenManager.gd`
2. Add to autoload in `project.godot`
3. Implement basic screen loading/unloading
4. Update `DiegeticPanel.gd` with `load_content()` method
5. Update `ShopScene.gd` to call `load_content()` on panel open

### Phase 2: Screen Conversion (Start Simple)
1. Convert QueueScreen to panel format
   - Add `panel_mode` variable
   - Add signals for customer selection
   - Create compact 600×620 layout
   - Test in panel

### Phase 3: Remaining Screens
2. Convert TranslationScreen
3. Convert DictionaryScreen
4. Convert ExaminationScreen
5. Convert WorkScreen

### Phase 4: Cross-Panel Integration
1. Implement dictionary opening from translation
2. Implement examination opening from queue
3. Test multi-panel workflows

### Phase 5: Polish
1. Add screen refresh mechanisms
2. Optimize state persistence
3. Add loading indicators if needed
4. Final testing of all workflows

---

## Notes

- **Backward Compatibility**: Keep old scene-based navigation working during transition - remove once all screens are converted
- **Performance**: Only instantiate screen content when panel opens, clean up on close
- **State Management**: GameState remains source of truth - screens just display/modify it
- **Screen Reuse**: If reopening same panel type, consider reusing screen instance vs. recreating
- **Error Handling**: Gracefully handle missing screen scenes, failed loads
