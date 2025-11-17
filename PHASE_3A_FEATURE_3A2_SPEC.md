# Feature 3A.2: Shop Workspace Zones (Desk Focus Perspective)

**Priority:** CRITICAL - Defines spatial foundation for diegetic panel system

**Tests Critical Question:** Q3 (Engaging texture) - Does the perspective shift to focus on desk work create a more immersive workspace experience than static full-screen panels?

**Estimated Time:** 90 minutes

**Dependencies:**
- Feature 3A.1: Interactive Desk Objects (signals and glow system)
- Existing ShopScene camera and layout

---

## Overview

When a desk object is clicked, the camera perspective shifts to "lean over the desk," bringing the desk area into sharp focus while the bookshelves remain semi-visible in the background (peripheral vision). This creates defined workspace zones where panels can appear on the desk surface itself. The shift makes the player feel like they're physically moving closer to work on specific tasks.

**Critical Design Constraint:** The perspective shift must feel natural and immersive - like the player is leaning forward to focus on their work. Bookshelves fade to background but remain visible to maintain spatial awareness of the shop.

---

## What Player Sees

### **Default View (No Panel Open):**

```
Camera Position: Default shop view
  ┌─────────────────────────────────────────┐
  │  [Left Shelf] [Left Shelf2] [Right Shelf] │  ← Bookshelves fully visible, bright
  │           [Doorway with light]            │
  │═══════════════════════════════════════════│
  │  [Papers] [Diary] [Papers] [Mag] [Bell]   │  ← Desk objects visible, normal size
  │         [Open Dictionary Book]            │
  │              Desk Surface                 │
  └─────────────────────────────────────────┘

Viewport: 1920×1080
Desk occupies: Lower 430px (650-1080)
All elements at 100% brightness
```

### **Focused View (Panel Open - "Leaning Over Desk"):**

```
Camera Position: Shifted down and scaled to focus on desk
  ┌─────────────────────────────────────────┐
  │  [Dim Shelves...]  [Dim Shelves...]      │  ← Bookshelves 60% opacity, blurred
  ├───────────────────────────────────────────┤
  │                                           │
  │  [Desk Zone: Left 40%]  [Panel Zone: 60%]│
  │                                           │
  │  [Diary]  [Papers]  │ <Panel slides here> │
  │  [Mag]    [Bell]    │                     │
  │  [Objects visible]  │  Panel content      │
  │                     │                     │
  └─────────────────────────────────────────┘

Viewport: 1920×1080
Desk now occupies: ~900px vertical space (enlarged/zoomed)
Bookshelves: ~180px at top (compressed, dim, background)
```

**Zone Breakdown:**

**Desk Object Zone (Left 40% = 768px width):**
- Contains all 5 interactive desk objects
- Objects remain clickable during panel view
- Objects maintain glow states from Feature 3A.1
- Slightly brighter than default (105% to maintain focus)

**Panel Display Zone (Right 60% = 1152px width):**
- Panels slide in from right edge
- Appears to "lay on desk surface"
- Max 3 panels can stack (browser-style tabs)
- Panel dimensions: 1100px wide × 850px tall
- Positioned: (800, 115) in focused view

**Background Transition:**
- Bookshelves: Fade to 60% opacity, apply 3px blur
- Doorway: Fade to 50% opacity
- Desk surface: Slightly brighten to 110% (work area emphasis)
- Top bar: Remains visible at 100% (day/cash always readable)

---

## What Player Does

### **Input Methods:**

**Opening Panel (triggers focus shift):**
1. Click any desk object (Diary, Papers, Dictionary, Magnifier, Bell)
2. Press keyboard shortcut (Q, T, D, E, W)
3. **Immediate response:** Camera shifts over 0.4s with ease-out
4. **Visual feedback:**
   - Bookshelves fade/blur
   - Desk zooms/shifts into focus
   - Panel zone becomes available
   - Clicked object glows (from Feature 3A.1)

