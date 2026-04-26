class_name GiantSnake
extends Node2D

enum MovePhase {
	MOVING_UP,
	WAITING
}

var segments: Array[SnakeSegment] = []
var segment_scene: PackedScene

var grid_data: Array[Array[int]] = []

var reached_top: bool = false
var move_timer: float = 0.0

const LEFT_AREA_HEIGHT: float = 1820.0
const LEFT_AREA_TOP: float = 100.0
const ROWS_NEEDED: int = 23
const TIME_TO_WIN: float = 180.0
var MOVE_INTERVAL: float

func _ready():
	MOVE_INTERVAL = TIME_TO_WIN / ROWS_NEEDED
	segment_scene = preload("res://scenes/SnakeSegment.tscn")
	_initialize_grid()
	_initialize_snake()
	GameManager.set_giant_snake(self)

func _initialize_grid():
	grid_data.clear()
	for row in range(ROWS_NEEDED):
		var row_data: Array[int] = []
		for col in range(GameManager.SEGMENTS_PER_ROW):
			row_data.append(-1)
		grid_data.append(row_data)

func _initialize_snake():
	var total_segments = GameManager.INITIAL_GIANT_SNAKE_LENGTH
	var segments_placed = 0
	var row = 0
	
	while segments_placed < total_segments and row < ROWS_NEEDED:
		var segments_in_row = mini(total_segments - segments_placed, GameManager.SEGMENTS_PER_ROW)
		var start_col = (GameManager.SEGMENTS_PER_ROW - segments_in_row) / 2
		
		for i in range(segments_in_row):
			var col = start_col + i
			_create_segment(row, col, segments_placed + i)
		
		segments_placed += segments_in_row
		row += 1
	
	_update_segment_visuals()
	_update_positions_from_grid()

func _create_segment(row: int, col: int, index: int):
	var segment: SnakeSegment
	if segment_scene != null:
		segment = segment_scene.instantiate() as SnakeSegment
	else:
		segment = SnakeSegment.new()
	
	segment.hp = GameManager.INITIAL_SEGMENT_HP
	segment.max_hp = GameManager.INITIAL_SEGMENT_HP
	segment.set_index(index)
	
	add_child(segment)
	segments.append(segment)
	grid_data[row][col] = segments.size() - 1
	
	segment.destroyed.connect(_on_segment_destroyed.bind(segment))

func _update_segment_visuals():
	for i in range(segments.size()):
		if i == segments.size() - 1:
			segments[i].set_as_head()
		else:
			segments[i].set_as_body()

func _update_positions_from_grid():
	for row in range(grid_data.size()):
		for col in range(grid_data[row].size()):
			var seg_index = grid_data[row][col]
			if seg_index >= 0 and seg_index < segments.size():
				var segment = segments[seg_index]
				var x = col * GameManager.SEGMENT_WIDTH
				var y = LEFT_AREA_TOP + LEFT_AREA_HEIGHT - (row + 1) * GameManager.SEGMENT_HEIGHT
				segment.position = Vector2(x, y)

func _on_segment_destroyed(segment: SnakeSegment):
	var seg_index = segments.find(segment)
	if seg_index == -1:
		return
	
	var front_segments_count = segments.size() - seg_index - 1
	
	for row in range(grid_data.size()):
		for col in range(grid_data[row].size()):
			var idx = grid_data[row][col]
			if idx > seg_index:
				grid_data[row][col] = -1
	
	for i in range(front_segments_count):
		var idx = segments.size() - 1
		if idx > seg_index:
			var seg = segments[idx]
			seg.queue_free()
			segments.remove_at(idx)
	
	for row in range(grid_data.size()):
		for col in range(grid_data[row].size()):
			var idx = grid_data[row][col]
			if idx > seg_index:
				grid_data[row][col] = -1
			elif idx == seg_index:
				grid_data[row][col] = -1
	
	_compact_grid()
	
	if segments.is_empty():
		GameManager.lose_game()
	else:
		_update_segment_visuals()
		_update_positions_from_grid()

func _compact_grid():
	var rows_to_move = 0
	for row in range(grid_data.size() - 1, -1, -1):
		var has_segment = false
		for col in range(grid_data[row].size()):
			if grid_data[row][col] >= 0:
				has_segment = true
				break
		
		if has_segment:
			if rows_to_move > 0:
				for col in range(grid_data[row].size()):
					grid_data[row + rows_to_move][col] = grid_data[row][col]
					grid_data[row][col] = -1
		else:
			rows_to_move += 1

