# Ajoute tous les problèmes et les demandes de tirage à un projet

Ce workflow GitHub Actions est conçu pour ajouter automatiquement tous les problèmes (issues) et les demandes de tirage (pull requests) à un projet GitHub spécifié.

## Déclencheur

Le workflow est conçu pour être déclenché sur les évenements suivants :

```yaml
  issues:
    types:
      - opened
  pull_request:
    types:
      - opened
```

## Entrées

- `project_number` : **(Obligatoire)** Le numéro du projet auquel les problèmes et les demandes de tirage doivent être ajoutés. Ce numéro peut être obtenu à partir de l'URL du projet.
- `labeled` : (Facultatif) Un label utilisé pour filtrer les problèmes et les demandes de tirage. Si spécifié, seuls les éléments avec ce label seront ajoutés au projet.
  - Par défaut : `""` (chaîne vide)
- `label-operator` : (Facultatif) L'opérateur utilisé en conjonction avec l'entrée `labeled` pour filtrer les problèmes et les demandes de tirage.
  - Par défaut : `""` (chaîne vide)

## Secrets

- `personal_access_token` : **(Obligatoire)** Un jeton d'accès personnel (PAT) utilisé pour s'authentifier auprès de l'API GitHub. Ce jeton doit avoir les scopes appropriés pour ajouter des problèmes et des demandes de tirage au projet.

## Jobs

### `add-to-project`

Ce job s'exécute sur un runner personnalisé nommé `sonu-github-arc`.

#### Étapes

1. **Ajouter au Projet** : Utilise l'action `actions/add-to-project@v1.0.2` pour ajouter des problèmes et des demandes de tirage au projet spécifié.
   - `project-url` : Construit en utilisant l'entrée `project_number` pour spécifier le projet cible.
   - `github-token` : Utilise le secret `personal_access_token` pour l'authentification.
   - `labeled` : Utilise l'entrée `labeled` pour filtrer quels problèmes et demandes de tirage sont ajoutés en fonction des labels.
   - `label-operator` : Utilise l'entrée `label-operator` pour déterminer comment les labels sont utilisés pour filtrer les problèmes et les demandes de tirage.
