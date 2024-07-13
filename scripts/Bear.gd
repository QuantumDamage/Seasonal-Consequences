extends CharacterBody2D
var speed = 200
@onready var sprite = $Sprite2D

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	  
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()

		if input_vector.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	
	velocity = input_vector * speed
	move_and_slide()
