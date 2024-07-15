extends AudioStreamPlayer

func _ready():
	# Ładowanie pliku audio
	var music = load("res://assets/fsm-team-escp-early-bird.mp3")
	if music:
		self.stream = music
		self.autoplay = true
		self.play()
	else:
		print("Nie można załadować pliku audio")
