extends Node

# Данные проекта
const SUPABASE_URL = "https://hwdwtviyrjflyrikmiqk.supabase.co"
const SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3ZHd0dml5cmpmbHlyaWttaXFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc4OTE1MTAsImV4cCI6MjA4MzQ2NzUxMH0.84JLavXFDKzVFfiv2g3Sn_gHoSbnK9H9QVmzJwCC0V0"
const SAVE_PATH = "user://save.cfg"

var player_uuid : String = ""
var player_name : String = ""

func _ready():
	load_player_data()

func load_player_data():
	var cfg = ConfigFile.new()
	var err = cfg.load(SAVE_PATH)
	
	if err == OK:
		player_name = cfg.get_value("player", "nickname", "")
		player_uuid = cfg.get_value("player", "uuid", "")
	
	# Если UUID всё еще пустой (новый игрок), создаем его
	if player_uuid == "":
		player_uuid = OS.get_unique_id()
		if player_uuid == "":
			player_uuid = str(Time.get_unix_time_from_system()) + str(randi())
		save_player_data()

func save_player_data():
	var cfg = ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("player", "nickname", player_name)
	cfg.set_value("player", "uuid", player_uuid)
	cfg.save(SAVE_PATH)

func save_score(uuid: String, nickname: String, score: int, mode: String = "classic"):
	print("Попытка отправить: ", nickname, " счет: ", score)
	var url = SUPABASE_URL + "/rest/v1/leaderboard"
	
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY,
		"Prefer: resolution=merge-duplicates"
	]
	
	var data = {
		"UUID": uuid,
		"Nickname": nickname,
		"Score": score,
		"Mode": mode
	}
	
	var json_data = JSON.stringify(data)
	var http = HTTPRequest.new()
	add_child(http)
	
	http.request_completed.connect(func(_result, response_code, _headers, _body):
		if response_code in [200, 201]:
			print("Успех! Данные в облаке.")
		else:
			print("Ошибка! Код: ", response_code)
			print("Ответ базы: ", _body.get_string_from_utf8())
		http.queue_free()
	)
	
	http.request(url, headers, HTTPClient.METHOD_POST, json_data)

func get_leaderboard():
	# Формируем URL: берем всё (*), сортируем по score (desc - убывание), лимит 10
	var url = SUPABASE_URL + "/rest/v1/leaderboard?select=*&order=Score.desc&limit=10"
	
	var headers = [
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY,
		"Content-Type: application/json"
	]
	
	var http = HTTPRequest.new()
	add_child(http)
	
	# Делаем GET запрос
	http.request(url, headers, HTTPClient.METHOD_GET)
	
	var response = await http.request_completed
	var response_code = response[1]
	var body = response[3].get_string_from_utf8()
	
	http.queue_free() # Убираем временную ноду запроса
	
	if response_code == 200:
		var data = JSON.parse_string(body)
		return data # Возвращает массив словарей [{}, {}, ...]
	else:
		print("Ошибка получения лидерборда! Код: ", response_code)
		print("Ответ базы: ", body)
		return []