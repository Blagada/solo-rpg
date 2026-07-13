extends PanelContainer

@onready var slider_taille: HSlider = $ScrollContainer/ParametresContainer/TailleTexte/SliderTaille
@onready var options_police: OptionButton = $ScrollContainer/ParametresContainer/PoliceCaractereTexte/OptionsPoliceCaractere


func _ready() -> void:
	options_police.clear()
	for nom_police in Preferences.POLICES.keys():
		options_police.add_item(nom_police)

	var prefs = Preferences.charger()
	if prefs.has("taille_police"):
		slider_taille.value = prefs["taille_police"]
	if prefs.has("police"):
		options_police.select(Preferences.POLICES.keys().find(prefs["police"]))


func _on_taille_slider_value_changed(value: float) -> void:
	ThemeDB.get_project_theme().default_font_size = int(value)
	Preferences.sauvegarder(value, options_police.get_item_text(options_police.selected))


func _on_police_options_item_selected(index: int) -> void:
	var nom_police = options_police.get_item_text(index)
	ThemeDB.get_project_theme().default_font = Preferences.POLICES[nom_police]
	Preferences.sauvegarder(slider_taille.value, nom_police)
