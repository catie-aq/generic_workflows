# Publier un nouveau tag et une pre-release lorsque la version est augmentée

Ce workflow GitHub Actions est conçu pour être déclenché sur pull request. Il a trois entrées et deux sorties.

## Entrées

| nom           | description                          | requis | par défaut |
| ------------- | ------------------------------------ | ------ | ---------- |
| `image`       | Le nom de l'image à construire       | `true` |            |
| `extra_cmd`   | Commande supplémentaire à exécuter avant le tag. Par exemple, pour installer des dépendances. | `false` | |
| `version_cmd` | Commande pour obtenir la version actuelle d'un package | `true` | |

## Sorties

| nom           | description                          |
| ------------- | ------------------------------------ |
| `bump`        | Indique si la version a été augmentée ou non |
| `version`     | La nouvelle version |

## Jobs

Le workflow contient un seul job, `bump-tag`.

### bump-tag

Ce job est exécuté si l'acteur GitHub n'est pas `dependabot[bot]`. Il s'exécute sur le groupe par défaut dans un conteneur spécifié par `inputs.image`.

Les étapes pour ce job sont :

- Extraire le code en utilisant l'action `actions/checkout@v4`.
- Installer les dépendances si `inputs.extra_cmd` est fourni.
- Obtenir la version actuelle du package en utilisant `inputs.version_cmd`.
- Vérifier la version en utilisant l'action `semver` du dépôt `catie-aq/generic_workflows`.
- Si la sortie `bump` de l'étape `semver` est `true`, augmenter la version et pousser la balise en utilisant l'action `mathieudutour/github-tag-action@v6.1`.

Les sorties du job sont `bump` et `version`, qui sont respectivement les sorties des étapes `semver` et `get_version`.
