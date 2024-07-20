extends CharacterBody2D

@export var speed = 50.0
@export var hunting_speed = 60.0
@export var movement_radius = 80.0
@export var flee_duration = 3.0
@export var flee_cooldown = 5.0

var target_position: Vector2
var start_position: Vector2
var stuck_timer: float = 0.0
var stuck_threshold: float = 1.0
var is_hunting = false
var bear: Node2D
var flee_timer: float = 0.0
var flee_cooldown_timer: float = 0.0
var is_fleeing = false

func _ready():
	start_position = global_position
	choose_new_target()
	$HuntingArea.connect("body_entered", Callable(self, "_on_HuntingArea_body_entered"))
	$HuntingArea.connect("body_exited", Callable(self, "_on_HuntingArea_body_exited"))

func _physics_process(delta):
	if is_fleeing:
		flee(delta)
	elif is_hunting:
		hunt(delta)
	else:
		wander(delta)
	
	move_and_slide()
	
	if $Sprite2D:
		$Sprite2D.flip_h = velocity.x < 0

func hunt(delta):
	target_position = bear.global_position
	speed = hunting_speed
	
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	
	flee_cooldown_timer += delta
	if flee_cooldown_timer >= flee_cooldown:
		start_fleeing()

func wander(delta):
	speed = 50.0
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	
	if get_slide_collision_count() > 0:
		stuck_timer += delta
		if stuck_timer >= stuck_threshold:
			choose_new_target()
	else:
		stuck_timer = 0.0
	
	if global_position.distance_to(target_position) < 5:
		choose_new_target()

func flee(delta):
	flee_timer += delta
	if flee_timer >= flee_duration:
		stop_fleeing()
	else:
		var flee_direction = (global_position - bear.global_position).normalized()
		velocity = flee_direction * hunting_speed

func start_fleeing():
	is_fleeing = true
	flee_timer = 0.0
	flee_cooldown_timer = 0.0
	# Tutaj dodaj wywołanie dźwięku "roar"
	if $RoarSound:
		$RoarSound.play()

func stop_fleeing():
	is_fleeing = false
	is_hunting = false
	choose_new_target()

func choose_new_target():
	var random_offset = Vector2(randf_range(-movement_radius, movement_radius),
								randf_range(-movement_radius, movement_radius))
	target_position = start_position + random_offset
	stuck_timer = 0.0

func _on_HuntingArea_body_entered(body):
	if body.name == "Bear":
		is_hunting = true
		bear = body

func _on_HuntingArea_body_exited(body):
	if body.name == "Bear":
		is_hunting = false
		choose_new_target()
