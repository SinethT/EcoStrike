extends RigidBody3D
class_name WeaponPickUp

@export var weapon: WeaponSlot
@export_enum("Weapon","Ammo") var TYPE = "Weapon"

var Pick_Up_Ready: bool = false

func _ready():
	# Debug: Print node information
	# print("WeaponPickUp _ready() called for node: ", name)
	# print("Current weapon slot: ", weapon)
	
	# Auto-configure weapon if no WeaponSlot is assigned
	if weapon == null:
		# print("No weapon slot assigned, attempting auto-configuration...")
		auto_configure_weapon()
		
		# Verify the weapon was configured
	# 	if weapon != null:
	# 		print("Auto-configuration successful!")
	# 	else:
	# 		print("Auto-configuration failed - weapon is still null")
	# else:
	# 	print("Weapon slot already assigned")
	
	await get_tree().create_timer(2.0).timeout
	Pick_Up_Ready = true
	# print("Weapon pickup ready for: ", name)

func auto_configure_weapon():
	# Get the weapon name from the node name
	var node_name = name
	# print("Trying to auto-configure weapon for node: ", node_name)
	
	# Create a mapping of node names to resource names
	var weapon_mapping = {
		"blasterL": "blasterL",
		"blaster_L": "blasterL", 
		"blasterM": "blasterM",
		"blaster_m": "blasterM",
		"blaster_n": "blasterN",
		"blasterN": "blasterN",
		"blaster_I": "blasterI",
		"blasterI": "blasterI",
		"blasterQ": "blasterQ"
	}
	
	var resource_name = ""
	if weapon_mapping.has(node_name):
		resource_name = weapon_mapping[node_name]
	else:
		# Try to clean up the node name for common patterns
		var clean_name = node_name.replace("_", "").to_lower()
		for key in weapon_mapping.keys():
			if key.to_lower().replace("_", "") == clean_name:
				resource_name = weapon_mapping[key]
				break
	
	if resource_name.is_empty():
		# print("Warning: Cannot find weapon mapping for node name: ", node_name)
		return
	
	# Try to load the corresponding WeaponResource
	var resource_path = "res://Player_Controller/scripts/Weapon_State_Machine/Weapon_Resources/" + resource_name + ".tres"
	
	# print("Attempting to load weapon resource: ", resource_path)
	
	if ResourceLoader.exists(resource_path):
		var weapon_resource = load(resource_path) as WeaponResource
		if weapon_resource != null:
			# Create a new WeaponSlot and configure it
			weapon = WeaponSlot.new()
			weapon.weapon = weapon_resource
			weapon.current_ammo = weapon_resource.magazine
			weapon.reserve_ammo = weapon_resource.magazine
			
			# Verify the WeaponSlot was created properly
	# 		if weapon != null and weapon.weapon != null:
	# 			print("✅ Auto-configured weapon: ", resource_name, " with ", weapon.current_ammo, " ammo")
	# 			print("   - Weapon resource: ", weapon.weapon.weapon_name)
	# 			print("   - Magazine size: ", weapon.weapon.magazine)
	# 		else:
	# 			print("❌ WeaponSlot creation failed despite successful resource loading")
	# 	else:
	# 		print("❌ Failed to load WeaponResource at: ", resource_path)
	# else:
	# 	print("❌ WeaponResource not found at: ", resource_path)

# Remove the unused function
# func get_scene_file_hint() -> String:
