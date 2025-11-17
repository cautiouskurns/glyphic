# SceneManager.gd
# Autoload singleton for managing scene transitions
extends Node

var previous_scene: String = ""
var current_scene: String = ""

# Target tab when loading Main scene from shop
var target_tab: int = -1

func _ready():
	"""Initialize current scene to the starting scene"""
	# Get the current scene path when the game starts
	var root = get_tree().current_scene
	if root:
		current_scene = root.scene_file_path
	else:
		# Fallback to the main scene from project settings
		current_scene = "res://scenes/ShopScene.tscn"

func goto_scene(scene_path: String, tab: int = -1):
	"""Transition to a new scene, optionally with a target tab"""
	previous_scene = current_scene
	current_scene = scene_path
	target_tab = tab

	get_tree().change_scene_to_file(scene_path)

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
