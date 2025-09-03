extends CharacterBody3D
class_name Robot

const DAMAGE = 2.0
const SCORE = 2
const CHASE_SPEED = 0.7
const IMMUNE_TIME = 0.3

# Health system variables
@export var look_speed: float = 5.0
@export var max_health: float = 20
var current_health: float
var is_dead: bool = false
var can_take_damage = true
var player = null

# AI movement variables
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var ray_cast = $RayCast3D
@onready var animation_player = $robot/AnimationPlayer
@onready var health_bar = $SubViewport/health_bar

func _ready():
	current_health = max_health
	
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	animation_player.play("CharacterArmature|Idle")
	# Add robot to Target group so it can be hit by bullets
	add_to_group("Target")

func _physics_process(delta):
	if player:
		look_at(player.global_transform.origin, Vector3.UP)
		var target_dir = (player.global_transform.origin - global_transform.origin).normalized()
		var target_rot = Transform3D().looking_at(target_dir, Vector3.UP).basis.get_euler()
		rotation = rotation.lerp(target_rot, look_speed * delta)
		# Add 180-degree rotation around Y axis to correct model facing direction
		rotation.y += deg_to_rad(180)
		
		if !is_dead and ray_cast.is_colliding() and ray_cast.get_collider() == player:
			attack()

func attack():
	animation_player.play("CharacterArmature|Shoot")
	await get_tree().create_timer(0.3).timeout
	if !player == null:
		player.take_damage(DAMAGE)

# Called by bullets/projectiles when they hit the robot
func Hit_Successful(damage: float, _direction: Vector3 = Vector3.ZERO, _hit_position: Vector3 = Vector3.ZERO):
	# Don't process hits if already dead
	if is_dead or !can_take_damage:
		return
		
	# Apply damage
	current_health -= damage
	health_bar.value -= damage
	await get_tree().create_timer(0.001).timeout
	
	# Check if the robot should die
	if current_health <= 0:
		die()
		return
	
	immune_frames(IMMUNE_TIME)

func immune_frames(time):
	# Prevent taking damage within this timer
	can_take_damage = false
	await get_tree().create_timer(time).timeout
	can_take_damage = true

func die():
	if is_dead:
		return
	
	is_dead = true
	current_health = 0
	GameManager.kill(SCORE) #TODO
	#print (GameManager.zombie_kills)
	
	health_bar.queue_free()
	
	# Stop any current animation and play death animation if available
	animation_player.stop()
	# You can add a death animation here when you have one
	animation_player.play("CharacterArmature|Death")
	
	# Remove from collision/targeting
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	# Queue for deletion after a delay
	await get_tree().create_timer(0.8).timeout
	queue_free()

func _on_player_detect_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		if ray_cast.is_colliding() and ray_cast.get_collider().is_in_group("Player"):
			attack()


func _on_player_detect_body_exited(body):
	if body == player:
		player = null
