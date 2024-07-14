extends MeshInstance3D

# with references to hand controller
# when trigger is held down
# enable two cameras, move them to the position of the XR left/right eye
# also enable two sprite3Ds and move them in front of XR left/right eye so
# the user only sees the cameras essentially.
# otherwise disable them all
@export var leftCameraRoot: Node3D
@export var rightCameraRoot: Node3D

@export var leftCamera: Camera3D
@export var rightCamera: Camera3D

@export var controller: XRController3D
@export var origin: XROrigin3D

@export var leftvp: SubViewport  
@export var rightvp: SubViewport

@export var cameraOrigin: XRCamera3D
@export var raycast: RayCast3D # Reference to the RayCast3D node

@export var sky_spawner: NodePath # Add this line to reference the SkyObjectSpawner

# Called when the node enters the scene tree for the first time.
func _ready():
	leftvp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	rightvp.render_target_update_mode = SubViewport.UPDATE_DISABLED

var enableView: bool = false

# Variables to store the last detected image and balloon node
var last_chosen_image: String = ""
var last_balloon_node: Node = null

func _adjust_lenses(joystick: Vector2):
	# disable these controls, don't need them until we readd more distant objects.
	return
	
	
	if joystick.y > 0.8:
		leftCamera.fov = clamp(leftCamera.fov * 0.9, 1, 15)
		rightCamera.fov = leftCamera.fov
	if joystick.y < -0.8:
		leftCamera.fov = clamp(leftCamera.fov * 1.1, 1, 15)
		rightCamera.fov = leftCamera.fov
	# overlap/cant of the lenses
	# todo make less sensitive at high zoom
	if joystick.x > 0.6:
		var adjust = deg_to_rad(lerp(0.0, 0.1, joystick.x - 0.6))
		leftCamera.rotate_y(-adjust)
		rightCamera.rotate_y(adjust)
	elif joystick.x < -0.6:
		var adjust = deg_to_rad(lerp(0.0, 0.1, -joystick.x - 0.6))
		leftCamera.rotate_y(adjust)
		rightCamera.rotate_y(-adjust)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_adjust_lenses(controller.get_vector2("primary"))

	if not enableView:
		return
	
	if not XRServer.primary_interface:
		return
		
	var pin = XRServer.primary_interface
	leftCameraRoot.global_transform = pin.get_transform_for_view(0, origin.global_transform)
	rightCameraRoot.global_transform = pin.get_transform_for_view(1, origin.global_transform)

	if raycast.is_colliding():
		handle_raycast()


func handle_raycast():
	# Perform the raycast
	if raycast.is_colliding():
		#print("Raycast hit something")
		var collider = raycast.get_collider()
		if collider:
			#print("Raycast hit collider: ", collider.name)
			var balloon = collider # Assuming the collider is the CollisionShape3D
			if balloon:
				balloon.highlight()
				#print("Balloon node: ", balloon.name)
				#print("Balloon's children: ", balloon.get_children())
				#if balloon.has_node("Target"):
				#	var target_node = balloon.get_node("Target")
				#	#print("Found Target node")
				#	if target_node.has_method("get_chosen_image"):
				#		var image_name = target_node.get_chosen_image() # Assuming get_chosen_image returns a string
				#		#print("Image name: ", image_name)

signal success_might_need_new_images()

func handle_button_press():
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and collider.has_node(".."):
			var balloon = collider # Assuming the collider is the CollisionShape3D
			if balloon.has_node("Target"):
				var target_node: Basket = balloon.get_node("Target")
				
				if target_node.is_real_image():
					
					var old_card_number = GameState.current_card_number
					GameState.mark_image_found(target_node.chosen_image)
					
					print("Image found and marked: ", target_node.chosen_image)
					
					# very hacky but worgs
					if old_card_number != GameState.current_card_number:
						$CardCompleted.play()
					
					handle_success(balloon)
					success_might_need_new_images.emit()
				else:
					handle_failure(balloon)
	else:
		$ClickDull.play()

func handle_success(balloon):
	balloon.balloon_success()
	$PopSuccess.play()
	remove_balloon(balloon)

func handle_failure(balloon):
	balloon.balloon_failure()
	$PopFail.play()
	remove_balloon(balloon)


func remove_balloon(balloon):
	if has_node(sky_spawner):
		var spawner = get_node(sky_spawner) as SkyObjectSpawner
		if spawner:
			spawner.remove_and_respawn(balloon)



func _on_activate_binoculars_body_entered(body):
	# assume it's the binoculars, no other objects exist currently.
	enableView = true
	show()
	leftvp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	rightvp.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func _on_activate_binoculars_body_exited(body):
	enableView = false
	hide()
	leftvp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	rightvp.render_target_update_mode = SubViewport.UPDATE_DISABLED