**During Focused View:**
- Desk objects remain clickable (can open multiple panels)
- ESC key closes all panels and returns to default view
- Clicking background returns to default view
- Clicking active panel tab brings that panel to front

**Closing Panel (returns to default):**
1. Click last active panel's close button
2. Press ESC
3. Click dimmed bookshelf area (background)
4. **Immediate response:** Camera shifts back over 0.4s with ease-in
5. **Visual feedback:**
   - Bookshelves return to 100% opacity, no blur
   - Desk returns to default size/position
   - All glows fade (from Feature 3A.1)

---

## Underlying Behavior

### **GDScript Structure (ShopScene.gd additions):**

```gdscript
# ShopScene.gd
# Feature 3A.2: Shop Workspace Zones

@onready var camera = $Camera2D  # Main camera for perspective shift
@onready var background_dim = $BackgroundDim  # Overlay for dimming bookshelves

# Workspace zone state
var is_focused_mode: bool = false
var focus_tween: Tween

# Camera positions and zoom levels
var default_camera_position: Vector2 = Vector2(960, 540)  # Center of 1920×1080
var focused_camera_position: Vector2 = Vector2(960, 720)  # Shifted down to desk
var default_zoom: Vector2 = Vector2(1.0, 1.0)
var focused_zoom: Vector2 = Vector2(1.0, 1.3)  # Zoom in on desk area

# Panel zone configuration
const DESK_ZONE_WIDTH = 768  # Left 40%
const PANEL_ZONE_X = 800
const PANEL_ZONE_Y = 115
const PANEL_ZONE_WIDTH = 1100
const PANEL_ZONE_HEIGHT = 850

func _ready():
    # Existing setup...
    setup_camera()
    setup_background_dim()
    connect_desk_objects()

func setup_camera():
    """Initialize camera for perspective shifts"""
    if not camera:
        camera = Camera2D.new()
        add_child(camera)

    camera.position = default_camera_position
    camera.zoom = default_zoom
    camera.enabled = true

func setup_background_dim():
    """Create dimming overlay for bookshelves during focus mode"""
    background_dim = ColorRect.new()
    background_dim.size = Vector2(1920, 650)  # Cover bookshelf area
    background_dim.position = Vector2(0, 0)
    background_dim.color = Color(0, 0, 0, 0)  # Transparent initially
    background_dim.mouse_filter = Control.MOUSE_FILTER_STOP  # Blocks clicks when active
    background_dim.visible = false
    background_dim.z_index = 50  # Above bookshelves, below panels
    add_child(background_dim)

    # Connect click to exit focus mode
    background_dim.gui_input.connect(_on_background_clicked)

func connect_desk_objects():
    """Connect desk object signals to focus mode - Feature 3A.1 integration"""
    diary_button.object_clicked.connect(_on_desk_object_clicked)
    papers_button.object_clicked.connect(_on_desk_object_clicked)
    dictionary_button.object_clicked.connect(_on_desk_object_clicked)
    magnifying_glass_button.object_clicked.connect(_on_desk_object_clicked)
    bell_button.object_clicked.connect(_on_desk_object_clicked)

func _on_desk_object_clicked(screen_type: String):
    """Handle desk object click - enter focus mode if not already"""
    if not is_focused_mode:
        enter_focus_mode()

    # Signal will be handled by DiegeticScreenManager in Feature 3A.4
    # For now, just enter focus mode

func enter_focus_mode():
    """Shift perspective to focus on desk workspace"""
    if is_focused_mode:
        return  # Already in focus mode

    is_focused_mode = true

    # Kill existing tween if any
    if focus_tween:
        focus_tween.kill()

    focus_tween = create_tween()
    focus_tween.set_parallel(true)
    focus_tween.set_ease(Tween.EASE_OUT)
    focus_tween.set_trans(Tween.TRANS_CUBIC)

    # Camera shift and zoom
    focus_tween.tween_property(camera, "position", focused_camera_position, 0.4)
    focus_tween.tween_property(camera, "zoom", focused_zoom, 0.4)

    # Dim and blur bookshelves
    background_dim.visible = true
    focus_tween.tween_property(background_dim, "color:a", 0.4, 0.4)  # 40% dark overlay

    # Dim bookshelf modulate (separate from overlay for blur effect)
    focus_tween.tween_property(left_bookshelf, "modulate:a", 0.6, 0.4)
    focus_tween.tween_property(left_bookshelf2, "modulate:a", 0.6, 0.4)
    focus_tween.tween_property(right_bookshelf, "modulate:a", 0.6, 0.4)
    focus_tween.tween_property(doorway, "modulate:a", 0.5, 0.4)

    # Brighten desk surface slightly
    var desk_surface = $Desk/DeskSurface
    focus_tween.tween_property(desk_surface, "modulate", Color(1.1, 1.1, 1.1), 0.4)

func exit_focus_mode():
    """Return perspective to default shop view"""
    if not is_focused_mode:
        return  # Already in default mode

    is_focused_mode = false

    # Kill existing tween if any
    if focus_tween:
        focus_tween.kill()

    focus_tween = create_tween()
    focus_tween.set_parallel(true)
    focus_tween.set_ease(Tween.EASE_IN)
    focus_tween.set_trans(Tween.TRANS_CUBIC)

    # Camera return to default
    focus_tween.tween_property(camera, "position", default_camera_position, 0.4)
    focus_tween.tween_property(camera, "zoom", default_zoom, 0.4)

    # Remove dim overlay
    focus_tween.tween_property(background_dim, "color:a", 0.0, 0.4)

    # Restore bookshelf brightness
    focus_tween.tween_property(left_bookshelf, "modulate:a", 1.0, 0.4)
    focus_tween.tween_property(left_bookshelf2, "modulate:a", 1.0, 0.4)
    focus_tween.tween_property(right_bookshelf, "modulate:a", 1.0, 0.4)
    focus_tween.tween_property(doorway, "modulate:a", 1.0, 0.4)

    # Return desk to normal brightness
    var desk_surface = $Desk/DeskSurface
    focus_tween.tween_property(desk_surface, "modulate", Color(1, 1, 1), 0.4)

    # Hide background dim after animation
    await focus_tween.finished
    background_dim.visible = false

    # Clear all object glows (Feature 3A.1 integration)
    diary_button.set_panel_open(false)
    papers_button.set_panel_open(false)
    dictionary_button.set_panel_open(false)
    magnifying_glass_button.set_panel_open(false)
    bell_button.set_panel_open(false)

func _on_background_clicked(event: InputEvent):
    """Handle click on dimmed background - exit focus mode"""
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        exit_focus_mode()

func _input(event):
    """Handle ESC to exit focus mode"""
    # Existing keyboard shortcuts...

    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE:
            if is_focused_mode:
                exit_focus_mode()
                get_viewport().set_input_as_handled()  # Don't propagate ESC

        # Existing Q/T/D/E/W shortcuts...

# Public API for DiegeticScreenManager (Feature 3A.4)

func get_panel_zone_rect() -> Rect2:
    """Returns the panel display zone in global coordinates"""
    return Rect2(PANEL_ZONE_X, PANEL_ZONE_Y, PANEL_ZONE_WIDTH, PANEL_ZONE_HEIGHT)

func is_in_focus_mode() -> bool:
    """Check if shop is currently in focused desk mode"""
    return is_focused_mode
```

