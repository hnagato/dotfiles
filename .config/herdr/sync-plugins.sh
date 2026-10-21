#!/usr/bin/env bash
# Install declared herdr plugins and uninstall undeclared GitHub plugins.
set -euo pipefail
command -v herdr >/dev/null || exit 0
decl=~/.config/herdr/plugins.txt
wanted=$(grep -v -e '^#' -e '^$' "$decl" || true)
installed=$(herdr plugin list --json | jq -r '.result.plugins[]
  | select(.source.kind == "github")
  | "\(.source.owner)/\(.source.repo)\t\(.plugin_id)"')

while read -r spec; do
  [ -n "$spec" ] || continue
  repo=${spec%@*}
  cut -f1 <<<"$installed" | grep -qxF "$repo" && continue
  if [[ $spec == *@* ]]; then
    herdr plugin install "$repo" --ref "${spec#*@}" -y
  else
    herdr plugin install "$repo" -y
  fi
done <<<"$wanted"

while IFS=$'\t' read -r repo id; do
  [ -n "$repo" ] || continue
  sed 's/@.*//' <<<"$wanted" | grep -qxF "$repo" || herdr plugin uninstall "$id"
done <<<"$installed"
