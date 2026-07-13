extends PanelContainer

@onready var valeur_univers: Label = $VBoxContainer/Univers/ValeurUnivers
@onready var valeur_nom: Label = $VBoxContainer/Nom/ValeurNom
@onready var valeur_profession: Label = $VBoxContainer/Profession/ValeurProfession
@onready var valeur_age: Label = $VBoxContainer/Age/ValeurAge
@onready var valeur_genre: Label = $VBoxContainer/Genre/ValeurGenre

func _ready() -> void:
	actualiser()

func actualiser() -> void:
	valeur_univers.text = GameData.univers_choisi + (", " + GameData.precisions if GameData.precisions != "" else "")
	valeur_age.text = str(GameData.age_perso)
	valeur_genre.text = GameData.genre_perso
	valeur_nom.text = GameData.nom_perso if GameData.nom_perso != "" else "À déterminer"
	valeur_profession.text = GameData.profession_perso if GameData.profession_perso != "" else "À déterminer"
