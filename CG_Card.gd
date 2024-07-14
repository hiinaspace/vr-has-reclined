extends MeshInstance3D

# Exposed variables
@export var card_to_enable: int = 1 # Card number to check for enabling the object

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initially disable the object
	visible = false
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Check if the specified card is finished
	var finished_cards = GameState.get_finished_cards()
	if card_to_enable in finished_cards:
		#print("Card", card_to_enable, "is finished.")
		visible = true
		set_process(false) # Stop checking once the object is enabled
	#else:
		#print("Card", card_to_enable, "is not finished yet.")
