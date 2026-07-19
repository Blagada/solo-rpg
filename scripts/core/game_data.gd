extends Node

# --- RÉFÉRENTIELS (Données statiques pour le jeu) ---

const AVAILABLE_UNIVERSES: Array[String] = [
	"Médiéval fantastique",
	"Post-apocalyptique",
	"Science fiction",
	"Cosy / tranche de vie",
	"Horreur",
	"Romantasy",
	"Victorien",
	"Western"
]

const AVAILABLE_GENDERS: Array[String] = [
	"Féminin",
	"Masculin",
	"Neutre"
]

const AVAILABLE_TAROT_MODELS: Array[String] = [
	"marseille",
	"egyptien"
]

# --- DONNÉES DE SESSION (Choix du joueur et état actuel) ---

# Configuration initiale choisie par le joueur
@export var config_universe: String = "" # PostApo, cosy, médieval, etc.
@export var config_precisions: String = ""
@export var config_tarot_model: String = AVAILABLE_TAROT_MODELS[0] # marceille, egyptien, etc.
@export var config_is_auto_draw: bool = true

# Attributs du personnage
@export var character_gender: String = "" # Options : "masculin", "féminin", "neutre"
@export var character_age: int = 25 # Entre 13 et 99 ans pour l'instant
@export var character_name: String = "" # Nom du personnage - toujours rempli par l'IA
@export var character_profession: String = "" # Profession du personnage - toujours rempli par l'IA

# État de partie persistant : résumé condensé des faits établis (lieu, objets,
# PNJ, objectif...), mis à jour par l'IA à chaque tour et toujours réinjecté
# dans le prompt système, même quand l'historique brut est tronqué.
@export_multiline var world_current_state: String = ""

# --- SAUVEGARDE ---
var conversation_history: Array[Dictionary] = []
