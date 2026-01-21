extends Node

signal settings_changed

const SAVE_PATH := "user://settings.cfg"

var player_uuid : String = ""
var player_name : String = ""

var sound_enabled := true
var music_enabled := true
var vibration_enabled := true
var aim_enabled := true

func _ready():
	load_settings()

func load_settings():
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		save_settings()
		return

	sound_enabled = cfg.get_value("settings", "sound", true)
	music_enabled = cfg.get_value("settings", "music", true)
	vibration_enabled = cfg.get_value("settings", "vibration", true)
	aim_enabled = cfg.get_value("settings", "aim", true)

func save_settings():
	var cfg := ConfigFile.new()
	cfg.set_value("settings", "sound", sound_enabled)
	cfg.set_value("settings", "music", music_enabled)
	cfg.set_value("settings", "vibration", vibration_enabled)
	cfg.set_value("settings", "aim", aim_enabled)
	cfg.save(SAVE_PATH)
	settings_changed.emit()
