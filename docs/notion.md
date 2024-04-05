# Synchronisation du Readme avec Notion

## Entrées

| nom             | description                          | requis | par défaut |
| --------------- | ------------------------------------ | ------ | ---------- |
| `notion-page-id`| ID de la page Notion à synchroniser  | `true` |            |
| `file-path`     | Chemin du fichier à synchroniser avec Notion | `false` | `README.md` |

## Secrets

| nom             | description                          |
| --------------- | ------------------------------------ |
| `notion-token`  | Token Notion pour l'authentification |

## Jobs

Le workflow contient un seul job, `sync_readme_to_notion`.

### sync_readme_to_notion

Ce job s'exécute sur le groupe par défaut dans un conteneur avec l'image `ubuntu:22.04`.

Les étapes pour ce job sont :

- Extraire le code en utilisant l'action `actions/checkout@v4`.
- Télécharger le fichier spécifié vers Notion en utilisant l'action `agonzalezl/readme-to-notion-action`.
