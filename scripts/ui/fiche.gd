extends PanelContainer
class_name FichePerso

@onready var valeur_univers: Label = $VBoxContainer/Univers/ValeurUnivers
@onready var valeur_nom: Label = $VBoxContainer/Nom/ValeurNom
@onready var valeur_profession: Label = $VBoxContainer/Profession/ValeurProfession
@onready var valeur_age: Label = $VBoxContainer/Age/ValeurAge
@onready var valeur_genre: Label = $VBoxContainer/Genre/ValeurGenre

func _ready() -> void:
	actualiser()

func actualiser() -> void:
	var univers_complet: String = GameData.config_universe
	if GameData.config_precisions != "":
		univers_complet += ", " + GameData.config_precisions
	valeur_univers.text = univers_complet
	
	# Conversion sécurisée des types vers String pour le texte des Labels
	valeur_age.text = str(GameData.character_age)
	valeur_genre.text = GameData.character_gender
	
	# Gestion des valeurs par défaut
	valeur_nom.text = GameData.character_name if GameData.character_name != "" else "À déterminer"
	valeur_profession.text = GameData.character_profession if GameData.character_profession != "" else "À déterminer"
