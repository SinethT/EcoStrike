extends Resource
class_name SaveData

# Dictionary structure that mirrors LevelData for saving/loading
# This stores the persistent level progress data
@export var level_dic = {
	"Level1":
	{
		"unlocked": true,          # Level 1 is unlocked by default
		"score": 0,                # Player's best score for this level
		"max_score": 0,            # Maximum possible score for this level
		"enemy_kills": 0,          # Best enemy kill count for this level
		"max_enemy_kills": 0,      # Total enemies in this level
		"damage_taken": 0,         # Least damage taken in a successful run
		"time_over": false,        # Whether player completed within time limit
		"unlocks": "Level2",       # Which level this unlocks when completed
		"beaten": false            # Whether player has ever beaten this level
	}
}
