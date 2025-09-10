extends Node

# Signals emitted when game events occur
signal enemy_kill(int)  # Emitted when an enemy is killed, passes kill count
signal level_beaten()   # Emitted when the level is completed successfully

# Scene file paths for UI transitions
const INPUT_MAP = "res://UI/scenes/InputSettings.tscn"        # Path to input settings scene
const LEVEL_DIRECTORY = "res://UI/scenes/LevelDirectory.tscn" # Path to level selection scene

# Game state variables that track player progress
var score: int = 0              # Player's current score in the level
var enemy_kills: int = 0        # Number of enemies killed so far this level
var max_enemy_kills: int = 0    # Total enemies that need to be killed to win
var damage_taken = 0            # Amount of damage player has taken this level
var time_over = false           # Flag to track if time has run out
var paused = false              # Flag to track if game is currently paused

# UI references that should be assigned from the main scene
var pause_menu          # Reference to pause menu UI element
var gameover_screen     # Reference to game over screen UI element
var score_label         # Reference to score display label
var timer               # Reference to level timer

# Called when an enemy is killed - updates score and kill count
func kill(kill_score):
	enemy_kills += 1                    # Increment the kill counter
	score += kill_score                 # Add points to player's score
	emit_signal("enemy_kill")           # Notify other systems of the kill
	if enemy_kills == max_enemy_kills:  # Check if all enemies are defeated
		die()                           # End the game (player won)

# Called when the game ends (either by winning, losing, or time running out)
func die():
	timer.stop()                                        # Stop the level timer
	gameover_screen.visible = true                      # Show the game over screen
	score_label.text = "Your Score: " + str(score)     # Display the final score
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)      # Make cursor visible for UI interaction
	# Check if player won (either time remaining or completed within time limit)
	if !time_over or timer.time_left < (timer.wait_time * 75/100):
		win()                                           # Player achieved victory

# Toggle the pause state of the game
func pause_play():
	paused = !paused                                # Toggle the pause flag
	pause_menu.visible = paused                     # Show/hide pause menu accordingly
	timer.paused = paused                           # Pause/unpause the level timer
	# Show cursor when paused for menu interaction
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Resume game from paused state
func resume():
	pause_play()                                    # Unpause the game
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Hide cursor for gameplay

# Restart the current level from the beginning
func restart():
	get_tree().reload_current_scene()               # Reload the current scene

# Load the input settings/controls configuration scene
func load_settings():
	get_tree().change_scene_to_file(INPUT_MAP)      # Switch to input settings scene

# Load the level selection screen
func load_level_directory():
	get_tree().change_scene_to_file(LEVEL_DIRECTORY) # Switch to level directory scene

# Exit the application completely
func quit():
	get_tree().quit()                               # Terminate the game

# Called when the player successfully completes the level
func win():
	emit_signal("level_beaten")                     # Notify other systems that level is complete
