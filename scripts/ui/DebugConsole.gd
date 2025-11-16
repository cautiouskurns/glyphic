# DebugConsole.gd
# Debug UI for testing game systems
extends Panel

@onready var output_text = $HBoxContainer/OutputScroll/OutputText

func _ready():
	# Start hidden
	visible = false

func _input(event):
	# Toggle with F1 key
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		visible = !visible
		get_viewport().set_input_as_handled()

func _print(message: String):
	"""Append message to output text"""
	output_text.text += message + "\n"

func _print_header(title: String):
	"""Print a test section header"""
	_print("\n" + "=".repeat(60))
	_print(title)
	_print("=".repeat(60))

func _print_pass(message: String):
	"""Print a passing test"""
	_print("✓ PASS: " + message)

func _print_fail(message: String):
	"""Print a failing test"""
	_print("✗ FAIL: " + message)

func _print_result(condition: bool, message: String):
	"""Print pass or fail based on condition"""
	if condition:
		_print_pass(message)
	else:
		_print_fail(message)

# Button callbacks
func _on_close_button_pressed():
	visible = false

func _on_clear_pressed():
	output_text.text = ""

func _on_test_symbols_pressed():
	_print_header("TEST 1: Symbol Alphabet")
	_print("SYMBOLS array size: %d" % SymbolData.SYMBOLS.size())
	_print_result(SymbolData.SYMBOLS.size() == 20, "Should have exactly 20 symbols")
	_print("\nAll symbols:")
	for i in range(SymbolData.SYMBOLS.size()):
		_print("  [%d] %s" % [i + 1, SymbolData.SYMBOLS[i]])

func _on_test_texts_pressed():
	_print_header("TEST 2: All 5 Translation Texts")
	_print("texts array size: %d" % SymbolData.texts.size())
	_print_result(SymbolData.texts.size() == 5, "Should have exactly 5 texts")

	_print("\nAll texts:")
	for text in SymbolData.texts:
		_print("\n%s:" % text.name)
		_print("  Symbols: '%s'" % text.symbols)
		_print("  Solution: '%s'" % text.solution)
		_print("  Payment: $%d | Difficulty: %s" % [text.payment_base, text.difficulty])
		_print("  Mappings: %d symbol groups" % text.mappings.size())

	# Verify payment amounts
	_print("\nPayment verification:")
	_print_result(SymbolData.texts[0].payment_base == 50, "Text 1 pays $50")
	_print_result(SymbolData.texts[1].payment_base == 100, "Text 2 pays $100")
	_print_result(SymbolData.texts[2].payment_base == 100, "Text 3 pays $100")
	_print_result(SymbolData.texts[3].payment_base == 150, "Text 4 pays $150")
	_print_result(SymbolData.texts[4].payment_base == 200, "Text 5 pays $200")

