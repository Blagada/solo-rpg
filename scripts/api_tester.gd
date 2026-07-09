# ---------------------------------------------
# Script qui permet de valider si le model et la clé fonctionne.
# Gemini renvoie "Connexion établie" si ça à foncitonné, sinon renvoie un message d'erreur.
#----------------------------------------------
extends Node

# Remplace par ta vraie clé API ici
const API_KEY = "REMPLACER_PAR_VOTRE_CLE_ICI"
const MODEL_NAME = "gemini-2.5-flash" 
const API_URL = "https://generativelanguage.googleapis.com/v1beta/models/" + MODEL_NAME + ":generateContent?key=" + API_KEY

func _ready():
	# On crée une requête HTTP
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	# On prépare le message pour Gemini
	var body = {
		"contents": [{
			"parts": [{"text": "Bonjour, je suis un RPG textuel. Dis-moi 'Connexion établie' si tu me reçois !"}]
		}]
	}
	
	# Conversion en JSON
	var json_body = JSON.stringify(body)
	var headers = ["Content-Type: application/json"]
	
	# Envoi de la requête
	var error = http_request.request(API_URL, headers, HTTPClient.METHOD_POST, json_body)
	
	if error != OK:
		print("Erreur lors de l'envoi de la requête")

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var response_text = json["candidates"][0]["content"]["parts"][0]["text"]
		print("Réponse de Gemini : ", response_text)
	else:
		print("Erreur de connexion, code : ", response_code)
		print("Détails : ", body.get_string_from_utf8())
