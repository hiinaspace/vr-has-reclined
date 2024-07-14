extends Sprite3D

# Variables
var last_slot_number: int = 0

@export var card1Images: Array[CompressedTexture2D]
@export var card2Images: Array[CompressedTexture2D]
@export var card3Images: Array[CompressedTexture2D]

var cardImages

# Called when the node enters the scene tree for the first time.
func _ready():
	cardImages = [card1Images, card2Images, card3Images]

# Function to assign texture based on passed value
func assign_texture(slot_number: int):
	if slot_number == 0:
		hide()
	else:
		show()
		last_slot_number = slot_number
		texture = cardImages[GameState.current_card_number - 1][slot_number - 1]


func _on_viewmaster_card_update_card(slot_count: int):
	assign_texture(slot_count)

func _on_auto_binoculars_success_might_need_new_images():
	assign_texture(last_slot_number)
