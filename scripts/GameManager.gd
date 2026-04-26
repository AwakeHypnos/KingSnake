extends Node

enum GameState {
	STARTING,
	PLAYING,
	WON,
	LOST
}

var game_state: GameState = GameState.STARTING

var giant_snake = null
var player_snake = null
var wall_system = null

var score: int = 0
var time_elapsed: float = 0.0
var player_snake_base_hp: int = 10

var GAME_DURATION: float = 180.0
var SEGMENT_WIDTH: float = 80.0
var SEGMENT_HEIGHT: float = 80.0
var SEGMENTS_PER_ROW: int = 6
var INITIAL_GIANT_SNAKE_LENGTH: int = 13
var INITIAL_SEGMENT_HP: int = 7

var SOLDIER_INITIAL_DAMAGE: int = 2
var SOLDIER_ATTACK_INTERVAL: float = 4.0
var SOLDIER_SPAWN_INTERVAL: float = 30.0
var SOLDIER_ATTACK_SEGMENTS: int = 3

var SCORE_PER_APPLE: int = 10
var HP_BOOST_PER_APPLE: int = 10

var LEFT_AREA_WIDTH: float = 540.0
var RIGHT_AREA_WIDTH: float = 540.0
var SCREEN_WIDTH: float = 1080.0
var SCREEN_HEIGHT: float = 1920.0
var WALL_HEIGHT: float = 100.0

signal game_won
signal game_lost
signal score_changed(new_score: int)
signal time_changed(new_time: float)
signal hp_boosted(new_hp: int)

func _ready():
	_start_game()

func _start_game():
	score = 0
	time_elapsed = 0.0
	player_snake_base_hp = 10
	game_state = GameState.PLAYING

func _process(delta: float):
	if game_state == GameState.PLAYING:
		time_elapsed += delta
		time_changed.emit(time_elapsed)
		
		if time_elapsed >= GAME_DURATION:
			_check_giant_snake_reached_top()

func _check_giant_snake_reached_top():
	if giant_snake:
		if giant_snake.has_reached_top():
			win_game()

func set_giant_snake(snake):
	giant_snake = snake

func set_player_snake(snake):
	player_snake = snake

func set_wall_system(wall):
	wall_system = wall

func add_score(points: int):
	score += points
	score_changed.emit(score)

func boost_giant_snake_hp(amount: int):
	player_snake_base_hp += amount
	hp_boosted.emit(player_snake_base_hp)
	if giant_snake:
		giant_snake.boost_front_segment_hp(amount)

func get_remaining_time() -> float:
	return max(0.0, GAME_DURATION - time_elapsed)

func win_game():
	if game_state == GameState.PLAYING:
		game_state = GameState.WON
		game_won.emit()
		print("游戏胜利！大蛇到达城墙！")

func lose_game():
	if game_state == GameState.PLAYING:
		game_state = GameState.LOST
		game_lost.emit()
		print("游戏失败！大蛇被消灭了！")

func is_playing() -> bool:
	return game_state == GameState.PLAYING
