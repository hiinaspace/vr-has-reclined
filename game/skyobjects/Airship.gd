
## Simulates an airship (zeppelin) in the sky scene.
##
## This class models an airship with active propulsion and steering.
## It aims to follow a desired path while being affected by wind.
## The airship can adjust its altitude and heading, and performs
## banking turns for more realistic movement.
class_name Airship
extends BaseSkyObject

@export var desired_path: Vector3 = Vector3(1, 0, 0)
@export var desired_altitude: float = 1000.0
@export var altitude_tolerance: float = 10.0
@export var min_speed: float = 5.0  # m/s
@export var max_speed: float = 15.0  # m/s
@export var max_turn_torque: float = 2000.0  # N*m
@export var heading_tolerance: float = 0.1  # Radians
@export var acceleration: float = 2.0  # m/s^2
@export var lift_adjustment_speed: float = 0.1
@export var propulsion_force: float = 5000.0  # N

var current_lift_force: float = 9.8
var target_velocity: Vector3 = Vector3.ZERO
var last_heading_error: float = 0.0
var heading_change_time: float = 0.0
var heading_change_interval: float = 1.0

func _ready():
	super._ready()
	mass = 5000  # kg
	set_initial_orientation()
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(randf(), randf(), randf())
	$Balloon.material_override = m

func set_initial_orientation():
	target_velocity = desired_path.normalized() * ((min_speed + max_speed) / 2)
	look_at(global_position + target_velocity, Vector3.UP)
	# Rotate 180 degrees as we want the airship to face its back to the target direction
	rotate_y(PI)

func _physics_process(delta):
	super._physics_process(delta)
	adjust_lift(delta)
	apply_propulsion(delta)
	adjust_orientation(delta)

func adjust_lift(delta):
	var altitude_error = desired_altitude - global_position.y
	if abs(altitude_error) > altitude_tolerance:
		current_lift_force += sign(altitude_error) * lift_adjustment_speed * delta
		current_lift_force = clamp(current_lift_force, 0, 2 * 9.8)
	apply_central_force(Vector3.UP * current_lift_force * mass)

func apply_propulsion(delta):
	var current_horizontal_velocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
	var desired_horizontal_velocity = Vector3(target_velocity.x, 0, target_velocity.z)
	
	var velocity_error = desired_horizontal_velocity - current_horizontal_velocity
	var local_velocity_error = global_transform.basis.inverse() * velocity_error
	
	# We only apply force along the local Z axis
	var propulsion = Vector3(0, 0, -local_velocity_error.z).normalized() * propulsion_force
	
	apply_central_force(propulsion)

func adjust_orientation(delta):
	heading_change_time += delta
	if heading_change_time < heading_change_interval:
		return

	heading_change_time = 0.0
	
	var current_direction = -global_transform.basis.z
	var target_direction = target_velocity.normalized()
	
	var heading_error = current_direction.signed_angle_to(target_direction, Vector3.UP)
	
	if abs(heading_error) > heading_tolerance:
		var torque = Vector3.UP * sign(heading_error) * max_turn_torque
		apply_torque(torque)
	
	last_heading_error = heading_error

func update_target_velocity(new_target: Vector3):
	target_velocity = new_target.normalized() * clamp(new_target.length(), min_speed, max_speed)

func initialize(spawn_data: SpawnData):
	global_position = spawn_data.position
	var bounds = spawn_data.bounds
	var end_point = get_random_point_on_opposite_edge(spawn_data.position, bounds)
	desired_path = (end_point - global_position).normalized()
	desired_altitude = randf_range(bounds.position.y, bounds.end.y)
	update_target_velocity(desired_path * max_speed)
	set_initial_orientation()
