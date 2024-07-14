## Base class for all objects that appear in the sky scene.
##
## This class provides common functionality for all sky objects,
## including initialization from spawn data and basic physics properties.
## It's designed to be extended by specific sky object types like
## balloons, airships, and skydivers.
class_name BaseSkyObject
extends RigidBody3D

var initial_altitude: float = 1000.0
var altitude_range: Vector2 = Vector2(800.0, 1200.0)

func _ready():
	position.y = initial_altitude

func _physics_process(delta):
	apply_wind_force(delta)

func apply_wind_force(delta):
	var wind_vector = SkyWindSystemGlobal.get_wind_at_position(global_position)
	apply_central_force(wind_vector * mass)

func is_too_high() -> bool:
	return global_position.y > altitude_range.y

func is_too_low() -> bool:
	return global_position.y < altitude_range.x

func initialize(spawn_data: SpawnData):
	# Base implementation, to be overridden by subclasses
	pass

func get_random_point_on_opposite_edge(start_point: Vector3, spawn_bounds: AABB) -> Vector3:
	var end_point = Vector3.ZERO
	
	if is_equal_approx(start_point.x, spawn_bounds.position.x):
		end_point.x = spawn_bounds.end.x
		end_point.z = randf_range(spawn_bounds.position.z, spawn_bounds.end.z)
	elif is_equal_approx(start_point.x, spawn_bounds.end.x):
		end_point.x = spawn_bounds.position.x
		end_point.z = randf_range(spawn_bounds.position.z, spawn_bounds.end.z)
	elif is_equal_approx(start_point.z, spawn_bounds.position.z):
		end_point.x = randf_range(spawn_bounds.position.x, spawn_bounds.end.x)
		end_point.z = spawn_bounds.end.z
	else:
		end_point.x = randf_range(spawn_bounds.position.x, spawn_bounds.end.x)
		end_point.z = spawn_bounds.position.z
	
	end_point.y = randf_range(spawn_bounds.position.y, spawn_bounds.end.y)
	return end_point
