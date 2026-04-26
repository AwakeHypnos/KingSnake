class_name SnakeSegment
extends Area2D

@export var hp: int = 7
@export var max_hp: int = 7
@export var segment_index: int = 0

var hp_label: Label
var segment_sprite: ColorRect

signal destroyed
signal hp_changed(new_hp: int)

func _ready():
	_setup_visuals()
	_setup_collision()

func _setup_visuals():
	segment_sprite = ColorRect.new()
	segment_sprite.color = Color(0.09, 0.47, 0.13, 1.0)
	segment_sprite.size = Vector2(GameManager.SEGMENT_WIDTH, GameManager.SEGMENT_HEIGHT)
	add_child(segment_sprite)
	
	hp_label = Label.new()
	hp_label.text = str(hp)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_label.anchors_preset = Control.PRESET_FULL_RECT
	hp_label.add_theme_font_size_override("font_size", 24)
	hp_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	add_child(hp_label)

func _setup_collision():
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(GameManager.SEGMENT_WIDTH - 2.0, GameManager.SEGMENT_HEIGHT - 2.0)
	collision.shape = shape
	add_child(collision)
	
	collision_layer = 1
	collision_mask = 16

func set_hp(new_hp: int):
	hp = clampi(new_hp, 0, max_hp)
	hp_label.text = str(hp)
	hp_changed.emit(hp)
	
	if hp <= 0:
		destroy()

func take_damage(damage: int):
	set_hp(hp - damage)

func heal(amount: int):
	set_hp(hp + amount)

func destroy():
	destroyed.emit()
	queue_free()

func set_index(index: int):
	segment_index = index

func set_as_head():
	segment_sprite.color = Color(0.0, 0.8, 0.2, 1.0)

func set_as_body():
	segment_sprite.color = Color(0.09, 0.47, 0.13, 1.0)
