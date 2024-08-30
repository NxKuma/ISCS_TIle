extends Node2D

@onready var tile_map = $"../TileMap"
@onready var sprite_2d = $Sprite2D

#var is_moving = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if is_moving:
		#return
		
	if Input.is_action_pressed("left"):
		move(Vector2.LEFT)
	elif Input.is_action_pressed("right"):
		move(Vector2.RIGHT)
	elif Input.is_action_pressed("up"):
		move(Vector2.UP)
	elif Input.is_action_pressed("down"):
		move(Vector2.DOWN)

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
	
	#if tile_data.get_costum_data("walkable") == false:
		#return
		
	#Move Player
	#is_moving = true
	global_position = tile_map.map_to_local(target_tile)
