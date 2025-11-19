# Phase 4: Deep Scholar System - Feature Implementation Specs

**Last Updated:** 2025-11-18
**Status:** In Progress

This document contains detailed feature specifications for implementing the Deep Scholar loop, organized in the order they appear in the gameplay experience.

---

## ✅ Feature DS-1: Queue Opens (COMPLETE)

**Based on Loop Section:** "1. The Queue Opens"
**Status:** ✅ Implemented & Tested
**Completion Time:** ~1 hour

### Implementation Summary

**What was built:**
- ✅ Book titles added to all customers (Mrs. Kowalski - "Family History", Dr. Chen - "Research Journal", The Stranger - "Ancient Tome")
- ✅ Customer cards now display: "📖 Mrs. Kowalski - "Family History" - $50 (Easy) ●●○○○"
- ✅ Queue generation system using CustomerData.generate_daily_queue()
- ✅ Capacity counter at top of queue panel: "Capacity: 0/5"
- ✅ Auto-refresh on day advance with proper signal handling

**Files Modified:**
1. `scripts/CustomerData.gd` - Added book_title to all customer types
2. `scripts/ui/CustomerCard.gd` - Updated display to show book titles
3. `scripts/GameState.gd` - Replaced test data with procedural queue generation
4. `scripts/screens/QueueScreen.gd` - Added capacity counter and day refresh

### Purpose
Display the daily customer queue with 7-10 customers, showing their books, difficulty, and payment clearly.

### Current Implementation Status

#### ✅ **What's Already Implemented:**
- QueueScreen panel displays customer queue (`scripts/screens/QueueScreen.gd`)
- CustomerCard component with visual styling (`scripts/ui/CustomerCard.gd`)
- Difficulty display with dots (●●○○○) instead of stars
- Payment display ($50, $100, etc.)
- Difficulty badges (EASY, MEDIUM, HARD)
- Capacity tracking system (`GameState.capacity_used / max_capacity`)
- CustomerData system with recurring + random customers (`scripts/CustomerData.gd`)
- Queue generation function (`CustomerData.generate_daily_queue(day_number)`)
- Diary button → Queue panel interaction
- Customer card click → popup interaction

#### ❌ **What's Missing:**

1. **Wrong Test Data**
   - Location: `GameState.gd:167-203` (`add_test_customers()`)
   - Issue: Uses hardcoded customers (Madame Leclair, Professor Thornwood, Dr. Nakamura)
   - Should use: `CustomerData.generate_daily_queue(current_day)`

2. **Book Title Not Displayed**
   - Location: `CustomerCard.gd` (name_label only shows customer name)
   - Issue: Cards show "Mrs. Kowalski" but not "Family History"
   - Should show: "📖 Mrs. Kowalski - 'Family History'"

3. **Book Title Missing from Data Structure**
   - Location: `CustomerData.gd` recurring_customers and random_customer_templates
   - Issue: No `book_title` field in customer data
   - Need to add: Example titles for each customer type

4. **Capacity Counter Not Visible in Queue**
   - Location: `QueueScreen.gd`
   - Issue: No visual display of "Capacity: 0/5"
   - Should add: Header showing remaining capacity

5. **Queue Not Refreshed on Day Advance**
   - Location: `GameState.gd:58-77` (`advance_day()`)
   - Issue: Queue doesn't regenerate for new day
   - Should call: `customer_queue = CustomerData.generate_daily_queue(current_day)`

---

### Implementation Plan

#### **Task DS-1.1: Add Book Titles to Customer Data**

**File:** `scripts/CustomerData.gd`

**Changes:**

Add `book_title` field to all recurring customers:

```gdscript
var recurring_customers: Dictionary = {
    "Mrs. Kowalski": {
        # ... existing fields ...
        "book_title": "Family History",  # NEW
        # ...
    },
    "Dr. Chen": {
        # ... existing fields ...
        "book_title": "Research Journal",  # NEW
        # ...
    },
    "The Stranger": {
        # ... existing fields ...
        "book_title": "Ancient Tome",  # NEW (mysterious, no specific title)
        # ...
    }
}
```

Add `book_title` field to random customer templates:

```gdscript
var random_customer_templates: Array = [
    {
        "name_prefix": "Scholar",
        "book_title": "Ancient Text",  # NEW - generic title
        # ... existing fields ...
    },
    {
        "name_prefix": "Collector",
        "book_title": "Estate Find",  # NEW
        # ... existing fields ...
    },
    {
        "name_prefix": "Student",
        "book_title": "Homework Assignment",  # NEW
        # ... existing fields ...
    },
    {
        "name_prefix": "Merchant",
        "book_title": "Mystery Book",  # NEW
        # ... existing fields ...
    }
]
```

Update `create_customer_instance()` to include book_title:

```gdscript
func create_customer_instance(name: String, data: Dictionary) -> Dictionary:
    return {
        "name": name,
        "book_title": data.book_title,  # NEW
        # ... rest of fields ...
    }
```

Update `generate_random_customer()` to include book_title:

