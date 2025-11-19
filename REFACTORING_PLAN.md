# Glyphic Refactoring Plan: Scene-Based + Data-Driven Architecture

**Goal:** Transform runtime-created UI into visual scenes and extract hardcoded data into resources for easier debugging, iteration, and maintenance.

**Principle:** "If you can see it, make it a scene. If it changes, make it data."

---

## Current Architecture Problems

### 🔴 **Problem 1: Invisible UI**
**Current State:**
```gdscript
# QueueScreen.gd - Everything created in code
func setup_panel_layout():
    var margin = MarginContainer.new()
    margin.add_theme_constant_override("margin_top", 35)
    add_child(margin)

    var capacity_label = Label.new()
    capacity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    capacity_label.add_theme_font_size_override("font_size", 16)
    # ... 50 more lines of UI construction
```

**Problem:** Can't see layout in Godot editor, must run game to debug positioning.

---

### 🔴 **Problem 2: Data Mixed with Code**
**Current State:**
```gdscript
# CustomerData.gd - Dictionary soup
var recurring_customers: Dictionary = {
    "Mrs. Kowalski": {
        "type": "recurring",
        "book_title": "Family History",
        "payment": 50,
        "difficulty": "Easy",
        # ... 15 more fields
    }
}
```

**Problem:** No validation, no autocomplete, hard to manage in bulk, can't reference in editor.

---

### 🔴 **Problem 3: Magic Numbers Everywhere**
**Current State:**
```gdscript
# ShopScene.gd
const PANEL_ZONES = {
    "queue": Vector2(56, 700),
    "translation": Vector2(403, 726),
    # ...
}
const PANEL_WIDTH = 309
const DICTIONARY_PANEL_WIDTH = 426
```

**Problem:** Positions scattered across files, no single source of truth.

---

## Refactoring Strategy: 3 Phases

### **Phase 1: Extract Data (Week 1)** ⭐ START HERE
*Separate what changes from how it's displayed*

### **Phase 2: Scene-ify UI (Week 2)**
*Move runtime UI creation to visual scenes*

### **Phase 3: Polish & Consistency (Week 3)**
*Unify patterns, add editor tooling*

---

## Phase 1: Extract Data to Resources (3-5 days)

**Goal:** Create custom Resource types for all game data so it's editable in Godot inspector.

### **1.1: Create Customer Resource (1 day)**

**Why:** Customers are complex, reusable data that should be resources, not dictionaries.

**Create:** `res://resources/customer_resource.gd`

```gdscript
# customer_resource.gd
@tool  # Allows editing in inspector
class_name CustomerResource
extends Resource

@export_category("Identity")
@export var customer_name: String = "Unknown Customer"
@export var book_title: String = "Untitled Book"
@export var is_recurring: bool = false
@export var is_priority: bool = false

@export_category("Job Details")
@export_enum("Easy", "Medium", "Hard") var difficulty: String = "Medium"
@export var payment: int = 50
@export var appears_on_days: Array[int] = [1]  # Which days they show up

@export_category("Priorities")
@export var wants_fast: bool = false
@export var wants_cheap: bool = false
@export var wants_accurate: bool = false

@export_category("Story")
@export_multiline var greeting_dialogue: String = ""
@export_multiline var success_dialogue: String = ""
@export_multiline var failure_dialogue: String = ""
@export var story_role: String = "None"

@export_category("Appearance")
@export var book_cover_color: Color = Color("#F4E8D8")
@export_multiline var uv_hidden_text: String = ""

@export_category("Relationship")
@export var refusal_tolerance: int = 2
@export var current_relationship: int = 2

# Helper method to get priorities as array (for backward compatibility)
func get_priorities() -> Array:
    var priorities = []
    if wants_fast: priorities.append("Fast")
    if wants_cheap: priorities.append("Cheap")
    if wants_accurate: priorities.append("Accurate")
    return priorities

# Helper to convert to legacy dictionary format (during transition)
func to_dict() -> Dictionary:
    return {
        "name": customer_name,
        "book_title": book_title,
        "type": "recurring" if is_recurring else "one-time",
        "payment": payment,
        "difficulty": difficulty,
        "priorities": get_priorities(),
        "dialogue": {
            "greeting": greeting_dialogue,
            "success": success_dialogue,
            "failure": failure_dialogue
        },
        "story_role": story_role,
        "is_recurring": is_recurring,
        "is_priority": is_priority,
        "book_cover_color": book_cover_color,
        "uv_hidden_text": uv_hidden_text
    }
```

