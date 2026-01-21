extends Control

@export var default_scale := 1.0


func open():
	show()
	_sync_settings(self)

	self.visible = true
	self.modulate.a = 0.0
	self.scale = Vector2.ONE * (default_scale * 0.8)
	self.pivot_offset = size / 2.0 
	

	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tw.tween_property(self, "modulate:a", 1.0, 0.3)
	tw.tween_property(self, "scale", Vector2.ONE * default_scale, 0.3)


func close():
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.tween_property(self, "scale", Vector2.ONE * (default_scale * 0.8), 0.2)

	tw.chain().step_finished.connect(func(_name): self.visible = false)
	get_tree().paused = false


func _sync_settings(node: Node):
	for child in node.get_children():
		# Если узел в группе, обновляем его автоматом по имени
		if child.is_in_group("config_popup"):
			var setting_name = child.name.to_lower() + "_enabled" # "vibration" + "_enabled"
			if setting_name in Settings:
				child.button_pressed = Settings.get(setting_name)
		
		# Рекурсия, чтобы проверить вложенные контейнеры
		if child.get_child_count() > 0:
			_sync_settings(child)
