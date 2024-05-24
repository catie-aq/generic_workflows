# Helm chart upgrade

## Entrées

| nom            | description        | requis  | par défaut    |
| -------------- | ------------------ | ------- | ------------- |
| `release_name` | Nom de la release  | `true`  |               |
| `namespace`    | Namespace          | `false` | `default`     |
| `chart_path`   | Chemin du chart    | `false` | `.`           |
| `values_file`  | Fichier de valeurs | `false` | `values.yaml` |
| `submodule`    | Fetch submodule ?  | `false` | `false`       |

## Secrets

| nom          | description |
| ------------ | ----------- |
| `kubeconfig` | Kubeconfig  |

## Jobs

Le workflow contient un seul job, `deployment`.

### deployment

Ce job s'exécute sur le runner `sonu-github-arc` dans un conteneur avec l'image `ubuntu:latest`.

Les étapes pour ce job sont :

- Installer les dépendances en utilisant une commande shell.
- Extraire le code en utilisant l'action `actions/checkout@v3`.
- Déployer en utilisant l'action `WyriHaximus/github-action-helm3@v3` avec les paramètres appropriés.
