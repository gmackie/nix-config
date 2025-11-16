{
  config,
  pkgs,
  lib,
  user,
  ...
}:

{
  # Nix configuration
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        user
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Timezone and locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # User configuration
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable zsh
  programs.zsh.enable = true;

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Sudo configuration
  security.sudo.wheelNeedsPassword = false;

  # Avahi/mDNS for .local hostname resolution
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enable mDNS NSS support for IPv4
    nssmdns6 = true; # Enable mDNS NSS support for IPv6
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  # Common system packages
  environment.systemPackages = with pkgs; [
    # Core utilities
    wget
    vim
    neovim
    nano
    curl
    zsh
    git
    gh
    htop
    btop
    pv
    killall
    unzip
    tmux
    stow
    gnupg
    ripgrep
    fd
    fzf
    bat
    eza
    zoxide
    direnv

    # AI Development tools
    claude-code

    # Development tools
    gcc
    gnumake
    binutils

    # Network tools
    nmap
    telnet
    mtr
    dig
    traceroute

    # System monitoring
    ncdu
    iotop
    lsof

    # Archive tools
    unrar
    p7zip

    # JSON/YAML tools
    jq
    yq

    # Process management
    killall
    pstree
  ];

  # Environment variables
  environment.variables = {
    EDITOR = "vim";
  };

  # System version
  system.stateVersion = "24.05";
}
