# Feuille de route — Solo RPG

## ✅ Fait (session 1)
- Sécurisation de la clé API (fichier `secrets.cfg`, hors Git)
- État de partie persistant (`etat_partie`) — mémoire longue indépendante de l'historique tronqué
- Historique réduit à 2 tours (4 messages) au lieu de 3
- Ajout de la réponse du MJ à l'historique (oubli corrigé)
- Format neutre unifié (`{role, text}`) — prompt_manager et game_manager ne connaissent plus les formats spécifiques Gemini/Claude
- `gemini_client.gd` et `claude_client.gd` en miroir, chacun traduit le format neutre vers son API
- Nettoyage du champ `etat` : ne répète plus les infos déjà données ailleurs (âge, genre, univers)
- Directives Tarot dédiées : tirage seulement aux moments charnières, carte nommée explicitement, interprétation à effet concret

## ✅ Fait (session 2)
- Refonte UX config de partie : 3 modes fusionnés en 1 formulaire, options "Aléatoire" directement dans les dropdowns Univers/Genre, checkbox "Âge aléatoire" — plus besoin d'écran vide avant les boutons
- Fix prompt : `univers`/`genre` vides ne cassent plus la phrase envoyée au modèle (`univers_affiche`/`genre_affiche` avec fallback "à inventer")
- Clé API Claude obtenue et intégrée à `secrets.cfg`
- `claude_client.gd` branché dans `solo_rpg.tscn`, variable unique `client` (Gemini ou Claude selon `@export var utiliser_claude`) — un seul point d'appel dans `game_manager.gd`
- Premier test réel : Haiku plus structuré et cohérent que Gemini Flash dès le premier essai
- **Tool use démarré (Claude seulement, Gemini reste sur le JSON)** : tool `mettre_a_jour_etat` fonctionnel — remplace le champ `etat` du JSON par un vrai appel structuré
- Bug corrigé : `FORMAT_REPONSE` (consigne JSON) entrait en conflit avec les tools et vidait la narration → nouvelle constante `INSTRUCTIONS_TOOL_USE`, choisie selon `utiliser_claude` dans `generer_system_prompt()`
- Structure de ressources Tarot démarrée : `CarteTarot` (Resource Godot, champs `nom` + `asset`), dossier `ressources/marseille/`, première carte test `fou.tres`

