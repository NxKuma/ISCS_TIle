extends Node2D

@onready var tile_map = $"../TileMap"
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var ray_2d = $RayCast2D
@onready var area_2d = $"../Area2D"

var can_animate: bool = true
var is_moving: bool = false
var on_water: bool = false
var is_water: bool = false
var on_mud: bool = false
var on_ground: bool = true
var did_check: bool = false
var from_portal: bool = false

var tile: Vector2 = Vector2.ZERO
var next_direction: Vector2 = Vector2.ZERO
var saved_direction: Vector2 = Vector2.ZERO
var saved_coords: Vector2 = Vector2.ZERO
var current_tile: Vector2i
var current_data: TileData

func _ready():
	# Get current tile Vector2
	current_tile = tile_map.local_to_map(global_position)
	current_data= tile_map.get_cell_tile_data(0, current_tile)


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	current_data= tile_map.get_cell_tile_data(0, current_tile)
	if is_moving == false:
		return
	if animation_player.is_playing() == false:
		is_moving = false
	if on_mud and saved_direction != Vector2.ZERO:
		move(saved_direction)
		animate(saved_direction)
		if !is_moving or on_ground:
			on_mud = false
	if on_water and saved_direction != Vector2.ZERO and is_water:
		if is_water and saved_direction == next_direction:
			move(next_direction, true)
		else:
			move(saved_direction, true)
		if !is_moving or on_ground:
			on_water = false
		animate(saved_direction)
		
	current_tile = tile_map.local_to_map(global_position)
	global_position = global_position.move_toward(tile, 0.6)
	
	if from_portal:
		global_position = saved_coords
		current_tile = tile_map.local_to_map(saved_coords)
		from_portal = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	on_water = current_data.get_custom_data("water")
	if is_moving:
		return
		
	print(on_water)
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
		if on_mud:
			return
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
	elif on_mud and !on_water:
		if direction == Vector2.RIGHT or direction == Vector2.UP:
			animation_player.play("MudSlide")
		else:
			animation_player.play_backwards("MudSlide")
	else:
		if direction == Vector2.LEFT:
			animation_player.play("LeftHop")
		if direction == Vector2.UP:
			animation_player.play("UpHop")
		if direction == Vector2.RIGHT:
			animation_player.play("RightHop")
		if direction == Vector2.DOWN:
			animation_player.play("DownHop")

func move(direction: Vector2, in_water: bool = false):
	# Get target tile Vector2
	var target_tile: Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y,
	)
	# Get custom data layer 
	var tile_data: TileData = tile_map.get_cell_tile_data(0, target_tile)
	print("Target", target_tile)
	ray_2d.target_position = direction * 16
	ray_2d.force_raycast_update()
	if in_water:
		await get_tree().create_timer(0.1).timeout
	if !did_check:
		if ray_2d.is_colliding():
			if in_water:
				did_check = true
				return
			can_animate = false
			return
		else:
			can_animate = true

	for index in tile_map.get_layers_count():
		#tile_data = tile_map.get_cell_tile_data(index, target_tile)
		if !tile_data is TileData:
			return
		elif tile_data.get_custom_data("walkable") == false:
			return
		elif tile_data.get_custom_data("ground"):
			did_check = false
			on_mud = false
			on_water = false
			on_ground = true 
		elif tile_data.get_custom_data("mud"):
			saved_direction = direction
			did_check = false
			on_mud = true
			on_water = false
			on_ground = false
		elif tile_data.get_custom_data("water"):
			if in_water:
				if tile_data.get_custom_data("obstacle"):
					print("Hello")
					return
				else:
					did_check = false
					next_direction = tile_data.get_custom_data("direction")
					saved_direction = current_data.get_custom_data("direction")
			else:
				did_check = false
				saved_direction = tile_data.get_custom_data("direction")
			on_mud = false
			is_water = true
			on_ground = false
		
	tile = tile_map.map_to_local(target_tile)
	is_moving = true

func _on_area_2d_area_entered(area):
	if area.is_in_group("Portal"):
		await get_tree().create_timer(0.6).timeout
		from_portal = true
		saved_coords = area.get_child(1).global_position
		#Put the coords in position
		global_position = saved_coords
		current_tile = tile_map.local_to_map(saved_coords)
		tile = tile_map.map_to_local(global_position)
