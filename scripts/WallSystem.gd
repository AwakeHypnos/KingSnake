extends Node2D

var soldiers: Array[Node2D] = []
var attack_timer: float = 0.0
var spawn_timer: float = 0.0
var soldier_scene: PackedScene

var wall_width: float = 540.0
var wall_height: float = 100.0

func _ready():
	soldier_scene = preload("res://scenes/Soldier.tscn")
	_setup_wall_visual()
	_initialize_soldiers()
	GameManager.set_wall_system(self)

func _setup_wall_visual():
	var wall_rect = ColorRect.new()
	wall_rect.color = Color.BROWN
	wall_rect.size = Vector2(wall_width, wall_height)
	wall_rect.position = Vector2(0, 0)
	add_child(wall_rect)
	
	var wall_label = Label.new()
	wall_label.text = "城墙"
	wall_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wall_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wall_label.anchors_preset = Control.PRESET_FULL_RECT
	wall_label.add_theme_font_size_override("font_size", 28)
	wall_label.modulate = Color.WHITE
	wall_rect.add_child(wall_label)

func _initialize_soldiers():
	_add_soldier(0)

func _add_soldier(index: int):
	var soldier: Node2D
	if soldier_scene:
		soldier = soldier_scene.instantiate()
	else:
		soldier = _create_basic_soldier()
	
	var spacing = wall_width / 6.0
	var x_pos = spacing * (index + 1)
	soldier.position = Vector2(x_pos, wall_height - 50)
	
	add_child(soldier)
	soldiers.append(soldier)

func _create_basic_soldier() -> Node2D:
	var soldier = Node2D.new()
	soldier.set_script(preload("res://scripts/Soldier.gd"))
	
	var visual = ColorRect.new()
	visual.color = Color.RED
	visual.size = Vector2(40, 60)
	visual.position = Vector2(-20, -30)
	soldier.add_child(visual)
	
	var label = Label.new()
	label.text = "兵"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchors_preset = Control.PRESET_FULL_RECT
	label.modulate = Color.WHITE
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
	
	if not GameManager.giant_snake:
		return
	
	var targets = GameManager.giant_snake.get_segments_to_attack()
	
	if targets.is_empty():
		return
	
	for i in range(min(soldiers.size(), targets.size())):
		var soldier = soldiers[i]
		var target = targets[i]
		
		if soldier.has_method("attack"):
			soldier.attack(target, GameManager.SOLDIER_INITIAL_DAMAGE)

func _spawn_new_soldier():
	if soldiers.size() < 5:
		_add_soldier(soldiers.size())
