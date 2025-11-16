# PHASE 2B: REFERENCE SYSTEM - Feature Specifications

**Game:** Glyphic - Translation Shop Prototype
**Phase Goal:** Player can consult reference materials to solve translations through scholarly research, not just pattern matching.
**Estimated Time:** 3 hours (Hours 6-9 of development, after Phase 2 Core Puzzle Loop)
**Features in Phase:** 5 features (2B.1 through 2B.5)

**Context:** Phase 2 established the core translation loop (type answer, validate, earn money). Phase 2B transforms it from pure pattern matching into scholarly research by adding a reference library system. Players consult multiple sources (Grimoire Index, Prior Translations, Customer Context, Working Notes) to decode symbols through cross-referencing, making late-game puzzles feel like detective work instead of typing exercises.

---

## Feature 2B.1: Reference Library Shelf

**Priority:** HIGH - Visual entry point for entire reference system.

**Tests Critical Question:** Q1 (Puzzle satisfaction) + Q3 (Engaging texture) - Makes translation feel like scholarly research, not just symbol substitution.

**Estimated Time:** 30 minutes

**Dependencies:**
- **Feature 1.3 (UI Workspace Layout)** must be complete - Reference shelf renders above workspace
- **Feature 2.1 (Translation Display System)** must be complete - Reference shelf appears when translation active

---

### Overview

The Reference Library Shelf displays 4 clickable book spines at the top of the workspace. When clicked, books "pull down" and open in the Reference Panel (Feature 2B.2). This is the player's research library—always visible during translation, inviting consultation when stuck.

**Critical Design Constraint:** Books must be visually distinct (different colors, readable spines). Maximum 4 books to avoid overwhelming interface. Books are reference tools only—cannot be permanently removed or reordered.

---

### What Player Sees

**Screen Layout:**
- **Position:** Top of center workspace, just below top bar (300, 70) to (1480, 130) - spans 1180×60px
- **4 Book Spines:**
  - Each spine: 280×60px
  - Spacing: 15px between spines
  - Alignment: Centered horizontally in workspace area

**Visual Appearance:**

**Book Spine Design:**

**📕 Grimoire Index (Red):**
- Background: Deep red #8B0000
- Text: "GRIMOIRE INDEX" in gold #FFD700, 16pt serif, vertical orientation
- Spine edge: Dark brown leather texture #3A2518
- Embossed symbol: Small ⊞ glyph near bottom

**📗 Prior Translations (Green):**
- Background: Dark green #2D5016
- Text: "MY TRANSLATIONS" in cream #F4E8D8, 16pt serif, vertical
- Spine edge: Worn brown #5A4A3A
- Page marker: Small bookmark ribbon visible at top

**📙 Customer Context (Orange):**
- Background: Burnt orange #CC6600
- Text: "CUSTOMER FILES" in dark brown #2A1F1A, 16pt serif, vertical
- Spine edge: Light brown #8B7355
- Label: Small paper tag with "Clients" handwritten

**📔 Working Notes (Brown):**
- Background: Tan brown #A0826D
- Text: "MY NOTES" in dark ink #1A1A1A, 16pt serif, vertical
- Spine edge: Leather-bound brown #5A4A3A
- Bookmark: Multiple colored tabs visible at edges

**Visual States:**

**Default State (no book open):**
- All 4 spines visible side-by-side
- Slight 3D depth effect (1px shadow on right edge)
- Subtle wood texture behind spines (shelf background)

**Hover State:**
- Hovered book spine lifts 3px upward (pull-out animation)
- Glow effect: 2px soft shadow around spine
- Cursor changes to pointing hand
- Tooltip appears below: "Click to consult [Book Name]"

**Active State (book open):**
- Selected book spine lifts 8px and tilts slightly forward (5° angle)
- Brighter glow: 4px shadow, higher opacity
- Other 3 books remain in default state (not dimmed - can still click)
- Active book stays "pulled out" while Reference Panel shows its content

**Visual Feedback:**
- **On click:** Book spine animates pulling forward (0.2s) before Reference Panel opens
- **On close:** Book spine animates returning to shelf (0.2s) as Reference Panel closes
- **On switch:** Current book returns to shelf while new book pulls out (sequential, 0.15s each)

---

### What Player Does

**Input Methods:**

**Mouse:**
- Click book spine → Opens that reference book in Reference Panel (Feature 2B.2)
- Hover spine → Spine lifts slightly, tooltip appears
- Click active book again → Closes Reference Panel, book returns to shelf

**Keyboard:**
- Number keys 1-4 → Quick-open corresponding book (1=Grimoire, 2=Translations, 3=Context, 4=Notes)
- Escape key → Closes currently open reference

**Immediate Response:**
- Click spine → Book pulls out within 0.2 seconds, Reference Panel opens simultaneously
- Hover → Lift effect appears instantly (<16ms)
- Switch books → Old book returns, new book opens in 0.3 seconds total

**Feedback Loop:**

**Example: Player stuck on symbol ⊞⊟≈**

1. **Player action:** Sees unknown symbol ⊞⊟≈ in text "∆ ◊≈ ⊞⊟≈ ⬡≈≈⊢⬡"
2. **Player thought:** "I know ∆='the' and ◊≈='old', but what's ⊞⊟≈?"
3. **Player decision:** Clicks red Grimoire Index spine
4. **System response:** Grimoire spine pulls out, Reference Panel opens showing symbol entries
5. **Visual change:** Red book tilts forward, panel displays "Symbol: ⊞⊟≈" content
6. **Player action:** Reads context clues, discovers "deity symbol, ritual contexts"
7. **Player thought:** "Ah, it's probably 'god' - 'the old god [something]'"
8. **Next action:** Closes Grimoire (clicks spine again), continues solving puzzle

**Example: Player checking prior work**

1. **Player thought:** "Did I see ⊕⊗⬡ before? What did it mean?"
2. **Player action:** Clicks green Prior Translations spine
3. **System response:** Prior Translations opens showing archive of completed texts
4. **Visual change:** Green book pulls out, panel shows Text 2 entry with ⊕⊗⬡="was"
5. **Player action:** Confirms symbol, closes reference (presses Escape)
6. **Next action:** Returns to translation with confidence

---

### Underlying Behavior

**GDScript Structure:**

```gdscript
# res://scripts/ui/ReferenceShelf.gd
extends Control

@onready var grimoire_spine = $ShelfContainer/GrimoireSpine
@onready var translations_spine = $ShelfContainer/TranslationsSpine
@onready var context_spine = $ShelfContainer/ContextSpine
@onready var notes_spine = $ShelfContainer/NotesSpine

var active_book: String = ""  # "", "grimoire", "translations", "context", "notes"

signal book_opened(book_name: String)
signal book_closed()

func _ready():
	grimoire_spine.pressed.connect(_on_book_clicked.bind("grimoire"))
	translations_spine.pressed.connect(_on_book_clicked.bind("translations"))
	context_spine.pressed.connect(_on_book_clicked.bind("context"))
	notes_spine.pressed.connect(_on_book_clicked.bind("notes"))

	# Hover effects
	grimoire_spine.mouse_entered.connect(_on_book_hovered.bind(grimoire_spine))
	translations_spine.mouse_entered.connect(_on_book_hovered.bind(translations_spine))
	context_spine.mouse_entered.connect(_on_book_hovered.bind(context_spine))
	notes_spine.mouse_entered.connect(_on_book_hovered.bind(notes_spine))

	grimoire_spine.mouse_exited.connect(_on_book_unhovered.bind(grimoire_spine))
	translations_spine.mouse_exited.connect(_on_book_unhovered.bind(translations_spine))
	context_spine.mouse_exited.connect(_on_book_unhovered.bind(context_spine))
	notes_spine.mouse_exited.connect(_on_book_unhovered.bind(notes_spine))

func _on_book_clicked(book_name: String):
	"""Handle book spine click"""
	if active_book == book_name:
		# Close if clicking active book
		close_book()
	else:
		# Open new book (close old if any)
		open_book(book_name)

func open_book(book_name: String):
	"""Animate book pulling out and emit signal"""
	# Close previous book if any
	if active_book != "":
		close_book()

	active_book = book_name

	# Get spine node
	var spine = get_spine_node(book_name)

	# Pull-out animation
	var tween = create_tween()
	tween.tween_property(spine, "position:y", spine.position.y - 8, 0.2)
	tween.tween_property(spine, "rotation_degrees", 5, 0.2)

	# Emit signal for Reference Panel to display content
	book_opened.emit(book_name)

func close_book():
	"""Animate book returning to shelf and emit signal"""
	if active_book == "":
		return

	var spine = get_spine_node(active_book)

	# Return animation
	var tween = create_tween()
	tween.tween_property(spine, "position:y", spine.position.y + 8, 0.15)
	tween.tween_property(spine, "rotation_degrees", 0, 0.15)

	active_book = ""
	book_closed.emit()

func _on_book_hovered(spine: Control):
	"""Hover lift effect"""
	if get_book_name_from_spine(spine) == active_book:
		return  # Skip if already active

	var tween = create_tween()
	tween.tween_property(spine, "position:y", spine.position.y - 3, 0.1)

	# Show tooltip
	spine.tooltip_text = "Click to consult %s" % get_book_display_name(spine)

func _on_book_unhovered(spine: Control):
	"""Remove hover effect"""
	if get_book_name_from_spine(spine) == active_book:
		return

	var tween = create_tween()
	tween.tween_property(spine, "position:y", spine.position.y + 3, 0.1)

func get_spine_node(book_name: String) -> Control:
	"""Get spine node by book name"""
	match book_name:
		"grimoire": return grimoire_spine
		"translations": return translations_spine
		"context": return context_spine
		"notes": return notes_spine
	return null

func get_book_name_from_spine(spine: Control) -> String:
	"""Get book name from spine node"""
	if spine == grimoire_spine: return "grimoire"
	if spine == translations_spine: return "translations"
	if spine == context_spine: return "context"
	if spine == notes_spine: return "notes"
	return ""

func get_book_display_name(spine: Control) -> String:
	"""Get display name for tooltip"""
	var book_name = get_book_name_from_spine(spine)
	match book_name:
		"grimoire": return "Grimoire Index"
		"translations": return "Prior Translations"
		"context": return "Customer Context"
		"notes": return "Working Notes"
	return ""

func _input(event):
	"""Keyboard shortcuts"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: open_book("grimoire")
			KEY_2: open_book("translations")
			KEY_3: open_book("context")
			KEY_4: open_book("notes")
			KEY_ESCAPE: close_book()
```

