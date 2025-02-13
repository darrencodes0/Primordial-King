extends Node2D

var enemy_scene = preload("res://Scenes/Enemy/Enemy.tscn")
var enemy_stats = preload("res://Resources/Stats/basicEnemy.tres")

var positions = {}
var tile_size = 16

func spawn_characters(count: int, layer: TileMapLayer) -> Array[Enemy]:
	var spawned_characters: Array[Enemy] = []
	
	for i in range(count):
		var character = spawn_character(layer)
		if character:
			spawned_characters.append(character)
			
	return spawned_characters

func spawn_character(layer: TileMapLayer) -> Enemy:
	var tile_position = Vector2i(randi() % tile_size, randi() % tile_size)
	var tile_data = layer.get_cell_tile_data(tile_position)
	
	if tile_data and tile_data.get_custom_data("walkable") and !positions.has(tile_position):
		var position = Vector2(tile_position) * tile_size + Vector2(tile_size / 2, tile_size / 2)
		var char_instance = enemy_scene.instantiate()
		
		var stats = enemy_stats.duplicate()
		var rng = RandomNumberGenerator.new()
		stats.health += rng.randi_range(-2, 2)
		stats.movement_speed += rng.randi_range(-5, 5)
		
		char_instance.global_position = position
		add_child(char_instance)
		positions[char_instance] = layer.local_to_map(char_instance.global_position)
		return char_instance
	
	return spawn_character(layer)
