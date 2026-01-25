extends Node

# Данные проекта
const SUPABASE_URL = "https://hwdwtviyrjflyrikmiqk.supabase.co"
const SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3ZHd0dml5cmpmbHlyaWttaXFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc4OTE1MTAsImV4cCI6MjA4MzQ2NzUxMH0.84JLavXFDKzVFfiv2g3Sn_gHoSbnK9H9QVmzJwCC0V0"
const SAVE_PATH = "user://save.cfg"
const ENCRYPTION_PASS = "LUBLU_LERU"
const HASH_SALT = "EBAL_YA_ETU_BEZOPASNOST"
var player_uuid : String = ""
var player_name : String = ""

func _ready():
	load_player_data()

func load_player_data():
	var cfg = ConfigFile.new()
	
	if not FileAccess.file_exists(SAVE_PATH):
		_create_new_player()
		return
	var err = cfg.load_encrypted_pass(SAVE_PATH, ENCRYPTION_PASS)
	
	if err == OK:
		player_name = cfg.get_value("player", "nickname", "")
		player_uuid = cfg.get_value("player", "uuid", "")
		var h = cfg.get_value("security", "hash", "")

		var check_hash = (player_name + player_uuid + HASH_SALT).sha256_text()

		if h == check_hash:
			player_name = player_name
			player_uuid = player_uuid
			print("Сейв загружен и проверен")
		else:
			print("КОНТРОЛЬНАЯ СУММА НЕ СОВПАЛА")
			_reset_to_default()
	else:
		print("Новый профиль или ошибка пароля")
		_create_new_player()

func _create_new_player():
	player_uuid = OS.get_unique_id()
	if player_uuid == "":
		player_uuid = str(Time.get_unix_time_from_system()) + str(randi())
	player_name = ""
	save_player_data()

func _reset_to_default():
	player_uuid = "BANNED_" + str(randi())
	player_name = "Cheater"
	save_player_data()
	
	# Если UUID всё еще пустой (новый игрок), создаем его
	if player_uuid == "":
		player_uuid = OS.get_unique_id()
		if player_uuid == "":
			player_uuid = str(Time.get_unix_time_from_system()) + str(randi())
		save_player_data()

func save_player_data():
	var cfg = ConfigFile.new()
	cfg.load_encrypted_pass(SAVE_PATH, ENCRYPTION_PASS)

	cfg.set_value("player", "nickname", player_name)
	cfg.set_value("player", "uuid", player_uuid)

	#Кодировка и хэш
	var data_to_hash = player_name + player_uuid + HASH_SALT
	var security_hash = data_to_hash.sha256_text()

	cfg.set_value("security", "hash", security_hash)

	var err = cfg.save_encrypted_pass(SAVE_PATH, ENCRYPTION_PASS)
	if err != OK:
		print("Ошибка сохранения зашифрованного файла: ", err)


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

func is_nickname_taken(nickname: String) -> bool:
	var url = SUPABASE_URL + "/rest/v1/leaderboard?Nickname=eq." + nickname.uri_encode() + "&select=Nickname"
	var headers = [
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY
	]
	var http = HTTPRequest.new()
	add_child(http)

	http.request(url, headers, HTTPClient.METHOD_GET)

	var response = await http.request_completed
	var response_code = response[1]
	var body = response[3].get_string_from_utf8()

	http.queue_free()

	if response_code == 200:
		var data = JSON.parse_string(body)
		return data is Array and data.size() > 0
	else:
		print("Ошибка проверки ника! Код: ", response_code)
		return false