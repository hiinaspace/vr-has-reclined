## Represents an airplane in the sky scene.
##
## This class simulates a small propeller plane with simplified aerodynamics.
## It maintains a constant speed and performs banking turns to adjust its heading.
## The airplane follows a target heading while making small course corrections.
class_name Airplane
extends BaseSkyObject

@export var cruise_speed: float = 50.0  # m/s
@export var max_bank_angle: float = PI / 4  # 45 degrees
@export var turn_rate: float = 0.5  # radians per second
@export var roll_rate: float = 1.0  # radians per second
@export var heading_tolerance: float = 0.05  # radians

var target_heading: Vector3
var current_bank: float = 0.0
var lift_force: float

func _ready():
	super._ready()
	mass = 1000  # kg, adjust as needed for small planes
	lift_force = mass * 9.8  # Lift force to counteract gravity at cruise
	
	# Set initial velocity
	linear_velocity = -global_transform.basis.z * cruise_speed
	
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(randf(), randf(), randf())
	$wing.material_override = m
	$fuselage.material_override = m

func _physics_process(delta):
	apply_lift()
	apply_engine_force()
	adjust_bank(delta)
	update_orientation(delta)

func apply_lift():
	var lift = global_transform.basis.y * lift_force
	apply_central_force(lift)

func apply_engine_force():
	var drag_force = linear_velocity.length_squared() * 0.5 * 1.225 * 0.1 * 10  # Simplified drag
	var engine_force = -global_transform.basis.z * drag_force
	apply_central_force(engine_force)

func adjust_bank(delta):
	var current_heading = -global_transform.basis.z
	var heading_error = current_heading.signed_angle_to(target_heading, Vector3.UP)
	
	var target_bank = 0.0
	if abs(heading_error) > heading_tolerance:
		target_bank = sign(heading_error) * max_bank_angle
	
	var bank_difference = target_bank - current_bank
	var bank_change = sign(bank_difference) * min(abs(bank_difference), roll_rate * delta)
	current_bank += bank_change
	
	var roll_torque = global_transform.basis.z * bank_change / delta
	apply_torque(roll_torque)

func update_orientation(delta):
	var bank_direction = global_transform.basis.x
	var turn_torque = bank_direction * sin(current_bank) * turn_rate
	apply_torque(turn_torque)
	
	# Adjust pitch to maintain altitude
	var pitch_correction = global_transform.basis.x.cross(Vector3.UP).normalized()
	var pitch_torque = pitch_correction * 0.1  # Small constant pitch correction
	apply_torque(pitch_torque)

func set_target_heading(new_heading: Vector3):
	target_heading = new_heading.normalized()

func spawn(position: Vector3, initial_heading: Vector3):
	global_position = position
	target_heading = initial_heading.normalized()
	
	# Randomly perturb the initial heading
	var perturb_angle = randf_range(-PI/6, PI/6)  # Up to 30 degrees off
	var perturb_axis = Vector3.UP
	var perturbed_heading = initial_heading.rotated(perturb_axis, perturb_angle)
	
	look_at(global_position + perturbed_heading, Vector3.UP)
	#rotate_y(PI)  # Face the back of the plane to the direction of travel
	
	# Set initial velocity with slight random variation
	var speed_variation = randf_range(0.9, 1.1)
	linear_velocity = -global_transform.basis.z * cruise_speed * speed_variation

func initialize(spawn_data: SpawnData):
	var spawn_position = spawn_data.position
	var bounds = spawn_data.bounds
	var end_point = get_random_point_on_opposite_edge(spawn_position, bounds)
	var initial_heading = (end_point - spawn_position).normalized()
	spawn(spawn_position, initial_heading)
