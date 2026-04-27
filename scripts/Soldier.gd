extends Node2D

var arrow_scene: PackedScene

func _ready():
	arrow_scene = preload("res://scenes/Arrow.tscn")

func attack(target: Node2D, damage: int):
	_shoot_arrow(target, damage)

func _shoot_arrow(target: Node2D, damage: int):
	if target == null:
		return
	
	var arrow: Node2D
	if arrow_scene != null:
		arrow = arrow_scene.instantiate()
	else:
		arrow = _create_basic_arrow()
	
	arrow.set("target_node", target)
	arrow.set("damage", damage)
	arrow.position = global_position
	
	get_tree().root.add_child(arrow)

func _create_basic_arrow() -> Node2D:
	var arrow = Area2D.new()
	arrow.set_script(preload("res://scripts/Arrow.gd"))
	
	var visual = ColorRect.new()
	visual.color = Color(0.5, 0.5, 0.5, 1.0)
	visual.size = Vector2(10.0, 30.0)
	visual.position = Vector2(-5.0, -15.0)
	arrow.add_child(visual)
	
	return arrow