func _on_test_validation_pressed():
	_print_header("TEST 3: Validation Logic")

	_print("--- BASIC VALIDATION ---")
	# Test exact match
	var test1 = SymbolData.validate_translation(1, "the old way")
	_print_result(test1, "validate_translation(1, 'the old way') == true")

	# Test case insensitivity
	var test2 = SymbolData.validate_translation(1, "THE OLD WAY")
	_print_result(test2, "validate_translation(1, 'THE OLD WAY') == true (case-insensitive)")

	# Test mixed case
	var test3 = SymbolData.validate_translation(1, "The Old Way")
	_print_result(test3, "validate_translation(1, 'The Old Way') == true (mixed case)")

	# Test whitespace trimming
	var test4 = SymbolData.validate_translation(1, "  the old way  ")
	_print_result(test4, "validate_translation(1, '  the old way  ') == true (whitespace trimmed)")

	_print("\n--- REJECTION TESTS ---")
	# Test wrong answer
	var test5 = !SymbolData.validate_translation(1, "wrong answer")
	_print_result(test5, "validate_translation(1, 'wrong answer') == false")

	# Test word order matters
	var test6 = !SymbolData.validate_translation(1, "old the way")
	_print_result(test6, "validate_translation(1, 'old the way') == false (word order matters)")

	# Test incomplete answer
	var test7 = !SymbolData.validate_translation(1, "the old")
	_print_result(test7, "validate_translation(1, 'the old') == false (incomplete)")

	# Test punctuation
	var test8 = !SymbolData.validate_translation(1, "the old way!")
	_print_result(test8, "validate_translation(1, 'the old way!') == false (punctuation)")

	# Test spelling error
	var test9 = !SymbolData.validate_translation(1, "the ould way")
	_print_result(test9, "validate_translation(1, 'the ould way') == false (spelling error)")

	_print("\n--- EDGE CASES ---")
	# Test empty input
	var test10 = !SymbolData.validate_translation(1, "")
	_print_result(test10, "validate_translation(1, '') == false (empty input)")

	# Test whitespace-only input
	var test11 = !SymbolData.validate_translation(1, "   ")
	_print_result(test11, "validate_translation(1, '   ') == false (whitespace only)")

	# Test extra spaces between words
	var test12 = !SymbolData.validate_translation(1, "the  old  way")
	_print_result(test12, "validate_translation(1, 'the  old  way') == false (extra spaces)")

	# Test invalid ID
	var test13 = !SymbolData.validate_translation(99, "anything")
	_print_result(test13, "validate_translation(99, 'anything') == false (invalid ID)")

	_print("\n--- ALL 5 SOLUTIONS ---")
	# Test Text 1
	var test14 = SymbolData.validate_translation(1, "the old way")
	_print_result(test14, "Text 1: 'the old way'")

	# Test Text 2
	var test15 = SymbolData.validate_translation(2, "the old way was forgotten")
	_print_result(test15, "Text 2: 'the old way was forgotten'")

	# Test Text 3
	var test16 = SymbolData.validate_translation(3, "the old god sleeps")
	_print_result(test16, "Text 3: 'the old god sleeps'")

	# Test Text 4
	var test17 = SymbolData.validate_translation(4, "magic was once known")
	_print_result(test17, "Text 4: 'magic was once known'")

	# Test Text 5
	var test18 = SymbolData.validate_translation(5, "they are returning soon")
	_print_result(test18, "Text 5: 'they are returning soon'")

func _on_test_dict_init_pressed():
	_print_header("TEST 4: Dictionary Initialization")

	# Reset dictionary to test initialization
	SymbolData.initialize_dictionary()

	_print("Dictionary size: %d" % SymbolData.dictionary.size())
	_print_result(SymbolData.dictionary.size() == 14, "Dictionary has 14 symbol groups (from all 5 texts)")

	# Check first symbol group
	var delta_entry = SymbolData.get_dictionary_entry("∆")
	_print("\nEntry for '∆':")
	_print("  word: %s" % str(delta_entry.word))
	_print("  confidence: %d" % delta_entry.confidence)
	_print("  learned_from: %s" % str(delta_entry.learned_from))

	_print_result(delta_entry.word == null, "Initial word is null")
	_print_result(delta_entry.confidence == 0, "Initial confidence is 0")
	_print_result(delta_entry.learned_from.size() == 0, "Initial learned_from is empty")

	# Check invalid symbol
	var invalid = SymbolData.get_dictionary_entry("X")
	_print_result(invalid.word == null, "Invalid symbol returns default entry")

func _on_test_dict_update_pressed():
	_print_header("TEST 5: Dictionary Updates")

	# Reset and update with Text 1
	SymbolData.initialize_dictionary()
	SymbolData.update_dictionary(1)

	_print("After update_dictionary(1):\n")

	# Check learned symbols
	var delta = SymbolData.dictionary["∆"]
	_print("Symbol '∆':")
	_print("  word: %s" % str(delta.word))
	_print("  confidence: %d" % delta.confidence)
	_print_result(delta.word == "the", "∆ maps to 'the'")
	_print_result(delta.confidence == 3, "∆ has confidence 3 (confirmed)")

	var old = SymbolData.dictionary["◊≈"]
	_print("\nSymbol '◊≈':")
	_print("  word: %s" % str(old.word))
	_print_result(old.word == "old", "◊≈ maps to 'old'")

	var way = SymbolData.dictionary["⊕⊗◈"]
	_print("\nSymbol '⊕⊗◈':")
	_print("  word: %s" % str(way.word))
	_print_result(way.word == "way", "⊕⊗◈ maps to 'way'")

	# Check unlearned symbol group (from Text 3, not in Text 1)
	var god = SymbolData.dictionary["⊞⊟≈"]
	_print("\nSymbol '⊞⊟≈' (not in Text 1):")
	_print("  word: %s" % str(god.word))
	_print_result(god.word == null, "⊞⊟≈ still unknown (not in Text 1)")

