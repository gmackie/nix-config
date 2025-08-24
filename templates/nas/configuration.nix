# NAS Server NixOS Configuration Template
{ config, pkgs, lib, inputs, user, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/secrets.nix
  ];
  
  # Enable SSH for remote management
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
    ports = [ 22 ];
  };
  
  # File sharing services
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "NAS Server";
        "netbios name" = "nas";
        security = "user";
        "map to guest" = "bad user";
      };
      
      # Example share
      # media = {
      #   path = "/storage/media";
      #   browseable = "yes";
      #   "read only" = "no";
      #   "guest ok" = "no";
      #   "create mask" = "0644";
      #   "directory mask" = "0755";
      #   "valid users" = user;
      # };
    };
  };
  
  # NFS server
  services.nfs.server = {
    enable = true;
    exports = ''
      # /storage/nfs *(rw,sync,no_subtree_check,no_root_squash)
    '';
  };
  
  # Media server
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  
  # ZFS support for storage
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    forceImportRoot = false;
    extraPools = [ "storage" ]; # Adjust pool names as needed
  };
  
  # Auto-scrub ZFS pools monthly
  services.zfs.autoScrub = {
    enable = true;
    interval = "monthly";
    pools = [ "storage" ];
  };
  
  # S.M.A.R.T monitoring
  services.smartd = {
    enable = true;
    autodetect = true;
    notifications = {
      x11.enable = false;
      wall.enable = true;
    };
  };
  
  # System monitoring
  services.prometheus = {
    enable = true;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9100;
      };
      
      smartctl = {
        enable = true;
        port = 9633;
      };
      
      zfs = {
        enable = true;
        port = 9134;
      };
    };
  };
  
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
      };
    };
  };
  
  # Backup services
  services.borgbackup.jobs.homebackup = {
    # Configure backup job
    # paths = [ "/storage/important" ];
    # repo = "/backup/borg";
    # encryption = {
    #   mode = "repokey-blake2";
    #   passCommand = "cat /run/secrets/borg-passphrase";
    # };
    # startAt = "daily";
  };
  
  # Networking
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 
        22     # SSH
        139 445 # Samba
        2049    # NFS
        8096    # Jellyfin
        3000    # Grafana
        9100    # Prometheus node exporter
      ];
      allowedUDPPorts = [
        137 138 # Samba
        2049    # NFS
      ];
    };
  };
  
  # NAS-specific packages
  environment.systemPackages = with pkgs; [
    # File system tools
    zfs
    smartmontools
    hdparm
    
    # Network tools
    nfs-utils
    cifs-utils
    
    # Monitoring
    htop
    iotop
    ncdu
    
    # Media tools
    ffmpeg
    
    # Backup tools
    borgbackup
    restic
    rclone
    
    # System administration
    tmux
    neovim
    
    # Docker compose for additional services
    docker-compose
  ];
  
  # Automatic updates (consider carefully for production)
  # system.autoUpgrade = {
  #   enable = true;
  #   flake = "/path/to/your/flake";
  #   flags = [ "--update-input" "nixpkgs" ];
  #   dates = "04:00";
  #   randomizedDelaySec = "45min";
  # };
}