extends Node
class_name GeminiClient

signal reponse_recue(texte_ia)
signal erreur_recue(code)

@onready var http_request: HTTPRequest = $APIRequest

const MODEL_NAME = "gemini-2.5-flash"
const SECRETS_PATH = "res://secrets.cfg"

var api_key: String = ""

func _ready() -> void:
	api_key = _charger_cle_api()

func _charger_cle_api() -> String:
	# 1. Priorité à la variable d'environnement (pratique en dev, et seule option viable
	#    si un jour ce jeu tourne derrière un serveur relais plutôt qu'en local).
	var env_key = OS.get_environment("GEMINI_API_KEY")
	if env_key != "":
		return env_key

	# 2. Sinon, fichier local non versionné (voir secrets.cfg.example + .gitignore)
	var config = ConfigFile.new()
	var err = config.load(SECRETS_PATH)
	if err == OK:
		return config.get_value("api", "gemini_key", "")

	push_error("Clé API introuvable. Copie secrets.cfg.example vers secrets.cfg et remplis ta clé, ou définis la variable d'environnement GEMINI_API_KEY.")
	return ""

func envoyer_requete(historique):
	if api_key == "":
		erreur_recue.emit(-1)
		return
	var url = "https://generativelanguage.googleapis.com/v1beta/models/" + MODEL_NAME + ":generateContent?key=" + api_key
	var body = {"contents": historique}
	var json_body = JSON.stringify(body)
	var headers = ["Content-Type: application/json"]
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)


func _on_api_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var ai_text = json["candidates"][0]["content"]["parts"][0]["text"]
		reponse_recue.emit(ai_text)
	else:
		# AFFICHE CE QUE LE SERVEUR TE DIT
		print("Réponse serveur : ", body.get_string_from_utf8())
		erreur_recue.emit(response_code)
