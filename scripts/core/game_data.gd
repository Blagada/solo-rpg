extends Node

# --- CONTENU STATIQUE (ne change jamais en cours de partie) ---

const UNIVERS_PAR_DEFAUT = [
	"Médiéval fantastique",
	"Post-apocalyptique",
	"Science fiction",
	"Cosy / tranche de vie",
	"Horreur",
	"Romantasy",
	"Victorien",
	"Western"
]

# --- ÉTAT DE PARTIE (rempli/modifié pendant le jeu) ---

# Variable qui sont choisi par le joueur. Pas obligatoire, si vide, l'IA va les remplir
var univers_choisi: String = "" # PostApo, cosy, médieval, etc.
var precisions: String = ""
var type_tarot: String = "" # marceille, egyptien, etc.
var tirage_auto: bool = true
var genre_joueur: String = "" # Options : "masculin", "féminin", "neutre"
var age_joueur: int = 25 # Entre 13 et 99 ans pour l'instant

# État de partie persistant : résumé condensé des faits établis (lieu, objets,
# PNJ, objectif...), mis à jour par l'IA à chaque tour et toujours réinjecté
# dans le prompt système, même quand l'historique brut est tronqué.
var etat_partie: String = ""

# --- SAUVEGARDE ---
var historique_partie: Array = []
