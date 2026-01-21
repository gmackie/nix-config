{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/darwin/common.nix
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/development.nix
    ../../modules/shared/common-packages.nix
  ];

  # Host-specific overrides

  # Additional casks specific to this machine
  homebrew.casks = lib.mkAfter [
    # Add any labtop-specific casks here
  ];

  # Additional brews specific to this machine
  homebrew.brews = lib.mkAfter [
    # Add any labtop-specific brews here
  ];
}
