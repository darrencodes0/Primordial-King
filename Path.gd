extends Node2D

@onready var character = get_parent()
@onready var tile_map = $"../../../TileMap"

func _process(_delta):
	queue_redraw()

func _draw():
	if character.current_point_path.is_empty():
		for i in character.test_point_path.size():
			tile_map.set_cell(1, character.test_point_path[i], 2, Vector2i(4, 2), 0)
	else:
		for i in character.current_point_path.size():
			tile_map.set_cell(1, character.current_point_path[i], 2, Vector2i(4, 2), 0)
