extends Node2D

@export var y: float = -170
@export var width: float = 380
@export var fade_distance: float = 100.0

@export var line_z_index: int = -1

var alpha: float = 0.0
var locked: bool = false
var time_passed: float = 0.0

func _ready() -> void:
	z_as_relative = false
	z_index = line_z_index

func _process(delta: float) -> void:
	time_passed += delta
    
	var target_alpha: float = 0.0
	if not locked:
		for b in get_tree().get_nodes_in_group("balls"):
			if not b.can_trigger_game_over: continue
			if b.global_position.y < y: continue
			var dy: float = abs(b.global_position.y - y)
			if dy < fade_distance:
				target_alpha = max(target_alpha, 1.0 - dy / fade_distance)
		if target_alpha > 0.01: locked = true
	else:
		target_alpha = 1.0

	alpha = lerp(alpha, target_alpha, 0.1)
	queue_redraw()

func _draw() -> void:
	if alpha <= 0.01: return

	var col: Color = Color(1, 1, 1, alpha * 0.6)
    
    # Настройки пунктира
	var dash_len = 12.0
	var gap_len = 8.0
	var speed = 20.0 
	var total_step = dash_len + gap_len
    
	var offset = fmod(time_passed * speed, total_step)
    
	var start_x = -width * 0.5
	var end_x = width * 0.5
    
	var current_x = start_x - offset
	while current_x < end_x:
		var d_start = max(current_x, start_x)
		var d_end = min(current_x + dash_len, end_x)
        
		if d_end > d_start:
			draw_line(Vector2(d_start, y), Vector2(d_end, y), col, 3.0)
        
		current_x += total_step