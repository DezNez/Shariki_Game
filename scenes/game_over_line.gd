extends Node2D

@export var y: float = -170
@export var width: float = 400
@export var fade_distance: float = 120.0  # на каком расстоянии начинает появляться

var alpha: float = 0.0

func _process(_delta: float) -> void:
	var target_alpha: float = 0.0

	for b in get_tree().get_nodes_in_group("balls"):
		# учитываем только шары, которые могут триггерить game over
		if not b.can_trigger_game_over:
			continue
		# игнорим шары, которые спавнятся выше линии
		if b.global_position.y < y:
			continue

		var dy: float = abs(b.global_position.y - y)
		if dy < fade_distance:
			target_alpha = max(target_alpha, 1.0 - dy / fade_distance)

	alpha = lerp(alpha, target_alpha, 0.1)
	queue_redraw()

# func _draw() -> void:
# 	if alpha <= 0.01:
# 		return

# 	var col: Color = Color(1, 0.2, 0.2, alpha * 0.6)
# 	draw_line(
# 		Vector2(-width * 0.5, y),
# 		Vector2(width * 0.5, y),
# 		col,
# 		2.0
# 	)
