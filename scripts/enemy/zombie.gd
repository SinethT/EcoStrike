extends CharacterBody3D
class_name Enemy


const SPEED = 5.0
const CHASE_SPEED = 0.7
const ATTACK_RADIUS = 1.2
const DETECTION_RADIUS = 5.0
const MELEE_DAMAGE = 1.5
const IMMUNE_TIME = 0.3

# Health system variables
@export var max_health: float = 100.0
var current_health: float
var is_dead: bool = false
var can_take_damage = true

# AI movement variables
@onready var player = get_tree().get_first_node_in_group("Player")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var animation_player = $zombie/AnimationPlayer
@onready var motion_player = $zombie/AnimationPlayer2
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
		
		

		if distance_to_player > DETECTION_RADIUS and animation_player.current_animation != "Armature|Idle" and animation_player.current_animation != "Armature|Hit_reaction":
			# If player is out of range, stop moving and play idle animation
			velocity.x = 0
			velocity.z = 0
			if animation_player.current_animation != "Armature|Idle":
				animation_player.play("Armature|Idle")
		else:
			# If player is not detected, stop moving
			velocity.x = 0
			velocity.z = 0
		
		if distance_to_player <= ATTACK_RADIUS:
			attack()

		elif distance_to_player <= DETECTION_RADIUS:
			move_towards_player()
		else:
			# Stop moving and play idle animation
			velocity.x = 0
			velocity.z = 0
			if animation_player.current_animation != "Armature|Idle" and animation_player.current_animation != "Armature|Hit_reaction":
				animation_player.play("Armature|Idle")
		
		if Input.is_action_just_pressed("Melee") and distance_to_player < ATTACK_RADIUS:
			Hit_Successful(MELEE_DAMAGE)
	
	move_and_slide()

func animation_stop(anim_player="b"):
	anim_player = anim_player.to_lower()
	match anim_player:
		"motion", "m":
			motion_player.stop()
		"animation", "anim", "a":
			animation_player.stop()
		"both", "b":
			motion_player.stop()
			animation_player.stop()
	
func attack():
	animation_stop("motion")
	animation_player.play("Armature|Attack")
	await get_tree().create_timer(2.8).timeout
	

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
	if motion_player.current_animation != "Armature|Walk":
		motion_player.play("Armature|Walk")

# Called by bullets/projectiles when they hit the zombie
func Hit_Successful(damage: float, _direction: Vector3 = Vector3.ZERO, _hit_position: Vector3 = Vector3.ZERO):
	# Don't process hits if already dead
	if is_dead or !can_take_damage:
		return
		
	# Apply damage
	current_health -= damage
	health_bar.value -= damage
	immune_frames()
	
	# Check if zombie should die
	if current_health <= 0:
		die()
		return
	
	# Play hit reaction animation if still alive
	animation_stop()
	animation_player.play("Armature|Hit_reaction")
	animation_player.seek(0.3)
	await get_tree().create_timer(1.7).timeout

func immune_frames():
	# Prevent taking damage within this timer
	can_take_damage = false
	await get_tree().create_timer(IMMUNE_TIME).timeout
	can_take_damage = true

func die():
	if is_dead:
		return
	
	is_dead = true
	current_health = 0
	GameManager.kill()
	#print (GameManager.zombie_kills)
	
	health_bar.queue_free()
	
	# Stop any current animation and play death animation if available
	animation_stop()
	# You can add a death animation here when you have one
	animation_player.play("Armature|Die")
	
	# Remove from collision/targeting
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	# Queue for deletion after a delay
	await get_tree().create_timer(3.5).timeout
	queue_free()
