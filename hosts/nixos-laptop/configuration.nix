{ config, pkgs, lib, inputs, user, desktop, laptop, ... }:

{
  imports = [
    ./hardware-configuration.nix # You'll need to generate this with nixos-generate-config
    ../../modules/nixos/common.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/laptop.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/development.nix
    ../../modules/nixos/languages/python.nix
    ../../modules/nixos/languages/nodejs.nix
    ../../modules/nixos/languages/go.nix
    ../../modules/nixos/languages/rust.nix
  ];
  
  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  
  # Enable networking
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };
  
  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  # Enable touchpad support
  services.xserver.libinput.enable = true;
  
  # Laptop-specific power management
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
  
  # Enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  
  # System packages for laptop
  environment.systemPackages = with pkgs; [
    brightnessctl
    powertop
    acpi
  ];
}