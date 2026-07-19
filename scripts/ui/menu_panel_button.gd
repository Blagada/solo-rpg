extends Button
class_name MenuPanelButton

@onready var menu_panel: Control = $"../../MenuPanel"


func _on_pressed() -> void:
	if menu_panel:
		menu_panel.visible = true
