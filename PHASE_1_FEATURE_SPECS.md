# PHASE 1: FOUNDATION - Detailed Feature Specifications

**Phase Goal:** Core data structures exist, UI layout visible, game can track state.

**Time Budget:** 2 hours (Hours 0-2)

**Features in Phase:**
- 1.1 Game State Manager
- 1.2 Symbol Data System
- 1.3 UI Workspace Layout
- 1.4 Customer Data Structures

**Context:** Glyphic is a translation shop prototype testing whether puzzle-solving + capacity management creates strategic tension. Phase 1 establishes the foundation—everything built after this queries or renders into these systems.

---

## Feature 1.1: Game State Manager

**Priority:** CRITICAL - Every other feature depends on this as the single source of truth for game state.

**Tests Critical Question:** Foundation for Q2 (strategic tension) - Tracks capacity and money pressure that creates choices.

**Estimated Time:** 30 minutes

**Dependencies:** None - foundation feature, must be built first.

---	

### Overview

The Game State Manager is an autoload singleton (`GameState.gd`) that maintains all global game variables: current day (1-7), day name (Monday-Sunday), player cash (starts $100), capacity used (0/5 slots), and handles state transitions (day advance, utility deductions, rent checks). This is the backbone—all UI elements query it for display values, all transactions modify it.

**Critical Design Constraint:** This must be an autoload singleton accessible globally via `GameState.current_day`, `GameState.player_cash`, etc. No scene should maintain its own separate day/money tracking.

---

### What Player Sees

**Screen Layout:**
- Position: Top bar, spans full width (1280px)
- Components displayed:
  - **Day tracker:** Top-left corner (20px from left, 20px from top)
  - **Capacity counter:** Top-center (590px from left, 20px from top)
  - **Cash counter:** Top-right corner (1180px from left, 20px from top)

**Visual Appearance:**
- **Day tracker:**
  - Text: "Day 1 - Monday" (or current day name)
  - Font: Serif, 18pt, dark brown #3A2518
  - Background: Cream parchment #F4E8D8 (rounded rectangle, 10px radius)
  - Size: Auto-width (fits text), 30px height

- **Capacity counter:**
  - Text: "0/5 Customers Served"
  - Font: Sans-serif, 16pt, gray #666666
  - Background: None (transparent)
  - Size: 200px width, 30px height

- **Cash counter:**
  - Text: "$100" (or current amount)
  - Font: Sans-serif, 24pt bold
  - Color: Dynamic based on value:
    - Green #2D5016 if cash ≥ $200 (above rent threshold)
    - Orange #CC6600 if cash $100-$199 (warning zone)
    - Red #8B0000 if cash < $100 (danger zone)
  - Background: None (transparent)
  - Size: 80px width, 30px height

**Visual States:**
- **Default:** Displays current values (Day 1, $100, 0/5)
- **Day transition:** Numbers update instantly (no animation for prototype)
- **Transaction:** Cash counter updates immediately when money changes
- **Capacity update:** Counter increments when customer accepted (0/5 → 1/5 → ... → 5/5)
- **No error states needed** - this is pure data storage

**Visual Feedback:**
- On day advance: Day tracker updates from "Day 1 - Monday" → "Day 2 - Tuesday"
- On cash change: Cash counter updates amount and may change color (green → orange → red thresholds)
- On capacity change: Denominator updates (0/5 → 1/5 → 2/5...)
- **No animations in Phase 1** - instant value updates only

---

### What Player Does

**Input Methods:**
- **None for Phase 1** - This is a passive data store
- Other systems will modify values (customer acceptance, translation completion, day end)
- Player only **observes** values changing in response to their actions elsewhere

**Immediate Response:**
- When game launches → See Day 1, $100, 0/5 displayed immediately
- When other features modify state → Values update on screen within same frame
- **No player input directly to this feature** - it's pure data + display

**Feedback Loop:**
1. Game launches or day advances
2. GameState initializes/updates internal variables
3. UI labels query GameState and display current values
4. Player sees current state at all times in top bar

**Example State Flow:**
```
Game Start:
→ GameState.current_day = 1, day_name = "Monday", player_cash = 100, capacity_used = 0
→ Top bar displays: "Day 1 - Monday" | "0/5 Customers Served" | "$100" (green)

Player accepts customer (later phase):
→ GameState.capacity_used += 1
→ Top bar updates: "1/5 Customers Served"

Player completes translation earning $50:
→ GameState.player_cash += 50
→ Top bar updates: "$150" (green)

Day ends:
→ GameState.current_day = 2, day_name = "Tuesday", player_cash -= 30 (utilities)
→ Top bar updates: "Day 2 - Tuesday" | "$120" (orange, now in warning zone)
```

---

### Underlying Behavior

**Data Structure (GDScript):**
```gdscript
# res://scripts/GameState.gd (Autoload singleton)

extends Node

# Core state variables
var current_day: int = 1
var day_name: String = "Monday"
var player_cash: int = 100
var capacity_used: int = 0
var max_capacity: int = 5

# Constants from design doc
const DAILY_UTILITIES: int = 30
const WEEKLY_RENT: int = 200
const RENT_DUE_DAY: int = 5  # Friday
const STARTING_CASH: int = 100

# Day name mapping
const DAY_NAMES: Array = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

func _ready():
	reset_game_state()

func reset_game_state():
	current_day = 1
	day_name = DAY_NAMES[0]
	player_cash = STARTING_CASH
	capacity_used = 0
	max_capacity = 5

func advance_day():
	# Deduct utilities
	player_cash -= DAILY_UTILITIES

	# Advance day counter
	current_day += 1
	if current_day <= 7:
		day_name = DAY_NAMES[current_day - 1]

	# Reset daily capacity
	capacity_used = 0

	# Check rent deadline on Friday
	if current_day == RENT_DUE_DAY:
		check_rent_payment()

func check_rent_payment():
	if player_cash >= WEEKLY_RENT:
		player_cash -= WEEKLY_RENT
		# Show success message (Phase 4)
	else:
		# Trigger game over (Phase 4)
		pass

func add_cash(amount: int):
	player_cash += amount

func increment_capacity():
	capacity_used += 1

func can_accept_customer() -> bool:
	return capacity_used < max_capacity

func get_cash_color() -> Color:
	if player_cash >= 200:
		return Color("#2D5016")  # Green
	elif player_cash >= 100:
		return Color("#CC6600")  # Orange
	else:
		return Color("#8B0000")  # Red
```

**UI Display Script (attached to top bar labels):**
```gdscript
# Attached to DayLabel node
extends Label

func _process(_delta):
	text = "Day %d - %s" % [GameState.current_day, GameState.day_name]

# Attached to CapacityLabel node
extends Label

func _process(_delta):
	text = "%d/%d Customers Served" % [GameState.capacity_used, GameState.max_capacity]

# Attached to CashLabel node
extends Label

func _process(_delta):
	text = "$%d" % GameState.player_cash
	modulate = GameState.get_cash_color()
```

