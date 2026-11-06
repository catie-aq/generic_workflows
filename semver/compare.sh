#!/usr/bin/env bash
# Compare a version with the latest semver tag and write bump=true|false to
# $GITHUB_OUTPUT (stdout when unset).
#
# Usage: compare.sh <previous tag> <current version>
#
# - Versions are compared by semver precedence on MAJOR.MINOR.PATCH, numerically.
# - A leading "v" is accepted on both sides.
# - bump=true only when the version is exactly X.Y.Z (optional "v") and greater
#   than the previous tag. A pre-release (1.2.0-rc1), build metadata (1.2.0+b1)
#   or any other shape (1.2, 1.2.0rc1) gives bump=false with a notice: the tag
#   lookup ignores such tags, so tagging them would be retried on every run.
# - A previous tag that is not semver is unexpected and makes the script fail.
set -euo pipefail

previous="${1-}"
current="${2-}"
bump=false

release_re='^v?([0-9]+)\.([0-9]+)\.([0-9]+)$'
semver_re='^v?([0-9]+)\.([0-9]+)\.([0-9]+)(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'

echo "Previous tag: ${previous}"
echo "Current version: ${current}"

if [[ ! "$previous" =~ $semver_re ]]; then
  echo "::error::Previous tag '${previous}' is not a semver version"
  exit 1
fi
# 10# forces base 10 so that leading zeros are not read as octal.
prev_core=("$((10#${BASH_REMATCH[1]}))" "$((10#${BASH_REMATCH[2]}))" "$((10#${BASH_REMATCH[3]}))")
prev_is_prerelease="${BASH_REMATCH[4]:+yes}"

if [[ ! "$current" =~ $release_re ]]; then
  echo "::notice::Version '${current}' is not a plain X.Y.Z release: no tag"
else
  cur_core=("$((10#${BASH_REMATCH[1]}))" "$((10#${BASH_REMATCH[2]}))" "$((10#${BASH_REMATCH[3]}))")
  order=0
  for i in 0 1 2; do
    if ((cur_core[i] > prev_core[i])); then
      order=1
      break
    elif ((cur_core[i] < prev_core[i])); then
      order=-1
      break
    fi
  done
  # Same core: a release is greater than its pre-release (1.2.0 > 1.2.0-rc1).
  if ((order == 1)) || { ((order == 0)) && [ -n "$prev_is_prerelease" ]; }; then
    bump=true
  fi
fi

echo "Bump: ${bump}"
echo "bump=${bump}" >>"${GITHUB_OUTPUT:-/dev/stdout}"
