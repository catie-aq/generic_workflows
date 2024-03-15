# Exécution de pre-commit

## Jobs

Le workflow contient un seul job, `pre-commit`.

### pre-commit

Ce job s'exécute sur le groupe par défaut dans un conteneur avec l'image `ubuntu:22.04`.

Les étapes pour ce job sont :

- Installer sqlite3 et git.
- Extraire le code en utilisant l'action `actions/checkout@v4`.
- Configurer Python en utilisant l'action `actions/setup-python@v3`.
- Installer pre-commit.
- Exécuter pre-commit sur tous les fichiers.
