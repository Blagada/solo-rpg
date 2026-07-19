extends OptionButton
class_name FontOptionButton


const POLICES: Dictionary = {
	"AtkinsonHyperlegible": preload("res://assets/fonts/Atkinson_Hyperlegible/AtkinsonHyperlegible-Regular.ttf"),
	"Averia": preload("res://assets/fonts/Averia_Serif_Libre/AveriaSerifLibre-Light.ttf"),
	"GistPixel": preload("res://assets/fonts/Geist_Pixel/GeistPixel-Regular-VariableFont_ELSH.ttf"),
	"Lora": preload("res://assets/fonts/Lora/Lora-VariableFont_wght.ttf"),
	"RadioCanada": preload("res://assets/fonts/Radio_Canada/RadioCanada-VariableFont_wdth,wght.ttf")
}

func _ready() -> void:
	# Nettoyage avant ajout pour éviter les doublons
	clear()
	for nom_police: String in POLICES.keys():
		add_item(nom_police)

func _on_police_options_item_selected(index: int) -> void:
	# Récupération sécurisée du nom de la police
	var nom_police: String = get_item_text(index)
	
	# Mise à jour typée du thème global
	if POLICES.has(nom_police):
		var theme_global: Theme = ThemeDB.get_project_theme()
		theme_global.default_font = POLICES[nom_police] as Font
