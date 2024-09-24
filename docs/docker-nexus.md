# Construction de Docker et push vers Nexus

Ce workflow GitHub Actions est déclenché lorsqu'un appel de workflow est effectué. Il a une entrée : `nexus_host`, et trois secrets : `build_args`, `nexus_username` et `nexus_password`.

Deprecated : Ce workflow n'est plus utilisé. Il est remplacé par `docker-ghcr.yml`.

## Entrées

| nom           | description                          | requis | par défaut |
| ------------- | ------------------------------------ | ------ | ---------- |
| `nexus_host`  | IP de Nexus                          | `false` | `NEXUS_REGISTRY_HOST` |

## Secrets

| nom             | description                          |
| --------------- | ------------------------------------ |
| `build_args`    | Arguments de construction pour Dockerfile |
| `nexus_username`| Nom d'utilisateur Nexus |
| `nexus_password`| Mot de passe Nexus |

## Jobs

Le workflow contient un seul job, `build`.

### build

Ce job s'exécute sur le groupe par défaut dans un conteneur avec l'image `docker:dind`.

Les étapes pour ce job sont :

- Extraire le code en utilisant l'action `actions/checkout@v4`.
- Obtenir le dernier tag en utilisant l'action `actions-ecosystem/action-get-latest-tag@v1`.
- Se connecter au registre Nexus en utilisant l'action `docker/login-action@v1`.
- Construire l'image Docker et la pousser vers Nexus en utilisant l'action `docker/build-push-action@v2`.
