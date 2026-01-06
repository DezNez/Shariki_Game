extends Node2D

@onready var walls := get_parent()

func _draw():
	for child in walls.get_children():
		if child is StaticBody2D:
			for c in child.get_children():
				if c is CollisionShape2D:
					_draw_collision(c)


func _draw_collision(col: CollisionShape2D):
	if col.shape is RectangleShape2D:
		var shape := col.shape as RectangleShape2D
		var size := shape.size
		var color := col.modulate

		# позиция коллизии относительно CupVisual
		var center := col.global_position - global_position

		# применяем трансформацию
		draw_set_transform(
			center,
			col.global_rotation,
			Vector2.ONE
		)

		# рисуем от центра
		draw_rect(
			Rect2(-size * 0.5, size),
			color
		)

		# сброс transform
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
