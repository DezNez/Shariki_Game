extends Node2D

@export var y: float = -170
@export var width: float = 380
@export var fade_distance: float = 100.0  # расстояние появления

@export var line_z_index: int = -1  # ниже стенок

var alpha: float = 0.0
var locked: bool = false  # ← линия уже появлялась хотя бы раз

func _ready() -> void:
	z_as_relative = false
	z_index = line_z_index

func _process(_delta: float) -> void:
	var target_alpha: float = 0.0

	if not locked:
		for b in get_tree().get_nodes_in_group("balls"):
			if not b.can_trigger_game_over:
				continue
			if b.global_position.y < y:
				continue

			var dy: float = abs(b.global_position.y - y)
			if dy < fade_distance:
				target_alpha = max(target_alpha, 1.0 - dy / fade_distance)

		# если линия хоть немного появилась — фиксируем
		if target_alpha > 0.01:
			locked = true
	else:
		# после первого появления линия всегда стремится к 1
		target_alpha = 1.0

	alpha = lerp(alpha, target_alpha, 0.1)
	queue_redraw()

func _draw() -> void:
	if alpha <= 0.01:
		return

	var col: Color = Color(1, 1, 1, alpha * 0.6)
	draw_line(
		Vector2(-width * 0.5, y),
		Vector2(width * 0.5, y),
		col,
		3.0
	)
