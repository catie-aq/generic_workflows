---
titre: Déploiement Docker Compose
---

# Déploiement Docker Compose

Lance `docker-compose up -d --build --force-recreate` du dépôt appelant contre un démon Docker distant (variable `DOCKER_HOST`). À utiliser pour déployer une application décrite par un fichier Compose à la racine du dépôt.

Fichier : `.github/workflows/deploy-compose.yml` · Déclencheur : `workflow_call` · Runner : `sonu-github-arc`

## Utilisation

```yaml
jobs:
  deploy:
    uses: catie-aq/generic_workflows/.github/workflows/deploy-compose.yml@main
    with:
      docker_host: tcp://<hôte>:2375
    secrets:
      env_variables: ${{ secrets.COMPOSE_ENV }}
```

## Entrées

| Nom | Type | Description | Requis | Défaut |
| ------------ | ------- | ---------------------------------------- | ----- | ------------ |
| `docker_host` | string | Adresse du démon Docker cible (`DOCKER_HOST`) | non | adresse IP interne codée en dur dans le `.yml` (non reprise ici) |
| `extra_args` | string | Arguments supplémentaires pour la commande `up` (non utilisé, voir Points d'attention) | non | `""` |

## Secrets

| Nom | Description | Requis |
| ------------ | ---------------------------------------- | ----- |
| `env_variables` | Variables d'environnement préfixées à la commande, au format `VAR1=valeur1 VAR2=valeur2` | non |

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |

Aucune.

## Fonctionnement

Job `deploy` (runner `sonu-github-arc`, environment GitHub `compose`, conteneur `ubuntu:22.04`) :

1. `apt update` puis installation de `sudo`, `curl`, `git`, `docker-compose`.
2. `actions/checkout@v4`.
3. `<env_variables> DOCKER_HOST=<docker_host> docker-compose up -d --build --force-recreate`.

## Dépendances

Aucune.

## Points d'attention

- L'entrée `extra_args` est déclarée mais n'est pas utilisée dans la commande `docker-compose up`.
- La valeur par défaut de `docker_host` est une adresse IP interne codée en dur dans un dépôt public ; passer `docker_host` explicitement.
- La connexion au démon Docker se fait en `tcp://` sans TLS.
- Le secret `env_variables` est inséré tel quel dans la ligne de commande shell (pas d'échappement).
- L'environment GitHub `compose` est fixe : ses règles de protection et ses secrets s'appliquent à tout appelant.
- `docker-compose` est la version 1 fournie par les paquets Ubuntu 22.04 (et non le plugin `docker compose`).
