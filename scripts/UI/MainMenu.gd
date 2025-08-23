extends Control

const LOGIN_MENU = "res://UI/scenes/LoginMenu.tscn"
const ERROR404 = "res://scenes/ui/error404.tscn"
const OPTIONS = "res://UI/scenes/InputSettings.tscn"
const MAIN_MENU = "res://UI/scenes/MainMenu.tscn"



# Called when the "Start" button is pressed
# Changes the scene to the LOGIN_MENU scene
func _on_start_pressed():
	get_tree().change_scene_to_file(LOGIN_MENU)

# Called when the "Options" button is pressed
# Changes the scene to the ERROR404 scene
func _on_options_pressed():
	get_tree().change_scene_to_file(OPTIONS)

# Called when the "Exit" button is pressed
# Quits the game
func _on_exit_pressed():
	get_tree().quit()

# Called when the "Back to Main Menu" button is pressed
# Changes the scene to the MAIN_MENU scene
func _on_back_to_mainmenu_pressed():
	get_tree().change_scene_to_file(MAIN_MENU)
