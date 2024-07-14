extends Node

class_name WindSystem

var noise_x: FastNoiseLite
var noise_y: FastNoiseLite
var noise_z: FastNoiseLite
var time: float = 0.0
@export var prevailing_direction: Vector3 = Vector3(1, 0, 0)
@export var wind_strength: float = 0.5
@export var wind_variability: float = 1.0
@export var vertical_wind_factor: float = 0.1

func _ready():
	noise_x = FastNoiseLite.new()
	noise_y = FastNoiseLite.new()
	noise_z = FastNoiseLite.new()
	
	noise_x.seed = randi()
	noise_y.seed = randi()
	noise_z.seed = randi()
	
	noise_x.frequency = 0.005
	noise_y.frequency = 0.005
	noise_z.frequency = 0.005

func _process(delta):
	time += delta * 0.2

func get_wind_at_position(pos: Vector3) -> Vector3:
	var wind_variation = Vector3(
		noise_x.get_noise_3d(pos.x, pos.y, pos.z + time),
		noise_y.get_noise_3d(pos.x, pos.y, pos.z + time) * vertical_wind_factor,
		noise_z.get_noise_3d(pos.x, pos.y, pos.z + time)
	) * wind_variability
	
	return (prevailing_direction * wind_strength + wind_variation).normalized() * wind_strength
