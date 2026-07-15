extends Node
class_name ClaudeClient

signal reponse_recue(texte_ia, nouvel_etat, tools_declenches: Dictionary)
signal erreur_recue(code)

@onready var http_request: HTTPRequest = $APIRequest

const MODEL_NAME = "claude-haiku-4-5-20251001"
const API_URL = "https://api.anthropic.com/v1/messages"
const ANTHROPIC_VERSION = "2023-06-01"
const SECRETS_PATH = "res://secrets.cfg"
const MAX_TOKENS = 1024

const TOOL_ETAT = {
	"name": "mettre_a_jour_etat",
	"description": "Met à jour le résumé persistant de l'état de la partie (lieu, objets, PNJ, objectif, événements marquants). À appeler à chaque tour.",
	"input_schema": {
		"type": "object",
		"properties": {
			"etat": {
				"type": "string",
				"description": "Résumé condensé et autonome de la situation actuelle, 2-4 phrases maximum."
			}
		},
		"required": ["etat"]
	}
}

const TOOL_REPONSE = {
	"name": "repondre_joueur",
	"description": "Utilise CET outil pour structurer CHAQUE réponse au joueur, sans exception.",
	"input_schema": {
		"type": "object",
		"properties": {
			"narration": {"type": "string", "description": "Le texte narratif complet à afficher au joueur."},
			"etat": {"type": "string", "description": "Résumé condensé de la situation, incluant TOUT fait pertinent déjà établi — y compris ce que le personnage sait ou a compris (pas seulement les objets et lieux physiques)."},
			"carte_tiree": {
				"type": "object",
				"description": "Uniquement si un tirage a lieu ce tour (moments charnières). Omets sinon.",
				"properties": {
					"nom_carte": {"type": "string"},
					"consequence_narrative": {"type": "string"}
				}
			},
		},
		"required": ["narration", "etat"]
	}
}

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


func envoyer_requete(historique: Array, system_prompt: String, type_tarot: String, forcer_carte: bool = false) -> void:

	if api_key == "":
		erreur_recue.emit(-1)
		return

	var body = {
		"model": MODEL_NAME,
		"max_tokens": MAX_TOKENS,
		"system": system_prompt,
		"messages": _traduire_vers_claude(historique),
		"tools": _construire_tools(type_tarot, forcer_carte),
		"tool_choice": {"type": "tool", "name": "repondre_joueur"}
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


func _construire_tools(type_tarot: String, forcer_carte: bool = false) -> Array:
	var noms_cartes = _charger_noms_cartes(type_tarot)
	var champs_requis = ["narration", "etat", "moment_charniere"]
	if forcer_carte:
		champs_requis.append("carte_tiree")
	
	return [{
		"name": "repondre_joueur",
		"description": "Utilise CET outil pour structurer CHAQUE réponse au joueur, sans exception.",
		"input_schema": {
			"type": "object",
			"properties": {
				"narration": {
					"type": "string",
					"description": "Le texte narratif complet à afficher au joueur."
				},
				"etat": {
					"type": "string",
					"description": "Résumé condensé de la situation, incluant TOUT fait pertinent déjà établi — y compris ce que le personnage sait ou a compris (pas seulement les objets et lieux physiques)."
				},
				"carte_tiree": {
					"type": "object",
					"description": "Uniquement si un tirage a lieu ce tour (moments charnières). Omets ce champ sinon.",
					"properties": {
						"nom_carte": {"type": "string", "enum": noms_cartes},
						"consequence_narrative": {"type": "string"}
					}
				},
				"moment_charniere": {
					"type": "boolean",
					"description": "true si CE tour correspond à un moment charnière justifiant un tirage de tarot (rencontre déterminante, choix important, obstacle majeur), false sinon."
				},
				"univers_invente": {
					"type": "string",
					"description": "Uniquement si l'univers n'était pas déjà précisé par le joueur : indique en quelques mots l'univers que tu viens d'inventer pour cette partie."
				},
				"nom_personnage": {"type": "string", "description": "Le nom du personnage joueur, dès qu'il est établi ou confirmé dans la narration."},
				"profession": {"type": "string", "description": "La profession/le métier du personnage, dès qu'il est établi ou confirmé dans la narration."}
			},
			"required": champs_requis
		}
	}]


func _charger_noms_cartes(type_tarot: String) -> Array:
	var noms = []
	var chemin = "res://ressources/" + type_tarot + "/"
	var dir = DirAccess.open(chemin)

	if dir == null:
		push_error("Dossier de cartes introuvable : " + chemin)
		return noms

	dir.list_dir_begin()
	var fichier = dir.get_next()
	while fichier != "":
		if fichier.ends_with(".tres"):
			var carte = load(chemin + fichier) as TarotCards
			if carte:
				noms.append(carte.nom)
		fichier = dir.get_next()

	return noms


func _on_api_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var blocs = json["content"]

		var narration = ""
		var nouvel_etat = ""
		var tools_declenches = {}

		for bloc in blocs:
			if bloc["type"] == "tool_use" and bloc["name"] == "repondre_joueur":
				narration = bloc["input"].get("narration", "")
				nouvel_etat = bloc["input"].get("etat", "")
				if bloc["input"].has("carte_tiree"):
					tools_declenches["tarot"] = bloc["input"]["carte_tiree"]
				if bloc["input"].has("univers_invente"):
					tools_declenches["univers_invente"] = bloc["input"]["univers_invente"]
				if bloc["input"].has("nom_personnage"):
					tools_declenches["nom_personnage"] = bloc["input"]["nom_personnage"]
				if bloc["input"].has("profession"):
					tools_declenches["profession"] = bloc["input"]["profession"]
				if bloc["input"].has("moment_charniere"):
					tools_declenches["moment_charniere"] = bloc["input"]["moment_charniere"]

		reponse_recue.emit(narration, nouvel_etat, tools_declenches)
	else:
		print("Réponse serveur (Claude) : ", body.get_string_from_utf8())
		erreur_recue.emit(response_code)
