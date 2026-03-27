#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

flake_file="$root/flake.nix"
module_file="$root/modules/home-manager/agent-skills.nix"
common_home_file="$root/home/mackieg/common.nix"

test -f "$flake_file"
test -f "$module_file"
test -f "$common_home_file"

grep -q 'agent-skills' "$flake_file"
grep -q 'modules/home-manager/agent-skills.nix' "$common_home_file"

flake_ref="path:$root"

nix eval --impure --extra-experimental-features "nix-command flakes" --expr "
  let flake = builtins.getFlake \"$flake_ref\";
  in builtins.isFunction flake.homeManagerModules.agent-skills
" >/dev/null
