extends PanelContainer

@onready var valeur_univers: Label = $VBoxContainer/Univers/ValeurUnivers
@onready var valeur_age: Label = $VBoxContainer/Age/ValeurAge
@onready var valeur_genre: Label = $VBoxContainer/Gnre/ValeurGenre

func _ready() -> void:
	valeur_univers.text = GameData.univers_choisi + (", " + GameData.precisions if GameData.precisions != "" else "")
	valeur_age.text = str(GameData.age_joueur)
	valeur_genre.text = GameData.genre_joueur
