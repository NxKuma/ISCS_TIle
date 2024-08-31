extends Node2D

@onready var tile_map = $"../TileMap"
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var ray_2d = $RayCast2D

var can_animate: bool = true
var is_moving: bool = false
var on_water: bool = false
var on_mud: bool = false
var tile: Vector2 = Vector2(0,0)
var saved_direction: Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.

func _physics_process(delta):
	if is_moving == false:
		return
	
	global_position = global_position.move_toward(tile, 0.6)
	
	if animation_player.is_playing() == false:
		is_moving = false
	if on_mud and saved_direction != Vector2.ZERO:
		move(saved_direction)
		animate(saved_direction)
	if on_water and saved_direction != Vector2.ZERO:
		move(saved_direction)
		animate(saved_direction)
	
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_moving:
		return
	
	if Input.is_action_pressed("left"):
		move(Vector2.LEFT)
		animate(Vector2.LEFT)
	elif Input.is_action_pressed("right"):
		move(Vector2.RIGHT)
		animate(Vector2.RIGHT)
	elif Input.is_action_pressed("up"):
		move(Vector2.UP)
		animate(Vector2.UP)
	elif Input.is_action_pressed("down"):
		move(Vector2.DOWN)
		animate(Vector2.DOWN)
	

func animate(direction: Vector2):
	if !can_animate:
		if direction == Vector2.LEFT:
			sprite_2d.frame = 16 #Look Right
		if direction == Vector2.UP:
			sprite_2d.frame = 24 #Look Right
		if direction == Vector2.RIGHT:
			sprite_2d.frame = 0 #Look Right
		if direction == Vector2.DOWN:
			sprite_2d.frame = 8 #Look Down
		return
	
	if on_water and !on_mud:
		if direction == Vector2.LEFT:
			animation_player.play("LeftSwim")
		if direction == Vector2.UP:
			animation_player.play("UpSwim")
		if direction == Vector2.RIGHT:
			animation_player.play("RightSwim")
		if direction == Vector2.DOWN:
			animation_player.play("DownSwim")
	elif !on_water and on_mud:
		animation_player.play("MudSlide")
	else:
		if direction == Vector2.LEFT:
			animation_player.play("LeftHop")
		if direction == Vector2.UP:
			animation_player.play("UpHop")
		if direction == Vector2.RIGHT:
			animation_player.play("RightHop")
		if direction == Vector2.DOWN:
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
	
	ray_2d.target_position = direction * 16
	ray_2d.force_raycast_update()
	if ray_2d.is_colliding():
		can_animate = false
		return
	else:
		can_animate = true
	
	for index in tile_map.get_layers_count():
		tile_map.get_cell_tile_data(index, target_tile)
		if !tile_data is TileData:
			return
		elif tile_data.get_custom_data("walkable") == false:
			return
		elif tile_data.get_custom_data("ground"):
			on_mud = false
			on_water = false
		elif tile_data.get_custom_data("mud"):
			saved_direction = direction
			on_mud = true
			on_water = false
		elif tile_data.get_custom_data("water"):
			on_mud = false
			on_water = true
			
		if on_water:
			saved_direction = tile_data.get_custom_data("direction")
			
	
	tile = tile_map.map_to_local(target_tile)
	
	
	#global_position = tile_map.map_to_local(target_tile)
	is_moving = true
