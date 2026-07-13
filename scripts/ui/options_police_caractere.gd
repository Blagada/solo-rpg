extends OptionButton

@onready var options_police_caractere: OptionButton = $"."


const POLICES = {
	"AtkinsonHyperlegible": preload("res://assets/fonts/Atkinson_Hyperlegible/AtkinsonHyperlegible-Regular.ttf"),
	"Averia": preload("res://assets/fonts/Averia_Serif_Libre/AveriaSerifLibre-Light.ttf"),
	"GistPixel": preload("res://assets/fonts/Geist_Pixel/GeistPixel-Regular-VariableFont_ELSH.ttf"),
	"Lora": preload("res://assets/fonts/Lora/Lora-VariableFont_wght.ttf"),
	"RadioCanada": preload("res://assets/fonts/Radio_Canada/RadioCanada-VariableFont_wdth,wght.ttf")
}

func _ready() -> void:
	for nom_police in POLICES.keys():
		options_police_caractere.add_item(nom_police)

func _on_police_options_item_selected(index: int) -> void:
	var nom_police = options_police_caractere.get_item_text(index)
	var theme_global = ThemeDB.get_project_theme()
	theme_global.default_font = POLICES[nom_police]
