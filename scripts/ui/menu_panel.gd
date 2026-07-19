extends Control
class_name MenuFicheController

@onready var fiche: PanelContainer = $TabContainer/Fiche/Fiche


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible and fiche:
		fiche.actualiser()


func _on_close_button_pressed() -> void:
	visible = false


func _on_exit_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Principales/main_menu.tscn")
