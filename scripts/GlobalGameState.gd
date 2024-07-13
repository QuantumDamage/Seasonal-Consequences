extends Node

var current_season = 0  # 0: Spring, 1: Summer, 2: Autumn, 3: Winter
var seasons = ["Spring", "Summer", "Autumn", "Winter"]
var season_duration = 180  # 3 minutes per season
var game_time = 0
var bear_energy = 100
var collected_food = 0

func _process(delta):
	game_time += delta
	current_season = int(game_time / season_duration) % 4
	if bear_energy <= 0:
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
