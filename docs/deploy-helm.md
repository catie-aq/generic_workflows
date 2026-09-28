---
titre: Déploiement Helm
---

# Déploiement Helm

Installe ou met à jour une release Helm (`helm upgrade --install --wait --atomic`) à partir d'un chart du dépôt appelant, avec un kubeconfig fourni en secret. Peut au préalable ajouter et mettre à jour un dépôt de charts Helm.

Fichier : `.github/workflows/deploy-helm.yml` · Déclencheur : `workflow_call` · Runner : `sonu-github-arc`

## Utilisation

```yaml
jobs:
  deploy:
    uses: catie-aq/generic_workflows/.github/workflows/deploy-helm.yml@main
    with:
      release_name: mon-application
      namespace: mon-namespace
      chart_path: helm
      values_file: helm/values.yaml
    secrets:
      kubeconfig: ${{ secrets.KUBECONFIG }}
```

## Entrées

| Nom | Type | Description | Requis | Défaut |
| ------------ | ------- | ---------------------------------------- | ----- | ------------ |
| `release_name` | string | Nom de la release Helm | oui | |
| `namespace` | string | Namespace Kubernetes (créé s'il n'existe pas) | non | `default` |
| `chart_path` | string | Chemin du chart dans le dépôt | non | `.` |
| `values_file` | string | Fichier de valeurs passé à `--values` | non | `values.yaml` |
| `environment` | string | Nom de l'environment GitHub du job | non | `k8s_discodiode` |
| `extra_args` | string | Arguments supplémentaires insérés dans `helm upgrade` | non | `""` |
| `update` | boolean | Ajoute puis met à jour un dépôt de charts avant le déploiement | non | `false` |
| `update_chart_name` | string | Nom du dépôt de charts pour `helm repo add` (si `update`) | non | `""` |
| `update_chart_url` | string | URL du dépôt de charts pour `helm repo add` (si `update`) | non | `""` |

## Secrets

| Nom | Description | Requis |
| ------------ | ---------------------------------------- | ----- |
| `kubeconfig` | Contenu du kubeconfig d'accès au cluster | oui |
| `extra_secret` | Arguments sensibles insérés dans `helm upgrade` (par exemple `--set cle=valeur`) | non |

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |

Aucune.

## Fonctionnement

Job `deployment` (runner `sonu-github-arc`, conteneur `ubuntu:latest`, environment GitHub `${{ inputs.environment }}`) :

1. `apt update` puis installation de `curl`.
2. `actions/checkout@v3`.
3. Si `update` : `WyriHaximus/github-action-helm3@v3` exécute `helm repo add <update_chart_name> <update_chart_url>`.
4. Si `update` : `WyriHaximus/github-action-helm3@v3` exécute `helm repo update`.
5. `WyriHaximus/github-action-helm3@v3` exécute `helm upgrade <extra_args> <extra_secret> <release_name> <chart_path> --install --wait --atomic --namespace=<namespace> --values=<values_file> --create-namespace`.

Les trois appels à `WyriHaximus/github-action-helm3@v3` reçoivent le kubeconfig via `secrets.KUBECONFIG`, avec l'option `overrule_existing_kubeconfig` à `"true"`.

## Dépendances

Aucune.

## Points d'attention

- Le secret est déclaré `kubeconfig` mais lu sous la forme `secrets.KUBECONFIG` ; cela fonctionne car les noms de propriétés des expressions GitHub ne sont pas sensibles à la casse.
- Le job déclare un `environment` : si cet environment GitHub définit lui-même un secret `KUBECONFIG`, c'est ce secret qui est utilisé à la place de celui passé par l'appelant (comportement documenté par GitHub pour les workflows réutilisables).
- La valeur par défaut de `environment` est un nom d'environment GitHub propre à un usage donné ; un appelant hors de cet usage doit passer sa propre valeur.
- `extra_secret` et `extra_args` sont insérés tels quels dans la ligne de commande `helm`, sans échappement.
- `actions/checkout@v3` est une version ancienne (runtime Node déprécié par GitHub) ; l'image `ubuntu:latest` n'est pas figée.
- `--atomic` annule la release en cas d'échec ; `--create-namespace` crée le namespace s'il n'existe pas.
