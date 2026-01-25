extends CanvasLayer

signal nickname_confirmed

@onready var nick_input = $RegistrationPopup/Panel/NickInput
@onready var error_label = $RegistrationPopup/Panel/ErrorLabel
@onready var submit_button = $RegistrationPopup/Panel/SubmitButton
@onready var registration_popup = $RegistrationPopup

var last_kb_height: float = 0.0

func _ready():
    # 1. Сразу центрируем попап при спавне
    var screen_height = get_viewport().get_visible_rect().size.y
    registration_popup.position.y = (screen_height - registration_popup.get_rect().size.y) / 2
    
    # 2. Убеждаемся, что переменная высоты в нуле
    last_kb_height = 0.0
    
    # Твой остальной код...
    nick_input.grab_focus()
    nick_input.text = Supabase.player_name
    nick_input.text_changed.connect(_on_nick_input_text_changed)
    _update_button_ui()

func _process(_delta):
    var current_kb_height = DisplayServer.virtual_keyboard_get_height()
    
    # Эмуляция для ПК через Ctrl
    if not DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
        current_kb_height = 400.0 if Input.is_key_pressed(KEY_CTRL) else 0.0
    
    # Запускаем анимацию только если высота реально изменилась
    if current_kb_height != last_kb_height:
        _animate_keyboard_shift(current_kb_height)
        last_kb_height = current_kb_height

func _animate_keyboard_shift(kb_height: float):
    var screen_height = get_viewport().get_visible_rect().size.y
    # Центр экрана для панели
    var center_y = (screen_height - registration_popup.get_rect().size.y) / 2
    var target_y = center_y
    
    if kb_height > 0:
        # Считаем "опасную зону": где верх клавиатуры + отступ
        var keyboard_top = screen_height - kb_height
        var margin = 50.0 # Отступ от клавы
        
        # Если панель перекрывается, поднимаем её выше клавиатуры
        target_y = keyboard_top - registration_popup.get_rect().size.y - margin
        
        # На всякий случай: не даем панели улететь выше края экрана
        target_y = max(target_y, 20.0)
    
    # Плавное движение
    var tween = create_tween()
    tween.tween_property(registration_popup, "position:y", target_y, 0.3)\
        .set_trans(Tween.TRANS_QUART)\
        .set_ease(Tween.EASE_OUT)

# --- Остальная логика (кнопки и ошибки) ---

func _on_nick_input_text_changed(_new_text: String):
    _update_button_ui()
    
func _update_button_ui():
    var current_text = nick_input.text.strip_edges()
    submit_button.text = "Close" if current_text == Supabase.player_name else "Submit"
    if current_text == Supabase.player_name:
        error_label.visible = false

func _on_submit_button_pressed():
    var raw_nick : String = nick_input.text.strip_edges()
    if raw_nick == Supabase.player_name:
        queue_free()
        return

    if not NickCheck.is_valid(raw_nick):
        _show_error("Недопустимый ник")
        return

    submit_button.disabled = true
    _show_error("Проверка ника...") 

    if await Supabase.is_nickname_taken(raw_nick):
        _show_error("Ник занят")
        submit_button.disabled = false
        return
    
    Supabase.player_name = raw_nick
    Supabase.save_player_data()

    var cfg = ConfigFile.new()
    if cfg.load_encrypted_pass("user://save.cfg", Supabase.ENCRYPTION_PASS) == OK:
        var best = cfg.get_value("scores", "classic", 0)
        Supabase.save_score(Supabase.player_uuid, raw_nick, best, "classic")

    nickname_confirmed.emit()
    queue_free()

func _show_error(text):
    error_label.text = text
    error_label.visible = true