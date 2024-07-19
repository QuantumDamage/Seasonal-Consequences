extends CharacterBody2D

var speed = 150
var ice_speed = 100  # Prędkość na lodzie
var slide_friction = 0.98  # Współczynnik tarcia dla efektu ślizgania
var ice_acceleration = 500  # Przyspieszenie na lodzie
var bounce_factor = 0.5  # Współczynnik odbicia

@onready var sprite = $Sprite2D

signal game_over

var has_collectable = false
var collectable
var is_game_over = false

func pickup_beehive():
	if not has_collectable:
		has_collectable = true
		collectable = "beehive"
		update_appearance(collectable)
		return true
	else:
		print("Can't carry any more stuff")
		return false

func drop_stuff():
	update_appearance("none")
	has_collectable = false

func update_appearance(thing):
	if thing == "beehive":
		$Beehive.visible = true
	if thing == "none":
		$Beehive.visible = false

func set_game_over(value):
	is_game_over = value

func _physics_process(delta):
	var input_vector = get_input_vector()
	
	if not is_game_over:
		normal_movement(input_vector)
	else:
		ice_movement(input_vector, delta)
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#var collider = collision.get_collider()
		#if collider.is_in_group("Enemies"):
			#emit_signal("game_over")
			#set_game_over(true)
		if is_game_over:
			bounce(collision.get_normal())
	
	update_sprite_direction()

func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	return input_vector.normalized() if input_vector.length() > 0 else input_vector

func normal_movement(input_vector):
	velocity = input_vector * speed

func ice_movement(input_vector, delta):
	# Aplikuj "tarcie" do aktualnej prędkości
	velocity *= slide_friction
	
	# Dodaj przyspieszenie w kierunku inputu
	velocity += input_vector * ice_acceleration * delta
	
	# Ogranicz maksymalną prędkość
	velocity = velocity.limit_length(ice_speed)

func bounce(collision_normal):
	# Odbij prędkość względem normalnej kolizji
	velocity = velocity.bounce(collision_normal) * bounce_factor

func update_sprite_direction():
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false