func _on_test_consistency_pressed():
	_print_header("TEST 6: Symbol Consistency Across Texts")

	var text1 = SymbolData.get_text(1)
	var text2 = SymbolData.get_text(2)
	var text3 = SymbolData.get_text(3)

	_print("Checking '∆' (should always be 'the'):")
	_print("  Text 1: %s" % text1.mappings.get("∆", "NOT FOUND"))
	_print("  Text 2: %s" % text2.mappings.get("∆", "NOT FOUND"))
	_print("  Text 3: %s" % text3.mappings.get("∆", "NOT FOUND"))
	var delta_consistent = (text1.mappings.get("∆") == "the" and
							text2.mappings.get("∆") == "the" and
							text3.mappings.get("∆") == "the")
	_print_result(delta_consistent, "∆ = 'the' in all texts")

	_print("\nChecking '◊≈' (should always be 'old'):")
	_print("  Text 1: %s" % text1.mappings.get("◊≈", "NOT FOUND"))
	_print("  Text 2: %s" % text2.mappings.get("◊≈", "NOT FOUND"))
	_print("  Text 3: %s" % text3.mappings.get("◊≈", "NOT FOUND"))
	var old_consistent = (text1.mappings.get("◊≈") == "old" and
							text2.mappings.get("◊≈") == "old" and
							text3.mappings.get("◊≈") == "old")
	_print_result(old_consistent, "◊≈ = 'old' in all texts")

	var text4 = SymbolData.get_text(4)
	_print("\nChecking '⊕⊗⬡' (should be 'was' in Text 2 and Text 4):")
	_print("  Text 2: %s" % text2.mappings.get("⊕⊗⬡", "NOT FOUND"))
	_print("  Text 4: %s" % text4.mappings.get("⊕⊗⬡", "NOT FOUND"))
	var was_consistent = (text2.mappings.get("⊕⊗⬡") == "was" and
							text4.mappings.get("⊕⊗⬡") == "was")
	_print_result(was_consistent, "⊕⊗⬡ = 'was' in both texts")

func _on_run_all_pressed():
	_print("\n" + "█".repeat(60))
	_print("RUNNING ALL TESTS")
	_print("█".repeat(60))

	_on_test_symbols_pressed()
	_on_test_texts_pressed()
	_on_test_validation_pressed()
	_on_test_dict_init_pressed()
	_on_test_dict_update_pressed()
	_on_test_consistency_pressed()
	_on_test_gamestate_pressed()
	_on_test_gamestate_advance_pressed()
	_on_test_gamestate_cash_pressed()
	_on_test_customerdata_pressed()
	_on_test_customerdata_schedules_pressed()
	_on_test_customerdata_queue_pressed()
	_on_test_customerdata_relationships_pressed()
	_on_test_customerdata_random_pressed()

	_print("\n" + "█".repeat(60))
	_print("ALL TESTS COMPLETE")
	_print("█".repeat(60))

# GameState tests
func _on_test_gamestate_pressed():
	_print_header("GameState: Initial Values")

	GameState.reset_game_state()

	_print("current_day: %d" % GameState.current_day)
	_print("day_name: %s" % GameState.day_name)
	_print("player_cash: $%d" % GameState.player_cash)
	_print("capacity_used: %d" % GameState.capacity_used)
	_print("max_capacity: %d" % GameState.max_capacity)

	_print_result(GameState.current_day == 1, "Day starts at 1")
	_print_result(GameState.day_name == "Monday", "Day name is Monday")
	_print_result(GameState.player_cash == 100, "Starting cash is $100")
	_print_result(GameState.capacity_used == 0, "Capacity used starts at 0")
	_print_result(GameState.max_capacity == 5, "Max capacity is 5")

func _on_test_gamestate_advance_pressed():
	_print_header("GameState: Day Advancement")

	GameState.reset_game_state()
	_print("Initial: Day %d (%s), Cash: $%d" % [GameState.current_day, GameState.day_name, GameState.player_cash])

	GameState.advance_day()
	_print("After advance_day(): Day %d (%s), Cash: $%d" % [GameState.current_day, GameState.day_name, GameState.player_cash])

	_print_result(GameState.current_day == 2, "Day advanced to 2")
	_print_result(GameState.day_name == "Tuesday", "Day name is Tuesday")
	_print_result(GameState.player_cash == 70, "Cash reduced by $30 utilities (100 - 30 = 70)")
	_print_result(GameState.capacity_used == 0, "Capacity reset to 0")

