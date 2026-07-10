extends Node
class_name ClaudeClient

signal reponse_recue(texte_ia, nouvel_etat)
signal erreur_recue(code)

@onready var http_request: HTTPRequest = $APIRequest

const MODEL_NAME = "claude-haiku-4-5-20251001"
const API_URL = "https://api.anthropic.com/v1/messages"
const ANTHROPIC_VERSION = "2023-06-01"
const SECRETS_PATH = "res://secrets.cfg"
const MAX_TOKENS = 1024

var api_key: String = ""

func _ready() -> void:
	api_key = _charger_cle_api()

func _charger_cle_api() -> String:
	var env_key = OS.get_environment("CLAUDE_API_KEY")
	if env_key != "":
		return env_key

	var config = ConfigFile.new()
	var err = config.load(SECRETS_PATH)
	if err == OK:
		return config.get_value("api", "claude_key", "")

	push_error("Clé API Claude introuvable. Ajoute 'claude_key' dans secrets.cfg, ou définis CLAUDE_API_KEY.")
	return ""

# Remplace toute la fonction envoyer_requete par celle-ci

func envoyer_requete(historique: Array, system_prompt: String) -> void:
	if api_key == "":
		erreur_recue.emit(-1)
		return

	var body = {
		"model": MODEL_NAME,
		"max_tokens": MAX_TOKENS,
		"system": system_prompt,
		"messages": _traduire_vers_claude(historique)
	}
	var json_body = JSON.stringify(body)
	var headers = [
		"Content-Type: application/json",
		"x-api-key: " + api_key,
		"anthropic-version: " + ANTHROPIC_VERSION
	]

	var resultat_envoi = http_request.request(API_URL, headers, HTTPClient.METHOD_POST, json_body)
	if resultat_envoi != OK:
		printerr("--- ÉCHEC DE L'ENVOI DE LA REQUÊTE (Claude) ---")
		printerr("Code d'erreur Godot : ", resultat_envoi)

func _traduire_vers_claude(historique: Array) -> Array:
	var contenu = []
	for message in historique:
		contenu.append({"role": message["role"], "content": message["text"]})
	return contenu

func _on_api_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var texte_brut = json["content"][0]["text"]

		print("--- TEXTE BRUT REÇU DE CLAUDE ---")
		print(texte_brut)
		print("----------------------------------")

		var contenu_parse = JSON.parse_string(_extraire_json(texte_brut))
		if contenu_parse != null and typeof(contenu_parse) == TYPE_DICTIONARY and contenu_parse.has("narration"):
			print("--- NOUVEL ÉTAT EXTRAIT (Claude) ---")
			print(contenu_parse.get("etat", "(aucun champ etat reçu)"))
			print("--------------------------------------")
			reponse_recue.emit(contenu_parse["narration"], contenu_parse.get("etat", ""))
		else:
			push_warning("Réponse Claude non conforme au format JSON attendu, repli en texte brut.")
			reponse_recue.emit(texte_brut, "")
	else:
		print("Réponse serveur (Claude) : ", body.get_string_from_utf8())
		erreur_recue.emit(response_code)

func _extraire_json(texte: String) -> String:
	var nettoye = texte.strip_edges()
	if nettoye.begins_with("```"):
		nettoye = nettoye.trim_prefix("```json").trim_prefix("```").trim_suffix("```").strip_edges()
	return nettoye