**Create Resources:** `res://data/customers/`
- `mrs_kowalski.tres`
- `dr_chen.tres`
- `the_stranger.tres`
- `scholar_template.tres`
- `collector_template.tres`
- `student_template.tres`
- `merchant_template.tres`

**Update CustomerData.gd:**
```gdscript
# CustomerData.gd (new version)
extends Node

# Load customer resources
@export var recurring_customers: Array[CustomerResource] = []
@export var random_templates: Array[CustomerResource] = []

func _ready():
    # Load from resources folder
    recurring_customers = [
        load("res://data/customers/mrs_kowalski.tres"),
        load("res://data/customers/dr_chen.tres"),
        load("res://data/customers/the_stranger.tres")
    ]

    random_templates = [
        load("res://data/customers/scholar_template.tres"),
        load("res://data/customers/collector_template.tres"),
        load("res://data/customers/student_template.tres"),
        load("res://data/customers/merchant_template.tres")
    ]

func generate_daily_queue(day_number: int) -> Array:
    var queue: Array = []

    # Add recurring customers
    for customer_res in recurring_customers:
        if day_number in customer_res.appears_on_days:
            if customer_res.current_relationship > 0:
                queue.append(customer_res.to_dict())

    # Add random customers
    var num_random = randi_range(4, 7)
    for i in range(num_random):
        queue.append(generate_random_customer())

    queue.shuffle()
    return queue

func generate_random_customer() -> Dictionary:
    var template = random_templates[randi() % random_templates.size()]
    var instance = template.duplicate()  # Create copy
    instance.customer_name = "%s #%d" % [instance.customer_name, randi_range(100, 999)]
    return instance.to_dict()
```

**Benefits:**
- ✅ Edit customers in Godot Inspector (visual!)
- ✅ Type safety (no more typos in dictionary keys)
- ✅ Autocomplete in code
- ✅ Can preview in FileSystem panel
- ✅ Easy to duplicate/template

**Time:** 1 day (create resource script + migrate 10 customers)

---

### **1.2: Create Translation Text Resource (1 day)**

**Create:** `res://resources/translation_text_resource.gd`

```gdscript
# translation_text_resource.gd
@tool
class_name TranslationTextResource
extends Resource

@export var text_id: int = 1
@export var text_name: String = "Text 1 - The Old Way"

@export_category("Content")
@export var symbols: String = "∆ ◊≈ ⊕⊗◈"
@export var solution: String = "the old way"
@export var hint: String = "Simple word substitution"

@export_category("Difficulty")
@export_enum("Easy", "Medium", "Hard") var difficulty: String = "Easy"
@export var word_count: int = 15
@export var base_payment: int = 50

@export_category("Symbol Mappings")
@export var mappings: Dictionary = {}  # Symbol -> Word

@export_category("Story")
@export_multiline var lore_snippet: String = ""
@export var narrative_beat: int = 1  # Which story beat this text reveals

func to_dict() -> Dictionary:
    return {
        "id": text_id,
        "name": text_name,
        "symbols": symbols,
        "solution": solution,
        "mappings": mappings,
        "difficulty": difficulty,
        "payment_base": base_payment,
        "hint": hint
    }
```

**Create Resources:** `res://data/translations/`
- `text_01_old_way.tres`
- `text_02_forgotten.tres`
- `text_03_god_sleeps.tres`
- `text_04_magic_known.tres`
- `text_05_returning.tres`

**Update SymbolData.gd:**
```gdscript
# SymbolData.gd (new version)
extends Node

@export var translation_texts: Array[TranslationTextResource] = []

func _ready():
    translation_texts = [
        load("res://data/translations/text_01_old_way.tres"),
        load("res://data/translations/text_02_forgotten.tres"),
        load("res://data/translations/text_03_god_sleeps.tres"),
        load("res://data/translations/text_04_magic_known.tres"),
        load("res://data/translations/text_05_returning.tres")
    ]

func get_text(text_id: int) -> Dictionary:
    for text_res in translation_texts:
        if text_res.text_id == text_id:
            return text_res.to_dict()
    return {}
```

