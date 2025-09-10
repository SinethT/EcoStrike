extends CharacterBody3D
class_name Zombie

# Constants defining zombie characteristics and behaviors
const DAMAGE = 20.0           # Damage zombie deals to player when attacking
const SCORE = 10              # Points player gets for killing this zombie
const SPEED = 5.0             # Maximum movement speed (currently unused)
const CHASE_SPEED = 0.7       # Speed when chasing the player
const ATTACK_RADIUS = 1.1     # Distance at which zombie can attack player
const DETECTION_RADIUS = 20.0 # Distance at which zombie detects player
const MELEE_DAMAGE = 5.0      # Damage from melee attacks (for testing)
const IMMUNE_TIME = 0.3       # Time zombie is immune to damage after being hit

# Health system variables
@export var max_health: float = 100.0  # Maximum health of the zombie
var current_health: float              # Current health of the zombie
var is_dead: bool = false              # Flag to track if zombie is dead
var can_take_damage = true             # Flag for damage immunity frames
var player_in_area = false             # Flag for player detection area
var player_in_attack = false           # Flag for player in attack range

# AI movement and targeting variables
@onready var player = get_tree().get_first_node_in_group("Player")  # Reference to player
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")  # Gravity value

# Node references for zombie functionality
@onready var animation_player = $zombie/AnimationPlayer      # Main animation player
@onready var motion_player = $zombie/AnimationPlayer2        # Secondary animation player
@onready var health_bar = $SubViewport/health_bar            # Health bar UI
@onready var detection_area = $DetectionArea/CollisionShape3D # Detection collision shape
@onready var attack_area = $AttackArea/CollisionShape3D      # Attack collision shape

# Initialize zombie when it spawns
func _ready():
	current_health = max_health          # Set health to maximum
	
	# Initialize health bar display
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	# Start with idle animation
	animation_player.play("Armature|Idle")
	# Set up detection and attack radii
	detection_area.shape.radius = DETECTION_RADIUS
	attack_area.shape.radius = ATTACK_RADIUS
	# Add zombie to Target group so it can be hit by bullets
	add_to_group("Target")

# Main physics processing loop for zombie AI
func _physics_process(delta):
	# Don't process if zombie is dead
	if is_dead:
		return
	
	# Apply gravity if not on ground
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# AI behavior when player is detected
	if player_in_area:
		# Handle attack and movement logic
		if animation_player.current_animation != "Armature|Attack":
			if player_in_attack:
				attack()                    # Attack if player is in range
			else: 
				move_towards_player()       # Move towards player if detected but not in range
		# Debug: Allow player to damage zombie with melee
		if Input.is_action_just_pressed("Melee") and player_in_attack:
			Hit_Successful(MELEE_DAMAGE)
	else:
		# Player not detected - stop moving and play idle
		if animation_player.current_animation != "Armature|Idle" and animation_player.current_animation != "Armature|Hit_reaction":
			velocity.x = 0
			velocity.z = 0
			if animation_player.current_animation != "Armature|Idle":
				animation_player.play("Armature|Idle")
		else:
			# If player is not detected, stop moving
			velocity.x = 0
			velocity.z = 0
	
	# Apply movement
	move_and_slide()

# Utility function to stop animations
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

# Perform attack sequence on the player
func attack():
	animation_stop("motion")                                    # Stop motion animations
	animation_player.play("Armature|Attack")                   # Play attack animation
	await get_tree().create_timer(1.2).timeout                 # Wait for attack timing
	# Check if still attacking and damage player
	if animation_player.current_animation == "Armature|Attack":
		player.take_damage(DAMAGE)
	await get_tree().create_timer(1.5).timeout                 # Wait for attack cooldown

# Move zombie towards the player
func move_towards_player():
	# Calculate direction to player (only on horizontal plane)
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0  # Remove vertical component to prevent flying
	
	# Apply movement velocity towards player
	velocity.x = direction.x * CHASE_SPEED
	velocity.z = direction.z * CHASE_SPEED
	
	# Rotate to face the player with correction for model orientation
	if direction.length() > 0:
		look_at(global_position + direction, Vector3.UP)
		# Add 180-degree rotation around Y axis to correct model facing direction
		rotation.y += deg_to_rad(180)
	
	# Play walking animation if not already playing
	if motion_player.current_animation != "Armature|Walk":
		motion_player.play("Armature|Walk")

# Called when zombie takes damage from bullets/projectiles
func Hit_Successful(damage: float, _direction: Vector3 = Vector3.ZERO, _hit_position: Vector3 = Vector3.ZERO):
	# Don't process hits if already dead or in immunity frames
	if is_dead or !can_take_damage:
		return
		
	# Apply damage and update health
	current_health -= damage
	health_bar.value -= damage
	await get_tree().create_timer(0.001).timeout  # Small delay for visual feedback
	
	# Check if zombie should die
	if current_health <= 0:
		die()
		return
	
	# Enter immunity frames to prevent spam damage
	immune_frames(IMMUNE_TIME)

# Provide immunity frames after taking damage
func immune_frames(time):
	# Prevent taking damage within this timer
	can_take_damage = false
	await get_tree().create_timer(time).timeout
	can_take_damage = true

# Handle zombie death sequence
func die():
	# Prevent multiple death calls
	if is_dead:
		return
	
	# Set death state and update game manager
	is_dead = true
	current_health = 0
	GameManager.kill(SCORE)                    # Notify game manager of kill
	
	# Clean up health bar
	health_bar.queue_free()
	
	# Play death animation
	animation_stop()                           # Stop current animations
	animation_player.play("Armature|Die")      # Play death animation
	
	# Remove from collision/targeting system
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	# Queue for deletion after death animation
	await get_tree().create_timer(3.5).timeout
	queue_free()

# Detection area callbacks for player tracking
func _on_detection_area_body_entered(body):
	if body == player:
		player_in_area = true

func _on_detection_area_body_exited(body):
	if body == player:
		player_in_area = false

# Attack area callbacks for attack range tracking
func _on_attack_area_body_entered(body):
	if body == player:
		player_in_attack = true

func _on_attack_area_body_exited(body):
	if body == player:
		player_in_attack = false
