extends MeshInstance3D

# Exposed variables
@export var slots: int = 7 # Number of slots on the card
@export var rotation_speed: float = 1.0 # Speed of rotation
@export var texture_assigner: NodePath # Path to the CardAssigner node

var target_rotation: float = 0.0 # Target rotation angle
var current_rotation: float = 0.0 # Current rotation angle
var slot_count: int = 0

# when card changes, to update texture from ViewCards
signal update_card(slot_cout: int)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Smoothly interpolate towards the target rotation
	current_rotation = lerp_angle(current_rotation, target_rotation, rotation_speed * delta)
	rotation_degrees.z = rad_to_deg(current_rotation)

func _update_card():
		# Call the assign_texture function with the current slot count
	update_card.emit(slot_count)

# Called when the right controller trigger is pressed
func _on_right_controller_button_pressed(name):
	if name == "trigger_click":
		slot_count += 1
		slot_count = slot_count % slots
		target_rotation = (PI / float(slots)) * slot_count
		_update_card()
		print("trigger pressed and slot count at", slot_count)

# Called when the left controller trigger is pressed
func _on_left_controller_button_pressed(name):
	if name == "trigger_click":
		if slot_count > 0:
			slot_count -= 1
		slot_count = slot_count % slots
		target_rotation = (PI / float(slots)) * slot_count
		_update_card()
		print("trigger pressed and slot count at", slot_count)
