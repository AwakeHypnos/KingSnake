class_name WallSystem
extends Node2D

var soldiers: Array[Node2D] = []
var attack_timer: float = 0.0
var spawn_timer: float = 0.0
var soldier_scene: PackedScene

const wall_width: float = 540.0
const wall_height: float = 100.0

func _ready():
	soldier_scene = preload("res://scenes/Soldier.tscn")
	_setup_wall_visual()
	_initialize_soldiers()
	GameManager.set_wall_system(self)

func _setup_wall_visual():
	var wall_rect = ColorRect.new()
	wall_rect.color = Color(0.6, 0.4, 0.2, 1.0)
	wall_rect.size = Vector2(wall_width, wall_height)
	wall_rect.position = Vector2(0.0, 0.0)
	add_child(wall_rect)
	
	var wall_label = Label.new()
	wall_label.text = "城墙"
	wall_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wall_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wall_label.anchors_preset = Control.PRESET_FULL_RECT
	wall_label.add_theme_font_size_override("font_size", 28)
	wall_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	wall_rect.add_child(wall_label)

func _initialize_soldiers():
	_add_soldier(0)

func _add_soldier(index: int):
	var soldier: Node2D
	if soldier_scene != null:
		soldier = soldier_scene.instantiate()
	else:
		soldier = _create_basic_soldier()
	
	var spacing = wall_width / 6.0
	var x_pos = spacing * (index + 1)
	soldier.position = Vector2(x_pos, wall_height - 50.0)
	
	add_child(soldier)
	soldiers.append(soldier)

func _create_basic_soldier() -> Node2D:
	var soldier = Node2D.new()
	soldier.set_script(preload("res://scripts/Soldier.gd"))
	
	var visual = ColorRect.new()
	visual.color = Color(1.0, 0.2, 0.2, 1.0)
	visual.size = Vector2(40.0, 60.0)
	visual.position = Vector2(-20.0, -30.0)
	soldier.add_child(visual)
	
	var label = Label.new()
	label.text = "兵"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchors_preset = Control.PRESET_FULL_RECT
	label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	visual.add_child(label)
	
	return soldier

func _process(delta: float):
	if not GameManager.is_playing():
		return
	
	attack_timer += delta
	spawn_timer += delta
	
	if attack_timer >= GameManager.SOLDIER_ATTACK_INTERVAL:
		attack_timer = 0.0
		_attack()
	
	if spawn_timer >= GameManager.SOLDIER_SPAWN_INTERVAL:
		spawn_timer = 0.0
		_spawn_new_soldier()

func _attack():
	if soldiers.is_empty():
		return
	
	if GameManager.giant_snake == null:
		return
	
	if not GameManager.giant_snake.has_method("get_segments_to_attack"):
		return
	
	var targets = GameManager.giant_snake.get_segments_to_attack()
	
	if targets.is_empty():
		return
	
	for i in range(mini(soldiers.size(), targets.size())):
		var soldier = soldiers[i]
		var target = targets[i]
		
		if soldier.has_method("attack"):
			soldier.attack(target, GameManager.SOLDIER_INITIAL_DAMAGE)

func _spawn_new_soldier():
	if soldiers.size() < 5:
		_add_soldier(soldiers.size())
