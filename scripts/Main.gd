extends Node2D
@onready var bear = $Bear
@onready var bear_camera = $Bear/BearCamera
@onready var tile_map: TileMap = $WorldTileMap
@onready var bee_container = $BeeContainer
@onready var hunter_container = $HunterContainer
@onready var beehive_container = $Beehivecontainer
@onready var fish_container = $FishContainer
@onready var music_player = $BackgroundMusic

@onready var score_scene = $Bear/Score/CanvasLayer
var bee_scene = preload("res://scenes/Bee.tscn")
var hunter_scene = preload("res://scenes/Hunter.tscn")
var beehive_scene = preload("res://scenes/Beehive.tscn")
const POND_SOURCE_ID = 0
const POND_CHANCE = 0.003
const HUNTER_CHANCE = 0.004
const BEE_CHANCE = 0.005
const TREE_CHANCE = 0.1

var game_over = false
var paused = false
var current_season = 0  # 0: Spring, 1: Summer, 2: Autumn, 3: Winter
var seasons = ["spring", "summer", "autumn", "winter"]
var season_duration = 60  # 1 minutes per season
var season_time = 0
var bear_energy = 100
var collected_food = 0
var current_score = INF
@onready var hud = $"Bear/HUD"
@onready var beehive_display = $CollectablesDisplayManager

var scores = {
	0: 0,
	1: 0,
	2: 0,
}

var season_requirements = {
	"spring" : {"beehive": 1, "fish": 2},
	"summer" : {"beehive": 2, "fish": 3},
	"autumn" : {"beehive": 3, "fish": 4},
	#"winter" : {"beehive": 0, "fish": 0},
	#"spring" : {"beehive": 3, "fish": 2},
	#"summer" : {"beehive": 4, "fish": 3},
	#"autumn" : {"beehive": 5, "fish": 4}
} # for now, enemies will be in the same numbers as collectables
const BEEHIVE_CHANCE = 0.02
const FISH_CHANCE = 0.02
var CollectablesDisplayManager = preload("res://scenes/CollectablesDisplayManager.tscn")

func start_season(season):
	current_score = INF
	tile_map.change_season(season)
	spawn_display(season)
	spawn_enemies(season)
	spawn_collecables(season)
	if season == 2:
		bear_camera.get_node("Rain").show()
	if season == 3:
		bear_camera.get_node("Rain").hide()
		bear_camera.get_node("Snow").show()
		bear.position = tile_map.map_to_local(Vector2(5, 99))
		print(bear)
		game_over = true
		bear.set_game_over(true)
	music_player.start_music(season)

func spawn_display(season):
	# Usuń istniejący display, jeśli istnieje
	if beehive_display:
		beehive_display.queue_free()
	# Stwórz nowy display
	if season == 3:
		return
	beehive_display = CollectablesDisplayManager.instantiate()
	# Ustaw pozycję (dostosuj według potrzeb)
	beehive_display.position = Vector2(0, 0)
	# Dodaj do sceny
	add_child(beehive_display)
	# Inicjalizuj z odpowiednią liczbą uli dla danego sezonu
	var how_much_beehive = season_requirements[seasons[season]]["beehive"]
	beehive_display.initialize(how_much_beehive)
	# Opcjonalnie: wymusz aktualizację wyświetlania
	#beehive_display.update()

func _ready():
	score_scene.hide()
	spawn_initial_objects()
	start_season(current_season)
	bear.connect("game_over", Callable(self, "_on_game_over"))
	$DropPlace.connect("body_entered", Callable(self, "_on_drop_place_entered"))

func _on_drop_place_entered(body):
	if body.is_in_group("bear"):
		if game_over:
			var end_game_scene = load("res://scenes/EndGame.tscn").instantiate()
			var score = scores[0] + scores[1] + scores[2]
			end_game_scene.set_score(score)  # Zakładając, że masz zmienną 'score'
			get_tree().root.add_child(end_game_scene)
			get_tree().current_scene.queue_free()
		if body.has_collectable == true:
			beehive_display.add_beehive()
			collected_food += 1
			bear.drop_stuff()
		
	
	

func _on_game_over():
	pass
	
