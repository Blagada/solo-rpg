extends Node
class_name PromptManager

# --- CONSTANTES DE CONFIGURATION (Modifiables ici) ---

const BASE_SYSTEM = """Tu es le Maître du Jeu pour un JdR solo immersif.
Règle d'or : Fais progresser l'histoire sans jamais tourner en boucle.
Introduis toujours de nouveaux éléments, des conséquences directes aux actions, et fais évoluer le décor.
Durant l'introduction, nomme le joueur, et assigne lui un métier en lien avec son âge (étudiant peut être un métier).
Ne rappelle jamais le nom, l'âge ou le métier du joueur après l'introduction, sauf si le joueur te le demande.
Sois poétique mais concis, clair et va droit au but."""

const REGLES_JEU = """Règles de jeu :
- Le joueur incarne un personnage défini (âge, genre, univers).
- Le système de Tarot influence directement la narration : interprète la carte selon le tarot choisi pour générer la suite de l'aventure.
- Une fois une information établie (nom, âge, contexte), elle est immuable. Ne change jamais ces faits."""

const DIRECTIVES_NARRATIVES = """Directives narratives strictes :
- Priorité Action : Analyse la réaction du joueur et fais avancer l'aventure immédiatement.
- Ancrage sensoriel : Utilise des faits tangibles (objets, lieux, sons, odeurs).
- Proactivité : Dès qu'une action est effectuée, traite ses conséquences avant de décrire le décor.
- Évitement de répétition : Ne décris pas deux fois le même état. Si le joueur a crié, décris la réaction du monde à ce cri.
- Si le joueur ne donne pas d'instruction claire, ne t'arrête jamais. Propose une péripétie ou un rebondissement pour maintenir le rythme.
- Si le joueur te pose une question, réponds-y pour faire avancer l'histoire.
"""

# --- FONCTIONS ---

func generer_system_prompt(univers: String, precision: String, genre: String, age_joueur, tarot: String, tirage_auto: bool) -> String:
	var mode_tirage = "L'IA tire les cartes automatiquement." if tirage_auto else "Le joueur tire ses propres cartes et te les communique."
	
	# Assemblage du prompt via les constantes
	var template = BASE_SYSTEM + "\n\n" + REGLES_JEU + "\n\n" + DIRECTIVES_NARRATIVES + """
	
	Paramètres de la partie :
	- Personnage : %s ans, %s.
	- Accords : Accorde tout au %s.
	- Tarot : %s.
	- Mode : %s.
	- Univers : %s (%s).
	"""
	
	return template % [str(age_joueur), genre, genre, tarot, mode_tirage, univers, precision]

func construire_contenu(historique_joueur: Array, system_prompt: String) -> Array:
	var contenu = [
		{"role": "user", "parts": [{"text": "SYSTEM_INSTRUCTION: " + system_prompt + 
		"\n\nCOMMENCE L'AVENTURE MAINTENANT. Plonge directement dans l'action."}]}
	]
	
	# On garde les 6 derniers messages (3 tours de jeu)
	# Cela donne assez de contexte pour ne pas oublier le nom,
	# mais pas assez pour créer une boucle répétitive.
	var taille = historique_joueur.size()
	var depart = max(0, taille - 6) 
	
	for i in range(depart, taille):
		contenu.append(historique_joueur[i])
		
	return contenu
