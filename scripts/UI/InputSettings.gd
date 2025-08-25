extends Control

const MAIN_MENU = "res://UI/scenes/MainMenu.tscn"

var is_remapping = false
var action_to_remap = null
var remapping_button = null

var input_actions = {
	"shoot": "Shoot",
	"jump": "Jump",
	"Reload":"Reload",
	"Melee":"Melee",
	"crouch":"Crouch",
	"lean_left":"Lean Left",
	"lean_right":"Lean Right",
	"sprint":"Sprint",
	"up":"Move Forward",
	"down":"Move Backward",
	"left":"Move Left",
	"right":"Move Right",
}

@onready var input_button_scene = preload("res://UI/scenes/InputButton.tscn")
@onready var action_list = $Panel/MarginContainer/VBoxContainer/ScrollContainer/ActionList


func _ready():
	_create_action_list()


func _create_action_list():
	# Loads input settings from the project settings
	InputMap.load_from_project_settings()
	# Clears the existing items in the action_list
	for item in action_list.get_children():
		item.queue_free()

	# Creates buttons for each input action and displays the corresponding action label & input label
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")

		action_label.text = input_actions[action]

		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			# Removing the suffix "(Physical)" from the input event text
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""

		# Adds a child button to the action_list
		action_list.add_child(button)
		# connects its pressed signal to the _on_input_button_pressed method
		button.pressed.connect(_on_input_button_pressed.bind(button, action))


func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		# Stores the action and button to be remapped
		action_to_remap = action
		remapping_button = button
		# Updates the label text of the button to indicate that the user should press a key to bind
		button.find_child("LabelInput").text = "Press key to bind..."


func _input(event):
	if is_remapping:
		if event is InputEventKey or (event is InputEventMouseButton and event.pressed):
			# Turn double click into single click
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
			# Erases any existing events associated with the action being remapped in the InputMap
			InputMap.action_erase_events(action_to_remap)
			# Adds the new event to the InputMap for the action
			InputMap.action_add_event(action_to_remap, event)
			# Updates the action list in the UI
			_update_action_list(remapping_button, event)

			is_remapping = false
			action_to_remap = null
			remapping_button = null

			# Prevent clicking on the button gets as the mapping event
			accept_event()


func _update_action_list(button, event):
	# Sets the text of the "LabelInput" without the "(Physical)" suffix.
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)").to_upper()


func _on_reset_button_pressed():
	# Clears all the input actions from the InputMap
	# Restores the default input settings
	_create_action_list()


func _on_back_to_mainmenu_pressed():
	# Changes the current scene to the main menu scene.
	get_tree().change_scene_to_file(MAIN_MENU)
