extends Node

# Multidimensional dictionary to store all levels and their associated data 
var level_dic = {
	"Level1":
	{
		"unlocked": true,          # Whether this level is available to play
		"score": 0,                # Player's achieved score for this level
		"max_score": 0,            # Maximum possible score for this level
		"enemy_kills": 0,          # Number of enemies killed by player
		"max_enemy_kills": 0,      # Total number of enemies in the level
		"damage_taken": 0,         # Amount of damage player took during level
		"time_over": false,        # Whether the player ran out of time
		"unlocks": "Level2",       # Which level this one unlocks when beaten
		"beaten": false            # Whether the player has completed this level
	}
}

# Creates a new level entry in the level dictionary if it doesn't exist
func generate_level(level):
	# Generate the next level dictionary entry
	if level not in level_dic:
		level_dic[level] = {
			"unlocked": false,                    # New levels start locked
			"score": 0,                          # No score initially
			"max_score": 0,                      # Max score will be calculated later
			"enemy_kills": 0,                    # No kills initially
			"max_enemy_kills": 0,                # Will be set based on level content
			"damage_taken": 0,                   # No damage taken initially
			"time_over": false,                  # Time hasn't run out initially
			"unlocks": generate_level_id(level), # Calculate next level ID
			"beaten": false                      # Level hasn't been beaten yet
		}

# Generates the ID for the next level based on current level name
func generate_level_id(level):
	# Generate the ID of next level when player beats current level
	var level_id = ""
	# Extract numeric characters from level name
	for character in level:
		if character.is_valid_int():
			level_id += character
	# Convert to integer, add 1, then convert back to level format
	level_id = int(level_id) + 1
	return "Level" + str(level_id)

# Updates all the statistics for a completed level
func update_level(level: String, score: int, max_score: int, enemy_kills: int, max_enemy_kills: int, damage_taken: int, time_over: bool, beaten: bool):
	level_dic[level]["score"] = score                    # Update player's score
	level_dic[level]["max_score"] = max_score            # Update maximum possible score
	level_dic[level]["enemy_kills"] = enemy_kills        # Update enemies killed
	level_dic[level]["max_enemy_kills"] = max_enemy_kills # Update total enemies in level
	level_dic[level]["damage_taken"] = damage_taken      # Update damage player took
	level_dic[level]["time_over"] = time_over            # Update whether time ran out
	level_dic[level]["beaten"] = beaten                  # Update completion status
