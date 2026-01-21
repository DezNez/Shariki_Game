extends CanvasLayer

@onready var list = $Panel/ScrollContainer/List
var item_scene = preload("res://UI/screens/leaderboard_item.tscn")

func _ready():
	visible = false
	fill_leaderboard()

func _show_leaderboard():
	visible = true

func _hide_leaderboard():
	visible = false

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