```gdscript
func generate_random_customer() -> Dictionary:
    var template = random_customer_templates[randi() % random_customer_templates.size()]
    var random_number = randi_range(100, 999)

    return {
        "name": "%s #%d" % [template.name_prefix, random_number],
        "book_title": template.book_title,  # NEW
        # ... rest of fields ...
    }
```

**Acceptance Criteria:**
- [x] All recurring customers have unique book titles
- [x] All random customer templates have generic book titles
- [x] `create_customer_instance()` includes book_title in returned dictionary
- [x] `generate_random_customer()` includes book_title in returned dictionary

**Time Estimate:** 15 minutes ✅ **COMPLETE**

---

#### **Task DS-1.2: Update CustomerCard to Display Book Title**

**File:** `scripts/ui/CustomerCard.gd`

**Changes:**

Add book title label reference (update existing name_label or add new one):

Option A: Modify name_label to show both (simpler):

```gdscript
func set_customer_data(data: Dictionary):
    customer_data = data

    # Set name with book title
    if data.has("name") and data.has("book_title"):
        name_label.text = "📖 %s\n'%s'" % [data["name"], data["book_title"]]
    elif data.has("name"):
        name_label.text = data["name"]

    # ... rest of function unchanged ...
```

OR Option B: Add separate book title label (better visual separation):

1. Add `@onready var book_title_label = $MarginContainer/VBoxContainer/BookTitleLabel` to top of file
2. Update `set_customer_data()`:

```gdscript
func set_customer_data(data: Dictionary):
    customer_data = data

    # Set customer name
    if data.has("name"):
        name_label.text = data["name"]

    # Set book title (NEW)
    if data.has("book_title"):
        book_title_label.text = "📖 %s" % data["book_title"]

    # ... rest of function unchanged ...
```

**Recommendation:** Use Option A for prototype speed (no scene editing needed).

**Acceptance Criteria:**
- [x] Customer cards show both name and book title
- [x] Book icon (📖) appears before book title
- [x] Text is readable at card size
- [x] Format matches loop description: "📖 Mrs. Kowalski - 'Family History'"

**Time Estimate:** 10 minutes ✅ **COMPLETE**

---

#### **Task DS-1.3: Replace Test Customers with Generated Queue**

**File:** `scripts/GameState.gd`

**Changes:**

Replace `add_test_customers()` function:

```gdscript
# OLD VERSION (DELETE):
func add_test_customers():
    """Feature 3A.4: Add test customers to queue for development/testing"""
    customer_queue = [
        {
            "name": "Madame Leclair",
            # ... hardcoded data ...
        },
        # ...
    ]

# NEW VERSION:
func generate_customer_queue():
    """Generate daily customer queue from CustomerData"""
    customer_queue = CustomerData.generate_daily_queue(current_day)
    print("Generated %d customers for Day %d (%s)" % [customer_queue.size(), current_day, day_name])
```

Update `reset_game_state()` to call new function:

```gdscript
func reset_game_state():
    # ... existing resets ...

    # Generate queue for Day 1 (was: add_test_customers())
    generate_customer_queue()
```

Update `advance_day()` to regenerate queue:

```gdscript
func advance_day():
    """Advance to next day, deduct utilities, reset capacity"""
    player_cash -= DAILY_UTILITIES
    current_day += 1
    if current_day <= 7:
        day_name = DAY_NAMES[current_day - 1]
    capacity_used = 0
    accepted_customers = []

    # Regenerate queue for new day (NEW)
    generate_customer_queue()

    # Check if rent is due
    if current_day == RENT_DUE_DAY:
        check_rent_payment()

    day_advanced.emit()  # NEW - signal for UI refresh
```

**Acceptance Criteria:**
- [x] Queue generates 7-10 customers on game start
- [x] Queue includes recurring customers (Mrs. Kowalski on Day 1, Dr. Chen on Day 2+, etc.)
- [x] Queue includes random customers (Scholar, Collector, Student, Merchant)
- [x] Queue regenerates each day with new mix
- [x] Console prints queue generation confirmation

**Time Estimate:** 15 minutes ✅ **COMPLETE**

---

#### **Task DS-1.4: Add Capacity Counter to Queue Panel**

**File:** `scripts/screens/QueueScreen.gd`

**Changes:**

Add capacity header to panel:

