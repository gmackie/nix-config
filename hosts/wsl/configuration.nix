{ config, pkgs, lib, inputs, user, wsl, ... }:

{
  imports = [
    ../../modules/shared/common-packages.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/docker.nix
  ];
  
  wsl = {
    enable = true;
    defaultUser = user;
    startMenuLaunchers = true;
    nativeSystemd = true;
    
    wslConf = {
      automount.root = "/mnt";
      network.generateHosts = false;
    };
  };
  
  # WSL-specific overrides
  boot.isContainer = lib.mkForce true;
  
  environment.etc.hosts.enable = false;
  environment.etc."resolv.conf".enable = false;
  
  networking.dhcpcd.enable = false;
  
  # Disable systemd units that don't make sense on WSL
  systemd.services = {
    "serial-getty@ttyS0".enable = false;
    "serial-getty@hvc0".enable = false;
    "getty@tty1".enable = false;
    "autovt@".enable = false;
    firewall.enable = false;
    systemd-resolved.enable = false;
    systemd-udevd.enable = false;
  };
  
  # Don't allow emergency mode, because we don't have a console
  systemd.enableEmergencyMode = false;
  
  # WSL-specific packages
  environment.systemPackages = with pkgs; [
    wslu # WSL utilities
  ];
}