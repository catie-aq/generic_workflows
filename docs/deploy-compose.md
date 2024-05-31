# Déploiement avec Docker Compose

Il a deux entrées : `docker_host` et `extra_args`, et trois secrets : `env_variables`.

## Entrées

| nom           | description                          | requis | par défaut |
| ------------- | ------------------------------------ | ------ | ---------- |
| `docker_host` | Docker Host                          | `false` | `tcp://192.168.73.6:2375` |
| `extra_args`  | Arguments supplémentaires pour la commande up | `false` | `""` |

## Secrets

| nom                 | description                          |
| ------------------- | ------------------------------------ |
| `env_variables`     | Variables d'environnement            |

## Jobs

Le workflow contient un seul job, `deploy`.

### deploy

Ce job s'exécute dans un conteneur avec l'image `ubuntu:22.04`.

Les étapes pour ce job sont :

- Installer sudo, curl, git, docker-compose.
- Extraire le code en utilisant l'action `actions/checkout@v4`.
- Exécuter `docker-compose up -d --build --force-recreate`
