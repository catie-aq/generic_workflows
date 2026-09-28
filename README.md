---
titre: generic_workflows
---

# generic_workflows

Ce dépôt contient des workflows GitHub Actions réutilisables qui ne sont liés ni à une technologie ni à un projet particulier : images Docker, déploiement Helm ou Docker Compose, tags de version, pre-commit, PDF. Vue d'ensemble de tous les workflows `catie-aq` : dépôt `catie-aq/sonu_workflow` (REF-001).

## Workflows réutilisables

| Workflow | Rôle | Doc |
| -------------------- | ---------------------------------------- | ---- |
| `autotag.yml` | Crée un tag quand la version du paquet dépasse le dernier tag | [Tag automatique de version](docs/autotag.md) |
| `autoupdate-pre-commit.yml` | Met à jour les hooks pre-commit par pull request | [Mise à jour automatique des hooks pre-commit](docs/autoupdate-pre-commit.md) |
| `cookiecutter.yml` | Vérifie qu'un template Cookiecutter se génère sans erreur | [Test d'un template Cookiecutter](docs/cookiecutter.md) |
| `deploy-compose.yml` | Déploie une application Docker Compose sur un démon Docker distant | [Déploiement Docker Compose](docs/deploy-compose.md) |
| `deploy-helm.yml` | Installe ou met à jour une release Helm | [Déploiement Helm](docs/deploy-helm.md) |
| `docker-ghcr.yml` | Construit et publie une image Docker sur GHCR | [Publication d'image Docker sur GHCR](docs/docker-ghcr.md) |
| `docker-nexus.yml` | Obsolète, échoue volontairement : remplacé par `docker-ghcr.yml` | [Publication d'image Docker sur Nexus (obsolète)](docs/docker-nexus.md) |
| `docker-test.yaml` | Analyse un Dockerfile avec hadolint | [Lint de Dockerfile](docs/docker-test.md) |
| `pandoc-pdf.yml` | Compile des documents en PDF avec Pandoc et les publie | [Génération de PDF avec Pandoc](docs/pandoc-pdf.md) |
| `pre-commit.yaml` | Exécute pre-commit sur tous les fichiers | [Exécution de pre-commit](docs/pre-commit.md) |
| `sido-derivus-simple-deploy.yml` | Spécifique SIDO : redémarre une application Compose avec un nouveau tag | [Redémarrage d'une application Derivus (SIDO)](docs/sido-derivus-simple-deploy.md) |
| `sido-docker-nexus.yml` | Spécifique SIDO : construit et publie une image Docker sur Nexus | [Publication d'image Docker sur Nexus (SIDO)](docs/sido-docker-nexus.md) |

## Actions composites

| Action | Rôle | Doc |
| -------------------- | ---------------------------------------- | ---- |
| `semver` | Compare une version au dernier tag semver du dépôt | [semver](semver/README.md) |

## Workflows internes

| Workflow | Déclencheur | Rôle |
| -------------------- | -------------------- | ---------------------------------------- |
| `stress_test.yml` | `workflow_dispatch` | Test de charge des runners `sonu-github-arc` : 40 jobs en parallèle (conteneur `ubuntu:22.04`), chacun lance `stress --cpu 4` pendant 180 s |

## Workflows retirés

Ces workflows ont été supprimés du dépôt ; un appelant qui les référence encore échoue.

| Workflow | Supprimé au commit | Remplaçant | Encore appelé par |
| -------------------- | ------------ | -------------------- | ---------------------------------------- |
| `cruft.yaml` | `f51324c` | Aucun | `python_package-ci/.github/workflows/autoupdate.yml` |
| `github-project.yml` | `f51324c` | Aucun | Aucun appelant connu |
| `notion.yml` | `699ce03` | Aucun | `mbed_workflows/.github/workflows/notion.yml` |

Leur documentation (`docs/cruft.md`, `docs/github-project.md` au commit `f51324c`, `docs/notion.md` au commit `b5fc258`) a été supprimée avec eux.

## Licence

Ce dépôt est distribué sous licence Apache 2.0 : voir le fichier `LICENSE`.