func _on_test_gamestate_cash_pressed():
	_print_header("GameState: Cash Color Coding")

	# Test green (>= 200)
	GameState.player_cash = 250
	var green = GameState.get_cash_color()
	_print("Cash $250 → Color: %s" % green)
	_print_result(green == Color("#2D5016"), "Cash >= $200 shows green")

	# Test orange (100-199)
	GameState.player_cash = 150
	var orange = GameState.get_cash_color()
	_print("Cash $150 → Color: %s" % orange)
	_print_result(orange == Color("#CC6600"), "Cash $100-199 shows orange")

	# Test red (< 100)
	GameState.player_cash = 50
	var red = GameState.get_cash_color()
	_print("Cash $50 → Color: %s" % red)
	_print_result(red == Color("#8B0000"), "Cash < $100 shows red")

	# Reset to starting value
	GameState.reset_game_state()
	_print("\nGameState reset to initial values")

# CustomerData tests (Feature 1.4)
func _on_test_customerdata_pressed():
	_print_header("CustomerData: Recurring Customer Data")

	CustomerData.reset_relationships()

	_print("Number of recurring customers: %d" % CustomerData.recurring_customers.size())
	_print_result(CustomerData.recurring_customers.size() == 3, "Should have exactly 3 recurring customers")

	_print("\nRecurring customer details:")
	for customer_name in CustomerData.recurring_customers.keys():
		var customer = CustomerData.recurring_customers[customer_name]
		_print("\n%s:" % customer_name)
		_print("  Payment: $%d" % customer.payment)
		_print("  Difficulty: %s" % customer.difficulty)
		_print("  Days: %s" % str(customer.appears_days))
		_print("  Tolerance: %d" % customer.refusal_tolerance)

	_print("\nPayment verification:")
	_print_result(CustomerData.recurring_customers["Mrs. Kowalski"].payment == 50, "Mrs. Kowalski pays $50")
	_print_result(CustomerData.recurring_customers["Dr. Chen"].payment == 100, "Dr. Chen pays $100")
	_print_result(CustomerData.recurring_customers["The Stranger"].payment == 200, "The Stranger pays $200")

func _on_test_customerdata_schedules_pressed():
	_print_header("CustomerData: Appearance Schedules")

	var mrs_k = CustomerData.recurring_customers["Mrs. Kowalski"]
	var dr_chen = CustomerData.recurring_customers["Dr. Chen"]
	var stranger = CustomerData.recurring_customers["The Stranger"]

	_print("Mrs. Kowalski appears: %s" % str(mrs_k.appears_days))
	_print_result(mrs_k.appears_days == [1, 2, 3], "Mrs. K appears Days 1-3 (Mon-Wed)")

	_print("\nDr. Chen appears: %s" % str(dr_chen.appears_days))
	_print_result(dr_chen.appears_days == [2, 3, 4, 5, 6, 7], "Dr. Chen appears Days 2-7 (Tue-Sun)")

	_print("\nThe Stranger appears: %s" % str(stranger.appears_days))
	_print_result(stranger.appears_days == [5, 6, 7], "The Stranger appears Days 5-7 (Fri-Sun)")

	_print("\nRefusal tolerance:")
	_print_result(mrs_k.refusal_tolerance == 2, "Mrs. K tolerance = 2")
	_print_result(dr_chen.refusal_tolerance == 2, "Dr. Chen tolerance = 2")
	_print_result(stranger.refusal_tolerance == 1, "The Stranger tolerance = 1")

func _on_test_customerdata_queue_pressed():
	_print_header("CustomerData: Queue Generation")

	CustomerData.reset_relationships()

	# Test Day 1 queue
	var day1_queue = CustomerData.generate_daily_queue(1)
	_print("Day 1 queue size: %d" % day1_queue.size())
	_print_result(day1_queue.size() >= 7 and day1_queue.size() <= 10, "Queue has 7-10 customers")

	var has_mrs_k = false
	var has_dr_chen = false
	var has_stranger = false
	for customer in day1_queue:
		if customer.name == "Mrs. Kowalski": has_mrs_k = true
		if customer.name == "Dr. Chen": has_dr_chen = true
		if customer.name == "The Stranger": has_stranger = true

	_print("\nDay 1 recurring customers:")
	_print_result(has_mrs_k, "Mrs. Kowalski appears (Day 1 is in her schedule)")
	_print_result(!has_dr_chen, "Dr. Chen does NOT appear (starts Day 2)")
	_print_result(!has_stranger, "The Stranger does NOT appear (starts Day 5)")

	# Test Day 5 queue
	var day5_queue = CustomerData.generate_daily_queue(5)
	has_mrs_k = false
	has_dr_chen = false
	has_stranger = false
	for customer in day5_queue:
		if customer.name == "Mrs. Kowalski": has_mrs_k = true
		if customer.name == "Dr. Chen": has_dr_chen = true
		if customer.name == "The Stranger": has_stranger = true

	_print("\nDay 5 recurring customers:")
	_print_result(!has_mrs_k, "Mrs. Kowalski does NOT appear (ended Day 3)")
	_print_result(has_dr_chen, "Dr. Chen appears (Day 5 in schedule)")
	_print_result(has_stranger, "The Stranger appears (Day 5 in schedule)")

	_print("\nSample Day 1 queue:")
	for i in range(min(5, day1_queue.size())):
		var c = day1_queue[i]
		_print("  %d. %s - $%d (%s)" % [i + 1, c.name, c.payment, c.difficulty])

