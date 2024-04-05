# Mise à jour du dépôt avec Cruft

Ce workflow GitHub Actions est conçu pour être déclenché sur une crontab. Il a une entrée secrète : `token`, qui est un Personal Access Token.

## Entrées secrètes

| nom           | description                          | requis |
| ------------- | ------------------------------------ | ------ |
| `token`       | Personal Access Token                | `true` |

## Jobs

Le workflow contient un seul job, `update`.

### update

Ce job s'exécute sur le groupe par défaut dans un conteneur avec l'image `ubuntu:22.04`.

Les étapes pour ce job sont :

- Configurer Python en utilisant l'action `actions/setup-python@v4`.
- Installer Cruft.
- Installer Git.
- Extraire le code en utilisant l'action `actions/checkout@v4`.
- Configurer les permissions pour Git.
- Vérifier si une mise à jour est disponible en utilisant Cruft.
- Exécuter la mise à jour si elle est disponible.
- Créer une pull request avec les modifications en utilisant l'action `peter-evans/create-pull-request@v4`.

La pull request créée a pour titre "Update repository with Cruft", est étiquetée avec "dependencies", et demande une revue de la part de l'acteur GitHub qui a déclenché le workflow. La branche de la pull request est supprimée une fois que la pull request est fusionnée.
