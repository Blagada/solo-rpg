extends Control
class_name UIController

@onready var chat_display: RichTextLabel = $HistoryScroll/ChatDisplay
@onready var input_text: LineEdit = $InputLayout/InputText
@onready var thinking_label: Label = $LoadLabel

func afficher_message(auteur: String, message: String):
	chat_display.append_text("[b]" + auteur + ": [/b]" + message + "\n")

func basculer_indicateur_pense(etat: bool):
	thinking_label.visible = etat

func clear_input():
	input_text.clear()
	input_text.grab_focus()
