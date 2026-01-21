extends Control

signal nickname_confirmed

@onready var nick_input = $Panel/NickInput
@onready var error_label = $Panel/ErrorLabel

func _ready():
	nick_input.grab_focus()

func _on_submit_button_pressed():
	var nick = nick_input.text.strip_edges()
	
	if nick.length() < 4:
		_show_error("Слишком короткий ник!")
		return
	if nick.length() > 12:
		_show_error("Максимум 12 символов!")
		return
		
	# Сохраняем в наш синглтон
	Supabase.player_name = nick
	Supabase.save_player_data()
	
	# Сразу пушим текущий рекорд в базу, если он есть
	var cfg = ConfigFile.new()
	if cfg.load("user://save.cfg") == OK:
		var best = cfg.get_value("scores", "classic", 0)
		if best > 0:
			Supabase.save_score(Supabase.player_uuid, nick, best, "classic")
	
	emit_signal("nickname_confirmed")
	queue_free() # Закрываем попап

func _show_error(text):
	error_label.text = text
	error_label.visible = true