func show_score():
	var sum = scores[0] + scores[1] + scores [2]
	if scores[0] != 0:
		score_scene.get_node("Spring").show()
		score_scene.get_node("SpringScore").show()
		score_scene.update_score("SpringScore", scores[0])
	if scores[1] != 0:
		score_scene.get_node("Summer").show()
		score_scene.get_node("SummerScore").show()
		score_scene.update_score("SummerScore", scores[1])
	if scores[2] != 0:
		score_scene.get_node("Autumn").show()
		score_scene.get_node("AutumnScore").show()
		score_scene.update_score("AutumnScore", scores[2])
	if sum != 0:
		score_scene.get_node("Total").show()
		score_scene.get_node("TotalScore").show()
		score_scene.update_score("TotalScore", sum)
	score_scene.show()
	
func _process(delta):
	if game_over:
		var sum = scores[0] + scores[1] + scores [2]
		hud.update_timer("Slide to home")
	else:
		season_time += delta
		if current_score > 0:
			current_score = season_duration - season_time
			hud.update_timer(current_score)
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
	if not game_over: 
		if collected_food == season_requirements[seasons[current_season]]["beehive"]:
			scores[current_season] = int(current_score)
			collected_food = 0
			hud.hide()
			show_score()
			paused = true
			Engine.time_scale = 0
		
	if Input.is_action_just_pressed("ui_select") and paused:
		current_season += 1
		season_time = 0
		score_scene.hide()
		start_season(0)
		start_season(current_season)
		hud.show()
		paused = false
		Engine.time_scale = 1

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
					elif randf() < TREE_CHANCE and is_space_for_tree(x, y):
						spawn_tree(x, y)
				elif y>1:
					if randf() < TREE_CHANCE and is_space_for_tree(x, y):
						spawn_tree(x, y)
			spawn_tree(x, 100)

func spawn_enemies(season):
	if season == 3:
		clear_enemies()
		return
	var how_much_bee = season_requirements[seasons[season]]["beehive"]
	var how_much_hunter = season_requirements[seasons[season]]["fish"]
	var current_bee = 0
	var current_hunter = 0
	var regenerate = true
	while regenerate:
		clear_enemies()
		current_bee = 0
		current_hunter = 0 
		for x in range(10):
			for y in range(1,100):
				if regenerate and randf() < HUNTER_CHANCE and is_space_free(x, y):
					if current_hunter < how_much_hunter:
						spawn_hunter(x, y)
						current_hunter += 1
						print("spawned hunter: ", current_hunter)
				elif regenerate and randf() < BEE_CHANCE and is_space_free(x, y):
					if current_bee < how_much_bee:
						spawn_bee(x, y)
						current_bee += 1
				if (current_hunter == how_much_hunter) and (current_bee == how_much_bee):
					regenerate = false
	
func spawn_collecables(season):
	if season == 3:
		clear_collecables()
		return
	var how_much_beehive = season_requirements[seasons[season]]["beehive"]
	var current_beehive = 0
	var how_much_fish = season_requirements[seasons[season]]["fish"]
	var regenerate = true
	while regenerate:
		clear_collecables()
		current_beehive = 0
		for x in range(10):
			for y in range(1,100):
				if regenerate and randf() < BEEHIVE_CHANCE and is_space_free(x, y):
					spawn_collecable("beehive", x, y)
					current_beehive += 1
					if current_beehive == how_much_beehive:
						regenerate = false

func spawn_collecable(type, x, y):
	if type == "beehive":
		var beehive_instance = beehive_scene.instantiate()
		beehive_instance.position = tile_map.map_to_local(Vector2i(x, y))
		beehive_container.add_child(beehive_instance)

func clear_collecables():
	for beehive in beehive_container.get_children():
		beehive.queue_free()
	for fish in fish_container.get_children():
		fish.queue_free()

func is_space_for_pond(x: int, y: int) -> bool:
	for dx in range(-2, 5):  # Zwiększamy zakres sprawdzania
		for dy in range(-2, 5):
			if x + dx < 0 or x + dx >= 10 or y + dy < 0 or y + dy >= 100:
				continue  # Pomijamy pola poza mapą
			if tile_map.get_cell_source_id(1, Vector2i(x + dx, y + dy)) != -1:
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
	