**Time:** 1 day

---

### **1.3: Create UI Configuration Resource (1 day)**

**Why:** All those magic numbers for positions, sizes, colors should be data.

**Create:** `res://resources/ui_config_resource.gd`

```gdscript
# ui_config_resource.gd
@tool
class_name UIConfigResource
extends Resource

@export_category("Screen Size")
@export var screen_width: int = 1920
@export var screen_height: int = 1080

@export_category("Panel Zones")
@export var queue_zone_position: Vector2 = Vector2(56, 700)
@export var translation_zone_position: Vector2 = Vector2(403, 726)
@export var dictionary_zone_position: Vector2 = Vector2(1448, 701)
@export var examination_zone_position: Vector2 = Vector2(880, 708)

@export_category("Panel Sizes")
@export var default_panel_size: Vector2 = Vector2(309, 684)
@export var translation_panel_size: Vector2 = Vector2(451, 596)
@export var dictionary_panel_size: Vector2 = Vector2(426, 750)
@export var examination_panel_size: Vector2 = Vector2(520, 650)

@export_category("Colors - Theme")
@export var color_desk: Color = Color("#D4B896")
@export var color_text_dark: Color = Color("#3A2518")
@export var color_parchment: Color = Color("#F4E8D8")
@export var color_success: Color = Color("#2D5016")
@export var color_failure: Color = Color("#8B0000")
@export var color_highlight: Color = Color("#FFD700")

@export_category("Colors - UI")
@export var panel_queue_color: Color = Color("#A0826D")
@export var panel_translation_color: Color = Color("#F4E8D8")
@export var panel_dictionary_color: Color = Color("#A0826D")

@export_category("Camera")
@export var default_camera_position: Vector2 = Vector2(960, 540)
@export var focused_camera_position: Vector2 = Vector2(960, 970)
@export var default_zoom: Vector2 = Vector2(1.0, 1.0)

@export_category("Animation")
@export var panel_slide_duration: float = 0.4
@export var focus_transition_duration: float = 0.4
```

**Create Resource:** `res://data/ui_config.tres`

**Create Autoload:** `UIConfig` pointing to this resource

**Update ShopScene.gd:**
```gdscript
# ShopScene.gd (simplified)
extends Control

# BEFORE: Hardcoded constants everywhere
# const PANEL_ZONES = { ... }
# const PANEL_WIDTH = 309
# ...

# AFTER: Reference config
func get_panel_position(panel_type: String) -> Vector2:
    match panel_type:
        "queue": return UIConfig.queue_zone_position
        "translation": return UIConfig.translation_zone_position
        "dictionary": return UIConfig.dictionary_zone_position
        "examination": return UIConfig.examination_zone_position
        _: return Vector2.ZERO

func get_panel_size(panel_type: String) -> Vector2:
    match panel_type:
        "translation": return UIConfig.translation_panel_size
        "dictionary": return UIConfig.dictionary_panel_size
        "examination": return UIConfig.examination_panel_size
        _: return UIConfig.default_panel_size
```

**Benefits:**
- ✅ Edit all positions/sizes in one place (Inspector)
- ✅ No more const hunting across files
- ✅ Can have multiple configs (dev vs production)
- ✅ Tweak values live in editor

**Time:** 1 day

---

### **1.4: Backward Compatibility Layer**

**Important:** During migration, keep old dictionary-based code working.

**Pattern:**
```gdscript
# Keep both APIs working
func get_customer(name: String):
    # Try resource first
    for res in recurring_customers:
        if res.customer_name == name:
            return res.to_dict()  # Convert to old format

    # Fallback to old dictionary
    return old_recurring_customers.get(name, {})
```

**Time:** Built into above tasks

---

## Phase 2: Scene-ify UI (5-7 days)

**Goal:** Move runtime-created UI to .tscn files editable in Godot editor.

### **2.1: Convert QueueScreen to Full Scene (1 day)**

**Current:** Everything created in `setup_panel_layout()`

**New Approach:**
1. Create scene in editor: `QueueScreen.tscn`
2. Add all nodes visually (VBoxContainer, Labels, ScrollContainer, etc.)
3. Wire up references with `@onready`
4. Remove all `new()` calls from code