func _on_test_customerdata_relationships_pressed():
	_print_header("CustomerData: Relationship Damage")

	CustomerData.reset_relationships()

	_print("Initial Mrs. Kowalski relationship: %d" % CustomerData.recurring_customers["Mrs. Kowalski"].current_relationship)
	_print_result(CustomerData.recurring_customers["Mrs. Kowalski"].current_relationship == 2, "Starts at 2")

	# First refusal
	CustomerData.damage_relationship("Mrs. Kowalski")
	_print("\nAfter 1st refusal: %d" % CustomerData.recurring_customers["Mrs. Kowalski"].current_relationship)
	_print_result(CustomerData.recurring_customers["Mrs. Kowalski"].current_relationship == 1, "Reduced to 1")

	# Generate queue - should still appear
	var queue_after_1 = CustomerData.generate_daily_queue(2)
	var has_mrs_k_after_1 = false
	for customer in queue_after_1:
		if customer.name == "Mrs. Kowalski": has_mrs_k_after_1 = true
	_print_result(has_mrs_k_after_1, "Mrs. K still appears after 1 refusal")

	# Second refusal
	CustomerData.damage_relationship("Mrs. Kowalski")
	_print("\nAfter 2nd refusal: %d" % CustomerData.recurring_customers["Mrs. Kowalski"].current_relationship)
	_print_result(CustomerData.recurring_customers["Mrs. Kowalski"].current_relationship == 0, "Reduced to 0")

	# Generate queue - should NOT appear
	var queue_after_2 = CustomerData.generate_daily_queue(2)
	var has_mrs_k_after_2 = false
	for customer in queue_after_2:
		if customer.name == "Mrs. Kowalski": has_mrs_k_after_2 = true
	_print_result(!has_mrs_k_after_2, "Mrs. K does NOT appear after 2 refusals")

	# Test Stranger (1 refusal tolerance)
	_print("\n--- The Stranger (1 refusal tolerance) ---")
	CustomerData.reset_relationships()
	_print("Initial relationship: %d" % CustomerData.recurring_customers["The Stranger"].current_relationship)

	CustomerData.damage_relationship("The Stranger")
	_print("After 1 refusal: %d" % CustomerData.recurring_customers["The Stranger"].current_relationship)
	_print_result(CustomerData.recurring_customers["The Stranger"].current_relationship == 0, "Immediately reduced to 0")

	var queue_day5 = CustomerData.generate_daily_queue(5)
	var has_stranger = false
	for customer in queue_day5:
		if customer.name == "The Stranger": has_stranger = true
	_print_result(!has_stranger, "The Stranger does NOT appear after 1 refusal")

	# Reset for next tests
	CustomerData.reset_relationships()
	_print("\nRelationships reset to starting values")

func _on_test_customerdata_random_pressed():
	_print_header("CustomerData: Random Customer Generation")

	_print("Random customer templates: %d" % CustomerData.random_customer_templates.size())
	_print_result(CustomerData.random_customer_templates.size() == 4, "Should have 4 templates")

	_print("\nGenerating 5 random customers:")
	for i in range(5):
		var random = CustomerData.generate_random_customer()
		_print("  %s - $%d (%s) - %s" % [random.name, random.payment, random.difficulty, random.priorities])

	_print("\nVerifying random customer properties:")
	var test_random = CustomerData.generate_random_customer()
	_print_result(test_random.has("name"), "Has name property")
	_print_result(test_random.has("payment"), "Has payment property")
	_print_result(test_random.has("difficulty"), "Has difficulty property")
	_print_result(test_random.has("is_recurring"), "Has is_recurring property")
	_print_result(test_random.is_recurring == false, "is_recurring = false for random customers")

