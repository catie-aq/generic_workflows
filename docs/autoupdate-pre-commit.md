# Mise à jour automatique de pre-commit

Ce workflow GitHub Actions est conçu pour être déclenché sur une crontab. Il a une entrée : `path`, qui est le chemin vers le dossier contenant le package à mettre à jour.

## Entrées

| nom           | description                          | requis | par défaut |
| ------------- | ------------------------------------ | ------ | ---------- |
| `path`        | Chemin vers le dossier contenant le package à mettre à jour | `false` | `.` |

## Jobs

Le workflow contient un seul job, `auto-update`.

### auto-update

Ce job s'exécute sur le groupe par défaut dans un conteneur avec l'image `ubuntu:22.04`.

Les étapes pour ce job sont :

- Configurer Python en utilisant l'action `actions/setup-python@v2`.
- Installer sqlite3 et git.
- Installer pre-commit.
- Extraire le code en utilisant l'action `actions/checkout@v4`.
- Exécuter `pre-commit autoupdate` sur le package.
- Créer une pull request avec les modifications en utilisant l'action `peter-evans/create-pull-request@v3`.

La pull request créée a pour titre "Update pre-commit hooks", est étiquetée avec "dependencies", et demande une revue de la part de l'acteur GitHub qui a déclenché le workflow. La branche de la pull request est supprimée une fois que la pull request est fusionnée.
