# PHASE 2: CORE PUZZLE LOOP - Feature Specifications

**Game:** Glyphic - Translation Shop Prototype
**Phase Goal:** Player can translate one text, submit answer, see success/failure, earn money, dictionary updates.
**Estimated Time:** 4 hours (Hours 2-6 of development)
**Features in Phase:** 6 features (2.1 through 2.6)

---

## Feature 2.1: Translation Display System

**Priority:** CRITICAL - Without text display, there's no puzzle to solve.

**Tests Critical Question:** Q1 (Puzzle satisfaction) - Displays the core puzzle content (symbol text) that player must decode.

**Estimated Time:** 45 minutes

**Dependencies:**
- **Feature 1.2 (Symbol Data System)** must be complete - Needs symbol text data to display
- **Feature 1.3 (UI Workspace Layout)** must be complete - Renders into center workspace panel

---

### Overview

The Translation Display System shows the current translation puzzle in the center workspace area. It displays symbol text (e.g., "∆ ◊≈ ⊕⊗◈") in large readable font, provides an input field for player's English translation, and includes a Submit button. This is the primary interaction point—the visual "paper on desk" where translation work happens.

**Critical Design Constraint:** Symbols must be large enough to read clearly (48pt minimum). Input field max length 50 characters (longest solution is "they are returning soon" = 25 chars).

---

### What Player Sees

**Screen Layout:**
- **Position:** Center workspace panel (420, 90) to (1500, 780) - 1080×690px area
- **Symbol Text Display:**
  - Position: Centered horizontally, 150px from top of workspace
  - Size: Full workspace width minus 60px margins (1020px wide)
  - Height: Auto-fit to content (1-2 lines max)
- **Input Field:**
  - Position: Centered, 360px from top of workspace (below symbol text)
  - Size: 720×60px
- **Submit Button:**
  - Position: Centered, 450px from top of workspace (below input field)
  - Size: 240×60px

**Visual Appearance:**

**Symbol Text Display:**
- Background: Cream parchment #F4E8D8
- Border: 2px solid dark brown #3A2518, rounded corners 8px
- Padding: 30px all sides
- Symbol font: 72pt (scaled 1.5x from 48pt spec), color dark brown #2A1F1A
- Symbol spacing: 24px between symbol groups (space character)
- Drop shadow: Subtle 2px offset, 30% opacity black

**Input Field:**
- Background: White #FFFFFF
- Border: 3px solid medium brown #5A4A3A, rounded corners 6px
- Padding: 15px horizontal, 12px vertical
- Text font: 30pt sans-serif, color #333333
- Placeholder text: "Type your translation here..." in light gray #999999
- Cursor: Blinking vertical line, dark brown #2A1F1A

**Submit Button:**
- Background: Dark green #2D5016 (same as cash display green)
- Border: 2px solid darker green #1A3009, rounded corners 6px
- Text: "Submit Translation" in white #FFFFFF, 27pt bold sans-serif
- Padding: 18px vertical

**Visual States:**

