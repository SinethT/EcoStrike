extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _ready():
	$zombie/AnimationPlayer.play("Armature|Idle")
