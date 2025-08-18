extends Node

signal zombie_kill(int)

var zombie_kills: int = 0
var damage_taken = 0

func kill():
	zombie_kills += 1
	emit_signal("zombie_kill")
