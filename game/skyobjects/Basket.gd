extends MeshInstance3D
class_name Basket

# Variables
var card_number = null # Current card number

var image_texture = null # Stores the texture assigned to this balloon
var chosen_image: CompressedTexture2D # Track the chosen image for unloading

@export var card1Images: Array[CompressedTexture2D]
@export var card2Images: Array[CompressedTexture2D]
@export var card3Images: Array[CompressedTexture2D]
@export var decoys: Array[CompressedTexture2D]

var cardImages

# Called when the node enters the scene tree for the first time.
func _ready():
	cardImages = [card1Images, card2Images, card3Images]
	assign_texture()


func assign_texture():
	# choose random from current card plus decoys
	var curCardImages = cardImages[GameState.current_card_number - 1].duplicate()
	for i in decoys:
		curCardImages.append(i)
	chosen_image = curCardImages.pick_random()
	var m = get_active_material(0).duplicate()
	m.albedo_texture = chosen_image
	material_override = m

func is_real_image():
	return cardImages[GameState.current_card_number - 1].has(chosen_image)
	
