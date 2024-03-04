# Semver

## Description

Compare last semver of GitHub tag with input version. Return a boolean to indicate if the version should be bumped.

## Inputs

| name      | description     | required | default |
| --------- | --------------- | -------- | ------- |
| `version` | Current version | `true`   | `""`    |

## Outputs

| name   | description                                         |
| ------ | --------------------------------------------------- |
| `bump` | Boolean to indicate if the version should be bumped |

## Runs

This action is a `composite` action.
