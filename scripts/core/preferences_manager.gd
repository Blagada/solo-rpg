extends Node
class_name PreferenceManager

const PREFS_PATH: String = "user://preferences_joueur.json"


const POLICES: Dictionary = {
	"AtkinsonHyperlegible": preload("res://assets/fonts/Atkinson_Hyperlegible/AtkinsonHyperlegible-Regular.ttf"),
	"Averia": preload("res://assets/fonts/Averia_Serif_Libre/AveriaSerifLibre-Light.ttf"),
	"GistPixel": preload("res://assets/fonts/Geist_Pixel/GeistPixel-Regular-VariableFont_ELSH.ttf"),
	"Lora": preload("res://assets/fonts/Lora/Lora-VariableFont_wght.ttf"),
	"RadioCanada": preload("res://assets/fonts/Radio_Canada/RadioCanada-VariableFont_wdth,wght.ttf")
}


func _ready() -> void:
	appliquer()


func appliquer() -> void:
	var prefs: Dictionary = charger()
	var theme_global: Theme = ThemeDB.get_project_theme()

	if prefs.has("police") and POLICES.has(prefs["police"]):
		theme_global.default_font = POLICES[prefs["police"]] as Font

	if prefs.has("taille_police"):
		theme_global.default_font_size = int(prefs["taille_police"])


func sauvegarder(taille_police: float, nom_police: String) -> void:
	var data: Dictionary = {"taille_police": taille_police, "police": nom_police}
	var fichier: FileAccess = FileAccess.open(PREFS_PATH, FileAccess.WRITE)
	if fichier:
		fichier.store_string(JSON.stringify(data))
		fichier.close()


func charger() -> Dictionary:
	if not FileAccess.file_exists(PREFS_PATH):
		return {}

	var fichier: FileAccess = FileAccess.open(PREFS_PATH, FileAccess.READ)
	if not fichier:
		return {}

	var contenu: String = fichier.get_as_text()
	fichier.close()

	var data: Variant = JSON.parse_string(contenu)
	return data as Dictionary if data is Dictionary else {}
