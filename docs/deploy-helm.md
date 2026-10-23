---
titre: Déploiement Helm
---

# Déploiement Helm

Installe ou met à jour une release Helm (`helm upgrade --install --wait`) à partir d'un chart du dépôt appelant, avec un kubeconfig fourni en secret. Peut au préalable ajouter et mettre à jour un dépôt de charts Helm. En cas d'échec, relève l'état des pods de la release dans les logs du job puis revient à la dernière révision réussie.

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

1. `apt update` puis installation de `curl` et `jq`.
2. `actions/checkout@v3`.
3. Si `update` : `WyriHaximus/github-action-helm3@v3` exécute `helm repo add <update_chart_name> <update_chart_url>`.
4. Si `update` : `WyriHaximus/github-action-helm3@v3` exécute `helm repo update`.
5. Étape `Deploy` : `WyriHaximus/github-action-helm3@v3` relève la dernière révision de la release (`helm history`, `0` si la release est absente ; toute autre erreur de lecture arrête l'étape avant l'upgrade), puis exécute `helm upgrade <extra_args> <extra_secret> <release_name> <chart_path> --install --wait --namespace=<namespace> --values=<values_file> --create-namespace`.
6. Étape `Diagnostic`, seulement si `Deploy` échoue après avoir relevé la révision (`continue-on-error`, son propre échec ne masque pas celui du déploiement) : installe `kubectl` `v1.29.15` (somme SHA-256 vérifiée). Si l'upgrade n'a créé aucune révision (erreur de rendu du chart, `--dry-run`, release verrouillée), elle s'arrête là. Sinon elle affiche, pour la release :
   - les cinq dernières révisions et leur statut ;
   - les Deployment, StatefulSet, DaemonSet et Job de la release (annotation `meta.helm.sh/release-name` ou label `app.kubernetes.io/instance`) et leur nombre de réplicas prêts ;
   - les pods non prêts : phase, nœud, état de chaque conteneur et conteneur d'init (raison d'attente, code de sortie, redémarrages, arrêt précédent) et conditions en échec ;
   - les 40 derniers événements du namespace qui portent sur ces pods non prêts, leurs ReplicaSet ou Job, leurs PVC et les charges de travail de la release ;
   - les 50 dernières lignes de logs de chaque conteneur des pods non prêts (et de l'exécution précédente si le conteneur a redémarré et tourne de nouveau), une section repliable par conteneur, 20 conteneurs au plus. Ces logs ne sont affichés que si le dépôt appelant est privé.

   Un résumé (pods non prêts, dix derniers événements `Warning`) est ajouté au résumé du job.
7. Étape `Rollback`, mêmes conditions que `Diagnostic` : `WyriHaximus/github-action-helm3@v3` lit `helm history` et reproduit le retour arrière de `--atomic` :
   - dernière révision `pending-*` (une autre opération Helm en cours) : avertissement, aucune action ;
   - aucune révision créée par l'upgrade (erreur de rendu du chart, `--dry-run`) ou release absente : aucune action, même si la release était déjà en `failed` ;
   - révision créée par l'upgrade et en `failed` : `helm rollback` vers la dernière révision `deployed` ou `superseded`, ou `helm uninstall` s'il n'y en a aucune (premier déploiement en échec) ;
   - toute autre erreur de `helm history` (droits, cluster injoignable) : l'étape échoue.

   Le retour arrière attend la fin (`--wait`) avec le `--timeout` trouvé dans `extra_args` (le dernier s'il y en a plusieurs), `5m0s` par défaut comme Helm.

Les appels à `WyriHaximus/github-action-helm3@v3` reçoivent le kubeconfig via `secrets.KUBECONFIG`, avec l'option `overrule_existing_kubeconfig` à `"true"` ; l'étape `Diagnostic` l'écrit dans un fichier temporaire supprimé en fin d'étape.

## Dépendances

Aucune.

## Points d'attention

- Le secret est déclaré `kubeconfig` mais lu sous la forme `secrets.KUBECONFIG` ; cela fonctionne car les noms de propriétés des expressions GitHub ne sont pas sensibles à la casse.
- Le job déclare un `environment` : si cet environment GitHub définit lui-même un secret `KUBECONFIG`, c'est ce secret qui est utilisé à la place de celui passé par l'appelant (comportement documenté par GitHub pour les workflows réutilisables).
- La valeur par défaut de `environment` est un nom d'environment GitHub propre à un usage donné ; un appelant hors de cet usage doit passer sa propre valeur.
- `extra_secret` et `extra_args` sont insérés tels quels dans la ligne de commande `helm`, sans échappement.
- `actions/checkout@v3` est une version ancienne (runtime Node déprécié par GitHub) ; l'image `ubuntu:latest` n'est pas figée.
- `--create-namespace` crée le namespace s'il n'existe pas.
- Le retour arrière est fait par l'étape `Rollback` et non par `--atomic`, qui effacerait les pods en échec avant le diagnostic. Si le job est annulé pendant `Deploy`, `Rollback` ne s'exécute pas : la release reste dans l'état où Helm l'a laissée (`failed`, ou `pending-upgrade` si Helm a été tué), et un statut `pending-*` bloque les déploiements suivants tant qu'il n'est pas débloqué à la main (`helm rollback`).
- Seul le `--timeout` de `extra_args` est repris par le retour arrière. `--atomic` reprenait aussi `--no-hooks`, `--force`, `--wait-for-jobs`, `--cleanup-on-fail` et `--kube-context` ; un appelant qui les passe à `upgrade` ne les retrouve pas dans `helm rollback` ou `helm uninstall`.
- Helm ne pose pas l'annotation `meta.helm.sh/release-name` sur les hooks : le diagnostic ne trouve un Job de hook (et ses pods) que si le chart lui met le label `app.kubernetes.io/instance`.
- Dépôt appelant public : les logs Actions y sont publics, les logs des conteneurs ne sont donc pas affichés ; le reste du diagnostic (noms, états, événements) l'est. Les messages d'événements peuvent citer des noms de Secret ou de ConfigMap manquants, jamais leur contenu.
- `WyriHaximus/github-action-helm3@v3` télécharge Helm (dernière version 3) à chaque étape sans vérifier que le téléchargement a abouti : un échec donne `helm: No such file or directory` à l'étape concernée. Constaté le 16/10/2026 sur un déploiement du banc d'essai ; relancer le job suffit.
