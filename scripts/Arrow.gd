class_name Arrow
extends Area2D

@export var speed: float = 600.0
var target: SnakeSegment = null
var damage: int = 2
var direction: Vector2 = Vector2.DOWN

var arrow_sprite: ColorRect

func _ready():
	_setup_visual()
	_setup_collision()
	
	if target != null:
		direction = (target.global_position - global_position).normalized()
		look_at(target.global_position)

func _setup_visual():
	arrow_sprite = ColorRect.new()
	arrow_sprite.color = Color(0.5, 0.5, 0.5, 1.0)
	arrow_sprite.size = Vector2(8.0, 25.0)
	arrow_sprite.position = Vector2(-4.0, -12.5)
	add_child(arrow_sprite)

func _setup_collision():
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(8.0, 25.0)
	collision.shape = shape
	add_child(collision)
	
	collision_layer = 8
	collision_mask = 1

func _process(delta: float):
	if not GameManager.is_playing():
		queue_free()
		return
	
	global_position += direction * speed * delta
	
	if target != null and target.is_inside_tree():
		var distance = global_position.distance_to(target.global_position)
		if distance < 30.0:
			_hit_target()
	
	if global_position.y > GameManager.SCREEN_HEIGHT + 100.0:
		queue_free()

func _on_body_entered(body: Node2D):
	if body is SnakeSegment:
		target = body
		_hit_target()

func _hit_target():
	if target != null and target.is_inside_tree():
		target.take_damage(damage)
	
	var effect = _create_hit_effect()
	effect.position = global_position
	get_tree().root.add_child(effect)
	
	queue_free()

func _create_hit_effect() -> Node2D:
	var effect = Node2D.new()
	var timer = Timer.new()
	timer.wait_time = 0.3
	timer.one_shot = true
	timer.timeout.connect(_on_effect_timeout.bind(effect))
	effect.add_child(timer)
	timer.start()
	
	var visual = ColorRect.new()
	visual.color = Color(1.0, 0.65, 0.0, 1.0)
	visual.size = Vector2(30.0, 30.0)
	visual.position = Vector2(-15.0, -15.0)
	effect.add_child(visual)
	
	return effect

func _on_effect_timeout(effect: Node2D):
	if effect != null and effect.is_inside_tree():
		effect.queue_free()
