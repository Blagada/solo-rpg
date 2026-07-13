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


func _ready():
	# 1. On connecte le signal
	client.reponse_recue.connect(_on_reponse_ia)
	client.erreur_recue.connect(_on_erreur_ia)
	print("--- CLIENT API ACTIF : ", "Claude" if utiliser_claude else "Gemini", " ---")

	# 2. On génère le prompt système au début
	_regenerer_system_prompt()

	# 3. On prépare le contenu initial
	if GameData.historique_partie.is_empty():
		# Nouvelle aventure : on lance le premier tour
		ui.afficher_message("Système ", "La partie peut commencer.")
		var messages = prompt_manager.construire_contenu([])
		client.envoyer_requete(messages, system_prompt, GameData.type_tarot)
	else:
		# Aventure chargée : on réaffiche l'historique, aucun appel API
		ui.afficher_message("Système ", "Aventure reprise.")
		for message in GameData.historique_partie:
			var auteur = "Vous" if message["role"] == "user" else "DM"
			ui.afficher_message(auteur, message["text"])


func _regenerer_system_prompt() -> void:
	system_prompt = prompt_manager.generer_system_prompt(
		GameData.univers_choisi,
		GameData.precisions,
		GameData.genre_perso,
		GameData.age_perso,
		GameData.type_tarot,
		GameData.tirage_auto,
		GameData.etat_partie,
		utiliser_claude
	)


func _on_reponse_ia(texte_ia: String, nouvel_etat: String, tools_declenches: Dictionary):
	ui.basculer_indicateur_pense(false)
	ui.afficher_message("DM", texte_ia)
	GameData.historique_partie.append({"role": "assistant", "text": texte_ia})

	if nouvel_etat != "":
		GameData.etat_partie = nouvel_etat
		# Envoi la réponse dans de l'IA dans la conversation
		_regenerer_system_prompt()

	if GameData.univers_choisi == "" and tools_declenches.has("univers_invente"):
		GameData.univers_choisi = tools_declenches["univers_invente"]
	if tools_declenches.has("nom_personnage"):
		GameData.nom_perso = tools_declenches["nom_personnage"]
	if tools_declenches.has("profession"):
		GameData.profession_perso = tools_declenches["profession"]

	# Sauvegarde automatiquement la partie après la réponse de l'IA
	SaveManager.sauvegarder_partie()

func _on_send_button_pressed():
	_gerer_envoi()


func _on_input_text_text_submitted(_text: String):
	_gerer_envoi()


func _gerer_envoi():
	var texte_joueur = ui.input_text.text
	if texte_joueur != "":
		ui.afficher_message("Vous", texte_joueur)
		ui.clear_input()
		ui.basculer_indicateur_pense(true)

		# 1. On stocke le message du joueur (format neutre)
		GameData.historique_partie.append({"role": "user", "text": texte_joueur})

		var contenu_final = prompt_manager.construire_contenu(GameData.historique_partie)

		client.envoyer_requete(contenu_final, system_prompt, GameData.type_tarot)

		get_viewport().gui_release_focus()
		await get_tree().process_frame
		input_text.grab_focus()


func _on_erreur_ia(code):
	# C'est ici que tu vas enfin voir les erreurs en rouge
	printerr("--- ALERTE ERREUR IA ---")
	printerr("Code erreur reçu : ", code)
	
	if code == 429:
		printerr("Détail : Trop de requêtes (Quota dépassé).")
	elif code == 503:
		printerr("Détail : Serveur Google indisponible (Surcharge).")
	elif code == 400:
		printerr("Détail : Requête mal formée (Vérifie ton JSON).")
	else:
		printerr("Détail : Erreur non identifiée.")
