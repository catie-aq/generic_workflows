---
titre: Exécution de pre-commit
---

# Exécution de pre-commit

Exécute `pre-commit run --all-files` sur le dépôt appelant, dans l'image `ghcr.io/catie-aq/pre-commit_docker` qui embarque pre-commit. À appeler dans la CI de tout dépôt doté d'un `.pre-commit-config.yaml`.

Fichier : `.github/workflows/pre-commit.yaml` · Déclencheur : `workflow_call` · Runner : `sonu-github-arc`

## Utilisation

```yaml
jobs:
  pre-commit:
    uses: catie-aq/generic_workflows/.github/workflows/pre-commit.yaml@main
```

## Entrées

| Nom | Type | Description | Requis | Défaut |
| ------------ | ------- | ---------------------------------------- | ----- | ------------ |
| `image-tag` | string | Tag de l'image `ghcr.io/catie-aq/pre-commit_docker` (pas de description dans le code) | non | `latest` |

## Secrets

| Nom | Description | Requis |
| ------------ | ---------------------------------------- | ----- |

Aucune.

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |

Aucune.

## Fonctionnement

Job `pre-commit` (runner `sonu-github-arc`, conteneur `ghcr.io/catie-aq/pre-commit_docker:${{ inputs.image-tag }}`) :

1. `actions/checkout@v4` dans le sous-dossier `folder`.
2. `cd folder/` puis `pre-commit run --color=always --all-files`.

## Dépendances

- Image `ghcr.io/catie-aq/pre-commit_docker` (dépôt `catie-aq/pre-commit_docker`).

## Points d'attention

- Le tag par défaut `latest` n'est pas figé : une nouvelle image peut changer le résultat sans modification du dépôt appelant.
- L'entrée `image-tag` n'a pas de `description` dans le code.