---

## Acceptance Criteria

### **Visual Checks:**
- [ ] Default view: All bookshelves and desk visible at normal size
- [ ] Default view: Camera centered at (960, 540), zoom 1.0
- [ ] Focus mode: Camera shifts to (960, 720), zoom 1.3
- [ ] Focus mode: Bookshelves fade to 60% opacity with slight blur
- [ ] Focus mode: Doorway fades to 50% opacity
- [ ] Focus mode: Desk surface brightens to 110%
- [ ] Focus mode: Background dim overlay visible at 40% opacity
- [ ] Transition animations smooth (0.4s ease-out entering, ease-in exiting)

### **Interaction Checks:**
- [ ] Click any desk object → Enters focus mode
- [ ] Press keyboard shortcut (Q/T/D/E/W) → Enters focus mode
- [ ] Press ESC in focus mode → Exits focus mode
- [ ] Click background dim area → Exits focus mode
- [ ] Top bar remains 100% visible in both modes
- [ ] Desk objects remain clickable in focus mode
- [ ] Smooth transition with no visual glitches or jumps

### **Zone Definition Checks:**
- [ ] Desk zone occupies left 40% (768px) in focus mode
- [ ] Panel zone positioned at (800, 115) with size 1100×850
- [ ] Panel zone clearly defined and ready for Feature 3A.3
- [ ] Zones don't overlap desk objects
- [ ] Zones maintain consistent positions during transitions

