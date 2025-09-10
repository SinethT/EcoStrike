extends CanvasLayer

# UI element references for game interface
@onready var kill_display = $Kill_Display      # Display for enemy kill count
@onready var timer_display = $Timer_Display    # Display for remaining time
@onready var timer = $Timer                    # Game timer node
@onready var score_label = $GameOverScreen/score  # Score display on game over screen

# Initialize UI manager and connect to game events
func _ready():
	# Set up GameManager references for UI elements
	GameManager.gameover_screen = $GameOverScreen
	GameManager.score_label = $GameOverScreen/score
	GameManager.pause_menu = $PauseMenu
	GameManager.timer = $Timer
	# Connect to enemy kill signal for updating kill display
	GameManager.enemy_kill.connect(update_enemy_kills)
	# Start the level timer
	timer.start()

# Process input and update displays every frame
func _process(_delta):
	update_timer_display(timer.time_left)      # Update timer display
	# Handle pause input
	if Input.is_action_just_pressed("pause"):
		GameManager.pause_play()

# Update the enemy kill counter display
func update_enemy_kills():
	kill_display.text = str(GameManager.enemy_kills)

# Update the timer display with color coding for urgency
func update_timer_display(time):
	# Change color to red when time is running low (less than 20% remaining)
	if time <= timer.wait_time * 20/100:
		timer_display.add_theme_color_override("font_color", Color(1.0,0,0,1.0))  # Red
	else:
		timer_display.add_theme_color_override("font_color", Color(0,0,0,1.0))    # Black
	# Update the timer text with formatted time
	timer_display.text = format_time(time)

# Format time in MM:SS format
func format_time(time):
	var mins = floor(time / 60)             # Calculate minutes
	var secs = int(time) % 60               # Calculate remaining seconds
	return "%02d : %02d" % [mins, secs]     # Format as MM:SS

# Timer timeout callback - triggers game over due to time limit
func _on_timer_timeout():
	GameManager.time_over = true            # Set time over flag
	GameManager.die()                       # End the game

# Pause menu button callbacks
func _on_resume_pressed():
	GameManager.resume()                    # Resume the game

func _on_restart_pressed():
	GameManager.restart()                   # Restart current level

func _on_settings_pressed():
	GameManager.load_settings()             # Open settings menu

func _on_quit_pressed():
	GameManager.quit()                      # Quit the game

# Game over screen callback
func _on_continue_pressed():
	GameManager.load_level_directory()      # Return to level selection