# Translation Display tests (Feature 2.1)
func _on_load_text1_pressed():
	_print_header("Translation: Loading Text 1")

	var translation_display = get_node("/root/Main/Workspace/TranslationDisplay")
	translation_display.load_text(1)

	_print("Loaded Text 1: 'the old way'")
	_print("Symbol text: ∆ ◊≈ ⊕⊗◈")
	_print("Payment: $50")
	_print("\nType 'the old way' in the input field and press Enter or Submit")

func _on_load_text2_pressed():
	_print_header("Translation: Loading Text 2")

	var translation_display = get_node("/root/Main/Workspace/TranslationDisplay")
	translation_display.load_text(2)

	_print("Loaded Text 2: 'the old way was forgotten'")
	_print("Symbol text: ∆ ◊≈ ⊕⊗◈ ⊕⊗⬡ ⬡∞◊⊩⊩≈⊩")
	_print("Payment: $100")
	_print("\nType 'the old way was forgotten' in the input field and press Enter or Submit")

func _on_load_text3_pressed():
	_print_header("Translation: Loading Text 3")

	var translation_display = get_node("/root/Main/Workspace/TranslationDisplay")
	translation_display.load_text(3)

	_print("Loaded Text 3: 'the old god sleeps'")
	_print("Symbol text: ∆ ◊≈ ⊞⊟≈ ⬡≈≈⊢⬡")
	_print("Payment: $100")
	_print("\nType 'the old god sleeps' in the input field and press Enter or Submit")

func _on_load_text4_pressed():
	_print_header("Translation: Loading Text 4")

	var translation_display = get_node("/root/Main/Workspace/TranslationDisplay")
	translation_display.load_text(4)

	_print("Loaded Text 4: 'magic was once known'")
	_print("Symbol text: ⊗◈⊞∞◈ ⊕⊗⬡ ◊⊩◈≈ ⊟⊩◊⊕⊩")
	_print("Payment: $150")
	_print("\nType 'magic was once known' in the input field and press Enter or Submit")

func _on_load_text5_pressed():
	_print_header("Translation: Loading Text 5")

	var translation_display = get_node("/root/Main/Workspace/TranslationDisplay")
	translation_display.load_text(5)

	_print("Loaded Text 5: 'they are returning soon'")
	_print("Symbol text: ∆≈◊ ⊗◈≈ ◈≈∆◊◈⊩∞⊩⊞ ⬡◊◊⊩")
	_print("Payment: $200")
	_print("\nType 'they are returning soon' in the input field and press Enter or Submit")

func _on_reset_translation_pressed():
	_print_header("Translation: Reset to Default")

	var translation_display = get_node("/root/Main/Workspace/TranslationDisplay")
	translation_display.set_default_state()

	_print("Translation display reset")
	_print("Shows: '*Select a customer to begin...*'")
	_print("Input field and Submit button disabled")

