extends Node2D

class_name Character

@onready var tile_map = $"../../TileMap"
@export var char_stats : Stats
var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var hover_id_path: PackedVector2Array
var target_position: Vector2
var is_moving: bool
var is_active_char: bool
signal turn_complete
signal char_moving

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
			)
			
			var tile_data = tile_map.get_cell_tile_data(0, tile_position)
			
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position)

func _input(event):
	if self == get_parent().active_char:
		if event.is_action_pressed("move") == false:
			return
		
		var id_path
		
		if is_moving:
			id_path = astar_grid.get_id_path(
				tile_map.local_to_map(target_position), 
				tile_map.local_to_map(get_global_mouse_position())
			).slice(1)
		else:
			id_path = astar_grid.get_id_path(
				tile_map.local_to_map(global_position), 
				tile_map.local_to_map(get_global_mouse_position())
			).slice(1)
		
		if id_path.is_empty() == false:
			current_id_path = id_path
			current_point_path = astar_grid.get_point_path(
				tile_map.local_to_map(target_position), 
				tile_map.local_to_map(get_global_mouse_position())
			)
			
			for i in current_point_path.size():
				current_point_path[i] = current_point_path[i] + Vector2(8, 8)

func _physics_process(_delta):
	if self == get_parent().active_char:
		var tile_position = tile_map.local_to_map(get_global_mouse_position())
		
		hover_id_path = astar_grid.get_id_path(
			tile_map.local_to_map(global_position), 
			tile_position
		)
		hover_id_path = hover_id_path.slice(1, hover_id_path.size() - 1)
		
		if current_id_path.is_empty():
			return
		
		if is_moving == false:
			target_position = tile_map.map_to_local(current_id_path.front())
			is_moving = true
			char_moving.emit()
			
		global_position = global_position.move_toward(target_position, 1)
		
		if global_position == target_position:
			current_id_path.pop_front()
			
			if current_id_path.is_empty() == false:
				target_position = tile_map.map_to_local(current_id_path.front())
			else:
				is_moving = false
				current_point_path.clear()
				turn_complete.emit()