func _process(delta: float):
	if not GameManager.is_playing() or reached_top:
		return
	
	move_timer += delta
	
	if move_timer >= MOVE_INTERVAL:
		move_timer = 0.0
		_advance_snake()

func _advance_snake():
	if reached_top:
		return
	
	var top_row = _find_top_row()
	
	if top_row <= 0:
		reached_top = true
		GameManager.win_game()
		return
	
	var segments_in_top_row = _get_segments_in_row(top_row)
	var can_add_more = segments_in_top_row < GameManager.SEGMENTS_PER_ROW
	
	if can_add_more:
		_grow_top_row(top_row)
	else:
		_move_to_next_row(top_row)
	
	_update_positions_from_grid()
	
	var new_top_row = _find_top_row()
	if new_top_row <= 0:
		reached_top = true
		GameManager.win_game()

func _find_top_row() -> int:
	for row in range(grid_data.size()):
		for col in range(grid_data[row].size()):
			if grid_data[row][col] >= 0:
				return row
	return grid_data.size()

func _get_segments_in_row(row: int) -> int:
	var count = 0
	for col in range(grid_data[row].size()):
		if grid_data[row][col] >= 0:
			count += 1
	return count

func _grow_top_row(top_row: int):
	var segments_in_top_row = _get_segments_in_row(top_row)
	var start_col = (GameManager.SEGMENTS_PER_ROW - (segments_in_top_row + 1)) / 2
	
	for col in range(grid_data[top_row].size()):
		if grid_data[top_row][col] >= 0:
			var current_start = col
			var expected_start = start_col
			if current_start > expected_start:
				var shift = current_start - expected_start
				for i in range(segments_in_top_row):
					var from_col = current_start + i
					var to_col = expected_start + i
					if from_col < GameManager.SEGMENTS_PER_ROW and to_col >= 0:
						grid_data[top_row][to_col] = grid_data[top_row][from_col]
						grid_data[top_row][from_col] = -1
				break
	
	for col in range(grid_data[top_row].size()):
		if grid_data[top_row][col] < 0:
			var has_neighbor = false
			if col > 0 and grid_data[top_row][col - 1] >= 0:
				has_neighbor = true
			elif col < GameManager.SEGMENTS_PER_ROW - 1 and grid_data[top_row][col + 1] >= 0:
				has_neighbor = true
			
			if has_neighbor:
				var new_index = segments.size()
				_create_segment_in_grid(top_row, col, new_index)
				return
	
	if segments_in_top_row == 0 and top_row + 1 < grid_data.size():
		_move_to_next_row(top_row)

func _move_to_next_row(current_top_row: int):
	var next_row = current_top_row - 1
	if next_row < 0:
		return
	
	var start_col = (GameManager.SEGMENTS_PER_ROW - 1) / 2
	
	_create_segment_in_grid(next_row, start_col, segments.size())

func _create_segment_in_grid(row: int, col: int, index: int):
	var segment: SnakeSegment
	if segment_scene != null:
		segment = segment_scene.instantiate() as SnakeSegment
	else:
		segment = SnakeSegment.new()
	
	segment.hp = GameManager.INITIAL_SEGMENT_HP + (GameManager.player_snake_base_hp - 10)
	segment.max_hp = maxi(segment.hp, GameManager.INITIAL_SEGMENT_HP)
	segment.set_index(index)
	
	add_child(segment)
	segments.append(segment)
	grid_data[row][col] = segments.size() - 1
	
	segment.destroyed.connect(_on_segment_destroyed.bind(segment))
	
	_update_segment_visuals()

func has_reached_top() -> bool:
	return reached_top

func boost_front_segment_hp(amount: int):
	if segments.is_empty():
		return
	
	var top_row = _find_top_row()
	var boosted = 0
	
	for row in range(top_row, mini(top_row + 2, grid_data.size())):
		for col in range(grid_data[row].size()):
			var seg_index = grid_data[row][col]
			if seg_index >= 0 and seg_index < segments.size():
				segments[seg_index].heal(amount)
				boosted += 1
				if boosted >= 3:
					return

func get_segments_to_attack() -> Array[SnakeSegment]:
	var result: Array[SnakeSegment] = []
	if segments.is_empty():
		return result
	
	var top_row = _find_top_row()
	var found = 0
	
	for row in range(top_row, mini(top_row + 3, grid_data.size())):
		for col in range(grid_data[row].size()):
			var seg_index = grid_data[row][col]
			if seg_index >= 0 and seg_index < segments.size():
				result.append(segments[seg_index])
				found += 1
				if found >= GameManager.SOLDIER_ATTACK_SEGMENTS:
					return result
	
	return result

func get_segment_count() -> int:
	return segments.size()
