extends Node2D

var BEEHIVE_SLOTS = 3  # Domyślna wartość, może być zmieniona przy inicjalizacji
const SLOT_SIZE = 16  # Zmniejszone do 32, bo oryginalna tekstura ma 16x16

var collected_beehives = 0
var beehive_slots = []

var beehive_texture = preload("res://assets/town_packed_converted.png")

func initialize(n: int):
	BEEHIVE_SLOTS = n
	for i in range(BEEHIVE_SLOTS):
		var slot = Sprite2D.new()
		slot.texture = beehive_texture
		slot.region_enabled = true
		slot.region_rect = Rect2(160, 112, 16, 16)  # Zakładając, że to są poprawne koordynaty dla tekstury ula
		slot.position = Vector2(i * SLOT_SIZE + 8, 8)
		slot.modulate = Color(1, 1, 1, 0.3)  # Prawie przezroczysty
		add_child(slot)
		beehive_slots.append(slot)

func add_beehive():
	if collected_beehives < BEEHIVE_SLOTS:
		beehive_slots[collected_beehives].modulate = Color(1, 1, 1, 1)  # Pełna nieprzezroczystość
		collected_beehives += 1