### **Integration Checks (Feature 3A.1):**
- [ ] Desk object signals trigger focus mode correctly
- [ ] Object glows remain visible during focus mode
- [ ] Object glows clear when exiting focus mode
- [ ] Hover effects work on desk objects in both modes
- [ ] Tooltips appear correctly in both modes

### **Camera Behavior Checks:**
- [ ] No jitter or stutter during camera movement
- [ ] Zoom feels natural and not disorienting
- [ ] Transition speed (0.4s) feels responsive but not rushed
- [ ] Camera returns exactly to default position when exiting
- [ ] Multiple rapid focus/unfocus cycles don't break animation

### **Edge Case Checks:**
- [ ] Clicking desk object while already in focus mode doesn't restart animation
- [ ] Exiting focus mode while entering completes gracefully
- [ ] Window resize doesn't break camera positioning
- [ ] All transitions complete even if interrupted
- [ ] ESC in default mode doesn't trigger errors

---

## Manual Test Script

### **1. Verify default state:**
```
- Launch game, navigate to shop scene
- Verify camera centered, no dim overlays
- Verify all bookshelves bright and clear
- Verify desk objects at normal size
- Screenshot: "3A2_default_view.png"
```

### **2. Test focus mode entry (click):**
```
- Click Diary desk object
- Observe: Camera shifts down and zooms over 0.4s
- Observe: Bookshelves fade to 60%, slightly blurred
- Observe: Desk surface brightens
- Observe: Diary glows brown (Feature 3A.1)
- Verify: Smooth animation, no jumps
- Screenshot: "3A2_focused_view.png"
```

### **3. Test focus mode entry (keyboard):**
```
- Return to default (press ESC)
- Press T key
- Observe: Same smooth transition as click test
- Observe: Papers glows cream (Feature 3A.1)
- Verify: Transition matches click behavior exactly
```

### **4. Test focus mode exit (ESC):**
```
- While in focus mode, press ESC
- Observe: Camera returns to center/default zoom over 0.4s
- Observe: Bookshelves return to 100% brightness, no blur
- Observe: Desk returns to normal brightness
- Observe: All object glows fade
- Verify: Smooth return animation
```

### **5. Test focus mode exit (background click):**
```
- Enter focus mode (click any object)
- Click on dimmed bookshelf area at top
- Observe: Same smooth exit as ESC test
- Verify: Background click works anywhere in dim overlay
```

### **6. Test desk objects remain interactive:**
```
- Enter focus mode (click Diary)
- Click Papers object while in focus mode
- Verify: Papers glow appears without restarting focus animation
- Click Dictionary object
- Verify: Dictionary glow appears
- Verify: All 3 objects can glow simultaneously
```

### **7. Test rapid toggling:**
```
- Click Diary (enter focus)
- Immediately press ESC (exit focus)
- Immediately click Papers (enter focus)
- Verify: All transitions complete smoothly
- Verify: No animation glitches or stuck states
```

