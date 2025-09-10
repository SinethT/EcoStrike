extends Control

const LEVEL_DIRECTORY = "res://UI/scenes/LevelDirectory.tscn"
const MAIN_MENU = "res://UI/scenes/MainMenu.tscn"
const AGE_LIMIT = 12
const AGE_BOUNDARY = 100

var player_name = ""
var birth_year = 0
var greeting = "Hi %s ^_^\nWe're Almost there…"

@onready var name_holder = $VBoxContainer/Name
@onready var year_holder = $VBoxContainer/BirthYear
@onready var loading_bar = $LoadingBar
@onready var greeter = $Greeter
@onready var age_label = $AgeLabel
@onready var input_error = $InputError
@onready var name_box = $VBoxContainer/Name
@onready var birth_year_box = $VBoxContainer/BirthYear
@onready var continue_button = $HBoxContainer/Continue


func _ready():
	# Declaring initial visual status
	loading_bar.visible = false
	greeter.visible = false
	age_label.visible = false
	input_error.visible = false
	# Giving focus to the name box
	name_box.grab_focus()
	
func _input(event):
	# Handling keyboard navigation for the login menu 
	if name_box.has_focus():
		if event.is_action_pressed("enter") or event.is_action_pressed("tab"):
				accept_event()
				birth_year_box.grab_focus()
	elif birth_year_box.has_focus():
		if event.is_action_pressed("enter"):
				accept_event()
				continue_button.emit_signal("pressed")

func _on_continue_pressed():
	# Validating name input
	if name_holder.text.length() <= 15:
		player_name = name_holder.text.capitalize()
		# Adding that name to the greeting
		greeter.text = greeting % player_name
		# Validating the birth year input
		if year_holder.text.is_valid_int():
			birth_year = int(year_holder.text)
			if check_age(birth_year):
				# If both inputs are correct, proceed to the next stage
				loading_bar.visible = true
				loading_bar.play()
				greeter.visible = true
				await loading_bar.animation_finished
				# Opens the level directory
				get_tree().change_scene_to_file(LEVEL_DIRECTORY)
			else:
				# Outputting InputError
				input_error.visible = false
				age_label.visible = true
		else:
			# Outputting age is not enough
			age_label.visible = false
			input_error.visible = true
	else:
		input_error.visible = true


func check_age(year):
	# Obtaines current year from the system's date
	var current_year = Time.get_date_dict_from_system()["year"]
	# If valid, return true
	if current_year - year > AGE_LIMIT and current_year - year < AGE_BOUNDARY:
		return true



# Handles the event when the back button is pressed in the login menu
func _on_back_pressed():
	# Changes the scene to the main menu
	get_tree().change_scene_to_file(MAIN_MENU)
