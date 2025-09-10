extends CharacterBody3D
class_name Robot

# Constants defining robot characteristics and behaviors
const DAMAGE = 2.0         # Damage robot deals to player when attacking
const SCORE = 2            # Points player gets for killing this robot
const CHASE_SPEED = 0.7    # Movement speed (currently unused)
const IMMUNE_TIME = 0.3    # Time robot is immune to damage after being hit

# Health system variables
@export var look_speed: float = 5.0    # Speed at which robot rotates to face player
@export var max_health: float = 20     # Maximum health of the robot
var current_health: float             # Current health of the robot
var is_dead: bool = false             # Flag to track if robot is dead
var can_take_damage = true            # Flag for damage immunity frames
var player = null                     # Reference to player (null when not detected)

# Physics and AI variables
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")  # Gravity value

# Node references for robot functionality
@onready var ray_cast = $RayCast3D                    # Raycast for line of sight detection
@onready var animation_player = $robot/AnimationPlayer # Animation player for robot actions
@onready var health_bar = $SubViewport/health_bar      # Health bar UI display

# Initialize robot when it spawns
func _ready():
	current_health = max_health          # Set health to maximum
	
	# Initialize health bar display
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	# Start with idle animation
	animation_player.play("CharacterArmature|Idle")
	# Add robot to Target group so it can be hit by bullets
	add_to_group("Target")

# Main physics processing loop for robot AI
func _physics_process(delta):
	# Only process AI if player is detected
	if player:
		# Rotate to face the player smoothly
		look_at(player.global_transform.origin, Vector3.UP)
		var target_dir = (player.global_transform.origin - global_transform.origin).normalized()
		var target_rot = Transform3D().looking_at(target_dir, Vector3.UP).basis.get_euler()
		rotation = rotation.lerp(target_rot, look_speed * delta)
		# Add 180-degree rotation around Y axis to correct model facing direction
		rotation.y += deg_to_rad(180)
		
		# Attack if player is visible and robot is not dead
		if !is_dead and ray_cast.is_colliding() and ray_cast.get_collider() == player:
			attack()

# Perform attack sequence on the player
func attack():
	animation_player.play("CharacterArmature|Shoot")   # Play shooting animation
	await get_tree().create_timer(0.3).timeout         # Wait for attack timing
	# Damage player if still valid target
	if !player == null:
		player.take_damage(DAMAGE)

# Called when robot takes damage from bullets/projectiles
func Hit_Successful(damage: float, _direction: Vector3 = Vector3.ZERO, _hit_position: Vector3 = Vector3.ZERO):
	# Don't process hits if already dead or in immunity frames
	if is_dead or !can_take_damage:
		return
		
	# Apply damage and update health display
	current_health -= damage
	health_bar.value -= damage
	await get_tree().create_timer(0.001).timeout  # Small delay for visual feedback
	
	# Check if robot should die
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

# Handle robot death sequence
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
	animation_player.stop()                    # Stop current animations
	animation_player.play("CharacterArmature|Death")  # Play death animation
	
	# Remove from collision/targeting system
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	# Queue for deletion after death animation
	await get_tree().create_timer(0.8).timeout
	queue_free()

# Player detection area callbacks
func _on_player_detect_body_entered(body):
	# Set player reference when they enter detection area
	if body.is_in_group("Player"):
		player = body
		# Attack immediately if player is visible
		if ray_cast.is_colliding() and ray_cast.get_collider().is_in_group("Player"):
			attack()

func _on_player_detect_body_exited(body):
	# Clear player reference when they leave detection area
	if body == player:
		player = null
