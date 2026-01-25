extends Node

func _ready():
	# Подключаемся к сигналу окна: он видит все события ввода
	get_tree().node_added.connect(_on_node_added)
	_connect_buttons_recursive(get_tree().root)

# Эта штука находит все кнопки, которые уже есть в сцене при запуске
func _connect_buttons_recursive(node):
	for child in node.get_children():
		if child is Button:
			_connect_button(child)
		_connect_buttons_recursive(child)

# Эта штука находит кнопки, которые спавнятся динамически (как твои попапы)
func _on_node_added(node):
	if node is Button:
		_connect_button(node)

func _connect_button(btn: Button):
	# Чтобы не подключать дважды
	if not btn.pressed.is_connected(_play_haptic):
		btn.pressed.connect(_play_haptic)

func _play_haptic():
	# Проверяем, включена ли вибрация в настройках
	if Settings.vibration_enabled:
		# 50мс - легкий приятный "тык"
		Input.vibrate_handheld(50)