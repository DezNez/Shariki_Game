extends Node2D

@export var game: Node

@export var start_pos: Vector2 = Vector2(0, 0)
@export var scale_ball: float = 0.35
@export var padding: float = 10
@export var tilt: float = 0  # наклон как в suika

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

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if game == null:
		return

	# ─── ищем реальный максимальный шар в стакане ───
	var max_level: int = -1
	for b in get_tree().get_nodes_in_group("balls"):
		if b.size_level > max_level:
			max_level = b.size_level

	var pos: Vector2 = start_pos
	var prev_r: float = 0.0

	for i: int in range(RADII.size()):
		var r: float = RADII[i] * scale_ball
		var col: Color = COLORS[i]
		var width: float = 2
		# ─── подсветка реального максимального ───────
		if i == max_level:
			draw_circle(
				pos,
				r + 5.0,
				Color(1, 1, 1, 0.4)
			)

		# ─── сам шар ────────────────────────────────
		draw_circle(pos, r, col)
		draw_circle(pos, r - 2, col.darkened(0.4), width)
		# ─── динамический шаг ───────────────────────
		if i < RADII.size() - 1:
			var next_r: float = RADII[i + 1] * scale_ball
			var dy: float = prev_r + r + padding
			pos.y += dy
			pos.x += dy * tilt
			prev_r = r
