extends PanelContainer

func setup(rank: int, p_name: String, score: int, is_empty: bool = false, is_current_player: bool = false):
	$HBoxContainer/Rank.text = str(rank) + "."
	$HBoxContainer/PlayerName.text = p_name
	$HBoxContainer/Score.text = str(score)

	if is_empty:
		$HBoxContainer/Score.text = ""
	else:
		$HBoxContainer/Score.text = str(score)

	if is_current_player:
		$HBoxContainer/PlayerName.add_theme_color_override("font_color", Color.GOLD)
		$HBoxContainer/Score.add_theme_color_override("font_color", Color.GOLD)
