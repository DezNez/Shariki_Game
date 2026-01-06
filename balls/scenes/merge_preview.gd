extends Node2D

@export var game: Node

const RADII := [14,18,22,26,32,38,46,56,68,90]
const COLORS := [
	Color("#81C784"),
	Color("#FFF176"),
	Color("#FFB74D"),
	Color("#BA68C8"),
	Color("#F06292"),
	Color("#4DD0E1"),
	Color("#FFD54F"),
	Color("#7986CB"),
	Color("#E57373"),
	Color("#ff7300ff")
]

func _process(_delta):
	queue_redraw()

func _draw():
	if game == null:
		return

	var base = game.current_size
	for i in range(10):
		var lvl = base + i
		if lvl >= RADII.size():
			break

		draw_circle(
			Vector2(i * 36, 0),
			RADII[lvl] * 0.35,
			COLORS[lvl]
		)