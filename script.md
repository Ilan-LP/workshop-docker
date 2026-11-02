# Script de présentation

Script oral du workshop Docker, à lire avec `presentation.pptx`. Les mêmes notes sont dans les notes du diaporama.

Durée totale visée : 2h. Théorie et démo : environ 30 minutes. Pratique sur les 4 mini-projets : environ 1h30. Les timings ci-dessous sont indicatifs.

Avant de commencer : vérifier que `docker run --rm hello-world` fonctionne sur la machine de présentation, et avoir `demo/README.md` ouvert.

## Slide 1 : Page de titre (0:00 -> 0:40)

- Je me présente en une phrase (AER à Epitech Lyon) et je dis pourquoi Docker vaut le coup de s'y mettre maintenant.
- Déroulé: 30 min de théorie et démo, puis 1h30 où VOUS pratiquez sur 4 mini-projets. Tout est dans un repo GitHub.
- Avant de commencer, vérifiez que Docker tourne: docker run --rm hello-world. Ceux qui n'ont pas Docker, venez me voir à la fin de la partie théorique.

## Slide 2 : 01 · Pourquoi Docker (0:40 -> 0:50)

- Transition rapide. On commence par le problème que Docker résout.

## Slide 3 : Ça marche chez moi (0:50 -> 2:20)

- Qui a déjà dit ou entendu 'ça marche chez moi' sur un projet de groupe? Tout le monde.
- Gauche: ma machine, Node 22, Postgres 16, un .env. Droite: le serveur ou le PC du coéquipier, une autre version de Node, pas de Postgres, un .env oublié.
- Le code est identique, l'environnement ne l'est pas. Sur un projet Epitech en groupe, c'est la cause numéro un des 'chez moi ça tourne'.
- Message: ce qu'il faut livrer, ce n'est pas que le code, c'est le code AVEC son environnement.

## Slide 4 : Machine virtuelle ou conteneur (2:20 -> 4:00)

- Première idée des élèves: 'une VM'. Oui sur le principe, non sur la technique.
- VM: un OS invité complet par machine, au-dessus d'un hyperviseur. Lourd en disque et en RAM, démarrage lent.
- Conteneur: pas d'OS invité. Tous les conteneurs partagent le noyau de la machine hôte, Docker Engine gère l'isolation. Léger, démarre en secondes.
- Précision utile: sur Mac et Windows, Docker Desktop fait tourner une petite VM Linux en dessous, c'est ce noyau Linux qui est partagé.
- Message: un conteneur partage le noyau de l'hôte, c'est ce qui le rend léger.

## Slide 5 : Sous le capot (4:00 -> 5:30)

- Docker n'a pas inventé l'isolation, il rend pratique des fonctions du noyau Linux.
- Namespaces: chaque conteneur a sa propre vue des processus, du réseau, des fichiers. Il croit être seul au monde.
- cgroups: on peut plafonner le CPU et la RAM par conteneur. Un conteneur qui s'emballe ne mange pas toute la machine.
- Système de fichiers en couches: une image est une pile de couches en lecture seule, le conteneur ajoute une fine couche en écriture par-dessus. On y revient avec le cache.
- Message: Docker, c'est des fonctions du noyau Linux plus une CLI pratique.

## Slide 6 : Image et conteneur (5:30 -> 7:30)

- La confusion la plus fréquente: image et conteneur. Pour des devs: l'image c'est la classe, le conteneur c'est l'objet.
- Le Dockerfile est la recette, un simple fichier texte qu'on versionne dans Git. docker build en fait une image.
- L'image est figée, en lecture seule. docker run en crée un conteneur, une instance qui tourne. On peut en lancer dix à partir de la même image.
- Le registry (Docker Hub) est le GitHub des images: push pour envoyer, pull pour récupérer. node:22-alpine, c'est nom:version.
- Question rapide à la salle: si je supprime un conteneur, je perds l'image? Non.

## Slide 7 : 02 · Construire et lancer (7:30 -> 7:40)

- Maintenant on construit et on lance.

## Slide 8 : Le Dockerfile (7:40 -> 9:40)

