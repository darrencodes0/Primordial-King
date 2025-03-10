extends Unit
class_name Character

var in_ui_element: bool
var mode : String = "idle"
@onready var path = $Path

func _ui_element_mouse_entered():
	in_ui_element = true
	path._on_ui_element_mouse_entered()
	
func _ui_element_mouse_exited():
	in_ui_element = false
	path._on_ui_element_mouse_exited()
	
func change_mode(input_mode: String):
	if mode == input_mode:
		mode = "idle"
	else:
		mode = input_mode

func _input(event):
	if self == turn_queue.active_char:
		match mode:
			"idle":
				if !in_ui_element:
					if event.is_action_pressed("interact"):
						if !is_moving:
							current_id_path = astar_grid.get_id_path(
								tile_layer_zero.local_to_map(global_position),
								tile_layer_zero.local_to_map(get_global_mouse_position())
							).slice(1, movement_limit - moved_distance + 1)
						elif is_moving:
							return
							
						if !current_id_path.is_empty():
							tile_layer_zero._unsolid_coords(tile_layer_zero.local_to_map(global_position))
							unit_moving.emit()
							mode = "moving"
					else:
						return
			"moving":
				if event.is_action_pressed("stop_move"):
						if is_moving:
							current_id_path = current_id_path.slice(0, 1)
						unit_still.emit()
						mode = "idle"
			"attack":
				if event.is_action_pressed("interact"):
					var mouse_tile = tile_layer_zero.local_to_map(get_global_mouse_position())
					if actions > 0:
						if turn_queue.pc_positions.find_key(mouse_tile) != null:
							turn_queue.pc_positions.find_key(mouse_tile).unit_stats.health -= rng.randi_range(1, 6)
							print(turn_queue.pc_positions.find_key(mouse_tile).unit_stats.health)
						elif turn_queue.enemy_positions.find_key(mouse_tile) != null:
							turn_queue.enemy_positions.find_key(mouse_tile).unit_stats.health -= rng.randi_range(1, 6)
							print(turn_queue.enemy_positions.find_key(mouse_tile).unit_stats.health)
						actions -= 1
					else:
						return

func _physics_process(_delta):
	if self == turn_queue.active_char:
		if !in_ui_element:
			var tile_position = tile_layer_zero.local_to_map(get_global_mouse_position())
			
			if !is_moving:
				hover_id_path = astar_grid.get_id_path(
					tile_layer_zero.local_to_map(global_position),
					tile_position
				)
				hover_id_path = hover_id_path.slice(1, hover_id_path.size() - 1)
			
		move_towards_target(_delta)
