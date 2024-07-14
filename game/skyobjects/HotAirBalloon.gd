## Represents a hot air balloon in the sky scene.
##
## This class simulates the behavior of a hot air balloon, including
## buoyancy, wind interaction, and simple altitude control. The balloon
## aims to maintain a desired altitude range while being affected by
## environmental factors like wind.

class_name HotAirBalloon
extends BaseSkyObject

var lift_force: float = 9.8  # Assuming gravity is 9.8 m/s^2
var lift_adjustment_speed: float = 0.05
var lift_hysteresis: float = 50.0



func _ready():
	super._ready()
	mass = 1000  # kg, adjust as needed
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(randf(), randf(), randf())
	$Balloon.material_override = m

func _physics_process(delta):
	super._physics_process(delta)
	adjust_lift(delta)

func adjust_lift(delta):
	if is_too_high():
		lift_force = max(0, lift_force - lift_adjustment_speed * delta)
	elif is_too_low():
		lift_force = min(20, lift_force + lift_adjustment_speed * delta)
	
	apply_central_force(Vector3.UP * lift_force * mass)

func initialize(spawn_data: SpawnData):
	global_position = spawn_data.position
	var bounds = spawn_data.bounds
	altitude_range = Vector2(
		randf_range(bounds.position.y, bounds.end.y),
		randf_range(bounds.position.y, bounds.end.y)
	)
	altitude_range.x = min(altitude_range.x, altitude_range.y)
	altitude_range.y = max(altitude_range.x, altitude_range.y)
	
func highlight():
	null
	
func balloon_success():
	null
	
func balloon_failure():
	null

