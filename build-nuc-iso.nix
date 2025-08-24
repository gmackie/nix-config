{ config, pkgs, lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    ./nuc-headless-installer.nix
  ];

  # Ensure we can build the ISO
  nixpkgs.hostPlatform = "x86_64-linux";
}