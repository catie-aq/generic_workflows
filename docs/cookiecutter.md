---
titre: Test d'un template Cookiecutter
---

# Test d'un template Cookiecutter

Vérifie qu'un template Cookiecutter (le dépôt appelant) se génère sans erreur, sans interaction, avec ou sans fichier de configuration. À appeler depuis la CI du dépôt du template.

Fichier : `.github/workflows/cookiecutter.yml` · Déclencheur : `workflow_call` · Runner : `group: default`

## Utilisation

```yaml
jobs:
  cookiecutter:
    uses: catie-aq/generic_workflows/.github/workflows/cookiecutter.yml@main
    with:
      config-file: tests/config.yaml
      python-version: "3.12"
```

## Entrées

| Nom | Type | Description | Requis | Défaut |
| ------------ | ------- | ---------------------------------------- | ----- | ------------ |
| `config-file` | string | Fichier de configuration passé à `cookiecutter --config-file` (pas de description dans le code) | non | |
| `python-version` | string | Version de Python, utilisée comme tag de l'image `python` (pas de description dans le code) | non | `3.10` |

## Secrets

| Nom | Description | Requis |
| ------------ | ---------------------------------------- | ----- |

Aucune.

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |

Aucune.

## Fonctionnement

Permissions déclarées au niveau du workflow : `read-all`.

Job `build` (runner `group: default`, conteneur `python:${{ inputs.python-version }}`) :

1. `actions/checkout@v4`.
2. `pip install cookiecutter`.
3. Si `config-file` est renseigné : `cookiecutter . --no-input --config-file <config-file>`.
4. Sinon : `cookiecutter . --no-input`.

## Dépendances

Aucune.

## Points d'attention

- Les entrées n'ont pas de `description` dans le code.
- La version de Cookiecutter n'est pas figée (`pip install cookiecutter`).