**Key Numbers from Design Doc:**
- Starting cash: $100 (STARTING_CASH constant)
- Daily utilities: $30 (DAILY_UTILITIES constant)
- Weekly rent: $200 due Friday (WEEKLY_RENT, RENT_DUE_DAY constants)
- Daily capacity: 5 translation slots (max_capacity)
- Week length: 7 days, Monday-Sunday (DAY_NAMES array)

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Day tracker visible at top-left (20, 20), shows "Day 1 - Monday" in serif 18pt #3A2518
- [ ] Capacity counter visible at top-center (590, 20), shows "0/5 Customers Served" in sans 16pt #666
- [ ] Cash counter visible at top-right (1180, 20), shows "$100" in sans bold 24pt green #2D5016
- [ ] Day tracker has cream parchment background (#F4E8D8, 10px radius)
- [ ] All text is readable with no overlap or truncation
- [ ] Cash color is green when ≥$200, orange when $100-$199, red when <$100

**Functional Checks:**
- [ ] GameState is accessible globally (can call `GameState.current_day` from any script)
- [ ] Initial values match design doc: day=1, day_name="Monday", cash=$100, capacity=0/5
- [ ] `GameState.advance_day()` increments current_day, updates day_name, deducts $30 utilities
- [ ] `GameState.add_cash(50)` increases player_cash by $50
- [ ] `GameState.increment_capacity()` increases capacity_used by 1
- [ ] `GameState.can_accept_customer()` returns true when <5, false when =5
- [ ] `GameState.get_cash_color()` returns correct color for thresholds (green ≥$200, orange $100-199, red <$100)
- [ ] Day names cycle correctly: Monday → Tuesday → ... → Sunday
- [ ] Capacity resets to 0/5 when day advances

**Integration Checks:**
- [ ] UI labels update in real-time when GameState values change
- [ ] Multiple scenes can access same GameState (singleton pattern works)
- [ ] No duplicate GameState nodes exist (autoload configured correctly)
- [ ] Values persist across scene changes (if applicable)

**Edge Case Checks:**
- [ ] Day 7 (Sunday) doesn't advance to Day 8 (or handles gracefully)
- [ ] Negative cash displays correctly (shows "-$50" not "$-50")
- [ ] Capacity can't exceed max_capacity (5/5 enforced)
- [ ] Cash color updates instantly when crossing thresholds

---

### Manual Test Script

1. **Launch game in Godot Editor (F5)**
2. **Verify initial display:**
   - Top-left shows "Day 1 - Monday"
   - Top-center shows "0/5 Customers Served"
   - Top-right shows "$100" in green
3. **Open debugger, run GDScript:**
   ```gdscript
   GameState.add_cash(50)
   ```
   - Verify cash updates to "$150" (still green)
4. **Run:**
   ```gdscript
   GameState.player_cash = 180
   ```
   - Verify cash shows "$180" in **orange** (warning zone)
5. **Run:**
   ```gdscript
   GameState.player_cash = 50
   ```
   - Verify cash shows "$50" in **red** (danger zone)
6. **Run:**
   ```gdscript
   GameState.increment_capacity()
   GameState.increment_capacity()
   ```
   - Verify capacity shows "2/5 Customers Served"
7. **Run:**
   ```gdscript
   GameState.advance_day()
   ```
   - Verify day updates to "Day 2 - Tuesday"
   - Verify cash decreased by $30 (utilities deducted)
   - Verify capacity reset to "0/5"
8. **Repeat advance_day() 5 more times:**
   - Verify days progress: Wed, Thu, Fri, Sat, Sun
   - Verify day names correct for each
9. **Pass criteria:** All values update correctly, colors change at thresholds, day names accurate

---

### Known Simplifications

**Phase 1 shortcuts:**
- No rent payment logic (just placeholder in `check_rent_payment()`)
- No game over screen (Phase 4 feature)
- No save/load persistence (out of scope per design doc)
- No animation on value changes (instant updates only)
- Cash can go negative (no validation - game over handles this in Phase 4)

**Technical debt:**
- Using `_process()` for UI updates is inefficient - should use signals
  - **Impact:** Works fine for prototype, refactor if greenlit
- Hard-coded day names in array - not localized
  - **Impact:** English-only prototype per design doc, acceptable
- No validation on manual value changes (can set cash = -9999)
  - **Impact:** Doesn't matter - only called from controlled systems

---

## Feature 1.2: Symbol Data System

**Priority:** CRITICAL - Translation puzzles can't exist without symbol-to-word mappings.

**Tests Critical Question:** Q1 (puzzle satisfaction) - Provides the core puzzle content (5 texts, 20 symbols, solutions).

**Estimated Time:** 45 minutes

**Dependencies:** None - foundation feature, can be built in parallel with 1.1.

---

### Overview

The Symbol Data System defines the 20-symbol alphabet (∆◊≈⊕⊗⬡∞◈⊟⊞⊠⊡⊢⊣⊤⊥⊦⊧⊨⊩) and 5 translation texts with increasing difficulty. Stores symbol-to-word mappings, text solutions, difficulty ratings, and payment amounts. This data feeds the translation validation engine and dictionary auto-fill system.

**Critical Design Constraint:** Symbols must be consistent across all texts (∆ always = "the" throughout all 5 puzzles). Same input always produces same solution (deterministic, no randomization).

---

### What Player Sees

**Screen Layout:**
- **Not directly visible in Phase 1** - this is pure data
- Phase 2 will display symbol text in center workspace
- Phase 2 will populate dictionary panel with 20 symbol entries

**Visual Appearance (for Phase 2 reference):**
- Symbols displayed at 32pt for readability
- Symbol text shown in dark brown #3A2518 on cream parchment #F4E8D8
- Dictionary shows symbol (left column) and word (right column, initially "???")

**Visual States:**
- N/A for Phase 1 - data structure only
- Phase 2: Symbols render as Unicode glyphs in specified font

**Visual Feedback:**
- N/A for Phase 1
- Phase 2: Dictionary entries update when symbols learned

---

### What Player Does

**Input Methods:**
- **None in Phase 1** - this is pure data storage
- Phase 2: Player will type English translations to match solutions
- Phase 2: Player will reference dictionary to see learned symbols

**Immediate Response:**
- N/A for Phase 1 (no player interaction with raw data)

**Feedback Loop:**
- N/A for Phase 1
- Phase 2: Player sees symbols → Types translation → System validates against solution stored here

---

### Underlying Behavior

**Data Structure (GDScript):**
```gdscript
# res://scripts/SymbolData.gd (Autoload singleton)

extends Node

# 20-symbol alphabet from design doc
const SYMBOLS: Array = [
	"∆", "◊", "≈", "⊕", "⊗", "⬡", "∞", "◈",
	"⊟", "⊞", "⊠", "⊡", "⊢", "⊣", "⊤", "⊥",
	"⊦", "⊧", "⊨", "⊩"
]

# 5 translation texts with increasing difficulty
var texts: Array = [
	{
		"id": 1,
		"name": "Text 1 - Family History",
		"symbols": "∆ ◊≈ ⊕⊗◈",
		"solution": "the old way",
		"mappings": {
			"∆": "the",
			"◊≈": "old",
			"⊕⊗◈": "way"
		},
		"difficulty": "Easy",
		"payment_base": 50,
		"hint": "Simple word substitution. Each symbol group = one English word."
	},
	{
		"id": 2,
		"name": "Text 2 - Forgotten Ways",
		"symbols": "∆ ◊≈ ⊕⊗◈ ⊕⊗⬡ ⬡∞◊⊩⊩≈⊩",
		"solution": "the old way was forgotten",
		"mappings": {
			"∆": "the",
			"◊≈": "old",
			"⊕⊗◈": "way",
			"⊕⊗⬡": "was",
			"⬡∞◊⊩⊩≈⊩": "forgotten"
		},
		"difficulty": "Medium",
		"payment_base": 100,
		"hint": "Builds on previous text. Look for familiar symbols."
	},
	{
		"id": 3,
		"name": "Text 3 - Sleeping God",
		"symbols": "∆ ◊≈ ⊞⊟≈ ⬡≈≈⊢⬡",
		"solution": "the old god sleeps",
		"mappings": {
			"∆": "the",
			"◊≈": "old",
			"⊞⊟≈": "god",
			"⬡≈≈⊢⬡": "sleeps"
		},
		"difficulty": "Medium",
		"payment_base": 100,
		"hint": "Half the symbols are known. New vocabulary: divine entities."
	},
	{
		"id": 4,
		"name": "Text 4 - Lost Magic",
		"symbols": "⊗◈⊞∞◈ ⊕⊗⬡ ◊⊩◈≈ ⊟⊩◊⊕⊩",
		"solution": "magic was once known",
		"mappings": {
			"⊗◈⊞∞◈": "magic",
			"⊕⊗⬡": "was",
			"◊⊩◈≈": "once",
			"⊟⊩◊⊕⊩": "known"
		},
		"difficulty": "Hard",
		"payment_base": 150,
		"hint": "Only one familiar symbol. Deduce from context."
	},
	{
		"id": 5,
		"name": "Text 5 - The Return",
		"symbols": "∆≈◊ ⊗◈≈ ◈≈∆◊◈⊩∞⊩⊞ ⬡◊◊⊩",
		"solution": "they are returning soon",
		"mappings": {
			"∆≈◊": "they",
			"⊗◈≈": "are",
			"◈≈∆◊◈⊩∞⊩⊞": "returning",
			"⬡◊◊⊩": "soon"
		},
		"difficulty": "Hard",
		"payment_base": 200,
		"hint": "Finale text. Ominous warning. Synthesis of all previous knowledge."
	}
]

# Dictionary state (symbol → word, confidence level)
var dictionary: Dictionary = {}

func _ready():
	initialize_dictionary()

func initialize_dictionary():
	# Initialize all 20 symbols as unknown
	for symbol in SYMBOLS:
		dictionary[symbol] = {
			"word": null,  # null = unknown, shows "???"
			"confidence": 0,  # 0 = unknown, 1-2 = tentative, 3+ = confirmed
			"learned_from": []  # Track which texts taught this symbol
		}

func get_text(text_id: int) -> Dictionary:
	for text in texts:
		if text.id == text_id:
			return text
	return {}

func validate_translation(text_id: int, player_input: String) -> bool:
	var text = get_text(text_id)
	if text.is_empty():
		return false

	# Normalize input: lowercase, strip whitespace
	var normalized_input = player_input.strip_edges().to_lower()
	var normalized_solution = text.solution.to_lower()

	return normalized_input == normalized_solution

func update_dictionary(text_id: int):
	# Called on successful translation
	# Updates dictionary with learned symbols from this text
	var text = get_text(text_id)
	if text.is_empty():
		return

	for symbol in text.mappings.keys():
		var word = text.mappings[symbol]

		# For Phase 1: Immediate confirmation (skip 3-use rule)
		dictionary[symbol].word = word
		dictionary[symbol].confidence = 3  # Confirmed
		dictionary[symbol].learned_from.append(text.name)

func get_dictionary_entry(symbol: String) -> Dictionary:
	if symbol in dictionary:
		return dictionary[symbol]
	return {"word": null, "confidence": 0, "learned_from": []}
```

**Key Numbers from Design Doc:**
- Alphabet size: 20 symbols
- Text count: 5 texts (Text 1 through Text 5)
- Text 1: "the old way" (3 words, $50 payment, Easy)
- Text 2: "the old way was forgotten" (5 words, $100 payment, Medium)
- Text 3: "the old god sleeps" (4 words, $100 payment, Medium)
- Text 4: "magic was once known" (4 words, $150 payment, Hard)
- Text 5: "they are returning soon" (4 words, $200 payment, Hard)
- Dictionary auto-fill: 3 correct uses → confirmed (prototype: 1 use for testing)
- No randomization: Same input = same solution (deterministic)

**Symbol Mapping Consistency:**
- ∆ = "the" (appears in Text 1, 2, 3)
- ◊≈ = "old" (appears in Text 1, 2, 3)
- ⊕⊗◈ = "way" (appears in Text 1, 2)
- ⊕⊗⬡ = "was" (appears in Text 2, 4)
- ⊞⊟≈ = "god" (appears in Text 3)
- ... (all symbols consistent across texts)

---

### Acceptance Criteria

**Data Integrity Checks:**
- [ ] SYMBOLS array contains exactly 20 unique Unicode symbols
- [ ] texts array contains exactly 5 text definitions
- [ ] Each text has: id, name, symbols, solution, mappings, difficulty, payment_base
- [ ] Text IDs are 1-5 (sequential, no gaps)
- [ ] Payment amounts match design doc: $50, $100, $100, $150, $200
- [ ] Difficulty ratings match design doc: Easy, Medium, Medium, Hard, Hard

**Symbol Consistency Checks:**
- [ ] Symbol ∆ maps to "the" in Text 1, 2, 3 (consistent across all uses)
- [ ] Symbol ◊≈ maps to "old" in Text 1, 2, 3 (consistent)
- [ ] Symbol ⊕⊗⬡ maps to "was" in Text 2, 4 (consistent)
- [ ] No symbol maps to different words in different texts (fails consistency)
- [ ] All symbols used in texts exist in SYMBOLS array

**Validation Logic Checks:**
- [ ] `validate_translation(1, "the old way")` returns true
- [ ] `validate_translation(1, "THE OLD WAY")` returns true (case-insensitive)
- [ ] `validate_translation(1, "  the old way  ")` returns true (strips whitespace)
- [ ] `validate_translation(1, "wrong answer")` returns false
- [ ] `validate_translation(1, "old the way")` returns false (word order matters)
- [ ] `validate_translation(5, "they are returning soon")` returns true
- [ ] Invalid text_id returns false gracefully

**Dictionary Initialization Checks:**
- [ ] `initialize_dictionary()` creates 20 entries (one per symbol)
- [ ] All dictionary entries start with word=null, confidence=0
- [ ] `get_dictionary_entry("∆")` returns {word: null, confidence: 0, learned_from: []}
- [ ] `get_dictionary_entry("invalid")` returns default empty dictionary

**Dictionary Update Checks:**
- [ ] After `update_dictionary(1)`, dictionary["∆"].word = "the"
- [ ] After `update_dictionary(1)`, dictionary["◊≈"].word = "old"
- [ ] After `update_dictionary(1)`, dictionary["⊕⊗◈"].word = "way"
- [ ] After `update_dictionary(1)`, confidence = 3 (confirmed, not 1)
- [ ] After `update_dictionary(1)`, learned_from includes "Text 1 - Family History"
- [ ] Symbols not in Text 1 remain word=null (unchanged)

**Edge Case Checks:**
- [ ] `get_text(99)` returns empty dictionary (invalid ID handled)
- [ ] Empty player input "" returns false for validation
- [ ] Unicode symbols display correctly (not corrupted/replaced with ?)
- [ ] Symbols with combining characters parse correctly (◊≈ is single token)

---

### Manual Test Script

1. **Launch Godot Editor, open Script panel**
2. **Verify SYMBOLS constant:**
   ```gdscript
   print(SymbolData.SYMBOLS.size())  # Should print 20
   print(SymbolData.SYMBOLS)  # Should show all 20 symbols
   ```
3. **Verify texts array:**
   ```gdscript
   print(SymbolData.texts.size())  # Should print 5
   for text in SymbolData.texts:
       print("%s: '%s' → '%s' ($%d, %s)" % [text.name, text.symbols, text.solution, text.payment_base, text.difficulty])
   ```
   - Expected output:
     ```
     Text 1 - Family History: '∆ ◊≈ ⊕⊗◈' → 'the old way' ($50, Easy)
     Text 2 - Forgotten Ways: '∆ ◊≈ ⊕⊗◈ ⊕⊗⬡ ⬡∞◊⊩⊩≈⊩' → 'the old way was forgotten' ($100, Medium)
     [etc.]
     ```
4. **Test validation logic:**
   ```gdscript
   print(SymbolData.validate_translation(1, "the old way"))  # true
   print(SymbolData.validate_translation(1, "THE OLD WAY"))  # true
   print(SymbolData.validate_translation(1, "wrong"))  # false
   print(SymbolData.validate_translation(5, "they are returning soon"))  # true
   ```
5. **Test dictionary initialization:**
   ```gdscript
   print(SymbolData.dictionary.size())  # Should be 20
   print(SymbolData.get_dictionary_entry("∆"))  # {word: null, confidence: 0, learned_from: []}
   ```
6. **Test dictionary update:**
   ```gdscript
   SymbolData.update_dictionary(1)
   print(SymbolData.dictionary["∆"])  # {word: "the", confidence: 3, learned_from: ["Text 1 - Family History"]}
   print(SymbolData.dictionary["◊≈"])  # {word: "old", confidence: 3, learned_from: [...]}
   print(SymbolData.dictionary["⊕⊗◈"])  # {word: "way", confidence: 3, learned_from: [...]}
   print(SymbolData.dictionary["⊞"])  # Still {word: null, confidence: 0, learned_from: []} (not in Text 1)
   ```
7. **Verify symbol consistency:**
   ```gdscript
   var text1 = SymbolData.get_text(1)
   var text2 = SymbolData.get_text(2)
   print(text1.mappings["∆"])  # "the"
   print(text2.mappings["∆"])  # "the" (same)
   print(text1.mappings["◊≈"])  # "old"
   print(text2.mappings["◊≈"])  # "old" (same)
   ```
8. **Pass criteria:** All outputs match expected values, validation logic works, dictionary updates correctly

---

### Known Simplifications

**Phase 1 shortcuts:**
- Dictionary confirmation is immediate (confidence=3 after 1 use, not 3 uses per design doc)
- No tentative/yellow state (skips confidence 1-2, goes straight to confirmed/green)
- Text hints stored but not used yet (Phase 2 feature)
- No cross-referencing logic (clicking dictionary entry to see usage history - Phase 3)

**Technical debt:**
- Hard-coded text data (not loaded from JSON file)
  - **Impact:** Fine for 5-text prototype, would need data files for full game
- Symbol groups stored as strings ("◊≈") not parsed into components
  - **Impact:** Works for validation, but makes pattern analysis harder
- No grammar pattern enforcement (design doc mentions word order, but not validated separately)
  - **Impact:** Acceptable - solution string handles this implicitly

---

## Feature 1.3: UI Workspace Layout

**Priority:** CRITICAL - Everything else renders into these panels. Without layout, nothing is visible.

**Tests Critical Question:** Foundation for all 5 questions - Provides visual structure for puzzles, choices, progression.

**Estimated Time:** 30 minutes

**Dependencies:**
- **1.1 Game State Manager** must be complete (UI labels display GameState values)

---

### Overview

The UI Workspace Layout establishes the visual foundation: 5 main panels (top status bar, left customer queue, center workspace, right dictionary, bottom dialogue) positioned on a 1280×720 viewport. All panels are static containers in Phase 1—no interactivity yet, just visual structure. Later features render into these predefined areas.

**Critical Design Constraint:** Layout is fixed (not responsive). All positions are absolute pixel coordinates. Panel sizes must match design doc exactly to ensure proper spacing for content added in later phases.

---

### What Player Sees

**Screen Layout:**

```
┌─────────────────────────────────────────────────────────────────┐
│ [Day 1-Monday]        [0/5 Customers]            [$100]        │ ← Top bar (1280×60px)
├───────────┬─────────────────────────────────┬──────────────────┤
│           │                                 │                  │
│ [Customer │       [WORKSPACE AREA]          │  [Dictionary]    │
│  Queue]   │   (Translation happens here)    │   [Panel]        │
│  [Panel]  │                                 │                  │
│           │                                 │                  │
│ (280×660) │         (720×460)               │   (280×660)      │
│           │                                 │                  │
├───────────┴─────────────────────────────────┴──────────────────┤
│ [Customer Dialogue Box - Messages appear here]                 │ ← Bottom (1280×200px)
└─────────────────────────────────────────────────────────────────┘
```

**Specific Dimensions:**
- **Viewport:** 1280×720px (fixed, non-resizable for prototype)
- **Top Bar:** Full width 1280×60px, top-aligned
- **Left Panel (Customer Queue):** 280×660px, left-aligned below top bar
- **Center Workspace:** 720×460px, center-aligned below top bar
- **Right Panel (Dictionary):** 280×660px, right-aligned below top bar
- **Bottom Dialogue Box:** 1280×200px, bottom-aligned

**Visual Appearance:**

**Background (desk surface):**
- Color: Beige #D4B896
- Fills entire viewport (1280×720)
- Texture: Solid color (no wood grain for prototype)

**Top Bar:**
- Background: Darker brown #2A1F1A with subtle border
- Contains 3 labels (connected to GameState - see Feature 1.1):
  - Day tracker (left): Cream parchment bg #F4E8D8, rounded 10px
  - Capacity counter (center): Transparent bg
  - Cash counter (right): Transparent bg, color changes with value

**Left Panel (Customer Queue):**
- Background: Dark brown #2A1F1A
- Border: 2px solid #3A2518
- Title: "Today's Customers" at top (20pt serif, cream #F4E8D8)
- Content area: Empty for Phase 1 (Phase 3 adds customer cards)

**Center Workspace:**
- Background: Beige desk #D4B896 (same as main background, blends in)
- Border: None (seamless with desk)
- Content area: Empty for Phase 1 (Phase 2 adds translation display)

**Right Panel (Dictionary):**
- Background: Dark brown #2A1F1A
- Border: 2px solid #3A2518
- Title: "Dictionary" at top (20pt serif, cream #F4E8D8)
- Content area: Empty for Phase 1 (Phase 2 adds 20 symbol entries)

**Bottom Dialogue Box:**
- Background: Dark brown #3A2518
- Border: 2px solid top edge only #4A3728
- Content area: Empty for Phase 1 (shows placeholder: "*Customer dialogue appears here...*" in italic gray)

**Visual States:**
- **All panels static** - no hover, active, or disabled states in Phase 1
- **No animations** - panels don't move, resize, or fade
- **No visual feedback** - just structural containers

---

### What Player Does

**Input Methods:**
- **None in Phase 1** - this is pure visual structure
- Player can only observe the layout
- No clicks, hovers, or keyboard input affect panels

**Immediate Response:**
- Game launches → All 5 panels appear immediately, correctly positioned
- No player interaction with panels themselves (content added in later phases)

**Feedback Loop:**
- N/A for Phase 1 (panels are static containers)

---

### Underlying Behavior

**Scene Structure (Godot):**
```
Main.tscn (root scene, Control node, 1280×720)
├── Background (ColorRect)
│   └── color: #D4B896, size: 1280×720
├── TopBar (Panel)
│   ├── position: (0, 0), size: (1280, 60)
│   ├── background: #2A1F1A
│   ├── DayLabel (Label, connects to GameState)
│   ├── CapacityLabel (Label, connects to GameState)
│   └── CashLabel (Label, connects to GameState)
├── LeftPanel (Panel)
│   ├── position: (0, 60), size: (280, 660)
│   ├── background: #2A1F1A, border: 2px #3A2518
│   └── TitleLabel (Label, "Today's Customers")
├── Workspace (Control)
│   ├── position: (280, 60), size: (720, 460)
│   └── background: transparent (shows desk through)
├── RightPanel (Panel)
│   ├── position: (1000, 60), size: (280, 660)
│   ├── background: #2A1F1A, border: 2px #3A2518
│   └── TitleLabel (Label, "Dictionary")
└── DialogueBox (Panel)
    ├── position: (0, 520), size: (1280, 200)
    ├── background: #3A2518, border-top: 2px #4A3728
    └── PlaceholderLabel (Label, "*Customer dialogue appears here...*")
```

**GDScript for Main scene:**
```gdscript
# res://scenes/Main.gd

extends Control

func _ready():
	# Set viewport size (project settings should handle this, but enforce here)
	get_viewport().size = Vector2(1280, 720)

	# Phase 1: All panels are just containers
	# Later phases will populate with content
	pass
```

**Key Numbers from Design Doc:**
- Viewport: 1280×720px (fixed resolution)
- Top bar height: 60px
- Panel widths: Left 280px, Center 720px, Right 280px (total = 1280px)
- Panel heights: 660px (below 60px top bar, above 200px dialogue = 720 - 60 - 200 = 460px for workspace)
- Bottom dialogue: 200px height
- Colors: Beige desk #D4B896, dark brown panels #2A1F1A, text cream #F4E8D8

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Viewport is exactly 1280×720px (check window size)
- [ ] Background fills entire viewport with beige #D4B896
- [ ] Top bar spans full width (1280px), height 60px, background #2A1F1A
- [ ] Left panel at (0, 60), size 280×660px, background #2A1F1A, border 2px #3A2518
- [ ] Center workspace at (280, 60), size 720×460px, transparent background
- [ ] Right panel at (1000, 60), size 280×660px, background #2A1F1A, border 2px #3A2518
- [ ] Bottom dialogue at (0, 520), size 1280×200px, background #3A2518
- [ ] No panel overlap or gaps (seams are clean)
- [ ] All borders 2px solid, correct colors

**Text Label Checks (Top Bar):**
- [ ] "Day 1 - Monday" visible at (20, 20) in serif 18pt #3A2518
- [ ] "0/5 Customers Served" visible at (590, 20) in sans 16pt #666
- [ ] "$100" visible at (1180, 20) in sans bold 24pt green #2D5016
- [ ] All labels readable, not truncated or overlapping

**Title Label Checks:**
- [ ] Left panel shows "Today's Customers" at top in serif 20pt cream #F4E8D8
- [ ] Right panel shows "Dictionary" at top in serif 20pt cream #F4E8D8
- [ ] Bottom dialogue shows placeholder "*Customer dialogue appears here...*" in italic gray #999

**Layout Precision Checks:**
- [ ] Left panel + Center workspace + Right panel widths = 1280px (280 + 720 + 280)
- [ ] Top bar + Center workspace + Bottom dialogue heights = 720px (60 + 460 + 200)
- [ ] No elements extend beyond viewport (no scrollbars appear)
- [ ] Panel corners align perfectly (no 1px gaps at seams)

**Integration Checks:**
- [ ] GameState values display correctly in top bar (see Feature 1.1 tests)
- [ ] Changing GameState.player_cash updates cash label in top bar
- [ ] Changing GameState.current_day updates day label in top bar

**Edge Case Checks:**
- [ ] Window resize doesn't break layout (or better: disable resizing in project settings)
- [ ] Zoom in/out doesn't distort panels (2D pixel-perfect mode)
- [ ] Long text in labels doesn't overflow (test with "$99999" or "Day 100 - FakeDay")

---

### Manual Test Script

1. **Launch game in Godot Editor (F5)**
2. **Measure viewport:**
   - Window title should show 1280×720
   - Fullscreen not enabled (windowed mode)
3. **Visual inspection:**
   - Background is beige (not white/black)
   - 5 distinct panels visible (top bar, left, center, right, bottom)
4. **Check top bar:**
   - Dark brown background (#2A1F1A)
   - 3 labels visible: Day (left), Capacity (center), Cash (right)
   - Text readable, correct colors
5. **Check left panel:**
   - Dark brown background, 2px border
   - Title "Today's Customers" at top in cream
   - Content area empty (expected for Phase 1)
6. **Check center workspace:**
   - Blends with beige desk background
   - No visible border (seamless)
   - Large empty area (expected for Phase 1)
7. **Check right panel:**
   - Dark brown background, 2px border
   - Title "Dictionary" at top in cream
   - Content area empty (expected for Phase 1)
8. **Check bottom dialogue:**
   - Dark brown background, border only on top edge
   - Placeholder text visible in italic gray
9. **Test GameState integration:**
   - Open debugger, change GameState.player_cash = 500
   - Verify cash label updates to "$500" in green
   - Change GameState.current_day = 5
   - Verify day label updates to "Day 5 - Friday"
10. **Pass criteria:** All panels positioned correctly, no overlap, GameState values display

---

### Known Simplifications

**Phase 1 shortcuts:**
- Panels are empty containers (no scrollbars, content, interactivity)
- No responsive layout (fixed 1280×720, doesn't adapt to screen size)
- Placeholder text in dialogue box (removed in Phase 2)
- No panel animations (fade in/out, slide - out of scope)
- Simple solid colors (no wood texture on desk, no parchment texture on panels)

**Technical debt:**
- Hard-coded positions (not using anchors/containers)
  - **Impact:** Works for fixed-resolution prototype, would need refactor for responsive design
- No theme resource (colors duplicated across panels)
  - **Impact:** Acceptable for prototype, create theme file if greenlit
- Using Control nodes instead of specialized containers (HBoxContainer, VBoxContainer)
  - **Impact:** Simpler for prototype, harder to maintain long-term

---

## Feature 1.4: Customer Data Structures

**Priority:** HIGH - Enables customer queue display (Phase 3) and relationship tracking system.

**Tests Critical Question:** Q2 (strategic tension), Q5 (story emergence) - Defines recurring customers with distinct personalities.

**Estimated Time:** 15 minutes

**Dependencies:** None - pure data structure, can be built in parallel with other Phase 1 features.

---

### Overview

The Customer Data Structures define 3 recurring customer types (Mrs. Kowalski, Dr. Chen, The Stranger) with unique properties (payment, priorities, dialogue, story role) and a random customer generator for one-time arrivals. This data feeds the customer queue display (Phase 3) and relationship tracking system (Phase 3). Each customer is a dictionary with 8-10 properties.

**Critical Design Constraint:** Recurring customers must track refusal tolerance (Mrs. K and Dr. Chen stop appearing after 2 refusals, Stranger after 1). Random customers are never stored—generated fresh each day.

---

### What Player Sees

**Screen Layout:**
- **Not directly visible in Phase 1** - this is pure data
- Phase 3 will display customer names, payments, priorities in queue cards
- Phase 4 will show customer dialogue in bottom dialogue box

**Visual Appearance (for Phase 3 reference):**
- Customer cards show: Name (top-left), Payment (top-right green), Difficulty (below name)
- Dialogue box shows customer messages (greeting/negotiation/success/failure)

**Visual States:**
- N/A for Phase 1 - data structure only

**Visual Feedback:**
- N/A for Phase 1

---

### What Player Does

**Input Methods:**
- **None in Phase 1** - this is pure data storage
- Phase 3: Player will click customer cards to view details
- Phase 3: Player will accept/refuse customers (modifies relationship data)

**Immediate Response:**
- N/A for Phase 1 (no player interaction with raw data)

**Feedback Loop:**
- N/A for Phase 1
- Phase 3: Player refuses customer → Relationship damage recorded → Customer may not return next day

---

### Underlying Behavior

**Data Structure (GDScript):**
```gdscript
# res://scripts/CustomerData.gd (Autoload singleton)

extends Node

# 3 recurring customer types from design doc
var recurring_customers: Dictionary = {
	"Mrs. Kowalski": {
		"type": "recurring",
		"appears_days": [1, 2, 3],  # Monday, Tuesday, Wednesday
		"payment": 50,
		"difficulty": "Easy",
		"priorities": ["Cheap", "Accurate"],
		"refusal_tolerance": 2,  # Stops appearing after 2 refusals
		"current_relationship": 2,  # Starts at max, decreases on refusal
		"dialogue": {
			"greeting": "Hello dear, I found this old family book.",
			"negotiation": "Take your time, dear. I just want it done right.",
			"success": "Oh wonderful! Thank you so much!",
			"failure": "Are you sure, dear? It doesn't seem quite right...",
			"story_beat": "My grandmother was in a secret society, you know."
		},
		"story_role": "Tutorial/Heart",
		"personality": "Patient, sweet, gentle introduction"
	},

	"Dr. Chen": {
		"type": "recurring",
		"appears_days": [2, 3, 4, 5, 6, 7],  # Tuesday through Sunday
		"payment": 100,
		"difficulty": "Medium",
		"priorities": ["Fast", "Accurate"],
		"refusal_tolerance": 2,
		"current_relationship": 2,
		"dialogue": {
			"greeting": "I need this translated for my research. It's critical.",
			"negotiation": "Accuracy is everything. Money isn't an issue.",
			"success": "Excellent work. This confirms my hypothesis.",
			"failure": "This can't be right. My research depends on accuracy.",
			"story_beat": "Something is waking up beneath the city... we're running out of time."
		},
		"story_role": "Scholar/Plot",
		"personality": "Curious, intense, driven"
	},

	"The Stranger": {
		"type": "recurring",
		"appears_days": [5, 6, 7],  # Friday, Saturday, Sunday
		"payment": 200,
		"difficulty": "Hard",
		"priorities": ["Fast", "Accurate"],
		"refusal_tolerance": 1,  # Very sensitive - one refusal and gone
		"current_relationship": 1,
		"dialogue": {
			"greeting": "Translate this. Now.",
			"negotiation": "Fast and accurate. Money is no object.",
			"success": "You've done well. Keep this between us.",
			"failure": "Unacceptable. I expected better.",
			"story_beat": "They are returning soon. You need to know the truth."
		},
		"story_role": "Mystery/Finale",
		"personality": "Mysterious, terse, ominous"
	}
}

# Random customer templates (one-time only)
var random_customer_templates: Array = [
	{
		"name_prefix": "Scholar",
		"difficulty": "Medium",
		"payment_range": [80, 120],
		"priorities": [["Fast", "Cheap"], ["Cheap", "Accurate"]],
		"dialogue": {
			"greeting": "I need this academic text translated.",
			"success": "Thank you, this will help my thesis.",
			"failure": "Hmm, I'll need to double-check this."
		}
	},
	{
		"name_prefix": "Collector",
		"difficulty": "Hard",
		"payment_range": [150, 180],
		"priorities": [["Fast", "Accurate"]],
		"dialogue": {
			"greeting": "Rare find. Need it authenticated.",
			"success": "Fascinating. Worth every penny.",
			"failure": "Are you certain? This is valuable."
		}
	},
	{
		"name_prefix": "Student",
		"difficulty": "Easy",
		"payment_range": [40, 60],
		"priorities": [["Fast", "Cheap"]],
		"dialogue": {
			"greeting": "I need help with my homework...",
			"success": "Thanks! You're a lifesaver!",
			"failure": "Oh no... I really needed this."
		}
	},
	{
		"name_prefix": "Merchant",
		"difficulty": "Easy",
		"payment_range": [50, 80],
		"priorities": [["Fast", "Cheap"], ["Cheap", "Accurate"]],
		"dialogue": {
			"greeting": "Got this at an estate sale. What's it say?",
			"success": "Neat! Thanks for the translation.",
			"failure": "Eh, not worth much anyway."
		}
	}
]

# Generate daily customer queue
func generate_daily_queue(day_number: int) -> Array:
	var queue: Array = []

	# Add recurring customers if they should appear today
	for customer_name in recurring_customers.keys():
		var customer = recurring_customers[customer_name]

		# Check if day is in appearance window
		if day_number in customer.appears_days:
			# Check if relationship is intact (not refused too many times)
			if customer.current_relationship > 0:
				queue.append(create_customer_instance(customer_name, customer))

	# Fill remaining slots with random one-time customers (target 7-10 total)
	var num_random = randi_range(4, 7)  # Fill to reach 7-10 total
	for i in range(num_random):
		queue.append(generate_random_customer())

	# Shuffle queue so recurring customers aren't always first
	queue.shuffle()

	return queue

func create_customer_instance(name: String, data: Dictionary) -> Dictionary:
	return {
		"name": name,
		"type": data.type,
		"payment": data.payment,
		"difficulty": data.difficulty,
		"priorities": data.priorities,
		"dialogue": data.dialogue,
		"story_role": data.story_role,
		"is_recurring": true
	}

func generate_random_customer() -> Dictionary:
	var template = random_customer_templates[randi() % random_customer_templates.size()]
	var random_number = randi_range(100, 999)

	return {
		"name": "%s #%d" % [template.name_prefix, random_number],
		"type": "one-time",
		"payment": randi_range(template.payment_range[0], template.payment_range[1]),
		"difficulty": template.difficulty,
		"priorities": template.priorities[randi() % template.priorities.size()],
		"dialogue": template.dialogue,
		"story_role": "None",
		"is_recurring": false
	}

func damage_relationship(customer_name: String):
	# Called when player refuses a recurring customer
	if customer_name in recurring_customers:
		recurring_customers[customer_name].current_relationship -= 1

func reset_relationships():
	# Reset all relationships to starting values (for new game)
	for customer_name in recurring_customers.keys():
		recurring_customers[customer_name].current_relationship = recurring_customers[customer_name].refusal_tolerance
```

**Key Numbers from Design Doc:**
- 3 recurring customer types (Mrs. K, Dr. Chen, Stranger)
- Mrs. Kowalski: $50, Easy, Cheap+Accurate, Days 1-3, tolerance 2
- Dr. Chen: $100-150, Medium, Fast+Accurate, Days 2-7, tolerance 2
- The Stranger: $200, Hard, Fast+Accurate, Days 5-7, tolerance 1
- Random customers: $40-$120 payment range
- Daily queue: 7-10 customers total (3 recurring + 4-7 random)
- Dialogue budget: 4 lines per customer (greeting, negotiation, success, failure)

**Priorities (Fast/Cheap/Accurate):**
- Mrs. K: Cheap + Accurate (pays 50%, patient, must be perfect)
- Dr. Chen: Fast + Accurate (normal pay, quick + perfect)
- Stranger: Fast + Accurate (high pay, nightmare mode)
- Random: Various combinations

---

### Acceptance Criteria

**Data Integrity Checks:**
- [ ] recurring_customers dictionary has exactly 3 entries (Mrs. K, Dr. Chen, Stranger)
- [ ] Each recurring customer has all required fields (type, appears_days, payment, difficulty, priorities, refusal_tolerance, dialogue, story_role)
- [ ] random_customer_templates array has 4 templates (Scholar, Collector, Student, Merchant)
- [ ] Payment amounts match design doc: Mrs. K $50, Dr. Chen $100, Stranger $200

**Appearance Schedule Checks:**
- [ ] Mrs. Kowalski appears_days = [1, 2, 3] (Mon, Tue, Wed)
- [ ] Dr. Chen appears_days = [2, 3, 4, 5, 6, 7] (Tue-Sun)
- [ ] The Stranger appears_days = [5, 6, 7] (Fri, Sat, Sun)
- [ ] No overlap errors (all day numbers 1-7)

**Refusal Tolerance Checks:**
- [ ] Mrs. K refusal_tolerance = 2, starts with current_relationship = 2
- [ ] Dr. Chen refusal_tolerance = 2, starts with current_relationship = 2
- [ ] Stranger refusal_tolerance = 1, starts with current_relationship = 1
- [ ] All current_relationship values match refusal_tolerance initially

**Dialogue Checks:**
- [ ] Each recurring customer has 4 dialogue lines (greeting, negotiation, success, failure)
- [ ] Each has 1 story_beat line (total 5 lines per character)
- [ ] Random templates have 3 dialogue lines (greeting, success, failure)
- [ ] No empty/null dialogue strings

**Queue Generation Checks:**
- [ ] `generate_daily_queue(1)` returns 7-10 customers
- [ ] Day 1 queue includes Mrs. Kowalski (only recurring who appears Day 1)
- [ ] Day 1 queue does NOT include Dr. Chen (appears Day 2+) or Stranger (appears Day 5+)
- [ ] Day 2 queue includes Mrs. K AND Dr. Chen (both appear Days 2-3)
- [ ] Day 5 queue includes Dr. Chen AND Stranger (both appear Days 5-7)
- [ ] Queue contains 3 recurring + 4-7 random (total 7-10)
- [ ] Queue is shuffled (recurring not always first)

**Random Customer Generation Checks:**
- [ ] `generate_random_customer()` returns valid customer dictionary
- [ ] Random customer has unique name (e.g., "Scholar #542", "Student #189")
- [ ] Payment is within template range (Scholar: $80-120, Student: $40-60)
- [ ] Difficulty matches template (Scholar: Medium, Student: Easy)
- [ ] is_recurring = false for all random customers

**Relationship Damage Checks:**
- [ ] `damage_relationship("Mrs. Kowalski")` decreases current_relationship by 1 (2 → 1)
- [ ] After 2 refusals (current_relationship = 0), Mrs. K doesn't appear in next queue
- [ ] `damage_relationship("The Stranger")` decreases from 1 → 0 (immediately broken)
- [ ] Stranger doesn't appear in next queue after 1 refusal
- [ ] `reset_relationships()` restores all current_relationship to refusal_tolerance

**Edge Case Checks:**
- [ ] `generate_daily_queue(8)` handles invalid day gracefully (no recurring customers appear)
- [ ] `damage_relationship("Invalid Name")` doesn't crash
- [ ] Queue never has duplicate recurring customers (each appears max once per day)
- [ ] Random customer names are unique within same queue (no "Scholar #542" twice)

---

### Manual Test Script

1. **Launch Godot Editor, open Script panel**
2. **Verify recurring customer data:**
   ```gdscript
   print(CustomerData.recurring_customers.keys())  # ["Mrs. Kowalski", "Dr. Chen", "The Stranger"]
   print(CustomerData.recurring_customers["Mrs. Kowalski"].payment)  # 50
   print(CustomerData.recurring_customers["Dr. Chen"].payment)  # 100
   print(CustomerData.recurring_customers["The Stranger"].payment)  # 200
   ```
3. **Test appearance schedules:**
   ```gdscript
   print(CustomerData.recurring_customers["Mrs. Kowalski"].appears_days)  # [1, 2, 3]
   print(CustomerData.recurring_customers["Dr. Chen"].appears_days)  # [2, 3, 4, 5, 6, 7]
   print(CustomerData.recurring_customers["The Stranger"].appears_days)  # [5, 6, 7]
   ```
4. **Test queue generation for Day 1:**
   ```gdscript
   var day1_queue = CustomerData.generate_daily_queue(1)
   print(day1_queue.size())  # 7-10 customers
   for customer in day1_queue:
       print("%s: $%d (%s) - %s" % [customer.name, customer.payment, customer.difficulty, customer.priorities])
   ```
   - Verify Mrs. Kowalski appears in queue
   - Verify Dr. Chen does NOT appear (too early)
   - Verify 4-7 random customers (Scholar #XXX, Student #YYY, etc.)
5. **Test queue generation for Day 5 (Friday):**
   ```gdscript
   var day5_queue = CustomerData.generate_daily_queue(5)
   print(day5_queue.size())  # 7-10 customers
   var has_chen = false
   var has_stranger = false
   for customer in day5_queue:
       if customer.name == "Dr. Chen": has_chen = true
       if customer.name == "The Stranger": has_stranger = true
   print("Has Dr. Chen: %s, Has Stranger: %s" % [has_chen, has_stranger])
   ```
   - Both should be true
6. **Test relationship damage:**
   ```gdscript
   print(CustomerData.recurring_customers["Mrs. Kowalski"].current_relationship)  # 2
   CustomerData.damage_relationship("Mrs. Kowalski")
   print(CustomerData.recurring_customers["Mrs. Kowalski"].current_relationship)  # 1
   CustomerData.damage_relationship("Mrs. Kowalski")
   print(CustomerData.recurring_customers["Mrs. Kowalski"].current_relationship)  # 0

   var day2_queue_after_refusals = CustomerData.generate_daily_queue(2)
   var has_kowalski = false
   for customer in day2_queue_after_refusals:
       if customer.name == "Mrs. Kowalski": has_kowalski = true
   print("Mrs. K appears after 2 refusals: %s" % has_kowalski)  # false
   ```
7. **Test random customer generation:**
   ```gdscript
   for i in range(5):
       var random_customer = CustomerData.generate_random_customer()
       print("%s: $%d (%s)" % [random_customer.name, random_customer.payment, random_customer.difficulty])
   ```
   - Verify names are unique (Scholar #XXX, Student #YYY, etc.)
   - Verify payments within expected ranges ($40-180)
8. **Pass criteria:** All data structures correct, queue generation works, relationship tracking functions

---

### Known Simplifications

**Phase 1 shortcuts:**
- No Agent Williams or Marcus (cut to 3 recurring customers for prototype)
- Random customer names are simple "#XXX" format (not realistic names)
- Dialogue is stored but not displayed yet (Phase 3-4 feature)
- Priorities stored but not enforced mechanically yet (Phase 4 constraint effects)
- No customer portraits/avatars (text-only per design doc)

**Technical debt:**
- Dialogue stored as flat dictionary (not localized)
  - **Impact:** English-only prototype acceptable
- Relationship tracking is simple integer (not detailed reputation system)
  - **Impact:** Works for binary "appears/doesn't appear", full game could add nuance
- Random customer templates are hard-coded (not data-driven)
  - **Impact:** Fine for 4 templates, would need JSON for full game variety

---

## PHASE 1 COMPLETE - INTEGRATION TEST

**Goal:** Verify all 4 foundation features work together correctly.

**Time:** 10 minutes

---

### Full Integration Test

1. **Launch game (F5)**
2. **Visual verification:**
   - [ ] All 5 panels visible (top bar, left, center, right, bottom)
   - [ ] Top bar shows "Day 1 - Monday", "0/5 Customers Served", "$100" (green)
   - [ ] Left panel titled "Today's Customers" (empty content)
   - [ ] Right panel titled "Dictionary" (empty content)
   - [ ] Bottom dialogue shows placeholder text
3. **GameState integration:**
   - Open debugger console
   - Run: `GameState.add_cash(100)`
   - [ ] Cash counter updates to "$200" (still green)
   - Run: `GameState.increment_capacity()`
   - [ ] Capacity counter updates to "1/5 Customers Served"
   - Run: `GameState.advance_day()`
   - [ ] Day updates to "Day 2 - Tuesday"
   - [ ] Cash decreases by $30 (utilities): $200 → $170 (now orange)
   - [ ] Capacity resets to "0/5"
4. **Symbol data integration:**
   - Run: `print(SymbolData.texts[0].solution)`
   - [ ] Prints "the old way"
   - Run: `SymbolData.update_dictionary(1)`
   - [ ] No errors (dictionary updates internally)
   - Run: `print(SymbolData.dictionary["∆"])`
   - [ ] Prints {word: "the", confidence: 3, learned_from: [...]}
5. **Customer data integration:**
   - Run: `var queue = CustomerData.generate_daily_queue(1)`
   - [ ] No errors
   - Run: `for c in queue: print(c.name)`
   - [ ] Prints 7-10 customer names (Mrs. Kowalski + random customers)
   - [ ] Dr. Chen NOT in list (too early)
6. **Cross-feature integration:**
   - Run: `GameState.current_day = 5`
   - [ ] Day label updates to "Day 5 - Friday"
   - Run: `var day5_queue = CustomerData.generate_daily_queue(GameState.current_day)`
   - [ ] Queue includes both Dr. Chen and The Stranger
7. **Pass criteria:** All systems accessible, UI updates from data changes, no errors

---

## PHASE 1 DELIVERABLES CHECKLIST

After completing all 4 features:

**Code Files Created:**
- [ ] `res://scripts/GameState.gd` (autoload singleton)
- [ ] `res://scripts/SymbolData.gd` (autoload singleton)
- [ ] `res://scripts/CustomerData.gd` (autoload singleton)
- [ ] `res://scenes/Main.tscn` (root scene with 5 panels)
- [ ] `res://scenes/Main.gd` (main scene script)

**Project Settings Configured:**
- [ ] Autoload: GameState → res://scripts/GameState.gd
- [ ] Autoload: SymbolData → res://scripts/SymbolData.gd
- [ ] Autoload: CustomerData → res://scripts/CustomerData.gd
- [ ] Display/Window: Width=1280, Height=720, Resizable=false

**Visual Deliverables:**
- [ ] Screenshot of Phase 1 complete UI (all 5 panels visible)
- [ ] Debugger output showing all 3 singletons accessible
- [ ] Top bar displays correct GameState values

**Documentation:**
- [ ] Comments in each script explaining data structure
- [ ] Test output from manual test scripts
- [ ] Phase 1 completion timestamp logged

**Ready for Phase 2:**
- [ ] GameState can be queried by any script
- [ ] SymbolData provides 5 texts with solutions
- [ ] CustomerData can generate daily queues
- [ ] UI panels ready to receive content (translation display, customer cards, dictionary entries)

---

**PHASE 1 COMPLETE - TIME TO BUILD PHASE 2 (CORE PUZZLE LOOP)**

Next phase will add translation display, validation engine, dictionary auto-fill, and money tracking to create the first playable loop.
