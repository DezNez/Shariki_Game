extends Node2D

@export var game: Node

const RADII := [14, 18, 22, 26, 32, 38, 46, 56, 68, 90]
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

var time_acc := 0.0

func _process(delta):
	time_acc += delta
	queue_redraw()

	# лёгкий пульс
	scale = Vector2.ONE * (0.9 + 0.1 * sin(time_acc * 3.0))

func _draw():
	if game == null:
		return

	var size = game.next_size
	var col = COLORS[size]
	var width = 4
	# основной круг
	draw_circle(Vector2.ZERO, RADII[size], col)

	# обводка
	draw_circle(Vector2.ZERO, RADII[size] - 2, col.darkened(0.4), width)
