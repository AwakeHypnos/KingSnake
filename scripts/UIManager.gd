extends CanvasLayer

var score_label: Label
var time_label: Label
var hp_boost_label: Label
var game_over_panel: PanelContainer
var game_result_label: Label
var restart_button: Button

func _ready():
	_setup_connections()
	_setup_ui_elements()

func _setup_connections():
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.time_changed.connect(_on_time_changed)
	GameManager.hp_boosted.connect(_on_hp_boosted)
	GameManager.game_won.connect(_on_game_won)
	GameManager.game_lost.connect(_on_game_lost)

func _setup_ui_elements():
	var info_panel = VBoxContainer.new()
	info_panel.anchors_preset = Control.PRESET_TOP_WIDE
	info_panel.offset_top = 5
	info_panel.offset_left = 10
	info_panel.offset_right = -10
	add_child(info_panel)
	
	var info_hbox = HBoxContainer.new()
	info_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_panel.add_child(info_hbox)
	
	score_label = Label.new()
	score_label.text = "积分: 0"
	score_label.add_theme_font_size_override("font_size", 32)
	score_label.modulate = Color.WHITE
	info_hbox.add_child(score_label)
	
	info_hbox.add_child(Control.new())
	
	time_label = Label.new()
	time_label.text = "时间: 3:00"
	time_label.add_theme_font_size_override("font_size", 32)
	time_label.modulate = Color.WHITE
	info_hbox.add_child(time_label)
	
	info_hbox.add_child(Control.new())
	
	hp_boost_label = Label.new()
	hp_boost_label.text = "血量加成: 10"
	hp_boost_label.add_theme_font_size_override("font_size", 32)
	hp_boost_label.modulate = Color.GREEN
	info_hbox.add_child(hp_boost_label)
	
	_setup_game_over_panel()

func _setup_game_over_panel():
	game_over_panel = PanelContainer.new()
	game_over_panel.anchors_preset = Control.PRESET_CENTER
	game_over_panel.visible = false
	add_child(game_over_panel)
	
	var vbox = VBoxContainer.new()
	game_over_panel.add_child(vbox)
	
	game_result_label = Label.new()
	game_result_label.add_theme_font_size_override("font_size", 48)
	game_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(game_result_label)
	
	var final_score_label = Label.new()
	final_score_label.name = "FinalScoreLabel"
	final_score_label.add_theme_font_size_override("font_size", 32)
	final_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(final_score_label)
	
	restart_button = Button.new()
	restart_button.text = "重新开始"
	restart_button.add_theme_font_size_override("font_size", 32)
	restart_button.pressed.connect(_on_restart_pressed)
	vbox.add_child(restart_button)

func _on_score_changed(new_score: int):
	score_label.text = "积分: " + str(new_score)

func _on_time_changed(new_time: float):
	var remaining = GameManager.get_remaining_time()
	var minutes = int(remaining / 60)
	var seconds = int(remaining % 60)
	time_label.text = "时间: %d:%02d" % [minutes, seconds]

func _on_hp_boosted(new_hp: int):
	hp_boost_label.text = "血量加成: " + str(new_hp)

func _on_game_won():
	_show_game_over(true)

func _on_game_lost():
	_show_game_over(false)

func _show_game_over(won: bool):
	game_over_panel.visible = true
	
	if won:
		game_result_label.text = "游戏胜利！"
		game_result_label.modulate = Color.GREEN
	else:
		game_result_label.text = "游戏失败！"
		game_result_label.modulate = Color.RED
	
	var final_score_label = game_over_panel.get_node("VBoxContainer/FinalScoreLabel")
	if final_score_label:
		final_score_label.text = "最终积分: " + str(GameManager.score)

func _on_restart_pressed():
	get_tree().reload_current_scene()
