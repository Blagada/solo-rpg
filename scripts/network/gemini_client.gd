extends Node
class_name GeminiClient

signal reponse_recue(texte_ia, nouvel_etat)
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


func envoyer_requete(historique: Array, system_prompt: String, type_tarot: String = "") -> void:
	if api_key == "":
		erreur_recue.emit(-1)
		return

	var url = "https://generativelanguage.googleapis.com/v1beta/models/" + MODEL_NAME + ":generateContent?key=" + api_key
	var contenu_gemini = _traduire_vers_gemini(historique, system_prompt)
	var body = {"contents": contenu_gemini}
	var json_body = JSON.stringify(body)
	var headers = ["Content-Type: application/json"]

	var resultat_envoi = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if resultat_envoi != OK:
		printerr("--- ÉCHEC DE L'ENVOI DE LA REQUÊTE (Gemini) ---")
		printerr("Code d'erreur Godot : ", resultat_envoi)


func _traduire_vers_gemini(historique: Array, system_prompt: String) -> Array:
	# Gemini n'a pas de champ système dédié : on le glisse dans le tout
	# premier message, comme avant. Chaque client cache ce détail pour
	# le reste du jeu, qui n'a plus à s'en soucier.
	var contenu = []

	for i in range(historique.size()):
		var message = historique[i]
		var texte = message["text"]

		if i == 0:
			texte = "SYSTEM_INSTRUCTION: " + system_prompt + "\n\n" + texte

		var role_gemini = "model" if message["role"] == "assistant" else "user"
		contenu.append({"role": role_gemini, "parts": [{"text": texte}]})

	return contenu


func _on_api_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var texte_brut = json["candidates"][0]["content"]["parts"][0]["text"]

		print("--- TEXTE BRUT REÇU DE GEMINI ---")
		print(texte_brut)
		print("----------------------------------")

		var contenu_parse = JSON.parse_string(_extraire_json(texte_brut))
		if contenu_parse != null and typeof(contenu_parse) == TYPE_DICTIONARY and contenu_parse.has("narration"):
			print("--- NOUVEL ÉTAT EXTRAIT ---")
			print(contenu_parse.get("etat", "(aucun champ etat reçu)"))
			print("----------------------------")
			reponse_recue.emit(contenu_parse["narration"], contenu_parse.get("etat", ""))
		else:
			push_warning("Réponse du modèle non conforme au format JSON attendu, repli en texte brut.")
			reponse_recue.emit(texte_brut, "")
	else:
		# AFFICHE CE QUE LE SERVEUR TE DIT
		print("Réponse serveur : ", body.get_string_from_utf8())
		erreur_recue.emit(response_code)


func _extraire_json(texte: String) -> String:
	# Sécurité : le modèle entoure parfois le JSON de ```json ... ``` malgré
	# la consigne (vu dans ta capture d'écran). On nettoie avant de parser.
	var nettoye = texte.strip_edges()
	if nettoye.begins_with("```"):
		nettoye = nettoye.trim_prefix("```json").trim_prefix("```").trim_suffix("```").strip_edges()
	return nettoye
