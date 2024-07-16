extends Node2D
@onready var bear = $Bear
@onready var tile_map: TileMap = $WorldTileMap
@onready var bee_container = $BeeContainer
@onready var hunter_container = $HunterContainer

var bee_scene = preload("res://scenes/Bee.tscn")
var hunter_scene = preload("res://scenes/Hunter.tscn")
const POND_SOURCE_ID = 0
const POND_CHANCE = 0.003
const HUNTER_CHANCE = 0.004
const BEE_CHANCE = 0.005
const TREE_CHANCE = 0.1

var current_season = 0  # 0: Spring, 1: Summer, 2: Autumn, 3: Winter
var seasons = ["Spring", "Summer", "Autumn", "Winter"]
var season_duration = 60  # 1 minutes per season
var season_time = 0
var bear_energy = 100
var collected_food = 0
var current_score = 0
@onready var hud = $"Bear/HUD"

var season_requirements = {
	"spring" : {"honey": 3, "fish": 2},
	"summer" : {"honey": 4, "fish": 3},
	"autumn" : {"honey": 5, "fish": 4}
} # for now, enemies will be in the same numbers as collectables

func _ready():
	spawn_initial_objects()
	spawn_enemies(0)
	spawn_collecables(0)
	bear.connect("game_over", Callable(self, "_on_game_over"))

func _on_game_over():
	pass

func _process(delta):
	season_time += delta
	current_score = season_duration - season_time
	hud.update_timer(current_score)
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func get_random_transform(horizontal_only=false) -> int:
	var transforms
	if horizontal_only:
		transforms = [
			0,
			TileSetAtlasSource.TRANSFORM_FLIP_H,
			]
		return transforms[randi() % transforms.size()]
	transforms = [
		0,
		TileSetAtlasSource.TRANSFORM_FLIP_H,
		TileSetAtlasSource.TRANSFORM_FLIP_V,
		TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	]
	return transforms[randi() % transforms.size()]

func clear_enemies():
	for bee in bee_container.get_children():
		bee.queue_free()
	for hunter in hunter_container.get_children():
		hunter.queue_free()

func spawn_initial_objects():
	var ponds_needed = 3
	var current_ponds
	var regenerate = true
	var grass_tiles = [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)]
	
	while regenerate:
		current_ponds = 0
		tile_map.clear_layer(1)
		clear_enemies()
		for x in range(10):
			for y in range(1,100):
				# Generowanie trawy
				tile_map.set_cell(0, Vector2i(x, y), 0, grass_tiles.pick_random(), get_random_transform())
				
				if y > 96:
					continue
				elif y >= 15:  # Generowanie jeziorek od 25 rzędu w dół
					if randf() < POND_CHANCE and is_space_for_pond(x, y):
						spawn_pond(x, y)
						current_ponds += 1
						if current_ponds >= ponds_needed:
							regenerate = false
					elif randf() < HUNTER_CHANCE and is_space_free(x,y):
						spawn_hunter(x,y) 
					elif randf() < BEE_CHANCE and is_space_free(x, y):
						spawn_bee(x, y)
					elif randf() < TREE_CHANCE and is_space_for_tree(x, y):
						spawn_tree(x, y)
				elif y>1:
					if randf() < BEE_CHANCE and is_space_free(x, y):
						spawn_bee(x, y)
					elif randf() < TREE_CHANCE and is_space_for_tree(x, y):
						spawn_tree(x, y)
			spawn_tree(x, 100)

func spawn_enemies(season):
	pass

func spawn_collecables(season):
	pass

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

func spawn_hunter(x: int, y: int):
	var hunter_instance = hunter_scene.instantiate()
	hunter_instance.position = tile_map.map_to_local(Vector2i(x, y))
	hunter_container.add_child(hunter_instance)

func is_space_for_tree(x: int, y: int) -> bool:
	return tile_map.get_cell_source_id(1, Vector2i(x, y)) == -1 and \
		   tile_map.get_cell_source_id(1, Vector2i(x, y-1)) == -1

func spawn_tree(x: int, y: int):
	var tree_source_id = 3
	tile_map.set_cell(1, Vector2i(x, y), tree_source_id, Vector2i(4, 1), get_random_transform(true))
	tile_map.set_cell(1, Vector2i(x, y-1), tree_source_id, Vector2i(4, 0), get_random_transform(true))
	

