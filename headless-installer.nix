{ config, pkgs, lib, ... }:

{
  # Enable SSH daemon for headless installation
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  # Set a temporary root password for initial access
  users.users.root.initialPassword = "nixos";

  # Enable networking
  networking = {
    useDHCP = lib.mkForce true;
    firewall.allowedTCPPorts = [ 22 ];
  };

  # Add some useful tools for installation
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    parted
    gptfdisk
  ];

  # Keep the default nixos auto-login user
  services.getty.autologinUser = lib.mkForce "nixos";

  # Enable flakes for modern NixOS
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}