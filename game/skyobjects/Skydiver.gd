## Simulates a skydiver with a parachute in the sky scene.
##
## This class models a skydiver's behavior, including realistic parachute physics,
## aerodynamic forces, and random steering maneuvers. It aims to create a balance
## between realistic physics and interesting visual behavior, allowing for both
## stable descent and dynamic movements like diving and turning.
class_name Skydiver
extends BaseSkyObject

@export var safe_terminal_velocity: float = 5.5  # m/s, typical safe landing speed
@export var body_drag_coefficient: float = 0.1
@export var lift_coefficient: float = 0.2
@export var max_steering_torque: float = 5.0
@export var min_altitude: float = 100.0  # Minimum safe altitude

var air_density: float = 1.225  # kg/m^3, approximate air density at sea level
var body_area: float = 1.0  # m^2, approximate frontal area of a human body

var time_until_next_maneuver: float = 0.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var parachute_drag_coefficient: float

func _ready():
	mass = 80  # kg, average human mass
	
	# Calculate parachute drag coefficient based on safe terminal velocity
	parachute_drag_coefficient = (2 * mass * gravity) / (air_density * safe_terminal_velocity * safe_terminal_velocity)
   
	# Set the center of mass to be at the "body" of the skydiver
	set_center_of_mass_mode(RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM)
	set_center_of_mass(Vector3(0, -1, 0))  # 1 meter below the center
	
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(randf(), randf(), randf())
	$Parachute.material_override = m
	
func initialize(spawn_data: SpawnData):
	global_position = Vector3(spawn_data.position.x, spawn_data.bounds.end.y, spawn_data.position.z)
	rotate_y(randf_range(0, 2 * PI))
	linear_velocity = Vector3.ZERO

func _physics_process(delta):
	apply_aerodynamic_forces()
	perform_random_maneuvers(delta)

func apply_aerodynamic_forces():
	var velocity = linear_velocity
	var speed_squared = velocity.length_squared()

	# Parachute drag (using global Y axis of the RigidBody as parachute normal)
	var parachute_normal = global_transform.basis.y
	var parachute_drag = parachute_normal * parachute_drag_coefficient * air_density * speed_squared * 0.5
	apply_central_force(parachute_drag)

	# Body drag
	var body_drag = -velocity.normalized() * body_drag_coefficient * air_density * speed_squared * body_area * 0.5
	apply_central_force(body_drag)

	# Lift force
	var lift_direction = velocity.cross(parachute_normal).cross(velocity).normalized()
	var lift_force = lift_direction * lift_coefficient * air_density * speed_squared * body_area * 0.5
	apply_central_force(lift_force)

func perform_random_maneuvers(delta):
	time_until_next_maneuver -= delta
	if time_until_next_maneuver <= 0:
		time_until_next_maneuver = randf_range(1.0, 5.0)
		
		# Calculate steering direction, biased against steering downward at low altitudes
		var altitude_factor = clamp((global_position.y - min_altitude) / 2000.0, 0.0, 1.0)
		var vertical_bias = lerp(0.2, 1.0, altitude_factor)  # 0.2 (slight downward bias) to 1.0 (full range)
		
		var steering_direction = Vector3(
			randf_range(-1, 1),
			randf_range(-vertical_bias, 1),  # Bias against steering downward
			randf_range(-1, 1)
		).normalized()
		
		var steering_torque = steering_direction * max_steering_torque * randf()
		apply_torque(steering_torque)
