extends Control
class_name MainMenu

@onready var continue_button: Button = $VBoxContainer/ContinueButton


func _ready() -> void:
	continue_button.disabled = not SaveManager.une_sauvegarde_existe()

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_new_pressed() -> void:
	# On remet l'histoiree et l'état de la partie à vide, pour ne pas que la nouvelle partie relance l'ancienne
	GameData.conversation_history = []
	GameData.world_current_state = ""
	# On change de scène pour aller vers la scène de configuration
	get_tree().change_scene_to_file("res://scenes/Principales/configuration_jeu.tscn")


func _on_continue_pressed() -> void:
	# Appel les données de l'ancienne partie, et envoie directement à la scène de conversation
	if SaveManager.charger_partie():
		get_tree().change_scene_to_file("res://scenes/Principales/solo_rpg.tscn")
