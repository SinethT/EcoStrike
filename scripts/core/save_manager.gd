extends Node

# File paths for save system
var save_path = "res://saves/"     # Directory where save files are stored
var save_name = "save1.tres"       # Name of the save file

# Instance of save data resource for managing persistent data
var save_data = SaveData.new()

# Loads the game data from the saved file on disk
func load_game():
    # Load the save file and create a duplicate to avoid reference issues
    save_data = ResourceLoader.load(save_path + save_name).duplicate(true)
    # Update the level data singleton with loaded data
    LevelData.level_dic = save_data.level_dic

# Saves the current game state to disk
func save_game():
    # Update the save data with current level progress
    save_data.level_dic = LevelData.level_dic
    # Write the save data to file
    ResourceSaver.save(save_data, save_path + save_name)
