extends Control

# Main menu controller

func _ready():
	# Check if save file exists to enable/disable Continue button
	check_save_file()
	
	# Fade in menu
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func check_save_file():
	# TODO: Check if save file exists
	# For now, Continue button is disabled
	var continue_button = $CenterContainer/ButtonContainer/ContinueButton
	continue_button.disabled = true

func _on_new_game_pressed():
	print("MainMenu: Starting new game")

	# Reset game state
	if has_node("/root/GameState"):
		GameState.reset_game_state()

	# Fade out and transition to main game (no music fade - let it continue)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(_start_new_game)

func _start_new_game():
	# Transition to shop scene (Feature 3A - Diegetic UI)
	get_tree().change_scene_to_file("res://scenes/ShopScene.tscn")

func _on_continue_pressed():
	print("MainMenu: Continue game")
	# TODO: Load saved game
	pass

func _on_settings_pressed():
	print("MainMenu: Opening settings")
	# TODO: Open settings menu
	show_coming_soon("Settings")

func _on_credits_pressed():
	print("MainMenu: Showing credits")
	show_credits()

func show_coming_soon(feature_name: String):
	# Temporary popup for unimplemented features
	var popup = AcceptDialog.new()
	add_child(popup)
	popup.dialog_text = feature_name + " coming soon!"
	popup.title = "Coming Soon"
	popup.popup_centered()
	popup.confirmed.connect(popup.queue_free)

func show_credits():
	# Show credits popup
	var popup = AcceptDialog.new()
	add_child(popup)
	popup.dialog_text = """GLYPHIC
A Translation Mystery

Created for Weekend Prototype Challenge

Design & Development: [Your Name]
Music: Desk Work.mp3

Built with Godot 4.5
Prototype v0.1

Thank you for playing!"""
	popup.title = "Credits"
	popup.popup_centered()
	popup.confirmed.connect(popup.queue_free)
