extends CanvasLayer

func update_timer(value):
	if value is String:
		$Label.text = value
		return
	$Label.text = str(int(value))