**Default State (no active text):**
- Symbol display shows: "*Select a customer to begin...*" in italic gray #999999
- Input field disabled (grayed out, border #CCCCCC)
- Submit button disabled (background #666666, text #999999)

**Active State (text loaded):**
- Symbol display shows current puzzle symbols in dark brown
- Input field enabled (white background, clickable)
- Submit button enabled (green background, clickable)

**Input Field Focus State:**
- Border thickens to 4px, color changes to bright blue #3498DB
- Background remains white
- Cursor blinks at 1Hz

**Submit Button Hover State:**
- Background lightens to #3A6020
- Slight lift effect (2px box-shadow offset)
- Cursor changes to pointer hand

**Submit Button Active State (clicked):**
- Background darkens to #1F3610
- Button depresses (box-shadow inset 2px)
- Held for 0.2 seconds before validation triggers

**Visual Feedback:**
- **On text load:** Symbol text fades in over 0.3 seconds
- **On input focus:** Border transition to blue over 0.15 seconds
- **On submit click:** Button flash + slight scale (1.0 → 1.05 → 1.0) over 0.3 seconds
- **On validation start:** Input field becomes read-only (prevents typing during validation)

---

### What Player Does

**Input Methods:**

**Mouse:**
- Click input field to focus (enables typing)
- Click Submit button to validate translation (triggers Feature 2.2)
- Click outside input field to unfocus (deselects, keeps text)

**Keyboard:**
- Type English letters, spaces, apostrophes in input field (max 50 chars)
- Press Enter key → same as clicking Submit button
- Press Escape key → clears input field, unfocuses
- Backspace/Delete → removes characters normally

**Combined:**
- Tab key → moves focus between input field and Submit button
- Shift+Tab → reverse tab order

**Immediate Response:**

1. **Click input field** → Border turns blue, cursor appears, ready to type (instant)
2. **Type character** → Letter appears in field within 16ms (single frame at 60fps)
3. **Click Submit (or press Enter)** → Button flashes, validation starts within 0.1 seconds
4. **Press Escape** → Input field clears, cursor disappears (instant)

**Feedback Loop:**

1. **Player action:** Clicks input field, begins typing translation
2. **Visual change:** Input field border turns blue, typed text appears character-by-character
3. **System response:** Text stored in memory, character count tracked (no max length warning unless >50 chars)
4. **Player decision:** Continue typing, backspace to edit, or click Submit when confident

**Example Interaction Flow:**

Player sees symbol text "∆ ◊≈ ⊕⊗◈" displayed
→ Clicks input field (border turns blue, cursor blinks)
→ Types "t" → "th" → "the" → "the " → "the o" → "the ol" → "the old" → "the old " → "the old w" → "the old wa" → "the old way"
→ Presses Enter key (Submit button flashes)
→ Validation engine checks answer (Feature 2.2 takes over)
→ Success/failure feedback displays (Feature 2.3 takes over)

---

### Underlying Behavior

**GDScript Structure:**

```gdscript
# res://scripts/ui/TranslationDisplay.gd
extends Control

@onready var symbol_text_label = $SymbolTextDisplay/SymbolLabel
@onready var input_field = $InputField
@onready var submit_button = $SubmitButton

var current_text_id: int = 0  # 0 = no active text, 1-5 = Text ID
var is_validating: bool = false  # Prevents multiple submit clicks

func _ready():
	set_default_state()
	submit_button.pressed.connect(_on_submit_pressed)
	input_field.text_submitted.connect(_on_text_submitted)  # Enter key

func load_text(text_id: int):
	"""Load a translation text from SymbolData"""
	current_text_id = text_id
	var text_data = SymbolData.get_text(text_id)

	if text_data.is_empty():
		push_error("Invalid text_id: %d" % text_id)
		return

	# Display symbols
	symbol_text_label.text = text_data.symbols

	# Enable input
	input_field.editable = true
	input_field.placeholder_text = "Type your translation here..."
	input_field.text = ""  # Clear previous input

	# Enable submit button
	submit_button.disabled = false

	# Fade in animation
	symbol_text_label.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(symbol_text_label, "modulate:a", 1.0, 0.3)

func set_default_state():
	"""Reset to 'no active text' state"""
	current_text_id = 0
	symbol_text_label.text = "*Select a customer to begin...*"
	symbol_text_label.add_theme_color_override("font_color", Color("#999999"))
	input_field.editable = false
	input_field.text = ""
	submit_button.disabled = true

func _on_submit_pressed():
	"""Handle Submit button click"""
	if is_validating or current_text_id == 0:
		return  # Prevent multiple clicks or submit with no text

	var player_input = input_field.text.strip_edges()

	if player_input.is_empty():
		# Flash red if trying to submit empty answer
		flash_input_field(Color("#CC0000"))
		return

	# Disable input during validation
	is_validating = true
	input_field.editable = false
	submit_button.disabled = true

	# Trigger validation (Feature 2.2)
	validate_translation(current_text_id, player_input)

func _on_text_submitted(text: String):
	"""Handle Enter key press in input field"""
	_on_submit_pressed()

func validate_translation(text_id: int, player_input: String):
	"""Call validation engine and handle result"""
	var is_correct = SymbolData.validate_translation(text_id, player_input)

	if is_correct:
		handle_success(text_id)
	else:
		handle_failure()

func handle_success(text_id: int):
	"""Success feedback - Feature 2.3 handles visual effects"""
	flash_input_field(Color("#2ECC71"))  # Green flash

	# Get payment amount
	var text_data = SymbolData.get_text(text_id)
	var payment = text_data.payment_base

	# Update game state
	GameState.add_cash(payment)
	SymbolData.update_dictionary(text_id)

	# Show success message (Feature 2.3)
	show_success_feedback(payment)

	# Re-enable input after 1 second
	await get_tree().create_timer(1.0).timeout
	reset_for_next_translation()

func handle_failure():
	"""Failure feedback - Feature 2.3 handles visual effects"""
	flash_input_field(Color("#E74C3C"))  # Red flash

	# Show failure message (Feature 2.3)
	show_failure_feedback()

	# Clear input and re-enable after 0.5 seconds
	await get_tree().create_timer(0.5).timeout
	input_field.text = ""
	input_field.editable = true
	submit_button.disabled = false
	is_validating = false
	input_field.grab_focus()  # Re-focus for next attempt

func reset_for_next_translation():
	"""Prepare for next translation"""
	is_validating = false
	set_default_state()

func flash_input_field(color: Color):
	"""Flash input field border with given color"""
	var original_stylebox = input_field.get_theme_stylebox("normal")
	var flash_stylebox = original_stylebox.duplicate()
	flash_stylebox.border_color = color
	flash_stylebox.border_width_left = 4
	flash_stylebox.border_width_top = 4
	flash_stylebox.border_width_right = 4
	flash_stylebox.border_width_bottom = 4

	input_field.add_theme_stylebox_override("normal", flash_stylebox)

	await get_tree().create_timer(0.3).timeout
	input_field.add_theme_stylebox_override("normal", original_stylebox)

# Placeholder stubs for Feature 2.3
func show_success_feedback(payment: int):
	pass  # Feature 2.3 implementation

func show_failure_feedback():
	pass  # Feature 2.3 implementation
```

**Scene Structure:**

```
TranslationDisplay (Control)
├── SymbolTextDisplay (Panel)
│   └── SymbolLabel (Label) - 72pt, dark brown
├── InputField (LineEdit) - 720×60px, white bg
└── SubmitButton (Button) - 240×60px, green bg
```

**Key Numbers from Design Doc:**
- Symbol font size: 72pt (1.5x scale from 48pt)
- Input field max length: 50 characters
- 5 translation texts (Text 1 through Text 5)
- Longest solution: "they are returning soon" = 25 characters
- Validation triggered on Submit click or Enter key press

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Symbol text displays centered in workspace panel at 72pt
- [ ] Symbol text uses dark brown #2A1F1A on cream parchment #F4E8D8
- [ ] Input field is 720×60px, white background, 3px brown border
- [ ] Submit button is 240×60px, green #2D5016 background
- [ ] Placeholder text "Type your translation here..." shows in gray when empty
- [ ] Default state shows "*Select a customer to begin...*" in symbol display
- [ ] All elements properly positioned (centered, correct spacing)

**Interaction Checks:**
- [ ] Click input field → Border turns blue, cursor appears
- [ ] Type characters → Text appears immediately (no lag)
- [ ] Press Enter key → Same as clicking Submit button
- [ ] Press Escape → Input field clears
- [ ] Click Submit → Button flashes, validation starts
- [ ] Submit button disabled when no text loaded
- [ ] Input field disabled when no text loaded
- [ ] Cannot submit empty answer (red flash warning)

**Functional Checks:**
- [ ] `load_text(1)` displays "∆ ◊≈ ⊕⊗◈" from SymbolData
- [ ] `load_text(5)` displays "∆≈◊ ⊗◈≈ ◈≈∆◊◈⊩∞⊩⊞ ⬡◊◊⊩" from SymbolData
- [ ] Input field accepts letters, spaces, apostrophes (a-z, A-Z, space, ')
- [ ] Input field rejects special characters (numbers, symbols like @#$%)
- [ ] Input field max length enforced at 50 characters
- [ ] Submit triggers validation with trimmed input (leading/trailing spaces removed)
- [ ] Multiple rapid clicks on Submit don't cause duplicate validations

**Integration Checks:**
- [ ] Symbol text loaded from SymbolData.get_text(id)
- [ ] Validation calls SymbolData.validate_translation(id, input)
- [ ] Success updates GameState.add_cash(payment)
- [ ] Success updates SymbolData.update_dictionary(id)
- [ ] Symbol display updates when text changes (Text 1 → Text 2)

**Edge Case Checks:**
- [ ] Load invalid text_id (99) → Error logged, no crash
- [ ] Submit with whitespace-only input "   " → Treated as empty, red flash
- [ ] Type exactly 50 characters → Accepted, Submit works
- [ ] Type 51+ characters → Prevented (max length enforced)
- [ ] Press Enter rapidly multiple times → Only one validation triggered
- [ ] Load new text while current text active → Previous text cleared, new text displays

---

### Manual Test Script

1. **Launch game, open Debug Console (F1)**
2. **Test default state:**
   ```gdscript
   # In scene tree, locate TranslationDisplay node
   # Verify symbol_text_label.text == "*Select a customer to begin...*"
   # Verify input_field.editable == false
   # Verify submit_button.disabled == true
   ```
3. **Load Text 1:**
   ```gdscript
   $TranslationDisplay.load_text(1)
   # Observe symbol text fades in: "∆ ◊≈ ⊕⊗◈"
   # Verify input field enabled (white background, clickable)
   # Verify submit button enabled (green background)
   ```
4. **Test input field interaction:**
   - Click input field → Border should turn blue, cursor blinks
   - Type "the old way" → Text appears character by character
   - Press Escape → Input clears
   - Type "test" again
   - Click outside input field → Border returns to brown, text remains
5. **Test Submit button:**
   - Type "wrong answer" in input field
   - Click Submit button → Button flashes, red flash on input (failure)
   - Input clears after 0.5 seconds, refocuses
   - Type "the old way" (correct answer)
   - Press Enter key → Button flashes, green flash on input (success)
   - Cash updates to $150 ($100 + $50 payment)
6. **Test edge cases:**
   - Clear input field (empty)
   - Click Submit → Red flash, validation doesn't run
   - Type "   " (spaces only)
   - Click Submit → Treated as empty, red flash
7. **Test multiple texts:**
   ```gdscript
   $TranslationDisplay.load_text(2)
   # Verify new symbols: "∆ ◊≈ ⊕⊗◈ ⊕⊗⬡ ⬡∞◊⊩⊩≈⊩"
   # Previous input cleared
   ```
8. **Pass criteria:** Symbol text displays correctly, input accepts typing, Submit triggers validation, success/failure states work

---

### Known Simplifications

**Phase 2 shortcuts:**
- No text selection/highlighting in input field (OS default behavior only)
- No copy/paste prevention (player can paste answers - acceptable for prototype)
- No undo/redo (Ctrl+Z/Ctrl+Y disabled - not needed for short text)
- No autocomplete or suggestions (pure manual typing)
- Symbol display wraps to 2 lines if needed (no horizontal scroll)
- No character counter display (50 char limit enforced silently)

**Technical debt:**
- Input field doesn't sanitize HTML/special chars (could break if pasting rich text)
  - **Impact:** Low risk for prototype, fix in production
- Symbol font assumes Unicode support (might show � boxes on old systems)
  - **Impact:** Acceptable - modern systems support Unicode
- Fade-in animation uses tween (could conflict if spamming load_text())
  - **Impact:** Unlikely in normal play, not critical

---

## Feature 2.2: Translation Validation Engine

**Priority:** CRITICAL - Core game logic, determines success/failure of puzzle.

**Tests Critical Question:** Q1 (Puzzle satisfaction) - Validates if player correctly decoded symbols.

**Estimated Time:** 30 minutes

**Dependencies:**
- **Feature 1.2 (Symbol Data System)** must be complete - Needs solution data to validate against
- **Feature 2.1 (Translation Display System)** must be complete - Needs player input to validate

---

### Overview

The Translation Validation Engine compares player's typed answer to the stored solution. It normalizes both strings (lowercase, trim whitespace) and returns boolean success/failure. Allows infinite retries with no penalty—focus is on puzzle-solving satisfaction, not punishment.

**Critical Design Constraint:** Case-insensitive matching ("THE OLD WAY" = "the old way"). Word order matters ("old the way" ≠ "the old way"). No partial credit.

---

### What Player Sees

**Screen Layout:**
- **Not directly visible** - this is pure backend logic
- Player only sees results via Feature 2.3 (green flash = success, red flash = failure)

**Visual Appearance:**
- N/A - no UI components for validation logic itself

**Visual States:**
- N/A - validation happens behind the scenes

**Visual Feedback:**
- Validation completes within 0.1 seconds (imperceptible delay)
- Results manifest via Feature 2.3 feedback (flash colors, dialogue messages)

---

### What Player Does

**Input Methods:**
- **None** - validation triggered automatically by Feature 2.1 Submit button
- Player has no direct interaction with validation engine

**Immediate Response:**
- Submit button clicked → Validation runs → Result returned in <0.1 seconds
- Player perceives instant feedback (no loading spinner needed)

**Feedback Loop:**
1. **Player action:** Clicks Submit (Feature 2.1)
2. **System response:** Validation engine compares input to solution
3. **Visual change:** Success/failure feedback displays (Feature 2.3)
4. **Player decision:** Continue to next text (success) or retry (failure)

---

### Underlying Behavior

**GDScript Implementation:**

Already implemented in `SymbolData.gd` (Feature 1.2):

```gdscript
func validate_translation(text_id: int, player_input: String) -> bool:
	"""Check if player's translation matches the solution"""
	var text = get_text(text_id)
	if text.is_empty():
		return false

	# Normalize input: lowercase, strip whitespace
	var normalized_input = player_input.strip_edges().to_lower()
	var normalized_solution = text.solution.to_lower()

	return normalized_input == normalized_solution
```

**Validation Logic:**

1. **Retrieve text data:** `get_text(text_id)` → Returns text dictionary with `solution` field
2. **Normalize player input:**
   - `strip_edges()` → Removes leading/trailing whitespace ("  the old way  " → "the old way")
   - `to_lower()` → Converts to lowercase ("THE OLD WAY" → "the old way")
3. **Normalize solution:**
   - `to_lower()` → Converts stored solution to lowercase
4. **Compare strings:** Exact string match (==) → Returns true or false

**Key Numbers from Design Doc:**
- 5 solutions: "the old way", "the old way was forgotten", "the old god sleeps", "magic was once known", "they are returning soon"
- Case-insensitive: "THE OLD WAY" == "the old way" == "The Old Way"
- Whitespace normalized: "  the old way  " == "the old way"
- Word order strict: "old the way" ≠ "the old way"
- No partial credit: Must match entire solution exactly

---

### Acceptance Criteria

**Functional Checks:**
- [ ] `validate_translation(1, "the old way")` returns `true`
- [ ] `validate_translation(1, "THE OLD WAY")` returns `true` (case-insensitive)
- [ ] `validate_translation(1, "The Old Way")` returns `true` (mixed case)
- [ ] `validate_translation(1, "  the old way  ")` returns `true` (whitespace trimmed)
- [ ] `validate_translation(1, "wrong answer")` returns `false`
- [ ] `validate_translation(1, "old the way")` returns `false` (word order matters)
- [ ] `validate_translation(1, "the old")` returns `false` (incomplete answer)
- [ ] `validate_translation(1, "the old way!")` returns `false` (punctuation not allowed)
- [ ] `validate_translation(5, "they are returning soon")` returns `true` (Text 5)
- [ ] `validate_translation(99, "anything")` returns `false` (invalid text_id)

**Edge Case Checks:**
- [ ] Empty input "" returns `false`
- [ ] Whitespace-only input "   " returns `false` (normalized to "")
- [ ] Extra spaces between words "the  old  way" returns `false` (doesn't match "the old way")
- [ ] Spelling error "the ould way" returns `false`
- [ ] Apostrophe handling (if solution has apostrophe, must match exactly)

**Performance Checks:**
- [ ] Validation completes in <10ms (unnoticeable delay)
- [ ] 100 rapid validations don't cause lag or memory leak
- [ ] Invalid text_id handled gracefully (no crash)

**Integration Checks:**
- [ ] Feature 2.1 calls `validate_translation()` correctly
- [ ] Return value propagates to Feature 2.3 for feedback
- [ ] Success triggers cash update (Feature 2.5)
- [ ] Success triggers dictionary update (Feature 2.4)

---

### Manual Test Script

1. **Open Debug Console (F1), run validation tests:**
   ```gdscript
   print(SymbolData.validate_translation(1, "the old way"))  # true
   print(SymbolData.validate_translation(1, "THE OLD WAY"))  # true
   print(SymbolData.validate_translation(1, "  the old way  "))  # true
   print(SymbolData.validate_translation(1, "wrong"))  # false
   print(SymbolData.validate_translation(1, "old the way"))  # false
   ```
2. **Test all 5 solutions:**
   ```gdscript
   print(SymbolData.validate_translation(2, "the old way was forgotten"))  # true
   print(SymbolData.validate_translation(3, "the old god sleeps"))  # true
   print(SymbolData.validate_translation(4, "magic was once known"))  # true
   print(SymbolData.validate_translation(5, "they are returning soon"))  # true
   ```
3. **Test edge cases:**
   ```gdscript
   print(SymbolData.validate_translation(1, ""))  # false (empty)
   print(SymbolData.validate_translation(1, "   "))  # false (whitespace only)
   print(SymbolData.validate_translation(99, "test"))  # false (invalid ID)
   ```
4. **Integrate with Feature 2.1:**
   - Load Text 1 via TranslationDisplay
   - Type "the old way", click Submit
   - Verify validation returns `true`, success feedback displays
   - Type "wrong", click Submit
   - Verify validation returns `false`, failure feedback displays
5. **Pass criteria:** All test cases return expected boolean values, validation is instant (<0.1s)

---

### Known Simplifications

**Phase 2 shortcuts:**
- No fuzzy matching (typos always fail - "teh old way" ≠ "the old way")
- No autocorrect or suggestions (player must type exactly)
- No partial credit ("the old" doesn't give 2/3 credit)
- No hint system (validation only says yes/no, not where mistake is)

**Technical debt:**
- Normalization doesn't handle unicode edge cases (é vs e, ñ vs n)
  - **Impact:** Acceptable - all solutions are ASCII English
- Multiple spaces between words not normalized ("the  old  way" fails)
  - **Impact:** Unlikely edge case, not critical for prototype
- No profanity filter (player can type anything in input)
  - **Impact:** Single-player game, no issue

---

## Feature 2.3: Success/Failure Feedback

**Priority:** HIGH - Visual feedback makes puzzle completion satisfying.

**Tests Critical Question:** Q1 (Puzzle satisfaction) - Provides immediate gratification or clear retry prompt.

**Estimated Time:** 45 minutes

**Dependencies:**
- **Feature 2.1 (Translation Display System)** must be complete - Needs UI elements to flash/update
- **Feature 2.2 (Translation Validation Engine)** must be complete - Feedback responds to validation result

---

### Overview

Success/Failure Feedback provides visual and textual responses to translation attempts. Success shows green flash on input field, displays "+$50" payment message in dialogue box, and updates cash counter. Failure shows red flash on input field, displays "Try again" message, and clears input for retry. Customer dialogue adds personality to feedback.

**Critical Design Constraint:** Feedback must be instant and obvious—player should know success/failure within 0.3 seconds of clicking Submit. No ambiguity.

---

### What Player Sees

**Screen Layout:**

**Success Feedback:**
- **Input field:** Green flash border (0.3 second duration)
- **Dialogue box:** Payment message + customer success dialogue
  - Position: Bottom panel (0, 780) to (1920, 1080)
  - Text position: 30px from left, 30px from top of dialogue box
- **Cash counter:** Updates immediately (top-right corner)
- **Dictionary panel:** Green entries appear for learned symbols (right panel)

**Failure Feedback:**
- **Input field:** Red flash border (0.3 second duration)
- **Dialogue box:** "Try again" message + customer failure dialogue
  - Same position as success message
- **Cash counter:** Unchanged
- **Input field content:** Clears after 0.5 seconds

**Visual Appearance:**

**Success Flash (Input Field):**
- Border color: Bright green #2ECC71
- Border width: 4px (thicker than default 3px)
- Duration: 0.3 seconds fade out
- Accompanied by subtle glow effect (box-shadow: 0 0 12px rgba(46, 204, 113, 0.6))

**Failure Flash (Input Field):**
- Border color: Bright red #E74C3C
- Border width: 4px
- Duration: 0.3 seconds fade out
- Accompanied by subtle glow effect (box-shadow: 0 0 12px rgba(231, 76, 60, 0.6))

**Dialogue Box - Success Message:**
```
✓ Translation Accepted!
+$50

"Oh wonderful! Thank you so much!"
  — Mrs. Kowalski
```
- **"✓ Translation Accepted!"** - Green #2ECC71, 30pt bold
- **"+$50"** - Green #2ECC71, 36pt bold (payment amount varies: $50, $100, $150, $200)
- **Customer dialogue** - Cream #F4E8D8, 24pt, italic
- **Customer name** - Light gray #999999, 20pt

**Dialogue Box - Failure Message:**
```
✗ Incorrect Translation

"Are you sure, dear? It doesn't seem quite right..."
  — Mrs. Kowalski
```
- **"✗ Incorrect Translation"** - Red #E74C3C, 30pt bold
- **Customer dialogue** - Cream #F4E8D8, 24pt, italic
- **Customer name** - Light gray #999999, 20pt

**Visual States:**

**Default State (no feedback):**
- Dialogue box shows placeholder: "*Customer dialogue appears here...*" in gray #999999

**Success State:**
- Input field flashes green
- Dialogue box displays success message for 2 seconds
- Cash counter animates upward (+$50 → $150)
- Dictionary panel highlights new symbols in green

**Failure State:**
- Input field flashes red
- Dialogue box displays failure message for 1.5 seconds
- Input field clears after 0.5 seconds
- No cash change, no dictionary update

**Visual Feedback Sequence (Success):**
1. Submit clicked (t=0.0s)
2. Input field border flashes green (t=0.0s to t=0.3s)
3. Dialogue message appears instantly (t=0.0s)
4. Cash counter counts up (t=0.0s to t=0.5s, +$50 increments)
5. Dictionary updates (green symbols appear, t=0.3s)
6. Dialogue fades out (t=2.0s), returns to placeholder

**Visual Feedback Sequence (Failure):**
1. Submit clicked (t=0.0s)
2. Input field border flashes red (t=0.0s to t=0.3s)
3. Dialogue message appears instantly (t=0.0s)
4. Input field clears (t=0.5s)
5. Input field refocuses for retry (t=0.5s)
6. Dialogue fades out (t=1.5s), returns to placeholder

---

### What Player Does

**Input Methods:**
- **None** - feedback is passive (player watches response)
- After success: Player can select next customer/text (Feature 3.x)
- After failure: Player immediately types new answer (retry)

**Immediate Response:**
- Success: Green flash appears within 0.1 seconds of Submit click
- Failure: Red flash appears within 0.1 seconds of Submit click
- Dialogue message appears simultaneously with flash

**Feedback Loop:**

**Success:**
1. **System response:** Validation succeeds (Feature 2.2)
2. **Visual change:** Green flash, "+$50" message, cash counter updates
3. **Player perception:** "I solved it! Got paid!"
4. **Next action:** Player selects next customer (confident, ready for more)

**Failure:**
1. **System response:** Validation fails (Feature 2.2)
2. **Visual change:** Red flash, "Try again" message, input clears
3. **Player perception:** "Wrong answer, need to reconsider symbols"
4. **Next action:** Player reviews dictionary, retypes translation (learning moment)

---

### Underlying Behavior

**GDScript Implementation:**

```gdscript
# res://scripts/ui/TranslationDisplay.gd (extended from Feature 2.1)

func handle_success(text_id: int):
	"""Success feedback - flashes, message, updates"""
	# Flash input field green
	flash_input_field(Color("#2ECC71"))

	# Get text data for payment and dialogue
	var text_data = SymbolData.get_text(text_id)
	var payment = text_data.payment_base

	# Update game state
	GameState.add_cash(payment)
	SymbolData.update_dictionary(text_id)

	# Show success message in dialogue box
	show_success_message(payment, text_data.name)

	# Animate cash counter
	animate_cash_increase(payment)

	# Wait 2 seconds, then clear for next translation
	await get_tree().create_timer(2.0).timeout
	reset_for_next_translation()

func handle_failure():
	"""Failure feedback - flash, message, clear input"""
	# Flash input field red
	flash_input_field(Color("#E74C3C"))

	# Show failure message in dialogue box
	show_failure_message()

	# Clear input after 0.5 seconds and re-enable
	await get_tree().create_timer(0.5).timeout
	input_field.text = ""
	input_field.editable = true
	submit_button.disabled = false
	is_validating = false

	# Refocus input field for retry
	input_field.grab_focus()

	# Clear dialogue message after 1.5 seconds
	await get_tree().create_timer(1.0).timeout  # Total 1.5s from start
	clear_dialogue_message()

func flash_input_field(color: Color):
	"""Flash input field border with glow effect"""
	var original_style = input_field.get_theme_stylebox("normal")
	var flash_style = original_style.duplicate()

	# Set flash border
	flash_style.border_color = color
	flash_style.border_width_left = 4
	flash_style.border_width_top = 4
	flash_style.border_width_right = 4
	flash_style.border_width_bottom = 4
	flash_style.shadow_color = Color(color.r, color.g, color.b, 0.6)
	flash_style.shadow_size = 12

	input_field.add_theme_stylebox_override("normal", flash_style)

	# Fade out over 0.3 seconds
	var tween = create_tween()
	tween.tween_property(flash_style, "shadow_color:a", 0.0, 0.3)
	await tween.finished

	input_field.add_theme_stylebox_override("normal", original_style)

func show_success_message(payment: int, text_name: String):
	"""Display success message in dialogue box"""
	var dialogue_label = get_node("/root/Main/DialogueBox/DialogueLabel")

	var message = "✓ Translation Accepted!\n"
	message += "+$%d\n\n" % payment

	# Get customer success dialogue (placeholder for now)
	message += "\"Thank you for the translation!\"\n"
	message += "  — Customer"

	dialogue_label.text = message
	dialogue_label.add_theme_color_override("font_color", Color("#2ECC71"))

func show_failure_message():
	"""Display failure message in dialogue box"""
	var dialogue_label = get_node("/root/Main/DialogueBox/DialogueLabel")

	var message = "✗ Incorrect Translation\n\n"
	message += "\"Hmm, that doesn't seem right. Try again?\"\n"
	message += "  — Customer"

	dialogue_label.text = message
	dialogue_label.add_theme_color_override("font_color", Color("#E74C3C"))

func clear_dialogue_message():
	"""Reset dialogue box to placeholder"""
	var dialogue_label = get_node("/root/Main/DialogueBox/DialogueLabel")
	dialogue_label.text = "*Customer dialogue appears here...*"
	dialogue_label.add_theme_color_override("font_color", Color("#999999"))

func animate_cash_increase(amount: int):
	"""Animate cash counter counting up"""
	var cash_label = get_node("/root/Main/TopBar/CashLabel")
	var start_cash = GameState.player_cash - amount  # Before increase
	var end_cash = GameState.player_cash  # After increase

	var tween = create_tween()
	var duration = 0.5
	var steps = 10

	for i in range(steps + 1):
		var progress = float(i) / float(steps)
		var current_cash = lerp(start_cash, end_cash, progress)
		tween.tween_callback(func(): cash_label.text = "$%d" % int(current_cash))
		tween.tween_interval(duration / steps)
```

**Key Numbers from Design Doc:**
- Success flash duration: 0.3 seconds
- Failure flash duration: 0.3 seconds
- Success message display: 2.0 seconds
- Failure message display: 1.5 seconds
- Cash counter animation: 0.5 seconds
- Input clear delay (failure): 0.5 seconds
- Payment amounts: $50 (Easy), $100 (Medium), $150 (Hard), $200 (Very Hard)

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Success shows green flash on input field (#2ECC71, 4px border)
- [ ] Failure shows red flash on input field (#E74C3C, 4px border)
- [ ] Flash duration is 0.3 seconds (visible but not jarring)
- [ ] Success message displays "+$50" (or correct payment amount)
- [ ] Failure message displays "✗ Incorrect Translation"
- [ ] Dialogue box shows customer message (success or failure variant)
- [ ] Flash includes subtle glow effect (box-shadow visible)

**Interaction Checks:**
- [ ] Success feedback appears within 0.1 seconds of Submit
- [ ] Failure feedback appears within 0.1 seconds of Submit
- [ ] Success: Cash counter animates upward over 0.5 seconds
- [ ] Success: Dictionary updates with green symbols
- [ ] Failure: Input field clears after 0.5 seconds
- [ ] Failure: Input field refocuses for retry
- [ ] Success: Dialogue message fades out after 2.0 seconds
- [ ] Failure: Dialogue message fades out after 1.5 seconds

**Functional Checks:**
- [ ] Correct answer "the old way" → Green flash + "+$50" message
- [ ] Wrong answer "wrong" → Red flash + "Incorrect" message
- [ ] Payment amount matches text difficulty ($50/$100/$150/$200)
- [ ] Cash counter shows correct final amount ($100 → $150 for $50 payment)
- [ ] Dictionary updates only on success (not on failure)
- [ ] Multiple failures don't accumulate (each failure is independent)

**Integration Checks:**
- [ ] Feature 2.2 validation result triggers correct feedback (true→success, false→failure)
- [ ] Feature 2.5 cash update happens on success
- [ ] Feature 2.4 dictionary update happens on success
- [ ] Feedback clears properly before next translation

**Polish Checks:**
- [ ] Green flash feels rewarding (bright, positive)
- [ ] Red flash feels gentle (not harsh/punishing)
- [ ] Cash counter animation is smooth (no jittering)
- [ ] Dialogue text is readable (sufficient contrast, good font size)
- [ ] Timing feels natural (not too fast/slow)

**Edge Case Checks:**
- [ ] Rapid submit clicks don't cause multiple feedback sequences
- [ ] Success feedback doesn't overlap with next translation load
- [ ] Failure feedback completes before allowing next submit
- [ ] Cash counter doesn't overflow with large payments (Text 5: $200)

---

### Manual Test Script

1. **Load Text 1, submit correct answer:**
   ```gdscript
   $TranslationDisplay.load_text(1)
   # Type "the old way"
   # Click Submit
   # Observe:
   #   - Green flash on input field (0.3s)
   #   - Dialogue: "✓ Translation Accepted! +$50"
   #   - Cash: $100 → $150 (animated over 0.5s)
   #   - Dictionary: 3 new green symbols appear
   #   - After 2s, dialogue clears
   ```

2. **Load Text 1, submit wrong answer:**
   ```gdscript
   $TranslationDisplay.load_text(1)
   # Type "wrong answer"
   # Click Submit
   # Observe:
   #   - Red flash on input field (0.3s)
   #   - Dialogue: "✗ Incorrect Translation"
   #   - Input clears after 0.5s
   #   - Input refocuses (cursor blinks)
   #   - After 1.5s, dialogue clears
   #   - Cash unchanged ($100)
   ```

3. **Test multiple failures:**
   - Submit wrong answer #1 → Red flash
   - Wait for input to clear and refocus
   - Submit wrong answer #2 → Red flash again
   - Submit wrong answer #3 → Red flash again
   - Verify no accumulation (each failure independent)

4. **Test payment amounts:**
   ```gdscript
   # Text 1: $50
   $TranslationDisplay.load_text(1)
   # Submit correct → "+$50" displayed

   # Text 2: $100
   GameState.reset_game_state()  # Reset cash to $100
   $TranslationDisplay.load_text(2)
   # Submit "the old way was forgotten" → "+$100" displayed
   # Cash: $100 → $200
   ```

5. **Test animation timing:**
   - Use stopwatch to measure:
     - Flash duration (should be ~0.3s)
     - Success message display (should be ~2.0s)
     - Failure message display (should be ~1.5s)
     - Cash counter animation (should be ~0.5s)

6. **Pass criteria:** All feedback displays correctly, timing feels natural, cash updates accurately

---

### Known Simplifications

**Phase 2 shortcuts:**
- No sound effects (silence is fine for prototype)
- No particle effects (stars, sparkles on success - visual only for now)
- Generic customer dialogue ("Thank you!" placeholder instead of Mrs. Kowalski's actual line)
- No animation on dictionary update (symbols just appear, no fade-in)
- Cash counter uses linear interpolation (not eased/bouncy animation)

**Technical debt:**
- Dialogue label accessed via absolute path ("/root/Main/DialogueBox/DialogueLabel")
  - **Impact:** Fragile if scene structure changes, refactor to use @onready or signals
- Flash animation uses tween (could conflict if spamming submit)
  - **Impact:** Unlikely in normal play, validation lock prevents spam
- No accessibility support (screen readers won't announce success/failure)
  - **Impact:** Acceptable for prototype, add ARIA labels in production

---

## Feature 2.4: Dictionary Auto-Fill System

**Priority:** HIGH - Core progression mechanic, shows learning over time.

**Tests Critical Question:** Q1 (Puzzle satisfaction) - Visualizes player's growing knowledge of symbol language.

**Estimated Time:** 60 minutes

**Dependencies:**
- **Feature 1.2 (Symbol Data System)** must be complete - Needs dictionary data structure
- **Feature 1.3 (UI Workspace Layout)** must be complete - Renders into right panel
- **Feature 2.2 (Translation Validation Engine)** must be complete - Dictionary updates on successful validation

---

### Overview

The Dictionary Auto-Fill System displays all 20 symbols in the right panel, showing each symbol and its English word translation. Initially all show "???" (unknown). After successful translations, symbols update to show learned words in green. For prototype, symbols are confirmed after 1 correct use (skips 3-use confidence system for simplicity).

**Critical Design Constraint:** Dictionary is reference tool only—player can't manually edit entries. Updates happen automatically on translation success. All 20 symbols always visible (no scrolling hidden symbols).

---

### What Player Sees

**Screen Layout:**
- **Position:** Right panel (1500, 90) to (1920, 1080) - 420×990px
- **Title:** "Dictionary" at top (30px from top, centered)
- **Symbol List:** Scrollable area below title
  - Each entry: 60px tall
  - 20 entries total (∆ through ⊩)
  - Scroll if needed (20 × 60px = 1200px > 990px available)

**Visual Appearance:**

**Panel Background:**
- Background: Dark brown #2A1F1A
- Border: 2px solid #3A2518
- Title: "Dictionary" in cream #F4E8D8, 30pt serif

**Dictionary Entry (Unknown State):**
```
┌────────────────────────────┐
│  ∆              ???        │
└────────────────────────────┘
```
- Symbol (left): 36pt, dark brown #2A1F1A on cream circle bg #F4E8D8 (60px diameter)
- Word (right): "???" in gray #999999, 24pt italic
- Background: Transparent
- Divider line: 1px solid #3A2518 between entries

**Dictionary Entry (Learned/Confirmed State):**
```
┌────────────────────────────┐
│  ∆              the        │ ✓
└────────────────────────────┘
```
- Symbol (left): Same as unknown (36pt, cream circle)
- Word (right): "the" in green #2ECC71, 24pt bold
- Checkmark icon: Small green ✓ at far right
- Background: Subtle green tint #1A3009 (5% opacity)
- Divider line: Same 1px solid

**Visual States:**

**Default State (game start):**
- All 20 symbols show "???"
- Gray text, no green highlights
- Scroll position at top (∆ is first visible entry)

**After Text 1 Success (3 symbols learned):**
- ∆ → "the" (green)
- ◊ → "???" (still unknown - ◊≈ is a compound symbol)
- ◊≈ → "old" (green) - compound symbols treated as single entry
- ⊕⊗◈ → "way" (green)
- Remaining 17 symbols still "???"

**After All 5 Texts Success:**
- 15-17 symbols learned (varies based on symbol reuse across texts)
- Green entries clustered at top (sorted by learned order)
- Remaining 3-5 symbols still "???" at bottom

**Visual Feedback:**
- **On dictionary update:** Newly learned symbol fades from gray "???" to green "word" over 0.5 seconds
- **On hover:** Entry background lightens slightly (#2A1F1A → #3A2A1F)
- **On click:** No action (reference only, not interactive beyond hover)
- **Scroll behavior:** Smooth scrolling with mouse wheel or drag scrollbar

---

### What Player Does

**Input Methods:**

**Mouse:**
- Scroll wheel → Scrolls dictionary list up/down
- Hover over entry → Slight highlight (shows it's readable but not clickable)
- Click → No action (dictionary is read-only)

**Keyboard:**
- Arrow keys → Scrolls dictionary if panel focused
- Page Up/Down → Jumps by 5 entries
- Home/End → Jumps to top/bottom

**Immediate Response:**
- Scroll wheel → List scrolls smoothly (60fps, no lag)
- Symbol learned → Entry fades to green over 0.5 seconds
- Hover → Background lightens instantly

**Feedback Loop:**
1. **Player action:** Completes translation successfully (Feature 2.2)
2. **System response:** Dictionary updates with new symbols (Feature 2.4)
3. **Visual change:** Symbols fade from gray "???" to green "word"
4. **Player perception:** "I'm learning the language! Progress!"
5. **Next decision:** Player uses dictionary to solve harder texts (references known symbols)

**Example Interaction Flow:**

Player completes Text 1 ("the old way")
→ Dictionary updates: ∆="the", ◊≈="old", ⊕⊗◈="way" turn green
→ Player starts Text 2: "∆ ◊≈ ⊕⊗◈ ⊕⊗⬡ ⬡∞◊⊩⊩≈⊩"
→ Player scrolls dictionary, sees ∆="the", ◊≈="old", ⊕⊗◈="way" (known)
→ Player deduces first 3 words: "the old way ..."
→ Player focuses on unknown symbols: ⊕⊗⬡, ⬡∞◊⊩⊩≈⊩
→ Player cross-references with other known symbols, solves puzzle

---

### Underlying Behavior

**GDScript Structure:**

```gdscript
# res://scripts/ui/DictionaryPanel.gd
extends Panel

@onready var dictionary_list = $ScrollContainer/VBoxContainer

# Template scene for dictionary entries
var entry_scene = preload("res://scenes/ui/DictionaryEntry.tscn")

func _ready():
	populate_dictionary()

	# Connect to symbol learning events
	# (In real implementation, use signals; for prototype, poll on update)

func populate_dictionary():
	"""Create all 20 dictionary entries"""
	for symbol in SymbolData.SYMBOLS:
		var entry = entry_scene.instantiate()
		entry.set_symbol(symbol)
		entry.set_word(null)  # Unknown initially
		dictionary_list.add_child(entry)

func update_dictionary():
	"""Refresh all entries from SymbolData"""
	var entries = dictionary_list.get_children()

	for i in range(entries.size()):
		var symbol = SymbolData.SYMBOLS[i]
		var dict_entry = SymbolData.get_dictionary_entry(symbol)

		if dict_entry.word != null:
			# Symbol is learned
			entries[i].set_word(dict_entry.word)
			entries[i].set_learned(true)
		else:
			# Symbol still unknown
			entries[i].set_word(null)
			entries[i].set_learned(false)

func _process(_delta):
	"""Poll for dictionary updates (Phase 2 simplification)"""
	# In Phase 3+, use signals instead of polling
	update_dictionary()
```

**DictionaryEntry Scene:**

```gdscript
# res://scripts/ui/DictionaryEntry.gd
extends PanelContainer

@onready var symbol_label = $HBoxContainer/SymbolLabel
@onready var word_label = $HBoxContainer/WordLabel
@onready var checkmark = $HBoxContainer/Checkmark

var is_learned: bool = false

func set_symbol(symbol: String):
	"""Set the symbol to display"""
	symbol_label.text = symbol

func set_word(word):
	"""Set the English word (null = unknown)"""
	if word == null:
		word_label.text = "???"
		word_label.add_theme_color_override("font_color", Color("#999999"))
		checkmark.visible = false
	else:
		word_label.text = word
		word_label.add_theme_color_override("font_color", Color("#2ECC71"))
		checkmark.visible = true

func set_learned(learned: bool):
	"""Update visual state for learned symbols"""
	is_learned = learned

	if learned:
		# Green tint background
		var style = get_theme_stylebox("panel").duplicate()
		style.bg_color = Color("#1A3009")
		add_theme_stylebox_override("panel", style)

		# Fade in animation
		modulate.a = 0
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.5)
	else:
		# Transparent background
		var style = get_theme_stylebox("panel").duplicate()
		style.bg_color = Color(0, 0, 0, 0)
		add_theme_stylebox_override("panel", style)

func _on_mouse_entered():
	"""Hover highlight"""
	if not is_learned:
		modulate = Color(1.1, 1.1, 1.1)

func _on_mouse_exited():
	"""Remove hover highlight"""
	modulate = Color(1, 1, 1)
```

**Scene Hierarchy:**

```
RightPanel (Panel)
├── TitleLabel (Label) - "Dictionary"
└── ScrollContainer
    └── VBoxContainer - Holds all 20 DictionaryEntry instances
        ├── DictionaryEntry #1 (∆)
        ├── DictionaryEntry #2 (◊)
        ├── DictionaryEntry #3 (≈)
        ...
        └── DictionaryEntry #20 (⊩)

DictionaryEntry.tscn (template scene)
├── HBoxContainer
│   ├── SymbolLabel (Label) - 36pt symbol
│   ├── WordLabel (Label) - 24pt word or "???"
│   └── Checkmark (Label) - Small green ✓
```

**Key Numbers from Design Doc:**
- 20 total symbols in alphabet
- Text 1: Teaches 3 symbols (∆="the", ◊≈="old", ⊕⊗◈="way")
- Text 2: Teaches 2 new symbols (⊕⊗⬡="was", ⬡∞◊⊩⊩≈⊩="forgotten")
- Text 3: Teaches 2 new symbols (⊞⊟≈="god", ⬡≈≈⊢⬡="sleeps")
- Text 4: Teaches 4 new symbols (⊗◈⊞∞◈="magic", ◊⊩◈≈="once", ⊟⊩◊⊕⊩="known")
- Text 5: Teaches 4 new symbols (∆≈◊="they", ⊗◈≈="are", ◈≈∆◊◈⊩∞⊩⊞="returning", ⬡◊◊⊩="soon")
- Total: 15 unique symbol groups across all 5 texts
- Confidence rule (prototype): 1 correct use = confirmed (green)

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Dictionary panel displays 20 symbol entries
- [ ] Title "Dictionary" visible at top in cream #F4E8D8
- [ ] Unknown symbols show "???" in gray #999999
- [ ] Learned symbols show word in green #2ECC71
- [ ] Learned symbols have green checkmark ✓ at right
- [ ] Learned symbols have subtle green tint background
- [ ] Symbols display at 36pt, words at 24pt
- [ ] Divider lines between entries (1px solid #3A2518)

**Interaction Checks:**
- [ ] Scroll wheel scrolls dictionary list smoothly
- [ ] Hover over entry → Background lightens slightly
- [ ] Click entry → No action (read-only)
- [ ] Scrollbar appears when 20 entries overflow panel height
- [ ] Scroll position resets to top on game restart

**Functional Checks:**
- [ ] Initial state: All 20 symbols show "???"
- [ ] Complete Text 1 → 3 symbols turn green (∆, ◊≈, ⊕⊗◈)
- [ ] Complete Text 2 → 2 more symbols turn green (⊕⊗⬡, ⬡∞◊⊩⊩≈⊩)
- [ ] Complete all 5 texts → 15 symbols learned, 5 still "???"
- [ ] Dictionary updates automatically on translation success
- [ ] Dictionary does NOT update on translation failure
- [ ] Symbol-word mappings match SymbolData.texts definitions exactly

**Integration Checks:**
- [ ] Dictionary pulls data from SymbolData.dictionary
- [ ] SymbolData.update_dictionary(text_id) triggers visual update
- [ ] All 20 SYMBOLS array entries represented in dictionary
- [ ] Compound symbols (◊≈, ⊕⊗◈) treated as single dictionary entries
- [ ] Dictionary state persists across translations (doesn't reset)

**Animation Checks:**
- [ ] Newly learned symbol fades in over 0.5 seconds
- [ ] Fade animation doesn't block other interactions
- [ ] Multiple symbols can fade in simultaneously (Text 1: 3 symbols)

**Edge Case Checks:**
- [ ] Scroll to bottom → Entry #20 (⊩) visible
- [ ] Learn all 20 symbols → All show green, no "???" remaining
- [ ] Reset game → Dictionary reverts to all "???"
- [ ] Complete Text 1 twice → Symbols don't duplicate (already green stays green)

---

### Manual Test Script

1. **Verify initial state:**
   ```gdscript
   # Launch game
   # Open right panel dictionary
   # Verify all 20 symbols show "???" in gray
   # Verify title "Dictionary" at top
   # Scroll to bottom, verify all 20 entries present
   ```

2. **Complete Text 1, verify update:**
   ```gdscript
   # Load Text 1
   # Type "the old way", submit (success)
   # Observe dictionary update:
   #   - ∆ → "the" (green, checkmark)
   #   - ◊≈ → "old" (green, checkmark)
   #   - ⊕⊗◈ → "way" (green, checkmark)
   #   - Remaining 17 still "???"
   # Verify fade-in animation (0.5s)
   ```

3. **Test dictionary as reference tool:**
   ```gdscript
   # Load Text 2: "∆ ◊≈ ⊕⊗◈ ⊕⊗⬡ ⬡∞◊⊩⊩≈⊩"
   # Open dictionary, verify known symbols:
   #   - ∆ = "the" (green)
   #   - ◊≈ = "old" (green)
   #   - ⊕⊗◈ = "way" (green)
   # Verify unknown symbols:
   #   - ⊕⊗⬡ = "???"
   #   - ⬡∞◊⊩⊩≈⊩ = "???"
   # Use dictionary to solve: "the old way [unknown] [unknown]"
   ```

4. **Complete all 5 texts:**
   ```gdscript
   GameState.reset_game_state()
   SymbolData.initialize_dictionary()

   # Complete Text 1: 3 symbols learned
   # Complete Text 2: 5 symbols learned (3 + 2 new)
   # Complete Text 3: 7 symbols learned (5 + 2 new)
   # Complete Text 4: 11 symbols learned (7 + 4 new)
   # Complete Text 5: 15 symbols learned (11 + 4 new)

   # Verify final state:
   print("Learned symbols: %d" % count_learned_symbols())  # Should be 15
   # Verify 5 symbols still "???"
   ```

5. **Test scrolling:**
   - Scroll to bottom using mouse wheel
   - Verify Entry #20 (⊩) visible
   - Scroll to top using Home key
   - Verify Entry #1 (∆) visible
   - Drag scrollbar to middle
   - Verify entries #10-15 visible

6. **Pass criteria:** All 20 symbols display, updates happen automatically on translation success, dictionary serves as functional reference tool

---

### Known Simplifications

**Phase 2 shortcuts:**
- Immediate confirmation after 1 use (skips 3-use confidence progression)
- No tentative/yellow state (goes straight from unknown/gray to confirmed/green)
- Polling for updates (_process) instead of signal-based (less efficient)
- No click-to-highlight feature (can't click symbol to highlight it in translation text)
- No search/filter (all 20 symbols always visible)
- No symbol etymology or hints (just symbol + word mapping)

**Technical debt:**
- Compound symbols (◊≈, ⊕⊗◈) not broken into components
  - **Impact:** Fine for 5-text prototype, might need parsing for larger game
- Dictionary doesn't show usage count (how many times symbol appeared)
  - **Impact:** Acceptable - confidence system cut for simplicity
- No tooltip on hover (could show "Learned from Text 1" on hover)
  - **Impact:** Nice-to-have, not critical for prototype
- Scrollbar styling uses Godot default (not themed to match aesthetic)
  - **Impact:** Functional but not polished, acceptable for prototype

---

## Feature 2.5: Money Tracking System

**Priority:** MEDIUM - Important for progression, but simple implementation.

**Tests Critical Question:** Q4 (Economic pressure) - Tracks earnings to test if puzzle payouts sustain shop costs.

**Estimated Time:** 20 minutes

**Dependencies:**
- **Feature 1.1 (Game State Manager)** must be complete - Uses GameState.add_cash()
- **Feature 2.2 (Translation Validation Engine)** must be complete - Payment triggered by successful validation

---

### Overview

The Money Tracking System updates the cash counter after successful translations, adding payment ($50-$200 based on difficulty). Cash displays in top-right corner at all times with color-coding (green ≥$200, orange $100-199, red <$100). No deductions yet in Phase 2—utilities and rent added in Phase 4.

**Critical Design Constraint:** Cash display must be visible at all times (persistent UI element). Color changes should be instant and obvious to signal financial health.

---

### What Player Sees

**Screen Layout:**
- **Position:** Top-right corner of top bar (1550, 22) to (1890, 68)
- **Size:** 340×46px
- **Alignment:** Right-aligned text

**Visual Appearance:**

**Cash Display:**
- Text: "$100" (or current amount)
- Font: 36pt bold sans-serif
- Color: Dynamic based on amount
  - Green #2D5016: ≥ $200 (comfortable)
  - Orange #CC6600: $100-199 (cautious)
  - Red #8B0000: < $100 (danger)
- Background: Transparent (blends with top bar)
- Drop shadow: 2px offset, 30% opacity black (for readability)

**Visual States:**

**Green State (≥$200):**
- Color: #2D5016 (dark green)
- Indicates: Player has surplus, can afford expenses
- Example: "$250"

**Orange State ($100-199):**
- Color: #CC6600 (orange)
- Indicates: Player has enough for immediate needs, but tight
- Example: "$150"

**Red State (<$100):**
- Color: #8B0000 (dark red)
- Indicates: Player below starting capital, financial pressure
- Example: "$75"

**Visual Feedback:**
- **On cash increase:** Counter animates from old value to new value over 0.5 seconds
  - Example: $100 → $110 → $120 → $130 → $140 → $150 (smooth count-up)
- **On color change:** Color transitions smoothly over 0.3 seconds
  - Example: $195 (orange) + $10 → $205 (transitions orange → green)
- **On negative cash (game over):** Text flashes red 3 times, then stays red
  - Not implemented in Phase 2 (no deductions yet)

---

### What Player Does

**Input Methods:**
- **None** - cash counter is read-only
- Player observes cash changes passively

**Immediate Response:**
- Translation success → Cash increases within 0.5 seconds (animated count-up)
- Color change happens during count-up animation (smooth transition)

**Feedback Loop:**
1. **Player action:** Completes translation successfully (Feature 2.2)
2. **System response:** GameState.add_cash(payment) called
3. **Visual change:** Cash counter animates upward, color updates if threshold crossed
4. **Player perception:** "I earned $50! Still in the green!"
5. **Next decision:** Continue translating to earn more, or prepare for expenses (Phase 4)

**Example Interaction Flow:**

Player starts with $100 (orange)
→ Completes Text 1 (Easy, $50 payment)
→ Cash animates: $100 → $110 → $120 → $130 → $140 → $150
→ Color stays orange (still <$200)
→ Completes Text 2 (Medium, $100 payment)
→ Cash animates: $150 → $170 → $190 → $210 → $230 → $250
→ Color transitions orange → green at $200 threshold
→ Player feels financial security

---

### Underlying Behavior

**GDScript Implementation:**

Already implemented in `GameState.gd` (Feature 1.1):

```gdscript
# res://scripts/GameState.gd
func add_cash(amount: int):
	"""Add cash to player's balance"""
	player_cash += amount

func get_cash_color() -> Color:
	"""Return color based on cash amount thresholds"""
	if player_cash >= 200:
		return Color("#2D5016")  # Green - comfortable
	elif player_cash >= 100:
		return Color("#CC6600")  # Orange - cautious
	else:
		return Color("#8B0000")  # Red - danger
```

**Cash Label Update (from Feature 1.1):**

```gdscript
# res://scripts/ui/CashLabel.gd
extends Label

func _process(_delta):
	text = "$%d" % GameState.player_cash
	modulate = GameState.get_cash_color()
```

**Animation Enhancement (Feature 2.5 addition):**

```gdscript
# res://scripts/ui/CashLabel.gd (enhanced)
extends Label

var target_cash: int = 100
var displayed_cash: int = 100
var animation_speed: float = 100.0  # Dollars per second

func _ready():
	target_cash = GameState.player_cash
	displayed_cash = GameState.player_cash

func _process(delta):
	# Check if GameState cash changed
	if GameState.player_cash != target_cash:
		target_cash = GameState.player_cash

	# Animate towards target
	if displayed_cash != target_cash:
		var diff = target_cash - displayed_cash
		var step = sign(diff) * min(abs(diff), animation_speed * delta)
		displayed_cash += int(step)

	# Update display
	text = "$%d" % displayed_cash
	modulate = get_cash_color_for_amount(displayed_cash)

func get_cash_color_for_amount(amount: int) -> Color:
	"""Get color for specific cash amount (for smooth transition during animation)"""
	if amount >= 200:
		return Color("#2D5016")
	elif amount >= 100:
		return Color("#CC6600")
	else:
		return Color("#8B0000")
```

**Key Numbers from Design Doc:**
- Starting cash: $100 (orange)
- Text 1 payment: $50 (Easy)
- Text 2 payment: $100 (Medium)
- Text 3 payment: $100 (Medium)
- Text 4 payment: $150 (Hard)
- Text 5 payment: $200 (Hard)
- Color thresholds: ≥$200 green, $100-199 orange, <$100 red
- Animation duration: 0.5 seconds (100 dollars/second speed)

---

### Acceptance Criteria

**Visual Checks:**
- [ ] Cash counter displays in top-right corner (1550, 22)
- [ ] Font is 36pt bold sans-serif
- [ ] Starting cash shows "$100" in orange #CC6600
- [ ] Cash ≥$200 shows green #2D5016
- [ ] Cash $100-199 shows orange #CC6600
- [ ] Cash <$100 shows red #8B0000
- [ ] Drop shadow visible for readability

**Interaction Checks:**
- [ ] Cash increases after successful translation
- [ ] Counter animates from old value to new value (smooth count-up)
- [ ] Animation duration is ~0.5 seconds (100 dollars/second)
- [ ] Color transitions smoothly during animation
- [ ] Multiple rapid payments queue correctly (no conflicts)

**Functional Checks:**
- [ ] Start with $100 → Display shows "$100" (orange)
- [ ] Complete Text 1 (+$50) → Display shows "$150" (orange)
- [ ] Complete Text 2 (+$100) → Display shows "$250" (green)
- [ ] Cash value matches GameState.player_cash exactly (after animation completes)
- [ ] Color threshold at $200 works: $199 (orange) vs $200 (green)
- [ ] Color threshold at $100 works: $99 (red) vs $100 (orange)

**Integration Checks:**
- [ ] Feature 2.2 validation success triggers Feature 2.5 cash increase
- [ ] Payment amount matches text difficulty (Text 1: $50, Text 5: $200)
- [ ] GameState.add_cash() updates internal state correctly
- [ ] Cash label reads GameState.player_cash in _process()
- [ ] Color updates use GameState.get_cash_color() or local logic

**Animation Checks:**
- [ ] $100 → $150 (+$50) animates smoothly over 0.5 seconds
- [ ] $150 → $250 (+$100) animates smoothly over 1.0 seconds (100 dollars/second)
- [ ] Color transition from orange → green happens during animation (at $200 mark)
- [ ] Animation doesn't overshoot target (stops exactly at final value)

**Edge Case Checks:**
- [ ] Cash = $0 → Displays "$0" in red
- [ ] Cash = $999 → Displays "$999" in green (no overflow)
- [ ] Multiple payments in quick succession queue correctly (e.g., +$50, +$100)
- [ ] Animation interrupted by new payment updates target mid-animation

---

### Manual Test Script

1. **Verify initial state:**
   ```gdscript
   # Launch game
   # Verify cash displays "$100" in orange #CC6600
   # Verify position in top-right corner
   ```

2. **Test single payment:**
   ```gdscript
   # Complete Text 1 (correct answer: "the old way")
   # Observe cash animation: $100 → $150
   # Time animation with stopwatch (~0.5 seconds)
   # Verify color stays orange (still <$200)
   ```

3. **Test color threshold (orange → green):**
   ```gdscript
   GameState.player_cash = 195  # Just below threshold
   # Complete Text 1 (+$50)
   # Observe:
   #   - $195 (orange) → $200 (green) → $205 (green) → ... → $245 (green)
   #   - Color transitions at exactly $200
   ```

4. **Test color threshold (orange → red):**
   ```gdscript
   GameState.player_cash = 105  # Just above threshold
   # Manually deduct $10 (for testing):
   GameState.player_cash = 95
   # Observe:
   #   - $105 (orange) → $100 (orange) → $99 (red) → ... → $95 (red)
   #   - Color transitions at exactly $100
   ```

5. **Test all payment amounts:**
   ```gdscript
   # Reset to $100
   GameState.reset_game_state()

   # Text 1: +$50 → $150 (orange)
   # Text 2: +$100 → $250 (green)
   # Text 3: +$100 → $350 (green)
   # Text 4: +$150 → $500 (green)
   # Text 5: +$200 → $700 (green)

   # Verify final cash: $700
   ```

6. **Test animation interruption:**
   ```gdscript
   # Start cash at $100
   # Complete Text 2 (+$100, starts animating $100 → $200)
   # Immediately complete Text 1 (+$50)
   # Observe:
   #   - Animation should update target mid-flight
   #   - Final cash should be $250 (not $200 + $50 = $250)
   ```

7. **Pass criteria:** Cash displays correctly, animates smoothly, color thresholds work precisely, all payment amounts accurate

---

### Known Simplifications

**Phase 2 shortcuts:**
- No cash deductions yet (utilities/rent added in Phase 4)
- No negative cash handling (can't go below $0 in Phase 2)
- No cash history/transaction log (just current total)
- Animation uses linear interpolation (not eased/bouncy)
- No sound effect on cash increase (visual only)

**Technical debt:**
- Color transition during animation could be smoother (currently jumps at threshold)
  - **Impact:** Minor visual issue, acceptable for prototype
- Animation speed is constant (100 dollars/second) regardless of amount
  - **Impact:** Large payments (+$200) take 2 seconds, might feel slow
  - **Fix:** Use percentage-based duration instead
- No maximum cash cap (could overflow with many translations)
  - **Impact:** Unlikely in 7-day prototype, not critical

---

## Feature 2.6: Five Translation Texts

**Priority:** CRITICAL - Core content, tests full difficulty progression.

**Tests Critical Question:** Q1 (Puzzle satisfaction) - Validates if puzzles increase in complexity satisfyingly.

**Estimated Time:** 30 minutes

**Dependencies:**
- **Feature 1.2 (Symbol Data System)** must be complete - Contains all 5 text definitions
- **Feature 2.1 (Translation Display System)** must be complete - Displays texts
- **Feature 2.2 (Translation Validation Engine)** must be complete - Validates answers
- **Feature 2.4 (Dictionary Auto-Fill System)** must be complete - Shows learning progression

---

### Overview

Five Translation Texts provide the full puzzle content: Text 1 (Easy, 3 words), Text 2 (Medium, 5 words), Text 3 (Medium, 4 words), Text 4 (Hard, 4 words), Text 5 (Hard, 4 words). Each text reuses some symbols from previous texts (building dictionary knowledge) and introduces new symbols. Difficulty increases via vocabulary complexity, not time pressure.

**Critical Design Constraint:** Symbol consistency across texts (∆ always = "the"). Difficulty based on how many unknown symbols, not puzzle mechanics. All 5 texts must be solvable with dictionary knowledge from previous texts.

---

### What Player Sees

**Screen Layout:**
- **Position:** Center workspace panel (symbol text display area)
- **Text Selection:** Via customer queue (Phase 3) - for Phase 2, manually loaded via debug or hardcoded sequence

**Visual Appearance:**

**Text 1: "the old way"**
```
Symbol Display:
∆ ◊≈ ⊕⊗◈

Payment: $50
Difficulty: Easy
```
- 3 symbol groups
- All unknown initially (cold start)
- Simple 1:1 word substitution

**Text 2: "the old way was forgotten"**
```
Symbol Display:
∆ ◊≈ ⊕⊗◈ ⊕⊗⬡ ⬡∞◊⊩⊩≈⊩

Payment: $100
Difficulty: Medium
```
- 5 symbol groups
- First 3 known from Text 1 (∆="the", ◊≈="old", ⊕⊗◈="way")
- 2 new symbols to learn (⊕⊗⬡="was", ⬡∞◊⊩⊩≈⊩="forgotten")

**Text 3: "the old god sleeps"**
```
Symbol Display:
∆ ◊≈ ⊞⊟≈ ⬡≈≈⊢⬡

Payment: $100
Difficulty: Medium
```
- 4 symbol groups
- First 2 known from Text 1 (∆="the", ◊≈="old")
- 2 new symbols (⊞⊟≈="god", ⬡≈≈⊢⬡="sleeps")
- Tests cross-referencing: ⬡ appears in new context (not ⊕⊗⬡)

**Text 4: "magic was once known"**
```
Symbol Display:
⊗◈⊞∞◈ ⊕⊗⬡ ◊⊩◈≈ ⊟⊩◊⊕⊩

Payment: $150
Difficulty: Hard
```
- 4 symbol groups
- Only 1 known from previous (⊕⊗⬡="was" from Text 2)
- 3 new symbols (⊗◈⊞∞◈="magic", ◊⊩◈≈="once", ⊟⊩◊⊕⊩="known")
- Tests deduction: Many unknown, must use context/patterns

**Text 5: "they are returning soon"**
```
Symbol Display:
∆≈◊ ⊗◈≈ ◈≈∆◊◈⊩∞⊩⊞ ⬡◊◊⊩

Payment: $200
Difficulty: Hard
```
- 4 symbol groups
- 0 exact matches to previous (all compound symbols)
- Contains familiar components (∆, ◊, ⊩, ⬡) in new combinations
- Tests pattern recognition: "returning" is longest word (9 symbols)
- Finale difficulty: Must synthesize all prior knowledge

**Visual States:**
- All texts display identically (72pt symbols, cream parchment background)
- Difficulty indicated by payment amount ($50 Easy → $200 Hard)
- No time limit or pressure (static display, player works at own pace)

---

### What Player Does

**Input Methods:**
- Same as Feature 2.1 (type translation, click Submit)
- Player references dictionary (Feature 2.4) to decode symbols
- Player uses paper notes (external, not in-game) to track patterns

**Immediate Response:**
- Load text → Symbols display instantly
- Type translation → Character-by-character input
- Submit → Validation (Feature 2.2) → Success/Failure (Feature 2.3)

**Feedback Loop (Full Progression):**

**Text 1 (Cold Start):**
1. Player sees "∆ ◊≈ ⊕⊗◈" (all unknown)
2. Player guesses "the old way" (lucky) or tries combinations
3. Success → Dictionary shows 3 green symbols
4. Player learns: ∆="the", ◊≈="old", ⊕⊗◈="way"

**Text 2 (Building Knowledge):**
1. Player sees "∆ ◊≈ ⊕⊗◈ ⊕⊗⬡ ⬡∞◊⊩⊩≈⊩"
2. Player checks dictionary: ∆="the", ◊≈="old", ⊕⊗◈="way" (known)
3. Player deduces: "the old way [?] [?]"
4. Player considers context: "the old way [was/is] [forgotten/lost]?"
5. Player guesses "the old way was forgotten"
6. Success → Dictionary adds 2 more symbols
7. Player confidence grows: "I can use what I know!"

**Text 3 (Cross-Reference):**
1. Player sees "∆ ◊≈ ⊞⊟≈ ⬡≈≈⊢⬡"
2. Player knows: ∆="the", ◊≈="old"
3. Player deduces: "the old [?] [?]"
4. Player notices: ⊞⊟≈ and ⬡≈≈⊢⬡ are new
5. Player guesses religious/mythological theme: "the old god sleeps"
6. Success → Dictionary grows to 8 symbols

**Text 4 (Challenge):**
1. Player sees "⊗◈⊞∞◈ ⊕⊗⬡ ◊⊩◈≈ ⊟⊩◊⊕⊩"
2. Player knows only: ⊕⊗⬡="was"
3. Player deduces: "[?] was [?] [?]"
4. Player notices components: ⊗◈ appears in "⊗◈⊞∞◈" and SymbolData.SYMBOLS
5. Player tries thematic guess: "magic was once known"
6. Success → Breakthrough moment, pattern recognition

**Text 5 (Finale):**
1. Player sees "∆≈◊ ⊗◈≈ ◈≈∆◊◈⊩∞⊩⊞ ⬡◊◊⊩"
2. Player sees familiar components (∆, ◊, ⊩) but new combinations
3. Player uses all prior knowledge: "they are returning soon"
4. Success → Completion, narrative payoff

---

### Underlying Behavior

**Data Already Defined in Feature 1.2:**

All 5 texts are stored in `SymbolData.texts`:

```gdscript
var texts: Array = [
	{
		"id": 1,
		"name": "Text 1 - Family History",
		"symbols": "∆ ◊≈ ⊕⊗◈",
		"solution": "the old way",
		"mappings": {"∆": "the", "◊≈": "old", "⊕⊗◈": "way"},
		"difficulty": "Easy",
		"payment_base": 50,
		"hint": "Simple word substitution. Each symbol group = one English word."
	},
	{
		"id": 2,
		"name": "Text 2 - Forgotten Ways",
		"symbols": "∆ ◊≈ ⊕⊗◈ ⊕⊗⬡ ⬡∞◊⊩⊩≈⊩",
		"solution": "the old way was forgotten",
		"mappings": {"∆": "the", "◊≈": "old", "⊕⊗◈": "way", "⊕⊗⬡": "was", "⬡∞◊⊩⊩≈⊩": "forgotten"},
		"difficulty": "Medium",
		"payment_base": 100,
		"hint": "Builds on previous text. Look for familiar symbols."
	},
	{
		"id": 3,
		"name": "Text 3 - Sleeping God",
		"symbols": "∆ ◊≈ ⊞⊟≈ ⬡≈≈⊢⬡",
		"solution": "the old god sleeps",
		"mappings": {"∆": "the", "◊≈": "old", "⊞⊟≈": "god", "⬡≈≈⊢⬡": "sleeps"},
		"difficulty": "Medium",
		"payment_base": 100,
		"hint": "Half the symbols are known. New vocabulary: divine entities."
	},
	{
		"id": 4,
		"name": "Text 4 - Lost Magic",
		"symbols": "⊗◈⊞∞◈ ⊕⊗⬡ ◊⊩◈≈ ⊟⊩◊⊕⊩",
		"solution": "magic was once known",
		"mappings": {"⊗◈⊞∞◈": "magic", "⊕⊗⬡": "was", "◊⊩◈≈": "once", "⊟⊩◊⊕⊩": "known"},
		"difficulty": "Hard",
		"payment_base": 150,
		"hint": "Only one familiar symbol. Deduce from context."
	},
	{
		"id": 5,
		"name": "Text 5 - The Return",
		"symbols": "∆≈◊ ⊗◈≈ ◈≈∆◊◈⊩∞⊩⊞ ⬡◊◊⊩",
		"solution": "they are returning soon",
		"mappings": {"∆≈◊": "they", "⊗◈≈": "are", "◈≈∆◊◈⊩∞⊩⊞": "returning", "⬡◊◊⊩": "soon"},
		"difficulty": "Hard",
		"payment_base": 200,
		"hint": "Finale text. Ominous warning. Synthesis of all previous knowledge."
	}
]
```

**Loading Texts in Sequence (Phase 2 Prototype):**

```gdscript
# res://scripts/ui/TranslationDisplay.gd (addition)

var current_text_index: int = 0  # 0 = Text 1, 4 = Text 5

func load_next_text():
	"""Load next text in sequence (for Phase 2 testing)"""
	if current_text_index >= 5:
		print("All texts completed!")
		return

	current_text_index += 1
	load_text(current_text_index)

func _on_success():
	"""Called after successful translation (Feature 2.3)"""
	# Wait 2 seconds, then load next text
	await get_tree().create_timer(2.0).timeout
	load_next_text()
```

**Key Numbers from Design Doc:**
- 5 total texts
- Text lengths: 3, 5, 4, 4, 4 words
- Symbol groups: 3, 5, 4, 4, 4 per text
- Unique symbols taught: 3, 2, 2, 4, 4 (total 15 unique symbol groups)
- Payment progression: $50, $100, $100, $150, $200 (total $600 if all completed)
- Difficulty curve: Easy → Medium → Medium → Hard → Hard

---

### Acceptance Criteria

**Content Checks:**
- [ ] Text 1 displays "∆ ◊≈ ⊕⊗◈", solution is "the old way", payment $50
- [ ] Text 2 displays "∆ ◊≈ ⊕⊗◈ ⊕⊗⬡ ⬡∞◊⊩⊩≈⊩", solution is "the old way was forgotten", payment $100
- [ ] Text 3 displays "∆ ◊≈ ⊞⊟≈ ⬡≈≈⊢⬡", solution is "the old god sleeps", payment $100
- [ ] Text 4 displays "⊗◈⊞∞◈ ⊕⊗⬡ ◊⊩◈≈ ⊟⊩◊⊕⊩", solution is "magic was once known", payment $150
- [ ] Text 5 displays "∆≈◊ ⊗◈≈ ◈≈∆◊◈⊩∞⊩⊞ ⬡◊◊⊩", solution is "they are returning soon", payment $200
- [ ] All solutions are lowercase (case-insensitive validation)
- [ ] All symbol-to-word mappings match SymbolData definitions

**Symbol Consistency Checks:**
- [ ] ∆ = "the" in Text 1, 2, 3 (consistent)
- [ ] ◊≈ = "old" in Text 1, 2, 3 (consistent)
- [ ] ⊕⊗⬡ = "was" in Text 2, 4 (consistent)
- [ ] No symbol maps to different words in different texts

**Difficulty Progression Checks:**
- [ ] Text 1: 0 known symbols initially (cold start, hardest puzzle subjectively)
- [ ] Text 2: 3 known symbols (∆, ◊≈, ⊕⊗◈), 2 unknown
- [ ] Text 3: 2 known symbols (∆, ◊≈), 2 unknown
- [ ] Text 4: 1 known symbol (⊕⊗⬡), 3 unknown (spike in difficulty)
- [ ] Text 5: 0 exact known symbols, but familiar components (final challenge)
- [ ] Payment increases with difficulty ($50 → $200)

**Dictionary Learning Checks:**
- [ ] After Text 1: 3 symbols learned (∆, ◊≈, ⊕⊗◈)
- [ ] After Text 2: 5 symbols learned (adds ⊕⊗⬡, ⬡∞◊⊩⊩≈⊩)
- [ ] After Text 3: 7 symbols learned (adds ⊞⊟≈, ⬡≈≈⊢⬡)
- [ ] After Text 4: 11 symbols learned (adds ⊗◈⊞∞◈, ◊⊩◈≈, ⊟⊩◊⊕⊩)
- [ ] After Text 5: 15 symbols learned (adds ∆≈◊, ⊗◈≈, ◈≈∆◊◈⊩∞⊩⊞, ⬡◊◊⊩)
- [ ] 5 symbols remain unknown (never used in any text)

**Functional Checks:**
- [ ] Load Text 1 → Displays correctly
- [ ] Submit correct answer "the old way" → Success feedback
- [ ] Load Text 2 → Displays correctly
- [ ] Submit correct answer "the old way was forgotten" → Success feedback
- [ ] Repeat for Texts 3, 4, 5
- [ ] All 5 texts solvable in sequence

**Integration Checks:**
- [ ] Feature 2.1 displays all 5 texts correctly
- [ ] Feature 2.2 validates all 5 solutions correctly
- [ ] Feature 2.3 shows success feedback for all 5 texts
- [ ] Feature 2.4 dictionary updates after each text
- [ ] Feature 2.5 cash increases correctly ($100 → $150 → $250 → $350 → $500 → $700)

**Edge Case Checks:**
- [ ] Complete texts out of order (Text 5 before Text 1) → Still works (no hard dependencies)
- [ ] Complete same text twice → Dictionary doesn't re-add symbols (idempotent)
- [ ] Skip text (1 → 3 → 5) → Dictionary only has symbols from completed texts

---

### Manual Test Script

1. **Complete full progression (Text 1 through Text 5):**
   ```gdscript
   # Reset game state
   GameState.reset_game_state()
   SymbolData.initialize_dictionary()

   # Text 1
   $TranslationDisplay.load_text(1)
   # Type "the old way", submit
   # Verify: +$50, cash = $150, dictionary shows 3 symbols

   # Text 2
   $TranslationDisplay.load_text(2)
   # Type "the old way was forgotten", submit
   # Verify: +$100, cash = $250, dictionary shows 5 symbols

   # Text 3
   $TranslationDisplay.load_text(3)
   # Type "the old god sleeps", submit
   # Verify: +$100, cash = $350, dictionary shows 7 symbols

   # Text 4
   $TranslationDisplay.load_text(4)
   # Type "magic was once known", submit
   # Verify: +$150, cash = $500, dictionary shows 11 symbols

   # Text 5
   $TranslationDisplay.load_text(5)
   # Type "they are returning soon", submit
   # Verify: +$200, cash = $700, dictionary shows 15 symbols
   ```

2. **Verify symbol consistency:**
   ```gdscript
   # Check Text 1 mappings
   var text1 = SymbolData.get_text(1)
   print(text1.mappings["∆"])  # "the"

   # Check Text 2 mappings
   var text2 = SymbolData.get_text(2)
   print(text2.mappings["∆"])  # "the" (same as Text 1)

   # Check Text 4 mappings
   var text4 = SymbolData.get_text(4)
   print(text4.mappings["⊕⊗⬡"])  # "was" (same as Text 2)
   ```

3. **Test difficulty progression:**
   - Start fresh (no dictionary knowledge)
   - Load Text 1: 3 unknown symbols (guessing required)
   - Solve Text 1
   - Load Text 2: 3 known, 2 unknown (easier - can deduce from context)
   - Solve Text 2
   - Load Text 4: 1 known, 3 unknown (hard - spike in difficulty)
   - Observe player struggle (positive challenge)

4. **Test dictionary growth:**
   ```gdscript
   # After each text, count learned symbols
   func count_learned():
       var count = 0
       for symbol in SymbolData.SYMBOLS:
           var entry = SymbolData.get_dictionary_entry(symbol)
           if entry.word != null:
               count += 1
       return count

   # After Text 1: 3
   # After Text 2: 5
   # After Text 3: 7
   # After Text 4: 11
   # After Text 5: 15
   ```

5. **Test payment totals:**
   ```gdscript
   # Start: $100
   # After Text 1: $150 (+$50)
   # After Text 2: $250 (+$100)
   # After Text 3: $350 (+$100)
   # After Text 4: $500 (+$150)
   # After Text 5: $700 (+$200)
   # Total earned: $600
   ```

6. **Pass criteria:** All 5 texts display correctly, validate correctly, update dictionary correctly, pay correctly

---

### Known Simplifications

**Phase 2 shortcuts:**
- Texts loaded manually/sequentially (no customer selection yet - Phase 3)
- No text hints displayed (stored in data but not shown in UI)
- No story context/narrative (just raw symbol text)
- No text titles displayed ("Text 1 - Family History" stored but not shown)
- Fixed difficulty labels (Easy/Medium/Hard) not displayed to player

**Technical debt:**
- Text progression is linear (1 → 2 → 3 → 4 → 5)
  - **Impact:** Phase 3 will randomize via customer queue
- No text unlocking/gating (player can access Text 5 immediately)
  - **Impact:** Acceptable for prototype - tests difficulty scaling
- Compound symbols (◊≈, ⊕⊗◈) not broken into atomic components
  - **Impact:** Fine for 5-text prototype, would need parsing for larger symbol set
- No pattern-matching hints ("⊗◈" appears in multiple symbols - not highlighted)
  - **Impact:** Player must notice patterns manually (intended challenge)

---

## Phase 2 Complete!

**Total Features:** 6 (2.1 through 2.6)
**Total Estimated Time:** 4 hours (45 + 30 + 45 + 60 + 20 + 30 = 230 minutes)
**Core Loop Functional:** ✓ Player can translate texts, see feedback, earn money, build dictionary

**Ready for Phase 3:** Customer queue, accept/refuse mechanics, relationship tracking
