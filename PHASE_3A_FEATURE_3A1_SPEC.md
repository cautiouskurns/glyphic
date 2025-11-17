# Feature 3A.1: Interactive Desk Objects (Adapted)

**Priority:** CRITICAL - Foundation for entire diegetic shop system

**Tests Critical Question:** Q3 (Engaging texture) - Does interacting with physical desk objects to reveal panels feel more immersive than screen navigation?

**Estimated Time:** 90 minutes

**Dependencies:**
- Existing desk objects from ShopScene (DiaryButton, PapersButton, etc.)
- Replaces SceneManager navigation calls

---

## Overview

The 5 existing desk objects (Diary, Papers, Dictionary, Magnifying Glass, Bell) become triggers for sliding information panels instead of navigation buttons. Objects highlight when clicked, emit signals to DiegeticScreenManager, and maintain visual state while their panel is open. This establishes the core interaction: click desk object → panel slides in.

**Critical Design Constraint:** Desk objects must remain visible and clickable even when panels are open. They are the physical controls for the workspace.

---

## What Player Sees

**Desk Objects Location:**
- **Diary (📔):** Position (350, 700) - Papers on desk
- **Papers (📄):** Position (550, 730) - Scattered papers
- **Dictionary (📖):** Position (1600, 750) - Open book on right
- **Magnifying Glass (🔍):** Position (950, 770) - Tool on desk
- **Bell (🔔):** Position (1100, 750) - Service bell

**Visual States (For Each Object):**

### **Default State (No panel open):**
```gdscript
modulate = Color(1, 1, 1)  # Normal brightness
# Existing object visuals unchanged
```

### **Hover State:**
```gdscript
modulate = Color(1.2, 1.2, 1.15)  # Brightens 20%
# Cursor changes to pointer
# Tooltip appears after 0.3s: "Open [Panel Name]"
```

### **Active State (Panel open):**
```gdscript
# Colored glow outline appears around object
# Glow color matches panel color:
#   Diary → Brown (#A0826D)
#   Papers → Cream (#F4E8D8)
#   Dictionary → Green (#2D5016)
#   Magnifier → Blue (#3498DB)
#   Bell → Gold (#FFD700)

# Glow effect (StyleBoxFlat):
#   Border width: 4px
#   Border color: Panel color at 80% opacity
#   Shadow size: 8px
#   Shadow color: Panel color at 40% opacity
```

### **Inactive State (Different panel open):**
```gdscript
modulate = Color(0.8, 0.8, 0.8)  # Dimmed to 80%
# Still clickable (can open second panel)
```

**Tooltips:**
- **Diary:** "Open Customer Queue"
- **Papers:** "Open Translation Workspace"
- **Dictionary:** "Open Glyph Dictionary"
- **Magnifying Glass:** "Open Examination Screen"
- **Bell:** "Open Current Work"

**Tooltip Appearance:**
- Position: 40px above object center
- Size: Auto-width × 30px height
- Background: #2B2520 (dark brown) at 95% opacity
- Text: 14pt, #F4E8D8 (cream), centered
- Border: 1px solid #FFD700 (gold)
- Corner radius: 4px
- Appears after 0.3s hover delay
- Fades in over 0.15s

---

## What Player Does

**Input Methods:**

**Mouse:**
- Hover over object → Object brightens, tooltip appears
- Click object → Opens corresponding panel (or brings to front if already open)
- Object glows while panel open
- Click again → Toggles panel closed (if already front panel)

**Keyboard:**
- Q → Toggle Queue (Diary)
- T → Toggle Translation (Papers)
- D → Toggle Dictionary
- E → Toggle Examination (Magnifier)
- W → Toggle Work (Bell)

**Immediate Response:**
- Hover → Brighten within 16ms (single frame)
- Click → Glow appears within 50ms, panel slide starts
- Tooltip appears on hover after 0.3s delay

**Feedback Loop:**

**Example: Opening Customer Queue**
1. **Player action:** Mouse over Diary object on desk
2. **Visual change:** Diary brightens 20%, cursor becomes pointer
3. **System response:** Tooltip "Open Customer Queue" appears after 0.3s
4. **Player action:** Click Diary
5. **Visual change:** Brown glow outline appears around Diary
6. **System response:** `object_clicked` signal emits "queue"
7. **System response:** DiegeticScreenManager creates queue panel (Feature 3A.3)
8. **Visual change:** Queue panel slides in from right over 0.4s
9. **Next decision:** Read queue, open another panel, or close queue

---

## Underlying Behavior

**GDScript Structure (Modified DiaryButton.gd example):**

