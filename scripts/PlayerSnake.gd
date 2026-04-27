extends Node2D

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

var body: Array[Node2D] = []
var direction: int = Direction.UP
var next_direction: int = Direction.UP
var move_timer: float = 0.0
var move_interval: float = 0.2

const grid_size: float = 40.0
const area_x_offset: float = 540.0
const area_width: float = 540.0
const area_height: float = 1820.0
const area_y_offset: float = 100.0

const initial_length: int = 3
var is_alive: bool = true

var apple: Node2D = null
var segment_scene: PackedScene
var apple_scene: PackedScene

func _ready():
	segment_scene = preload("res://scenes/PlayerSegment.tscn")
	apple_scene = preload("res://scenes/Apple.tscn")
	_initialize_snake()
	_spawn_apple()
	GameManager.set_player_snake(self)

func _initialize_snake():
	var start_x = area_x_offset + area_width / 2.0
	var start_y = area_y_offset + area_height / 2.0
	
	for i in range(initial_length):
		var segment = _create_segment()
		segment.position = Vector2(start_x, start_y + i * grid_size)
		add_child(segment)
		body.append(segment)
	
	_update_head_visual()

func _create_segment() -> Node2D:
	var segment: Node2D
	if segment_scene != null:
		segment = segment_scene.instantiate()
	else:
		segment = _create_basic_segment()
	return segment

func _create_basic_segment() -> Node2D:
	var segment = Node2D.new()
	
	var visual = ColorRect.new()
	visual.color = Color(0.0, 0.0, 0.8, 1.0)
	visual.size = Vector2(grid_size - 2.0, grid_size - 2.0)
	visual.position = Vector2(-(grid_size - 2.0) / 2.0, -(grid_size - 2.0) / 2.0)
	segment.add_child(visual)
	
	return segment

func _update_head_visual():
	if body.size() > 0:
		var head = body[0]
		for child in head.get_children():
			if child is ColorRect:
				child.color = Color(0.0, 1.0, 1.0, 1.0)
	
	for i in range(1, body.size()):
		var segment = body[i]
		for child in segment.get_children():
			if child is ColorRect:
				child.color = Color(0.0, 0.0, 0.8, 1.0)

func _spawn_apple():
	if apple != null:
		apple.queue_free()
	
	var max_tries = 100
	var valid_position = false
	var apple_pos = Vector2.ZERO
	
	while not valid_position and max_tries > 0:
		max_tries -= 1
		
		var col = randi() % int(area_width / grid_size)
		var row = randi() % int(area_height / grid_size)
		
		var x = area_x_offset + col * grid_size + grid_size / 2.0
		var y = area_y_offset + row * grid_size + grid_size / 2.0
		
		apple_pos = Vector2(x, y)
		
		valid_position = true
		for segment in body:
			if segment.position.distance_to(apple_pos) < grid_size:
				valid_position = false
				break
	
	if valid_position:
		apple = _create_apple()
		apple.position = apple_pos
		get_tree().root.add_child(apple)

func _create_apple() -> Node2D:
	var apple_node: Node2D
	if apple_scene != null:
		apple_node = apple_scene.instantiate()
	else:
		apple_node = _create_basic_apple()
	return apple_node

func _create_basic_apple() -> Node2D:
	var apple_node = Node2D.new()
	
	var visual = ColorRect.new()
	visual.color = Color(1.0, 0.0, 0.0, 1.0)
	visual.size = Vector2(grid_size - 4.0, grid_size - 4.0)
	visual.position = Vector2(-(grid_size - 4.0) / 2.0, -(grid_size - 4.0) / 2.0)
	apple_node.add_child(visual)
	
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = grid_size / 2.0 - 2.0
	collision.shape = shape
	apple_node.add_child(collision)
	
	return apple_node

func _process(delta: float):
	if not GameManager.is_playing() or not is_alive:
		return
	
	_handle_input()
	
	move_timer += delta
	if move_timer >= move_interval:
		move_timer = 0.0
		_move()

func _handle_input():
	if Input.is_action_just_pressed("snake_up") and direction != Direction.DOWN:
		next_direction = Direction.UP
	elif Input.is_action_just_pressed("snake_down") and direction != Direction.UP:
		next_direction = Direction.DOWN
	elif Input.is_action_just_pressed("snake_left") and direction != Direction.RIGHT:
		next_direction = Direction.LEFT
	elif Input.is_action_just_pressed("snake_right") and direction != Direction.LEFT:
		next_direction = Direction.RIGHT

func _move():
	direction = next_direction
	
	if body.is_empty():
		return
	
	var head = body[0]
	var new_head_pos = _get_next_position(head.position, direction)
	
	new_head_pos = _wrap_position(new_head_pos)
	
	if _check_self_collision(new_head_pos):
		_die()
		return
	
	var new_segment = _create_segment()
	new_segment.position = new_head_pos
	add_child(new_segment)
	body.insert(0, new_segment)
	
	if _check_apple_collision(new_head_pos):
		_eat_apple()
	else:
		var tail = body.pop_back()
		tail.queue_free()
	
	_update_head_visual()

func _get_next_position(current: Vector2, dir: int) -> Vector2:
	match dir:
		Direction.UP:
			return current + Vector2(0.0, -grid_size)
		Direction.DOWN:
			return current + Vector2(0.0, grid_size)
		Direction.LEFT:
			return current + Vector2(-grid_size, 0.0)
		Direction.RIGHT:
			return current + Vector2(grid_size, 0.0)
	return current

func _wrap_position(pos: Vector2) -> Vector2:
	var wrapped = pos
	
	if wrapped.x < area_x_offset:
		wrapped.x = area_x_offset + area_width - grid_size
	elif wrapped.x >= area_x_offset + area_width:
		wrapped.x = area_x_offset
	
	if wrapped.y < area_y_offset:
		wrapped.y = area_y_offset + area_height - grid_size
	elif wrapped.y >= area_y_offset + area_height:
		wrapped.y = area_y_offset
	
	return wrapped

func _check_self_collision(new_head_pos: Vector2) -> bool:
	for i in range(0, body.size() - 1):
		var segment = body[i]
		if segment.position.distance_to(new_head_pos) < grid_size / 2.0:
			return true
	return false

func _check_apple_collision(head_pos: Vector2) -> bool:
	if apple == null:
		return false
	return head_pos.distance_to(apple.position) < grid_size

func _eat_apple():
	GameManager.add_score(10)
	GameManager.boost_giant_snake_hp(10)
	_spawn_apple()

func _die():
	is_alive = false
	print("Snake died!")
	
	for segment in body:
		for child in segment.get_children():
			if child is ColorRect:
				child.color = Color(0.5, 0.5, 0.5, 1.0)

func is_snake_alive() -> bool:
	return is_alive
