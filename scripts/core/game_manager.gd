extends Control
class_name GameManager

@onready var ui: UIController = $MainLayout
@onready var gemini_client: GeminiClient = $GeminiClient
@onready var input_text: LineEdit = $MainLayout/InputLayout/InputText
@onready var prompt_manager: PromptManager = $PromptManager

var historique_partie = []
var system_prompt: String = ""

func _ready():
	# 1. On connecte le signal
	gemini_client.reponse_recue.connect(_on_reponse_ia)
	gemini_client.erreur_recue.connect(_on_erreur_ia)
	remplir_donnees_par_defaut()
	# 2. On génère le prompt système au début
	_regenerer_system_prompt()

	# 3. On prépare le contenu initial (historique vide au départ)
	var messages = prompt_manager.construire_contenu([])

	# 4. On envoie la requête initiale pour lancer l'aventure
	ui.afficher_message("Système ", "La partie peu commencer.")
	# Dans _ready(), la ligne d'envoi initial change :
	gemini_client.envoyer_requete(messages, system_prompt)

# Nouvelle fonction à ajouter dans game_manager.gd

func _regenerer_system_prompt() -> void:
	system_prompt = prompt_manager.generer_system_prompt(
		GameData.univers_choisi,
		GameData.precisions,
		GameData.genre_joueur,
		GameData.age_joueur,
		GameData.type_tarot,
		GameData.tirage_auto,
		GameData.etat_partie
	)

# Dans _on_reponse_ia(), juste après avoir affiché le message à l'écran

func _on_reponse_ia(texte_ia: String, nouvel_etat: String):
	ui.basculer_indicateur_pense(false)
	ui.afficher_message("DM", texte_ia)

	# On ajoute aussi la réponse du MJ à l'historique — sinon le modèle
	# ne revoit jamais ses propres réponses précédentes.
	historique_partie.append({"role": "assistant", "text": texte_ia})

	if nouvel_etat != "":
		GameData.etat_partie = nouvel_etat
		print("--- ÉTAT SAUVEGARDÉ DANS GAMEDATA ---")
		print(GameData.etat_partie)
		print("---------------------------------------")
		_regenerer_system_prompt()


func _on_send_button_pressed():
	_gerer_envoi()


func _on_input_text_text_submitted(_text: String):
	_gerer_envoi()

func remplir_donnees_par_defaut():
	if GameData.age_joueur <= 0:
		GameData.age_joueur = randi_range(13, 99) # Âge aléatoire entre 13 et 99
		
	if GameData.genre_joueur == "":
		var genres = ["masculin", "féminin", "autre"]
		GameData.genre_joueur = genres.pick_random()
		
	if GameData.univers_choisi == "":
		GameData.univers_choisi = "médiéval fantastique"

# Dans _gerer_envoi(), remplace le bloc complet par celui-ci

func _gerer_envoi():
	var texte_joueur = ui.input_text.text
	if texte_joueur != "":
		ui.afficher_message("Vous", texte_joueur)
		ui.clear_input()
		ui.basculer_indicateur_pense(true)

		# 1. On stocke le message du joueur (format neutre)
		historique_partie.append({"role": "user", "text": texte_joueur})

		# 2. On construit le contenu avec le PromptManager (ne gère plus le system_prompt)
		var contenu_final = prompt_manager.construire_contenu(historique_partie)

		# 3. On envoie, system_prompt passé séparément
		gemini_client.envoyer_requete(contenu_final, system_prompt)

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
