extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var animation_player = $zombie/AnimationPlayer

func _ready():
	animation_player.play("Armature|Idle")
	# Add zombie to Target group so it can be hit by bullets
	add_to_group("Target")

# Called by bullets/projectiles when they hit the zombie
func Hit_Successful(_damage: float, _direction: Vector3 = Vector3.ZERO, _hit_position: Vector3 = Vector3.ZERO):
	# Force immediate animation change by stopping current animation first
	animation_player.stop()
	# Play animation starting from 0.3 seconds
	animation_player.play("Armature|Hit_reaction", -1, 1.0, false)
	animation_player.seek(0.3)
