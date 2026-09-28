---
titre: Mise à jour automatique des hooks pre-commit
---

# Mise à jour automatique des hooks pre-commit

Exécute `pre-commit autoupdate` dans le dépôt appelant et ouvre une pull request avec les nouvelles versions des hooks. À appeler typiquement depuis un workflow planifié (`schedule`).

Fichier : `.github/workflows/autoupdate-pre-commit.yml` · Déclencheur : `workflow_call` · Runner : `group: default`

## Utilisation

```yaml
on:
  schedule:
    - cron: "0 6 * * 1"

permissions:
  contents: write
  pull-requests: write

jobs:
  autoupdate:
    uses: catie-aq/generic_workflows/.github/workflows/autoupdate-pre-commit.yml@main
```

## Entrées

| Nom | Type | Description | Requis | Défaut |
| ------------ | ------- | ---------------------------------------- | ----- | ------------ |
| `path` | string | Chemin du dossier contenant le paquet à mettre à jour (celui qui porte `.pre-commit-config.yaml`) | non | `.` |

## Secrets

| Nom | Description | Requis |
| ------------ | ---------------------------------------- | ----- |

Aucune.

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |

Aucune.

## Fonctionnement

Permissions déclarées au niveau du workflow : `contents: write`, `pull-requests: write`.

Job `auto-update` (runner `group: default`, conteneur `ubuntu:22.04`) :

1. `actions/setup-python@v2`.
2. `apt-get update` puis installation de `sqlite3` et `git`.
3. Mise à jour de `pip` puis `pip install pre-commit`.
4. `actions/checkout@v4` dans le sous-dossier `folder`.
5. `cd folder/<path>` puis `pre-commit autoupdate`.
6. `peter-evans/create-pull-request@v6` sur `folder` : branche `update/pre-commit-hooks`, titre et message de commit « Update pre-commit hooks », auteur `GitHub <noreply@github.com>`, label `dependencies`, relecteur `${{ github.actor }}`, `delete-branch: true`.

## Dépendances

Aucune.

## Points d'attention

- `actions/setup-python@v2` est une version ancienne (runtime Node dépréciée par GitHub).
- Dans un workflow réutilisable, les `permissions` ne peuvent pas dépasser celles de l'appelant : l'appelant doit accorder `contents: write` et `pull-requests: write`.
- La pull request est créée avec le `GITHUB_TOKEN` : elle ne déclenche pas les workflows `pull_request` du dépôt (règle GitHub).
