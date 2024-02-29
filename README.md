# Generic Workflows

Ce dépôt contient une collection de workflows réutilisables, spécifiquement conçus pour la construction et les tests de paquets ROS, utilisables dans
le cadre d'Actions Github.

## Workflows Disponibles

### Auto Update Pre Commit

Ce workflow permet de mettre à jour automatiquement la version des hooks pre-commit dans le fichier `.pre-commit-config.yaml` de votre dépôt.

Paramètres :

- `path` : le chemin du dossier où se trouve le fichier `.pre-commit-config.yaml` (par défaut : `.`)

## Utilisation

Vous pouvez utiliser ce workflow dans votre dépôt en ajoutant le bloc de code suivant à votre fichier `.github/workflows/<name>.yml` :

```yaml
name: "CI/CD"
on:
  push:

jobs:
  ros:
    uses: catie-aq/generic_workflows/.github/workflows/<workflow>.yaml@main
```

Remarque : Vous pouvez également utiliser un tag spécifique pour le workflow, par exemple `<workflow>.yaml@v1.0.0`.
Voir les [releases displonibles](https://github.com/catie-aq/generic_workflows/releases).

## Licence

Ce projet est sous licence Apache 2.0, une licence open source permissive qui vous permet d'utiliser, de modifier, de distribuer et de vendre
librement vos propres produits qui incluent ce logiciel. Le texte intégral de la licence peut être obtenu sur
le [site web d'Apache](https://www.apache.org/licenses/LICENSE-2.0).