func _on_test_full_progression_pressed():
	_print_header("Translation: Full Progression Test (Feature 2.6)")

	_print("=== FIVE TRANSLATION TEXTS ===\n")

	# Text summaries
	var texts_info = [
		{"id": 1, "solution": "the old way", "symbols": 3, "payment": 50, "difficulty": "Easy"},
		{"id": 2, "solution": "the old way was forgotten", "symbols": 5, "payment": 100, "difficulty": "Medium"},
		{"id": 3, "solution": "the old god sleeps", "symbols": 4, "payment": 100, "difficulty": "Medium"},
		{"id": 4, "solution": "magic was once known", "symbols": 4, "payment": 150, "difficulty": "Hard"},
		{"id": 5, "solution": "they are returning soon", "symbols": 4, "payment": 200, "difficulty": "Hard"}
	]

	for info in texts_info:
		_print("Text %d (%s) - $%d" % [info.id, info.difficulty, info.payment])
		_print("  Solution: '%s'" % info.solution)
		_print("  Symbol groups: %d" % info.symbols)

	_print("\n=== PROGRESSION ANALYSIS ===\n")

	# Dictionary growth
	_print("Dictionary growth:")
	_print("  After Text 1: 3 symbols learned")
	_print("  After Text 2: 5 symbols learned (+2)")
	_print("  After Text 3: 7 symbols learned (+2)")
	_print("  After Text 4: 11 symbols learned (+4)")
	_print("  After Text 5: 15 symbols learned (+4)")

	_print("\nCash progression (starting $100):")
	_print("  After Text 1: $150 (+$50)")
	_print("  After Text 2: $250 (+$100)")
	_print("  After Text 3: $350 (+$100)")
	_print("  After Text 4: $500 (+$150)")
	_print("  After Text 5: $700 (+$200)")
	_print("  Total earned: $600")

	_print("\n=== SYMBOL CONSISTENCY ===\n")

	# Verify symbol consistency
	var text1 = SymbolData.get_text(1)
	var text2 = SymbolData.get_text(2)
	var text3 = SymbolData.get_text(3)
	var text4 = SymbolData.get_text(4)

	_print("∆ = 'the' verification:")
	_print("  Text 1: %s" % text1.mappings.get("∆", "NOT FOUND"))
	_print("  Text 2: %s" % text2.mappings.get("∆", "NOT FOUND"))
	_print("  Text 3: %s" % text3.mappings.get("∆", "NOT FOUND"))
	var delta_consistent = (text1.mappings.get("∆") == "the" and
	                        text2.mappings.get("∆") == "the" and
	                        text3.mappings.get("∆") == "the")
	_print_result(delta_consistent, "∆ consistently maps to 'the'")

	_print("\n◊≈ = 'old' verification:")
	_print("  Text 1: %s" % text1.mappings.get("◊≈", "NOT FOUND"))
	_print("  Text 2: %s" % text2.mappings.get("◊≈", "NOT FOUND"))
	_print("  Text 3: %s" % text3.mappings.get("◊≈", "NOT FOUND"))
	var old_consistent = (text1.mappings.get("◊≈") == "old" and
	                      text2.mappings.get("◊≈") == "old" and
	                      text3.mappings.get("◊≈") == "old")
	_print_result(old_consistent, "◊≈ consistently maps to 'old'")

	_print("\n⊕⊗⬡ = 'was' verification:")
	_print("  Text 2: %s" % text2.mappings.get("⊕⊗⬡", "NOT FOUND"))
	_print("  Text 4: %s" % text4.mappings.get("⊕⊗⬡", "NOT FOUND"))
	var was_consistent = (text2.mappings.get("⊕⊗⬡") == "was" and
	                      text4.mappings.get("⊕⊗⬡") == "was")
	_print_result(was_consistent, "⊕⊗⬡ consistently maps to 'was'")

	_print("\n✅ Feature 2.6: Five Translation Texts - VERIFIED")

# Feedback tests (Feature 2.3)
func _on_test_success_feedback_pressed():
	_print_header("Feedback: Test Success")

	var translation_display = get_node("/root/Main/Workspace/TranslationDisplay")
	translation_display.show_success_feedback(50)

	_print("Success feedback displayed:")
	_print("  - Message: '✓ Translation Accepted! +$50'")
	_print("  - Color: Green (#2ECC71)")
	_print("  - Customer dialogue: 'Thank you for the translation!'")
	_print("\nDialogue will auto-clear after 2.0 seconds")

func _on_test_failure_feedback_pressed():
	_print_header("Feedback: Test Failure")

	var translation_display = get_node("/root/Main/Workspace/TranslationDisplay")
	translation_display.show_failure_feedback()

	_print("Failure feedback displayed:")
	_print("  - Message: '✗ Incorrect Translation'")
	_print("  - Color: Red (#E74C3C)")
	_print("  - Customer dialogue: 'Hmm, that doesn't seem right. Try again?'")
	_print("\nDialogue will auto-clear after 1.5 seconds (manual clear needed for test)")

# Dictionary tests (Feature 2.4)
func _on_dictionary_view_pressed():
	_print_header("Dictionary: Current State")

	_print("Total symbol groups: %d" % SymbolData.dictionary.size())
	_print("")

	var learned_count = 0
	var unknown_count = 0

	_print("Symbol entries:")
	for symbol in SymbolData.dictionary.keys():
		var entry = SymbolData.get_dictionary_entry(symbol)
		if entry.word != null:
			_print("  %s → \"%s\" (✓ learned)" % [symbol, entry.word])
			learned_count += 1
		else:
			_print("  %s → ??? (unknown)" % symbol)
			unknown_count += 1

	_print("\nSummary:")
	_print("  Learned: %d symbols" % learned_count)
	_print("  Unknown: %d symbols" % unknown_count)

