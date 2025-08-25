extends Node3D

const HEALTH_UP = 10

@onready var animation_player = $AnimationPlayer
@onready var health_up_sfx = $"health-up_sfx"

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("idle")


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		body.health += HEALTH_UP
		health_up_sfx.play()
		queue_free()
