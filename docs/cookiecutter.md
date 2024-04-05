# Test du template Cookiecutter

Ce workflow GitHub Actions est conçu pour être déclenché sur une crontab. Il a deux entrées : `config-file` et `python-version`.

## Entrées

| nom             | description                          | requis | par défaut |
| --------------- | ------------------------------------ | ------ | ---------- |
| `config-file`   | Fichier de configuration pour Cookiecutter | `false` | |
| `python-version`| Version de Python à utiliser | `false` | `3.10` |

## Jobs

Le workflow contient un seul job, `build`.

### build

Ce job s'exécute sur le groupe par défaut dans un conteneur avec l'image `python:${{ inputs.python-version }}`.

Les étapes pour ce job sont :

- Extraire le code en utilisant l'action `actions/checkout@v3`.
- Installer Cookiecutter.
- Exécuter Cookiecutter avec le fichier de configuration si `inputs.config-file` est fourni.
- Exécuter Cookiecutter sans fichier de configuration si `inputs.config-file` n'est pas fourni.
