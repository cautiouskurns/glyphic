# Phase 4: Deep Scholar System - Feature Roadmap

**Vision**: Transform Glyphic from a translation puzzle game into a deep scholarly detective experience where players authenticate books, build a reference library, take notes, and uncover narrative connections through cross-referencing.

**Inspiration**: Return of the Obra Dinn (deduction through evidence) + Chants of Sennaar (language learning) + Papers Please (authentication tension)

---

## **Overview**

### **Core Pillars**
1. **Authentication**: Determine if books are genuine before accepting
2. **Reference Library**: A growing, searchable collection of completed work
3. **Note-Taking**: Capture insights and observations
4. **Cross-Referencing**: Compare current work with past knowledge
5. **Forgery Detection**: Risk/reward system for spotting fakes

### **Progression Arc**
- **Day 1**: Simple translation (tutorial, no complexity)
- **Day 2**: Authentication introduced (UV Light available)
- **Day 3**: Note-taking unlocked (after first repeated symbol)
- **Day 4+**: Library becomes essential (complex translations require cross-reference)
- **Day 7**: The Stranger's twist (fake-looking authentic book)

---

## **Feature List** (Priority Order)

| # | Feature | Time Est | Priority | Dependencies |
|---|---------|----------|----------|--------------|
| **4.1** | Current Book System | 1-2h | CRITICAL | None |
| **4.2** | Enhanced Examination Screen | 3-4h | CRITICAL | 4.1 |
| **4.3** | Reference Library Core | 5-7h | HIGH | 4.1 |
| **4.4** | Note-Taking System | 2-3h | HIGH | 4.3 |
| **4.5** | Authentication Phase | 4-5h | MEDIUM | 4.2 |
| **4.6** | Cross-Reference Compare | 4-6h | MEDIUM | 4.3, 4.4 |
| **4.7** | Forgery System | 3-4h | LOW | 4.5 |
| **4.8** | Library Search/Filter | 2-3h | LOW | 4.3 |
| **4.9** | Tag System | 2-3h | LOW | 4.4 |
| **4.10** | Provenance Metadata | 1-2h | LOW | 4.5 |

**Total Estimated Time**: 27-41 hours (MVP: 11-16 hours for features 4.1-4.4)

---

## **Feature 4.1: Current Book System**

### **Purpose**
Establish the concept of a "book on desk" that persists across examination → translation phases.

