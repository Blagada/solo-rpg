extends Control
class_name MainMenu


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_new_pressed() -> void:
	# On change de scène pour aller vers ta scène de configuration
	get_tree().change_scene_to_file("res://scenes/configuration_jeu.tscn")


func _on_new_random_pressed() -> void:
	# On change de scène pour aller vers ta scène de configuration
	get_tree().change_scene_to_file("res://scenes/solo_rpg.tscn")
