extends Node2D

@export var ball_scene: PackedScene
@onready var cam := $Camera2D
@onready var score_label := $CanvasLayer/ScoreLabel
@onready var pause_popup = $CanvasLayer/PausePopup
@onready var settings_popup = $CanvasLayer/SettingsPopup

var spawn_y := -220
var score := 0
var can_spawn := true
const SPAWN_COOLDOWN := 0.5
var game_over := false
const GAME_OVER_Y := -170
var best_score := 0
const SAVE_PATH := "user://save.cfg"
var mouse_in_game_area := false


var current_size := 0
var next_size := 0

func _ready():
	randomize()
	current_size = randi() % 3
	next_size = randi() % 3
	_load_best_score()

	if Supabase.player_name != "" and best_score > 0:
		Supabase.save_score(Supabase.player_uuid, Supabase.player_name, best_score, "classic")
	_update_score_labels()

	#КАМЕРА
	var viewport_size = get_viewport_rect().size

	# подгоняем масштаб под ширину стакана
	var target_width = 600
	var zoom_factor = viewport_size.x / target_width

	cam.zoom = Vector2(zoom_factor, zoom_factor)
	$GameOverLine.y = GAME_OVER_Y



func _input(event):
	if game_over:
		return
	if event is InputEventMouseButton and event.is_pressed():
		if get_viewport().gui_get_focus_owner() != null:
			return
	
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_released() \
	and mouse_in_game_area:
		spawn_ball()



func _trigger_game_over():
	if game_over:
		return

	get_tree().paused = true
	game_over = true
	can_spawn = false

	if score >= best_score:
		best_score = score
		_save_best_score()
	else:
		pass

	print("Пытаюсь вызвать Supabase. Имя игрока сейчас: '", Supabase.player_name, "'")
	if Supabase.player_name != "":
		Supabase.save_score(Supabase.player_uuid, Supabase.player_name, best_score, "classic")
		
	$CanvasLayer/GameOverLabel.visible = true
	$CanvasLayer/RestartButton.visible = true




func _process(_delta):
	if game_over:
		return

	for b in get_tree().get_nodes_in_group("balls"):
		if not b.can_trigger_game_over:
			continue

		if b.global_position.y < GAME_OVER_Y:
			_trigger_game_over()


func spawn_ball():
	if game_over:
		return
	if not can_spawn:
		return


	can_spawn = false

	var ball = ball_scene.instantiate()
	ball.size_level = current_size

	var mouse_x = get_global_mouse_position().x
	mouse_x = clamp(mouse_x, -155 + (current_size * 5), 155 - (current_size * 5))

	ball.global_position = Vector2(mouse_x, spawn_y)
	add_child(ball)

	# сдвигаем очередь
	current_size = next_size
	next_size = randi() % 3

	$NextBallPreview.queue_redraw()

	await get_tree().create_timer(SPAWN_COOLDOWN).timeout
	can_spawn = true


func _update_score_labels():
	score_label.text = "Score: %d" % score
	$CanvasLayer/BestLabel.text = "Best: %d" % best_score


func add_score(level):
	score += (level + 1) * 3

	if score > best_score:
		best_score = score
		_save_best_score()

	_update_score_labels()


func _save_best_score():
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)

	cfg.set_value("scores", "classic", best_score)
	cfg.save(SAVE_PATH)


func _load_best_score():
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		best_score = cfg.get_value("scores", "classic", 0)


func _on_game_area_mouse_entered():
	mouse_in_game_area = true

func _on_game_area_mouse_exited():
	mouse_in_game_area = false

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	pause_popup.open()
	get_tree().paused = true


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/screens/main_menu.tscn")

#Menu Popup
func _on_resume_button_pressed() -> void:
	pause_popup.close()
	get_tree().paused = false


func _on_exit_button_pressed() -> void:
	pause_popup.close()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/screens/main_menu.tscn")

func _on_settings_button_pressed() -> void:
	
	settings_popup.default_scale = 2.0
	# settings_popup.pivot_offset = settings_popup.size / 2
	settings_popup.open()
	pause_popup.close()
	get_tree().paused = true

#Settings Popup
func _on_close_settings_pressed() -> void:
	settings_popup.close()
	pause_popup.open()
	get_tree().paused = true

func _on_vibration_toggled(toggled_on: bool) -> void:
	Settings.vibration_enabled = toggled_on
	Settings.save_settings()

func _on_aim_toggled(toggled_on: bool) -> void:
	Settings.aim_enabled = toggled_on
	Settings.save_settings()
