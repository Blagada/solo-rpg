extends Control
class_name GameManager

@export var utiliser_claude: bool = false

# --- UI ---
@onready var ui: UIController = $MainLayout
@onready var input_text: LineEdit = $MainLayout/InputLayout/InputText

# --- script ---
@onready var prompt_manager: PromptManager = $PromptManager
# --- API ---
@onready var gemini_client: GeminiClient = $GeminiClient
@onready var claude_client: ClaudeClient = $ClaudeClient
@onready var client: Node = claude_client if utiliser_claude else gemini_client


var system_prompt: String = ""
# ne pas envoyer de réponse si en attente d'un tirage manuel
var attente_tirage_manuel: bool = false
# On s'assure de ne pas envoyer plusieurs requêtes si le joueur pèse plusieurs fois sur Enter ou Envoyer
var envoi_en_cours: bool = false

func _ready()-> void:
	# 1. On connecte le signal
	client.reponse_recue.connect(_on_reponse_ia)
	client.erreur_recue.connect(_on_erreur_ia)
	print("--- CLIENT API ACTIF : ", "Claude" if utiliser_claude else "Gemini", " ---")

	# 2. On génère le prompt système au début
	_regenerer_system_prompt()

	# 3. On prépare le contenu initial
	if GameData.conversation_history.is_empty():
		# Nouvelle aventure : on lance le premier tour
		ui.afficher_message("Système ", "La partie peut commencer.")
		var messages: Array[Dictionary] = prompt_manager.construire_contenu([])
		client.envoyer_requete(messages, system_prompt, GameData.config_tarot_model, attente_tirage_manuel)
		attente_tirage_manuel = false
	else:
		# Aventure chargée : on réaffiche l'historique, aucun appel API
		ui.afficher_message("Système ", "Aventure reprise.")
		for message: Dictionary in GameData.conversation_history:
			var auteur: String = "Vous" if message["role"] == "user" else "DM"
			ui.afficher_message(auteur, message["text"])


func _regenerer_system_prompt() -> void:
	system_prompt = prompt_manager.generer_system_prompt(
		GameData.config_universe,
		GameData.config_precisions,
		GameData.character_gender,
		GameData.character_age,
		GameData.config_tarot_model,
		GameData.config_is_auto_draw,
		GameData.world_current_state,
		utiliser_claude
	)


func _on_reponse_ia(texte_ia: String, nouvel_etat: String, tools_declenches: Dictionary) -> void:
	ui.basculer_indicateur_pense(false)
	envoi_en_cours = false

	if tools_declenches.get("moment_charniere", false) and not GameData.config_is_auto_draw and not tools_declenches.has("tarot"):
		ui.afficher_message("Système", "🎴 Moment charnière — tire une carte et dis-moi laquelle.")
		attente_tirage_manuel = true
	
	if tools_declenches.has("tarot"):
		var carte = tools_declenches["tarot"]["nom_carte"]
		ui.afficher_message("Système", "Carte tirée : " + carte)

	if nouvel_etat != "":
		GameData.world_current_state = nouvel_etat
		_regenerer_system_prompt()

	if GameData.config_universe == "" and tools_declenches.has("univers_invente"):
		GameData.config_universe = tools_declenches["univers_invente"]
	if tools_declenches.has("nom_personnage"):
		GameData.character_name = tools_declenches["nom_personnage"]
	if tools_declenches.has("profession"):
		GameData.character_profession = tools_declenches["profession"]

	ui.afficher_message("DM", texte_ia)
	GameData.conversation_history.append({"role": "assistant", "text": texte_ia})
	SaveManager.sauvegarder_partie()

func _on_send_button_pressed() -> void:
	_gerer_envoi()


func _on_input_text_text_submitted(_text: String) -> void:
	_gerer_envoi()


func _gerer_envoi() -> void:
	# Empêche de faire un appel lorsqu'il y a un envoi en cours
	if envoi_en_cours:
		return

	var texte_joueur = ui.input_text.text
	if texte_joueur != "":
		envoi_en_cours = true
		ui.afficher_message("Vous", texte_joueur)
		ui.clear_input()
		ui.basculer_indicateur_pense(true)

		# 1. On stocke le message du joueur (format neutre)
		GameData.conversation_history.append({"role": "user", "text": texte_joueur})

		var contenu_final = prompt_manager.construire_contenu(GameData.conversation_history)

		client.envoyer_requete(contenu_final, system_prompt, GameData.config_tarot_model, attente_tirage_manuel)
		attente_tirage_manuel = false

		# Repositionne le focus sur le champ de saisie après avoir fait un envoi
		get_viewport().gui_release_focus()
		await get_tree().process_frame
		input_text.grab_focus()


func _on_erreur_ia(code: int) -> void:
	# C'est ici que tu vas enfin voir les erreurs en rouge
	printerr("Code erreur reçu : ", code)
	envoi_en_cours = false
	
	if code == 429:
		printerr("Détail : Trop de requêtes (Quota dépassé).")
	elif code == 503:
		printerr("Détail : Serveur Google indisponible (Surcharge).")
	elif code == 400:
		printerr("Détail : Requête mal formée (Vérifie ton JSON).")
	else:
		printerr("Détail : Erreur non identifiée.")
