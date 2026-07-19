extends HSlider


func _on_taille_slider_value_changed(value: float) -> void:
	var theme_global: Theme = ThemeDB.get_project_theme()
	theme_global.default_font_size = int(value)