**Before:**
```gdscript
# QueueScreen.gd - 100 lines of UI construction
func setup_panel_layout():
    var margin = MarginContainer.new()
    margin.add_theme_constant_override("margin_top", 35)
    add_child(margin)

    var main_vbox = VBoxContainer.new()
    # ... 80 more lines
```

**After:**
```gdscript
# QueueScreen.gd - Just references
@onready var capacity_label: Label = $MarginContainer/MainVBox/CapacityLabel
@onready var scroll_container: ScrollContainer = $MarginContainer/MainVBox/ScrollContainer
@onready var card_container: GridContainer = $MarginContainer/MainVBox/ScrollContainer/CardContainer

func _ready():
    # Just populate, don't construct
    populate_queue()
    update_capacity_label()
```

**QueueScreen.tscn** (visual hierarchy):
```
QueueScreen (Control)
└─ MarginContainer
   └─ MainVBox (VBoxContainer)
      ├─ CapacityLabel (Label)
      └─ ScrollContainer
         └─ CardContainer (GridContainer)
```

**Benefits:**
- ✅ See layout in editor
- ✅ Drag nodes to reposition
- ✅ Edit fonts/colors visually
- ✅ 90% less code

**Time:** 1 day

---

### **2.2: Convert TranslationScreen to Scene (1 day)**

Same approach as QueueScreen.

**Current:** `setup_panel_layout()` creates everything

**New:** Create `TranslationScreen.tscn` with visual editor

---

### **2.3: Convert DictionaryScreen to Scene (1 day)**

---

### **2.4: Convert ExaminationScreen to Scene (1 day)**

---

### **2.5: Create Reusable UI Component Scenes (2 days)**

**Problem:** CustomerCard still creates UI in code

**Solution:** Make CustomerCard a fully visual scene

**Create:** `CustomerCard.tscn` with scene editor:
```
CustomerCard (PanelContainer)
├─ Pin (PanelContainer)
│  └─ PinCenter (PanelContainer)
├─ MarginContainer
   └─ VBoxContainer
      ├─ NameLabel (Label)
      ├─ DifficultyRow (HBoxContainer)
      │  ├─ DifficultyBadge (PanelContainer)
      │  │  └─ HBox
      │  │     ├─ DifficultyLabel
      │  │     └─ StarsLabel
      ├─ MetaRow (HBoxContainer)
      │  ├─ TimeContainer/TimeLabel
      │  └─ PaymentContainer/PaymentLabel
      ├─ DescriptionLabel
      ├─ SignatureLabel
      └─ StatusLabel
```

**CustomerCard.gd** (simplified):
```gdscript
# Just references, no more manual construction
@onready var name_label = $MarginContainer/VBoxContainer/NameLabel
@onready var difficulty_label = $MarginContainer/VBoxContainer/DifficultyRow/DifficultyBadge/HBox/DifficultyLabel
# etc...

func set_customer_data(data: Dictionary):
    name_label.text = "📖 %s - \"%s\"" % [data["name"], data["book_title"]]
    payment_label.text = "$%d" % data["payment"]
    # Just populate, don't construct
```

**Do this for:**
- CustomerCard
- DictionaryEntry
- Any other repeatedly-instantiated components

---

## Phase 3: Polish & Consistency (3-4 days)

### **3.1: Create Theme Resource**

**Why:** Font sizes, colors, margins currently set per-widget

**Create:** `res://themes/glyphic_theme.tres`

**Use throughout:** Every screen inherits this theme automatically

**Before:**
```gdscript
label.add_theme_font_size_override("font_size", 16)
label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4))
```

**After:**
```gdscript
label.theme_type_variation = "SubtleLabel"  # Defined in theme
```

---

### **3.2: Editor Tooling**

**Create:** `@tool` scripts for live preview

**Example:**
```gdscript
# customer_resource.gd
@tool  # ← This makes it editable in inspector

# Add preview in inspector
func _get_property_list():
    return [
        {
            "name": "Preview",
            "type": TYPE_STRING,
            "usage": PROPERTY_USAGE_CATEGORY
        },
        {
            "name": "preview_card",
            "type": TYPE_STRING,
            "hint": PROPERTY_HINT_MULTILINE_TEXT,
            "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY
        }
    ]

func _get(property):
    if property == "preview_card":
        return "📖 %s - \"%s\"\n%s - $%d" % [customer_name, book_title, difficulty, payment]
```

