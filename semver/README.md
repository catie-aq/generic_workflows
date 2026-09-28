---
titre: Action semver
---

# Action semver

Compare une version fournie au dernier tag semver du dépôt et renvoie `bump: true` si elle est plus récente. Utilisée par le workflow [autotag](../docs/autotag.md) pour décider de la création d'un tag.

Fichier : `semver/action.yml` · Type : action composite

## Utilisation

```yaml
steps:
  - uses: actions/checkout@v4
  - id: semver
    uses: catie-aq/generic_workflows/semver@main
    with:
      version: 1.2.3
  - if: ${{ steps.semver.outputs.bump == 'true' }}
    run: echo "Nouvelle version"
```

## Entrées

| Nom | Type | Description | Requis | Défaut |
| ------------ | ------- | ---------------------------------------- | ----- | ------------ |
| `version` | string | Version courante à comparer, au format `X.Y.Z` | oui | |

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |
| `bump` | `true` si `version` est plus récente que le dernier tag semver, `false` sinon |

## Fonctionnement

Étapes de l'action (`using: composite`) :

1. Étape `previoustag` : `actions-ecosystem/action-get-latest-tag@v1` avec `semver_only: true` et `initial_version: '0.0.0'` (valeur utilisée s'il n'existe aucun tag).
2. Étape `compare` (`shell: bash`) : retire les points du dernier tag et de `version` (`1.2.3` devient `123`), compare les deux nombres avec `-lt` et publie `bump=true` si le tag est inférieur, `bump=false` sinon, via `::set-output`.

## Dépendances

Aucune.

## Points d'attention

- La comparaison supprime les points puis compare des entiers : elle est fausse dès qu'un composant a deux chiffres (`2.0.0` donne `200`, inférieur à `1100` pour `1.10.0`, donc pas de bump) ou que les versions n'ont pas le même nombre de composants.
- Une version avec suffixe (`1.0.0-rc1`) n'est pas un entier : le test `-lt` échoue et `bump` vaut `false`.
- `::set-output` est déprécié par GitHub ; à remplacer par `$GITHUB_OUTPUT`.
- L'étape `compare` exige `bash` dans l'environnement d'exécution (image du conteneur le cas échéant).
- Le dossier ne contient que `action.yml` et ce `README.md` : aucun `pyproject.toml` ni `poetry.lock` (ni dans l'historique git du dossier).
