extends Area2D

@export var speed: float = 600.0
var target: SnakeSegment = null
var damage: int = 2
var direction: Vector2 = Vector2.DOWN

var arrow_sprite: ColorRect

func _ready():
	_setup_visual()
	_setup_collision()
	
	if target:
		direction = (target.global_position - global_position).normalized()
		look_at(target.global_position)

func _setup_visual():
	arrow_sprite = ColorRect.new()
	arrow_sprite.color = Color.GRAY
	arrow_sprite.size = Vector2(8, 25)
	arrow_sprite.position = Vector2(-4, -12.5)
	add_child(arrow_sprite)

func _setup_collision():
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(8, 25)
	collision.shape = shape
	add_child(collision)
	
	collision_layer = 8
	collision_mask = 1

func _process(delta: float):
	if not GameManager.is_playing():
		queue_free()
		return
	
	global_position += direction * speed * delta
	
	if target and target.is_inside_tree():
		var distance = global_position.distance_to(target.global_position)
		if distance < 30:
			_hit_target()
	
	if global_position.y > GameManager.SCREEN_HEIGHT + 100:
		queue_free()

func _on_body_entered(body: Node2D):
	if body is SnakeSegment:
		target = body
		_hit_target()

func _hit_target():
	if target and target.is_inside_tree():
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
	timer.timeout.connect(func(): effect.queue_free())
	effect.add_child(timer)
	timer.start()
	
	var visual = ColorRect.new()
	visual.color = Color.ORANGE
	visual.size = Vector2(30, 30)
	visual.position = Vector2(-15, -15)
	effect.add_child(visual)
	
	return effect
