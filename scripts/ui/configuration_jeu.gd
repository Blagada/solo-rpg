extends Control
@onready var univers_options: OptionButton = $VBoxContainer/Univers/UniversOptions
@onready var univers_precision: LineEdit = $VBoxContainer/UniversPrecision
@onready var tarot_options: OptionButton = $VBoxContainer/Tarot/TarotOptions
@onready var gender_options: OptionButton = $VBoxContainer/Gender/GenderOptions
@onready var tarot_check: CheckButton = $VBoxContainer/TarotCheck
@onready var age_input: SpinBox = $VBoxContainer/Age/AgeInput



func _on_start_pressed() -> void:
		# On stocke tout dans le Singleton
	GameData.univers_choisi = univers_options.get_item_text(univers_options.selected)
	GameData.precisions = univers_precision.text
	GameData.genre_joueur = gender_options.get_item_text(gender_options.selected)
	GameData.age_joueur = int(age_input.value)
	GameData.type_tarot = tarot_options.get_item_text(tarot_options.selected)
	GameData.tirage_auto = tarot_check.button_pressed

	# On lance la scène principale du jeu
	get_tree().change_scene_to_file("res://scenes/solo_rpg.tscn")
