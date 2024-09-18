extends Node2D

@onready var camera:Camera2D = $Character/Sprite2D/Camera2D
@onready var text: RichTextLabel = $UI/Control/MarginContainer/RichTextLabel
@onready var credits_marker: Marker2D = $Credits
@onready var tile_map: TileMap = $TileMap
@onready var character: Node2D = $Character
@onready var credits: RichTextLabel = $UI/Control/MarginContainer/Credits

var did_press: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	camera.zoom = Vector2(8,8)
	#credits.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_anything_pressed() and !did_press:
		did_press = true
		text.hide()
		
	if did_press and camera.zoom != Vector2(5,5):
		camera.zoom = camera.zoom.move_toward(Vector2(5,5),0.07)
	
	if character.global_position == credits_marker.global_position:
		credits.show()
	else:
		credits.hide()
