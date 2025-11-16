{
  config,
  pkgs,
  lib,
  inputs,
  user,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared/common-packages.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/development.nix
    ../../modules/nixos/languages/python.nix
    ../../modules/nixos/languages/nodejs.nix
    ../../modules/nixos/languages/go.nix
    ../../modules/nixos/languages/rust.nix
  ];

  # Host identification
  networking.hostName = "homelab";

  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Enable networking
  networking = {
    networkmanager = {
      enable = true;
      dns = "default";
    };

    firewall = {
      enable = true;
      # SSH for remote management
      allowedTCPPorts = [ 22 ];
      # mDNS for .local hostname resolution
      allowedUDPPorts = [ 5353 ];
      # Add additional ports as needed for homelab services
    };
  };

  # SSH configuration for remote access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      ClientAliveInterval = 30;
      ClientAliveCountMax = 5;
    };
  };

  # System monitoring and maintenance services
  services = {
    # Monitor system health
    netdata = {
      enable = true;
      config = {
        global = {
          "default port" = "19999";
        };
      };
    };
  };

  # Power management for 24/7 operation
  powerManagement = {
    enable = true;
    # Performance governor for server workload
    cpuFreqGovernor = lib.mkDefault "performance";
  };

  # Homelab-specific packages
  environment.systemPackages = with pkgs; [
    # Claude Code for terminal-based coding
    claude-code

    # System monitoring
    lm_sensors
    smartmontools
    sysstat
    iftop
    nethogs

    # Network tools
    speedtest-cli
    dig
    traceroute

    # Server utilities
    screen
    tmux

    # Storage management
    ncdu
    duf

    # Log management
    lnav

    # Optional: Tools for running services
    # caddy  # Reverse proxy
    # postgresql  # Database
  ];

  # User configuration
  users.users.${user} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBW0z6b1kJpQPh2v9q9EXfvX+eBmhgCCLjo4Dwy7Ep5I"
    ];
    # Add to docker group for container management
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
  };

  # Tailscale for easy remote access
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  # Automatic garbage collection to save space
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Optimize for SSD if using one
  services.fstrim.enable = true;

  # System state version
  system.stateVersion = "24.05";
}
