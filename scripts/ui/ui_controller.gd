extends Control
class_name UIController

@onready var chat_display: RichTextLabel = $HistoryScroll/ChatDisplay
@onready var input_text: LineEdit = $InputLayout/InputText
@onready var thinking_label: Label = $LoadLabel

# --- Constante de couleur
const COULEUR_DM: String = "#9fd3ff"
const COULEUR_JOUEUR: String = "#ffcb77"
const COULEUR_SYSTEME: String = "#a0a0a0"
# ---


func afficher_message(auteur: String, message: String)-> void:
	var couleur = COULEUR_SYSTEME

	if auteur == "DM":
		couleur = COULEUR_DM
	elif auteur == "Vous":
		couleur = COULEUR_JOUEUR

	var message_nettoye: String = message.replace("\\n\\n", "\n\n").replace("\\n", "\n")
	var message_formate: String = _convertir_markdown(message_nettoye)

	chat_display.append_text("[color=" + couleur + "][b]" + auteur + " :[/b] " + message_formate + "[/color]\n\n")


func _convertir_markdown(texte: String) -> String:
	var regex_gras: RegEx = RegEx.new()
	regex_gras.compile("\\*\\*(.+?)\\*\\*")
	var resultat: String = regex_gras.sub(texte, "[b]$1[/b]", true)

	var regex_italique: RegEx = RegEx.new()
	regex_italique.compile("\\*(.+?)\\*")
	resultat = regex_italique.sub(resultat, "[i]$1[/i]", true)

	return resultat


func basculer_indicateur_pense(etat: bool) -> void:
	thinking_label.visible = etat


func clear_input() -> void:
	input_text.clear()
	input_text.grab_focus()
