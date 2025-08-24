{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../modules/shared/common-packages.nix
  ];
  
  # Nix configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "mackieg" ];
    };
    
    gc = {
      automatic = true;
      interval = { Hour = 3; Day = 7; };
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
  
  # macOS-specific packages
  environment.systemPackages = with pkgs; [
    mas # Mac App Store CLI
    iterm2
    rectangle # Window management
    raycast # Spotlight replacement
    stats # System monitor
  ] ++ (with pkgs.darwin; [
    apple-sdk
  ]);
  
  # Homebrew integration (for casks and Mac App Store apps)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    
    taps = [
      "homebrew/cask"
      "homebrew/cask-fonts"
    ];
    
    casks = [
      "visual-studio-code"
      "docker"
      "firefox"
      "slack"
      "spotify"
    ];
    
    masApps = {
      # Add Mac App Store apps here
      # "App Name" = app_id;
    };
  };
  
  # Services
  services = {
    nix-daemon.enable = true;
  };
  
  # Programs
  programs = {
    zsh.enable = true;
  };
  
  # Users
  users.users.mackieg = {
    home = "/Users/mackieg";
    shell = pkgs.zsh;
  };
  
  nixpkgs.config.allowUnfree = true;
}