## ✅ Fait (session 3)
- Confirmé : narration + état fonctionnent bien avec Claude et le tool use
- Structure de ressources Tarot mise en place : `TarotCards` (Resource), `ressources/marseille/fou.tres` (1re carte test)
- Tool `tirer_carte` ajouté (liste de cartes chargée dynamiquement depuis le dossier `GameData.type_tarot`, plus besoin de lister à la main) — puis **fusionné** dans le tool unique ci-dessous
- Signal `reponse_recue` enrichi avec un `Dictionary tools_declenches`, extensible pour les futurs tools (inventaire, jalons) sans re-changer la signature à chaque fois
- **Bug important trouvé et corrigé** : `tool_choice` forcé sur un outil empêche l'API de générer du texte libre en même temps (confirmé par la doc Anthropic) → solution finale : un seul tool `repondre_joueur` qui contient narration + état + carte tirée (optionnelle), forcé à chaque tour. Remplace l'ancien `mettre_a_jour_etat` seul.
- Résultat validé en jeu : `etat` se met à jour à **chaque** tour sans exception (fini les oublis observés avant, ex. le personnage qui "oubliait" avoir vu une serrure)
- Ménage de code : suppression de `remplir_donnees_par_defaut()` (bug caché — écrasait le choix "univers aléatoire"), retrait des commentaires-artefacts, fix du mismatch de signature `envoyer_requete()` entre Gemini/Claude
- Config de partie simplifiée : suppression des boutons de mode (`ModeButtons`), formulaire visible directement au chargement de l'écran
- Liste `GameData.UNIVERS_PAR_DEFAUT` (const Array) centralisée pour peupler le dropdown Univers ; "Aléatoire" volontairement exclu de cette liste (comportement, pas un univers)
- Séparateurs natifs (`add_separator()`) préparés dans le dropdown Univers pour distinguer "Univers existants" (à venir) de "Univers général" — affichage du séparateur "Univers existants" à conditionner à `bibliotheque_univers.size() > 0` une fois construite
- Contrainte de longueur de réponse ajoutée (100-120 mots) → coût observé en baisse (~2 cents pour 4 échanges, contre ~6 cents pour une session plus verbeuse) ; à réajuster (probablement en fourchette plutôt qu'en plafond dur) selon le ressenti en jouant

## ✅ Fait (session 4)
- **Système de sauvegarde/chargement complet et validé en conditions réelles** :
  - `SaveManager` en autoload (accessible depuis n'importe quelle scène, comme `GameData`)
  - Sauvegarde automatique (JSON, `user://sauvegarde_partie.json`) après chaque réponse de l'IA — aucune action manuelle requise
  - `historique_partie` déménagé de `game_manager.gd` vers `GameData` (source unique, plus de désync)
  - Bouton "Continuer l'aventure" au menu principal, activé seulement si une sauvegarde existe
  - Chargement confirmé : reprise d'une aventure réaffiche tout l'historique, **aucun appel API inutile**, la suite reste narrativement cohérente
  - Bug corrigé : nouvelle aventure ne réinitialisait pas `historique_partie`/`etat_partie` → une nouvelle partie héritait de l'ancienne (fix dans `configuration_jeu.gd`, `_on_start_pressed`)
- **Lisibilité de l'interface de chat** :
  - Couleur distincte par narrateur (DM / Vous / Système) dans `ui_controller.gd`
  - Conversion markdown → BBCode (gras `**`, italique `*`) via RegEx, pour que le formatage de Claude s'affiche vraiment au lieu des étoiles brutes
  - `DIRECTIVES_FORMATAGE` ajoutée au prompt : gras pour noms propres marquants, italique pour objets de quête — première brique de "ludification" du texte
  - Piste notée pour plus tard : faire correspondre les objets en italique avec de vrais ajouts via le futur tool inventaire

## ✅ Fait (session 5)
- **Menu en jeu (☰ Menu)** : panneau `MenuPanel` avec 2 onglets (Fiche / Paramètres), ouvert/fermé par bouton (visible/false, pas de queue_free — bug corrigé après confusion scène vs nœud statique)
- **Fiche de personnage fonctionnelle** : univers (+ précisions), âge, genre, nom, profession — tous affichés et rafraîchis à chaque ouverture du panneau (`actualiser()` appelée via `visibility_changed`, pas juste `_ready()`)
- Univers "Aléatoire" pioche maintenant directement dans `GameData.UNIVERS_PAR_DEFAUT` (plus de champ vide laissé à l'IA) — simplifie et rend l'affichage fiable immédiatement, sans dépendre d'un tool
- Nom et profession du personnage capturés via le tool `repondre_joueur` (champs optionnels `nom_personnage`/`profession`) et assignés à `GameData.nom_perso`/`profession_perso`
- Âge aléatoire remplacé par une distribution en cloche (`randfn`, moyenne 32.5, écart-type 12.5, clampée 13-99) plutôt qu'une chance égale partout
- **Bug de timing important trouvé et corrigé** : `SaveManager.sauvegarder_partie()` était appelée avant l'assignation de `nom_perso`/`profession_perso`/`univers_invente` dans `_on_reponse_ia` → sauvegarde toujours "un tour en retard" sur ces champs. Déplacé à la toute fin de la fonction.
- **Préférences d'affichage (police + taille de texte)** :
  - Slider `HSlider` pour la taille (remplace un dropdown, plus adapté à une valeur continue)
  - 6 polices proposées : Lexend, Atkinson Hyperlegible (dyslexie), Lora, Merriweather (empattement), Inter (sans-empattement), Press Start 2P (pixel)
  - Bug de débordement corrigé (`Clip Contents` sur le panneau) quand la taille de police grossit
  - Sauvegarde séparée (`preferences_joueur.json`, autoload `Preferences`) — indépendante de la sauvegarde d'aventure, pour ne jamais être réinitialisée par "Nouvelle aventure"
  - Appliquées dès `Preferences._ready()` (autoload, donc avant toute scène) → police/taille cohérentes dès le menu principal, plus besoin d'avoir ouvert le panneau Paramètres au préalable
- Padding du chat (`RichTextLabel`) réglé proprement via le thème principal (Content Margin sur le StyleBoxFlat), pas de code

## ✅ Fait (session 6)
- **Mode tirage manuel du tarot (le manque noté en fin de session 5)** — solution trouvée : consigne en prose insuffisante (Claude ignorait la demande de tirage même à des moments clairement charnières), donc ajout d'un signal structurel fiable :
  - Champ `moment_charniere` (bool) ajouté au tool `repondre_joueur`, **obligatoire** à chaque tour — fiable comme `narration`/`etat`
  - `game_manager.gd` réagit à ce signal : si `moment_charniere = true` et `tirage_auto = false`, affiche un message Système ("🎴 Moment charnière — tire une carte") et arme `attente_tirage_manuel`
  - `carte_tiree` devient `required` seulement le tour suivant, via un nouveau paramètre `forcer_carte` sur `envoyer_requete()`
  - Message Système ajouté aussi pour le tirage automatique ("Carte tirée : X"), affiché **avant** la narration du DM — permet de retirer la mention du nom de carte de la prose du DM (reste immersif), séparant mécanique de jeu et narration
- **Bug de crash trouvé et corrigé** : accès direct `bloc["input"]["etat"]` plantait si Claude omettait exceptionnellement un champ obligatoire → remplacé par `.get(clé, defaut)` partout dans `_on_api_request_request_completed`, plus robuste même si Claude déroge au schema
- **Bug de double-envoi trouvé (fix écrit, pas encore testé)** : `InputText` était connecté à la fois à `_on_input_text_text_submitted` (touche Entrée) et au bouton Envoyer, causant un envoi en double sur une seule touche Entrée dans certains cas — expliquait le décalage d'un tour observé sur `attente_tirage_manuel` (consommé par le 1er envoi fantôme avant le vrai message du joueur). Fix : variable `envoi_en_cours` qui bloque les envois superposés, réinitialisée dans `_on_reponse_ia`/`_on_erreur_ia`.

## ⚠️ À reprendre en priorité
- **Retester le mode tirage manuel après le fix `envoi_en_cours`** — pas encore confirmé que ça règle bien le décalage du flag `attente_tirage_manuel`. Vérifier avec les prints de debug déjà en place (`FORCER_CARTE ENVOYÉ`, `FLAG ACTIVÉ`) que la séquence est maintenant : moment_charniere détecté → message Système → JOUEUR répond avec le nom d'une carte → forcer_carte=true correctement appliqué à CE message précis.
- **Retirer les prints de debug une fois confirmé** (dans `game_manager.gd` et `claude_client.gd`)
- **Vérifier si le double-signal était bien la vraie cause** — si le bug persiste après le fix `envoi_en_cours`, creuser pourquoi `_on_input_text_text_submitted` ET `_on_send_button_pressed` se déclenchaient tous les deux sur une touche Entrée (vérifier dans l'éditeur si le bouton Envoyer a le focus par défaut / est marqué comme action par défaut du champ de texte)

## 🐛 Autre bug noté (pas urgent)
- Les messages Système (moment charnière, carte tirée, aventure reprise) ne sont pas inclus dans `historique_partie` sauvegardé — volontaire pour l'API (pas besoin de les renvoyer à Claude), mais ça crée un trou visuel : recharger une partie ne réaffiche pas ces messages dans le chat. À décider : les stocker séparément juste pour l'affichage, sans les envoyer à l'API.

## ✅ Fait (session export & test externe)
- **Mode tirage manuel du tarot confirmé fonctionnel** : `forcer_carte` s'applique correctement au bon tour une fois le bug de double-envoi réglé (`envoi_en_cours`). Test réel validé : carte nommée par le joueur ("Le monde") correctement capturée et affichée par le Système.
- Note acceptée : le DM ne "gèle" pas toujours parfaitement la narration au moment charnière malgré la consigne ajoutée — cosmétique, pas fonctionnel, laissé tel quel (limite connue des consignes en prose non forcées)
- **Premier export Windows réussi** (`.exe` + `.pck`), avec `secrets.cfg` exclu de l'export (Project → Export → Resources → filtre d'exclusion) — clé jamais incluse dans le build distribué
- Clé transmise à l'ami testeur via un `LancerLeJeu.bat` (`set CLAUDE_API_KEY=...` + lancement de l'exe) plutôt que dans un fichier inclus au build
- Monitoring via Console Anthropic → Usage (filtrable par clé/modèle/période) — heures affichées en UTC, pas le fuseau local (source de confusion résolue)
- **Bugs trouvés par le testeur externe** :
  - Âge toujours aléatoire peu importe le choix du joueur — condition `age_random_check.button_pressed` perdue lors d'un ajout précédent (courbe `randfn`), corrigée
  - `\n\n` littéraux parfois visibles dans le texte au lieu de vrais sauts de ligne — fix défensif de nettoyage (`.replace("\\n", "\n")`) dans `ui_controller.gd`, peu importe la cause exacte côté modèle
- Ajout d'une consigne de style : guillemets français « » forcés plutôt qu'anglais " " dans `DIRECTIVES_FORMATAGE`

## 💡 Nouvelle idée (demandée par le testeur)
- **Exporter la conversation/aventure** pour la partager (probablement en texte ou markdown) — à définir : export de l'historique complet (`GameData.historique_partie`) vers un fichier lisible, déclenché depuis le menu en jeu ou après la partie

## 🔜 Prochaine étape (une fois le tirage manuel confirmé stable)
- Affichage visuel de la carte tirée (asset `TarotCards`) — maintenant que `carte_tiree`/`nom_carte` est fiable dans les deux modes
- Tool inventaire (`modifier_inventaire`)
- Bibliothèque d'univers sauvegardés (bouton "Sauvegarder cet univers" dans l'onglet Paramètres)

## 🔜 En cours de réflexion / prochaines étapes concrètes
0. **Trame narrative Opus** — mise de côté pour l'instant (Haiku performe déjà bien), à reconsidérer si le besoin d'un vrai fil conducteur scripté se fait sentir
1. **Tool use — suite** (sur Claude uniquement pour l'instant) :
   - `modifier_inventaire(action, objet, description)` — envisager le pattern à 2 appels (narration libre + extraction forcée) si la perte occasionnelle d'objets est jugée trop risquée, contrairement à `etat` où c'est toléré
   - `declencher_jalon(id_jalon)` — probablement lié aux jalons de la trame Opus
   - À valider : `mettre_a_jour_relation(pnj, changement)`, `mettre_a_jour_objectif(objectif)`
2. **Affichage visuel de la carte tirée** : `tools_declenches["tarot"]["nom_carte"]` → charger la ressource `TarotCards` correspondante pour afficher `asset` à l'écran
3. **Ajuster la fourchette de longueur de réponse** (actuellement 100-120 mots, un peu trop court) selon le ressenti en jouant

## 💡 Vision à plus long terme (fiche de joueur)
- Au lancement : formulaire unique (spécificité ou tout en "Aléatoire") ou univers existant (à faire) → affichage d'une fiche de joueur (nom, profession, univers)
- En tout temps en jeu : le joueur peut rouvrir cette fiche
- La fiche affichera à terme : inventaire, relations PNJ, objectif en cours — alimentés par les tools structurés, pas du texte à reparser
- **Principe clé : aucune génération d'image par l'IA.** L'IA fournit des données structurées (objets, catégories, noms) via les outils ; Godot affiche des assets visuels préparés à l'avance par le développeur (icônes génériques par catégorie d'objet, images réelles pour les cartes de tarot via `CarteTarot`, avatars génériques pour les PNJ)

## 💾 Sauvegardes (idée à développer)
- Sauvegarde d'aventure en cours (`etat_partie` + `trame_narrative`) — reprendre un perso précis
- Bibliothèque d'univers séparée (`univers_choisi` + `precisions` seulement) — rejouer un nouveau perso dans un décor aimé, sans perdre l'ambiance créée par Opus
- Bouton "Univers existant" déjà présent dans le menu (`ModeButtons`), non connecté — à faire une fois qu'il y a au moins un univers sauvegardé

## 🧠 Décisions de conception à garder en tête
- Modèle prévu : Haiku 4.5 pour le jeu courant (économique), Opus pour la trame initiale seulement (routage de modèles, pas de l'agentique au sens strict)
- Le vrai "agentique" (boucles autonomes multi-étapes) jugé non pertinent pour ce projet — la boucle tour par tour est déjà claire et suffisante
- Approche 2-modèles (Opus une fois + Haiku répété) déjà la version la plus écoresponsable possible, comparé à tout faire sur Opus
- Gemini reste sur le système JSON `{narration, etat}` ; Claude migre vers le tool use — les deux clients continuent de partager la même interface externe (`envoyer_requete`, signaux) même si leur implémentation interne diverge davantage maintenant
- Avant publication itch.io : migrer la clé API vers un serveur relais (le client ne doit jamais contenir la clé dans un exécutable distribué)
