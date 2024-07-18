extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("bear"):
		# Logika podnoszenia ula
		if body.pickup_beehive():  # Wywołaj metodę podnoszenia na Bear
			queue_free()  # Usuń ul ze sceny
		
