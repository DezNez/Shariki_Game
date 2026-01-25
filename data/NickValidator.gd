extends Node
class_name NickValidator

var banwords := {}

func _ready():
	_load_banwords()

func _load_banwords():
	var file := FileAccess.open("res://data/banwords.txt", FileAccess.READ)
	if file == null:
		push_error("Banwords file not found")
		return

	while not file.eof_reached():
		var w := file.get_line().strip_edges()
		if w != "":
			banwords[w] = true

	file.close()

func normalize(nick: String) -> String:
	nick = nick.to_lower()
	var out := ""
	for c in nick:
		if (c >= "a" and c <= "z") or (c >= "0" and c <= "9"):
			out += c
	return out

func is_valid(raw_nick: String) -> bool:
	var clean := normalize(raw_nick)

	if clean.length() < 4 or clean.length() > 12:
		return false

	if clean.is_valid_int():
		return false

	if clean.find("1488") != -1:
		return false

	if clean.find("aaaa") != -1:
		return false

	if clean.match(".*\\d{5,}.*"):
		return false

	if clean == "":
		return false
		
	for bad in banwords.keys():
		if clean.find(bad) != -1:
			return false

	return true
