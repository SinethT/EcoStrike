extends CharacterBody3D


const SPEED = 5.0
const CHASE_SPEED = 0.08
const JUMP_VELOCITY = 4.5

# Health system variables
@export var max_health: float = 100.0
var current_health: float
var is_dead: bool = false

# AI movement variables
@export var detection_radius: float = 10
@onready var player = get_tree().get_first_node_in_group("Player")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var animation_player = $zombie/AnimationPlayer
@onready var health_bar = $SubViewport/health_bar

func _ready():
	current_health = max_health
	
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	animation_player.play("Armature|Idle")
	# Add zombie to Target group so it can be hit by bullets
	add_to_group("Target")
	

func _physics_process(delta):
	if is_dead:
		return
	
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Check if player is within detection radius and move towards them
	if player and is_instance_valid(player):
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player <= detection_radius:
			move_towards_player()
		else:
			# Stop moving and play idle animation
			velocity.x = 0
			velocity.z = 0
			if animation_player.current_animation != "Armature|Idle":
				animation_player.play("Armature|Idle")
	
	move_and_slide()



func move_towards_player():
	# Calculate direction to player (only on horizontal plane)
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0  # Remove vertical component
	
	# Move towards player
	velocity.x = direction.x * CHASE_SPEED
	velocity.z = direction.z * CHASE_SPEED
	
	# Rotate to face the player with 90-degree correction for model orientation
	if direction.length() > 0:
		look_at(global_position + direction, Vector3.UP)
		# Add 180-degree rotation around Y axis to correct model facing direction
		rotation.y += deg_to_rad(180)
	
	# Play walking animation if not already playing
	if animation_player.current_animation != "Armature|Walk" and animation_player.current_animation != "Armature|Run":
		animation_player.play("Armature|Walk")

# Called by bullets/projectiles when they hit the zombie
func Hit_Successful(damage: float, _direction: Vector3 = Vector3.ZERO, _hit_position: Vector3 = Vector3.ZERO):
	# Don't process hits if already dead
	if is_dead:
		return
		
	# Apply damage
	current_health -= damage
	health_bar.value -= damage
	
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
	
	health_bar.queue_free()
	
	# Stop any current animation and play death animation if available
	animation_player.stop()
	# You can add a death animation here when you have one
	animation_player.play("Armature|Die")
	
	# Remove from collision/targeting
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	# Queue for deletion after a delay
	await get_tree().create_timer(3.5).timeout
	queue_free()
