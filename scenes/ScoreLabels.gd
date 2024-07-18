extends CanvasLayer

func update_score(label, value):
	self.get_node(label).text = str(value)
