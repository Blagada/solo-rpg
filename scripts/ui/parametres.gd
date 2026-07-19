extends PanelContainer
class_name MenuParametres

@onready var slider_taille: HSlider = $ScrollContainer/ParametresContainer/TailleTexte/SliderTaille
@onready var options_police: OptionButton = $ScrollContainer/ParametresContainer/PoliceCaractereTexte/OptionsPoliceCaractere


func _ready() -> void:
	options_police.clear()
	for nom_police: String in Preferences.POLICES.keys():
		options_police.add_item(nom_police)

	var prefs: Dictionary = Preferences.charger()
	if prefs.has("taille_police"):
		slider_taille.value = prefs["taille_police"]

	if prefs.has("police"):
		var index: int = Preferences.POLICES.keys().find(prefs["police"])
		if index != -1:
			options_police.select(index)


func _on_taille_slider_value_changed(value: float) -> void:
	ThemeDB.get_project_theme().default_font_size = int(value)
	var nom_police: String = options_police.get_item_text(options_police.selected)
	Preferences.sauvegarder(value, nom_police)


func _on_police_options_item_selected(index: int) -> void:
	var nom_police: String = options_police.get_item_text(index)
	ThemeDB.get_project_theme().default_font = Preferences.POLICES[nom_police] as Font
	Preferences.sauvegarder(slider_taille.value, nom_police)
