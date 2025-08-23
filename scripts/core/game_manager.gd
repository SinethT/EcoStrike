extends Node

signal zombie_kill(int)

var zombie_kills: int = 0
var damage_taken = 0
var timer = 900

func kill():
	zombie_kills += 1
	emit_signal("zombie_kill")

func die():
	print("You're Dead")