- Lecture ligne par ligne. FROM: l'image de départ, ici Node 22 en variante alpine, beaucoup plus petite.
- WORKDIR: le dossier de travail dans l'image. COPY: on copie des fichiers de ton projet vers l'image.
- RUN s'exécute au BUILD (installer les dépendances), CMD s'exécute au RUN (démarrer l'app). C'est la distinction qui piège le plus de monde.
- EXPOSE ne publie rien, c'est de la documentation. La publication se fait avec -p au lancement.
- Note: ce Dockerfile est un peu plus complet que celui de la démo (on a séparé package.json). Je vous explique pourquoi sur la slide suivante.

## Slide 9 : Couches et cache (9:40 -> 11:40)

- Chaque instruction crée une couche. Docker réutilise une couche si rien n'a changé, sinon il la reconstruit ET toutes celles en dessous.
- Gauche: je copie tout le code puis j'installe. Je modifie server.js, la couche COPY change, donc npm ci se relance à chaque build.
- Droite: je copie d'abord package.json, j'installe, et SEULEMENT ensuite le code. Modifier server.js ne touche que la dernière couche, npm ci reste en cache.
- Règle: ce qui change le moins en haut, ce qui change le plus en bas. Vous allez le vérifier dans le projet 1.

## Slide 10 : Les commandes de base (11:40 -> 13:10)

- Les six commandes à connaître. Je les passe vite, on va les utiliser tout de suite en démo.
- build construit l'image, run lance un conteneur (-p pour les ports), ps liste, logs -f suit les logs, exec -it ouvre un shell DANS le conteneur, stop puis rm pour nettoyer.
- Le plus utile pour débugger: logs pour comprendre pourquoi ça plante, exec pour aller voir ce qu'il y a dedans.
- Le CHEATSHEET.md du repo contient tout ça et plus.

## Démo live (13:10 -> 21:10)

Voir `demo/README.md`.

- DÉMO LIVE, 8 minutes. Tout est dans demo/README.md, le code est déjà écrit.
- 1. node -v dans deux versions différentes de Node, sans rien installer. 2. On écrit le Dockerfile en 6 lignes. 3. build, run, curl, logs, exec.
- 4. On modifie server.js et on rebuild pour montrer le CACHED. 5. On supprime le conteneur et on montre que le fichier créé dedans a disparu: ça introduit la slide volumes.
- Si la frappe en live part en vrac, demo/app/Dockerfile.final est la référence.

## Slide 11 : Ports et volumes (21:10 -> 23:10)

- Deux choses qu'on vient de croiser en démo.
- Ports: le conteneur est isolé, rien n'y entre par défaut. -p 8080:3000 veut dire: le port 8080 de MA machine redirigé vers le port 3000 DU conteneur. Toujours hôte puis conteneur.
- Volumes: un conteneur est jetable, ses données disparaissent avec lui. Ce qui doit survivre (une base de données) vit dans un volume, géré par Docker, indépendant du conteneur.
- Le bind mount, c'est monter un dossier de ta machine dans le conteneur. Pratique en développement, on le fait dans le bonus du projet 4.

## Slide 12 : Les pièges classiques (23:10 -> 24:40)

- Quatre erreurs que je vois tout le temps, y compris dans des projets notés.
- node:latest: la version change sous vos pieds, on fige (node:22-alpine). Un secret dans un ENV: n'importe qui avec l'image le lit avec docker history, on passe les secrets au lancement.
- Tout en root: si l'app est compromise, l'attaquant est root dans le conteneur, on ajoute USER node. node_modules copié: contexte énorme et dépendances de votre OS dans l'image, le .dockerignore règle ça.
- Les projets 1 et 3 vérifient plusieurs de ces points avec check.sh.

## Slide 13 : Le build multi-stage (24:40 -> 26:40)

- Problème: pour construire une app React, il faut Node, des centaines de Mo de node_modules, des outils de build. Pour la SERVIR, il faut juste quelques fichiers statiques.
- Solution: deux FROM dans le même Dockerfile. L'étape 1 build, l'étape 2 part d'une image nginx toute propre et ne récupère que le dossier dist avec COPY --from=build.
- Tout ce qui est dans l'étape 1 est jeté. L'image finale ne contient ni Node ni code source.
- [À VÉRIFIER avant le workshop: lancer docker images sur le projet 2 et noter les vraies tailles (étape build vs image finale) pour les citer à l'oral.]
- Message: on livre le résultat, pas l'atelier. C'est le projet 2.

## Slide 14 : 03 · Plusieurs services (26:40 -> 26:50)

- Dernière partie: une vraie app, c'est rarement un seul conteneur.

## Slide 15 : Docker Compose (26:50 -> 28:20)

- Une app complète = front, API, base de données. Avec docker run, ça fait trois longues commandes à retaper.
- Compose: on décrit les services dans UN fichier compose.yml. À gauche: web, api, db avec leur image ou leur dossier de build, les ports, le volume de la base.
- À droite: UNE commande, docker compose up -d, et les trois conteneurs démarrent, avec leur réseau.
- docker compose down arrête et supprime. Attention: down -v supprime AUSSI les volumes, donc les données.

## Slide 16 : Le réseau de Compose (28:20 -> 29:50)

- Compose crée un réseau et un DNS interne: chaque service est joignable par son NOM. L'API se connecte à la base avec db:5432, pas localhost (localhost, c'est le conteneur de l'API lui-même).
- Seul web publie un port (8080). L'API et la base ne sont pas accessibles depuis votre machine: moins de surface d'attaque.
- On peut même découper en deux réseaux: frontend (web et api), backend (api et db). web ne peut pas atteindre la base, même par erreur. C'est le projet 4.
- Message: le nom du service est le nom d'hôte.

## Slide 17 : Questions (29:50 -> 30:10)

- Questions rapides sur la théorie. Les questions de pratique, on les traite pendant les projets.

## Slide 18 : Les 4 mini-projets (30:10 -> 31:40)

- 4 projets de difficulté croissante, chacun réutilise le précédent: l'API, le front en multi-stage, API plus Postgres avec Compose, et la stack complète.
- Pour chacun: un README avec les consignes, des TODO dans les fichiers, des indices repliables, et un check.sh qui vous dit ce qui manque. La solution existe dans solutions/ mais c'est le dernier recours.
- Planning indicatif sur 1h30: projet 1 en 15 min, projet 2 en 20 min, projet 3 en 25 min, projet 4 en 30 min. Ceux qui vont vite font les bonus.
- Dernière slide: le QR code vers le repo. Faites git clone et lancez-vous. Je circule.

## Slide 19 : Le repo (31:40 -> fin)

- Laisser cette slide affichée pendant toute la partie pratique.
- Pour les élèves bloqués: lire l'erreur, docker logs, puis demander. Rappeler le CHEATSHEET.md.
- Dernières minutes: demander lequel des 4 projets était le plus dur, et rappeler que la doc officielle est dans le README du repo.
