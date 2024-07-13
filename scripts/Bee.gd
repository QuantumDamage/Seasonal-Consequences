extends CharacterBody2D

@export var speed = 50.0
@export var patrol_distance = 160  # Szerokość ekranu

var direction = Vector2.RIGHT
var start_position: Vector2

func _ready():
	start_position = global_position

func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		direction *= -1  # Zmień kierunek po kolizji
	
	## Sprawdź, czy pszczoła osiągnęła koniec patrolu
	#if abs(global_position.x - start_position.x) >= patrol_distance:
		#direction *= -1

	# Obróć sprite'a w kierunku ruchu
	$Sprite2D.flip_h = direction.x < 0
