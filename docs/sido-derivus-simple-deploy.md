---
titre: Redémarrage d'une application Derivus (SIDO)
---

# Redémarrage d'une application Derivus (SIDO)

Workflow spécifique à l'équipe SIDO. Arrête une application Docker Compose déjà présente sur la machine du runner, remplace `IMAGE_TAG` dans son fichier `.env` par la version demandée, puis la relance.

Fichier : `.github/workflows/sido-derivus-simple-deploy.yml` · Déclencheur : `workflow_call` · Runner : `ml`

## Utilisation

```yaml
jobs:
  deploy:
    uses: catie-aq/generic_workflows/.github/workflows/sido-derivus-simple-deploy.yml@main
    with:
      app_path: /chemin/vers/application
      app_version: 1.2.3
```

## Entrées

| Nom | Type | Description | Requis | Défaut |
| ------------ | ------- | ---------------------------------------- | ----- | ------------ |
| `app_path` | string | Dossier, sur la machine du runner, qui contient le fichier Compose et le `.env` de l'application | oui | |
| `app_version` | string | Tag de l'image Docker à déployer (valeur écrite dans `IMAGE_TAG`) | oui | |

## Secrets

| Nom | Description | Requis |
| ------------ | ---------------------------------------- | ----- |

Aucune.

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |

Aucune.

## Fonctionnement

Job `build` (runner `ml`, sans conteneur), toutes les étapes dans `working-directory: <app_path>` :

1. `docker compose down`.
2. Réécrit `.env` : retire toute ligne contenant `IMAGE_TAG`, ajoute `IMAGE_TAG=<app_version>`.
3. `docker compose up -d`.

## Dépendances

Aucune.

## Points d'attention

- Pas de checkout : le workflow agit sur un dossier existant de la machine du runner, qui doit donc être persistant et disposer de Docker Compose.
- Le fichier `.env` doit exister dans `app_path`, sinon l'étape de réécriture échoue après l'arrêt de l'application.
- Toute ligne du `.env` qui contient la chaîne `IMAGE_TAG` est supprimée, pas seulement la variable `IMAGE_TAG`.
- Si le `.env` ne contient que des lignes `IMAGE_TAG`, `grep -v` ne sélectionne rien et renvoie le code 1 : l'étape échoue (shell `bash -e` par défaut) alors que l'application est déjà arrêtée.
- Le job s'appelle `build` alors qu'il déploie.
