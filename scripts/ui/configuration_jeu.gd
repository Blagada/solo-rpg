extends Control
class_name ConfigurationJeu

@onready var form_container: VBoxContainer = $VBoxContainer/FormContainer

@onready var univers_options: OptionButton = $VBoxContainer/FormContainer/Univers/UniversOptions
@onready var univers_precision: LineEdit = $VBoxContainer/FormContainer/UniversPrecision
@onready var gender_options: OptionButton = $VBoxContainer/FormContainer/Gender/GenderOptions
@onready var age_input: SpinBox = $VBoxContainer/FormContainer/Age/AgeInput
@onready var age_random_check: CheckButton = $VBoxContainer/FormContainer/Age/AgeRandomCheck
@onready var tarot_check: CheckButton = $VBoxContainer/FormContainer/TarotCheck



func _ready() -> void:
	_remplir_dropdown_univers()


func _remplir_dropdown_univers() -> void:
	univers_options.clear()

	# univers_options.get_popup().add_separator("Univers existants")
	# for univers in bibliotheque_univers: univers_options.add_item(univers.nom)

	univers_options.add_item("Aléatoire")
	univers_options.get_popup().add_separator("Univers général")
	for nom: String in GameData.AVAILABLE_UNIVERSES:
		univers_options.add_item(nom)


func _on_start_pressed() -> void:
	var univers_selectionne: String = univers_options.get_item_text(univers_options.selected)
	GameData.config_universe = GameData.AVAILABLE_UNIVERSES.pick_random() as String if univers_selectionne == "Aléatoire" else univers_selectionne

	var genre_selectionne: String = gender_options.get_item_text(gender_options.selected)
	GameData.character_gender = GameData.AVAILABLE_GENDERS.pick_random() as String if genre_selectionne == "Aléatoire" else genre_selectionne

	# Calcul de l'âge
	var age: float = randfn(32.5, 12.5) if age_random_check.button_pressed else age_input.value
	GameData.character_age = int(clamp(round(age), 13, 99))

	GameData.config_precisions = univers_precision.text
	GameData.config_is_auto_draw = tarot_check.button_pressed

	get_tree().change_scene_to_file("res://scenes/Principales/solo_rpg.tscn")
