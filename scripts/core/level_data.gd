extends Node

# Multidimensional dic to store all levels and data 
var level_dic = {
	"Level1":
	{
		"unlocked": true,
		"max_zombie_kills": 0,
		"zombie_kills": 0,
		"unlocks": "Level2",
		"beaten": false
	}
}

func generate_level(level):
	# Genrates the next level dic
	if level not in level_dic:
		level_dic[level] = {
			"unlocked": false,
			"max_zombie_kills": 0,
			"zombie_kills": 0,
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

func update_level(level: String, zombie_kills: int, max_zombie_kills: int, beaten: bool):
	level_dic[level]["zombie_kills"] = zombie_kills
	level_dic[level]["max_zombie_kills"] = max_zombie_kills
	level_dic[level]["beaten"] = beaten
	print(level_dic)
