# Déploiement avec Docker Compose

Il a deux entrées : `docker_host` et `extra_args`, et trois secrets : `env_variables`, `TS_OAUTH_CLIENT_ID` et `TS_OAUTH_SECRET`.

## Entrées

| nom           | description                          | requis | par défaut |
| ------------- | ------------------------------------ | ------ | ---------- |
| `docker_host` | Docker Host                          | `false` | `tcp://100.121.122.93:2375` |
| `extra_args`  | Arguments supplémentaires pour la commande up | `false` | `""` |

## Secrets

| nom                 | description                          |
| ------------------- | ------------------------------------ |
| `env_variables`     | Variables d'environnement            |
| `TS_OAUTH_CLIENT_ID`| Tailscale OAuth Client ID            |
| `TS_OAUTH_SECRET`   | Tailscale OAuth Secret               |

## Jobs

Le workflow contient un seul job, `deploy`.

### deploy

Ce job s'exécute dans un conteneur avec l'image `ubuntu:22.04`.

Les étapes pour ce job sont :

- Installer sudo, curl, git, docker-compose.
- Configurer Tailscale en utilisant l'action `tailscale/github-action@v2`.
- Extraire le code en utilisant l'action `actions/checkout@v4`.
- Exécuter `docker-compose up -d --build --force-recreate`
