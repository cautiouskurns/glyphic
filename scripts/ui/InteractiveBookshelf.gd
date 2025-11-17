# InteractiveBookshelf.gd
# Feature 3A.1: Interactive Bookshelf
# Displays 4 book spines that pull out when clicked, triggering reference book display
extends Control

# Book spine nodes
@onready var grimoire_spine = $Spines/GrimoireSpine
@onready var translations_spine = $Spines/TranslationsSpine
@onready var context_spine = $Spines/ContextSpine
@onready var notes_spine = $Spines/NotesSpine

# Store original Y positions for each spine
var spine_default_y: Dictionary = {}

# Track which books are currently open
var active_books: Dictionary = {
	"grimoire": false,
	"translations": false,
	"context": false,
	"notes": false
}

# Signal emitted when a spine is clicked
signal book_clicked(book_name: String)

func _ready():
	"""Initialize bookshelf - store positions and connect signals"""
	# Store default positions for all spines
	for spine in [grimoire_spine, translations_spine, context_spine, notes_spine]:
		spine_default_y[spine] = spine.position.y

	# Connect pressed signals for each spine
	grimoire_spine.pressed.connect(_on_spine_clicked.bind("grimoire"))
	translations_spine.pressed.connect(_on_spine_clicked.bind("translations"))
	context_spine.pressed.connect(_on_spine_clicked.bind("context"))
	notes_spine.pressed.connect(_on_spine_clicked.bind("notes"))

	# Connect hover signals for each spine
	grimoire_spine.mouse_entered.connect(_on_spine_hover.bind(grimoire_spine, "grimoire"))
	grimoire_spine.mouse_exited.connect(_on_spine_unhover.bind(grimoire_spine, "grimoire"))

	translations_spine.mouse_entered.connect(_on_spine_hover.bind(translations_spine, "translations"))
	translations_spine.mouse_exited.connect(_on_spine_unhover.bind(translations_spine, "translations"))

	context_spine.mouse_entered.connect(_on_spine_hover.bind(context_spine, "context"))
	context_spine.mouse_exited.connect(_on_spine_unhover.bind(context_spine, "context"))

	notes_spine.mouse_entered.connect(_on_spine_hover.bind(notes_spine, "notes"))
	notes_spine.mouse_exited.connect(_on_spine_unhover.bind(notes_spine, "notes"))

func _on_spine_clicked(book_name: String):
	"""Handle spine click - toggle pull out/push back"""
	var spine = get_spine_node(book_name)

	if active_books[book_name]:
		# Book is open, close it
		push_spine_back(spine)
		active_books[book_name] = false
	else:
		# Book is closed, open it
		pull_spine_out(spine)
		active_books[book_name] = true

	# Notify DiegeticReferenceManager (will be connected in Feature 3A.4)
	book_clicked.emit(book_name)

func _on_spine_hover(spine: Button, book_name: String):
	"""Lift spine on hover (only if not already pulled out)"""
	if active_books[book_name]:
		return  # Already pulled out, don't lift

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(spine, "position:y", spine_default_y[spine] - 5, 0.1)
	tween.tween_property(spine, "modulate", Color(1.15, 1.15, 1.05), 0.1)

func _on_spine_unhover(spine: Button, book_name: String):
	"""Return spine to default on unhover (only if not pulled out)"""
	if active_books[book_name]:
		return  # Already pulled out, stay there

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(spine, "position:y", spine_default_y[spine], 0.1)
	tween.tween_property(spine, "modulate", Color(1, 1, 1), 0.1)

func pull_spine_out(spine: Button):
	"""Animate spine pulling forward (12px down, 3° tilt)"""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(spine, "position:y", spine_default_y[spine] - 12, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(spine, "rotation_degrees", 3, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func push_spine_back(spine: Button):
	"""Animate spine returning to shelf"""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(spine, "position:y", spine_default_y[spine], 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(spine, "rotation_degrees", 0, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func get_spine_node(book_name: String) -> Button:
	"""Get spine node by book name"""
	match book_name:
		"grimoire": return grimoire_spine
		"translations": return translations_spine
		"context": return context_spine
		"notes": return notes_spine
	return null

func get_book_name(spine: Button) -> String:
	"""Get book name by spine node"""
	if spine == grimoire_spine: return "grimoire"
	if spine == translations_spine: return "translations"
	if spine == context_spine: return "context"
	if spine == notes_spine: return "notes"
	return ""

func _input(event):
	"""Handle keyboard shortcuts (1-4 keys)"""
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: _on_spine_clicked("grimoire")
			KEY_2: _on_spine_clicked("translations")
			KEY_3: _on_spine_clicked("context")
			KEY_4: _on_spine_clicked("notes")

# Public API for external control (will be used by DiegeticReferenceManager)

func close_book(book_name: String):
	"""Programmatically close a book (called when reference book is closed)"""
	if active_books.get(book_name, false):
		var spine = get_spine_node(book_name)
		push_spine_back(spine)
		active_books[book_name] = false

func is_book_open(book_name: String) -> bool:
	"""Check if a book is currently open"""
	return active_books.get(book_name, false)