```gdscript
# DiaryButton.gd (adapted from existing button)
# Feature 3A.1: Interactive Desk Objects
extends Button

@onready var tooltip_panel = $TooltipPanel
@onready var glow_overlay = $GlowOverlay  # New: visual feedback

var is_panel_open: bool = false
var panel_color: Color = Color("#A0826D")  # Brown for diary/queue

# Signal for DiegeticScreenManager
signal object_clicked(screen_type: String)

func _ready():
    # Remove old SceneManager navigation
    # pressed.connect(SceneManager.goto_queue_screen)  # OLD

    # Connect new panel trigger
    pressed.connect(_on_clicked)
    mouse_entered.connect(_on_hover_start)
    mouse_exited.connect(_on_hover_end)

    # Initialize glow overlay (hidden by default)
    setup_glow_overlay()

func _on_clicked():
    """Emit signal to open/toggle panel"""
    object_clicked.emit("queue")

func _on_hover_start():
    """Brighten object on hover"""
    if not is_panel_open:
        var tween = create_tween()
        tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.15), 0.1)

    # Show tooltip after delay
    await get_tree().create_timer(0.3).timeout
    if is_hovered():  # Still hovering
        show_tooltip()

func _on_hover_end():
    """Return to normal on unhover"""
    if not is_panel_open:
        var tween = create_tween()
        tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)

    hide_tooltip()

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
    tooltip_panel.visible = true
    var tween = create_tween()
    tween.tween_property(tooltip_panel, "modulate:a", 1.0, 0.15)

func hide_tooltip():
    """Hide tooltip"""
    var tween = create_tween()
    tween.tween_property(tooltip_panel, "modulate:a", 0.0, 0.15)
    await tween.finished
    tooltip_panel.visible = false

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

func dim_inactive():
    """Dim object when different panel is active"""
    if not is_panel_open:
        modulate = Color(0.8, 0.8, 0.8)

func restore_inactive():
    """Restore brightness when other panel closes"""
    if not is_panel_open:
        modulate = Color(1, 1, 1)
```

**Scene Structure (DiaryButton.tscn - Modified):**
```
DiaryButton (Button) - Existing
├── [Existing visual children - SpineCover, Label, etc.]
├── GlowOverlay (Panel) - NEW: Glow effect when panel open
│   └── [StyleBoxFlat with colored border + shadow]
└── TooltipPanel (PanelContainer) - NEW: Hover tooltip
    └── Label ("Open Customer Queue")
```

**Key Changes to Existing Objects:**
1. Remove `SceneManager.goto_X()` connections
2. Add `object_clicked` signal with screen type
3. Add `GlowOverlay` child node
4. Add `TooltipPanel` child node
5. Add `set_panel_open()` method for DiegeticScreenManager
6. Add keyboard input handling (_input method)

**Signal Flow:**
```
Player clicks Diary
  ↓
DiaryButton._on_clicked()
  ↓
DiaryButton.object_clicked.emit("queue")
  ↓
DiegeticScreenManager receives signal
  ↓
DiegeticScreenManager.open_screen("queue") [Feature 3A.4]
  ↓
DiegeticScreenManager calls DiaryButton.set_panel_open(true)
  ↓
DiaryButton shows glow overlay
```

---

## Acceptance Criteria

**Visual Checks:**
- [ ] 5 desk objects visible in shop scene (diary, papers, dictionary, magnifier, bell)
- [ ] Objects have default appearance matching existing ShopScene visuals
- [ ] Hover over object → Brightens 20% within 0.1s
- [ ] Hover tooltip appears after 0.3s with correct text
- [ ] Click object → Glow outline appears matching panel color
- [ ] Glow uses correct colors: Brown (diary), Cream (papers), Green (dict), Blue (magnifier), Gold (bell)

**Interaction Checks:**
- [ ] Hover object → Brightens, cursor becomes pointer
- [ ] Unhover object → Returns to normal brightness
- [ ] Click object → Emits `object_clicked` signal with screen type
- [ ] Signal includes correct screen type: "queue", "translation", "dictionary", "examination", "work"
- [ ] Object glows when panel open (tested with dummy panel in Feature 3A.3)
- [ ] Glow fades in over 0.2s (smooth animation)
- [ ] Glow fades out over 0.2s when panel closes

**Keyboard Checks:**
- [ ] Press Q → Diary emits "queue" signal
- [ ] Press T → Papers emits "translation" signal
- [ ] Press D → Dictionary emits "dictionary" signal
- [ ] Press E → Magnifier emits "examination" signal
- [ ] Press W → Bell emits "work" signal
- [ ] Keyboard shortcuts work from anywhere in shop scene

**Functional Checks:**
- [ ] set_panel_open(true) shows glow correctly
- [ ] set_panel_open(false) hides glow correctly
- [ ] dim_inactive() reduces brightness to 80%
- [ ] restore_inactive() returns brightness to 100%
- [ ] Multiple objects can glow simultaneously (max 3 panels)
- [ ] Tooltips don't overlap each other
- [ ] Objects remain clickable when shop background dims (Feature 3A.2)

**Integration Checks:**
- [ ] Connects to DiegeticScreenManager (stub for now)
- [ ] Compatible with existing ShopScene layout
- [ ] Doesn't break existing shop visuals (books, doorway, lamp)
- [ ] Works with existing show_shop()/hide_shop() methods

