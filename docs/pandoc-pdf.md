# Génération de PDF avec Pandoc

Ce workflow GitHub Actions est déclenché lorsqu'un appel de workflow est effectué. Il compile des documents PDF avec Pandoc, publie les fichiers en artefacts, puis crée une release GitHub (draft) quand l'exécution est lancée sur un tag.

## Secrets

| nom                     | description                                                                                             | requis |
|-------------------------|---------------------------------------------------------------------------------------------------------|--------|
| `personal_access_token` | Token utilisé pour accéder aux dépôts privés de l'organisation (ex: dépendances, submodules, templates) | `true` |

## Prérequis dans le dépôt appelant

- Un script `compile.sh` à la racine du dépôt.
- Le script doit générer les fichiers PDF dans `out/*.pdf`.
- Le secret `personal_access_token` doit être défini dans le dépôt appelant.

## Jobs

Le workflow contient un seul job, `build`.

### build

Ce job s'exécute sur le runner `sonu-github-arc` dans le conteneur `pandoc/extra:3.9.0.0-alpine`.

Les étapes pour ce job sont :

- Extraire le code en utilisant `actions/checkout@v4`.
- Installer les dépendances système (`bash`, `nodejs`, `npm`, `git`).
- Configurer git avec le `personal_access_token` pour les dépôts privés de `github.com/${GITHUB_REPOSITORY_OWNER}`.
- Détecter l'année TeX Live et configurer le miroir `tlnet-final` correspondant.
- Installer les paquets TeX nécessaires via `tlmgr`.
- Exécuter `bash compile.sh`.
- Publier les PDF générés en artefacts (`actions/upload-artifact@v4`, nom `pdf-documents`, chemin `out/*.pdf`).
- Créer une release GitHub draft sur tag avec `softprops/action-gh-release@v2`.

## Exemple d'utilisation

```yaml
name: Build PDF

on:
  push:
    branches: [main]
    tags:
      - "*"
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    uses: catie-aq/generic_workflows/.github/workflows/pandoc-pdf.yml@add-md-latex-pdf-workflow
    secrets:
      personal_access_token: ${{ secrets.PAT }}
```
