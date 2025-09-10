extends ProgressBar

# Node references for health bar functionality
@onready var damage_bar = $damagebar    # Secondary bar showing damage taken
@onready var timer = $Timer             # Timer for damage bar animation delay

# Health value with custom setter for automatic updates
var health = 0: set = _set_health

# Custom setter for health value - handles bar updates and damage visualization
func _set_health(new_health):
	var prev_health = health                    # Store previous health for comparison
	health = min(max_value, new_health)         # Clamp health to maximum value
	value = health                              # Update main health bar immediately

	# Handle damage bar animation
	if health < prev_health:
		timer.start()                           # Start timer for damage bar delay (taking damage)
	else:
		damage_bar.value = health               # Immediately update damage bar (healing)

# Initialize health bar with starting health value
func init_health(_health):
	health = _health                            # Set current health
	max_value = health                          # Set maximum health value
	value = health                              # Set current display value
	damage_bar.max_value = health               # Set damage bar maximum
	damage_bar.value = health                   # Set damage bar current value

# Called when timer expires - animates damage bar to current health
func _on_timer_timeout():
	damage_bar.value = health                   # Smoothly update damage bar to current health