**Edge Case Checks:**
- [ ] Rapid clicking object doesn't spam signals
- [ ] Hover during glow animation completes gracefully
- [ ] Tooltip disappears when object clicked
- [ ] Keyboard shortcut while hovering works correctly
- [ ] All 5 objects can be clicked in rapid succession

---

## Manual Test Script

1. **Verify initial state:**
   ```
   - Launch game, go to shop scene
   - Verify 5 desk objects visible with existing visuals
   - Verify no glows, no tooltips visible
   ```

2. **Test hover interaction (Diary):**
   ```
   - Hover over Diary object
   - Observe: Brightens to 120% within 0.1s
   - Observe: Cursor changes to pointer
   - Wait 0.3s
   - Verify: Tooltip "Open Customer Queue" appears
   - Move mouse away
   - Observe: Brightness returns to 100%, tooltip disappears
   ```

3. **Test click interaction (Diary):**
   ```
   - Click Diary object
   - Verify: Console shows signal emission: object_clicked("queue")
   - Observe: Brown glow outline appears around Diary
   - Verify: Glow fades in over 0.2s
   - (Panel slide will be tested in Feature 3A.3)
   ```

4. **Test all 5 objects:**
   ```
   - Hover each object (Diary, Papers, Dictionary, Magnifier, Bell)
   - Verify: Each brightens on hover
   - Verify: Correct tooltip for each
   - Click each object
   - Verify: Correct signal emitted
   - Verify: Correct glow color appears
   ```

5. **Test keyboard shortcuts:**
   ```
   - Press Q → Verify Diary emits "queue"
   - Press T → Verify Papers emits "translation"
   - Press D → Verify Dictionary emits "dictionary"
   - Press E → Verify Magnifier emits "examination"
   - Press W → Verify Bell emits "work"
   ```

6. **Test multiple glows (simulated):**
   ```
   - Manually call: diary_button.set_panel_open(true)
   - Manually call: papers_button.set_panel_open(true)
   - Manually call: magnifier_button.set_panel_open(true)
   - Verify: All 3 objects show glows simultaneously
   - Verify: Other objects (dictionary, bell) dimmed to 80%
   ```

7. **Test edge cases:**
   ```
   - Rapidly click Diary 10 times
   - Verify: Signal emits each time, no errors
   - Hover Diary while glow animation playing
   - Verify: Animation completes smoothly
   - Press Q while hovering Papers
   - Verify: Diary still emits signal correctly
   ```

8. **Pass criteria:** All 5 objects interactive, signals emit correctly, glows appear with correct colors

---

## Known Simplifications

**Phase 3A shortcuts:**
- No object animation (diary opening, bell ringing)
- No particle effects (glow sparkles, hover shimmer)
- Simple tooltip design (flat panel, no arrow pointing to object)
- Glow is outline only (not full object highlight)

**Technical debt:**
- Object nodes hardcoded in ShopScene
  - **Impact:** Adding 6th object requires manual scene editing
- Glow colors hardcoded in each object script
  - **Impact:** Refactor to data-driven panel colors in Feature 3A.4
- Keyboard shortcuts use hardcoded key codes
  - **Impact:** Not rebindable, add input mapping system later
- Tooltip positioning assumes fixed screen size
  - **Impact:** May clip off-screen on smaller windows

---

## Integration Points

**Connects to Feature 3A.2 (Shop Workspace Zones):**
- Objects remain clickable when background dims
- Objects stay in desk area (left 40%)

**Connects to Feature 3A.3 (Screen Panel Sliding):**
- Signals trigger panel creation
- Panels notify objects when open/closed via set_panel_open()

**Connects to Feature 3A.4 (Diegetic Screen Manager):**
- Signals received by manager
- Manager calls set_panel_open() on objects
- Manager calls dim_inactive() when other panel active

---

## Visual Reference

**Object States:**

```
DEFAULT STATE:
[📔 Diary] ← Normal appearance, no outline

HOVER STATE:
[📔 Diary] ← Brightened 120%, tooltip above:
             ┌──────────────────────┐
             │ Open Customer Queue  │
             └──────────────────────┘

ACTIVE STATE (Panel open):
╔═══════════╗
║ 📔 Diary ║ ← Brown glow outline (4px border + 8px shadow)
╚═══════════╝

INACTIVE STATE (Different panel open):
[📔 Diary] ← Dimmed to 80% brightness
```

**Color Reference:**
```gdscript
# Panel colors (for glow matching)
QUEUE_COLOR      = Color("#A0826D")  # Brown (Diary)
TRANSLATION_COLOR = Color("#F4E8D8")  # Cream (Papers)
DICTIONARY_COLOR  = Color("#2D5016")  # Green (Dictionary)
EXAMINATION_COLOR = Color("#3498DB")  # Blue (Magnifier)
WORK_COLOR        = Color("#FFD700")  # Gold (Bell)
```

---

## Next Step

After Feature 3A.1 is complete, proceed to **Feature 3A.2: Shop Workspace Zones** to define the spatial layout where panels will appear.
