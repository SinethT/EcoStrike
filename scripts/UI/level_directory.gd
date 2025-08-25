extends Control

const LEVEL1 = "res://levels/level_1.tscn"
const LEVEL2 = "res://levels/level_2.tscn"
const LEVEL3 = "res://levels/level_3.tscn"
const LEVEL4 = "res://levels/level_4.tscn"

@onready var level_holder_1 = $LevelHolder1
@onready var level_holder_2 = $LevelHolder2

var levels = []

# Called when the node enters the scene tree for the first time.
func _ready():
	levels = level_holder_1.get_children() + level_holder_2.get_children()
	update_levels()

func update_levels():
	for level in levels:
		if level.name in LevelData.level_dic:
			if LevelData.level_dic[level.name]["unlocked"] == true:
				level.disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_level_1_pressed():
	get_tree().change_scene_to_file(LEVEL1)


func _on_level_2_pressed():
	get_tree().change_scene_to_file(LEVEL2)


func _on_level_3_pressed():
	get_tree().change_scene_to_file(LEVEL3)


func _on_level_4_pressed():
	get_tree().change_scene_to_file(LEVEL4)
