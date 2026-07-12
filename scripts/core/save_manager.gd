extends Node

const SAVE_PATH = "user://sauvegarde_partie.json"

func sauvegarder_partie() -> void:
	# va chercher tous les paramètres de la partie en cours, l'état de la partie et aussi l'historique de conversation.
	var data = {
		"univers_choisi": GameData.univers_choisi,
		"precisions": GameData.precisions,
		"genre_joueur": GameData.genre_joueur,
		"age_joueur": GameData.age_joueur,
		"type_tarot": GameData.type_tarot,
		"tirage_auto": GameData.tirage_auto,
		"etat_partie": GameData.etat_partie,
		"historique_partie": GameData.historique_partie
	}
	# Sauvegarde des donné (data) dans un JSON
	var fichier = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if fichier:
		fichier.store_string(JSON.stringify(data))
		fichier.close()
		print("--- PARTIE SAUVEGARDÉE ---")
	else:
		push_error("Impossible d'écrire la sauvegarde.")


func une_sauvegarde_existe() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func charger_partie() -> bool:
	# Pas de sauvegarde
	if not une_sauvegarde_existe():
		return false

	# Renvoie les données de la dernière aventure, à partir du fichier JSON
	var fichier = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var contenu = fichier.get_as_text()
	fichier.close()

	var data = JSON.parse_string(contenu)
	if data == null:
		push_error("Sauvegarde corrompue.")
		return false

	GameData.univers_choisi = data.get("univers_choisi", "")
	GameData.precisions = data.get("precisions", "")
	GameData.genre_joueur = data.get("genre_joueur", "")
	GameData.age_joueur = data.get("age_joueur", 25)
	GameData.type_tarot = data.get("type_tarot", "marseille")
	GameData.tirage_auto = data.get("tirage_auto", true)
	GameData.etat_partie = data.get("etat_partie", "")
	GameData.historique_partie = data.get("historique_partie", [])
	print("--- CHARGEMENT : historique contient ", GameData.historique_partie.size(), " messages ---")
	return true