---

### **3.3: Validation & Error Checking**

Add `_validate_property()` to resources:

```gdscript
# customer_resource.gd
func _validate_property(property: Dictionary):
    # Ensure payment is positive
    if property.name == "payment":
        if payment < 0:
            push_error("Customer payment cannot be negative!")

    # Ensure at least one priority
    if property.name == "wants_accurate":
        if not (wants_fast or wants_cheap or wants_accurate):
            push_warning("Customer should have at least one priority!")
```

---

## Migration Checklist

### **Week 1: Data Extraction**
- [ ] Create CustomerResource + migrate all customers
- [ ] Create TranslationTextResource + migrate all texts
- [ ] Create UIConfigResource + migrate constants
- [ ] Test backward compatibility (old code still works)

### **Week 2: Scene Conversion**
- [ ] Convert QueueScreen to full scene
- [ ] Convert TranslationScreen to full scene
- [ ] Convert DictionaryScreen to full scene
- [ ] Convert ExaminationScreen to full scene
- [ ] Convert CustomerCard to full scene
- [ ] Convert DictionaryEntry to full scene

### **Week 3: Polish**
- [ ] Create unified theme resource
- [ ] Add @tool scripts for live preview
- [ ] Add validation to resources
- [ ] Remove all old dictionary-based code
- [ ] Documentation update

---

## Benefits Summary

### **Before Refactoring:**
```gdscript
# CustomerData.gd - 200 lines of nested dictionaries
var recurring_customers: Dictionary = {
    "Mrs. Kowalski": {
        "type": "recurring",
        "book_title": "Family History",
        # ... 15 more fields, no autocomplete, easy typos
    }
}

# QueueScreen.gd - 150 lines of UI construction
func setup_panel_layout():
    var margin = MarginContainer.new()
    margin.add_theme_constant_override("margin_top", 35)
    # ... 100 more lines, can't see layout
```

**Problems:**
- ❌ Can't visualize UI without running game
- ❌ Hard to debug positioning
- ❌ No autocomplete for data
- ❌ Easy to make typos in dictionary keys
- ❌ Magic numbers scattered everywhere
- ❌ Hard to iterate on design

### **After Refactoring:**
```gdscript
# CustomerData.gd - 30 lines, loads resources
@export var recurring_customers: Array[CustomerResource] = [
    preload("res://data/customers/mrs_kowalski.tres"),
    preload("res://data/customers/dr_chen.tres")
]

# QueueScreen.gd - 20 lines, references scene nodes
@onready var capacity_label: Label = $MarginContainer/MainVBox/CapacityLabel

func _ready():
    populate_queue()  # Just populate, don't construct
```

**Benefits:**
- ✅ **Visual:** See UI layout in Godot editor
- ✅ **Type-Safe:** Autocomplete, no typos
- ✅ **Maintainable:** Single source of truth for data
- ✅ **Debuggable:** Edit positions live in editor
- ✅ **Scalable:** Easy to add new customers/texts
- ✅ **Professional:** Industry-standard Godot architecture

---

## Risk Mitigation

**Risk:** Breaking existing functionality during migration

**Mitigation:**
1. **Keep both systems running** during transition (backward compatibility)
2. **Migrate one screen at a time** (don't break everything at once)
3. **Test after each step** (verify old behavior still works)
4. **Use `to_dict()` helpers** to convert resources to old format temporarily
5. **Git branch per phase** (easy rollback if needed)

---

## Recommended Start

**Start with Phase 1.1 (Customer Resources):**
1. Small, isolated change
2. Immediate visual benefit (edit customers in inspector)
3. Doesn't break existing code (backward compatible)
4. Teaches the resource pattern for later phases

**Do this today:**
1. Create `customer_resource.gd`
2. Create `mrs_kowalski.tres` in inspector
3. Load in `CustomerData.gd` and test
4. If it works, migrate remaining customers

**Total time investment:** ~2-3 weeks for full refactor, but benefits compound immediately.
