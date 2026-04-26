class_name Soldier
extends Node2D

var arrow_scene: PackedScene

func _ready():
	arrow_scene = preload("res://scenes/Arrow.tscn")

func attack(target: SnakeSegment, damage: int):
	_shoot_arrow(target, damage)

func _shoot_arrow(target: SnakeSegment, damage: int):
	if target == null:
		return
	
	var arrow: Node2D
	if arrow_scene != null:
		arrow = arrow_scene.instantiate()
	else:
		arrow = _create_basic_arrow()
	
	if arrow.has_method("set_target"):
		arrow.set("target", target)
	if arrow.has_method("set_damage"):
		arrow.set("damage", damage)
	arrow.set("target", target)
	arrow.set("damage", damage)
	arrow.position = global_position
	
	get_tree().root.add_child(arrow)

func _create_basic_arrow() -> Node2D:
	var arrow = Node2D.new()
	arrow.set_script(preload("res://scripts/Arrow.gd"))
	
	var visual = ColorRect.new()
	visual.color = Color(0.5, 0.5, 0.5, 1.0)
	visual.size = Vector2(10.0, 30.0)
	visual.position = Vector2(-5.0, -15.0)
	arrow.add_child(visual)
	
	return arrow
