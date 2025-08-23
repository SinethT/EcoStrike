extends Node

signal zombie_kill(int)

const GAME_TIMER = 900
const INPUT_MAP = "res://UI/scenes/InputSettings.tscn"

var zombie_kills: int = 0
var damage_taken = 0
var paused = false
var pause_menu
var timer
	
func kill():
	zombie_kills += 1
	emit_signal("zombie_kill")

func die():
	print("You're Dead")

func pause_play():
	paused = !paused
	pause_menu.visible = paused
	timer.paused = paused
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func resume():
	pause_play()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func restart():
	get_tree().reload_current_scene()

func load_settings():
	get_tree().change_scene_to_file(INPUT_MAP)

func quit():
	get_tree().quit()
