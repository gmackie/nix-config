# Intel NUC NixOS Configuration Template
{ config, pkgs, lib, inputs, user, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/development.nix
    ../../modules/nixos/secrets.nix
  ];
  
  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  
  # Enable SSH for remote management
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  
  # Kubernetes/container orchestration
  services.k3s = {
    enable = true;
    role = "server";
    
    # Configuration for k3s
    extraFlags = toString [
      "--write-kubeconfig-mode=644"
      "--disable=traefik" # Use custom ingress controller
      "--disable=servicelb" # Use custom load balancer
    ];
  };
  
  # Enable container runtime
  virtualisation = {
    containerd.enable = true;
    
    # Podman as alternative to Docker
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
  };
  
  # Development services
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
  };
  
  services.redis.servers."" = {
    enable = true;
    port = 6379;
  };
  
  # Monitoring stack
  services.prometheus = {
    enable = true;
    port = 9090;
    
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = [ "localhost:9100" ];
        }];
      }
    ];
    
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9100;
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
  
  # Reverse proxy
  services.nginx = {
    enable = true;
    
    virtualHosts = {
      "nuc.local" = {
        locations = {
          "/grafana/" = {
            proxyPass = "http://localhost:3000/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
          
          "/prometheus/" = {
            proxyPass = "http://localhost:9090/";
          };
        };
      };
    };
  };
  
  # Networking
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 
        22     # SSH
        80 443 # HTTP/HTTPS
        3000   # Grafana
        6443   # Kubernetes API
        9090   # Prometheus
        9100   # Node exporter
      ];
    };
    
    # Static IP configuration (adjust for your network)
    # interfaces.eno1.ipv4.addresses = [{
    #   address = "192.168.1.100";
    #   prefixLength = 24;
    # }];
    # defaultGateway = "192.168.1.1";
    # nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };
  
  # Hardware-specific optimizations for NUC
  hardware = {
    cpu.intel.updateMicrocode = true;
    
    # Enable hardware video acceleration
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver # VAAPI
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };
  
  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };
  
  services.thermald.enable = true;
  
  # NUC-specific packages
  environment.systemPackages = with pkgs; [
    # Kubernetes tools
    kubectl
    kubernetes-helm
    k9s
    kubectx
    kustomize
    
    # Container tools
    podman
    podman-compose
    skopeo
    buildah
    
    # Development tools
    git
    gh
    vim
    tmux
    
    # System monitoring
    htop
    iotop
    nethogs
    iftop
    
    # Network tools
    nmap
    tcpdump
    wireshark-cli
    
    # Hardware monitoring
    lm_sensors
    smartmontools
  ];
  
  # Auto-updates for homelab use
  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos";
    flags = [ "--update-input" "nixpkgs" "--no-write-lock-file" ];
    dates = "04:00";
    randomizedDelaySec = "45min";
  };
  
  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}