extends Node

# Multidimensional dic to store all levels and data 
var level_dic = {
	"Level1":
	{
		"unlocked": true,
		"score": 0,
		"max_score": 0,
		"enemy_kills": 0,
		"max_enemy_kills": 0,
		"damage_taken": 0,
		"time_over": false,
		"unlocks": "Level2",
		"beaten": false
	}
}

func generate_level(level):
	# Genrates the next level dic
	if level not in level_dic:
		level_dic[level] = {
			"unlocked": false,
			"score": 0,
			"max_score": 0,
			"enemy_kills": 0,
			"max_enemy_kills": 0,
			"damage_taken": 0,
			"time_over": false,
			"unlocks": generate_level_id(level),
			"beaten": false
		}

func generate_level_id(level):
	# Genrates the id of next level when player beats current 
	var level_id = ""
	for character in level:
		if character.is_valid_int():
			level_id += character
	level_id = int(level_id) + 1
	return "Level" + str(level_id)

func update_level(level: String, score: int, max_score: int, enemy_kills: int, max_enemy_kills: int, damage_taken: int, time_over: bool, beaten: bool):
	level_dic[level]["score"] = score
	level_dic[level]["max_score"] = max_score
	level_dic[level]["enemy_kills"] = enemy_kills
	level_dic[level]["max_enemy_kills"] = max_enemy_kills
	level_dic[level]["damage_taken"] = damage_taken
	level_dic[level]["time_over"] = time_over
	level_dic[level]["beaten"] = beaten