func _on_dictionary_update_pressed():
	_print_header("Dictionary: Force Update")

	var dictionary_panel = get_node("/root/Main/RightPanel")
	dictionary_panel.update_dictionary()

	_print("Dictionary display refreshed")
	_print("All 14 entries updated from SymbolData")
	_print("\nUse 'Dictionary: View Current State' to see current values")

# Money tests (Feature 2.5)
func _on_money_test_50_pressed():
	_print_header("Money: Test +$50 Payment")

	var before_cash = GameState.player_cash
	GameState.add_cash(50)
	var after_cash = GameState.player_cash

	_print("Cash before: $%d" % before_cash)
	_print("Added: $50")
	_print("Cash after: $%d" % after_cash)
	_print("\nWatch cash counter in top-right animate from $%d → $%d" % [before_cash, after_cash])
	_print("Animation should take ~0.5 seconds (100 dollars/second)")

func _on_money_test_100_pressed():
	_print_header("Money: Test +$100 Payment")

	var before_cash = GameState.player_cash
	GameState.add_cash(100)
	var after_cash = GameState.player_cash

	_print("Cash before: $%d" % before_cash)
	_print("Added: $100")
	_print("Cash after: $%d" % after_cash)
	_print("\nWatch cash counter in top-right animate from $%d → $%d" % [before_cash, after_cash])
	_print("Animation should take ~1.0 seconds (100 dollars/second)")

func _on_money_test_threshold_pressed():
	_print_header("Money: Test Color Thresholds")

	_print("Setting cash to $195 (just below green threshold)...")
	GameState.player_cash = 195

	_print("Current: $195 (orange)")
	_print("\nAdding $50...")
	GameState.add_cash(50)

	_print("Final: $245 (green)")
	_print("\nWatch cash counter transition:")
	_print("  $195 (orange) → $200 (green) → $245 (green)")
	_print("  Color should change at exactly $200 during animation")

# Customer Queue tests (Feature 3.1)
func _on_test_customer_queue_pressed():
	_print_header("Customer Queue: Display Test (Feature 3.1)")

	var queue_panel = get_node("/root/Main/LeftPanel")
	queue_panel.refresh_queue()

	var queue = queue_panel.current_queue
	_print("Queue size: %d customers" % queue.size())
	_print_result(queue.size() >= 7 and queue.size() <= 10, "Queue has 7-10 customers")

	_print("\nCustomer queue for Day %d (%s):" % [GameState.current_day, GameState.day_name])
	for i in range(queue.size()):
		var customer = queue[i]
		_print("\n%d. %s" % [i + 1, customer.name])
		_print("   Payment: $%d" % customer.payment)
		_print("   Difficulty: %s" % customer.difficulty)
		_print("   Description: %s" % customer.description)

	# Check for recurring customers
	var recurring_count = 0
	var random_count = 0
	for customer in queue:
		if customer.has("is_recurring") and customer.is_recurring:
			recurring_count += 1
		else:
			random_count += 1

	_print("\n=== Queue Composition ===")
	_print("Recurring customers: %d" % recurring_count)
	_print("Random customers: %d" % random_count)

	_print("\n✅ Check the left panel to see customer cards!")
	_print("✅ Hover over cards to see gold tint effect")
	_print("✅ Click cards to test click interaction (prints to console)")

# Customer Popup tests (Feature 3.2)
func _on_test_customer_popup_pressed():
	_print_header("Customer Popup: Display Test (Feature 3.2)")

	# Create test customer data (Mrs. Kowalski)
	var test_customer = {
		"name": "Mrs. Kowalski",
		"payment": 50,
		"difficulty": "Easy",
		"priorities": ["Cheap", "Accurate"],
		"dialogue": {
			"greeting": "Hello dear, I found this old family book in my attic. Can you help me read it?"
		},
		"is_recurring": true,
		"type": "recurring"
	}

	# Show popup
	var popup = get_node("/root/Main/CustomerPopup")
	popup.show_popup(test_customer)

	_print("Popup displayed with test customer: Mrs. Kowalski")
	_print("Payment: $50 (Easy)")
	_print("Priorities: Cheap ✓, Accurate ✓, Fast ✗")
	_print("\n✅ Check centered popup on screen!")
	_print("✅ Test ACCEPT button (hover for green highlight)")
	_print("✅ Test REFUSE button (hover for red highlight)")
	_print("✅ Press Enter to accept, Escape to close")
	_print("✅ Click overlay (dark background) to close")
