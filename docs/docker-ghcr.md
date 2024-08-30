# Publier sur GHCR

Ce workflow GitHub Actions est conçu pour publier une image Docker sur GitHub Container Registry (GHCR).

## Entrées

- `Dockerfile` : (Facultatif) Chemin vers le Dockerfile.
  - Type : `string`
  - Par défaut : `"."`
- `target` : (Facultatif) Cible pour le Dockerfile.
  - Type : `string`

## Secrets

- `build_args` : (Facultatif) Arguments de construction pour le Dockerfile.
  - Description : "Build Args for Dockerfile"
- `PAT` : (Facultatif) Jeton d'accès personnel pour les sous-modules privés.
  - Description : "Personal Access Token for private submodules"

## Jobs

### `publish`

Ce job s'exécute sur un runner personnalisé nommé `sonu-github-arc`.

#### Permissions

- `contents` : `read`
- `packages` : `write`

#### Étapes

1. **Mettre à jour git** : Met à jour et installe git.

2. **Vérifier le dépôt (avec PAT)** : Vérifie le dépôt avec les sous-modules si `PAT` est fourni.

3. **Vérifier le dépôt (sans PAT)** : Vérifie le dépôt sans les sous-modules si `PAT` n'est pas fourni.

4. **Connexion à GHCR** : Se connecte à GitHub Container Registry.

5. **Définir le suffixe formaté** : Définit le suffixe formaté pour la cible.

6. **Extraire les métadonnées pour Docker** : Extrait les métadonnées pour l'image Docker.

7. **Construire et pousser l'image Docker** : Construit et pousse l'image Docker avec les tags et labels extraits.

## Règles de nommage des images

Les images Docker sont nommées en fonction de l'événement déclencheur et de la référence Git. Voici les règles de nommage, basées sur l'action [docker/metadata-action](https://github.com/docker/metadata-action) :

| Événement            | Référence Git             | Tags Docker                  |
|----------------------|---------------------------|------------------------------|
| `pull_request`       | `refs/pull/2/merge`       | `pr-2`                       |
| `push`               | `refs/heads/master`       | `master`                     |
| `push`               | `refs/heads/releases/v1`  | `releases-v1`                |
| `push tag`           | `refs/tags/v1.2.3`        | `v1.2.3`, `latest`           |
| `push tag`           | `refs/tags/v2.0.8-beta.67`| `v2.0.8-beta.67`, `latest`   |
| `workflow_dispatch`  | `refs/heads/master`       | `master`                     |

Si une `target` est donnée, le nom sera suffixé par `-target`.
