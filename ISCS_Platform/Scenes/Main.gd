extends Node2D

@onready var camera:Camera2D = $Character/Sprite2D/Camera2D
@onready var text: RichTextLabel = $UI/Control/MarginContainer/RichTextLabel

var did_press: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	camera.zoom = Vector2(8,8)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_anything_pressed() and !did_press:
		did_press = true
		text.hide()
		
	if did_press and camera.zoom != Vector2(5,5):
		camera.zoom = camera.zoom.move_toward(Vector2(5,5),0.07)
