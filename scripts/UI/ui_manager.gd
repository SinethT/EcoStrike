extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.zombie_kill.connect(update_zombie_kills)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_zombie_kills():
	$Kill_Display.text = str(GameManager.zombie_kills)
