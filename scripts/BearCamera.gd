extends Camera2D
@onready var camera: Camera2D = $"."

func _ready():
	camera.limit_left = 0
	camera.limit_right = 160
	camera.limit_top = 0
	camera.limit_bottom = 1600
