{ config, pkgs, lib, ... }:

{
  # Age - modern encryption tool
  environment.systemPackages = with pkgs; [
    age
    age-plugin-yubikey
    sops
    ssh-to-age
  ];
  
  # Create directory for secrets
  systemd.tmpfiles.rules = [
    "d /run/secrets 0755 root root -"
  ];
  
  # SOPS configuration
  # To use:
  # 1. Create .sops.yaml in repo root
  # 2. Add your age public key
  # 3. Encrypt secrets with: sops secrets/example.yaml
  # 4. Import in configuration with sops-nix module
  
  # Example .sops.yaml:
  # creation_rules:
  #   - path_regex: secrets/.*\.yaml$
  #     age: age1your_public_key_here
}