extends Node2D

@onready var tile_map: TileMap = $"../TileMap"
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ray_2d: RayCast2D = $RayCast2D
@onready var area_2d: Area2D = $"../Area2D"

var can_animate: bool = true
var is_moving: bool = false
var is_water: bool = false
var is_ground: bool = false
var is_obstacle: bool = false
var on_water: bool = false
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
	#animation_player.speed_scale = 1.5


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	current_data= tile_map.get_cell_tile_data(0, current_tile)
	current_tile = tile_map.local_to_map(global_position)
	
	if is_moving == false:
		return
	if animation_player.is_playing() == false:
		is_moving = false
	
	if on_mud and saved_direction != Vector2.ZERO and !is_ground :
		move(saved_direction)
		animate(saved_direction)
		if !is_moving or on_ground:
			on_mud = false
			
	if on_water and saved_direction != Vector2.ZERO and is_water:
		if is_water and saved_direction == next_direction:
			move(next_direction, true)
			animate(next_direction)
		else:
			move(saved_direction, true)
			animate(saved_direction)
		if !is_moving or on_ground:
			on_water = false
	
		
	if !global_position.distance_to(tile) == 0:
		is_moving = true
		global_position = global_position.move_toward(tile, 0.5)
		animation_player.get_animation(animation_player.current_animation).set_loop_mode(1)
	else:
		animation_player.get_animation(animation_player.current_animation).set_loop_mode(0)
		animation_player.stop()
		is_moving = false
	
	if from_portal:
		global_position = saved_coords
		current_tile = tile_map.local_to_map(saved_coords)
		animation_player.stop()
		is_moving = false
		from_portal = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	on_water = current_data.get_custom_data("water")
	on_mud = current_data.get_custom_data("mud")
	on_ground = current_data.get_custom_data("ground")

	if is_moving:
		return
	saved_direction = Vector2.ZERO
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
		if on_mud and is_obstacle:
			await get_tree().create_timer(0.1).timeout
		if direction == Vector2.LEFT:
			if on_mud and is_obstacle:
				sprite_2d.frame = 34 #Look Right
			else:
				sprite_2d.frame = 16 #Look Right
		if direction == Vector2.UP:
			if on_mud and is_obstacle:
				sprite_2d.frame = 35 #Look Right
			else:
				sprite_2d.frame = 24 #Look Right
		if direction == Vector2.RIGHT:
			if on_mud and is_obstacle:
				sprite_2d.frame = 32 #Look Right
			else:
				sprite_2d.frame = 0 #Look Right
		if direction == Vector2.DOWN:
			if on_mud and is_obstacle:
				sprite_2d.frame = 33 #Look Right
			else:
				sprite_2d.frame = 8 #Look Down
		return
	
	if (on_water and !on_mud) or is_water:
		if direction == Vector2.LEFT:
			animation_player.play("LeftSwim")
		if direction == Vector2.UP:
			animation_player.play("UpSwim")
		if direction == Vector2.RIGHT:
			animation_player.play("RightSwim")
		if direction == Vector2.DOWN:
			animation_player.play("DownSwim")
	elif on_mud and !on_water:
		#animation_player.play("MudSlide")
		if direction == Vector2.RIGHT or direction == Vector2.UP:
			animation_player.play("MudSlide")
		else:
			animation_player.play("MudSlide_R")
	else :
		if direction == Vector2.LEFT:
			animation_player.play("LeftHop")
		if direction == Vector2.UP:
			animation_player.play("UpHop")
		if direction == Vector2.RIGHT:
			animation_player.play("RightHop")
		if direction == Vector2.DOWN:
			animation_player.play("DownHop")

func move(direction: Vector2, in_water: bool = false):
	can_animate = true
	# Get target tile Vector2
	var target_tile: Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y,
	)
	# Get custom data layer 
	var tile_data: TileData = tile_map.get_cell_tile_data(0, target_tile)
	
	
	if in_water:
		await get_tree().create_timer(0.1).timeout
	if is_water and in_water :
		ray_2d.target_position = direction * 8
	else:
		ray_2d.target_position = direction * 16
	ray_2d.force_raycast_update()
	if ray_2d.is_colliding():
		can_animate = false
		if in_water:
			is_moving = false
		is_obstacle = true
		await get_tree().create_timer(0.1).timeout
		return
	else:
		can_animate = true


	for index in tile_map.get_layers_count():
		if !tile_data is TileData:
			return
		else:
			if tile_data.get_custom_data("walkable") == false:
				return
			elif tile_data.get_custom_data("ground"):
				did_check = false
				on_ground = true
				on_water = false
				on_mud = false
				is_water = false
				is_ground = true
			elif tile_data.get_custom_data("mud"):
				saved_direction = direction
				on_mud = true
				did_check = false
				is_ground = false
				is_water = false
			elif tile_data.get_custom_data("water"):
				if in_water:
					did_check = true
					next_direction = tile_data.get_custom_data("direction")
					saved_direction = current_data.get_custom_data("direction")
				else:
					did_check = false
					saved_direction = tile_data.get_custom_data("direction")
				on_mud = false
				is_water = true
				on_ground = false
			
	#tile_data = tile_map.get_cell_tile_data(0, target_tile)
	##if !did_check:
		##if ray_2d.is_colliding():
			##if in_water:
				##did_check = true
				##pass
			##can_animate = false
			##return
		##else:
			##can_animate = true
	tile = tile_map.map_to_local(target_tile)
	is_moving = true
	#tile = tile_map.map_to_local(target_tile)
	#is_moving = true

func _on_area_2d_area_entered(area):
	if area.is_in_group("Portal"):
		await get_tree().create_timer(0.6).timeout
		from_portal = true
		saved_coords = area.get_child(1).global_position
		#Put the coords in position
		global_position = saved_coords
		current_tile = tile_map.local_to_map(saved_coords)
		tile = tile_map.map_to_local(global_position)
