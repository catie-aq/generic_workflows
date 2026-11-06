---
titre: Tag automatique de version
---

# Tag automatique de version

Lit la version courante d'un paquet, la compare au dernier tag semver du dépôt et, si elle est plus récente, crée et pousse un tag portant cette version. À appeler après une montée de version, par exemple sur `push` vers `main`.

Fichier : `.github/workflows/autotag.yml` · Déclencheur : `workflow_call` · Runner : `group: default`

## Utilisation

```yaml
jobs:
  tag:
    uses: catie-aq/generic_workflows/.github/workflows/autotag.yml@main
    with:
      image: python:3.12
      version_cmd: python -c "import tomllib; print(tomllib.load(open('pyproject.toml', 'rb'))['project']['version'])"
```

## Entrées

| Nom | Type | Description | Requis | Défaut |
| ------------ | ------- | ---------------------------------------- | ----- | ------------ |
| `image` | string | Image du conteneur dans lequel s'exécute le job | oui | |
| `extra_cmd` | string | Commande supplémentaire exécutée avant la lecture de la version (installation de dépendances, par exemple) | non | |
| `version_cmd` | string | Commande qui affiche la version courante du paquet sur la sortie standard | oui | |

## Secrets

| Nom | Description | Requis |
| ------------ | ---------------------------------------- | ----- |

Aucune.

## Sorties

| Nom | Description |
| ------------ | ---------------------------------------- |
| `bump` | `true` si la version est plus récente que le dernier tag (tag créé), `false` sinon |
| `version` | Version renvoyée par `version_cmd` |

## Fonctionnement

Job `bump-tag` (runner `group: default`, conteneur `${{ inputs.image }}`), ignoré si `github.actor` vaut `dependabot[bot]` :

1. `actions/checkout@v4`.
2. Si `extra_cmd` est renseigné : exécution de `extra_cmd`.
3. Étape `get_version` : exécute `version_cmd`, retire tous les blancs de sa sortie (espaces, tabulations, `\r`, sauts de ligne : `tr -d '[:space:]'`) et publie le résultat en sortie `version` dans `$GITHUB_OUTPUT`. La même valeur sert à la comparaison, au tag et à la sortie du workflow.
4. Étape `semver` : action composite `catie-aq/generic_workflows/semver@main` avec `version`, qui renvoie `bump` (règles de comparaison dans [semver](../semver/README.md) : seule une version `X.Y.Z` supérieure au dernier tag est taguée).
5. Si `bump` vaut `true` : `mathieudutour/github-tag-action@v6.2` avec `github_token: ${{ secrets.GITHUB_TOKEN }}`, `custom_tag` = la version et `tag_prefix: ""` (tag sans préfixe `v`).

Les sorties `bump` et `version` du workflow reprennent celles du job.

## Dépendances

- `catie-aq/generic_workflows/semver@main` (action composite de ce dépôt, voir [semver](../semver/README.md)). Référence `@main` en dur : une branche de test de `autotag.yml` utilise toujours `semver` de `main`.

## Points d'attention

- Le nom du workflow parle de « pre-release », mais seul un tag est créé : aucune release GitHub n'est publiée.
- Le workflow ne déclare pas de `permissions` : le `GITHUB_TOKEN` de l'appelant doit avoir `contents: write` pour pousser le tag.
- Un tag poussé avec le `GITHUB_TOKEN` ne déclenche pas d'autre workflow (règle GitHub) : un workflow `on: push: tags` du dépôt ne partira pas.
- Pour `dependabot[bot]`, le job est ignoré et les sorties sont vides.
- L'image `image` doit contenir `bash` (étape `shell: bash` de l'action `semver`).
- Une sortie de `version_cmd` sur plusieurs lignes est collée en une seule (`1.2.31.2.4`) : ce n'est plus une version `X.Y.Z`, `semver` renvoie `false` et aucun tag n'est posé.
- Une pré-version (`1.3.0-rc1`) ou une version PEP 440 hors forme `X.Y.Z` (`1.3.0rc1`) n'est jamais taguée : voir [semver](../semver/README.md).
- `actions/checkout@v4` est appelé sans `fetch-depth: 0`. Constaté le 06/11/2026 : `actions-ecosystem/action-get-latest-tag@v1` lance lui-même `git fetch --tags` puis `git fetch --unshallow`, le dernier tag est donc trouvé.
