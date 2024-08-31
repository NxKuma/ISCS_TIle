extends Node2D

@onready var tile_map = $"../TileMap"
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

var is_moving = false
var tile = Vector2(0,0)
# Called when the node enters the scene tree for the first time.

func _physics_process(delta):
	if is_moving == false:
		return
	if animation_player.is_playing() == false:
		is_moving = false
	global_position = global_position.move_toward(tile, 0.6)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_moving:
		return
	
	
	if Input.is_action_pressed("left"):
		move(Vector2.LEFT)
		animation_player.play("LeftHop")
	elif Input.is_action_pressed("right"):
		move(Vector2.RIGHT)
		animation_player.play("RightHop")
	elif Input.is_action_pressed("up"):
		move(Vector2.UP)
		animation_player.play("UpHop")
	elif Input.is_action_pressed("down"):
		move(Vector2.DOWN)
		animation_player.play("DownHop")

func move(direction: Vector2):
	# Get current tile Vector2
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	# Get target tile Vector2
	var target_tile: Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y,
	)
	# Get custom data layer 
	var tile_data: TileData = tile_map.get_cell_tile_data(0, target_tile)
	
	for index in tile_map.get_layers_count():
		tile_map.get_cell_tile_data(index, target_tile)
		if !tile_data is TileData:
			return
		elif tile_data.get_custom_data("walkable") == false:
			return
	
	tile = tile_map.map_to_local(target_tile)
	
	
	#global_position = tile_map.map_to_local(target_tile)
	is_moving = true
