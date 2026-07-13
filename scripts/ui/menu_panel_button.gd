extends Button
@onready var menu_panel: Control = $"../../MenuPanel"


func _on_pressed() -> void:
	menu_panel.visible = true