**Scene Structure:**

```
ReferenceShelf (Control)
└── ShelfContainer (HBoxContainer) - 15px spacing
    ├── GrimoireSpine (Button) - Red #8B0000, 280×60px
    ├── TranslationsSpine (Button) - Green #2D5016, 280×60px
    ├── ContextSpine (Button) - Orange #CC6600, 280×60px
    └── NotesSpine (Button) - Brown #A0826D, 280×60px
```

**Key Numbers from Design:**
- 4 reference books total
- Spine width: 280px each
- Spine height: 60px
- Spacing: 15px between spines
- Hover lift: 3px upward
- Active lift: 8px upward + 5° tilt
- Pull-out animation: 0.2 seconds
- Return animation: 0.15 seconds
- Keyboard shortcuts: 1-4 for quick access

---

### Acceptance Criteria

**Visual Checks:**
- [ ] 4 book spines visible at top of workspace (300, 70)
- [ ] Spines are distinct colors: Red, Green, Orange, Brown
- [ ] Text readable on each spine (vertical orientation, 16pt)
- [ ] Shelf background visible (wood texture)
- [ ] All spines same size (280×60px)
- [ ] 15px spacing between spines
- [ ] Slight 3D depth effect (1px shadow on right edges)

**Interaction Checks:**
- [ ] Click spine → Book pulls out 8px, tilts 5°, animation takes 0.2s
- [ ] Hover spine → Lifts 3px, tooltip appears
- [ ] Un-hover spine → Returns to default position
- [ ] Click active book again → Book returns to shelf, closes reference
- [ ] Switch books → Old book returns, new book opens (sequential)
- [ ] Press 1-4 keys → Opens corresponding book
- [ ] Press Escape → Closes current reference

**Functional Checks:**
- [ ] book_opened signal emits with correct book name ("grimoire", "translations", "context", "notes")
- [ ] book_closed signal emits when closing reference
- [ ] active_book variable tracks currently open book
- [ ] Only one book can be active at a time
- [ ] Clicking same book twice closes it (toggle behavior)
- [ ] Keyboard shortcuts work (1=Grimoire, 2=Translations, 3=Context, 4=Notes)

**Integration Checks:**
- [ ] Reference Panel (Feature 2B.2) listens to book_opened signal
- [ ] Reference Panel displays content for opened book
- [ ] Reference Panel closes when book_closed signal emitted
- [ ] Animation doesn't conflict with translation input (can type while book animates)

**Polish Checks:**
- [ ] Pull-out animation smooth (no jittering)
- [ ] Hover effect responsive (lifts within 16ms)
- [ ] Active book visually distinct (pulled out, others at rest)
- [ ] Tooltips appear centered below spines
- [ ] Color contrast readable (text visible on colored backgrounds)

**Edge Case Checks:**
- [ ] Rapid clicking doesn't break animation (queue clicks)
- [ ] Pressing number key while book open switches correctly
- [ ] Escape works even if reference panel not open (no error)
- [ ] Click spine during pull-out animation completes gracefully

---

### Manual Test Script

1. **Verify initial state:**
   ```
   - Launch game, load Text 1
   - Verify 4 book spines visible at top of workspace
   - Verify colors: Red (Grimoire), Green (Translations), Orange (Context), Brown (Notes)
   - Verify text readable on each spine
   ```

2. **Test click interaction:**
   ```
   - Click red Grimoire spine
   - Observe: Book pulls out 8px, tilts 5° forward
   - Time animation (should be ~0.2 seconds)
   - Verify Reference Panel opens (Feature 2B.2 should display Grimoire content)
   ```

3. **Test hover effects:**
   ```
   - Hover over green Translations spine (without clicking)
   - Verify: Spine lifts 3px, tooltip appears "Click to consult Prior Translations"
   - Move mouse away
   - Verify: Spine returns to default position
   ```

4. **Test toggle behavior:**
   ```
   - Click Grimoire spine (opens)
   - Click Grimoire spine again (should close)
   - Verify: Book returns to shelf, Reference Panel closes
   ```

5. **Test book switching:**
   ```
   - Click Grimoire (opens red book)
   - Click Translations (switches to green book)
   - Verify: Red book returns to shelf, green book pulls out
   - Time total transition (~0.3 seconds: 0.15s close + 0.15s open)
   ```

6. **Test keyboard shortcuts:**
   ```
   - Press "1" key → Grimoire opens
   - Press "2" key → Switches to Translations
   - Press "3" key → Switches to Context
   - Press "4" key → Switches to Notes
   - Press Escape → Closes current book
   ```

7. **Test edge cases:**
   ```
   - Click Grimoire spine rapidly 5 times
   - Verify: Toggles correctly (open → close → open → close → open)
   - No animation conflicts or stuck states
   ```

8. **Pass criteria:** All 4 books clickable, animations smooth, keyboard shortcuts work, signals emit correctly

---

### Known Simplifications

