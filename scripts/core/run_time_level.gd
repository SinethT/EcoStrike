extends Node
class_name RunTimeLevel

# Variables to track maximum possible achievements in this level
var max_score = 0        # Maximum score achievable in this level
var max_enemy_kills = 0  # Maximum number of enemies that can be killed

# Get the level name from the node name
@onready var level = name

# Initialize the level when it's ready
func _ready():
    # Set the maximum enemy count based on nodes in the "Target" group
    GameManager.max_enemy_kills = get_tree().get_node_count_in_group("Target")
    # Connect the level completion signal to our beat_level method
    GameManager.level_beaten.connect(beat_level)
    # Calculate the maximum possible values for this level
    set_values()

# Calculate the maximum score and enemy kills possible in this level
func set_values():
    # Loop through all child nodes to count enemies and calculate max score
    for node in get_children():
        if node is Zombie:
            max_score += Zombie.SCORE        # Add zombie score value
            max_enemy_kills += 1             # Increment enemy count
        elif node is Robot:
            max_score += Robot.SCORE         # Add robot score value
            max_enemy_kills += 1             # Increment enemy count

# Called when the player beats the level
func beat_level():
    # Check if player achieved at least 60% of maximum possible score
    if GameManager.score > (max_score * 60/100):
        # Unlock the next level
        LevelData.generate_level(LevelData.level_dic[level]["unlocks"])
        # Mark the next level as unlocked in the level dictionary
        LevelData.level_dic[LevelData.level_dic[level]["unlocks"]]["unlocked"] = true

    # Update the level data with player's performance for stats and saving
    LevelData.update_level(level, GameManager.score, max_score, GameManager.enemy_kills, max_enemy_kills, GameManager.damage_taken, GameManager.time_over, true)
    # Save the updated game data to file
    SaveManager.save_game()
