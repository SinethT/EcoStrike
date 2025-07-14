extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Health system variables
@export var max_health: float = 100.0
var current_health: float
var is_dead: bool = false

@onready var animation_player = $zombie/AnimationPlayer

func _ready():
	current_health = max_health
	animation_player.play("Armature|Idle")
	# Add zombie to Target group so it can be hit by bullets
	add_to_group("Target")

# Called by bullets/projectiles when they hit the zombie
func Hit_Successful(damage: float, _direction: Vector3 = Vector3.ZERO, _hit_position: Vector3 = Vector3.ZERO):
	# Don't process hits if already dead
	if is_dead:
		return
		
	# Apply damage
	current_health -= damage
	
	# Check if zombie should die
	if current_health <= 0:
		die()
		return
	
	# Play hit reaction animation if still alive
	animation_player.stop()
	animation_player.play("Armature|Hit_reaction")
	animation_player.seek(0.3)

func die():
	if is_dead:
		return
	
	is_dead = true
	current_health = 0
	print("Zombie died!")
	
	# Stop any current animation and play death animation if available
	animation_player.stop()
	# You can add a death animation here when you have one
	animation_player.play("Armature|Die")
	
	# Remove from collision/targeting
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	# Queue for deletion after a delay
	await get_tree().create_timer(5.0).timeout
	queue_free()

func get_health_percentage() -> float:
	return current_health / max_health
