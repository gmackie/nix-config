{ config, pkgs, lib, ... }:

{
  # Enable SSH daemon for headless installation with NUC config
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

  # Pre-install the NUC configuration in the installer
  environment.etc."nixos-nuc-config.nix".text = ''
    # Intel NUC NixOS Configuration for K3S Homelab
    { config, pkgs, lib, ... }:

    {
      imports = [
        ./hardware-configuration.nix
      ];
      
      # Boot configuration
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      # System info
      networking.hostName = "nuc-k3s";
      time.timeZone = "America/New_York";
      
      # Enable SSH for remote management
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      # Create user account
      users.users.mackieg = {
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" ];
        openssh.authorizedKeys.keys = [
          # Add your SSH keys here after installation
        ];
      };

      # Enable sudo for wheel group
      security.sudo.wheelNeedsPassword = false;
      
      # Kubernetes/container orchestration
      services.k3s = {
        enable = true;
        role = "server";
        
        extraFlags = toString [
          "--write-kubeconfig-mode=644"
          "--disable=traefik"
          "--disable=servicelb"
        ];
      };
      
      # Enable container runtime
      virtualisation = {
        containerd.enable = true;
        
        podman = {
          enable = true;
          dockerCompat = true;
          dockerSocket.enable = true;
        };

        docker.enable = true;
      };
      
      # Basic development services
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_15;
        
        authentication = pkgs.lib.mkOverride 10 '''
          #type database  DBuser  auth-method
          local all       all     trust
        ''';
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
          "192.168.0.6" = {
            locations = {
              "/grafana/" = {
                proxyPass = "http://localhost:3000/";
                extraConfig = '''
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                ''';
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
        
        # Static IP configuration
        interfaces.enp3s0.ipv4.addresses = [{
          address = "192.168.0.6";
          prefixLength = 24;
        }];
        defaultGateway = "192.168.0.1";
        nameservers = [ "8.8.8.8" "8.8.4.4" ];
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
            intel-media-driver
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
      
      # Essential packages
      environment.systemPackages = with pkgs; [
        kubectl
        kubernetes-helm
        k9s
        kubectx
        kustomize
        
        podman
        podman-compose
        skopeo
        buildah
        
        git
        gh
        vim
        tmux
        curl
        wget
        
        htop
        iotop
        nethogs
        iftop
        
        nmap
        tcpdump
        
        lm_sensors
        smartmontools
      ];
      
      # Auto-updates
      system.autoUpgrade = {
        enable = true;
        dates = "04:00";
        randomizedDelaySec = "45min";
      };
      
      # Automatic garbage collection
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      # Enable flakes
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      system.stateVersion = "24.05";
    }
  '';

  # Add useful tools for installation
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