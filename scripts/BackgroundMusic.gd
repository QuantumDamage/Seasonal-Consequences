extends AudioStreamPlayer
var path

func start_music(season):
	# Ładowanie pliku audio
	if season == 0:
		path = "res://assets/fsm-team-escp-early-bird.mp3"
	elif season == 1:
		path = "res://assets/surf-house-productions-endless-summer.mp3"
	elif season == 2:
		path = "res://assets/vlad-gluschenko-autumn-walk.mp3"
	else:
		path = "res://assets/alex-productions-winter-spa.mp3"
	var music = load(path)
	if music:
		self.stream = music
		self.autoplay = true
		self.play()
	else:
		print("Nie można załadować pliku audio")
