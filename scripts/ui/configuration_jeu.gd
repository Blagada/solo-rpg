extends Control

@onready var form_container: VBoxContainer = $VBoxContainer/FormContainer

@onready var univers_options: OptionButton = $VBoxContainer/FormContainer/Univers/UniversOptions
@onready var univers_precision: LineEdit = $VBoxContainer/FormContainer/UniversPrecision
@onready var gender_options: OptionButton = $VBoxContainer/FormContainer/Gender/GenderOptions
@onready var age_input: SpinBox = $VBoxContainer/FormContainer/Age/AgeInput
@onready var age_random_check: CheckButton = $VBoxContainer/FormContainer/Age/AgeRandomCheck
@onready var tarot_check: CheckButton = $VBoxContainer/FormContainer/TarotCheck

const TAROT_PAR_DEFAUT = "marseille"

func _ready() -> void:
	_remplir_dropdown_univers()


func _remplir_dropdown_univers() -> void:
	univers_options.clear()

	# univers_options.get_popup().add_separator("Univers existants")
	# for univers in bibliotheque_univers: univers_options.add_item(univers.nom)

	univers_options.add_item("Aléatoire")
	univers_options.get_popup().add_separator("Univers général")
	for nom in GameData.UNIVERS_PAR_DEFAUT:
		univers_options.add_item(nom)


func _on_start_pressed() -> void:
	var genres_possibles = ["masculin", "féminin", "neutre"]

	var univers = univers_options.get_item_text(univers_options.selected)
	GameData.univers_choisi = GameData.UNIVERS_PAR_DEFAUT.pick_random() if univers == "Aléatoire" else univers

	var genre = gender_options.get_item_text(gender_options.selected)
	GameData.genre_perso = genres_possibles[randi() % genres_possibles.size()] if genre == "Aléatoire" else genre

	var age = randfn(32.5, 12.5) if age_random_check.button_pressed else age_input.value
	GameData.age_perso = int(clamp(round(age), 13, 99))
	GameData.precisions = univers_precision.text
	GameData.type_tarot = TAROT_PAR_DEFAUT
	GameData.tirage_auto = tarot_check.button_pressed

	get_tree().change_scene_to_file("res://scenes/Principales/solo_rpg.tscn")
