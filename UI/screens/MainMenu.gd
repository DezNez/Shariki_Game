extends Control

# попапы
@onready var modes_popup = $CanvasLayer/Popups/ModesPopup
@onready var settings_popup = $CanvasLayer/Popups/SettingsPopup
@export var registration_scene: PackedScene

# кнопки
@onready var play_button = $CanvasLayer/Buttons/PlayButton
@onready var settings_button = $CanvasLayer/Buttons/SettingsButton
@onready var leaderboard_button = $CanvasLayer/Buttons/LeaderboardButton
@onready var nick_button = $CanvasLayer/NicknameButton


func _ready():
	# подключаем сигналы кнопок
	# play_button.pressed.connect(_on_play_button_pressed)
	# settings_button.pressed.connect(_on_settings_button_pressed)
	# leaderboard_button.pressed.connect(_on_leaderboard_button_pressed)
	update_nickname_display()
	# проверка
	print("MainMenu ready!")

# открытие попапов
func _on_play_button_pressed():
	if Supabase.player_name == "":
		var reg = registration_scene.instantiate()
		get_tree().root.add_child(reg)
		reg.nickname_confirmed.connect(_on_classic_pressed)
	else:
		_on_classic_pressed()

	# modes_popup.open()

func _on_settings_button_pressed():
	settings_popup.open()

func _on_leaderboard_button_pressed() -> void:
	GlobalLeaderboard._show_leaderboard()


func _on_close_settings_pressed() -> void:
	settings_popup.close()

# func _on_vibration_toggled(toggled_on: bool) -> void:
# 	Settings.vibration_enabled = toggled_on
# 	Settings.save_settings()


func _on_close_modes_pressed() -> void:
	modes_popup.close()


func _on_classic_pressed() -> void:
	modes_popup.close()
	get_tree().change_scene_to_file("res://scenes/gm_classic.tscn")
	


# func _on_aim_toggled(toggled_on: bool) -> void:
# 	Settings.aim_enabled = toggled_on
# 	Settings.save_settings()


func update_nickname_display():
	if Supabase.player_name == "":
		nick_button.visible = false
	else:
		nick_button.visible = true
		nick_button.text = "Welcome, " + Supabase.player_name

func _on_change_nick_button_pressed():
	if registration_scene:
		var popup = registration_scene.instantiate()
		get_tree().root.add_child(popup)
		popup.nickname_confirmed.connect(update_nickname_display)

func _on_nickname_button_pressed() -> void:
	_on_change_nick_button_pressed()



func _on_aim_2_toggled(is_on: bool) -> void:
	Settings.aim_enabled = is_on
	Settings.save_settings()

func _on_vibration_2_toggled(is_on: bool) -> void:
	Settings.vibration_enabled = is_on
	Settings.save_settings()
