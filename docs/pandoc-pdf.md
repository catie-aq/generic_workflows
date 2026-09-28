---
titre: Génération de PDF avec Pandoc
---

# Génération de PDF avec Pandoc

Compile les documents Markdown du dépôt appelant en PDF via son script `compile.sh`, publie les PDF en artefact et, sur un tag, les joint à une release GitHub en brouillon.

Fichier : `.github/workflows/pandoc-pdf.yml` · Déclencheur : `workflow_call` · Runner : `sonu-github-arc`

## Utilisation

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

permissions:
  contents: write

jobs:
  build:
    uses: catie-aq/generic_workflows/.github/workflows/pandoc-pdf.yml@main
    secrets:
      personal_access_token: ${{ secrets.PAT }}
```

Prérequis dans le dépôt appelant :

- un script `compile.sh` à la racine, exécuté avec `bash` ;
- ce script écrit les PDF dans `out/*.pdf`.

## Entrées

| Nom | Type | Description | Requis | Défaut |
| ------------ | ------- | ---------------------------------------- | ----- | ------------ |

Aucune.

## Secrets

| Nom | Description | Requis |
| ------------ | ---------------------------------------- | ----- |
| `personal_access_token` | Jeton d'accès aux dépôts privés du propriétaire du dépôt (dépendances, sous-modules, gabarits clonés par `compile.sh`) | oui |

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |

Aucune.

## Fonctionnement

Job `build` (runner `sonu-github-arc`, conteneur `pandoc/extra:3.9.0.0-alpine`) :

1. `actions/checkout@v4`.
2. `apk add --no-cache bash nodejs npm git`.
3. `git config --global url."https://x-access-token:<personal_access_token>@github.com/<propriétaire>/".insteadOf "https://github.com/<propriétaire>/"` : les clones HTTPS des dépôts du propriétaire utilisent le jeton.
4. Détection de l'année TeX Live (`tlmgr --version`) et choix du miroir `https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/<année>/tlnet-final` ; échec si l'année n'est pas détectée.
5. `tlmgr install placeins mathtools nomencl hyphenat lastpage lipsum newunicodechar pdfpages jknapltx raleway pdflscape rsfs soul`.
6. `bash compile.sh`.
7. `actions/upload-artifact@v4` : artefact `pdf-documents`, chemin `out/*.pdf`, échec si aucun fichier.
8. Si `github.ref_type == 'tag'` : `softprops/action-gh-release@v2` avec `out/*.pdf`, `generate_release_notes: true`, `draft: true`, jeton `GITHUB_TOKEN`.

## Dépendances

Aucune.

## Points d'attention

- Le workflow ne déclare pas de `permissions` : pour la release sur tag, le `GITHUB_TOKEN` de l'appelant doit avoir `contents: write`.
- La compilation dépend d'un miroir TeX Live externe (`ftp.math.utah.edu`, archives `tlnet-final`).
- Le secret `personal_access_token` est obligatoire même si `compile.sh` ne clone aucun dépôt privé.
