extends Node
class_name GeminiClient

signal reponse_recue(texte_ia)
signal erreur_recue(code)

@onready var http_request: HTTPRequest = $APIRequest

const API_KEY = "REMPLACER_PAR_VOTRE_CLE_ICI"
const MODEL_NAME = "gemini-2.5-flash"
const API_URL = "https://generativelanguage.googleapis.com/v1beta/models/" + MODEL_NAME + ":generateContent?key=" + API_KEY

func envoyer_requete(historique):
	var body = {"contents": historique}
	var json_body = JSON.stringify(body)
	var headers = ["Content-Type: application/json"]
	http_request.request(API_URL, headers, HTTPClient.METHOD_POST, json_body)


func _on_api_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var ai_text = json["candidates"][0]["content"]["parts"][0]["text"]
		reponse_recue.emit(ai_text)
	else:
		# AFFICHE CE QUE LE SERVEUR TE DIT
		print("Réponse serveur : ", body.get_string_from_utf8())
		erreur_recue.emit(response_code)
