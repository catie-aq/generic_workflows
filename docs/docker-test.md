---
titre: Lint de Dockerfile
---

# Lint de Dockerfile

Analyse un Dockerfile du dépôt appelant avec hadolint et échoue à partir du niveau `warning`. À appeler dans la CI d'un dépôt qui contient un Dockerfile.

Fichier : `.github/workflows/docker-test.yaml` · Déclencheur : `workflow_call` · Runner : `sonu-github-arc`

## Utilisation

```yaml
jobs:
  lint-dockerfile:
    uses: catie-aq/generic_workflows/.github/workflows/docker-test.yaml@main
    with:
      dockerfile: Dockerfile
```

## Entrées

| Nom | Type | Description | Requis | Défaut |
| ------------ | ------- | ---------------------------------------- | ----- | ------------ |
| `dockerfile` | string | Chemin du Dockerfile à analyser | oui | |
| `ignore` | string | Règles hadolint ignorées, séparées par des virgules | non | `DL3008, DL3015` |

## Secrets

| Nom | Description | Requis |
| ------------ | ---------------------------------------- | ----- |

Aucune.

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |

Aucune.

## Fonctionnement

Job `check-dockerfile` (runner `sonu-github-arc`, sans conteneur) :

1. `actions/checkout@v2`.
2. `hadolint/hadolint-action@master` avec `dockerfile`, `failure-threshold: warning` et `ignore`.

## Dépendances

Aucune.

## Points d'attention

- Le nom du workflow (« Lint Dockerfile, Build Docker image, Scout Quickview ») ne correspond plus au code : seul le lint est fait. L'étape Docker Scout a été retirée au commit `b5b1824`, la construction de l'image au commit `59ff242`.
- `hadolint/hadolint-action@master` suit une branche, pas une version figée.
- `actions/checkout@v2` est une version ancienne (runtime Node dépréciée par GitHub).
