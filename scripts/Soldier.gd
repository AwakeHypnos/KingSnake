extends Node2D

var arrow_scene: PackedScene

func _ready():
	arrow_scene = preload("res://scenes/Arrow.tscn")

func attack(target: SnakeSegment, damage: int):
	_shoot_arrow(target, damage)

func _shoot_arrow(target: SnakeSegment, damage: int):
	if not target:
		return
	
	var arrow: Node2D
	if arrow_scene:
		arrow = arrow_scene.instantiate()
	else:
		arrow = _create_basic_arrow()
	
	arrow.set("target", target)
	arrow.set("damage", damage)
	arrow.position = global_position
	
	get_tree().root.add_child(arrow)

func _create_basic_arrow() -> Node2D:
	var arrow = Node2D.new()
	arrow.set_script(preload("res://scripts/Arrow.gd"))
	
	var visual = ColorRect.new()
	visual.color = Color.GRAY
	visual.size = Vector2(10, 30)
	visual.position = Vector2(-5, -15)
	arrow.add_child(visual)
	
	return arrow
