## Manages the spawning and lifecycle of sky objects in the scene.
##
## This class is responsible for creating, maintaining, and removing sky objects
## within a defined spawn area. It ensures a constant number of each object type
## is present in the scene, spawning new objects as others leave the area.
## It's designed to be easily extensible for new types of sky objects
class_name SkyObjectSpawner
extends Node3D

@export var spawn_area: Area3D
@export var object_types: Array[SkyObjectType]

var spawn_bounds: AABB
var active_objects: Dictionary = {}

func _ready():
	if not spawn_area:
		push_error("Spawn area not set for SkyObjectSpawner")
		return
	
	calculate_spawn_bounds()
	
	spawn_area.body_exited.connect(_on_body_exited)
	
	preload_scene()

func calculate_spawn_bounds():
	var collision_shape = spawn_area.get_node("CollisionShape3D")
	if not collision_shape or not collision_shape.shape is BoxShape3D:
		push_error("Spawn area must have a CollisionShape3D with BoxShape3D")
		return

	var box_shape = collision_shape.shape as BoxShape3D
	var extents = box_shape.extents
	var spawn_area_transform = collision_shape.global_transform
	
	var center = spawn_area_transform.origin
	var size = extents * 2
	spawn_bounds = AABB(center - size/2, size)

func preload_scene():
	for object_type in object_types:
		var type_name = object_type.scene.resource_path.get_file().get_basename()
		active_objects[type_name] = []
		for i in range(object_type.desiredCount):
			spawn_object(object_type)

func spawn_object(object_type: SkyObjectType):
	var spawn_position = get_random_spawn_position()
	
	if spawn_position:
		var sky_object = object_type.scene.instantiate() as BaseSkyObject
		add_child(sky_object)
		
		var spawn_data = SpawnData.new()
		spawn_data.position = spawn_position
		spawn_data.bounds = spawn_bounds
		
		sky_object.initialize(spawn_data)
		
		var type_name = object_type.scene.resource_path.get_file().get_basename()
		active_objects[type_name].append(sky_object)

func get_random_spawn_position() -> Vector3:
	return Vector3(
		randf_range(spawn_bounds.position.x, spawn_bounds.end.x),
		randf_range(spawn_bounds.position.y, spawn_bounds.end.y),
		randf_range(spawn_bounds.position.z, spawn_bounds.end.z)
	)

func _on_body_exited(body: Node3D):
	for type_name in active_objects:
		if body in active_objects[type_name]:
			if body.has_node("Target"): 
				var quad_node = body.get_node("Target") # Update with the correct path
				#if quad_node:
				#	quad_node._on_despawn()
			active_objects[type_name].erase(body)
			body.queue_free()
			for object_type in object_types:
				if object_type.scene.resource_path.get_file().get_basename() == type_name:
					spawn_object(object_type)
					break
			break
			
func remove_and_respawn(body: Node3D):
	for type_name in active_objects:
		if body in active_objects[type_name]:
			if body.has_node("Target"): 
				var quad_node = body.get_node("Target")
				#if quad_node:
				#	quad_node._on_despawn()
			active_objects[type_name].erase(body)
			body.queue_free()
			for object_type in object_types:
				if object_type.scene.resource_path.get_file().get_basename() == type_name:
					spawn_object(object_type)
					break
			break
