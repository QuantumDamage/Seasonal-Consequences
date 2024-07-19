extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("ui_select"):
		get_tree().quit()


var score = 0

func _ready():
	$CanvasLayer/Label2.text = str(score)
	print("Dddddddddddddddddddddddddddd")

func set_score(new_score):
	score = new_score
	if $CanvasLayer/Label2:
		$CanvasLayer/Label2.text = str(score)