**Phase 2B shortcuts:**
- No book "peek" (can't partially open to see first page without fully opening)
- Fixed book order (can't reorder spines)
- No bookmarks visible on spines (no indication of which page you're on)
- Simple pull-out animation (no realistic page-flipping)
- No sound effects (book sliding, pages rustling)

**Technical debt:**
- Hardcoded spine positions (not responsive to workspace resize)
  - **Impact:** Fine for fixed 1920×1080 viewport, refactor if adding responsive design
- Animation uses position offset (not z-index layering)
  - **Impact:** Works for 2D shelf, would need 3D transform for realistic depth
- Tooltip text not localized (English only)
  - **Impact:** Acceptable for prototype

---

## Feature 2B.2: Reference Panel

**Priority:** CRITICAL - Core UI for displaying reference content.

**Tests Critical Question:** Q1 (Puzzle satisfaction) + Q3 (Engaging texture) - Makes research feel rewarding, not tedious.

**Estimated Time:** 45 minutes

**Dependencies:**
- **Feature 2B.1 (Reference Library Shelf)** must be complete - Panel opens when shelf book clicked
- **Feature 2B.3 (Reference Content System)** must be complete - Panel displays content from data structures

---

### Overview

The Reference Panel replaces the static Dictionary panel (right side) with a dynamic content area showing the currently open reference book. Displays text-based reference material with scrolling, search, and close button. Supports 4 book types with distinct layouts.

**Critical Design Constraint:** Panel is read-only (player cannot edit reference content, only read). Maximum 1 book open at a time. Content must be scannable (headings, bullet points, no walls of text).

---

### What Player Sees

**Screen Layout:**
- **Position:** Right panel (1500, 90) to (1920, 1080) - 420×990px (same area as old Dictionary)
- **Header:** Book title at top (40px height)
- **Content Area:** Scrollable main content (950px height)
- **Footer:** Close button at bottom (40px height)

**Visual Appearance:**

**Panel Header:**
- Background: Matches book spine color (red for Grimoire, green for Translations, etc.)
- Title: "[Book Name]" in cream #F4E8D8, 24pt serif, centered
- Close button (×): Right side, 30×30px, cream text

**Content Area (varies by book type):**

**📕 Grimoire Index Layout:**
```
┌────────────────────────────────┐
│  Symbol: ⊞⊟≈                   │  ← Heading, 30pt
│                                │
│  Known Contexts:               │  ← Subheading, 20pt bold
│  • Blood Moon Ceremony (deity) │  ← Bullet, 18pt
│  • Dream Journal (sleeper)     │
│  • Harvest Ritual (spirit)     │
│                                │
│  Historical Note:              │  ← Subheading
│  "Often paired with sleep      │  ← Paragraph, 18pt
│   symbols in ritual texts..."  │
│                                │
│  Etymology:                    │  ← Subheading
│  "Sumerian 'god' + Germanic    │  ← Italic, 16pt
│   'sleep' rune combination"    │
└────────────────────────────────┘
```

**📗 Prior Translations Layout:**
```
┌────────────────────────────────┐
│  TEXT 1 - Day 1                │  ← Heading, 24pt bold
│  Mrs. Kowalski, Family History │  ← Subheading, 18pt
│                                │
│  Original:                     │  ← Label, 16pt
│  ∆ ◊≈ ⊕⊗◈                      │  ← Symbols, 30pt
│                                │
│  Your Translation:             │  ← Label
│  "the old way"                 │  ← Quote, 20pt green
│                                │
│  Confirmed Symbols:            │  ← Label
│  ∆ = "the"                     │  ← List, 18pt
│  ◊≈ = "old"                    │
│  ⊕⊗◈ = "way"                   │
│                                │
│  [Divider line]                │
│                                │
│  TEXT 2 - Day 2                │  ← Next entry
│  ...                           │
└────────────────────────────────┘
```

**📙 Customer Context Layout:**
```
┌────────────────────────────────┐
│  MRS. KOWALSKI                 │  ← Heading, 28pt bold
│                                │
│  Background:                   │  ← Subheading, 20pt
│  • Elderly Polish immigrant    │  ← Bullets, 18pt
│  • Grandmother in secret       │
│    society                     │
│  • Fled Europe 1920s           │
│                                │
│  Book Characteristics:         │  ← Subheading
│  • Handwritten diary style     │
│  • Dates 1880s-1910s           │
│  • Mentions "old ways"         │
│                                │
│  Translation Hints:            │  ← Subheading
│  • Pre-WWI occult dialect      │
│  • Personal tone               │
│  • May reference locations     │
│                                │
│  [Divider line]                │
│                                │
│  DR. CHEN                      │  ← Next customer
│  ...                           │
└────────────────────────────────┘
```

**📔 Working Notes Layout:**
```
┌────────────────────────────────┐
│  CONFIRMED SYMBOLS             │  ← Heading, 24pt green
│                                │
│  ∆ = "the"                     │  ← List, 20pt
│    (3× in Texts 1, 2, 3)      │  ← Usage count, 16pt gray
│                                │
│  ◊≈ = "old"                    │
│    (3× in Texts 1, 2, 3)      │
│                                │
│  [Divider line]                │
│                                │
│  TENTATIVE                     │  ← Heading, 24pt yellow
│                                │
│  ⊞⊟≈ = "god"?                  │  ← List, 20pt
│    (ritual context, customer   │  ← Note, 16pt italic
│     mentions deity)            │
│                                │
│  [Divider line]                │
│                                │
│  MY THEORIES                   │  ← Heading, 24pt cream
│                                │
│  • Text 3 seems ritual         │  ← Player notes, 18pt
│  • Mrs. K's book is personal   │
│    diary, not formal           │
└────────────────────────────────┘
```

**Visual States:**

**Closed State:**
- Panel not visible (space occupied by old Dictionary from Phase 2)
- Or: Panel shows placeholder "Select a reference book to begin..."

**Open State (book active):**
- Panel displays content for active book
- Scrollbar appears if content exceeds 950px height
- Header shows book name in spine color
- Close button visible (× in top-right)

**Scrolling State:**
- Mouse wheel scrolls content up/down
- Scrollbar thumb indicates position
- Content fades at top/bottom edges (subtle gradient)

**Visual Feedback:**
- **On open:** Panel content fades in over 0.3 seconds
- **On scroll:** Smooth scrolling at 60fps
- **On close:** Panel content fades out over 0.2 seconds
- **On search (later):** Matching text highlights yellow

---

### What Player Does

**Input Methods:**

**Mouse:**
- Scroll wheel → Scrolls content vertically
- Drag scrollbar → Jumps to section
- Click close button (×) → Closes reference panel
- Hover over entries → Highlight (future: for clickable cross-references)

**Keyboard:**
- Arrow keys → Scrolls content if panel focused
- Page Up/Down → Jumps by full page (950px)
- Home/End → Jumps to top/bottom
- Escape → Closes panel

**Immediate Response:**
- Open book → Content appears within 0.3 seconds (fade-in)
- Scroll → Content moves immediately (no lag)
- Close → Content fades out within 0.2 seconds

**Feedback Loop:**

**Example: Looking up symbol in Grimoire**

1. **Player action:** Clicks Grimoire spine (Feature 2B.1)
2. **System response:** Reference Panel opens, displays Grimoire Index
3. **Visual change:** Panel fades in showing symbol list
4. **Player action:** Scrolls down to find symbol ⊞⊟≈
5. **Player reads:** "Symbol ⊞⊟≈: Deity symbol, ritual contexts"
6. **Player insight:** "It's probably 'god' - matches 'the old god' pattern"
7. **Player action:** Clicks × to close, returns to translation
8. **Next action:** Types "the old god sleeps" with confidence

**Example: Checking prior work**

1. **Player thought:** "I remember seeing ⊕⊗⬡ before..."
2. **Player action:** Presses "2" key (Prior Translations shortcut)
3. **System response:** Reference Panel switches to Prior Translations
4. **Visual change:** Panel shows archive, Text 2 entry visible
5. **Player scans:** Sees "⊕⊗⬡ = 'was'" in Text 2 confirmed symbols
6. **Player confirms:** "Yes, it's 'was' - I translated that correctly"
7. **Player action:** Presses Escape to close
8. **Next action:** Continues solving current puzzle

---

### Underlying Behavior

**GDScript Structure:**

```gdscript
# res://scripts/ui/ReferencePanel.gd
extends Panel

@onready var header_label = $Header/TitleLabel
@onready var close_button = $Header/CloseButton
@onready var content_scroll = $ContentScroll
@onready var content_container = $ContentScroll/ContentVBox

var current_book: String = ""  # "", "grimoire", "translations", "context", "notes"

func _ready():
	# Connect to Reference Shelf signals (Feature 2B.1)
	var shelf = get_node("/root/Main/ReferenceShelf")
	shelf.book_opened.connect(_on_book_opened)
	shelf.book_closed.connect(_on_book_closed)

	close_button.pressed.connect(_on_close_pressed)

	# Start hidden
	visible = false

func _on_book_opened(book_name: String):
	"""Display content for opened book"""
	current_book = book_name

	# Update header
	header_label.text = get_book_display_name(book_name)
	update_header_color(book_name)

	# Load and display content
	clear_content()
	load_book_content(book_name)

	# Show panel with fade-in
	modulate.a = 0
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func _on_book_closed():
	"""Hide panel"""
	current_book = ""

	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished

	visible = false

func _on_close_pressed():
	"""User clicked close button"""
	# Emit signal to Reference Shelf to close book
	get_node("/root/Main/ReferenceShelf").close_book()

func get_book_display_name(book_name: String) -> String:
	"""Get display name for header"""
	match book_name:
		"grimoire": return "GRIMOIRE INDEX"
		"translations": return "PRIOR TRANSLATIONS"
		"context": return "CUSTOMER CONTEXT"
		"notes": return "WORKING NOTES"
	return ""

func update_header_color(book_name: String):
	"""Set header color to match book spine"""
	var color: Color
	match book_name:
		"grimoire": color = Color("#8B0000")  # Red
		"translations": color = Color("#2D5016")  # Green
		"context": color = Color("#CC6600")  # Orange
		"notes": color = Color("#A0826D")  # Brown
		_: color = Color("#2A1F1A")  # Default brown

	var style = get_theme_stylebox("panel").duplicate()
	style.bg_color = color
	$Header.add_theme_stylebox_override("panel", style)

func clear_content():
	"""Remove all content nodes"""
	for child in content_container.get_children():
		child.queue_free()

func load_book_content(book_name: String):
	"""Load content from Reference Content System (Feature 2B.3)"""
	match book_name:
		"grimoire":
			load_grimoire_content()
		"translations":
			load_translations_content()
		"context":
			load_context_content()
		"notes":
			load_notes_content()

func load_grimoire_content():
	"""Display Grimoire Index entries"""
	var grimoire_data = ReferenceData.get_grimoire_data()

	for symbol in grimoire_data.keys():
		var entry = grimoire_data[symbol]

		# Symbol heading
		add_heading(symbol, 30)

		# Contexts section
		add_subheading("Known Contexts:")
		for context in entry.contexts:
			add_bullet("• " + context)

		# Historical note
		if "note" in entry and entry.note != "":
			add_subheading("Historical Note:")
			add_paragraph(entry.note)

		# Etymology
		if "etymology" in entry and entry.etymology != "":
			add_subheading("Etymology:")
			add_paragraph(entry.etymology, true)  # Italic

		# Divider
		add_divider()

func load_translations_content():
	"""Display prior translations archive"""
	var completed_texts = ReferenceData.get_completed_translations()

	for text_data in completed_texts:
		# Text heading
		add_heading("TEXT %d - Day %d" % [text_data.id, text_data.day], 24)
		add_subheading("%s, %s" % [text_data.customer, text_data.category])

		# Original symbols
		add_label("Original:")
		add_symbols(text_data.symbols, 30)

		# Translation
		add_label("Your Translation:")
		add_quote(text_data.solution)

		# Confirmed symbols
		add_label("Confirmed Symbols:")
		for sym in text_data.mappings.keys():
			add_bullet("%s = \"%s\"" % [sym, text_data.mappings[sym]])

		add_divider()

func load_context_content():
	"""Display customer context files"""
	var customers = ReferenceData.get_customer_contexts()

	for customer_name in customers.keys():
		var customer = customers[customer_name]

		# Customer name heading
		add_heading(customer_name.to_upper(), 28)

		# Background
		add_subheading("Background:")
		for point in customer.background:
			add_bullet("• " + point)

		# Book characteristics
		add_subheading("Book Characteristics:")
		for point in customer.book_characteristics:
			add_bullet("• " + point)

		# Translation hints
		add_subheading("Translation Hints:")
		for point in customer.translation_hints:
			add_bullet("• " + point)

		add_divider()

func load_notes_content():
	"""Display working notes"""
	var notes_data = ReferenceData.get_working_notes()

	# Confirmed symbols
	add_heading("CONFIRMED SYMBOLS", 24, Color("#2ECC71"))  # Green
	for symbol in notes_data.confirmed.keys():
		var word = notes_data.confirmed[symbol]
		var usage_count = notes_data.usage_counts.get(symbol, 0)
		add_bullet("%s = \"%s\"" % [symbol, word], 20)
		add_subtext("(%d× uses)" % usage_count, 16, Color("#999999"))

	add_divider()

	# Tentative symbols
	add_heading("TENTATIVE", 24, Color("#FFD700"))  # Yellow
	for symbol in notes_data.tentative.keys():
		var word = notes_data.tentative[symbol]
		var note = notes_data.tentative_notes.get(symbol, "")
		add_bullet("%s = \"%s\"?" % [symbol, word], 20)
		if note != "":
			add_subtext(note, 16, Color("#999999"), true)  # Italic

	add_divider()

	# Player theories
	add_heading("MY THEORIES", 24, Color("#F4E8D8"))  # Cream
	for theory in notes_data.theories:
		add_bullet("• " + theory, 18)

# Helper functions to add formatted content
func add_heading(text: String, font_size: int = 24, color: Color = Color("#F4E8D8")):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	content_container.add_child(label)

func add_subheading(text: String):
	add_heading(text, 20, Color("#FFD700"))  # Gold

func add_paragraph(text: String, italic: bool = false):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color("#F4E8D8"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	if italic:
		# Add italic font variant if available
		pass
	content_container.add_child(label)

func add_bullet(text: String, font_size: int = 18):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("#F4E8D8"))
	content_container.add_child(label)

func add_label(text: String):
	add_paragraph(text)

func add_symbols(text: String, font_size: int):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("#2A1F1A"))
	content_container.add_child(label)

func add_quote(text: String):
	var label = Label.new()
	label.text = "\"%s\"" % text
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("#2ECC71"))  # Green
	content_container.add_child(label)

func add_subtext(text: String, font_size: int, color: Color, italic: bool = false):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if italic:
		# Add italic font variant
		pass
	content_container.add_child(label)

func add_divider():
	var separator = HSeparator.new()
	separator.add_theme_constant_override("separation", 20)
	content_container.add_child(separator)
```

**Scene Structure:**

```
ReferencePanel (Panel)
├── Header (Panel) - 420×40px, colored by book type
│   ├── TitleLabel (Label) - Book name, centered
│   └── CloseButton (Button) - × symbol, right-aligned
└── ContentScroll (ScrollContainer) - 420×950px
    └── ContentVBox (VBoxContainer) - Dynamic content nodes
        ├── [Labels, headings, bullets added programmatically]
        └── ...
```

**Key Numbers from Design:**
- Panel size: 420×990px (same as old Dictionary)
- Header height: 40px
- Content area height: 950px
- Close button: 30×30px
- Font sizes: 30pt (symbol headings), 24pt (headings), 20pt (subheadings), 18pt (body), 16pt (notes)
- Fade-in duration: 0.3 seconds
- Fade-out duration: 0.2 seconds
- Colors: Red #8B0000, Green #2D5016, Orange #CC6600, Brown #A0826D (match spines)

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Panel occupies right side (1500, 90) to (1920, 1080)
- [ ] Header shows book name in spine color (red/green/orange/brown)
- [ ] Close button (×) visible in top-right of header
- [ ] Content area scrollable if content exceeds 950px
- [ ] Text readable (sufficient contrast, proper font sizes)
- [ ] Different book types have distinct layouts

**Interaction Checks:**
- [ ] Open book from shelf → Panel fades in over 0.3 seconds
- [ ] Click close button → Panel fades out over 0.2 seconds
- [ ] Scroll wheel → Content scrolls smoothly
- [ ] Drag scrollbar → Jumps to section
- [ ] Press Escape → Closes panel
- [ ] Switch books → Content updates to new book instantly

**Functional Checks:**
- [ ] Grimoire Index displays symbol entries (heading, contexts, notes, etymology)
- [ ] Prior Translations displays completed texts (original symbols, translation, mappings)
- [ ] Customer Context displays customer profiles (background, book characteristics, hints)
- [ ] Working Notes displays confirmed/tentative symbols + player theories
- [ ] Content loads from Reference Content System (Feature 2B.3)

**Integration Checks:**
- [ ] Listens to ReferenceShelf.book_opened signal
- [ ] Listens to ReferenceShelf.book_closed signal
- [ ] Close button triggers ReferenceShelf.close_book()
- [ ] Content updates match SymbolData state (learned symbols auto-populate Prior Translations)

**Scrolling Checks:**
- [ ] Content scrolls smoothly at 60fps
- [ ] Scrollbar appears only when content exceeds 950px
- [ ] Page Up/Down jumps by full page
- [ ] Home/End jumps to top/bottom
- [ ] Scroll position resets when switching books

**Edge Case Checks:**
- [ ] Empty content (no prior translations yet) displays placeholder "No translations completed yet"
- [ ] Long content (many entries) scrolls without lag
- [ ] Rapid book switching doesn't cause visual glitches
- [ ] Close during fade-in completes gracefully

---

### Manual Test Script

1. **Test Grimoire Index display:**
   ```
   - Click red Grimoire spine
   - Verify panel opens with red header "GRIMOIRE INDEX"
   - Verify symbol entries display:
     - Heading (symbol at 30pt)
     - Known Contexts (bulleted list)
     - Historical Note (paragraph)
     - Etymology (italic text)
   - Scroll down, verify multiple symbols listed
   ```

2. **Test Prior Translations display:**
   ```
   - Complete Text 1 ("the old way")
   - Click green Translations spine
   - Verify panel shows:
     - "TEXT 1 - Day 1"
     - Original symbols: "∆ ◊≈ ⊕⊗◈"
     - Your translation: "the old way" (green text)
     - Confirmed symbols list
   ```

3. **Test Customer Context display:**
   ```
   - Click orange Context spine
   - Verify panel shows:
     - "MRS. KOWALSKI" heading
     - Background bullets
     - Book Characteristics bullets
     - Translation Hints bullets
   - Scroll down to Dr. Chen entry
   ```

4. **Test Working Notes display:**
   ```
   - Complete Text 1
   - Click brown Notes spine
   - Verify panel shows:
     - "CONFIRMED SYMBOLS" (green heading)
     - ∆ = "the" (with usage count)
     - "TENTATIVE" section (yellow heading, empty initially)
     - "MY THEORIES" section (cream heading, empty initially)
   ```

5. **Test scrolling:**
   ```
   - Open Grimoire (long content)
   - Use mouse wheel to scroll down
   - Verify smooth scrolling (no jitter)
   - Press Page Down key
   - Verify jumps by ~950px
   - Press Home key
   - Verify jumps to top
   ```

6. **Test close behavior:**
   ```
   - Open any book
   - Click × close button
   - Verify panel fades out over ~0.2 seconds
   - Verify book spine returns to shelf
   ```

7. **Test book switching:**
   ```
   - Open Grimoire (red header)
   - Click Translations spine
   - Verify header changes to green
   - Verify content switches to Prior Translations
   - No visual glitches or leftover content
   ```

8. **Pass criteria:** All 4 book types display correctly, scrolling smooth, close/switch works

---

### Known Simplifications

**Phase 2B shortcuts:**
- No search function within reference books (scan manually)
- No bookmarks/favorites (can't mark specific entries for quick access)
- No cross-reference links (can't click symbol in Grimoire to jump to Prior Translations)
- Content is static text (no interactive elements beyond scrolling)
- No highlighting of relevant content based on current puzzle

**Technical debt:**
- Content generated programmatically (creates many Label nodes)
  - **Impact:** Works for prototype, consider RichTextLabel for production
- No content caching (regenerates on every open)
  - **Impact:** Fine for small dataset, optimize if reference books grow large
- Header color changes by replacing StyleBox (inefficient)
  - **Impact:** Imperceptible delay, acceptable for prototype

---

## Feature 2B.3: Reference Content System

**Priority:** CRITICAL - Data backbone for all reference materials.

**Tests Critical Question:** Q1 (Puzzle satisfaction) - Quality of reference content determines if research feels meaningful.

**Estimated Time:** 60 minutes

**Dependencies:**
- **Feature 1.2 (Symbol Data System)** must be complete - Grimoire references symbol definitions
- **Feature 2.2 (Translation Validation Engine)** must be complete - Prior Translations tracks completed texts
- **Feature 1.4 (Customer Data Structures)** must be complete - Customer Context references customer profiles

---

### Overview

The Reference Content System stores all data for the 4 reference books: Grimoire Index (symbol contexts), Prior Translations (completed texts archive), Customer Context (customer backgrounds), Working Notes (confirmed symbols + player theories). Provides getter functions for Reference Panel to display formatted content.

**Critical Design Constraint:** Reference data must be hint-based (contextual clues), not direct answers. Grimoire says "deity symbol, ritual contexts" not "means 'god'". Content quality is critical—bad hints = frustrating research.

---

### What Player Sees

**Screen Layout:**
- **Not directly visible** - this is pure data storage
- Content appears via Feature 2B.2 (Reference Panel)

**Visual Appearance:**
- N/A - data structure only

---

### What Player Does

**Input Methods:**
- **None** - data system is backend only
- Player interacts via Reference Panel (Feature 2B.2)

---

### Underlying Behavior

**GDScript Structure:**

```gdscript
# res://scripts/ReferenceData.gd (Autoload singleton)
extends Node

# ═══════════════════════════════════════════════════════════
# GRIMOIRE INDEX DATA
# ═══════════════════════════════════════════════════════════

var grimoire_index: Dictionary = {
	"⊞⊟≈": {
		"contexts": [
			"Blood Moon Ceremony (1847): Deity name",
			"Dream Journal (1892): 'The sleeper'",
			"Harvest Ritual (pre-1800): Nature spirit"
		],
		"note": "This symbol appears in texts associated with underground cults in the 1880s-1920s. Often paired with sleep/rest symbols.",
		"etymology": "Possibly derived from ancient Sumerian 'god' glyph, combined with Germanic 'sleep' rune."
	},
	"⬡≈≈⊢⬡": {
		"contexts": [
			"Lullaby manuscript: Rest/dormancy",
			"Ritual text: Deep slumber",
			"Medical treatise: Unconscious state"
		],
		"note": "Frequently appears after deity symbols. Suggests prolonged rest or hibernation state.",
		"etymology": "Related to proto-Germanic 'slæp' (sleep) root forms."
	},
	"⊕⊗⬡": {
		"contexts": [
			"Historical chronicles: Past tense marker",
			"Academic texts: 'Existed previously'",
			"Personal diaries: Memory references"
		],
		"note": "Common auxiliary symbol. Indicates past events or completed actions.",
		"etymology": "Derived from Latin 'erat' (was/were) symbolic representation."
	},
	"⬡∞◊⊩⊩≈⊩": {
		"contexts": [
			"Genealogy records: Lost lineages",
			"Archaeological notes: Erased history",
			"Religious texts: Forbidden knowledge"
		],
		"note": "Complex compound symbol. Suggests intentional removal or loss of memory/knowledge.",
		"etymology": "Combination of 'memory' + 'void' + 'past' glyphs."
	},
	"⊗◈⊞∞◈": {
		"contexts": [
			"Grimoire chapters: Supernatural forces",
			"Alchemical texts: Transformation power",
			"Folk tales: Wonder/miracle"
		],
		"note": "Associated with the occult and unexplained phenomena. Pre-modern understanding of physics.",
		"etymology": "From Greek 'magikos' symbolic cipher."
	},
	"◊⊩◈≈": {
		"contexts": [
			"Historical documents: Single instance",
			"Legal texts: One-time events",
			"Poetry: Unique moments"
		],
		"note": "Temporal marker indicating rarity or singularity.",
		"etymology": "Related to 'unus' (one) Latin root forms."
	},
	"⊟⊩◊⊕⊩": {
		"contexts": [
			"Academic records: Established knowledge",
			"Teaching texts: Learned information",
			"Scientific notes: Understood principles"
		],
		"note": "Indicates widespread or accepted knowledge in past times.",
		"etymology": "From 'cognoscere' (to know) Latin symbolic form."
	},
	"∆≈◊": {
		"contexts": [
			"Group references: Multiple persons",
			"Community texts: Collective entities",
			"Prophecies: Coming multitude"
		],
		"note": "Third-person plural marker. Often found in ominous or warning contexts.",
		"etymology": "Proto-Indo-European 'they/them' glyph variant."
	},
	"⊗◈≈": {
		"contexts": [
			"Existence statements: State of being",
			"Philosophical texts: Present condition",
			"Descriptions: Current attributes"
		],
		"note": "Copula/linking verb. Connects subjects to descriptions.",
		"etymology": "From 'esse' (to be) Latin root symbolic form."
	},
	"◈≈∆◊◈⊩∞⊩⊞": {
		"contexts": [
			"Prophecy texts: Coming back",
			"Cyclical rituals: Renewal/rebirth",
			"Migration records: Homecoming"
		],
		"note": "Longest known symbol group. Suggests inevitable return or cyclical pattern. Often appears in apocalyptic contexts.",
		"etymology": "Complex compound: 'again' + 'come' + 'cycle' + 'deity' components."
	},
	"⬡◊◊⊩": {
		"contexts": [
			"Prophecies: Near future",
			"Urgent messages: Imminent events",
			"Warning texts: Approaching danger"
		],
		"note": "Temporal proximity marker. Creates sense of urgency when used.",
		"etymology": "From 'sūn' (soon) Germanic root form."
	}
}

# ═══════════════════════════════════════════════════════════
# CUSTOMER CONTEXT DATA
# ═══════════════════════════════════════════════════════════

var customer_contexts: Dictionary = {
	"Mrs. Kowalski": {
		"background": [
			"Elderly Polish immigrant, sweet demeanor",
			"Grandmother was in a secret society",
			"Family fled Europe in 1920s",
			"Books are family heirlooms, very old"
		],
		"book_characteristics": [
			"Handwritten, personal diary style",
			"Dates from 1880s-1910s",
			"Mentions 'the old ways' repeatedly",
			"Some pages torn out (censored?)"
		],
		"translation_hints": [
			"Language is likely pre-WWI occult dialect",
			"Personal tone, not formal ritual",
			"May reference specific locations in Europe",
			"Family context important to understanding"
		]
	},
	"Dr. Chen": {
		"background": [
			"Academic researcher, archaeology focus",
			"Studying 'lost civilizations' in city's history",
			"Believes something ancient beneath the city",
			"Very urgent, time-sensitive research"
		],
		"book_characteristics": [
			"Mix of academic analysis + ancient text quotes",
			"References to seismic data, tremors",
			"Formal scholarly language",
			"Cites other sources (cross-reference possible)"
		],
		"translation_hints": [
			"Academic/formal tone expected",
			"Look for scientific or observational language",
			"May connect to geological events",
			"Research-focused, seeking confirmation"
		]
	},
	"The Stranger": {
		"background": [
			"Mysterious figure, minimal personal info",
			"Appears to have insider knowledge",
			"Urgent and insistent demeanor",
			"Pays extremely well (compensation for risk?)"
		],
		"book_characteristics": [
			"Ancient manuscript, possibly original source",
			"Prophetic or warning tone",
			"Direct and ominous language",
			"May be the 'source text' others reference"
		],
		"translation_hints": [
			"Likely contains direct prophecy or warning",
			"Language may be more archaic/original",
			"Pay attention to urgency markers",
			"This may answer questions from other texts"
		]
	}
}

# ═══════════════════════════════════════════════════════════
# WORKING NOTES (Auto-populated + player annotations)
# ═══════════════════════════════════════════════════════════

var working_notes: Dictionary = {
	"confirmed": {},  # {symbol: word} e.g. {"∆": "the"}
	"tentative": {},  # {symbol: word} e.g. {"⊞⊟≈": "god"}
	"usage_counts": {},  # {symbol: count} e.g. {"∆": 3}
	"tentative_notes": {},  # {symbol: note} e.g. {"⊞⊟≈": "appears in ritual context"}
	"theories": []  # ["Text 3 seems ritual", "Mrs. K's book is diary"]
}

# ═══════════════════════════════════════════════════════════
# PRIOR TRANSLATIONS (Auto-populated as player completes texts)
# ═══════════════════════════════════════════════════════════

var completed_translations: Array = []
# Structure: [
#   {
#     "id": 1,
#     "day": 1,
#     "customer": "Mrs. Kowalski",
#     "category": "Family History",
#     "symbols": "∆ ◊≈ ⊕⊗◈",
#     "solution": "the old way",
#     "mappings": {"∆": "the", "◊≈": "old", "⊕⊗◈": "way"}
#   }
# ]

# ═══════════════════════════════════════════════════════════
# GETTER FUNCTIONS
# ═══════════════════════════════════════════════════════════

func get_grimoire_data() -> Dictionary:
	"""Return Grimoire Index data"""
	return grimoire_index

func get_customer_contexts() -> Dictionary:
	"""Return Customer Context data"""
	return customer_contexts

func get_working_notes() -> Dictionary:
	"""Return Working Notes data"""
	# Auto-populate from SymbolData before returning
	update_working_notes()
	return working_notes

func get_completed_translations() -> Array:
	"""Return Prior Translations archive"""
	return completed_translations

# ═══════════════════════════════════════════════════════════
# AUTO-UPDATE FUNCTIONS
# ═══════════════════════════════════════════════════════════

func update_working_notes():
	"""Sync Working Notes with SymbolData dictionary"""
	working_notes.confirmed.clear()
	working_notes.usage_counts.clear()

	for symbol in SymbolData.SYMBOLS:
		var entry = SymbolData.get_dictionary_entry(symbol)
		if entry.word != null:
			# Symbol is learned
			working_notes.confirmed[symbol] = entry.word
			working_notes.usage_counts[symbol] = entry.learned_from.size()

func add_completed_translation(text_id: int, day: int, customer: String):
	"""Called after successful translation to archive it"""
	var text_data = SymbolData.get_text(text_id)
	if text_data.is_empty():
		return

	var archive_entry = {
		"id": text_id,
		"day": day,
		"customer": customer,
		"category": text_data.name.split(" - ")[1] if " - " in text_data.name else "Unknown",
		"symbols": text_data.symbols,
		"solution": text_data.solution,
		"mappings": text_data.mappings.duplicate()
	}

	completed_translations.append(archive_entry)

func add_theory(theory_text: String):
	"""Player adds a theory to Working Notes"""
	if theory_text.strip_edges() != "":
		working_notes.theories.append(theory_text)

func add_tentative_symbol(symbol: String, word: String, note: String = ""):
	"""Mark symbol as tentatively translated"""
	working_notes.tentative[symbol] = word
	if note != "":
		working_notes.tentative_notes[symbol] = note

func remove_tentative_symbol(symbol: String):
	"""Remove symbol from tentative (moved to confirmed)"""
	working_notes.tentative.erase(symbol)
	working_notes.tentative_notes.erase(symbol)
```

**Integration Points:**

```gdscript
# In TranslationDisplay.gd (Feature 2.1), after successful translation:

func handle_success(text_id: int):
	# ... existing success code ...

	# Archive this translation
	ReferenceData.add_completed_translation(text_id, GameState.current_day, current_customer_name)

	# Update dictionary and notes
	SymbolData.update_dictionary(text_id)
	ReferenceData.update_working_notes()
```

**Key Numbers from Design:**
- Grimoire entries: 11 symbols (all symbols that appear in 5 texts)
- Customer contexts: 3 customers (Mrs. K, Dr. Chen, The Stranger)
- Prior translations: Up to 5 entries (one per completed text)
- Working notes sections: 3 (confirmed, tentative, theories)
- Content style: Hint-based, not direct answers

---

### Acceptance Criteria

**Data Integrity Checks:**
- [ ] Grimoire Index has 11 symbol entries
- [ ] Each Grimoire entry has contexts (array), note (string), etymology (string)
- [ ] Customer Contexts has 3 entries (Mrs. K, Dr. Chen, Stranger)
- [ ] Each Customer entry has background, book_characteristics, translation_hints (all arrays)
- [ ] Working Notes has confirmed, tentative, usage_counts, tentative_notes, theories (all proper types)
- [ ] Completed Translations is empty array initially

**Content Quality Checks:**
- [ ] Grimoire hints are contextual, not direct (says "deity symbol" not "means god")
- [ ] Grimoire contexts reference historical sources (dates, document types)
- [ ] Customer contexts provide useful clues (background informs book tone)
- [ ] Etymology notes plausible (references real language roots)
- [ ] No spoilers in Grimoire (doesn't give away solutions directly)

**Auto-Update Checks:**
- [ ] `update_working_notes()` syncs with SymbolData.dictionary
- [ ] Confirmed symbols appear when SymbolData.dictionary[symbol].word != null
- [ ] Usage counts match SymbolData.dictionary[symbol].learned_from.size()
- [ ] `add_completed_translation()` archives text after success
- [ ] Archived entries have correct structure (id, day, customer, symbols, solution, mappings)

**Integration Checks:**
- [ ] Reference Panel (Feature 2B.2) calls getter functions correctly
- [ ] Grimoire entries display via `get_grimoire_data()`
- [ ] Customer contexts display via `get_customer_contexts()`
- [ ] Working notes display via `get_working_notes()`
- [ ] Prior translations display via `get_completed_translations()`

**Functional Checks:**
- [ ] Complete Text 1 → `completed_translations` gains 1 entry
- [ ] Complete Text 1 → `working_notes.confirmed` shows 3 symbols (∆, ◊≈, ⊕⊗◈)
- [ ] Complete all 5 texts → `completed_translations` has 5 entries
- [ ] Complete all 5 texts → `working_notes.confirmed` shows 15 symbols
- [ ] `add_theory("Test theory")` → `working_notes.theories` contains "Test theory"

**Edge Case Checks:**
- [ ] Call `get_working_notes()` before any translations → Returns empty confirmed dict
- [ ] Call `get_completed_translations()` before any translations → Returns empty array
- [ ] Add duplicate theory → Theory list contains duplicate (allowed)
- [ ] Archive same text twice → `completed_translations` contains duplicate (edge case, acceptable)

---

### Manual Test Script

1. **Verify Grimoire Index data:**
   ```gdscript
   var grimoire = ReferenceData.get_grimoire_data()
   print(grimoire.keys().size())  # Should be 11
   print(grimoire["⊞⊟≈"].contexts)  # Should show 3 contexts
   print(grimoire["⊞⊟≈"].note)  # Should mention "underground cults"
   ```

2. **Verify Customer Context data:**
   ```gdscript
   var customers = ReferenceData.get_customer_contexts()
   print(customers.keys())  # ["Mrs. Kowalski", "Dr. Chen", "The Stranger"]
   print(customers["Mrs. Kowalski"].background)  # Should show 4 points
   print(customers["Dr. Chen"].translation_hints)  # Should mention "academic tone"
   ```

3. **Test Working Notes auto-update:**
   ```gdscript
   # Before any translations
   var notes = ReferenceData.get_working_notes()
   print(notes.confirmed.size())  # Should be 0

   # Complete Text 1
   SymbolData.update_dictionary(1)
   notes = ReferenceData.get_working_notes()
   print(notes.confirmed.size())  # Should be 3
   print(notes.confirmed["∆"])  # Should be "the"
   print(notes.usage_counts["∆"])  # Should be 1
   ```

4. **Test Prior Translations archiving:**
   ```gdscript
   # Complete Text 1
   ReferenceData.add_completed_translation(1, 1, "Mrs. Kowalski")
   var archive = ReferenceData.get_completed_translations()
   print(archive.size())  # Should be 1
   print(archive[0].solution)  # Should be "the old way"
   print(archive[0].customer)  # Should be "Mrs. Kowalski"
   ```

5. **Test theory adding:**
   ```gdscript
   ReferenceData.add_theory("Text 3 seems ritual")
   ReferenceData.add_theory("Mrs. K's book is diary")
   var notes = ReferenceData.get_working_notes()
   print(notes.theories.size())  # Should be 2
   print(notes.theories[0])  # "Text 3 seems ritual"
   ```

6. **Test content quality (manual inspection):**
   - Read Grimoire entry for ⊞⊟≈
   - Verify: Does NOT say "means god" directly
   - Verify: DOES say "deity symbol, ritual contexts" (hints)
   - Verify: Etymology plausible (Sumerian + Germanic)

7. **Pass criteria:** All data structures correct, auto-updates work, content provides hints not answers

---

### Known Simplifications

**Phase 2B shortcuts:**
- Grimoire entries hard-coded (not loaded from JSON)
- Limited to 11 symbols (only symbols used in 5 texts)
- No symbol cross-references (Grimoire doesn't link to related symbols)
- Customer contexts don't update based on relationship (static data)
- Working notes theories are simple strings (no timestamps, categorization)

**Technical debt:**
- Grimoire content is English text (not localized)
  - **Impact:** Acceptable for prototype, externalize to JSON for full game
- Customer contexts don't reference specific texts (generic backgrounds)
  - **Impact:** Full game would add "Brought Text 2 on Day 2" tracking
- No search/filtering in data structures (linear scan only)
  - **Impact:** Fine for 11 Grimoire entries, optimize for larger reference library
- Theories stored as flat array (no organization by text or topic)
  - **Impact:** Works for prototype, add categorization in production

---

## Feature 2B.4: Working Notes System

**Priority:** MEDIUM - Enhances reference system with player input capability.

**Tests Critical Question:** Q1 (Puzzle satisfaction) + Q3 (Engaging texture) - Player feels ownership of research through note-taking.

**Estimated Time:** 30 minutes

**Dependencies:**
- **Feature 2B.2 (Reference Panel)** must be complete - Notes display in panel
- **Feature 2B.3 (Reference Content System)** must be complete - Notes data structure exists

---

### Overview

The Working Notes System allows players to add theories (text annotations) to the Working Notes reference book. Notes appear alongside auto-tracked confirmed/tentative symbols. Provides simple text input for players to document their deductions, making research feel personal.

**Critical Design Constraint:** Notes are player-created text only—no complex annotation tools (no drawing, tagging, categorization). Keep simple for prototype. Notes are local (no cloud sync, no sharing).

---

### What Player Sees

**Screen Layout:**
- **Position:** Within Working Notes reference book (Feature 2B.2), "MY THEORIES" section at bottom
- **Add Note Button:** Bottom of Working Notes panel, 360×40px
- **Note Input Popup:** Modal overlay when adding note, 600×400px centered

**Visual Appearance:**

**Add Note Button (in Working Notes panel):**
- Background: Light brown #8B7355
- Text: "+ Add Theory" in cream #F4E8D8, 20pt
- Border: 2px solid dark brown #5A4A3A
- Position: Bottom of Working Notes scroll area

**Note Input Popup:**
```
┌──────────────────────────────────────┐
│  Add Theory                          │  ← Header, brown #A0826D
│  ────────────────────────────────    │
│                                      │
│  ┌─────────────────────────────────┐│
│  │ Type your theory here...        ││  ← Text box, 560×200px
│  │                                 ││
│  │                                 ││
│  └─────────────────────────────────┘│
│                                      │
│  [Cancel]              [Save Theory] │  ← Buttons
└──────────────────────────────────────┘
```

**Theory Display (after adding):**
```
MY THEORIES

• Text 3 seems ritual, not mundane
  → use occult meanings?

• Mrs. K mentioned "grandmother's secret"
  → personal diary context?

• ⊞⊟≈ appears in Dr. Chen's research too
  → important recurring symbol
```

**Visual States:**

**Default State (no notes yet):**
- "MY THEORIES" section shows placeholder: "*No theories yet. Click + Add Theory to begin.*"
- Add Note button visible at bottom

**Has Notes State:**
- Theories listed as bullets (18pt cream text)
- Add Note button still visible (can always add more)

**Input Popup Active:**
- Modal overlay darkens background (40% opacity black)
- Popup centered on screen, visible above all content
- Text box focused, cursor blinking
- Save button disabled if text empty

**Visual Feedback:**
- **On Add button click:** Popup fades in over 0.2 seconds
- **On Save:** Popup fades out, new theory appears in list instantly
- **On Cancel:** Popup fades out, no theory added

---

### What Player Does

**Input Methods:**

**Mouse:**
- Click "+ Add Theory" button → Opens input popup
- Type in text box → Characters appear
- Click Save Theory → Adds theory, closes popup
- Click Cancel → Closes popup without saving

**Keyboard:**
- Type in text box → Normal text input
- Press Enter (Ctrl+Enter) → Same as clicking Save
- Press Escape → Same as clicking Cancel

**Immediate Response:**
- Click Add button → Popup appears within 0.2 seconds
- Type character → Text appears within 16ms (single frame)
- Click Save → Theory appears in list instantly, popup closes

**Feedback Loop:**

**Example: Adding a theory about Text 3**

1. **Player thought:** "Text 3 mentions 'god' and 'sleeps' - sounds like ritual language"
2. **Player action:** Opens Working Notes reference (presses "4" key)
3. **Player action:** Scrolls to bottom, clicks "+ Add Theory"
4. **System response:** Popup appears with empty text box
5. **Player action:** Types "Text 3 seems ritual - use occult meanings?"
6. **Player action:** Presses Enter key
7. **System response:** Popup closes, theory appears in "MY THEORIES" list
8. **Visual change:** Bullet appears: "• Text 3 seems ritual - use occult meanings?"
9. **Player perception:** "I've documented my thinking - I can reference this later"
10. **Next action:** Returns to translation with documented strategy

**Example: Reviewing past theories**

1. **Player thought:** "What did I conclude about Text 3 before?"
2. **Player action:** Opens Working Notes (presses "4")
3. **Player action:** Scrolls to "MY THEORIES" section
4. **Player reads:** "Text 3 seems ritual - use occult meanings?"
5. **Player confirms:** "Right, I should check the Grimoire for ritual contexts"
6. **Player action:** Closes Notes, opens Grimoire (presses "1")
7. **Next action:** Looks up symbol in Grimoire with ritual context in mind

---

### Underlying Behavior

**GDScript Structure:**

```gdscript
# res://scripts/ui/NoteInputPopup.gd
extends Panel

signal theory_saved(theory_text: String)

@onready var text_edit = $VBoxContainer/TextEdit
@onready var save_button = $VBoxContainer/ButtonRow/SaveButton
@onready var cancel_button = $VBoxContainer/ButtonRow/CancelButton

func _ready():
	save_button.pressed.connect(_on_save_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	text_edit.text_changed.connect(_on_text_changed)

	# Start hidden
	visible = false
	modulate.a = 0

func show_popup():
	"""Display popup with fade-in"""
	text_edit.text = ""
	save_button.disabled = true

	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	await tween.finished

	text_edit.grab_focus()

func hide_popup():
	"""Hide popup with fade-out"""
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	await tween.finished

	visible = false

func _on_text_changed():
	"""Enable/disable Save button based on text content"""
	save_button.disabled = text_edit.text.strip_edges().is_empty()

func _on_save_pressed():
	"""Save theory and close"""
	var theory = text_edit.text.strip_edges()
	if theory.is_empty():
		return

	theory_saved.emit(theory)
	hide_popup()

func _on_cancel_pressed():
	"""Close without saving"""
	hide_popup()

func _input(event):
	"""Keyboard shortcuts"""
	if not visible:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_on_cancel_pressed()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ENTER and event.ctrl_pressed:
			_on_save_pressed()
			get_viewport().set_input_as_handled()
```

**Integration with Reference Panel:**

```gdscript
# In ReferencePanel.gd (Feature 2B.2), add to load_notes_content():

func load_notes_content():
	"""Display working notes"""
	# ... existing confirmed/tentative code ...

	add_divider()

	# Player theories section
	add_heading("MY THEORIES", 24, Color("#F4E8D8"))

	var notes_data = ReferenceData.get_working_notes()
	if notes_data.theories.is_empty():
		add_paragraph("*No theories yet. Click + Add Theory to begin.*", true)
	else:
		for theory in notes_data.theories:
			add_bullet("• " + theory, 18)

	# Add Theory button
	var add_button = Button.new()
	add_button.text = "+ Add Theory"
	add_button.custom_minimum_size = Vector2(360, 40)
	add_button.pressed.connect(_on_add_theory_pressed)
	content_container.add_child(add_button)

func _on_add_theory_pressed():
	"""Show note input popup"""
	var popup = get_node("/root/Main/NoteInputPopup")
	popup.show_popup()

# Connect popup signal in _ready():
func _ready():
	# ... existing code ...

	var popup = get_node("/root/Main/NoteInputPopup")
	popup.theory_saved.connect(_on_theory_saved)

func _on_theory_saved(theory_text: String):
	"""Add theory to ReferenceData and refresh display"""
	ReferenceData.add_theory(theory_text)

	# Refresh Working Notes display
	if current_book == "notes":
		clear_content()
		load_notes_content()
```

**Scene Structure:**

```
Main (root scene)
└── NoteInputPopup (Panel) - 600×400px, centered
    └── VBoxContainer
        ├── HeaderLabel (Label) - "Add Theory"
        ├── TextEdit (TextEdit) - 560×200px, multi-line
        └── ButtonRow (HBoxContainer)
            ├── CancelButton (Button) - "Cancel"
            └── SaveButton (Button) - "Save Theory"
```

**Key Numbers from Design:**
- Popup size: 600×400px
- Text box size: 560×200px
- Max theory length: 500 characters (enforced in text box)
- Add button size: 360×40px
- Button font: 20pt
- Theory display font: 18pt

---

### Acceptance Criteria

**Visual Checks:**
- [ ] "+ Add Theory" button visible at bottom of Working Notes
- [ ] Button is 360×40px, light brown #8B7355
- [ ] Popup is 600×400px, centered on screen
- [ ] Text box is 560×200px, multi-line enabled
- [ ] Save/Cancel buttons visible in popup footer
- [ ] Modal overlay darkens background when popup open

**Interaction Checks:**
- [ ] Click "+ Add Theory" → Popup appears
- [ ] Type in text box → Characters appear immediately
- [ ] Click Save with empty text → Button disabled (can't save)
- [ ] Type text, click Save → Theory added to list, popup closes
- [ ] Click Cancel → Popup closes, no theory added
- [ ] Press Escape → Same as Cancel
- [ ] Press Ctrl+Enter → Same as Save

**Functional Checks:**
- [ ] Added theories appear in "MY THEORIES" section
- [ ] Theories persist across reference book opens/closes
- [ ] Theories display as bullets (18pt cream text)
- [ ] Empty theories section shows placeholder text
- [ ] Multiple theories can be added (no limit in prototype)
- [ ] ReferenceData.add_theory() called on Save

**Integration Checks:**
- [ ] NoteInputPopup emits theory_saved signal
- [ ] ReferencePanel listens to theory_saved signal
- [ ] Theory added to ReferenceData.working_notes.theories array
- [ ] Working Notes display refreshes after adding theory
- [ ] Theories survive switching between reference books

**Polish Checks:**
- [ ] Popup fade-in smooth (0.2 seconds)
- [ ] Popup fade-out smooth (0.2 seconds)
- [ ] Text box focused on popup open (cursor blinking)
- [ ] Save button disabled when text empty (visual feedback)
- [ ] Save button enabled when text present

**Edge Case Checks:**
- [ ] Add theory with only whitespace "   " → Stripped, treated as empty
- [ ] Add very long theory (500+ chars) → Text box enforces max length
- [ ] Open popup, close immediately → No crash, no empty theory added
- [ ] Add theory, switch to different reference, come back → Theory still visible

---

### Manual Test Script

1. **Test Add Theory button:**
   ```
   - Open Working Notes (press "4")
   - Scroll to bottom
   - Verify "+ Add Theory" button visible (360×40px, light brown)
   - Click button
   - Verify popup appears, fades in over ~0.2 seconds
   ```

2. **Test theory input:**
   ```
   - Type "Text 3 seems ritual"
   - Verify text appears character-by-character
   - Verify Save button enabled (was disabled when empty)
   - Click Save
   - Verify popup closes
   - Verify theory appears in "MY THEORIES" list
   ```

3. **Test Cancel behavior:**
   ```
   - Click "+ Add Theory" again
   - Type "This is a test"
   - Click Cancel (don't save)
   - Verify popup closes
   - Verify theory NOT added to list (only previous theory visible)
   ```

4. **Test keyboard shortcuts:**
   ```
   - Click "+ Add Theory"
   - Type "Testing Enter key"
   - Press Ctrl+Enter
   - Verify theory saved, popup closes
   - Click "+ Add Theory"
   - Press Escape
   - Verify popup closes without saving
   ```

5. **Test multiple theories:**
   ```
   - Add theory 1: "First theory"
   - Add theory 2: "Second theory"
   - Add theory 3: "Third theory"
   - Verify all 3 visible in list as bullets
   - Close Working Notes, reopen
   - Verify all 3 still present (persist)
   ```

6. **Test empty input handling:**
   ```
   - Click "+ Add Theory"
   - Leave text box empty, click Save
   - Verify nothing happens (button disabled)
   - Type "Test", delete all text
   - Verify Save button disabled again
   - Type "   " (only spaces)
   - Click Save
   - Verify treated as empty, not added
   ```

7. **Pass criteria:** Theories can be added, display correctly, persist across opens, keyboard shortcuts work

---

### Known Simplifications

**Phase 2B shortcuts:**
- No edit/delete functionality (can't modify theories after adding)
- No categorization or tagging (flat list only)
- No timestamps (can't see when theory was added)
- No theory linking (can't reference specific symbols or texts)
- Simple text only (no markdown, formatting, or images)

**Technical debt:**
- Theories stored as strings in array (no metadata)
  - **Impact:** Works for prototype, add timestamps/tags in production
- No save/load persistence (theories lost on game restart)
  - **Impact:** Acceptable for prototype, add save system later
- Text box doesn't auto-resize (fixed 200px height)
  - **Impact:** Fine for short theories, expand for longer notes in full game
- No theory search or filtering
  - **Impact:** Works for small number of theories, add for larger lists

---

## Feature 2B.5: Cross-Reference Hints System

**Priority:** LOW - Nice-to-have enhancement, not critical for prototype.

**Tests Critical Question:** Q1 (Puzzle satisfaction) - Automatic hints make research feel rewarding, not tedious.

**Estimated Time:** 30 minutes

**Dependencies:**
- **Feature 2B.1 (Reference Library Shelf)** must be complete - Hints trigger shelf book highlights
- **Feature 2B.2 (Reference Panel)** must be complete - Hints appear in panel content
- **Feature 2B.3 (Reference Content System)** must be complete - Hints reference content data
- **Feature 2.1 (Translation Display System)** must be complete - Hints react to current puzzle

---

### Overview

The Cross-Reference Hints System automatically highlights reference books on the shelf when they contain relevant information for the current puzzle. Shows subtle glow effect and displays hint text when hovering. Makes research feel guided without being hand-holding.

**Critical Design Constraint:** Hints must be subtle (not intrusive). Player should discover relevance, hints just point to where to look. Hints are contextual (different per puzzle), not generic.

---

### What Player Sees

**Screen Layout:**
- **Reference Shelf:** Book spines glow when relevant (Feature 2B.1)
- **Tooltip on Hover:** Shows hint text when hovering glowing book
- **Panel Content:** Relevant entries auto-highlighted when opened

**Visual Appearance:**

**Glowing Book Spine (relevant content detected):**
- Glow effect: Subtle 3px orange #FFD700 aura around spine
- Pulsing: Glow fades in/out over 2 seconds (breathe effect)
- Hint badge: Small "!" icon in top-right corner of spine

**Hover Tooltip (glowing book):**
```
[!] This book may contain useful information:
    "Symbol ⊞⊟≈ appears in ritual contexts"
    
    Click to consult Grimoire Index
```

**Highlighted Entry (in Reference Panel):**
```
┌────────────────────────────────┐
│  Symbol: ⊞⊟≈                   │  ← Heading has yellow highlight bg
│  [!] RELEVANT TO CURRENT TEXT  │  ← Badge below heading
│                                │
│  Known Contexts:               │
│  • Blood Moon Ceremony (deity) │  ← Highlighted in yellow
│  ...                           │
└────────────────────────────────┘
```

**Visual States:**

**No Hints Active:**
- All book spines normal appearance (no glow)
- No tooltips appear on hover
- Reference content displays normally (no highlights)

**Hints Active (relevant content detected):**
- Grimoire spine glows if current puzzle symbols have Grimoire entries
- Prior Translations glows if similar symbols were used before
- Customer Context glows if current customer has relevant background
- Working Notes always available (no hint needed)

**Visual Feedback:**
- **On puzzle load:** Relevant books start glowing within 0.5 seconds
- **On hover:** Tooltip appears instantly (<16ms)
- **On open:** Relevant entries highlighted in yellow
- **On solve:** Glows fade out over 1 second

---

### What Player Does

**Input Methods:**
- **None directly** - system is automatic
- Player observes glowing books, hovers to see hints
- Player clicks glowing book to consult (same as normal)

**Immediate Response:**
- Puzzle loads → Relevant books glow within 0.5 seconds
- Hover glowing book → Tooltip appears instantly
- Open glowing book → See highlighted entries immediately

**Feedback Loop:**

**Example: Stuck on symbol ⊞⊟≈**

1. **Player thought:** "I don't know what ⊞⊟≈ means..."
2. **System automatic:** Detects ⊞⊟≈ in current puzzle symbols
3. **Visual change:** Grimoire spine starts glowing orange (subtle pulse)
4. **Player notices:** "The Grimoire is glowing - it might have info"
5. **Player action:** Hovers over Grimoire spine
6. **System response:** Tooltip appears: "[!] This book may contain useful information: 'Symbol ⊞⊟≈ appears in ritual contexts'"
7. **Player thought:** "Ah, the Grimoire has an entry for this symbol!"
8. **Player action:** Clicks Grimoire spine
9. **System response:** Reference Panel opens, ⊞⊟≈ entry has yellow highlight
10. **Player perception:** "The system is guiding me to the right reference - helpful!"
11. **Next action:** Reads highlighted entry, gains context clues

---

### Underlying Behavior

**GDScript Structure:**

```gdscript
# res://scripts/ui/CrossReferenceHints.gd
extends Node

var current_puzzle_symbols: Array = []  # Symbols in current puzzle
var active_hints: Dictionary = {
	"grimoire": false,
	"translations": false,
	"context": false
}

func _ready():
	# Connect to translation display (Feature 2.1)
	var display = get_node("/root/Main/TranslationDisplay")
	# Would need signal from TranslationDisplay when text loads
	# For prototype, call update_hints() manually

func update_hints(text_id: int):
	"""Analyze current puzzle and activate relevant hints"""
	var text_data = SymbolData.get_text(text_id)
	if text_data.is_empty():
		clear_hints()
		return

	# Extract symbols from text
	current_puzzle_symbols = text_data.symbols.split(" ")

	# Check Grimoire relevance
	active_hints.grimoire = check_grimoire_relevance()

	# Check Prior Translations relevance
	active_hints.translations = check_translations_relevance()

	# Check Customer Context relevance
	active_hints.context = check_context_relevance(text_id)

	# Apply visual hints to Reference Shelf
	apply_shelf_hints()

func check_grimoire_relevance() -> bool:
	"""Check if Grimoire has entries for unknown symbols"""
	var grimoire_data = ReferenceData.get_grimoire_data()

	for symbol in current_puzzle_symbols:
		# Check if symbol is unknown (not in dictionary)
		var dict_entry = SymbolData.get_dictionary_entry(symbol)
		if dict_entry.word == null:
			# Symbol is unknown, check if Grimoire has entry
			if symbol in grimoire_data:
				return true  # Grimoire has relevant info

	return false  # No unknown symbols have Grimoire entries

func check_translations_relevance() -> bool:
	"""Check if prior translations contain current puzzle symbols"""
	var completed = ReferenceData.get_completed_translations()

	for translation in completed:
		for symbol in current_puzzle_symbols:
			if symbol in translation.symbols:
				return true  # Symbol appeared in previous text

	return false

func check_context_relevance(text_id: int) -> bool:
	"""Check if customer context has relevant hints"""
	# For prototype, always true if customer context exists
	# Full implementation would check customer name, book type, etc.
	var text_data = SymbolData.get_text(text_id)
	var customer = get_customer_for_text(text_data.name)

	if customer != "":
		var contexts = ReferenceData.get_customer_contexts()
		return customer in contexts

	return false

func get_customer_for_text(text_name: String) -> String:
	"""Determine which customer brought this text"""
	# Simplified mapping for prototype
	if "Family History" in text_name:
		return "Mrs. Kowalski"
	elif "Research" in text_name or "god" in text_name.to_lower():
		return "Dr. Chen"
	elif "Return" in text_name:
		return "The Stranger"
	return ""

func apply_shelf_hints():
	"""Apply glow effects to relevant reference books"""
	var shelf = get_node("/root/Main/ReferenceShelf")

	# Grimoire glow
	if active_hints.grimoire:
		apply_glow(shelf.grimoire_spine, "Symbol entries available")
	else:
		remove_glow(shelf.grimoire_spine)

	# Translations glow
	if active_hints.translations:
		apply_glow(shelf.translations_spine, "Similar symbols seen before")
	else:
		remove_glow(shelf.translations_spine)

	# Context glow
	if active_hints.context:
		apply_glow(shelf.context_spine, "Customer background may help")
	else:
		remove_glow(shelf.context_spine)

func apply_glow(spine: Control, hint_text: String):
	"""Add glow effect and tooltip to book spine"""
	# Add glow shader/material
	var glow_effect = StyleBoxFlat.new()
	glow_effect.set_border_width_all(3)
	glow_effect.border_color = Color("#FFD700")  # Gold
	glow_effect.shadow_color = Color("#FFD700")
	glow_effect.shadow_size = 5
	spine.add_theme_stylebox_override("normal", glow_effect)

	# Pulse animation
	var tween = create_tween().set_loops()
	tween.tween_property(glow_effect, "shadow_color:a", 0.3, 1.0)
	tween.tween_property(glow_effect, "shadow_color:a", 0.8, 1.0)

	# Update tooltip
	spine.tooltip_text = "[!] This book may contain useful information:\n    \"%s\"\n\nClick to consult" % hint_text

	# Add hint badge (!)
	if not spine.has_node("HintBadge"):
		var badge = Label.new()
		badge.name = "HintBadge"
		badge.text = "!"
		badge.add_theme_font_size_override("font_size", 18)
		badge.add_theme_color_override("font_color", Color("#FFD700"))
		badge.position = Vector2(spine.size.x - 20, 5)
		spine.add_child(badge)

func remove_glow(spine: Control):
	"""Remove glow effect from book spine"""
	spine.remove_theme_stylebox_override("normal")

	# Remove hint badge if exists
	if spine.has_node("HintBadge"):
		spine.get_node("HintBadge").queue_free()

func clear_hints():
	"""Remove all active hints"""
	active_hints = {"grimoire": false, "translations": false, "context": false}
	apply_shelf_hints()

func highlight_relevant_entries(book_name: String, panel: Control):
	"""Highlight relevant entries when reference panel opens"""
	if book_name == "grimoire" and active_hints.grimoire:
		# Highlight unknown symbols in Grimoire
		# (Implementation would search panel content for symbol headings)
		pass
	elif book_name == "translations" and active_hints.translations:
		# Highlight prior texts with matching symbols
		pass
	elif book_name == "context" and active_hints.context:
		# Highlight customer that brought current text
		pass
```

**Integration Points:**

```gdscript
# In TranslationDisplay.gd (Feature 2.1), when loading text:

func load_text(text_id: int):
	# ... existing load code ...

	# Trigger cross-reference hints
	var hints = get_node("/root/Main/CrossReferenceHints")
	hints.update_hints(text_id)

# In ReferencePanel.gd (Feature 2B.2), when opening book:

func _on_book_opened(book_name: String):
	# ... existing open code ...

	# Highlight relevant entries
	var hints = get_node("/root/Main/CrossReferenceHints")
	hints.highlight_relevant_entries(book_name, self)
```

**Key Numbers from Design:**
- Glow border width: 3px
- Glow color: Gold #FFD700
- Pulse duration: 2 seconds (1s fade out, 1s fade in)
- Hint badge size: 18pt "!" symbol
- Tooltip delay: Instant (<16ms)
- Hint activation delay: 0.5 seconds after puzzle loads

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Glowing book spine has 3px gold #FFD700 aura
- [ ] Glow pulses smoothly (2-second cycle)
- [ ] Hint badge "!" appears in top-right of glowing spine
- [ ] Tooltip shows hint text on hover
- [ ] Non-glowing spines appear normal (no glow)

**Functional Checks:**
- [ ] Grimoire glows when puzzle contains unknown symbols with Grimoire entries
- [ ] Translations glows when puzzle contains symbols seen in prior texts
- [ ] Context glows when current customer has context file
- [ ] Hints activate within 0.5 seconds of puzzle load
- [ ] Hints clear when puzzle solved (glow fades out)

**Integration Checks:**
- [ ] Hints update when TranslationDisplay.load_text() called
- [ ] Glow applies to ReferenceShelf book spines
- [ ] Tooltip text matches hint relevance (different per book)
- [ ] Highlighted entries appear when Reference Panel opens

**Behavior Checks:**
- [ ] Text 1 (all unknown) → Grimoire glows (all symbols have entries)
- [ ] Text 2 (reuses Text 1 symbols) → Translations glows (symbols seen before)
- [ ] Text 3 (Mrs. K's book) → Context glows (customer file exists)
- [ ] Working Notes never glows (always available, no hint needed)

**Edge Case Checks:**
- [ ] Puzzle with no unknown symbols → No Grimoire glow
- [ ] First puzzle (no prior translations) → No Translations glow
- [ ] Random one-time customer → No Context glow
- [ ] Switch puzzles rapidly → Hints update correctly, no stale glows

---

### Manual Test Script

1. **Test Grimoire hints:**
   ```
   - Load Text 1 (all symbols unknown)
   - Verify: Grimoire spine glows gold (3px aura, pulsing)
   - Verify: Hint badge "!" visible on Grimoire
   - Hover Grimoire
   - Verify: Tooltip appears with hint text
   - Click Grimoire
   - Verify: Relevant symbols highlighted in panel (yellow bg)
   ```

2. **Test Prior Translations hints:**
   ```
   - Complete Text 1
   - Load Text 2 (reuses ∆, ◊≈, ⊕⊗◈)
   - Verify: Translations spine glows (symbols seen before)
   - Hover Translations
   - Verify: Tooltip says "Similar symbols seen before"
   - Open Translations
   - Verify: Text 1 entry highlighted (contains matching symbols)
   ```

3. **Test Customer Context hints:**
   ```
   - Load Text 1 (Mrs. Kowalski's book)
   - Verify: Context spine glows
   - Hover Context
   - Verify: Tooltip says "Customer background may help"
   - Open Context
   - Verify: Mrs. Kowalski entry highlighted
   ```

4. **Test hint clearing:**
   ```
   - Load Text 1 (multiple hints active)
   - Verify: 2-3 books glowing
   - Submit correct translation
   - Verify: Glows fade out over 1 second
   - Load next text
   - Verify: New hints activate (may be different books)
   ```

5. **Test hint accuracy:**
   ```
   - Load Text 4 (only ⊕⊗⬡ known from Text 2)
   - Verify: Grimoire glows (unknown symbols have entries)
   - Verify: Translations glows (⊕⊗⬡ appeared in Text 2)
   - Verify: Context glows if customer relevant
   ```

6. **Pass criteria:** Hints activate correctly, glow effect visible, tooltips helpful, highlights work

---

### Known Simplifications

**Phase 2B shortcuts:**
- Simple glow effect (no advanced particles or animations)
- Binary hints (glow yes/no, not intensity levels)
- Generic tooltip text (not specific to which symbols)
- No hint dismissal (can't turn off hints if player wants challenge)
- Highlights entire entries (not specific lines within entries)

**Technical debt:**
- Hint logic is basic (doesn't weight relevance, just yes/no)
  - **Impact:** Works for prototype, add relevance scoring in full game
- Glow effect uses StyleBox (not shader)
  - **Impact:** Less performant than shader, refactor if many glows
- No hint history (can't see past hints after closing references)
  - **Impact:** Not needed for prototype, add hint log later
- Pulse animation restarts on every hint update
  - **Impact:** Minor visual glitch, acceptable for prototype

---

## Phase 2B Complete!

**Total Features:** 5 (2B.1 through 2B.5)
**Total Estimated Time:** 3 hours (30 + 45 + 60 + 30 + 30 = 195 minutes)
**Reference System Functional:** ✓ Player can consult 4 reference books, cross-reference materials, add notes, receive hints

**Ready for Phase 3:** Customer queue, accept/refuse mechanics, relationship tracking (with reference system enhancing puzzle-solving)

---

## INTEGRATION WITH EXISTING PHASES

**Phase 2 (Core Puzzle Loop) Changes:**
- Dictionary Panel (right side) → **Replaced by Reference Panel** (Feature 2B.2)
- Static symbol list → **Dynamic reference content** (4 book types)
- Auto-fill only → **Auto-fill + research tools** (Grimoire, Context, Notes)

**Phase 2B Enhancements:**
- Translation becomes **scholarship** (consult sources, cross-reference, document theories)
- Late-game puzzles require **research** (not just pattern matching + typing)
- Player builds **knowledge base** (Prior Translations archive, Working Notes theories)
- System provides **gentle guidance** (Cross-Reference Hints) without hand-holding

**Testing Strategy:**
- Test each 2B feature in isolation first
- Then test full integration: Load puzzle → See hints → Consult Grimoire → Check Prior Translations → Add theory → Solve puzzle
- Verify reference system doesn't slow down players who want fast-paced solving (all references are optional)
- Verify reference system provides meaningful value (puzzles solvable faster WITH references than without)

**Success Metric:** After Phase 2B, does research feel **rewarding** (detective work, "aha!" moments) or **tedious** (busywork, interrupts flow)? Player feedback determines if system stays or gets simplified.