```gdscript
var capacity_label: Label

func setup_panel_layout():
    # ... existing code ...

    # Margin container for top spacing
    var margin = MarginContainer.new()
    # ... existing setup ...

    # Create VBox for capacity + scroll
    var main_vbox = VBoxContainer.new()
    main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    main_vbox.add_theme_constant_override("separation", 10)
    margin.add_child(main_vbox)

    # Capacity counter (NEW)
    capacity_label = Label.new()
    capacity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    capacity_label.add_theme_font_size_override("font_size", 16)
    update_capacity_label()
    main_vbox.add_child(capacity_label)

    # Scroll container (move inside main_vbox)
    scroll_container = ScrollContainer.new()
    # ... existing scroll setup ...
    main_vbox.add_child(scroll_container)  # Was: margin.add_child(scroll_container)

    # ... rest unchanged ...

func update_capacity_label():
    """Update capacity display"""
    if not capacity_label:
        return

    var used = GameState.capacity_used
    var max_cap = GameState.max_capacity
    var remaining = max_cap - used

    capacity_label.text = "Capacity: %d/%d" % [used, max_cap]

    # Color code based on usage
    if used >= max_cap:
        capacity_label.add_theme_color_override("font_color", Color("#2D5016"))  # Green - full
    elif remaining <= 1:
        capacity_label.add_theme_color_override("font_color", Color("#FF8C00"))  # Orange - almost full
    else:
        capacity_label.add_theme_color_override("font_color", Color("#888888"))  # Gray - plenty of room

func initialize():
    """Called when panel opens"""
    populate_queue()
    update_capacity_label()  # NEW

func refresh():
    """Refresh the queue display"""
    populate_queue()
    update_capacity_label()  # NEW
```

Connect to GameState.capacity_changed signal:

```gdscript
func _ready():
    # ... existing setup ...

    # Connect to capacity changes
    GameState.capacity_changed.connect(_on_capacity_changed)

func _on_capacity_changed():
    """Handle capacity change"""
    update_capacity_label()
```

**Acceptance Criteria:**
- [x] "Capacity: 0/5" displays at top of queue panel
- [x] Counter updates when customers accepted (0/5 → 1/5 → ...)
- [x] Color changes: Gray (room), Orange (almost full), Green (full)
- [x] Counter persists across panel open/close

**Time Estimate:** 20 minutes ✅ **COMPLETE**

---

#### **Task DS-1.5: Add Day Change Signal**

**File:** `scripts/GameState.gd`

**Purpose:** Allow UI to refresh when day advances

**Changes:**

Signal already exists (`day_advanced` on line 7), but needs to be emitted:

```gdscript
func advance_day():
    # ... existing code ...

    day_advanced.emit()  # Add at end of function
```

Update `QueueScreen.gd` to listen:

```gdscript
func _ready():
    # ... existing setup ...

    # Connect to day changes to refresh queue
    GameState.day_advanced.connect(_on_day_advanced)

func _on_day_advanced():
    """Refresh queue when day advances"""
    refresh()
```

**Acceptance Criteria:**
- [x] Queue panel refreshes automatically when day advances
- [x] New customers appear for new day
- [x] Capacity counter resets to 0/5

**Time Estimate:** 10 minutes ✅ **COMPLETE**

---

### Testing Checklist

After implementing all tasks, verify:

- [ ] Start new game → Queue shows 7-10 customers
- [ ] Mrs. Kowalski appears on Day 1 with book "Family History"
- [ ] Dr. Chen does NOT appear Day 1 (only Day 2+)
- [ ] Random customers have varied book titles (Ancient Text, Estate Find, etc.)
- [ ] Customer cards show: "📖 Mrs. Kowalski - 'Family History' - $50 (Easy) ●●○○○"
- [ ] Capacity counter shows "Capacity: 0/5" initially
- [ ] Accepting a customer updates counter: 0/5 → 1/5
- [ ] Capacity counter turns orange at 4/5, green at 5/5
- [ ] Clicking diary button opens queue panel smoothly
- [ ] Queue displays correctly in panel zone (left side of desk)
- [ ] Advance day → queue refreshes with new customers
- [ ] Day 2+ shows Dr. Chen in queue
- [ ] Day 5+ shows The Stranger in queue

### Integration Points

- **Depends on:** DiegeticPanel system (Feature 3A.3), CustomerPopup (Feature 3A.4), GameState capacity tracking
- **Enables:** Customer selection → Authentication (DS-2), Customer acceptance flow

### Success Metrics

✅ Queue displays 7-10 customers per day
✅ All customer data fields visible (name, book title, difficulty, payment)
✅ Capacity tracking works (0/5 → 5/5)
✅ Queue regenerates daily with appropriate recurring customers
✅ Visual polish matches loop description (book icon, star ratings)

---

### Total Time Estimate: **1h 10min**

**Breakdown:**
- DS-1.1: Add book titles (15min)
- DS-1.2: Update card display (10min)
- DS-1.3: Replace test data (15min)
- DS-1.4: Add capacity counter (20min)
- DS-1.5: Add day signal (10min)
- Testing: (10min buffer)

---

## Next Feature: DS-2: Customer Selection → Authentication

*[To be added next...]*

---

## Notes

- **Star vs Dot Rating:** Loop shows ⭐⭐☆☆☆ but current implementation uses ●●○○○ (dots). This is visually cleaner and already implemented - keep dots.
- **Panel vs Fullscreen:** QueueScreen supports both panel and fullscreen modes. Loop shows panel mode (diary button → queue slides in) - this is already working.
- **Test vs Production Data:** Currently uses hardcoded test customers. DS-1.3 switches to procedural generation while maintaining ability to test specific scenarios.

