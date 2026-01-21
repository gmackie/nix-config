{ config, pkgs, lib, ... }:

{
  # Encryption tools
  environment.systemPackages = with pkgs; [
    age
    age-plugin-yubikey
    sops
    ssh-to-age
  ];

  # SOPS configuration
  # The sops-nix module is imported via lib/mksystem.nix
  sops = {
    # Default age key location
    age.keyFile = "/var/lib/sops-nix/key.txt";

    # Don't generate key automatically - we manage keys manually
    age.generateKey = false;

    # Default secrets file (can be overridden per-secret)
    defaultSopsFile = ../../secrets/secrets.yaml;

    # Default format
    defaultSopsFormat = "yaml";
  };

  # Ensure the sops key directory exists with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/sops-nix 0700 root root -"
  ];
}