### **Current State**
- ✅ `GameState.current_book` exists
- ✅ `accept_customer()` places book on desk
- ✅ `ExaminationScreen` reads from `current_book`
- ✅ `TranslationScreen` reads from `current_book`
- ⚠️ No visual feedback (book doesn't appear on desk)

### **What's Needed**
Add visual book representation on ShopScene desk.

### **Specification**

**Data Structure** (Already implemented):
```gdscript
# GameState.gd
var current_book: Dictionary = {
    "name": "Mrs. Kowalski",
    "book_title": "Family History",
    "text_id": 1,
    "difficulty": "easy",
    "payment": 50,
    "book_cover_color": Color("#F4E8D8"),
    "uv_hidden_text": "Property of M. Kowalski\n1924",
    "dialogue": {...},
    "priorities": ["Cheap", "Accurate"]
}
```

**Visual Component** (NEW):
Create `DeskBook.tscn` - A book sprite/panel that appears on desk.

**Location**: Bottom-right of desk, near magnifying glass (position: Vector2(1350, 850))

**Appearance**:
- Panel size: 120×180px (book proportions)
- Background color: `book_cover_color` from customer data
- Title text: `book_title` (small, centered)
- Slight rotation: -8 degrees (natural placement)
- Shadow effect
- Subtle pulse animation (draws attention)

**States**:
- **Hidden**: When `GameState.current_book.is_empty()`
- **Visible**: When book accepted
- **Slide-in animation**: 0.4s from right when book placed

**Code Location**: `ShopScene.gd`

```gdscript
# ShopScene.gd additions

var desk_book: PanelContainer = null

func _ready():
    # ... existing setup ...
    setup_desk_book()

func setup_desk_book():
    """Create visual book representation on desk"""
    desk_book = PanelContainer.new()
    desk_book.custom_minimum_size = Vector2(120, 180)
    desk_book.position = Vector2(1350, 850)
    desk_book.rotation_degrees = -8
    desk_book.visible = false
    desk_book.z_index = 3  # Above desk, below panels

    var book_style = StyleBoxFlat.new()
    book_style.bg_color = Color(0.956, 0.909, 0.847)  # Default cream
    book_style.border_width_left = 3
    book_style.border_width_top = 3
    book_style.border_width_right = 3
    book_style.border_width_bottom = 3
    book_style.border_color = Color(0.545, 0.266, 0.137)
    book_style.corner_radius_top_left = 4
    book_style.corner_radius_top_right = 4
    book_style.corner_radius_bottom_right = 4
    book_style.corner_radius_bottom_left = 4
    book_style.shadow_size = 8
    book_style.shadow_offset = Vector2(3, 4)
    book_style.shadow_color = Color(0, 0, 0, 0.4)
    desk_book.add_theme_stylebox_override("panel", book_style)

    # Title label
    var title_label = Label.new()
    title_label.add_theme_font_size_override("font_size", 11)
    title_label.add_theme_color_override("font_color", Color(0.3, 0.25, 0.2))
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    title_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    desk_book.add_child(title_label)

    $Desk.add_child(desk_book)

func update_desk_book():
    """Update visual book when current_book changes"""
    if GameState.current_book.is_empty():
        hide_desk_book()
    else:
        show_desk_book()

func show_desk_book():
    """Show book with slide-in animation"""
    if not desk_book:
        return

    var book_data = GameState.current_book

    # Update appearance
    var book_color = book_data.get("book_cover_color", Color("#F4E8D8"))
    var style = desk_book.get_theme_stylebox("panel").duplicate()
    style.bg_color = book_color
    desk_book.add_theme_stylebox_override("panel", style)

    # Update title
    var title_label = desk_book.get_child(0)
    title_label.text = book_data.get("book_title", "Ancient Tome")

    # Slide in from right
    desk_book.visible = true
    desk_book.position.x = 1920  # Off-screen right

    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(desk_book, "position:x", 1350, 0.4)

    # Subtle pulse animation
    start_book_pulse()

func hide_desk_book():
    """Hide book with slide-out animation"""
    if not desk_book or not desk_book.visible:
        return

    var tween = create_tween()
    tween.set_ease(Tween.EASE_IN)
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.tween_property(desk_book, "position:x", 1920, 0.3)
    tween.tween_callback(func(): desk_book.visible = false)

func start_book_pulse():
    """Gentle scale pulse to draw attention"""
    var tween = create_tween().set_loops()
    tween.tween_property(desk_book, "scale", Vector2(1.02, 1.02), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(desk_book, "scale", Vector2(1.0, 1.0), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
```

**Integration Points**:
- Call `update_desk_book()` in `_on_customer_accepted()`
- Call `update_desk_book()` when translation completed (book removed)
- Call `update_desk_book()` in `show_shop()` (refresh on return)

### **Acceptance Criteria**
- [ ] Book sprite appears on desk when customer accepted
- [ ] Book color matches customer's book_cover_color
- [ ] Book title displays correctly
- [ ] Slide-in animation plays smoothly
- [ ] Book disappears when translation completed
- [ ] Pulse animation draws visual attention

### **Time Estimate**: 1-2 hours

---

## **Feature 4.2: Enhanced Examination Screen**

### **Purpose**
Improve ExaminationScreen to provide meaningful context before translation.

### **Current State**
- ✅ Displays book cover with correct color
- ✅ Shows symbol pattern
- ✅ UV Light toggle (if owned)
- ✅ Zoom on hover
- ✅ "Begin Translation" button → opens translation panel
- ⚠️ No origin/provenance info
- ⚠️ No customer context
- ⚠️ No authentication mechanics

### **What's Needed**
Add provenance display, customer dialogue snippet, and better context.

### **Specification**

**UI Enhancements**:

1. **Provenance Section** (new)
   - Display above book cover
   - Shows: Origin, Age, Customer Claim
   - Small text, cream background panel

```gdscript
# ExaminationScreen.gd additions

# Add to setup_panel_layout():
# Provenance panel (above book)
var provenance_panel = PanelContainer.new()
var prov_style = StyleBoxFlat.new()
prov_style.bg_color = Color(0.956, 0.909, 0.847, 0.5)  # Semi-transparent cream
prov_style.corner_radius_top_left = 4
prov_style.corner_radius_top_right = 4
prov_style.corner_radius_bottom_right = 4
prov_style.corner_radius_bottom_left = 4
prov_style.content_margin_left = 10
prov_style.content_margin_top = 8
prov_style.content_margin_right = 10
prov_style.content_margin_bottom = 8
provenance_panel.add_theme_stylebox_override("panel", prov_style)
vbox.add_child(provenance_panel)
vbox.move_child(provenance_panel, 1)  # After header, before book

var prov_vbox = VBoxContainer.new()
prov_vbox.add_theme_constant_override("separation", 4)
provenance_panel.add_child(prov_vbox)

var origin_label = Label.new()
origin_label.add_theme_font_size_override("font_size", 11)
origin_label.add_theme_color_override("font_color", Color(0.3, 0.25, 0.2))
prov_vbox.add_child(origin_label)

var claim_label = Label.new()
claim_label.add_theme_font_size_override("font_size", 11)
claim_label.add_theme_color_override("font_color", Color(0.3, 0.25, 0.2))
claim_label.autowrap_mode = TextServer.AUTOWRAP_WORD
prov_vbox.add_child(claim_label)
```

2. **Customer Quote** (new)
   - Display below book
   - Show greeting dialogue from customer
   - Italic style, softer color

```gdscript
# Add to setup_panel_layout():
# Customer quote label (below book)
var quote_label = Label.new()
quote_label.add_theme_font_size_override("font_size", 12)
quote_label.add_theme_color_override("font_color", Color(0.4, 0.35, 0.3))
quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD
vbox.add_child(quote_label)
vbox.move_child(quote_label, vbox.get_child_count() - 2)  # Before buttons
```

3. **Update `load_book()` to populate new fields**:

```gdscript
func load_book(book_data: Dictionary):
    # ... existing code ...

    # Populate provenance
    var origin = book_data.get("origin", "Unknown origin")
    var age = book_data.get("age", "Undated")
    origin_label.text = "Origin: %s" % origin
    claim_label.text = "\"%s\"" % book_data.get("customer_claim", "No additional information")

    # Populate customer quote
    var dialogue = book_data.get("dialogue", {})
    var greeting = dialogue.get("greeting", "Please examine this book.")
    quote_label.text = "\"%s\"\n— %s" % [greeting, customer_name]
```

**Data Structure Enhancement**:

Add to `CustomerData.gd`:
```gdscript
var recurring_customers: Dictionary = {
    "Mrs. Kowalski": {
        # ... existing fields ...
        "origin": "Warsaw, Poland",
        "age": "Circa 1924",
        "customer_claim": "This belonged to my grandmother. She was in a secret society.",
        # ...
    },
    "Dr. Chen": {
        # ... existing fields ...
        "origin": "University Archive",
        "age": "Early 20th century",
        "customer_claim": "Critical for my research into forgotten rituals.",
        # ...
    },
    "The Stranger": {
        # ... existing fields ...
        "origin": "Unknown",
        "age": "Unknown",
        "customer_claim": "You don't need to know. Just translate it.",
        # ...
    }
}
```

**Visual Improvements**:
- Add subtle texture overlay to book cover (simulate leather/cloth)
- Improve zoom indicator (show 2× in corner)
- Add tooltip to UV button when disabled ("Purchase UV Light from shop")

### **Acceptance Criteria**
- [ ] Provenance info displays above book
- [ ] Customer quote displays below book
- [ ] All text is readable and well-formatted
- [ ] Context feels meaningful (not just data dump)
- [ ] Examination now answers: "Who brought this? Why? From where?"

### **Time Estimate**: 3-4 hours

---

## **Feature 4.3: Reference Library Core**

### **Purpose**
Create a persistent library of completed translations that players can search and reference.

### **Current State**
- ❌ No library system exists
- ✅ Dictionary tracks learned symbols
- ✅ Translations are validated and symbols saved

### **What's Needed**
Build a new Library screen that stores completed books with full metadata.

### **Specification**

**Data Structure**:

Add to `GameState.gd`:
```gdscript
# Reference Library
var library: Array = []  # Array of completed book dictionaries

# Library entry structure:
# {
#     "customer_name": "Mrs. Kowalski",
#     "book_title": "Family History",
#     "text_id": 1,
#     "solution": "the old way",
#     "symbols": "∆ ◊≈ ⊕⊗◈",
#     "difficulty": "easy",
#     "payment": 50,
#     "day_completed": 1,
#     "origin": "Warsaw, Poland",
#     "age": "Circa 1924",
#     "authenticated": true,
#     "player_notes": "",
#     "tags": []
# }

func add_to_library(book_data: Dictionary):
    """Add completed book to reference library"""
    var text_data = SymbolData.get_text(book_data.get("text_id", 1))

    var entry = {
        "customer_name": book_data.get("name", "Unknown"),
        "book_title": book_data.get("book_title", "Untitled"),
        "text_id": book_data.get("text_id", 1),
        "solution": text_data.get("solution", ""),
        "symbols": text_data.get("symbols", ""),
        "difficulty": book_data.get("difficulty", "medium"),
        "payment": book_data.get("payment", 0),
        "day_completed": current_day,
        "origin": book_data.get("origin", "Unknown"),
        "age": book_data.get("age", "Undated"),
        "book_cover_color": book_data.get("book_cover_color", Color("#F4E8D8")),
        "uv_hidden_text": book_data.get("uv_hidden_text", ""),
        "authenticated": book_data.get("authenticated", false),
        "player_notes": book_data.get("player_notes", ""),
        "tags": book_data.get("tags", [])
    }

    library.append(entry)
    print("Added to library: %s (Total: %d books)" % [entry.customer_name, library.size()])

func get_library_entries_with_symbol(symbol: String) -> Array:
    """Find all library entries containing a specific symbol"""
    var results = []
    for entry in library:
        if symbol in entry.symbols:
            results.append(entry)
    return results
```

**UI Component**: Create `LibraryScreen.gd`

**Visual Design**: Cork board with pinned index cards

**Layout**:
```
┌──────────────────────────────────────┐
│ MY LIBRARY                            │
│ [Search: ___] [Sort: Date ▼]         │
├──────────────────────────────────────┤
│ ┌──────────────────────────────────┐ │
│ │ 📖 Text 1: Family History        │ │
│ │    "the old way"                 │ │
│ │    Mrs. Kowalski • Day 1         │ │
│ │    ∆ ◊≈ ⊕⊗◈                      │ │
│ │    [View Details]                │ │
│ └──────────────────────────────────┘ │
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ 📖 Text 2: Forgotten Ways        │ │
│ │    "the old way was forgotten"   │ │
│ │    Scholar #412 • Day 1          │ │
│ │    ∆ ◊≈ ⊕⊗◈ ⊕⊗⬡ ⬡∞◊⊩⊩≈⊩          │ │
│ │    [View Details]                │ │
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘
```

**Code Structure**:

```gdscript
# LibraryScreen.gd
extends Control

var panel_mode: bool = false

@onready var search_box: LineEdit
@onready var sort_dropdown: OptionButton
@onready var entries_container: VBoxContainer
@onready var scroll_container: ScrollContainer

var library_entry_scene = preload("res://scenes/ui/LibraryEntry.tscn")
var current_search: String = ""
var current_sort: String = "date_desc"

signal entry_selected(entry_data: Dictionary)

func _ready():
    if panel_mode:
        setup_panel_layout()

    await get_tree().process_frame
    await get_tree().process_frame
    initialize()

func setup_panel_layout():
    """Create panel layout (520×750px for dictionary-sized panel)"""
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    size_flags_vertical = Control.SIZE_EXPAND_FILL
    custom_minimum_size = Vector2(480, 710)

    var margin = MarginContainer.new()
    margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
    margin.add_theme_constant_override("margin_left", 15)
    margin.add_theme_constant_override("margin_top", 35)
    margin.add_theme_constant_override("margin_right", 15)
    margin.add_theme_constant_override("margin_bottom", 15)
    add_child(margin)

    var vbox = VBoxContainer.new()
    vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    vbox.add_theme_constant_override("separation", 10)
    margin.add_child(vbox)

    # Header row (search + sort)
    var header_row = HBoxContainer.new()
    header_row.add_theme_constant_override("separation", 8)
    vbox.add_child(header_row)

    search_box = LineEdit.new()
    search_box.placeholder_text = "Search books..."
    search_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    search_box.add_theme_font_size_override("font_size", 12)
    search_box.text_changed.connect(_on_search_changed)
    header_row.add_child(search_box)

    sort_dropdown = OptionButton.new()
    sort_dropdown.add_item("Date ▼", 0)
    sort_dropdown.add_item("Date ▲", 1)
    sort_dropdown.add_item("Name", 2)
    sort_dropdown.add_item("Difficulty", 3)
    sort_dropdown.add_theme_font_size_override("font_size", 12)
    sort_dropdown.item_selected.connect(_on_sort_changed)
    header_row.add_child(sort_dropdown)

    # Stats label
    var stats_label = Label.new()
    stats_label.text = "0 books in library"
    stats_label.add_theme_font_size_override("font_size", 11)
    stats_label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4))
    vbox.add_child(stats_label)

    # Scroll container for entries
    scroll_container = ScrollContainer.new()
    scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
    vbox.add_child(scroll_container)

    entries_container = VBoxContainer.new()
    entries_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    entries_container.add_theme_constant_override("separation", 10)
    scroll_container.add_child(entries_container)

func initialize():
    """Load library from GameState"""
    populate_library()

func populate_library():
    """Create entry cards for all library books"""
    # Clear existing
    for child in entries_container.get_children():
        child.queue_free()

    var library = GameState.library

    if library.is_empty():
        var empty_label = Label.new()
        empty_label.text = "No books in library yet.\nComplete translations to build your collection."
        empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        empty_label.add_theme_font_size_override("font_size", 14)
        empty_label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4))
        entries_container.add_child(empty_label)
        return

    # Sort library
    var sorted_library = sort_library(library)

    # Filter by search
    var filtered_library = filter_library(sorted_library)

    # Create cards
    for entry_data in filtered_library:
        var entry_card = create_entry_card(entry_data)
        entries_container.add_child(entry_card)

func create_entry_card(entry_data: Dictionary) -> PanelContainer:
    """Create a library entry card"""
    var card = PanelContainer.new()
    card.custom_minimum_size = Vector2(450, 100)

    # Card style (cream index card on cork board)
    var card_style = StyleBoxFlat.new()
    card_style.bg_color = Color(0.956, 0.909, 0.847)
    card_style.border_width_left = 2
    card_style.border_width_top = 2
    card_style.border_width_right = 2
    card_style.border_width_bottom = 2
    card_style.border_color = Color(0.545, 0.266, 0.137)
    card_style.corner_radius_top_left = 4
    card_style.corner_radius_top_right = 4
    card_style.corner_radius_bottom_right = 4
    card_style.corner_radius_bottom_left = 4
    card_style.shadow_size = 4
    card_style.shadow_offset = Vector2(2, 2)
    card_style.shadow_color = Color(0, 0, 0, 0.2)
    card_style.content_margin_left = 12
    card_style.content_margin_top = 10
    card_style.content_margin_right = 12
    card_style.content_margin_bottom = 10
    card.add_theme_stylebox_override("panel", card_style)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 4)
    card.add_child(vbox)

    # Title + Solution
    var title_label = Label.new()
    title_label.text = "📖 %s: %s" % [entry_data.get("book_title", "Untitled"), entry_data.get("solution", "")]
    title_label.add_theme_font_size_override("font_size", 14)
    title_label.add_theme_color_override("font_color", Color(0.2, 0.15, 0.1))
    vbox.add_child(title_label)

    # Customer + Day
    var meta_label = Label.new()
    meta_label.text = "%s • Day %d • %s" % [
        entry_data.get("customer_name", "Unknown"),
        entry_data.get("day_completed", 0),
        entry_data.get("difficulty", "Medium")
    ]
    meta_label.add_theme_font_size_override("font_size", 11)
    meta_label.add_theme_color_override("font_color", Color(0.4, 0.35, 0.3))
    vbox.add_child(meta_label)

    # Symbols
    var symbols_label = Label.new()
    symbols_label.text = entry_data.get("symbols", "")
    symbols_label.add_theme_font_size_override("font_size", 20)
    symbols_label.add_theme_color_override("font_color", Color(0.5, 0.4, 0.35, 0.5))
    vbox.add_child(symbols_label)

    # Notes preview (if exists)
    if not entry_data.get("player_notes", "").is_empty():
        var notes_label = Label.new()
        notes_label.text = "📝 \"%s\"" % entry_data.player_notes.substr(0, 60)
        if entry_data.player_notes.length() > 60:
            notes_label.text += "..."
        notes_label.add_theme_font_size_override("font_size", 10)
        notes_label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4))
        notes_label.autowrap_mode = TextServer.AUTOWRAP_WORD
        vbox.add_child(notes_label)

    return card

func sort_library(lib: Array) -> Array:
    """Sort library based on current_sort"""
    var sorted = lib.duplicate()
    match current_sort:
        "date_desc":
            sorted.sort_custom(func(a, b): return a.day_completed > b.day_completed)
        "date_asc":
            sorted.sort_custom(func(a, b): return a.day_completed < b.day_completed)
        "name":
            sorted.sort_custom(func(a, b): return a.customer_name < b.customer_name)
        "difficulty":
            sorted.sort_custom(func(a, b): return a.difficulty < b.difficulty)
    return sorted

func filter_library(lib: Array) -> Array:
    """Filter library based on search query"""
    if current_search.is_empty():
        return lib

    var filtered = []
    var search_lower = current_search.to_lower()

    for entry in lib:
        var searchable = "%s %s %s %s %s" % [
            entry.get("customer_name", ""),
            entry.get("book_title", ""),
            entry.get("solution", ""),
            entry.get("player_notes", ""),
            " ".join(entry.get("tags", []))
        ]

        if search_lower in searchable.to_lower():
            filtered.append(entry)

    return filtered

func _on_search_changed(new_text: String):
    current_search = new_text
    populate_library()

func _on_sort_changed(index: int):
    match index:
        0: current_sort = "date_desc"
        1: current_sort = "date_asc"
        2: current_sort = "name"
        3: current_sort = "difficulty"
    populate_library()

func refresh():
    populate_library()
```

**Integration**:

Update `TranslationScreen.gd` to add book to library on success:
```gdscript
func handle_success():
    # ... existing code ...

    # Add to library
    GameState.add_to_library(GameState.current_book)
```

**New Screen Registration**:

Add to `DiegeticScreenManager.gd`:
```gdscript
const SCREEN_SCENES = {
    # ... existing ...
    "library": "res://scenes/screens/LibraryScreen.tscn"
}
```

Add library desk object (Book icon on shelf?) or repurpose existing dictionary button to toggle between Dictionary/Library.

### **Acceptance Criteria**
- [ ] Library stores completed books
- [ ] Library persists across game session
- [ ] Cards display all relevant metadata
- [ ] Search filters by text/customer/notes
- [ ] Sort options work correctly
- [ ] Empty state displays when no books

### **Time Estimate**: 5-7 hours

---

## **Feature 4.4: Note-Taking System**

### **Purpose**
Allow players to add personal notes to books for insight tracking.

### **Current State**
- ❌ No note-taking exists
- ✅ Library entry structure includes `player_notes` field (prepared)

### **What's Needed**
Post-translation prompt to add notes.

### **Specification**

**UI Component**: Create `NoteEditor.tscn` - A simple popup modal

**Trigger**: After successful translation, before library save

**Visual Design**:
```
┌────────────────────────────────────┐
│ Translation Complete! +$50         │
├────────────────────────────────────┤
│ "the old way"                      │
│                                    │
│ NEW SYMBOLS DOCUMENTED:            │
│ ∆ → "the" (added to dictionary)   │
├────────────────────────────────────┤
│ Add a note about this text?        │
│ ┌────────────────────────────────┐ │
│ │                                │ │
│ │ [Your observations here...]    │ │
│ │                                │ │
│ └────────────────────────────────┘ │
│                                    │
│ [Skip] [Save Note]                 │
└────────────────────────────────────┘
```

**Code**:

```gdscript
# NoteEditor.gd
extends ColorRect

signal note_saved(note_text: String)
signal note_skipped

@onready var note_input: TextEdit
@onready var save_button: Button
@onready var skip_button: Button
@onready var summary_label: Label

func _ready():
    # Overlay background
    color = Color(0, 0, 0, 0.6)
    mouse_filter = Control.MOUSE_FILTER_STOP

    # Center panel
    var panel = PanelContainer.new()
    panel.custom_minimum_size = Vector2(400, 300)
    panel.position = Vector2(760, 390)  # Centered on 1920×1080

    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color(0.956, 0.909, 0.847)
    panel_style.border_width_left = 3
    panel_style.border_width_top = 3
    panel_style.border_width_right = 3
    panel_style.border_width_bottom = 3
    panel_style.border_color = Color(0.545, 0.266, 0.137)
    panel_style.corner_radius_top_left = 6
    panel_style.corner_radius_top_right = 6
    panel_style.corner_radius_bottom_right = 6
    panel_style.corner_radius_bottom_left = 6
    panel.add_theme_stylebox_override("panel", panel_style)
    add_child(panel)

    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 10)
    panel.add_child(vbox)

    # Summary section
    summary_label = Label.new()
    summary_label.text = "Translation Complete!\n\"the old way\""
    summary_label.add_theme_font_size_override("font_size", 14)
    summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(summary_label)

    # Prompt
    var prompt_label = Label.new()
    prompt_label.text = "Add a note about this text?"
    prompt_label.add_theme_font_size_override("font_size", 12)
    prompt_label.add_theme_color_override("font_color", Color(0.3, 0.25, 0.2))
    vbox.add_child(prompt_label)

    # Text input
    note_input = TextEdit.new()
    note_input.placeholder_text = "Your observations, connections, questions..."
    note_input.custom_minimum_size = Vector2(360, 100)
    note_input.wrap_mode = TextEdit.LINE_WRAPPING_WORD_SMART
    vbox.add_child(note_input)

    # Buttons
    var button_row = HBoxContainer.new()
    button_row.add_theme_constant_override("separation", 10)
    vbox.add_child(button_row)

    skip_button = Button.new()
    skip_button.text = "Skip"
    skip_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    skip_button.pressed.connect(_on_skip_pressed)
    button_row.add_child(skip_button)

    save_button = Button.new()
    save_button.text = "Save Note"
    save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    save_button.pressed.connect(_on_save_pressed)
    button_row.add_child(save_button)

func show_editor(translation_solution: String):
    """Display note editor with context"""
    summary_label.text = "Translation Complete!\n\"%s\"" % translation_solution
    note_input.text = ""
    note_input.grab_focus()
    visible = true

func _on_save_pressed():
    var note = note_input.text.strip_edges()
    note_saved.emit(note)
    visible = false

func _on_skip_pressed():
    note_skipped.emit()
    visible = false
```

**Integration**:

Update `TranslationScreen.gd`:
```gdscript
# Add to handle_success():
func handle_success():
    # ... existing success handling ...

    # Show note editor
    await get_tree().create_timer(2.0).timeout  # After success message
    show_note_editor()

func show_note_editor():
    """Prompt player to add notes"""
    # Create note editor popup
    var note_editor_scene = load("res://scenes/ui/NoteEditor.tscn")
    var note_editor = note_editor_scene.instantiate()
    add_child(note_editor)

    note_editor.note_saved.connect(_on_note_saved)
    note_editor.note_skipped.connect(_on_note_skipped)

    note_editor.show_editor(current_text_data.solution)

func _on_note_saved(note_text: String):
    """Save note to current book"""
    GameState.current_book["player_notes"] = note_text
    print("Note saved: %s" % note_text)
    finalize_translation()

func _on_note_skipped():
    """Skip note-taking"""
    finalize_translation()

func finalize_translation():
    """Complete translation and add to library"""
    # Add to library (with or without notes)
    GameState.add_to_library(GameState.current_book)

    # Clear book from desk
    GameState.current_book = {}

    # ... continue to next customer ...
```

### **Acceptance Criteria**
- [ ] Note editor appears after successful translation
- [ ] Player can type multi-line notes
- [ ] "Skip" closes editor without saving
- [ ] "Save Note" adds note to book entry
- [ ] Notes appear in library cards
- [ ] Notes are searchable in library

### **Time Estimate**: 2-3 hours

---

## **Feature 4.5: Authentication Phase**

### **Purpose**
Add book authentication before accepting jobs (spot forgeries).

### **Current State**
- ❌ No authentication system
- ✅ UV Light upgrade exists in GameState
- ✅ ExaminationScreen has UV functionality

### **What's Needed**
Authentication markers in CustomerPopup before acceptance.

### **Specification**

**Data Enhancement**:

Add to `CustomerData.gd` for each customer:
```gdscript
"authenticity_markers": {
    "paper_age": "authentic",     # or "suspicious", "modern"
    "binding_style": "consistent", # or "anachronistic"
    "ownership_marks": "traceable", # or "missing", "fabricated"
    "is_forgery": false
}
```

**UI Addition**: Add "Examine for Authenticity" button to CustomerPopup

**Flow**:
1. Click customer in queue → Popup opens
2. New button: "Examine Authenticity" (optional)
3. Click → Mini-examination overlay appears
4. Shows 3 checks with visual indicators
5. Player decides: Accept, Refuse, or "Need UV Light"

**Code**:

```gdscript
# Add to CustomerPopup.gd

var examine_auth_button: Button

# In setup UI:
examine_auth_button = Button.new()
examine_auth_button.text = "🔍 Examine Authenticity"
examine_auth_button.pressed.connect(_on_examine_auth_pressed)
button_row.add_child(examine_auth_button)
button_row.move_child(examine_auth_button, 0)  # Before Accept

func _on_examine_auth_pressed():
    """Show authentication mini-screen"""
    var auth_overlay = create_auth_overlay()
    add_child(auth_overlay)

func create_auth_overlay() -> Control:
    """Create authentication check overlay"""
    var overlay = ColorRect.new()
    overlay.color = Color(0, 0, 0, 0.8)
    overlay.size = size

    var panel = PanelContainer.new()
    panel.custom_minimum_size = Vector2(400, 300)
    panel.position = Vector2(250, 150)  # Centered in popup
    overlay.add_child(panel)

    var vbox = VBoxContainer.new()
    panel.add_child(vbox)

    var title = Label.new()
    title.text = "Authenticity Examination"
    title.add_theme_font_size_override("font_size", 16)
    vbox.add_child(title)

    # Check 1: Paper Age
    var markers = current_customer.get("authenticity_markers", {})
    var paper_check = create_check_row("Paper Age:", markers.get("paper_age", "unknown"))
    vbox.add_child(paper_check)

    # Check 2: Binding Style
    var binding_check = create_check_row("Binding Style:", markers.get("binding_style", "unknown"))
    vbox.add_child(binding_check)

    # Check 3: Ownership Marks
    var ownership_check = create_check_row("Ownership Marks:", markers.get("ownership_marks", "unknown"))
    if markers.get("ownership_marks") == "hidden" and not GameState.has_uv_light:
        ownership_check.get_child(1).text += " (Requires UV Light)"
    vbox.add_child(ownership_check)

    # Verdict
    var verdict_label = Label.new()
    if markers.get("is_forgery", false):
        verdict_label.text = "⚠️ LIKELY FORGERY"
        verdict_label.add_theme_color_override("font_color", Color.RED)
    else:
        verdict_label.text = "✓ Appears Authentic"
        verdict_label.add_theme_color_override("font_color", Color.GREEN)
    vbox.add_child(verdict_label)

    # Close button
    var close_btn = Button.new()
    close_btn.text = "Close"
    close_btn.pressed.connect(func(): overlay.queue_free())
    vbox.add_child(close_btn)

    return overlay

func create_check_row(label_text: String, status: String) -> HBoxContainer:
    var row = HBoxContainer.new()

    var label = Label.new()
    label.text = label_text
    label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(label)

    var status_label = Label.new()
    match status:
        "authentic", "consistent", "traceable":
            status_label.text = "✓ " + status.capitalize()
            status_label.add_theme_color_override("font_color", Color.GREEN)
        "suspicious", "anachronistic", "missing":
            status_label.text = "⚠ " + status.capitalize()
            status_label.add_theme_color_override("font_color", Color.ORANGE)
        "modern", "fabricated":
            status_label.text = "✗ " + status.capitalize()
            status_label.add_theme_color_override("font_color", Color.RED)
        _:
            status_label.text = "? Unknown"
            status_label.add_theme_color_override("font_color", Color.GRAY)

    row.add_child(status_label)
    return row
```

### **Acceptance Criteria**
- [ ] "Examine Authenticity" button appears in CustomerPopup
- [ ] Examination shows 3 authenticity checks
- [ ] Visual indicators (✓ ⚠ ✗) are clear
- [ ] Verdict updates based on markers
- [ ] UV Light requirement shows when needed
- [ ] Forgeries can be detected and refused

### **Time Estimate**: 4-5 hours

---

## **Feature 4.6: Cross-Reference Compare**

### **Purpose**
Enable side-by-side comparison of current book with library entries.

### **Current State**
- ✅ Library exists with searchable entries
- ❌ No compare/split-view

### **What's Needed**
"Compare with Library" button in ExaminationScreen that opens split-view.

### **Specification**

**UI Layout**: Split-screen (50/50)

```
┌──────────────────┬──────────────────┐
│ CURRENT BOOK     │ LIBRARY SEARCH   │
│                  │                  │
│ ∆ ◊≈ ⊕⊗◈         │ Search: [∆]      │
│                  │                  │
│ Mrs. Kowalski    │ Results (2):     │
│ "the old way"    │                  │
│                  │ • Text 1 (Day 1) │
│ [Hover symbols]  │   ∆ = "the"      │
│                  │                  │
│                  │ • Text 2 (Day 1) │
│                  │   ∆ = "the"      │
└──────────────────┴──────────────────┘
```

**(Simplified for prototype)**:

Instead of split-screen, add "Search Library" button in ExaminationScreen that:
1. Opens Library panel alongside Examination panel
2. Highlights relevant entries containing symbols from current book
3. Player manually cross-references

**Code**:

```gdscript
# Add to ExaminationScreen.gd

var library_button: Button

# In setup_panel_layout():
library_button = Button.new()
library_button.text = "📚 Consult Library"
library_button.custom_minimum_size = Vector2(0, 32)
library_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
library_button.pressed.connect(_on_library_button_pressed)
button_row.add_child(library_button)

func _on_library_button_pressed():
    """Open library panel with current symbols pre-searched"""
    # Signal DiegeticScreenManager to open library
    var shop_scene = get_tree().get_first_node_in_group("shop_scene")
    if shop_scene:
        shop_scene._on_desk_object_clicked("library")

        # Wait for library to load
        await get_tree().create_timer(0.5).timeout

        # Pre-populate search with first symbol from current book
        var text_data = SymbolData.get_text(current_text_id)
        if not text_data.is_empty():
            var symbols = text_data.symbols.split(" ", false)
            if symbols.size() > 0:
                var library_screen = DiegeticScreenManager.get_active_screen("library")
                if library_screen and library_screen.has_method("set_search"):
                    library_screen.set_search(symbols[0])
```

Add to `LibraryScreen.gd`:
```gdscript
func set_search(query: String):
    """Programmatically set search query"""
    if search_box:
        search_box.text = query
        current_search = query
        populate_library()
```

### **Acceptance Criteria**
- [ ] "Consult Library" button opens Library panel
- [ ] Library pre-searches for relevant symbols
- [ ] Player can see both Examination and Library simultaneously (2 panels open)
- [ ] Cross-referencing feels natural

### **Time Estimate**: 4-6 hours

---

## **Feature 4.7-4.10: Additional Features** (Lower Priority)

These are outlined in less detail as they're optional enhancements:

### **4.7: Forgery System**
- Add 2-3 forgery customers to queue generation
- Create forgery detection mini-game
- Consequences for accepting fakes (bad reputation, wasted time)

### **4.8: Library Search/Filter**
- Already partially implemented in 4.3
- Add tag filtering
- Add difficulty filtering

### **4.9: Tag System**
- Auto-tag books based on content (origin, customer type, difficulty)
- Allow manual tag addition in NoteEditor
- Color-code tags

### **4.10: Provenance Metadata**
- Expand CustomerData with detailed provenance
- Show in authentication checks
- Add to library entries

---

## **Implementation Priority**

### **MVP (Minimum Viable Product) - 11-16 hours**
Implement features 4.1-4.4 to get core loop working:
1. **Current Book System** (visual book on desk)
2. **Enhanced Examination** (context and provenance)
3. **Reference Library** (store and display completed books)
4. **Note-Taking** (capture insights)

This gives players:
- ✅ Context before translating ("Whose book is this?")
- ✅ Persistent knowledge base
- ✅ Ability to track observations
- ✅ Foundation for cross-referencing

### **Enhanced Experience - +8-11 hours**
Add features 4.5-4.6:
5. **Authentication Phase** (spot forgeries)
6. **Cross-Reference Compare** (consult library while examining)

This adds:
- ✅ Detective gameplay (is this book real?)
- ✅ Active use of library (not just passive storage)
- ✅ Scholarly workflow (examine → consult → translate)

### **Full Depth - +7-10 hours**
Add features 4.7-4.10:
7. **Forgery System** (risk/reward layer)
8. **Advanced Library Features** (robust search/filter)
9. **Tag System** (organization tools)
10. **Provenance Metadata** (rich context)

---

## **Testing Checklist**

After implementing MVP (4.1-4.4), test this flow:

1. [ ] Start new game
2. [ ] Accept customer → Book appears on desk
3. [ ] Click Magnifying Glass → Examination screen shows book with context
4. [ ] Read provenance, customer quote
5. [ ] Click "Begin Translation"
6. [ ] Translate successfully
7. [ ] Note editor appears
8. [ ] Add note and save
9. [ ] Open Library panel → See completed book with note
10. [ ] Accept second customer
11. [ ] Examine book → Click "Consult Library"
12. [ ] Library opens alongside examination
13. [ ] Find previous book, cross-reference symbols
14. [ ] Translate using library knowledge
15. [ ] Library now has 2 books, both searchable

---

## **Success Metrics**

This system succeeds if:
- **Players use the library** (check analytics: library panel opens per session)
- **Notes are meaningful** (check note content: are they generic or insightful?)
- **Cross-referencing happens** (check: library opened during examination/translation)
- **Authentication is engaging** (check: forgery detection rate, false positives)
- **Narrative emerges organically** (playtest feedback: did players discover connections?)

---

## **Next Steps**

1. Review this roadmap
2. Decide which features to prioritize
3. Start with Feature 4.1 (Current Book System) - easiest entry point
4. Build incrementally, testing after each feature
5. Iterate based on feel

**Recommended Start**: Feature 4.1 (1-2 hours) → immediate visual feedback and foundation for everything else.
