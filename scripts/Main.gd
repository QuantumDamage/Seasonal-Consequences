extends Node2D

@onready var bear = $Bear
@onready var food_container = $FoodContainer
@onready var obstacle_container = $ObstacleContainer
@onready var enemy_container = $EnemyContainer
@onready var ui = $UI
@onready var tile_map: TileMap = $TileMap

@onready var bee_container = $BeeContainer
var bee_scene = preload("res://scenes/Bee.tscn")
const POND_SOURCE_ID = 0
const POND_CHANCE = 0.003
const BEE_CHANCE = 0.005
const TREE_CHANCE = 0.1
#var food_scene = preload("res://scenes/Food.tscn")
#var obstacle_scene = preload("res://scenes/Obstacle.tscn")
#var enemy_scene = preload("res://scenes/Enemy.tscn")

func _ready():
	spawn_initial_objects()

func _process(delta):
	pass
	#print(bear.position)
	#update_season()
	#update_ui()

func get_random_transform(horizontal_only=false) -> int:
	if horizontal_only:
		var transforms = [
			0,
			TileSetAtlasSource.TRANSFORM_FLIP_H,
			]
		return transforms[randi() % transforms.size()]
	var transforms = [
		0,
		TileSetAtlasSource.TRANSFORM_FLIP_H,
		TileSetAtlasSource.TRANSFORM_FLIP_V,
		TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	]
	return transforms[randi() % transforms.size()]

func spawn_initial_objects():
	var ponds_needed = 3
	var current_ponds
	var regenerate = true
	var grass_tiles = [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)]
	
	while regenerate:
		current_ponds = 0
		tile_map.clear_layer(1)
		for x in range(10):
			for y in range(1,100):
				# Generowanie trawy
				tile_map.set_cell(0, Vector2i(x, y), 0, grass_tiles.pick_random(), get_random_transform())
				
				if y > 97:
					continue
				if y >= 25:  # Generowanie jeziorek od 25 rzędu w dół
					if randf() < POND_CHANCE and is_space_for_pond(x, y):
						spawn_pond(x, y)
						current_ponds += 1
						if current_ponds >= ponds_needed:
							regenerate = false
					elif randf() < BEE_CHANCE and is_space_free(x, y):
						spawn_bee(x, y)
					elif randf() < TREE_CHANCE and is_space_for_tree(x, y):
						spawn_tree(x, y)
				else:
					if randf() < BEE_CHANCE and is_space_free(x, y):
						spawn_bee(x, y)
					elif randf() < TREE_CHANCE and is_space_for_tree(x, y):
						spawn_tree(x, y)
			spawn_tree(x, 100)

	
	
	#for x in range(10):
		#for y in range(1,100):
			#tile_map.set_cell(0, Vector2i(x, y), 0, tiles_list.pick_random(), get_random_transform())
			#
	#for x in range(10):
		#for y in range(1,98):
			#if randf() < TREE_CHANCE and is_space_for_tree(x, y):
				#spawn_tree(x, y)
		#spawn_tree(x, 100)
	## Spawn pszczół
	#for x in range(10):
		#for y in range(1, 99):
			#if randf() < BEE_CHANCE and is_space_free(x, y):
				#spawn_bee(x, y)

func is_space_for_pond(x: int, y: int) -> bool:
	for dx in range(3):
		for dy in range(3):
			if tile_map.get_cell_source_id(1, Vector2i(x + dx, y + dy)) != -1 and tile_map.get_cell_source_id(0, Vector2i(x + dx, y + dy)) == -1:
				return false
	return true

func spawn_pond(x: int, y: int):
	for dx in range(3):
		for dy in range(3):
			var pond_tile = Vector2i(dx, dy + 1)  # +1 because pond tiles start from 0,1 to 2,3
			tile_map.set_cell(1, Vector2i(x + dx, y + dy), POND_SOURCE_ID, pond_tile)

func is_space_free(x: int, y: int) -> bool:
	return tile_map.get_cell_source_id(1, Vector2i(x, y)) == -1

func spawn_bee(x: int, y: int):
	var bee_instance = bee_scene.instantiate()
	bee_instance.position = tile_map.map_to_local(Vector2i(x, y))
	bee_container.add_child(bee_instance)

func is_space_for_tree(x: int, y: int) -> bool:
	return tile_map.get_cell_source_id(1, Vector2i(x, y)) == -1 and \
		   tile_map.get_cell_source_id(1, Vector2i(x, y-1)) == -1

func spawn_tree(x: int, y: int):
	var tree_source_id = 3
	tile_map.set_cell(1, Vector2i(x, y), tree_source_id, Vector2i(4, 1), get_random_transform(true))
	tile_map.set_cell(1, Vector2i(x, y-1), tree_source_id, Vector2i(4, 0), get_random_transform(true))
	
#func update_season():
	#var current_season = GlobalGameState.current_season
	## Zmiana tła i obiektów w zależności od pory roku
#
#func update_ui():
	#ui.update_energy(GlobalGameState.bear_energy)
	#ui.update_food(GlobalGameState.collected_food)
	#ui.update_season(GlobalGameState.seasons[GlobalGameState.current_season])
