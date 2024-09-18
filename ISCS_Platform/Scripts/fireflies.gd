extends Node2D

@onready var tile_map: TileMap = $"../TileMap"
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ray_2d: RayCast2D = $RayCast2D
@onready var timer: Timer = $Timer

var rng: int = 0
var is_move: bool = false
var tile: Vector2 = Vector2(0,0) 
@export var current_tile: Vector2i

func _ready() -> void:
	rng = randi_range(0,3)
	current_tile = tile_map.local_to_map(global_position)

func _process(delta: float) -> void:
	animation_player.play("idle")
	rng = randi_range(0,3)

func _physics_process(delta: float) -> void:
	current_tile = tile_map.local_to_map(global_position)
	if global_position.distance_to(tile) != 0 and is_move:
		global_position = global_position.move_toward(tile, 1)

func move():
	is_move = true
	# Mapping randomized directions
	var direction: Vector2 = Vector2.ZERO
	match rng: 
		0: direction = Vector2.RIGHT
		1: direction = Vector2.LEFT
		2: direction = Vector2.UP
		3: direction = Vector2.DOWN
		
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
		return
	
	for index in tile_map.get_layers_count():
		tile_map.get_cell_tile_data(index, target_tile)
		if !tile_data is TileData:
			return
		elif tile_data.get_custom_data("walkable") == false:
			return

	timer.wait_time = randi_range(0,3)
	tile = tile_map.map_to_local(target_tile)
	
func _on_timer_timeout() -> void:
	move()