### **8. Test zone boundaries:**
```
- Enter focus mode
- Use Godot debug draw to verify:
  - Desk zone: 0-768px width
  - Panel zone: 800px x, 115px y, 1100×850 size
- Verify: get_panel_zone_rect() returns correct Rect2
```

### **9. Pass criteria:**
Camera shifts smoothly, zones defined correctly, desk objects remain interactive, all transitions feel natural and immersive.

---

## Known Simplifications

**Phase 3A shortcuts:**
- No camera rotation (just position + zoom shift)
- No depth-of-field blur effect (using simple opacity fade)
- Simple fade instead of radial blur for periphery
- Fixed camera positions (not dynamic based on which object clicked)

**Technical debt:**
- Camera positions hardcoded (should adapt to viewport size)
  - **Impact:** May not work correctly on non-1920×1080 displays
- Blur effect simulated with opacity instead of shader
  - **Impact:** Less realistic peripheral vision effect
- Panel zone fixed size (doesn't scale with camera zoom)
  - **Impact:** May need adjustment if zoom level changes
- Background dim is simple ColorRect (not gradient radial mask)
  - **Impact:** Less natural vignette effect

**Future enhancements:**
- Add subtle camera shake/rotation for more natural "lean in" feel
- Implement radial blur shader for true peripheral vision
- Dynamic panel zone sizing based on viewport
- Parallax effect on bookshelves during camera shift

---

## Integration Points

### **Connects to Feature 3A.1 (Interactive Desk Objects):**
- Desk object signals trigger `enter_focus_mode()`
- Object glows remain visible during focus mode
- Object `set_panel_open(false)` called when exiting focus mode

### **Connects to Feature 3A.3 (Screen Panel Sliding):**
- Defines `PANEL_ZONE_*` constants for panel positioning
- Provides `get_panel_zone_rect()` for panel creation
- Focus mode must be active before panels can slide in

### **Connects to Feature 3A.4 (Diegetic Screen Manager):**
- Manager calls `enter_focus_mode()` when creating first panel
- Manager calls `exit_focus_mode()` when closing last panel
- Manager uses `get_panel_zone_rect()` to position panels
- Manager checks `is_in_focus_mode()` before panel operations

---

## Visual Reference

### **Camera Shift Diagram:**

```
DEFAULT VIEW (Camera: y=540, zoom=1.0):
  ┌───────────────────────────────┐  ← y=0
  │     Bookshelves (870px)        │
  │     100% opacity              │
  ├───────────────────────────────┤  ← y=650
  │     Desk (430px)              │
  │     100% brightness           │
  └───────────────────────────────┘  ← y=1080

FOCUSED VIEW (Camera: y=720, zoom=1.3):
  ┌───────────────────────────────┐  ← y=0
  │ Bookshelves (180px compressed)│  ← Dim, blurred, background
  ├─────────────┬─────────────────┤  ← y=180
  │             │                 │
  │ Desk Zone   │  Panel Zone     │
  │ (768px)     │  (1152px)       │
  │             │                 │
  │ Objects ✓   │  [Panel area]   │
  │ Clickable   │                 │
  │             │                 │
  └─────────────┴─────────────────┘  ← y=1080
```

### **Opacity/Brightness Values:**

```gdscript
# Default Mode
bookshelves.modulate.a = 1.0  # 100% visible
doorway.modulate.a = 1.0
desk_surface.modulate = Color(1, 1, 1)  # Normal brightness
background_dim.visible = false

# Focused Mode
bookshelves.modulate.a = 0.6  # 60% visible (peripheral)
doorway.modulate.a = 0.5  # 50% visible
desk_surface.modulate = Color(1.1, 1.1, 1.1)  # 110% brightness (work area)
background_dim.color = Color(0, 0, 0, 0.4)  # 40% dark overlay
```

---

## Next Step

After Feature 3A.2 is complete, proceed to **Feature 3A.3: Screen Panel Sliding** to create the actual panel containers that slide into the defined panel zone.
