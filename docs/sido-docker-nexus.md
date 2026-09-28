---
titre: Publication d'image Docker sur Nexus (SIDO)
---

# Publication d'image Docker sur Nexus (SIDO)

Workflow spécifique à l'équipe SIDO. Construit l'image Docker du dépôt appelant et la pousse sur un registre Nexus sous le nom et le tag fournis.

Fichier : `.github/workflows/sido-docker-nexus.yml` · Déclencheur : `workflow_call` · Runner : `${{ inputs.workflow_host }}` (défaut `self-hosted`)

## Utilisation

```yaml
jobs:
  docker:
    uses: catie-aq/generic_workflows/.github/workflows/sido-docker-nexus.yml@main
    with:
      image_name: mon-image
      image_tag: 1.2.3
    secrets:
      nexus_username: ${{ secrets.NEXUS_USERNAME }}
      nexus_password: ${{ secrets.NEXUS_PASSWORD }}
      nexus_host: ${{ secrets.NEXUS_HOST }}
```

## Entrées

| Nom | Type | Description | Requis | Défaut |
| ------------ | ------- | ---------------------------------------- | ----- | ------------ |
| `image_name` | string | Nom de l'image Docker | oui | |
| `image_tag` | string | Tag de l'image Docker | oui | |
| `workflow_host` | string | Libellé du runner GitHub Actions (`runs-on`) | non | `self-hosted` |
| `submodules` | string | Récupération des sous-modules au checkout (`true`, `recursive` ou `false`) | non | `"false"` |

## Secrets

| Nom | Description | Requis |
| ------------ | ---------------------------------------- | ----- |
| `build_args` | Arguments de construction (`build-args`) du Dockerfile | non |
| `nexus_username` | Nom d'utilisateur du registre Nexus | oui |
| `nexus_password` | Mot de passe du registre Nexus | oui |
| `nexus_host` | Adresse du registre Nexus (préfixe des tags) | oui |

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |

Aucune.

## Fonctionnement

Job `build` (runner `${{ inputs.workflow_host }}`, conteneur `docker:dind`) :

1. `actions/checkout@v4` avec `submodules`.
2. `docker/login-action@v3` sur `nexus_host`.
3. `docker/build-push-action@v5` : contexte `.`, `push: true`, tag `<nexus_host>/<image_name>:<image_tag>`, `build-args` = `build_args`.

## Dépendances

Aucune.

## Points d'attention

- Variante SIDO de `docker-nexus.yml`, sans l'échec volontaire de dépréciation : c'est le seul workflow Nexus encore fonctionnel.
- Les secrets sont déclarés `nexus_username` / `nexus_password` mais lus en majuscules (`NEXUS_USERNAME`, `NEXUS_PASSWORD`) ; cela fonctionne car les expressions GitHub ne sont pas sensibles à la casse.
- Pas de secret `PAT` : les sous-modules privés ne peuvent être récupérés qu'avec le `GITHUB_TOKEN` par défaut.
