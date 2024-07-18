extends TileMap
var seasons = 0
var current_season = 0  # 0: wiosna, 1: lato, 2: jesień, 3: zima

func _ready():
	material.set_shader_parameter("season", current_season)

func change_season(new_season):
	current_season = new_season
	material.set_shader_parameter("season", current_season)
	
func _process(_delta):

	if Input.is_action_just_pressed("pora_roku"):
		seasons += 1
		print("pora_roku", seasons % 4)
		change_season(seasons)
