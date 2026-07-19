extends Node

const SAVE_PATH: String = "user://sauvegarde_partie.json"

func sauvegarder_partie() -> void:
	# va chercher tous les paramètres de la partie en cours, l'état de la partie et aussi l'historique de conversation.
	var data: Dictionary = {
		"config_universe": GameData.config_universe,
		"config_precisions": GameData.config_precisions,
		"character_gender": GameData.character_gender,
		"character_age": GameData.character_age,
		"config_tarot_model": GameData.config_tarot_model,
		"config_is_auto_draw": GameData.config_is_auto_draw,
		"world_current_state": GameData.world_current_state,
		"conversation_history": GameData.conversation_history,
		"character_name": GameData.character_name,
		"character_profession": GameData.character_profession
	}
	# Sauvegarde des donné (data) dans un JSON
	var fichier: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
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
		push_error("Aucune sauvegarde trouvée.")
		return false

	# Renvoie les données de la dernière aventure, à partir du fichier JSON
	var fichier: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not fichier:
		push_error("Erreur d'accès au fichier.")
		return false

	var contenu: String = fichier.get_as_text()
	fichier.close()

	var data: Variant = JSON.parse_string(contenu)
	if not data is Dictionary:
		push_error("Sauvegarde corrompue.")
		return false

	GameData.config_universe = data.get("config_universe", "") as String
	GameData.config_precisions = data.get("config_precisions", "") as String
	GameData.config_tarot_model = data.get("config_tarot_model", "marseille") as String
	GameData.config_is_auto_draw = data.get("config_is_auto_draw", true) as bool
	
	GameData.character_gender = data.get("character_gender", "") as String
	GameData.character_age = data.get("character_age", 25) as int
	GameData.character_name = data.get("character_name", "") as String
	GameData.character_profession = data.get("character_profession", "") as String
	
	GameData.world_current_state = data.get("world_current_state", "") as String

	var temp_history = data.get("conversation_history", [])
	if temp_history is Array:
		GameData.conversation_history.assign(temp_history)
	return true
