extends ScrollContainer

func _ready():
	get_v_scroll_bar().custom_step = 10
func _process(_delta):
	var is_refreshing = false
	if scroll_vertical < -50:
		if not is_refreshing:
			GlobalLeaderboard.fill_leaderboard()
			is_refreshing = true
		
		if scroll_vertical >= 0:
			is_refreshing = false
