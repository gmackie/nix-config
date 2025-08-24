{
  # Export NixOS modules
  common = import ./common.nix;
  docker = import ./docker.nix;
  desktop = import ./desktop.nix;
  laptop = import ./laptop.nix;
}