# BookResource.gd
# Resource defining a unique book with visual properties, secrets, and story context
class_name BookResource
extends Resource

# Basic Info
@export var book_id: String = ""
@export var title: String = "Ancient Tome"
@export var author: String = ""  # Author name displayed on cover
@export_enum("Easy", "Medium", "Hard") var difficulty: String = "Easy"
@export var text_id: int = 1

# Visual Properties
@export_group("Appearance")
@export var cover_color: Color = Color("#F4E8D8")  # Base cover color
@export_enum("Leather", "Cloth", "Paper", "Wood") var cover_material: String = "Leather"
@export var cover_pattern: String = "~"  # Decorative pattern on cover
@export var spine_text: String = ""  # Text visible on spine
@export_range(0, 100) var wear_level: int = 30  # 0=pristine, 100=falling apart
@export var has_embossing: bool = false
@export var embossing_symbol: String = "⊗"  # Symbol embossed on cover

# Physical Properties
@export_group("Physical")
@export_enum("Small", "Medium", "Large", "Tome") var size: String = "Medium"
@export var thickness: int = 200  # Number of pages (visual only)
@export_range(0, 100) var binding_quality: int = 50  # 0=loose pages, 100=perfect binding

# Hidden Details (discoverable through examination tools)
@export_group("Secrets")
@export var uv_hidden_text: String = ""  # Revealed by UV Light upgrade
@export var faded_inscription: String = ""  # Revealed by Better Lamp upgrade
@export var marginalia: Array[String] = []  # Handwritten notes in margins
@export var bookmark_page: int = 0  # Page number of bookmark (0 = none)
@export var pressed_flower: bool = false  # Dried flower pressed between pages
@export var coffee_stain: bool = false  # Coffee/tea stain on cover
@export var water_damage: bool = false  # Water damage visible on edges

# Provenance & Context (story clues)
@export_group("History")
@export var previous_owner: String = ""  # Name of previous owner
@export var publication_year: int = 0  # Year published (0 = unknown/ancient)
@export var library_stamp: String = ""  # e.g., "FORBIDDEN SECTION", "PRIVATE COLLECTION"
@export var acquisition_note: String = ""  # Where/how customer acquired it

# Story & Flavor
@export_group("Narrative")
@export_multiline var examination_flavor_text: String = ""  # Description when examining
@export_range(0, 5) var story_relevance: int = 0  # 0=random book, 5=critical to main story

func get_visual_description() -> String:
	"""Generate a text description of the book's appearance"""
	var desc = "A %s %s book" % [size.to_lower(), cover_material.to_lower()]

	if wear_level > 70:
		desc += ", heavily worn and aged"
	elif wear_level > 40:
		desc += ", showing signs of age"
	else:
		desc += " in good condition"

	if has_embossing:
		desc += ". An embossed symbol (%s) adorns the cover" % embossing_symbol

	if coffee_stain:
		desc += ". A coffee stain marks one corner"

	if water_damage:
		desc += ". Water damage is visible along the edges"

	return desc + "."

func get_all_secrets() -> Array[String]:
	"""Return array of all discoverable secrets"""
	var secrets: Array[String] = []

	if uv_hidden_text != "":
		secrets.append("UV marking: " + uv_hidden_text)

	if faded_inscription != "":
		secrets.append("Faded inscription: " + faded_inscription)

	if previous_owner != "":
		secrets.append("Previous owner: " + previous_owner)

	if library_stamp != "":
		secrets.append("Library stamp: " + library_stamp)

	if bookmark_page > 0:
		secrets.append("Bookmark at page %d" % bookmark_page)

	if pressed_flower:
		secrets.append("Pressed flower between pages")

	for note in marginalia:
		secrets.append("Margin note: " + note)

	return secrets

func get_size_multiplier() -> float:
	"""Return visual size multiplier for rendering"""
	match size:
		"Small":
			return 0.7
		"Medium":
			return 1.0
		"Large":
			return 1.3
		"Tome":
			return 1.5
		_:
			return 1.0
