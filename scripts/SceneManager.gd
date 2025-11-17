# SceneManager.gd
# Autoload singleton for managing scene transitions (using show/hide instead of scene switching)
extends Node

var previous_scene: String = ""
var current_scene: String = ""

# Target tab when loading Main scene from shop
var target_tab: int = -1

# References to loaded scenes
var shop_scene: Node = null
var main_scene: Node = null

func _ready():
	"""Initialize current scene to the starting scene"""
	# Get the current scene path when the game starts
	var root = get_tree().current_scene
	if root:
		current_scene = root.scene_file_path
		# Store reference to shop scene
		if current_scene == "res://scenes/ShopScene.tscn":
			shop_scene = root
	else:
		# Fallback to the main scene from project settings
		current_scene = "res://scenes/ShopScene.tscn"

func goto_scene(scene_path: String, tab: int = -1):
	"""Transition to a scene using show/hide instead of destroying"""
	previous_scene = current_scene
	target_tab = tab

	# If going to Main scene from shop
	if scene_path == "res://scenes/Main.tscn":
		# Load main scene if not already loaded
		if main_scene == null:
			var main_scene_resource = load("res://scenes/Main.tscn")
			main_scene = main_scene_resource.instantiate()
			get_tree().root.add_child(main_scene)

		# Hide shop, show main
		if shop_scene:
			shop_scene.hide_shop()
		main_scene.visible = true
		current_scene = scene_path

	# If going to shop from Main
	elif scene_path == "res://scenes/ShopScene.tscn":
		# Hide main, show shop
		if main_scene:
			main_scene.visible = false
		if shop_scene:
			shop_scene.show_shop()
		current_scene = scene_path
		target_tab = -1

func goto_work_screen():
	"""Go to main work interface"""
	goto_scene("res://scenes/Main.tscn", 0)

func goto_translation_screen():
	"""Go to translation screen"""
	goto_scene("res://scenes/Main.tscn", 1)

func goto_examination_screen():
	"""Go to examination screen"""
	goto_scene("res://scenes/Main.tscn", 2)

func goto_dictionary_screen():
	"""Go to dictionary screen"""
	goto_scene("res://scenes/Main.tscn", 3)

func goto_queue_screen():
	"""Go to customer queue screen"""
	goto_scene("res://scenes/Main.tscn", 4)

func return_to_shop():
	"""Return to shop hub"""
	target_tab = -1
	goto_scene("res://scenes/ShopScene.tscn")

func is_from_shop() -> bool:
	"""Check if we came from the shop scene"""
	return previous_scene == "res://scenes/ShopScene.tscn"
