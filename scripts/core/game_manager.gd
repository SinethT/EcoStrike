extends Node

signal enemy_kill(int)
signal level_beaten()

const GAME_TIMER = 35
const INPUT_MAP = "res://UI/scenes/InputSettings.tscn"
const LEVEL_DIRECTORY = "res://UI/scenes/LevelDirectory.tscn"

var score: int = 0
var enemy_kills: int = 0
var max_enemy_kills: int = 0
var damage_taken = 0
var time_over = false
var paused = false
var pause_menu
var gameover_screen
var score_label
var timer

func kill(kill_score):
	enemy_kills += 1
	score += kill_score
	emit_signal("enemy_kill")
	if enemy_kills == max_enemy_kills:
		die()
	
func die():
	timer.stop()
	gameover_screen.visible = true
	score_label.text = "Your Score: " + str(score)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if !time_over or timer.time_left < (GAME_TIMER * 75/100):
		win()

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

func load_level_directory():
	get_tree().change_scene_to_file(LEVEL_DIRECTORY)

func quit():
	get_tree().quit()

func win():
	emit_signal("level_beaten")
