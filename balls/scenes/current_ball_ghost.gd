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

var spawn_y := -250

var aim_enabled := true


func _process(_delta):
	if game == null:
		return
	var x = get_global_mouse_position().x
	x = clamp(x, -155 + (game.current_size * 5), 155 - (game.current_size * 5))
	global_position = Vector2(x, spawn_y)
	queue_redraw()

func _draw():
	if game == null:
		return

	var size = game.current_size
	var col = COLORS[size]
	var width = 4

	draw_circle(Vector2.ZERO, RADII[size], col)

	# обводка
	draw_circle(Vector2.ZERO, RADII[size] - 2, col.darkened(0.4), width)

	# прицел
	if aim_enabled:
		var y2 = game.game_over_y if "game_over_y" in game else 300
		draw_line(Vector2.ZERO, Vector2(0, y2 - global_position.y), Color(1,1,1,0.5), 2)