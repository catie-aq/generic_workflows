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
| `version` | string | Version courante à comparer, au format `X.Y.Z` (préfixe `v` accepté) | oui | |

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |
| `bump` | `true` si `version` est une version `X.Y.Z` plus récente que le dernier tag semver, `false` sinon |

## Fonctionnement

Étapes de l'action (`using: composite`) :

1. Étape `previoustag` : `actions-ecosystem/action-get-latest-tag@v1` avec `semver_only: true` et `initial_version: '0.0.0'` (valeur utilisée s'il n'existe aucun tag). Le « dernier » tag est le plus récemment créé (tri par date), pas le plus grand.
2. Étape `compare` (`shell: bash`) : exécute `semver/compare.sh` avec le dernier tag et `version`, passés par variables d'environnement. Le script publie `bump` dans `$GITHUB_OUTPUT`.

Règles de comparaison de `compare.sh` :

| Cas | Exemple (tag, version) | `bump` |
| ------------------------------ | -------------------- | ------------ |
| Version supérieure | `1.10.0`, `2.0.0` | `true` |
| Version égale ou inférieure | `1.2.3`, `1.2.3` | `false` |
| Aucun tag | `0.0.0`, `0.1.0` | `true` |
| Préfixe `v` d'un côté ou des deux | `v1.2.3`, `1.2.4` | `true` |
| Pré-version ou métadonnées de build | `1.2.3`, `1.3.0-rc1` | `false` |
| Version hors forme `X.Y.Z` | `1.2.3`, `1.3` ou `1.3.0rc1` | `false` |
| Dernier tag vide ou non semver | (vide), `1.0.0` | échec de l'étape |

- Les trois composants `MAJEUR.MINEUR.CORRECTIF` sont comparés un à un, comme des nombres (`1.10.0` est supérieur à `1.9.0`, un zéro initial ne change rien).
- Seule une version `X.Y.Z` (avec ou sans `v`) peut donner `bump: true`. Une pré-version (`-rc1`), des métadonnées de build (`+b1`) ou une autre forme, comme les pré-versions PEP 440 (`1.3.0rc1`), donnent `false` avec un message `notice` dans le journal. Raison : l'étape `previoustag` ignore ces tags (constaté le 06/11/2026), si bien qu'un tag `1.3.0-rc1` déjà posé ne serait jamais vu comme le dernier et que chaque run suivant tenterait de le recréer.
- Un dernier tag vide ou non semver fait échouer l'étape (`::error::Previous tag ... is not a semver version`). Avec `previoustag` tel qu'il est configuré (`semver_only: true`, valeur initiale `0.0.0`), ce cas ne se produit pas ; il signalerait un changement de comportement de `action-get-latest-tag`, par exemple la disparition de sa sortie `tag`. Que faire : vérifier la sortie de l'étape `previoustag` dans le journal du run, puis épingler ou remplacer l'action.
- Si le dernier tag est une pré-version (cas qui ne se produit pas avec l'étape `previoustag` actuelle), la version publiée de même numéro est supérieure (`1.2.0` après `1.2.0-rc1`).

## Dépendances

Aucune.

## Points d'attention

- L'étape `compare` exige `bash` dans l'environnement d'exécution (image du conteneur le cas échéant).
- La référence de comparaison est le tag le plus récemment créé, pas le plus grand : un tag plus ancien posé après coup (correctif `1.0.5` après `1.2.0`) devient la référence, la version `1.2.0` est alors vue comme une montée et la création du tag `1.2.0`, déjà existant, échoue à chaque run.
- La règle « pas de tag pour une pré-version » dépend de la regex de `action-get-latest-tag@v1`, qui ignore les tags à suffixe. Si l'action est remplacée par une lecture qui voit ces tags, la règle peut être revue.
- `actions-ecosystem/action-get-latest-tag@v1` publie sa sortie avec `::set-output`, déprécié par GitHub.
- Le dossier ne contient que `action.yml`, `compare.sh` et ce `README.md` : aucun `pyproject.toml` ni `poetry.lock` (ni dans l'historique git du dossier).
