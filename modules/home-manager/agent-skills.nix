{ inputs, pkgs, lib, ... }:
let
  privateFlake =
    if builtins.hasAttr "agent-skills-private" inputs then
      inputs.agent-skills-private
    else
      null;

  combinedModule =
    import (inputs.agent-skills.outPath + "/nix/examples/combined-home-manager.nix") {
      publicFlake = inputs.agent-skills;
      privateFlake = privateFlake;
    };
in
{
  imports = [
    combinedModule
  ];

  # These are already present elsewhere in nix-config today, but they are core
  # assumptions for the public agent-skills repo and make the dependency
  # boundary explicit at the Home Manager layer.
  home.packages = with pkgs; [
    nodejs
    jq
  ];
}
