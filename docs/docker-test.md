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

## Choix de hadolint

Hadolint compare chaque instruction du Dockerfile aux bonnes pratiques Docker : version d'image de base figée plutôt que `latest`, utilisateur non root, commandes `RUN` regroupées, cache des gestionnaires de paquets nettoyé. Il est léger, rapide et ses règles s'ignorent une par une (entrée `ignore`), d'où son adoption en CI.

Limites :

- il analyse le texte du Dockerfile, pas l'image construite ni le conteneur en exécution ;
- il ne remplace pas un scanner de vulnérabilités (Trivy, Clair) ;
- certaines règles sont trop strictes selon le contexte : les ignorer explicitement plutôt que baisser le seuil.

Pour l'exécuter en local avant commit, hook pre-commit :

```yaml
repos:
  - repo: https://github.com/hadolint/hadolint
    rev: v2.12.0
    hooks:
      - id: hadolint
```

## Dépendances

Aucune.

## Points d'attention

- Le nom du workflow (« Lint Dockerfile, Build Docker image, Scout Quickview ») ne correspond plus au code : seul le lint est fait. L'étape Docker Scout a été retirée au commit `b5b1824`, la construction de l'image au commit `59ff242`.
- `hadolint/hadolint-action@master` suit une branche, pas une version figée.
- `actions/checkout@v2` est une version ancienne (runtime Node déprécié par GitHub).
