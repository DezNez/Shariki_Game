extends CanvasLayer

@onready var list = $Panel/ScrollContainer/List
@onready var refresh_button = $Panel/RefreshButton
@onready var icon = $Panel/RefreshButton/Icon
var item_scene = preload("res://UI/screens/leaderboard_item.tscn")

func _ready():
	visible = false
	fill_leaderboard()

func _show_leaderboard():
	visible = true

func _hide_leaderboard():
	visible = false

func _leaderboard_refresh():
	await fill_leaderboard()


func fill_leaderboard():
	# Очистка
	for child in list.get_children():
		child.queue_free()

	var data = await Supabase.get_leaderboard()
	var my_name = Supabase.player_name
	
	var total_rows = max(100, data.size()) 

	for i in range(total_rows):
		var rank = i + 1
		var item = item_scene.instantiate()
		list.add_child(item)
		
		var style = StyleBoxFlat.new()
		style.set_border_width_all(1) # Толщина линии
		style.border_color = Color(0.2, 0.2, 0.2, 1) # Цвет линий сетки
		if rank % 2 == 0:
			style.bg_color = Color(0.1, 0.1, 0.1, 0.5) # Тёмный
		else:
			style.bg_color = Color(0.1, 0.1, 0.1, 0.2) # Основной
		
		item.add_theme_stylebox_override("panel", style)

		
		if i < data.size():
			# Если игрок есть в базе
			var entry = data[i]
			var p_name = entry.get("Nickname", "Anon")
			var p_score = int(entry.get("Score", 0))
			var is_me = (p_name == my_name)
			item.setup(rank, p_name, p_score, false, is_me)
		else:
			# Если место пустое (разметка)
			item.setup(rank, "---", 0, true, false)
			item.modulate.a = 0.5


func _on_close_button_pressed() -> void:
	GlobalLeaderboard._hide_leaderboard()


func _on_refresh_button_pressed() -> void:
	refresh_button.disabled = true
	var tween = create_tween()
	tween.tween_property(icon, "rotation_degrees", 360.0, 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).as_relative()
	
	for child in list.get_children():
		child.queue_free()

	await get_tree().process_frame

	await _leaderboard_refresh()

	refresh_button.disabled = false
	refresh_button.rotation_degrees = 0
	# _leaderboard_refresh()
