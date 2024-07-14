extends CharacterBody2D

@export var speed = 50.0
@export var movement_radius = 80.0

var target_position: Vector2
var start_position: Vector2
var stuck_timer: float = 0.0
var stuck_threshold: float = 1.0  # Czas w sekundach, po którym obiekt uznaje się za zaklinowany

func _ready():
	start_position = global_position
	choose_new_target()
	#print("Start position: ", start_position)

func _physics_process(delta):
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	
	#print("Current position: ", global_position)
	#print("Target position: ", target_position)
	#print("Velocity: ", velocity)
	
	move_and_slide()
	
	if get_slide_collision_count() > 0:
		stuck_timer += delta
		#print("Collision detected, stuck timer: ", stuck_timer)
		if stuck_timer >= stuck_threshold:
			choose_new_target()
	else:
		stuck_timer = 0.0
	
	if global_position.distance_to(target_position) < 5:  # Jeśli obiekt jest blisko celu
		#print("Reached target, choosing new one")
		choose_new_target()
	
	if $Sprite2D:
		$Sprite2D.flip_h = velocity.x < 0

func choose_new_target():
	var random_offset = Vector2(randf_range(-movement_radius, movement_radius),
								randf_range(-movement_radius, movement_radius))
	target_position = start_position + random_offset
	stuck_timer = 0.0
	#print("New target chosen: ", target_position)
