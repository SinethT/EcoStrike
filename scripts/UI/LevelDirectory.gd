extends Control

const LEVEL1 = "res://levels/level_1.tscn"
const LEVEL2 = "res://levels/level_2.tscn"
const LEVEL3 = "res://levels/level_3.tscn"
#const LEVEL4 = "res://levels/level_4.tscn"
const MAIN_MENU = "res://UI/scenes/MainMenu.tscn"
const STAT_DISPLAY = "StatDisplay"

@onready var level_holder_1 = $LevelHolder1
@onready var level_holder_2 = $LevelHolder2

var levels = []

# Called when the node enters the scene tree for the first time.
func _ready():
	SaveManager.load_game()
	levels = level_holder_1.get_children() + level_holder_2.get_children()
	update_levels()
	show_stats()

func update_levels():
	for level in levels:
		if level.name in LevelData.level_dic:
			if LevelData.level_dic[level.name]["unlocked"] == true:
				level.disabled = false


func show_stats():
	var i = len(LevelData.level_dic) - 2
	if i < 0:
		return
	for level in LevelData.level_dic:
		if LevelData.level_dic[level]["unlocked"]:
			levels[i].get_node(STAT_DISPLAY).visible = true
			levels[i].get_node(STAT_DISPLAY).get_node("AnimationPlayer").play("show")
			
		if (
			((LevelData.level_dic[level]["score"]) > (LevelData.level_dic[level]["max_score"] * 75 / 100))
			and ((LevelData.level_dic[level]["enemy_kills"]) > (LevelData.level_dic[level]["max_enemy_kills"] * 75 / 100))
			and (LevelData.level_dic[level]["time_over"] == false 
			and LevelData.level_dic[level]["damage_taken"] == 0)
			):
				levels[i].get_node(STAT_DISPLAY).get_node("Star1").visible = true
				levels[i].get_node(STAT_DISPLAY).get_node("Star2").visible = true
				levels[i].get_node(STAT_DISPLAY).get_node("Star3").visible = true
		elif (
			((LevelData.level_dic[level]["enemy_kills"]) > (LevelData.level_dic[level]["max_enemy_kills"] * 75 / 100))
			and (LevelData.level_dic[level]["time_over"] == false 
			or LevelData.level_dic[level]["damage_taken"] == 0)
			):
				levels[i].get_node(STAT_DISPLAY).visible = true
				levels[i].get_node(STAT_DISPLAY).get_node("Star1").visible = true
				levels[i].get_node(STAT_DISPLAY).get_node("Star2").visible = true
				
		elif (LevelData.level_dic[level]["score"]) > (LevelData.level_dic[level]["max_score"] * 75 / 100):
			levels[i].get_node(STAT_DISPLAY).get_node("Star1").visible = true
		
		else:
			levels[i].get_node(STAT_DISPLAY).get_node("Star1").visible = false
			levels[i].get_node(STAT_DISPLAY).get_node("Star2").visible = false
			levels[i].get_node(STAT_DISPLAY).get_node("Star3").visible = false
			
		i += 1


func _on_level_1_pressed():
	get_tree().change_scene_to_file(LEVEL1)


func _on_level_2_pressed():
	get_tree().change_scene_to_file(LEVEL2)


func _on_level_3_pressed():
	get_tree().change_scene_to_file(LEVEL3)


func _on_level_4_pressed():
	pass
	#get_tree().change_scene_to_file(LEVEL4)

func _on_back_to_mainmenu_pressed():
	get_tree().change_scene_to_file(MAIN_MENU)
