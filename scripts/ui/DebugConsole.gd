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

	# Test exact match
	var test1 = SymbolData.validate_translation(1, "the old way")
	_print_result(test1, "validate_translation(1, 'the old way') == true")

	# Test case insensitivity
	var test2 = SymbolData.validate_translation(1, "THE OLD WAY")
	_print_result(test2, "validate_translation(1, 'THE OLD WAY') == true (case-insensitive)")

	# Test whitespace trimming
	var test3 = SymbolData.validate_translation(1, "  the old way  ")
	_print_result(test3, "validate_translation(1, '  the old way  ') == true (whitespace trimmed)")

	# Test wrong answer
	var test4 = !SymbolData.validate_translation(1, "wrong answer")
	_print_result(test4, "validate_translation(1, 'wrong answer') == false")

	# Test word order matters
	var test5 = !SymbolData.validate_translation(1, "old the way")
	_print_result(test5, "validate_translation(1, 'old the way') == false (word order matters)")

	# Test Text 5
	var test6 = SymbolData.validate_translation(5, "they are returning soon")
	_print_result(test6, "validate_translation(5, 'they are returning soon') == true")

	# Test invalid ID
	var test7 = !SymbolData.validate_translation(99, "anything")
	_print_result(test7, "validate_translation(99, 'anything') == false (invalid ID)")

func _on_test_dict_init_pressed():
	_print_header("TEST 4: Dictionary Initialization")

	# Reset dictionary to test initialization
	SymbolData.initialize_dictionary()

	_print("Dictionary size: %d" % SymbolData.dictionary.size())
	_print_result(SymbolData.dictionary.size() == 20, "Dictionary has 20 entries")

	# Check first symbol
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

	# Check unlearned symbol
	var god = SymbolData.dictionary["⊞"]
	_print("\nSymbol '⊞' (not in Text 1):")
	_print("  word: %s" % str(god.word))
	_print_result(god.word == null, "⊞ still unknown (not in Text 1)")

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
