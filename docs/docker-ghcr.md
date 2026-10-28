---
titre: Publication d'image Docker sur GHCR
---

# Publication d'image Docker sur GHCR

Construit l'image Docker du dépôt appelant et la pousse sur GitHub Container Registry (`ghcr.io/<propriétaire>/<dépôt>`), avec des tags déduits de l'événement Git. Remplace `docker-nexus.yml`.

Fichier : `.github/workflows/docker-ghcr.yml` · Déclencheur : `workflow_call` · Runner : `sonu-github-arc`

## Utilisation

```yaml
permissions:
  contents: read
  packages: write

jobs:
  docker:
    uses: catie-aq/generic_workflows/.github/workflows/docker-ghcr.yml@main
    with:
      Dockerfile: .
      target: production
    secrets:
      PAT: ${{ secrets.PAT }}
```

## Entrées

| Nom | Type | Description | Requis | Défaut |
| ------------ | ------- | ---------------------------------------- | ----- | ------------ |
| `Dockerfile` | string | Contexte de construction (chemin du dossier, malgré le nom de l'entrée) | non | `.` |
| `file` | string | Chemin du Dockerfile s'il n'est pas à la racine du contexte | non | `""` |
| `target` | string | Cible (`--target`) du Dockerfile multi-étapes ; ajoutée en suffixe `-<target>` aux tags | non | |
| `sha_tag` | boolean | Publie en plus le tag immuable `sha-<sha complet du commit>`, pour déployer un build précis | non | `false` |

## Secrets

| Nom | Description | Requis |
| ------------ | ---------------------------------------- | ----- |
| `build_args` | Arguments de construction (`build-args`) du Dockerfile, un par ligne `CLE=valeur` | non |
| `build_secrets` | Secrets BuildKit pour `RUN --mount=type=secret`, un par ligne `id=valeur` | non |
| `PAT` | Jeton d'accès personnel pour les sous-modules privés ou les images privées | non |

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |
| `digest` | Digest de l'image poussée (`sha256:…`), pour déployer exactement ce build |

## Fonctionnement

Variables d'environnement du workflow : `REGISTRY=ghcr.io`, `IMAGE_NAME=${{ github.repository }}`, `PAT=${{ secrets.PAT }}`.

Job `publish` (runner `sonu-github-arc`, sans conteneur, permissions `contents: read` et `packages: write`) :

1. `sudo apt-get update && sudo apt-get install git -y`.
2. Si `PAT` est fourni : `actions/checkout@v4` avec `submodules: true` et `token: PAT`. Sinon : `actions/checkout@v4` sans sous-modules.
3. Connexion à `ghcr.io` avec `docker/login-action@v1` : `GITHUB_TOKEN` si `PAT` est vide, `PAT` sinon (utilisateur `${{ github.actor }}`).
4. Étape `suffix` : calcule `-<target>` (ou vide) via `::set-output`.
5. `docker/metadata-action` (épinglé au commit `9ec57ed1fcdbf14dcef7dfbe97b2010124a938b7`) sur `ghcr.io/<dépôt>`, avec `flavor: suffix=<suffixe>` et les règles `tags:` `type=schedule`, `type=ref,event=branch`, `type=ref,event=tag`, `type=ref,event=pr` (règles par défaut de l'action) et `type=sha,format=long`, active seulement si `sha_tag` vaut `true`.
6. Étape `file` : calcule le chemin du Dockerfile via `::set-output`.
7. Étape `cache` : calcule le package de cache `<dépôt>-buildcache` (en minuscules) et sa référence `ghcr.io/<propriétaire>/<dépôt>-buildcache:<target ou default>`.
8. `docker/setup-buildx-action@v4`.
9. `docker/build-push-action@v6` (id `build`) : `context` = `Dockerfile`, `file`, `push: true`, tags et labels de l'étape 5, `target`, `build-args` = `build_args`, `secrets` = `build_secrets`, `cache-from` et `cache-to` sur la référence de l'étape 7 (voir « Cache de construction »).
10. `actions/delete-package-versions@v5` supprime les versions sans tag du package de cache (`continue-on-error`).

### Cache de construction

Les runners ARC sont jetables : sans cache externe, chaque build rejoue toutes les couches du Dockerfile. BuildKit lit donc son cache sur ghcr avant le build (`cache-from`) et l'y réécrit après (`cache-to`, `mode=max` pour garder aussi les couches des étapes intermédiaires, `image-manifest=true` et `oci-mediatypes=true` pour un manifeste que ghcr accepte). Une couche dont les entrées n'ont pas changé (fichier de dépendances, instructions qui la précèdent) est téléchargée au lieu d'être reconstruite.

Le cache vit dans un package distinct de l'image, `<dépôt>-buildcache`, avec un tag par `target`. Chaque build écrase ce tag et laisse l'ancien manifeste sans tag ; l'étape 10 purge ces versions. Comme le package est séparé, la purge ne touche jamais les versions de l'image elle-même, qui peuvent rester déployées par digest.

Un échec d'écriture du cache (`ignore-error=true`) ou de la purge (`continue-on-error`) ne fait pas échouer la publication.

### Tags produits

Règles par défaut de [docker/metadata-action](https://github.com/docker/metadata-action), reprises explicitement dans `tags:` :

| Événement | Référence Git | Tags Docker |
| -------------------- | ------------------------------ | ------------------------------ |
| `pull_request` | `refs/pull/2/merge` | `pr-2` |
| `push` | `refs/heads/master` | `master` |
| `push` | `refs/heads/releases/v1` | `releases-v1` |
| `push tag` | `refs/tags/v1.2.3` | `v1.2.3`, `latest` |
| `push tag` | `refs/tags/v2.0.8-beta.67` | `v2.0.8-beta.67`, `latest` |
| `workflow_dispatch` | `refs/heads/master` | `master` |

Avec `sha_tag: true`, chaque build ajoute le tag `sha-<sha complet du commit>` (ex. `sha-3adda15…`), à passer au déploiement (`--set image.tag=sha-${{ github.sha }}`).

Si `target` est donnée, les tags sont suffixés par `-<target>`.

## Dépendances

Aucune.

## Points d'attention

- `::set-output` est déprécié par GitHub (étapes `suffix` et `file`).
- Les tests shell `[ ${{ inputs.target }} != "" ]` et `[ ${{ inputs.file }} == "" ]` ne mettent pas la valeur entre guillemets : quand l'entrée est vide, `[` échoue et c'est la branche `else` qui s'exécute. Le résultat reste correct (suffixe vide ; `file` vide, donc `Dockerfile` du contexte par défaut de `docker/build-push-action`), mais la branche `<Dockerfile>/Dockerfile` n'est jamais atteinte.
- L'entrée `Dockerfile` désigne le contexte de construction, pas le Dockerfile.
- `docker/login-action@v1` est une version ancienne (runtime Node déprécié par GitHub).
- Les permissions du job (`packages: write`) doivent être accordées par l'appelant.
- Le stockage sur ghcr des images de conteneurs est gratuit d'après la documentation GitHub, qui promet un préavis d'un mois avant tout changement. Si ghcr devenait payant, il suffirait de pointer `cache-from` et `cache-to` vers un registre local.
- Quand la connexion se fait avec `PAT`, le package de cache est créé au nom du propriétaire du jeton ; la purge, qui utilise `GITHUB_TOKEN`, peut alors manquer de droits (sans bloquer la publication).

> À vérifier : d'après la documentation de `docker/metadata-action`, le suffixe de `flavor` n'est pas appliqué au tag `latest` par défaut (`onlatest=false`) ; plusieurs `target` publiées depuis un même tag écriraient alors toutes `latest`.
