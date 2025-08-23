extends CanvasLayer

@onready var kill_display = $Kill_Display
@onready var timer_display = $Timer_Display
@onready var timer = $Timer

var game_timer = GameManager.GAME_TIMER

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.pause_menu = $PauseMenu
	GameManager.timer = $Timer
	GameManager.zombie_kill.connect(update_zombie_kills)
	timer.start(game_timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_timer_display(timer.time_left)
	if Input.is_action_just_pressed("pause"):
		GameManager.pause_play()

func update_zombie_kills():
	kill_display.text = str(GameManager.zombie_kills)

func update_timer_display(time):
	if time <= 120:
		timer_display.add_theme_color_override("font_color", Color(1.0,0,0,1.0))
	else:
		timer_display.add_theme_color_override("font_color", Color(1.0,1.0,1.0,1.0))
	timer_display.text = format_time(time)

func format_time(time):
	var mins = floor(time / 60)
	var secs = int(time) % 60
	return "%02d : %02d" % [mins, secs]


func _on_timer_timeout():
	GameManager.die()

func _on_resume_pressed():
	GameManager.resume()

func _on_restart_pressed():
	GameManager.restart()

func _on_settings_pressed():
	GameManager.load_settings()

func _on_quit_pressed():
	GameManager.quit()
