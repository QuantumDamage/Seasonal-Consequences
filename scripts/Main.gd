extends Node2D

@onready var bear = $Bear
@onready var food_container = $FoodContainer
@onready var obstacle_container = $ObstacleContainer
@onready var enemy_container = $EnemyContainer
@onready var ui = $UI
@onready var tile_map: TileMap = $TileMap
const TREE_CHANCE = 0.1  # 10% szans na wygenerowanie drzewa na każdym kafelku
@onready var bee_container = $BeeContainer
var bee_scene = preload("res://scenes/Bee.tscn")
const BEE_CHANCE = 0.05  # 5% szans na wygenerowanie pszczoły na każdym wolnym kafelku
#var food_scene = preload("res://scenes/Food.tscn")
#var obstacle_scene = preload("res://scenes/Obstacle.tscn")
#var enemy_scene = preload("res://scenes/Enemy.tscn")

func _ready():
	spawn_initial_objects()

func _process(delta):
	pass
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
	var tiles_list = [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)]
	for x in range(10):
		for y in range(1,100):
			tile_map.set_cell(0, Vector2i(x, y), 0, tiles_list.pick_random(), get_random_transform())
			
	for x in range(10):
		for y in range(1,99):
			if randf() < TREE_CHANCE and is_space_for_tree(x, y):
				spawn_tree(x, y)
				
	# Spawn pszczół
	for x in range(10):
		for y in range(1, 99):
			if randf() < BEE_CHANCE and is_space_free(x, y):
				spawn_bee(x, y)

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
