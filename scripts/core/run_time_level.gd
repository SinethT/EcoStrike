extends Node
class_name RunTimeLevel

var max_score = 0
var max_enemy_kills = 0

@onready var level = name

func _ready():
	GameManager.max_enemy_kills = get_tree().get_node_count_in_group("Target")
	# Connects the `level_beaten` signal to the `beat_level` method.
	GameManager.level_beaten.connect(beat_level)
	# Calls the `set_values` method to set initial values.
	set_values()

func set_values():
	# Calculating most enemies, coins and score the player can gain within that level
	for node in get_children():
		if node is Zombie:
			max_score += Zombie.SCORE
			max_enemy_kills += 1
		elif node is Robot:
			max_score += Robot.SCORE
			max_enemy_kills += 1

func beat_level():
	if GameManager.score > (max_score * 60/100):
	# Unlocks the next level
		LevelData.generate_level(LevelData.level_dic[level]["unlocks"])
		LevelData.level_dic[LevelData.level_dic[level]["unlocks"]]["unlocked"] = true

	# Updates the level data for the stat screen & data mesh (for saving)
	LevelData.update_level(level, GameManager.score, max_score, GameManager.enemy_kills, max_enemy_kills, GameManager.damage_taken, GameManager.time_over, true)
	SaveManager.save_game()
