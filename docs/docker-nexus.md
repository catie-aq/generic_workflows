---
titre: Publication d'image Docker sur Nexus (obsolète)
---

# Publication d'image Docker sur Nexus (obsolète)

Construit l'image Docker du dépôt appelant et la pousse sur un registre Nexus, taguée avec le dernier tag semver du dépôt. Obsolète : le workflow affiche un avertissement de dépréciation puis se termine volontairement en échec. Utiliser [docker-ghcr](docker-ghcr.md) à la place.

Fichier : `.github/workflows/docker-nexus.yml` · Déclencheur : `workflow_call` · Runner : `${{ inputs.workflow_host }}` (défaut `self-hosted`)

## Utilisation

```yaml
jobs:
  docker:
    uses: catie-aq/generic_workflows/.github/workflows/docker-nexus.yml@main
    secrets:
      nexus_username: ${{ secrets.NEXUS_USERNAME }}
      nexus_password: ${{ secrets.NEXUS_PASSWORD }}
      nexus_host: ${{ secrets.NEXUS_HOST }}
```

## Entrées

| Nom | Type | Description | Requis | Défaut |
| ------------ | ------- | ---------------------------------------- | ----- | ------------ |
| `workflow_host` | string | Libellé du runner GitHub Actions (`runs-on`) | non | `self-hosted` |
| `submodules` | string | Récupération des sous-modules au checkout (`true`, `recursive` ou `false`) | non | `"false"` |

## Secrets

| Nom | Description | Requis |
| ------------ | ---------------------------------------- | ----- |
| `build_args` | Arguments de construction (`build-args`) du Dockerfile | non |
| `nexus_username` | Nom d'utilisateur du registre Nexus | oui |
| `nexus_password` | Mot de passe du registre Nexus | oui |
| `nexus_host` | Adresse du registre Nexus (préfixe des tags) | oui |
| `PAT` | Jeton d'accès personnel utilisé pour le checkout | non |

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |

Aucune.

## Fonctionnement

Job `build` (runner `${{ inputs.workflow_host }}`, conteneur `docker:dind`) :

1. Affiche un avertissement de dépréciation qui renvoie vers `docker-ghcr.yml`.
2. `actions/checkout@v4` avec `submodules` et `token: PAT`.
3. `actions-ecosystem/action-get-latest-tag@v1` (`semver_only: true`, `initial_version: "0.0.0"`).
4. `docker/login-action@v3` sur `nexus_host`.
5. `docker/build-push-action@v5` : contexte `.`, `push: true`, tag `<nexus_host>/<nom du dépôt>:<dernier tag>`, `build-args` = `build_args`.
6. `exit 1` : le job échoue volontairement.

## Dépendances

Aucune.

## Points d'attention

- Obsolète : le job échoue toujours (dernière étape `exit 1`), même quand l'image a été poussée.
- Le message de dépréciation cite `catie-aq/generic_workflows/.github/docker-ghcr.yml`, chemin incomplet (il manque `workflows/`).
- Les secrets sont déclarés `nexus_username` / `nexus_password` mais lus en majuscules (`NEXUS_USERNAME`, `NEXUS_PASSWORD`) ; cela fonctionne car les expressions GitHub ne sont pas sensibles à la casse.
- `token: ${{ secrets.PAT }}` est passé au checkout même quand `PAT` n'est pas fourni.
- Le tag de l'image est le dernier tag git, pas la version du commit construit.
