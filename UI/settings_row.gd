extends HBoxContainer

@export var setting_name: String = "sound" # Сюда пишем имя переменной из Settings.gd
@export var label_text: String = "Звук"

func _ready():
	$SettingName.text = label_text
	
	# Формируем имя переменной
	var property_name = setting_name + "_enabled"
	
	# Проверяем, существует ли такая переменная в Settings.gd
	if property_name in Settings:
		var current_val = Settings.get(property_name)
		# Если значение вдруг Nil (не задано), используем true по умолчанию
		if current_val == null: current_val = true 
		$Toggle.set_pressed_no_signal(current_val)
	else:
		# Если ты опечатался в инспекторе, Godot напишет об этом в консоль
		push_error("Ошибка в SettingsRow: Переменная " + property_name + " не найдена в Settings.gd! Проверь Инспектор.")

	$Toggle.toggled.connect(_on_toggled)

func _on_toggled(is_on: bool):
	Settings.set(setting_name + "_enabled", is_on)
	Settings.save_settings()
	
	match setting_name:
		# "sound":
		# 	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !is_on)
		# "music":
		# 	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), !is_on)
		"vibration":
			if is_on:
				Input.vibrate_handheld(50)
		"aim":
			pass
	
	print("Настройка ", setting_name, " теперь: ", is_on)
