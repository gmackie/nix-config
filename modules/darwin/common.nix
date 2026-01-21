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
      trusted-users = [
        "root"
        user
      ];
    };

    gc = {
      automatic = true;
      interval = {
        Hour = 3;
        Day = 7;
      };
      options = "--delete-older-than 7d";
    };
  };

  # macOS system preferences
  system = {
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };

      dock = {
        autohide = true;
        show-recents = false;
        tilesize = 48;
        orientation = "bottom";
      };

      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        FXEnableExtensionChangeWarning = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };

    stateVersion = 4;
  };

  # Enable Touch ID for sudo
  security.pam.enableSudoTouchIdAuth = true;

  # Environment variables
  environment.variables = {
    EDITOR = "vim";
    LANG = "en_US.UTF-8";
  };

  # Core macOS packages
  environment.systemPackages = with pkgs; [
    # Core utilities
    wget
    vim
    neovim
    curl
    zsh
    git
    gh
    htop
    btop
    unzip
    tmux
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

    # macOS-specific
    mas # Mac App Store CLI
    iterm2
    rectangle # Window management
    raycast # Spotlight replacement
    stats # System monitor
  ] ++ (with pkgs.darwin; [
    apple-sdk
  ]);

  # Services
  services = {
    nix-daemon.enable = true;
  };

  # Programs
  programs = {
    zsh.enable = true;
  };

  # User configuration
  users.users.${user} = {
    home = "/Users/${user}";
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;
}
