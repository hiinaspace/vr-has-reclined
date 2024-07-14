extends Node

# Set the path to the AutoBinocular node
@export var auto_binoculars_path: NodePath

func _ready():
	# Check if the AutoBinocular node exists and is assigned
	if not auto_binoculars_path:
		print("AutoBinocular path not assigned")
	else:
		var auto_binoculars = get_node(auto_binoculars_path)
		if not auto_binoculars:
			print("AutoBinocular node not found at path: ", auto_binoculars_path)

func _on_left_controller_button_pressed(name):
	if name == "by_button":
		_recenter()
	if name == "ax_button":
		print("ax button pressed")
		_call_auto_binocular_function()

func _on_right_controller_button_pressed(name):
	if name == "by_button":
		_recenter()
	if name == "ax_button":
		print("ax button pressed")
		_call_auto_binocular_function()

func _recenter():
	XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, false)

func _call_auto_binocular_function():
	# Get the AutoBinocular node
	var auto_binoculars = get_node(auto_binoculars_path)
	if auto_binoculars:
		if auto_binoculars.has_method("handle_button_press"):
			auto_binoculars.call("handle_button_press")
		else:
			print("AutoBinocular node does not have method handle_button_press")
	else:
		print("AutoBinocular node not found at path: ", auto_binoculars_path)
